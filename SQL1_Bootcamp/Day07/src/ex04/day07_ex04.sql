select name, count_of_visits from
            (select person_id, count(person_id) as count_of_visits from person_visits
        group by person_id) as new
inner join person on new.person_id = person.id
group by name, count_of_visits
having count_of_visits > 3
