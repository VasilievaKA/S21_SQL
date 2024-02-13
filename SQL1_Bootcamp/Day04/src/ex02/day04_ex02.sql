create view v_generated_dates as
select cast(generate_series as Date) as generated_date from generate_series(date '2022-01-01', date '2022-01-31', '1 day')