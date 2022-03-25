{{
  config(
    materialized='table'
  )
}}
with count_all_sessions as (
    select count(distinct session_id) as total_sessions from {{ref('int_conv_by_product')}}
),
count_all_sessions_with_orders as (
    select count(distinct session_id) as sessions_with_orders from {{ref('int_conv_by_product')}}
    where checkout_event = 'Y'
)
select sessions_with_orders,total_sessions,{{decimal_division('sessions_with_orders','total_sessions')}} as overall_conversion_rate
from count_all_sessions,count_all_sessions_with_orders