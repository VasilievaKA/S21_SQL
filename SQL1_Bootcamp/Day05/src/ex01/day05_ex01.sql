select pizza_name, name from menu, pizzeria;

SET enable_seqscan = off;
SET enable_bitmapscan = off;
explain analyze select pizza_name, name from menu
    inner join pizzeria p on p.id = menu.pizzeria_id;