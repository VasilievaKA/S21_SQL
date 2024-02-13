with res as (select p.name as name, pizzeria_id, count(pizzeria_id) as c from person_visits
inner join pizzeria p on p.id = person_visits.pizzeria_id
group by name, pizzeria_id),
    res2 as (select p2.name as name, pizzeria_id, count(name) as c from person_order
inner join menu m on m.id = person_order.menu_id
inner join pizzeria p2 on p2.id = m.pizzeria_id
group by name, pizzeria_id)
select res.name,
case
    when res2.c is null then res.c
    when res.c is null then res2.c
    else (res.c + res2.c)
end as total_count from res
full join res2 on res.pizzeria_id = res2.pizzeria_id
order by total_count desc