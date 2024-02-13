select p1.name as person_name1, p2.name as person_name2, p2.address as common_address from person p1 
cross join (select name, address from person) p2
where p2.name > p1.name and p2.address = p1.address
order by 1, 2, 3
