create table if not exists peers (
    nicname varchar primary key,
    birthday date not null
);

create table if not exists tasks (
    task_name varchar primary key,
    parent_task varchar,
    max_xp int not null
);

create type status as enum ('Started', 'Success', 'Failure');

create table if not exists checks (
    id bigint primary key,
    peer_name varchar not null,
    task_name varchar not null,
    check_date date not null,
    foreign key(peer_name) references peers(nicname) on delete cascade on update cascade,
    foreign key(task_name) references tasks(task_name) on delete cascade on update cascade
);

create table if not exists p2p (
    id bigint primary key,
    check_id bigint,
    reviewer_name varchar not null,
    p2p_status status not null,
    check_time time,
    foreign key(reviewer_name) references peers(nicname) on delete cascade on update cascade,
    foreign key(check_id) references checks(id) on delete cascade on update cascade
);

create table if not exists verter (
    id bigint primary key,
    check_id bigint,
    verter_status status not null,
    check_time time,
    foreign key(check_id) references checks(id) on delete cascade on update cascade
);

create table if not exists transferredpoints (
    id bigint primary key,
    checking_peer varchar not null,
    checked_peer varchar not null,
    point_count int not null,
    foreign key(checking_peer) references peers(nicname) on delete cascade on update cascade,
    foreign key(checked_peer) references peers(nicname) on delete cascade on update cascade
);

create table if not exists friends (
    id bigint primary key,
    peer1 varchar not null,
    peer2 varchar not null,
    foreign key(peer1) references peers(nicname) on delete cascade on update cascade,
    foreign key(peer2) references peers(nicname) on delete cascade on update cascade
);

create table if not exists recommendations (
    id bigint primary key,
    peer varchar not null,
    recomended_peer varchar not null,
    foreign key(peer) references peers(nicname) on delete cascade on update cascade,
    foreign key(recomended_peer) references peers(nicname) on delete cascade on update cascade
);

create table if not exists XP (
    id bigint primary key,
    check_id bigint,
    xp_count int not null,
    foreign key(check_id) references checks(id) on delete cascade on update cascade
);

create table if not exists timetracking (
    id bigint primary key,
    peer_name varchar not null,
    visit_date date not null,
    visit_time time not null,
    state int not null check (state in (1, 2)),
    foreign key(peer_name) references peers(nicname) on delete cascade on update cascade
);

create or replace procedure import_from_csv (
    table_name text,
    path text,
    delimiter char(1) default ','
)
language plpgsql as
$$
begin
    execute format ('COPY %I FROM %L DELIMITER %L CSV HEADER', table_name, path, delimiter);
end;
$$;

create or replace procedure export_to_csv (
    table_name text,
    path text,
    delimiter char(1) default ','
)
language plpgsql as
$$
begin
    execute format ('COPY %I TO %L WITH (DELIMITER %L, FORMAT CSV, HEADER true)', table_name, path, delimiter);
end;
$$;


-- INSERT

INSERT INTO peers
VALUES ('chanrosa', '1994-01-24'),
       ('santobab', '1997-06-30'),
       ('joramuns', '1996-11-05'),
       ('jeanicet', '1993-04-03'),
       ('jolteona', '1996-01-01'),
       ('howieter', '1996-01-02'),
       ('sallieam', '1996-01-03'),
       ('kokoschk', '1996-01-04'),
       ('squintad', '1996-01-05'),
       ('butterbs', '1996-01-06'),
       ('tangleto', '1996-05-10');

