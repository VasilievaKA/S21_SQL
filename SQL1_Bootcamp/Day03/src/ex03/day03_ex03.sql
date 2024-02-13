select pizzeria.name from (select pizzeria_id as p_id, count(gender) as count_male from person_visits
inner join public.person p on p.id = person_visits.person_id where gender = 'male'
group by pizzeria_id) as new
inner join (select pizzeria_id, count(gender) as count_female from person_visits
inner join public.person p on p.id = person_visits.person_id where gender = 'female'
group by pizzeria_id) as res on res.pizzeria_id=new.p_id
inner join pizzeria on p_id = pizzeria.id
where count_female != count_male
order by 1
