with customer_summary as (
    select
        customer_type,
        lifetime_value_tier,
        customer_id,
        order_count,
        lifetime_value,
        average_order_value
    from {{ ref('rpt_customer_summary') }}
),

final as (
    select
        customer_type,
        lifetime_value_tier,
        count(customer_id) as customer_count,
        sum(order_count) as total_orders,
        sum(lifetime_value) as total_lifetime_value,
        avg(average_order_value) as avg_customer_average_order_value,
        avg(lifetime_value) as avg_customer_lifetime_value
    from customer_summary
    group by 1, 2
)

select *
from final