INSERT INTO tasks
VALUES ('C2_SimpleBashUtils', NULL, 250),
       ('C3_s21_string+', 'C2_SimpleBashUtils', 500),
       ('C4_s21_math', 'C2_SimpleBashUtils', 300),
       ('C5_s21_decimal', 'C4_s21_math', 350),
       ('C6_s21_matrix', 'C5_s21_decimal', 200),
       ('C7_SmartCalc_v1.0', 'C6_s21_matrix', 500),
       ('C8_3DViewer_v1.0', 'C7_SmartCalc_v1.0', 750),
       ('DO1_Linux', 'C3_s21_string+', 300),
       ('DO2_Linux Network', 'DO1_Linux', 250),
       ('DO3_LinuxMonitoring v1.0', 'DO2_Linux Network', 350),
       ('DO4_LinuxMonitoring v2.0', 'DO3_LinuxMonitoring v1.0', 350),
       ('DO5_SimpleDocker', 'DO3_LinuxMonitoring v1.0', 300),
       ('DO6_CICD', 'DO5_SimpleDocker', 300),
       ('CPP1_s21_matrix+', 'C8_3DViewer_v1.0', 300),
       ('CPP2_s21_containers', 'CPP1_s21_matrix+', 350),
       ('CPP3_SmartCalc_v2.0', 'CPP2_s21_containers', 600),
       ('CPP4_3DViewer_v2.0', 'CPP3_SmartCalc_v2.0', 750),
       ('CPP5_3DViewer_v2.1', 'CPP4_3DViewer_v2.0', 600),
       ('CPP6_3DViewer_v2.2', 'CPP4_3DViewer_v2.0', 800),
       ('CPP7_MLP', 'CPP4_3DViewer_v2.0', 700),
       ('CPP8_PhotoLab_v1.0', 'CPP4_3DViewer_v2.0', 450),
       ('CPP9_MonitoringSystem', 'CPP4_3DViewer_v2.0', 1000),
       ('SQL1_Bootcamp', 'C8_3DViewer_v1.0', 1500),
       ('SQL2_Info21 v1.0', 'SQL1_Bootcamp', 500),
       ('SQL3_RetailAnalitycs v1.0', 'SQL2_Info21 v1.0', 600),
       ('A1_Maze', 'CPP4_3DViewer_v2.0', 300),
       ('A2_SimpleNavigator v1.0', 'A1_Maze', 400),
       ('A3_Parallels', 'A2_SimpleNavigator v1.0', 300),
       ('A4_Crypto', 'A2_SimpleNavigator v1.0', 350),
       ('A5_s21_memory', 'A2_SimpleNavigator v1.0', 400),
       ('A6_Transactions', 'A2_SimpleNavigator v1.0', 700),
       ('A7_DNA Analyzer', 'A2_SimpleNavigator v1.0', 800),
       ('A8_Algorithmic trading', 'A2_SimpleNavigator v1.0', 800);

INSERT INTO checks
VALUES (1, 'joramuns', 'C2_SimpleBashUtils', '2022-12-07'),
       (2, 'jeanicet', 'C2_SimpleBashUtils', '2022-12-28'),
       (3, 'butterbs', 'C3_s21_string+', '2023-01-02'),
       (4, 'tangleto', 'C3_s21_string+', '2023-01-03'),
       (5, 'butterbs', 'DO1_Linux', '2023-01-07'),
       (6, 'joramuns', 'C3_s21_string+', '2023-01-12'),
       (7, 'jeanicet', 'DO1_Linux', '2023-01-12'),
       (8, 'tangleto', 'DO1_Linux', '2023-01-12'),
       (9, 'kokoschk', 'DO2_Linux Network', '2023-02-04'),
       (10, 'jeanicet', 'DO2_Linux Network', '2023-02-12'),
       (11, 'kokoschk', 'C6_s21_matrix', '2023-02-15'),
       (12, 'joramuns', 'C4_s21_math', '2023-02-18'),
       (13, 'butterbs', 'DO2_Linux Network', '2023-02-21'),
       (14, 'tangleto', 'DO2_Linux Network', '2023-02-21'),
       (15, 'jeanicet', 'DO3_LinuxMonitoring v1.0', '2023-02-21'),
       (16, 'butterbs', 'DO3_LinuxMonitoring v1.0', '2023-02-25'),
       (17, 'joramuns', 'C5_s21_decimal', '2023-03-02'),
       (18, 'butterbs', 'DO4_LinuxMonitoring v2.0', '2023-03-07'),
       (19, 'jeanicet', 'DO4_LinuxMonitoring v2.0', '2023-03-07'),
       (20, 'tangleto', 'C4_s21_math', '2023-03-07'),
       (21, 'kokoschk', 'C7_SmartCalc_v1.0', '2023-04-01'),
       (22, 'joramuns', 'C6_s21_matrix', '2023-04-03'),
       (23, 'butterbs', 'DO5_SimpleDocker', '2023-04-10'),
       (24, 'butterbs', 'DO6_CICD', '2023-04-15'),
       (25, 'joramuns', 'C7_SmartCalc_v1.0', '2023-05-06'),
       (26, 'joramuns', 'C8_3DViewer_v1.0', '2023-06-01');

