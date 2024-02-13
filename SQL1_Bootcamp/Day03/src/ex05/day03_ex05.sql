select p.name as pizzeria_name from person_visits pv inner join public.pizzeria p on p.id = pv.pizzeria_id
                   where person_id = (select id from person where name = 'Andrey')
except
select p2.name as pizzeria_name from person_order
    inner join public.menu m on m.id = person_order.menu_id
    inner join public.pizzeria p2 on p2.id = m.pizzeria_id
         where person_id = (select id from person where name = 'Andrey')
order by pizzeria_name