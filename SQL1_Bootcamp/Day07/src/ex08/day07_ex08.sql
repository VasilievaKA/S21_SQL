select address, p.name, count(p.name) from person_order
inner join menu m on m.id = person_order.menu_id
inner join pizzeria p on p.id = m.pizzeria_id
inner join person p1 on p1.id = person_order.person_id
group by p.name, address
order by 1, 2