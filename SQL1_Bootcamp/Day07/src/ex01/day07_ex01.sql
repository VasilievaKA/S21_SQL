select name, count(person_id) as count_of_visits
from person_visits
inner join person p on p.id = person_visits.person_id
group by name
order by count_of_visits desc, name
limit 4