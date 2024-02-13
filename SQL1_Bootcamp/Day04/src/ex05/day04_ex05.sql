create view v_price_with_discount as
(select name, pizza_name, price, price*0.9 as discount_price from person_order
inner join public.menu m on m.id = person_order.menu_id
inner join public.person p on p.id = person_order.person_id
order by name, pizza_name)