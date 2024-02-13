select pizza_name, pizzeria.name as pizzeria_name from person_order 
inner join menu on menu.id = menu_id 
inner join pizzeria on pizzeria.id = pizzeria_id
where person_id in (select id from person 
					where name in ('Denis', 'Anna'))  
order by 1, 2


