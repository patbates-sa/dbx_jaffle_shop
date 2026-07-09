with customers as (
    select
        customer_id,
        first_name,
        last_name,
        full_name,
        order_count,
        first_order_date,
        most_recent_order_date,
        lifetime_value
    from {{ ref('dim_customer') }}
),

final as (
    select
        customer_id,
        first_name,
        last_name,
        full_name,
        order_count,
        first_order_date,
        most_recent_order_date,
        lifetime_value,
        case
            when order_count = 0 then 'prospect'
            when order_count = 1 then 'one_time'
            else 'repeat'
        end as customer_type,
        case
            when order_count = 0 then 'no_orders'
            when lifetime_value < 25 then 'low_value'
            when lifetime_value < 50 then 'mid_value'
            else 'high_value'
        end as lifetime_value_tier,
        case
            when order_count = 0 then 0
            else lifetime_value / order_count
        end as average_order_value
    from customers
)

select *
from final
