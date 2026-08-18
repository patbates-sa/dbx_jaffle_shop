select
    cast(id as bigint) as customer_id,
    trim(first_name) as first_name,
    trim(last_name) as last_name,
    concat_ws(' ', trim(first_name), trim(last_name)) as full_name,
    'new col' as new_col
from {{ source('jaffle_shop', 'customers') }}
