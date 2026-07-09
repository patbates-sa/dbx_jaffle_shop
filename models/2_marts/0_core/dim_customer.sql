with customers as (
    select
        customer_id,
        first_name,
        last_name,
        full_name
    from {{ ref('stg_customers') }}
),

customer_order_summary as (
    select
        customer_id,
        count(order_id) as order_count,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        sum(amount) as lifetime_value
    from {{ ref('fct_orders') }}
    group by 1
),

final as (
    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customers.full_name,
        coalesce(customer_order_summary.order_count, 0) as order_count,
        customer_order_summary.first_order_date,
        customer_order_summary.most_recent_order_date,
        coalesce(customer_order_summary.lifetime_value, 0) as lifetime_value,
        case
            when coalesce(customer_order_summary.order_count, 0) = 0 then 0
            else 1.0 * customer_order_summary.order_count / greatest(
                (
                    (
                        year(customer_order_summary.most_recent_order_date)
                        - year(customer_order_summary.first_order_date)
                    ) * 12
                )
                + month(customer_order_summary.most_recent_order_date)
                - month(customer_order_summary.first_order_date)
                + 1,
                1
            )
        end as average_monthly_orders
    from customers
    left join customer_order_summary
        on customers.customer_id = customer_order_summary.customer_id
)

select *
from final
