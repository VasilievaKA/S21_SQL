create unique index idx_person_discounts_unique on person_discounts(person_id, pizzeria_id);

SET enable_seqscan = off;
explain analyze select person_id from person_discounts;