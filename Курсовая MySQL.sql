/* 
* Данная бд создана для сохранения всех данных из торговых аппаратов, а так же ведения
* статистики и ее хранения. Хоть и всю информацию можно посмотреть из телеметрии,
* все же полную статистику вести по тем данным невозможно. Так же, т.к я работал у тех,
* кто предоставляет услуги телеметрии я решил перестраховаться, мысли создать эту
* бд были давно. Данная бд будет разрабатываться и оптимизироваться в дальнейшем.
*/



drop table if exists machines;
create table machines (
	`number` int,
	`model` varchar(50),
	`place` varchar(50),
	`id` int primary key auto_increment,
	`Cost` bigint default null,				#для costs реализована хранимая процедура.
	`Total profit` bigint default null		#total profit будет браться из телеметрии, 
);											#но без бэкенда он не будет реализован


insert into machines (`number`, `model`, `place`)
values 
(1, 'jofemar g546', '****'), (2, 'jofemar g546', '****'),
(3, 'jofemar g250', '****'),										#4-го номера нет
(5, 'jofemar g546', '****'), (6, 'jofemar g546', '****'),
(7, 'jofemar g250', '****'), (8, 'jofemar g250', '****'),
(9, 'jofemar g546', '****'), (10, 'jofemar g546', '****'),
(11, 'jofemar g546', '****'), (12, 'jofemar g546', '****'),
(13, 'jofemar g250', '****'), (14, 'jofemar g546', '****'),
(15, 'jofemar g250', '****'), (16, 'jofemar g250', '****" (хол)'),
(17, 'jofemar g250', '****'), (18, 'jofemar g546', '****'),
(19, 'jofemar g546', '****'), (20, 'jofemar g546', '****'),
(21, 'jofemar g546', '****'), (22, 'jofemar g250', '****'),
(23, 'jofemar g250', '****'), (24, 'jofemar g546', '****'),
(25, 'jofemar g546', '****'), (26, '****'),
(27, 'jofemar g250', '****'), (28, 'jofemar g546', '****'),
(29, 'jofemar g546', '****');


drop table if exists coins;						#данная таблица будет заполняться 
create table coins (							#после того как будет разработан бэкенд
	id int primary key auto_increment,
	machine_num int,
	name varchar(255),
	place varchar(255),
	1_ruble int,
	5_ruble int,
	10_ruble int,
	50_ruble int,
	100_ruble int,
	total bigint,
	
	foreign key (id) references machines(id)
);


insert into coins(name, place, machine_num)
select model, place, `number`
from machines
where machine_id is true;


drop table if exists checks;					#данная таблица будет заполняться 
create table checks ( 							#после того как будет разработан бэкенд
	id int primary key auto_increment,
	machine_num int,
	place varchar(255),
	model varchar(255),
	drink varchar(255),
	summ int,
	value int,
	profit int,
	surrender int,
	`ОФД` varchar(255),
	
	foreign key (id) references machines(id)
);


drop table if exists events;					#данная таблица будет заполняться 
create table events (							#после того как будет разработан бэкенд
	id int primary key auto_increment,
	`type` varchar(255),
	event varchar(255),
	machine_model varchar(255),
	place varchar(255),
	`date` datetime,
	
	foreign key(id) references machines(id)
);


drop table if exists collections;				#данная таблица будет заполняться 
create table collections (						#после того как будет разработан бэкенд
	id int primary key auto_increment,
	`date` date,
	machine_id int,
	model varchar(255),
	checks varchar(255),
	coins bigint,
	cash bigint,
	profit bigint,
	
	foreign key(id) references machines(id)
);

drop table if exists sells;						#данная таблица будет заполняться 
create table sells (							#после того как будет разработан бэкенд
	id int primary key auto_increment,
	`date` datetime,
	machine_id int,
	model varchar(255),
	place varchar(255),
	profit int,
	
	foreign key(id) references machines(id)
);


drop table if exists machine_models;
create table machine_models (
	id int primary key auto_increment,
	name varchar(255),
	num_of_drinks int,
	quantity int
);


insert into machine_models(name, num_of_drinks, quantity)
values ('Jofemar g546', 20, (select count(model) from machines where model like 'jofemar g546') ),
('Jofemar g250', 15, (select count(model) from machines where model like 'jofemar g250') );


alter table machines
add column machine_id int,
add foreign key (machine_id) references machine_models(id); 


update machines 
set machine_id = (
	select id
	from machine_models 
	where name like 'Jofemar g546'
)
where model like 'jofemar g546';


