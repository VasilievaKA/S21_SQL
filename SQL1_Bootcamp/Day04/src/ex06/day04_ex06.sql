create materialized view mv_dmitriy_visits_and_eats as
(select pizzeria.name as pizzeria from person_visits
inner join pizzeria on pizzeria.id = pizzeria_id
inner join menu on pizzeria.id = menu.pizzeria_id
where person_id in (select id from person
					where name = 'Dmitriy') and visit_date = '2022-01-08' and price <= 800)
