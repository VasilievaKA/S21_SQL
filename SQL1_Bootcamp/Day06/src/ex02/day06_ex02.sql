select p.name, pizza_name, price, (price * (1 - discount/100)), p2.name from person_order
inner join menu m on m.id = person_order.menu_id
inner join person p on p.id = person_order.person_id
inner join person_discounts pd on p.id = pd.person_id
inner join pizzeria p2 on p2.id = m.pizzeria_id
order by 1, 2;