update machines 
set machine_id = (
	select id
	from machine_models 
	where name like 'Jofemar g250'
)
where model like 'jofemar g250';


drop table if exists ingridients;
create table ingridients (
	id int primary key auto_increment,
	name varchar(255),
	value int,
	costs double default null comment 'себестоимость ингридиента за грамм/штуку' 
);


insert into ingridients (name, value)
values
('Кофе', 600), ('Шоколад', 275), ('Сливки', 285), ('Ваниль', 285), ('Вода', 4), ('Сахар', 20),
('Орех', 285), ('Кисель', 275), ('Стаканчики', 2500), ('Размешиватели', 500);


update ingridients 			#ругаюсь на триггеры, потому что хотел изменять costs сразу после 
set costs = value/1000		#after update value, но изменять поля таблицы с триггером - нельзя.
where costs is null;		#set new.costs = value/1000 - не работает.


drop table if exists recipes;
create table recipes (
	name varchar(255),
	coffe double comment 'Кофе',
	choc int comment 'Шоколад',
	milk int comment 'Молоко',
	vanila int comment 'Ваниль',
	nut int comment 'Орех',
	jelly int comment 'Кисель',
	water int comment 'Вода',
	sugar int comment 'Сахар',
	cups int comment 'Стаканы',
	sticks int comment 'Размешиватели',
	cost double comment 'Себестоимость',	   
	profit double comment 'Маржа'
);


insert into recipes (name, coffe, choc, milk, vanila, nut, jelly, water, sugar, cups, sticks)
values 
('espresso', 7.75, null, null, null, null, null, 120, 8, 1, 1),
('americano', 7.75, null, null, null, null, null, 210, 8, 1, 1),
('macchiato', 7.75, null, 12, null, null, null, 210, 8, 1, 1),
('mocachino', 7.75, 14, 6, null, null, null, 210, 8, 1, 1),
('cappuchino', 7.75, null, 18, null, null, null, 210, 8, 1, 1),
('mocha nut', null, null, null, null, 30, null, 210, null, 1, null),   							#Не смейтесь, мокко по-английски так и пишется :)
('super mocha nut', null, null, null, null, 36, null, 210, null, 1, null),
('milk mocha nut', null, null, 12, null, 26, null, 210, null, 1, 1),
('double espresso', 7.75, null, null, null, null, null, 180, 8, 1, 1),
('jelly', null, null, null, null, null, 18, 210, null, 1, 1),
('choc', null, 32, null, null, null, null, 210, null, 1, null),
('double choc', null, 40, null, null, null, null, 210, null, 1, null),
('milk choc', null, 32, 12, null, null, null, 210, null, 1, 1),
('choc espresso', 7.75, 16, null, null, null, null, 210, 8, 1, 1),
('latte', 7.75, null, 28, null, null, null, 210, 8, 1, 1),
('mocha vanila', null, null, null, 30, null, null, 210, null, 1, null),
('super mocha vanila', null, null, null, 36, null, null, 210, null, 1, null),
('milk mocha vanila', null, null, 12, 26, null, null, 210, null, 1, null),
('cappuchino nut',7.75, null, 14, null, 8, null, 210, 8, 1, 1),
('cappuchino vanila', 7.75, null, 14, 8, null, null, 210, 8, 1, 1);


# представления


update machines
set `Total profit` = 100
where `number` = 1;

update machines
set `Total profit` = 200
where `number` = 2;

update machines
set `Total profit` = 300
where `number` = 3;


# представление, которое выбирает лучший по продажам т/а

create or replace view top_seles as
	select `number`, model, place, `Total profit`
	from machines
	where `Total profit` = (select max(`Total profit`) from machines);

select * from top_seles;


# представление, которое выбирает худший по продажам т/а

create or replace view worst_sales as
	select `number`, model, place, `Total profit`
	from machines
	where `Total profit` = (select min(`Total profit`) from machines);

select * from worst_sales;

# триггеры которые меняют количество аппаратов в machine_models

delimiter //															# если будет ошибка:
CREATE DEFINER=`root`@`localhost` TRIGGER `after insert` 				# я не знаю что с dbeaver
AFTER INSERT 															# через cmd все работает
	ON `machines` FOR EACH ROW 											# и через "создать тригер"
begin 																	# соответственно потом тестил
	update coffee_machines.machine_models
	set quantity = quantity+1
	where name = (select * from
					(select model from machines order by id desc limit 1) as temp); 
