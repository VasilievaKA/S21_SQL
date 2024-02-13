select id from menu
except
select distinct menu_id
from person_order
order by 1
