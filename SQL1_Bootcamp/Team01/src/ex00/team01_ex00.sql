select coalesce(u.name, 'not defined') as name,
       coalesce(lastname, 'not defined') as lastname,
       type, volume,
       coalesce(c.name, 'not defined') as currency_name,
       coalesce(rate_to_usd, 1) as last_rate_to_usd,
       (volume * coalesce(rate_to_usd, 1)) as total_volume_in_usd
    from (
    select user_id, currency_id, type, sum(money) as volume
    from balance
    group by user_id, currency_id, type) as balance
join "user" u on u.id = balance.user_id
full join
        (select * from currency
        order by updated desc limit 3) c on c.id = balance.currency_id
order by name desc, lastname, type