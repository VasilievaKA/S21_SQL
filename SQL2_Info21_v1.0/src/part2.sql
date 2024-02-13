-- Task 1
create or replace procedure update_p2p (
    checking_name varchar(20),
    reviewer_name_p varchar(20),
    task_name_p text,
    check_status status,
    check_time_p time
)
language plpgsql as
$$
begin
    if check_status = 'Started' then
        insert into checks
        values ((select max(id) + 1 from checks), checking_name, task_name_p, cast(now() as date));
        insert into p2p
        values ((select max(id) + 1 from p2p), (select max(id) from checks), reviewer_name_p, check_status, check_time_p);
    else
        insert into p2p
        values ((select max(id) + 1 from p2p), (select check_id from p2p
            inner join checks c on c.id = p2p.check_id
            where p2p.reviewer_name = reviewer_name_p and peer_name = checking_name and
                  c.task_name = task_name_p order by p2p.check_time desc limit 1), reviewer_name_p, check_status, check_time_p);
    end if;
end;
$$;

-- можно добавить exception на имена, название задания, время, статус, время с Success должно быть больше с Started,
call update_p2p('kokoschk', 'jeanicet', 'C5_s21_decimal', 'Started', '07:09:32');
call update_p2p('kokoschk', 'jeanicet', 'C5_s21_decimal', 'Success', '07:49:02');


--Task 2
create or replace procedure update_verter (
    checking_name varchar(20),
    task_name_p text,
    check_status status,
    check_time_p time
)
language plpgsql as
$$
begin
    insert into verter
    values ((select max(id) + 1 from verter), (select check_id from p2p
        inner join checks c on c.id = p2p.check_id
        where peer_name = checking_name and
                c.task_name = task_name_p and p2p_status = 'Success'
        order by p2p.check_time desc limit 1), check_status, check_time_p);
end;
$$;

-- можно добавить exception на имя, название задания, время, статус, время с вертера должно быть больше
call update_verter('kokoschk', 'C5_s21_decimal', 'Failure', '08:25:03');


--Task 3
create function update_transferedpoints() returns trigger as
$$
begin
    if new.p2p_status = 'Started' then
        update transferredpoints set point_count = point_count + 1
        where checking_peer = new.reviewer_name and
        checked_peer = (select peer_name from checks join p2p p on checks.id = p.check_id
                                                where checks.id = new.check_id limit 1);
    end if;
    return null;
end;
$$
language plpgsql;

create trigger add_to_p2p after insert on p2p
    for each row
    execute function update_transferedpoints();

insert into p2p values (57, 22, 'santobab', 'Started', '09:09:09');

--Task 4
create function update_XP() returns trigger as
$$
begin
    if new.xp_count > (select max_xp from tasks where task_name = (select task_name from xp
        inner join checks c on c.id = xp.check_id where xp.check_id = new.check_id)) then
        RAISE EXCEPTION 'Error: XP exceeds the maximum value.';
    elseif (select verter_status from verter
            inner join checks c2 on c2.id = verter.check_id where verter.check_id = new.check_id
            order by 1 desc limit 1) != 'Success' then
        RAISE EXCEPTION 'Error: Status is not success';
    end if;
    return (new.id, new.check_id, new.xp_count);
end;
$$
language plpgsql;

create trigger add_to_xp before insert on xp
    for each row
    execute function update_XP();

-- Success
insert into xp values (23, 22, 199);
-- Error: XP
insert into xp values (24, 12, 700);
-- Error: Status
insert into xp values (25, 27, 50);

drop trigger add_to_xp on xp