CREATE OR REPLACE FUNCTION customer_average_check_method1(param_customer_id BIGINT,
                                                          start_date TIMESTAMP,
                                                          end_date TIMESTAMP,
                                                          customer_average_check NUMERIC)
RETURNS NUMERIC AS
$$
DECLARE
    date_of_analysis TIMESTAMP = (SELECT to_timestamp(cast(analysis_formation as TEXT), 'DD.MM.YYYY HH24:MI:SS')
                                  FROM date_of_analysis_formation);
    start_period  TIMESTAMP = (SELECT min(transaction_date)
                               FROM Transactions t
                                   JOIN cards c ON t.customer_card_id = c.customer_card_id
                               WHERE c.customer_id = param_customer_id);
BEGIN
    IF start_date < start_period THEN
        start_date = start_period;
    END IF;
    IF date_of_analysis < end_date THEN
        end_date = date_of_analysis;
    END IF;
    RETURN customer_average_check * (
    SELECT sum(transaction_sum) / count(transaction_id)
    FROM transactions t
        JOIN cards c ON t.customer_card_id = c.customer_card_id
    WHERE c.customer_id = param_customer_id
      AND transaction_date BETWEEN start_date AND end_date);
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION customer_average_check_method2(param_customer_id BIGINT,
                                                          count_transactions INT,
                                                          customer_average_check NUMERIC)
RETURNS NUMERIC AS
$$
BEGIN
    RETURN customer_average_check * (
    WITH t AS (
    SELECT * FROM transactions
        JOIN cards c ON c.customer_card_id = transactions.customer_card_id
    WHERE c.customer_id = param_customer_id
    ORDER BY transaction_date DESC
    LIMIT count_transactions
    )
    SELECT sum(transaction_sum) / count(transaction_id) FROM t);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION amount_of_discount(param_customer_id BIGINT,
                                              max_index NUMERIC,
                                              max_discount_rate NUMERIC,
                                              margin NUMERIC)
RETURNS NUMERIC AS
$$
DECLARE
    n INTEGER = (SELECT count(*) FROM GroupsView
                 WHERE customer_id = param_customer_id);
    i INT = 1;
    r RECORD;
    param_margin NUMERIC;
BEGIN
    FOR i IN 1..n
        LOOP
            SELECT group_margin, group_minimum_discount, group_id
            FROM GroupsView
            WHERE customer_id = param_customer_id
              AND group_churn_rate <= max_index
              AND group_discount_share < max_discount_rate
            ORDER BY group_affinity_index DESC, group_id
            LIMIT 1 OFFSET i - 1
            INTO r;
            IF r.group_margin IS NOT NULL AND r.group_minimum_discount IS NOT NULL THEN
                param_margin = r.group_margin * margin;
                IF param_margin > ceil((r.group_minimum_discount * 100 / 5) * 5) THEN
                    RETURN ceil(r.group_minimum_discount * 100 / 5) * 5;
                END IF;
            END IF;
        END LOOP;
    RETURN 0;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION group_names_with_discount(param_customer_id BIGINT,
                                                     max_index NUMERIC,
                                                     max_discount_rate NUMERIC,
                                                     margin NUMERIC)
RETURNS VARCHAR AS
$$
DECLARE
    n INTEGER = (SELECT count(*) FROM groupsview
                 WHERE customer_id = param_customer_id);
    i INT = 1;
    r RECORD;
    param_margin NUMERIC;
BEGIN
    FOR i IN 1..n
        LOOP
            SELECT group_margin, group_minimum_discount, group_id
            FROM groupsview
            WHERE customer_id = param_customer_id
              AND group_churn_rate <= max_index
              AND group_discount_share < max_discount_rate
            ORDER BY group_affinity_index DESC, group_id
            LIMIT 1 OFFSET i - 1
            INTO r;
            IF r.group_margin IS NOT NULL AND r.group_minimum_discount IS NOT NULL THEN
                param_margin = r.group_margin * margin;
                IF param_margin > ceil((r.group_minimum_discount * 100 / 5) * 5) THEN
                    RETURN (SELECT group_name FROM sku_group where group_id = r.group_id);
                END IF;
            END IF;
        END LOOP;
    RETURN 0;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION part4(method INTEGER,
                                 start_date_parameter DATE,
                                 end_date_parameter DATE,
                                 num_transactions INTEGER,
                                 customer_average_check NUMERIC,
                                 max_rate NUMERIC,
                                 max_share_transactions NUMERIC,
                                 ad_share_margin NUMERIC)
    RETURNS TABLE
            (
                Customer_ID            BIGINT,
                Required_Check_Measure NUMERIC,
                Group_Name             VARCHAR,
                Offer_Discount_Depth   NUMERIC
            )
AS
$$
DECLARE
    start_date  TIMESTAMP = (SELECT start_date_parameter::timestamp);
    end_date TIMESTAMP = (SELECT end_date_parameter::timestamp);
BEGIN
    IF method = 1 THEN
        RETURN QUERY (SELECT pi.customer_id,
                             customer_average_check_method1(pi.customer_id,
                                                            start_date,
                                                            end_date,
                                                            customer_average_check),
                             group_names_with_discount(pi.customer_id,
                                                       max_rate,
                                                       max_share_transactions::NUMERIC / 100,
                                                       ad_share_margin::NUMERIC / 100),
                             amount_of_discount(pi.customer_id,
                                                max_rate,
                                                max_share_transactions::NUMERIC / 100,
                                                ad_share_margin::NUMERIC / 100)
                      FROM personalinformation pi);
    ELSIF method = 2 THEN
        RETURN QUERY (SELECT pi.customer_id,
                             customer_average_check_method2(pi.customer_id,
                                                            num_transactions,
                                                            customer_average_check),
                             group_names_with_discount(pi.customer_id,
                                                       max_rate,
                                                       max_share_transactions::NUMERIC / 100,
                                                       ad_share_margin::NUMERIC / 100),
                             amount_of_discount(pi.customer_id,
                                                max_rate,
                                                max_share_transactions::NUMERIC / 100,
                                                ad_share_margin::NUMERIC / 100)
                      FROM personalinformation pi);
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM part4(1, '2021-09-02', '2023-01-01', 100, 1.15, 3, 70, 30);