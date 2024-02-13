select p.name as person_name, m.pizza_name as pizza_name, pi.name as pizzeria_name
from person_order 
inner join person as p on p.id=person_id 
inner join menu as m on m.id=menu_id 
inner join pizzeria as pi on m.pizzeria_id=pi.id 
order by person_name, pizza_name, pizzeria_name
