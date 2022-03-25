{{
  config(
    materialized='table'
  )
}}

with checkout_event as (
    select  session_id, order_id, max(created_at) as checkout_time  from {{ ref('dim_events') }}
    where event_type = 'checkout' and order_id is not null
    group by session_id, order_id
    order by session_id, order_id
)
select * from checkout_event