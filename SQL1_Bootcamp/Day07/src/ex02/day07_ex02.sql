(select name, count(person_id), 'visit' as action_type
from person_visits
inner join pizzeria p on p.id = person_visits.pizzeria_id
group by name
order by 2 desc
limit 3)
union
(select p2.name, count(person_id), 'order' as action_type from person_order
inner join menu m on m.id = person_order.menu_id
inner join pizzeria p2 on p2.id = m.pizzeria_id
group by p2.name
order by 2 desc
limit 3)
order by action_type, 2 desc