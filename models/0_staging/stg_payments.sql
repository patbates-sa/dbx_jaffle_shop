select
    cast(id as bigint) as payment_id,
    cast(orderid as bigint) as order_id,
    lower(trim(paymentmethod)) as payment_method,
    lower(trim(status)) as payment_status,
    cast(amount as decimal(18,2)) / 100 as amount
from {{ source('jaffle_shop', 'payments') }}
