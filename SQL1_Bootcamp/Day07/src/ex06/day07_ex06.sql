select name,
       count(name) as count_of_orders,
       round(avg(price), 2) as average_price,
       max(price) as max_price,
       min(price) as min_price
from person_order
inner join menu m on m.id = person_order.menu_id
inner join pizzeria p on p.id = m.pizzeria_id
group by name
order by 1