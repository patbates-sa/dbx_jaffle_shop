select
    cast(id as bigint) as order_id,
    cast(user_id as bigint) as customer_id,
    cast(order_date as date) as order_date,
    lower(trim(status)) as order_status
from {{ source('jaffle_shop', 'orders') }}
