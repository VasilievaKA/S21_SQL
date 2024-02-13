-- insert into currency values (100, 'EUR', 0.85, '2022-01-01 13:29'),
--                             (100, 'EUR', 0.79, '2022-01-08 13:29');
with res as (select user_id, currency.id, name,  money,
       (select rate_to_usd from currency
            where b.updated > currency.updated and currency.id = currency_id
            order by 1 limit 1) as min,
       (select rate_to_usd from currency
            where b.updated < currency.updated and currency.id = currency_id
            order by 1 limit 1) as max from currency
join balance b on currency.id = b.currency_id
group by money, name, currency.id, b.updated, currency_id, user_id
order by min desc, max)
select coalesce("user".name, 'not defined') as name,
       coalesce(lastname, 'not defined') as lastname,
       res.name as currency_name,
       (money * coalesce(min, max)) as currency_in_usd
       from res
left join "user" on user_id = "user".id
order by 1 desc, 2, 3
