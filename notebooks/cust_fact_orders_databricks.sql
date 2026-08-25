-- Databricks notebook source
-- Creates the Databricks table equivalent of the dbt model.

-- COMMAND ----------

CREATE OR REPLACE TABLE `development`.`dbt_pbates`.`cust_fact_orders`
USING DELTA
AS
WITH orders AS (
    SELECT
        order_id,
        customer_id,
        order_date,
        order_status,
        amount
    FROM `development`.`dbt_pbates`.`fct_orders`
),

customers AS (
    SELECT
        customer_id,
        first_name,
        last_name,
        full_name,
        order_count,
        first_order_date,
        most_recent_order_date,
        lifetime_value
    FROM `development`.`dbt_pbates`.`dim_customer`
),

final AS (
    SELECT
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.order_status,
        orders.amount,
        customers.first_name,
        customers.last_name,
        customers.full_name,
        customers.order_count,
        customers.first_order_date,
        customers.most_recent_order_date,
        customers.lifetime_value
    FROM orders
    LEFT JOIN customers
        ON orders.customer_id = customers.customer_id
)

SELECT *
FROM final;

-- COMMAND ----------

-- Optional validation query
SELECT *
FROM `development`.`dbt_pbates`.`cust_fact_orders`
LIMIT 100;
