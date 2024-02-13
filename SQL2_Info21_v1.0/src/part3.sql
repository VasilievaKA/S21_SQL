-- Task 1
create function transferedpoints_return()
returns table (
    peer1 varchar,
    peer2 varchar,
    PointsAmount int) as
$$
begin;
select t1.checking_peer, t1.checked_peer, (t1.point_count - t2.point_count) as PointsAmount
from transferredpoints t1
inner join transferredpoints t2 on t1.checking_peer = t2.checked_peer
                                and t1.checked_peer = t2.checking_peer
                                and t1.id < t2.id;
end;
$$
language plpgsql;

-- Task 2
create function get_xp_count ()
returns table (
    peer_name varchar,
    task_name varchar,
    xp_count int) as
$$
begin;
    return query (select peer_name, task_name, xp_count from xp
    inner join checks c on c.id = xp.check_id);
end;
$$
language plpgsql;

-- Task 3
create function get_peers(check_date date)
returns table (
  peer_names varchar
) as
$$
begin;
    select peer_name from timetracking where visit_date = check_date
    group by peer_name
    having count(state) < 2;
end;
$$
language plpgsql;

-- Task 4
with sum_checking as (
    select checking_peer, abs(sum(point_count)) as sum_points from transferredpoints
    group by checking_peer),
sum_checked as (
    select checked_peer, abs(sum(point_count)) as sum_points from transferredpoints
    group by checked_peer)
select checking_peer as peer,
       ((coalesce(sum_checking.sum_points, 0)) - (coalesce(sum_checked.sum_points, 0))) as PointsChange
        from sum_checking
        inner join sum_checked on sum_checking.checking_peer = sum_checked.checked_peer
        order by PointsChange desc;

-- Task 5
create procedure prc_changes_peer_points_v2()
language plpgsql
begin atomic 
    with peer1 as (select Peer1 as Peer, sum(pointsamount) as PointsChange
                   from transferedpoints_return()
                   group by Peer1),
         peer2 as (select Peer2 as Peer, sum(pointsamount) as PointsChange
                   from transferedpoints_return()
                   group by Peer2)
    select coalesce(peer1.Peer, peer2.Peer) as Peer,
           (coalesce(peer1.PointsChange, 0) - coalesce(peer2.PointsChange, 0)) as PointsChange
    from peer1
    full join peer2 on peer1.Peer = peer2.Peer
    order by PointsChange desc ;
end;

-- Task 6
with task1 as (
    select task_name, check_date, count(*) as counts
    from checks
    group by task_name, check_date),
task2 as (
    select task1.task_name,
    task1.check_date,
    rank() over(partition by task1.check_date order by task1.counts) as rank from task1)
select task2.check_date, task2.task_name
from task2
where rank = 1;

-- Task 7
create procedure check_last_task(block_name varchar)
language plpgsql
begin atomic
    select peer_name, check_date from checks
    join p2p on checks.id = p2p.check_id
    join tasks t on t.task_name = checks.task_name
    where p2p_status = 'Success' and t.task_name = (
        select max(task_name) as max_task from tasks where task_name like concat(block_name, '[A-Z0-9]%'));
end;
-- Task 8 !!!
select nicname,
(case when nicname = f.peer1 then peer2
       else peer1 end) as friend
       from peers join friends f on peers.nicname = f.peer1;
select recomended_peer, count(recomended_peer) from recommendations group by recomended_peer;

