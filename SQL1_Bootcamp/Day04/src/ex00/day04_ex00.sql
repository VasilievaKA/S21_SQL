create view v_persons_female as select * from person where gender like 'f%';
create view v_persons_male as select * from person where gender like 'm%'