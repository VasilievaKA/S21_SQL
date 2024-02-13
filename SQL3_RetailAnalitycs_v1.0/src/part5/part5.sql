-- DROP FUNCTION IF EXISTS generate_growth_offers(TIMESTAMP, TIMESTAMP, INT, FLOAT , FLOAT, FLOAT);

SET datestyle = 'ISO, DMY';

CREATE OR REPLACE FUNCTION generate_growth_offers(
    date_start TIMESTAMP,
    date_end TIMESTAMP,
    added_transactions INT,
    max_churn_index FLOAT,
    max_discount_ratio FLOAT,
    max_margin_ratio FLOAT
)

RETURNS TABLE (
    customer_id INT,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    required_transactions_count INT,
    group_name VARCHAR(255),
    offer_discount_depth INT
)
AS $$
BEGIN
    RETURN QUERY
        WITH purchase_history_total AS( 
                SELECT
                    (AVG(purchase_history.group_summ) - AVG(purchase_history.group_cost)) / 100.0 * max_margin_ratio 
                    / AVG(purchase_history.group_cost) AS pre_offer_discount_depth,
                    purchase_history.customer_id,
                    purchase_history.group_id
                FROM
                    purchase_history
                GROUP BY
                    purchase_history.customer_id,
                    purchase_history.group_id
        )
        SELECT 
            DISTINCT ON (groupsview.customer_id) groupsview.customer_id :: INT,
            date_start as start_date,
            date_end as end_date,
            (EXTRACT(EPOCH FROM (date_end - date_start)) / 86400.0 / customer_frequency)
            :: INT + added_transactions AS target_transactions_count,
            sku_group.group_name AS group_name,
            (CEIL(group_minimum_discount / 0.05) * 0.05 * 100) :: INT AS offer_discount_depth
        FROM groupsview
            JOIN sku_group ON sku_group.group_id = groupsview.group_id
            JOIN periods ON periods.customer_id = groupsview.customer_id AND periods.group_id = groupsview.group_id 
            JOIN customersview ON customersview.customer_id = groupsview.customer_id
            JOIN purchase_history_total ON purchase_history_total.customer_id = groupsview.customer_id 
            AND purchase_history_total.group_id = groupsview.group_id
        WHERE
            -- Индекс оттока по данной группе не должен превышать заданного пользователем значения. 
            group_churn_rate <= max_churn_index
            -- Доля транзакций со скидкой по данной группе – менее заданного пользователем значения. 
            AND group_discount_share < max_discount_ratio / 100
            AND CEIL(group_minimum_discount / 0.05) * 0.05 < pre_offer_discount_depth
        ORDER BY
            groupsview.customer_id,
            -- Индекс востребованности группы – максимальный из всех возможных. + DISTINCT в SELECT
            groupsview.group_affinity_index DESC, 
            groupsview.group_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM generate_growth_offers (
    '01.01.2022 00:00:00', 
    '01.01.2024 00:00:00',
    2,
    4,
    70,
    40
);