select name from pizzeria 
where id in (select id from pizzeria except 
			 select pizzeria_id from person_visits);


select name from pizzeria
where exists (select id from pizzeria p where p.id = pizzeria.id
        and not exists (select pizzeria_id from person_visits where pizzeria_id = p.id));