{{
  config(
    materialized='table'
  )
}}
with order_id_lookup as (
  select user_id,session_id,order_id from {{ ref('dim_events') }} de where de.event_type = 'checkout'
)
SELECT 
    du2.user_id
    ,(CASE 
      WHEN du2.order_id IS NULL THEN olup.order_id
      ELSE du2.order_id
     END) as order_id-- only checkout and shipped seem to have an order_id so have to backfill
    ,du2.event_id
    ,du2.session_id
    ,du2.event_type
    ,du2.product_id
    ,du2.created_at as start_time
    ,(select min(du3.created_at) from {{ ref('dim_events') }} du3 
            where du3.user_id = du2.user_id  and du3.session_id = du2.session_id and  du3.created_at > du2.created_at)
        as stop_time
FROM {{ ref('dim_events') }} du2
JOIN order_id_lookup olup on olup.user_id = du2.user_id and olup.session_id = du2.session_id --only on completed orders
