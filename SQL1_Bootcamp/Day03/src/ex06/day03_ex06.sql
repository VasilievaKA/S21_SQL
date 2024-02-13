select m2.pizza_name as pizza_name, pizzeria_name1, pizzeria_name2, m2.price as price from
                (select price, pizzeria.name as pizzeria_name1 from menu
inner join pizzeria on menu.pizzeria_id = pizzeria.id) as m1
cross join (select price, pizza_name, pizzeria.name as pizzeria_name2 from menu
inner join pizzeria on menu.pizzeria_id = pizzeria.id) as m2
where m1.price = m2.price and m1.pizzeria_name1 < m2.pizzeria_name2
order by 1