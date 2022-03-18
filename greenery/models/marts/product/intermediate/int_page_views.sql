{{
  config(
    materialized='table'
  )
}}

SELECT 
    du2.user_id
    ,du2.order_id
    ,du2.event_id
    ,du2.session_id
    ,du2.event_type
    ,du2.product_id
    ,du2.created_at as start_time
    ,(select min(created_at) from {{ ref('dim_events') }} du3 
            where d3.user_id = du2.user_id and du3.order_id = du2.order_id and du3.session_id = du2.session_id and  du3.created_at != du2.created_at
        as stop_time)
FROM {{ ref('dim_events') }} du2 