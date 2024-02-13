select order_date as action_date, person.name from person_order 
inner join person on person_id=person.id 
intersect 
select visit_date as action_date, person.name from person_visits
inner join person on person_id=person.id 
order by action_date, name desc

