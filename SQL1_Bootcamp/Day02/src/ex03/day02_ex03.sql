with visit as (
	select visit_date + 1 as val from person_visits 
				where person_id between 1 and 2 
				order by id desc 
					  limit 1) 

select cast(generate_series as Date) as missing_date 
from generate_series(
	(select val from visit as pv), 
	date '2022-01-10', '1 day');


