create index idx_person_name on person(upper(name));
SET enable_seqscan = off;

explain analyze select name from person where upper(name) like 'DENIS';


