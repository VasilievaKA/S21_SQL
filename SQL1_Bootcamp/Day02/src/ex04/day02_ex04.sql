select pizza_name, pizzeria.name, price from menu 
inner join pizzeria on pizzeria.id = pizzeria_id
where pizza_name like 'mush%' or pizza_name like 'pep%' order by 1, 2