end; //


delimiter //
CREATE TRIGGER `before delete`
before delete
	ON machines FOR EACH ROW
begin
	update coffee_machines.machine_models
	set quantity = quantity-1
	where name = (select * from
					(select old.model from machines order by id desc limit 1) as temp);
end; //



# Не пугайтесь, это всего лишь расчет себестоимости каждого из напитков в recipes. 

update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3 + t4 + t5) as `sum` from
				(select coffe*
					(select costs from ingridients where name like 'Кофе') as t1
						from recipes where name like 'espresso') as tm1,
				(select water*
					(select costs from ingridients where name like 'Вода') as t2
						from recipes where name like 'espresso') as tm2,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t3
						from recipes where name like 'espresso') as tm3,
				(select sticks*
					(select costs from ingridients where name like 'Размешиватели') as t4
						from recipes where name like 'espresso') as tm4,
				(select sugar*
					(select costs from ingridients where name like 'Сахар') as t5
						from recipes where name like 'espresso') as tm5) as temp)
where name like 'espresso';

update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3 + t4 + t5) as `sum` from
				(select coffe*
					(select costs from ingridients where name like 'Кофе') as t1
						from recipes where name like 'americano') as tm1,
				(select water*
					(select costs from ingridients where name like 'Вода') as t2
						from recipes where name like 'americano') as tm2,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t3
						from recipes where name like 'americano') as tm3,
				(select sticks*
					(select costs from ingridients where name like 'Размешиватели') as t4
						from recipes where name like 'americano') as tm4,
				(select sugar*
					(select costs from ingridients where name like 'Сахар') as t5
						from recipes where name like 'americano') as tm5) as temp)
where name like 'americano';


update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3 + t4 + t5 + t6) as `sum` from
				(select coffe*
					(select costs from ingridients where name like 'Кофе') as t1
						from recipes where name like 'macchiato') as tm1,
				(select water*
					(select costs from ingridients where name like 'Вода') as t2
						from recipes where name like 'macchiato') as tm2,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t3
						from recipes where name like 'macchiato') as tm3,
				(select sticks*
					(select costs from ingridients where name like 'Размешиватели') as t4
						from recipes where name like 'macchiato') as tm4,
				(select sugar*
					(select costs from ingridients where name like 'Сахар') as t5
						from recipes where name like 'macchiato') as tm5,
				(select milk*
					(select costs from ingridients where name like 'Сливки') as t6
						from recipes where name like 'macchiato') as tm6) as temp)
where name like 'macchiato';


update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3 + t4 + t5 + t6) as `sum` from
				(select coffe*
					(select costs from ingridients where name like 'Кофе') as t1
						from recipes where name like 'mocachino') as tm1,
				(select water*
					(select costs from ingridients where name like 'Вода') as t2
						from recipes where name like 'mocachino') as tm2,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t3
						from recipes where name like 'mocachino') as tm3,
				(select sticks*
					(select costs from ingridients where name like 'Размешиватели') as t4
						from recipes where name like 'mocachino') as tm4,
				(select sugar*
					(select costs from ingridients where name like 'Сахар') as t5
						from recipes where name like 'mocachino') as tm5,
				(select milk*
					(select costs from ingridients where name like 'Сливки') as t6
						from recipes where name like 'mocachino') as tm6,
				(select choc*
					(select costs from ingridients where name like 'Шоколад') as t7
						from recipes where name like 'mocachino') as tm7) as temp)
where name like 'mocachino';


update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3 + t4 + t5 + t6) as `sum` from
				(select coffe*
					(select costs from ingridients where name like 'Кофе') as t1
						from recipes where name like 'cappuchino') as tm1,
				(select water*
					(select costs from ingridients where name like 'Вода') as t2
						from recipes where name like 'cappuchino') as tm2,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t3
						from recipes where name like 'cappuchino') as tm3,
				(select sticks*
					(select costs from ingridients where name like 'Размешиватели') as t4
						from recipes where name like 'cappuchino') as tm4,
				(select sugar*
					(select costs from ingridients where name like 'Сахар') as t5
						from recipes where name like 'cappuchino') as tm5,
				(select milk*
					(select costs from ingridients where name like 'Сливки') as t6
						from recipes where name like 'cappuchino') as tm6) as temp)
where name like 'cappuchino';