INSERT INTO p2p
VALUES (1, 1, 'butterbs', 'Started', '07:00:00'),
       (2, 1, 'butterbs', 'Success', '07:11:00'),
       (3, 2, 'joramuns', 'Started', '14:01:00'),
       (4, 2, 'joramuns', 'Success', '14:28:00'),
       (5, 3, 'joramuns', 'Started', '18:00:00'),
       (6, 3, 'joramuns', 'Failure', '18:14:00'),
       (7, 4, 'kokoschk', 'Started', '12:17:00'),
       (8, 4, 'kokoschk', 'Success', '12:49:00'),
       (9, 5, 'jeanicet', 'Started', '13:02:00'),
       (10, 5, 'jeanicet', 'Success', '13:13:00'),
       (11, 6, 'kokoschk', 'Started', '09:00:00'),
       (12, 6, 'kokoschk', 'Success', '09:29:00'),
       (13, 7, 'tangleto', 'Started', '15:45:00'),
       (14, 7, 'tangleto', 'Success', '15:58:00'),
       (15, 8, 'jeanicet', 'Started', '17:08:00'),
       (16, 8, 'jeanicet', 'Success', '17:38:00'),
       (17, 9, 'butterbs', 'Started', '14:31:00'),
       (18, 9, 'butterbs', 'Success', '14:53:00'),
       (19, 10, 'butterbs', 'Started', '17:12:00'),
       (20, 10, 'butterbs', 'Success', '17:39:00'),
       (21, 11, 'tangleto', 'Started', '21:17:00'),
       (22, 11, 'tangleto', 'Success', '21:29:00'),
       (23, 12, 'kokoschk', 'Started', '20:17:00'),
       (24, 12, 'kokoschk', 'Success', '20:34:00'),
       (25, 13, 'kokoschk', 'Started', '11:02:00'),
       (26, 13, 'kokoschk', 'Success', '11:13:00'),
       (27, 14, 'joramuns', 'Started', '18:12:00'),
       (28, 14, 'joramuns', 'Success', '18:32:00'),
       (29, 15, 'butterbs', 'Started', '15:00:00'),
       (30, 15, 'butterbs', 'Success', '15:21:00'),
       (31, 16, 'jeanicet', 'Started', '07:00:00'),
       (32, 16, 'jeanicet', 'Success', '07:11:00'),
       (33, 17, 'tangleto', 'Started', '16:17:00'),
       (34, 17, 'tangleto', 'Success', '16:49:00'),
       (35, 18, 'kokoschk', 'Started', '13:15:00'),
       (36, 18, 'kokoschk', 'Success', '13:48:00'),
       (37, 19, 'butterbs', 'Started', '10:15:00'),
       (38, 19, 'butterbs', 'Success', '10:36:00'),
       (39, 20, 'kokoschk', 'Started', '18:00:00'),
       (40, 20, 'kokoschk', 'Failure', '18:14:00'),
       (41, 21, 'joramuns', 'Started', '13:02:00'),
       (42, 21, 'joramuns', 'Success', '13:13:00'),
       (43, 22, 'tangleto', 'Started', '12:47:00'),
       (44, 22, 'tangleto', 'Success', '13:16:00'),
       (45, 23, 'jeanicet', 'Started', '15:42:00'),
       (46, 23, 'jeanicet', 'Success', '16:22:00'),
       (47, 24, 'kokoschk', 'Started', '18:21:00'),
       (48, 24, 'kokoschk', 'Success', '19:11:00'),
       (49, 25, 'butterbs', 'Started', '09:17:00'),
       (50, 25, 'butterbs', 'Success', '10:09:00'),
       (51, 26, 'tangleto', 'Started', '22:08:00'),
       (52, 26, 'tangleto', 'Success', '23:03:00');

