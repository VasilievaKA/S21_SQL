create table if not exists PersonalInformation (
    customer_id bigint primary key,
    customer_name varchar check (customer_name ~* '^[А-Яа-я-]+$'),
	customer_surname varchar check (customer_surname ~* '^[А-Яа-я-]+$'),
	customer_primary_email varchar check (customer_primary_email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+\.[A-Za-z]+$'),
	customer_primary_phone varchar check (customer_primary_phone ~* '^\+7[0-9]{10}$')
);

create table if not exists Cards (
    customer_card_id bigint primary key,
    customer_id bigint,
    foreign key(customer_id) references PersonalInformation(customer_id) on delete cascade on update cascade
);

create table if not exists SKU_group (
    group_id bigint primary key,
    group_name varchar
);

create table if not exists Product (
    SKU_id bigint primary key,
    SKU_name varchar,
    group_id bigint,
    foreign key(group_id) references SKU_group(group_id) on delete cascade on update cascade
);

create table if not exists Stores (
    transaction_store_id bigint,
    SKU_id bigint,
    SKU_purchase_price numeric,
    SCU_retail_price numeric,
    foreign key(SKU_id) references Product(SKU_id) on delete cascade on update cascade
);

create table if not exists Transactions (
    transaction_id bigint primary key,
    customer_card_id bigint,
    transaction_sum numeric,
    transaction_date TIMESTAMP,
    transaction_store_id bigint,
    foreign key(customer_card_id) references Cards(customer_card_id) on delete cascade on update cascade
);

create table if not exists Checks (
    transaction_id bigint,
    SKU_id bigint,
    SKU_amount numeric,
    SKU_sum numeric,
    SKU_sum_paid numeric,
    SKU_discount numeric,
    foreign key(SKU_id) references Product(SKU_id) on delete cascade on update cascade
);

create table if not exists Date_of_analysis_formation (
    analysis_formation text check ( analysis_formation ~* '^[0-9]{2}.[0-9]{2}.2+[0-9]{3} [0-2]+[0-9]:[0-6]+[0-9]:[0-6]+[0-9]$')
);

CREATE OR REPLACE PROCEDURE import_from_csv (
    IN table_name TEXT,
    IN path TEXT,
    IN delimiter char(2) DEFAULT E'\t'
) AS $$
BEGIN
    EXECUTE FORMAT(
        'COPY %I FROM %L WITH (DELIMITER %L, FORMAT CSV, HEADER false)',
        table_name,
        path,
        delimiter
    );
END;
$$ LANGUAGE plpgsql;

create or replace procedure export_to_csv (
    table_name text,
    path text,
    delimiter char(2) default E'\t'
)
language plpgsql as
$$
begin
    execute format ('COPY %I TO %L WITH (DELIMITER %L, FORMAT CSV, HEADER false)', table_name, path, delimiter);
end;
$$;