update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3) as `sum` from
				(select nut*
					(select costs from ingridients where name like 'Орех') as t1
						from recipes where name like 'mocha nut') as tm1,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t2
						from recipes where name like 'mocha nut') as tm2,
				(select water*
					(select costs from ingridients where name like 'Вода') as t3
						from recipes where name like 'mocha nut') as tm3) as temp)
where name like 'mocha nut';


update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3) as `sum` from
				(select nut*
					(select costs from ingridients where name like 'Орех') as t1
						from recipes where name like 'super mocha nut') as tm1,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t2
						from recipes where name like 'super mocha nut') as tm2,
				(select water*
					(select costs from ingridients where name like 'Вода') as t3
						from recipes where name like 'super mocha nut') as tm3) as temp)
where name like 'super mocha nut';


update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3 + t4) as `sum` from
				(select nut*
					(select costs from ingridients where name like 'Орех') as t1
						from recipes where name like 'milk mocha nut') as tm1,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t2
						from recipes where name like 'milk mocha nut') as tm2,
				(select milk*
					(select costs from ingridients where name like 'Сливки') as t3
						from recipes where name like 'milk mocha nut') as tm3,
				(select water*
					(select costs from ingridients where name like 'Вода') as t4
						from recipes where name like 'milk mocha nut') as tm4) as temp)
where name like 'milk mocha nut';


update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3 + t4 + t5) as `sum` from
				(select coffe*
					(select costs from ingridients where name like 'Кофе') as t1
						from recipes where name like 'espresso') as tm1,
				(select water*
					(select costs from ingridients where name like 'Вода') as t2
						from recipes where name like 'espresso') as tm2,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t3
						from recipes where name like 'espresso') as tm3,
				(select sticks*
					(select costs from ingridients where name like 'Размешиватели') as t4
						from recipes where name like 'espresso') as tm4,
				(select sugar*
					(select costs from ingridients where name like 'Сахар') as t5
						from recipes where name like 'espresso') as tm5) as temp)
where name like 'double espresso';


update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3 + t4) as `sum` from
				(select jelly*
					(select costs from ingridients where name like 'Кисель') as t1
						from recipes where name like 'jelly') as tm1,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t2
						from recipes where name like 'jelly') as tm2,
				(select sticks*
					(select costs from ingridients where name like 'Размешиватели') as t3
						from recipes where name like 'jelly') as tm3,
				(select water*
					(select costs from ingridients where name like 'Вода') as t4
						from recipes where name like 'jelly') as tm4) as temp)
where name like 'jelly';


update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3) as `sum` from
				(select choc*
					(select costs from ingridients where name like 'Шоколад') as t1
						from recipes where name like 'choc') as tm1,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t2
						from recipes where name like 'choc') as tm2,
				(select water*
					(select costs from ingridients where name like 'Вода') as t3
						from recipes where name like 'choc') as tm3) as temp)
where name like 'choc';


update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3) as `sum` from
				(select choc*
					(select costs from ingridients where name like 'Шоколад') as t1
						from recipes where name like 'double choc') as tm1,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t2
						from recipes where name like 'double choc') as tm2,
				(select water*
					(select costs from ingridients where name like 'Вода') as t3
						from recipes where name like 'double choc') as tm3) as temp)
where name like 'double choc';


update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3 + t4) as `sum` from
				(select choc*
					(select costs from ingridients where name like 'Шоколад') as t1
						from recipes where name like 'milk choc') as tm1,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t2
						from recipes where name like 'milk choc') as tm2,
				(select milk*
					(select costs from ingridients where name like 'Сливки') as t3
						from recipes where name like 'milk choc') as tm3,
				(select water*
					(select costs from ingridients where name like 'Вода') as t4
						from recipes where name like 'milk choc') as tm4) as temp)
where name like 'milk choc';


update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3 + t4 + t5) as `sum` from
				(select coffe*
					(select costs from ingridients where name like 'Кофе') as t1
						from recipes where name like 'choc espresso') as tm1,
				(select water*
					(select costs from ingridients where name like 'Вода') as t2
						from recipes where name like 'choc espresso') as tm2,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t3
						from recipes where name like 'choc espresso') as tm3,
				(select sticks*
					(select costs from ingridients where name like 'Размешиватели') as t4
						from recipes where name like 'choc espresso') as tm4,
				(select choc*
					(select costs from ingridients where name like 'Шоколад') as t5
						from recipes where name like 'choc espresso') as tm5,
				(select sugar*
					(select costs from ingridients where name like 'Сахар') as t6
						from recipes where name like 'choc espresso') as tm6) as temp)
