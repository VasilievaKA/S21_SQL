select pizza_name, price, pizzeria.name as pizzeria_name from menu
inner join pizzeria on menu.pizzeria_id = pizzeria.id
         where menu.id in (select id from menu
                                     except select distinct menu_id from person_order)
order by pizza_name, price