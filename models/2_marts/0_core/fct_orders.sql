with orders as (
    select
        order_id,
        customer_id,
        order_date,
        order_status
    from {{ ref('stg_orders') }}
),

payments as (
    select
        order_id,
        payment_status,
        amount
    from {{ ref('stg_payments') }}
),

order_payments as (
    select
        order_id,
        sum(case when payment_status = 'success' then amount else 0 end) as amount
    from payments
    group by 1
),

final as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.order_status,
        coalesce(order_payments.amount, 0) as amount
    from orders
    left join order_payments
        on orders.order_id = order_payments.order_id
)

select *
from final