where name like 'choc espresso';


update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3 + t4 + t5 + t6) as `sum` from
				(select coffe*
					(select costs from ingridients where name like 'Кофе') as t1
						from recipes where name like 'latte') as tm1,
				(select water*
					(select costs from ingridients where name like 'Вода') as t2
						from recipes where name like 'latte') as tm2,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t3
						from recipes where name like 'latte') as tm3,
				(select sticks*
					(select costs from ingridients where name like 'Размешиватели') as t4
						from recipes where name like 'latte') as tm4,
				(select sugar*
					(select costs from ingridients where name like 'Сахар') as t5
						from recipes where name like 'latte') as tm5,
				(select milk*
					(select costs from ingridients where name like 'Сливки') as t6
						from recipes where name like 'latte') as tm6) as temp)
where name like 'latte';


update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3) as `sum` from
				(select vanila*
					(select costs from ingridients where name like 'Ваниль') as t1
						from recipes where name like 'mocha vanila') as tm1,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t2
						from recipes where name like 'mocha vanila') as tm2,
				(select water*
					(select costs from ingridients where name like 'Вода') as t3
						from recipes where name like 'mocha vanila') as tm3) as temp)
where name like 'mocha vanila';


update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3) as `sum` from
				(select vanila*
					(select costs from ingridients where name like 'Ваниль') as t1
						from recipes where name like 'super mocha vanila') as tm1,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t2
						from recipes where name like 'super mocha vanila') as tm2,
				(select water*
					(select costs from ingridients where name like 'Вода') as t3
						from recipes where name like 'super mocha vanila') as tm3) as temp)
where name like 'super mocha vanila';


update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3 + t4) as `sum` from
				(select vanila*
					(select costs from ingridients where name like 'Ваниль') as t1
						from recipes where name like 'milk mocha vanila') as tm1,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t2
						from recipes where name like 'milk mocha vanila') as tm2,
				(select milk*
					(select costs from ingridients where name like 'Сливки') as t3
						from recipes where name like 'milk mocha vanila') as tm3,
				(select water*
					(select costs from ingridients where name like 'Вода') as t4
						from recipes where name like 'milk mocha vanila') as tm4) as temp)
where name like 'milk mocha vanila';


update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3 + t4 + t5 + t6 + t7) as `sum` from
				(select coffe*
					(select costs from ingridients where name like 'Кофе') as t1
						from recipes where name like 'cappuchino nut') as tm1,
				(select water*
					(select costs from ingridients where name like 'Вода') as t2
						from recipes where name like 'cappuchino nut') as tm2,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t3
						from recipes where name like 'cappuchino nut') as tm3,
				(select sticks*
					(select costs from ingridients where name like 'Размешиватели') as t4
						from recipes where name like 'cappuchino nut') as tm4,
				(select sugar*
					(select costs from ingridients where name like 'Сахар') as t5
						from recipes where name like 'cappuchino nut') as tm5,
				(select milk*
					(select costs from ingridients where name like 'Сливки') as t6
						from recipes where name like 'cappuchino nut') as tm6,
				(select nut*
					(select costs from ingridients where name like 'Орех') as t7
						from recipes where name like 'cappuchino nut') as tm7) as temp)
where name like 'cappuchino nut';


update recipes
set cost = (select `sum` from 
			(select *, sum(t1 + t2 + t3 + t4 + t5 + t6 + t7) as `sum` from
				(select coffe*
					(select costs from ingridients where name like 'Кофе') as t1
						from recipes where name like 'cappuchino vanila') as tm1,
				(select water*
					(select costs from ingridients where name like 'Вода') as t2
						from recipes where name like 'cappuchino vanila') as tm2,
				(select cups*
					(select costs from ingridients where name like 'Стаканчики') as t3
						from recipes where name like 'cappuchino vanila') as tm3,
				(select sticks*
					(select costs from ingridients where name like 'Размешиватели') as t4
						from recipes where name like 'cappuchino vanila') as tm4,
				(select sugar*
					(select costs from ingridients where name like 'Сахар') as t5
						from recipes where name like 'cappuchino vanila') as tm5,
				(select milk*
					(select costs from ingridients where name like 'Сливки') as t6
						from recipes where name like 'cappuchino vanila') as tm6,
				(select vanila*
					(select costs from ingridients where name like 'Ваниль') as t7
						from recipes where name like 'cappuchino vanila') as tm7) as temp)
where name like 'cappuchino vanila';