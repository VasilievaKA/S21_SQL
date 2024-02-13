select  
case 
	when person.name is null then '-' 
	else person.name 
end as person_name, visit_date, 
case 
	when pizzeria.name is null then '-' 
	else pizzeria.name 
end as pizzeria_name 
from (select * from person_visits 
	  where visit_date between '2022-01-01' and '2022-01-03') as pv
full join person on person.id=person_id 
full join pizzeria on pizzeria.id=pizzeria_id 
order by person_name, visit_date, pizzeria_name


