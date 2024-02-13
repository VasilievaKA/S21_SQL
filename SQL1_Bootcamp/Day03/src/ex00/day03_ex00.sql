select pizza_name, price, p.name as pizzeria_name, visit_date from person_visits as po
inner join pizzeria as p on po.pizzeria_id = p.id
inner join menu m on p.id = m.pizzeria_id
         where person_id = (select id from person where name = 'Kate') and
               price between 800 and 1000
order by pizza_name, price, p.name