{{
  config(
    materialized='table'
  )
}}
with first_order as (
    select distinct user_id,min(order_date) as min_date from {{ ref('dim_orders') }}
    group by user_id
),
last_order as (
    select distinct user_id,max(order_date) as max_date from {{ ref('dim_orders') }}
    group by user_id
)
SELECT 
    dim_users.user_id
    ,dim_orders.order_id
    ,dim_orders.order_date
    ,CASE dim_orders.order_date = (SELECT min_date from first_order
            left join {{ ref('dim_users') }} on  first_order.user_id = dim_users.user_id)
            WHEN TRUE THEN 'Y'
            ELSE 'N'
    END as is_first_order
    ,CASE dim_orders.order_date = (SELECT max_date from last_order
            left join {{ ref('dim_users') }} on  last_order.user_id = dim_users.user_id)
            WHEN TRUE THEN 'Y'
            ELSE 'N'
    END as is_last_order
FROM {{ ref('dim_users') }}
LEFT JOIN {{ ref('dim_orders') }} ON dim_orders.user_id = dim_users.user_id