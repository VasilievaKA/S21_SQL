select order_date, concat(person.name, '(age:', age, ')') as person_information 
from (select person_id as id, order_date 
	  from person_order) as np 
natural join person 
order by order_date, person_information