INSERT INTO verter
VALUES (1, 1, 'Started', '07:12:00'),
       (2, 1, 'Success', '07:13:00'),
       (3, 2, 'Started', '14:29:00'),
       (4, 2, 'Failure', '14:30:00'),
       (5, 4, 'Started', '12:50:00'),
       (6, 4, 'Success', '12:51:00'),
       (7, 6, 'Started', '09:30:00'),
       (8, 6, 'Success', '09:31:00'),
       (9, 11, 'Started', '21:30:00'),
       (10, 11, 'Failure', '21:31:00'),
       (11, 12, 'Started', '20:35:00'),
       (12, 12, 'Success', '20:36:00'),
       (13, 17, 'Started', '16:50:00'),
       (14, 17, 'Success', '16:51:00'),
       (15, 22, 'Started', '13:17:00'),
       (16, 22, 'Success', '13:18:00');

INSERT INTO Friends
VALUES (1, 'joramuns', 'jeanicet'),
       (2, 'joramuns', 'howieter'),
       (3, 'joramuns', 'sallieam'),
       (4, 'joramuns', 'butterbs'),
       (5, 'joramuns', 'tangleto'),
       (6, 'joramuns', 'squintad'),
       (7, 'joramuns', 'jolteona'),
       (8, 'joramuns', 'kokoschk'),
       (9, 'joramuns', 'santobab'),
       (10, 'jeanicet', 'howieter'),
       (11, 'jeanicet', 'sallieam'),
       (12, 'jeanicet', 'butterbs'),
       (13, 'jeanicet', 'tangleto'),
       (14, 'jeanicet', 'squintad'),
       (15, 'jeanicet', 'jolteona'),
       (16, 'jeanicet', 'kokoschk'),
       (17, 'jeanicet', 'santobab'),
       (18, 'howieter', 'sallieam'),
       (19, 'howieter', 'butterbs'),
       (20, 'howieter', 'tangleto'),
       (21, 'howieter', 'squintad'),
       (22, 'howieter', 'jolteona'),
       (23, 'howieter', 'kokoschk'),
       (24, 'howieter', 'santobab'),
       (25, 'sallieam', 'butterbs'),
       (26, 'sallieam', 'tangleto'),
       (27, 'sallieam', 'squintad'),
       (28, 'sallieam', 'jolteona'),
       (29, 'sallieam', 'kokoschk'),
       (30, 'sallieam', 'santobab'),
       (31, 'butterbs', 'tangleto'),
       (32, 'butterbs', 'squintad'),
       (33, 'butterbs', 'jolteona'),
       (34, 'butterbs', 'kokoschk'),
       (35, 'butterbs', 'santobab'),
       (36, 'tangleto', 'squintad'),
       (37, 'tangleto', 'jolteona'),
       (38, 'tangleto', 'kokoschk'),
       (39, 'tangleto', 'santobab'),
       (40, 'squintad', 'jolteona'),
       (41, 'squintad', 'kokoschk'),
       (42, 'squintad', 'santobab'),
       (43, 'jolteona', 'kokoschk'),
       (44, 'jolteona', 'santobab'),
       (45, 'kokoschk', 'santobab');

