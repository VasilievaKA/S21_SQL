select p.name as pizzeria_name from person_order
               inner join public.menu m on m.id = person_order.menu_id
               inner join public.pizzeria p on p.id = m.pizzeria_id
               where person_id in (select id from person where gender like 'fe%')
except
select p.name as pizzeria_name from person_order
               inner join public.menu m on m.id = person_order.menu_id
               inner join public.pizzeria p on p.id = m.pizzeria_id
               where person_id in (select id from person where gender like 'ma%')
order by pizzeria_name