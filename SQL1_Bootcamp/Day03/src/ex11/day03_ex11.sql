update menu
set price = price * 0.9
where pizza_name = 'greek pizza';

select * from menu where pizza_name = 'greek pizza';