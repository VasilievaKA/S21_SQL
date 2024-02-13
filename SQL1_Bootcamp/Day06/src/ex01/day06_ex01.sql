INSERT INTO person_discounts with res as (select person_id, pizzeria_id, count(pizzeria_id) as orders_amount from person_order
inner join menu m on m.id = person_order.menu_id
        group by person_id, pizzeria_id
         order by person_id, pizzeria_id)
select row_number() over () as id, person_id, pizzeria_id,
       case
           when orders_amount = 1 then 10.5
           when orders_amount = 2 then 22
           else 30 end
       as discount from res;

