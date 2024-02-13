select name, rating from pizzeria 
left join person_visits on pizzeria.id = pizzeria_id 
where pizzeria_id is null
