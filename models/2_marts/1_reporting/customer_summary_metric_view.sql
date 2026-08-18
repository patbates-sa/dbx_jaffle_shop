{{ config(materialized='metric_view') }}

version: 0.1
source: {{ ref('rpt_customer_summary') }}

dimensions:
  - name: customer_id
    expr: customer_id

  - name: first_name
    expr: first_name

  - name: last_name
    expr: last_name

  - name: full_name
    expr: full_name

  - name: customer_type
    expr: customer_type

  - name: lifetime_value_tier
    expr: lifetime_value_tier

  - name: first_order_date
    expr: first_order_date

  - name: most_recent_order_date
    expr: most_recent_order_date

measures:
  - name: customer_count
    expr: count(customer_id)

  - name: total_orders
    expr: sum(order_count)

  - name: total_lifetime_value
    expr: sum(lifetime_value)

  - name: average_customer_lifetime_value
    expr: avg(lifetime_value)

  - name: average_order_value
    expr: avg(average_order_value)

