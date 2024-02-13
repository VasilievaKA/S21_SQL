select person.name from person_order  
inner join person on person_id = person.id
where gender like 'ma%' and address in ('Moscow', 'Samara') and menu_id in (
	select id from menu where pizza_name like 'pep%' or pizza_name like 'mush%')
order by 1 desc

