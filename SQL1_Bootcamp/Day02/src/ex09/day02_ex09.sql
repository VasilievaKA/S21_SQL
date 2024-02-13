select person.name from person_order 
inner join person on person.id = person_id
inner join menu on menu.id = menu_id 
where gender='female' and pizza_name like 'cheese%'
intersect 
select person.name from person_order 
inner join person on person.id = person_id
inner join menu on menu.id = menu_id 
where gender='female' and pizza_name like 'pep%'
 