-- Task 9
create procedure percentage(
    name1 varchar,
    name2 varchar
)
language plpgsql
begin atomic
    with block1 as (
        select count(peer_name) as count_bl1 from checks
        join p2p on checks.id = p2p.check_id
        join tasks t on t.task_name = checks.task_name where t.task_name like concat(name1, '%')),
        block2 as (
        select count(peer_name) as count_bl2 from checks
        join p2p on checks.id = p2p.check_id
        join tasks t on t.task_name = checks.task_name where t.task_name like concat(name2, '%')),
        both_blocks as (
        select count(peer_name) as count_both from
        (select peer_name from checks
        join p2p on checks.id = p2p.check_id
        join tasks t on t.task_name = checks.task_name where t.task_name like concat(name1, '%')
        intersect
        select peer_name from checks
        join p2p on checks.id = p2p.check_id
        join tasks t on t.task_name = checks.task_name where t.task_name like concat(name2, '%')) as q1),
        no_start as (
        select count(nicname) as count_no
        FROM peers
        LEFT JOIN checks c ON peers.nicname = c.peer_name
        WHERE c.peer_name IS NULL),
        full_info as (
        select * from block1 full join block2 on block2.count_bl2 = block1.count_bl1
        full join both_blocks on both_blocks.count_both = block1.count_bl1
        full join no_start on no_start.count_no = block1.count_bl1)
    select (max(count_bl1)::float/(max(count_bl1) + max(count_bl2) + max(count_both) + max(count_no))::float) * 100 as StartedBlock1,
           (max(count_bl2)::float/(max(count_bl1) + max(count_bl2) + max(count_both) + max(count_no))::float) * 100 as StartedBlock2,
           (max(count_both)::float/(max(count_bl1) + max(count_bl2) + max(count_both) + max(count_no))::float) * 100 as StartedBothBlocks,
           (max(count_no)::float/(max(count_bl1) + max(count_bl2) + max(count_both) + max(count_no))::float) * 100 as DidntStartAnyBlock
    from full_info;
end;
-- Task 10
select nicname, coalesce(xp.check_id, 0) as status
                          from (select *
                                from checks c
                                         JOIN peers p ON p.nicname = c.peer_name
                                WHERE (select extract(DAY from birthday)) = (select extract(DAY from check_date))
                                  AND (select extract(MONTH from birthday)) =
                                      (select extract(MONTH from check_date))) as birt
                                   LEFT JOIN xp ON xp.check_id = birt.id
                          group by nicname, status;

-- Task 11
create procedure check_tasks (
    task1 varchar,
    task2 varchar,
    task3 varchar
)
language plpgsql
begin atomic
    select peer_name from p2p join checks c on p2p.check_id = c.id
    where (task_name = task1 or task_name = task2) and p2p_status = 'Success'
    intersect
    select peer_name from p2p join checks c on p2p.check_id = c.id
    where task_name = task3 and p2p_status = 'Failure';
end;

-- Task 12
with recursive parent as (
    select (select task_name from tasks
            where tasks.parent_task is null) as Task, 0 as PrevCount
    union all
    select t.task_name, PrevCount + 1
    from parent p
    join tasks t on t.parent_task = p.Task)
select Task, PrevCount - 1 from parent;
-- Task 13


-- Task 14
select peer_name, sum(xp_count) from xp
inner join checks c on c.id = xp.check_id
group by peer_name
order by 2 desc limit 1;

-- Task 15
create procedure check_visits(
    v_time time,
    n int
)
language plpgsql
begin atomic
    select peer_name from timetracking
                     where visit_time < v_time and state = 1
                     group by peer_name
                     having count(peer_name) >= n;
end;
--Task 16
create procedure check_visits_count(
    N int,
    M int
)
language plpgsql
begin atomic
    select peer_name from (select * from timetracking
                                    where state = 2
                    and timetracking.visit_date >= (now() - (N - 1 || 'days')::interval)::date
                    and timetracking.visit_date <= now()::date) as q1
            group by peer_name
            having count(state) >= M;
end;
--Task 17
with res as (
    select to_char(visit_date, 'TMMonth') as month, count(visit_date) as count_time
    from timetracking inner join peers p on p.nicname = timetracking.peer_name
        where extract(month from visit_date) = extract(month from birthday) and visit_time < '12:00:00'
        group by visit_date),
    res2 as (
    select to_char(visit_date, 'TMMonth') as month, count(visit_date) as count_all
    from timetracking inner join peers p on p.nicname = timetracking.peer_name
         where extract(month from visit_date) = extract(month from birthday)
         group by visit_date)
select res2.month, (cast(count_time as float)/cast(count_all as float)) * 100 from res
    full join res2 on res.month = res2.month