INSERT INTO recommendations
VALUES (1, 'joramuns', 'jeanicet'),
       (2, 'joramuns', 'howieter'),
       (3, 'joramuns', 'sallieam'),
       (4, 'joramuns', 'butterbs'),
       (5, 'joramuns', 'tangleto'),
       (6, 'joramuns', 'squintad'),
       (7, 'joramuns', 'jolteona'),
       (8, 'joramuns', 'kokoschk'),
       (9, 'joramuns', 'santobab'),
       (10, 'jeanicet', 'squintad'),
       (11, 'jeanicet', 'jolteona'),
       (12, 'jeanicet', 'kokoschk'),
       (13, 'howieter', 'sallieam'),
       (14, 'howieter', 'butterbs'),
       (15, 'howieter', 'santobab'),
       (16, 'sallieam', 'butterbs'),
       (17, 'sallieam', 'santobab'),
       (18, 'butterbs', 'tangleto'),
       (19, 'butterbs', 'santobab'),
       (20, 'tangleto', 'squintad'),
       (21, 'tangleto', 'santobab'),
       (22, 'squintad', 'jolteona'),
       (23, 'jolteona', 'kokoschk'),
       (24, 'jolteona', 'santobab'),
       (25, 'kokoschk', 'santobab');

INSERT INTO timeTracking
VALUES (1, 'joramuns', '2023-04-12', '13:11', 1),
       (2, 'joramuns', '2023-04-12', '13:44', 2),
       (3, 'joramuns', '2023-04-12', '15:14', 1),
       (4, 'joramuns', '2023-04-12', '19:10', 2),
       (5, 'butterbs', '2023-01-01', '10:00', 1),
       (6, 'butterbs', '2023-01-01', '20:00', 2);

INSERT INTO xp
VALUES (1, 1, 250),
       (2, 4, 400),
       (3, 5, 300),
       (4, 6, 450),
       (5, 7, 270),
       (6, 8, 285),
       (7, 9, 250),
       (8, 10, 240),
       (9, 12, 300),
       (10, 13, 250),
       (11, 14, 250),
       (12, 15, 300),
       (13, 16, 350),
       (14, 17, 330),
       (15, 18, 340),
       (16, 19, 350),
       (17, 21, 500),
       (18, 22, 200),
       (19, 23, 280),
       (20, 24, 300),
       (21, 25, 500),
       (22, 26, 700);


INSERT INTO transferredPoints
VALUES (1, 'chanrosa', 'santobab', 5),
       (2, 'chanrosa', 'joramuns', 2),
       (3, 'chanrosa', 'jeanicet', 4),
       (4, 'chanrosa', 'jolteona', 6),
       (5, 'chanrosa', 'howieter', 1),
       (6, 'chanrosa', 'sallieam', 1),
       (7, 'chanrosa', 'kokoschk', 3),
       (8, 'chanrosa', 'squintad', 4),
       (9, 'chanrosa', 'butterbs', 4),
       (10, 'chanrosa', 'tangleto', 3),
       (11, 'santobab', 'chanrosa', 1),
       (12, 'santobab', 'joramuns', 2),
       (13, 'santobab', 'jeanicet', 8),
       (14, 'santobab', 'jolteona', 1),
       (15, 'santobab', 'howieter', 1),
       (16, 'santobab', 'sallieam', 3),
       (17, 'santobab', 'kokoschk', 4),
       (18, 'santobab', 'squintad', 2),
       (19, 'santobab', 'butterbs', 7),
       (20, 'santobab', 'tangleto', 5),
       (21, 'joramuns', 'chanrosa', 4),
       (22, 'joramuns', 'santobab', 4),
       (23, 'joramuns', 'jeanicet', 2),
       (24, 'joramuns', 'jolteona', 3),
       (25, 'joramuns', 'howieter', 2),
       (26, 'joramuns', 'sallieam', 6),
       (27, 'joramuns', 'kokoschk', 1),
       (28, 'joramuns', 'squintad', 5),
       (29, 'joramuns', 'butterbs', 1),
       (30, 'joramuns', 'tangleto', 2);
