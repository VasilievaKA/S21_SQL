select name as object_name from person 
UNION all
select pizza_name as object_name from menu 
order by object_name
