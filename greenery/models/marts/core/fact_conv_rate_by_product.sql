{{
  config(
    materialized='table'
  )
}}
with count_sessions_viewed_prod as (
    select  product_id,count(session_id) as total_sessions from {{ref('int_product_viewed')}}
    GROUP BY product_id
    order by product_id
),
count_all_sessions_with_orders_by_prod as (
    select product_id,count(distinct session_id) as sessions_with_orders from {{ref('int_conv_by_product')}}
    where product_purchased = 'Y'
    group by product_id
    order by product_id
)
select tc.product_id,sessions_with_orders,total_sessions,{{decimal_division('sessions_with_orders','total_sessions')}} as overall_conversion_rate
from count_sessions_viewed_prod tc
join count_all_sessions_with_orders_by_prod tc2 on tc2.product_id = tc.product_id