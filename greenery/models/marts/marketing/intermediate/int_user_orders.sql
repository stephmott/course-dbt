{{
  config(
    materialized='table'
  )
}}
with order_shipped as (
    select order_id,created_at as ship_date from {{ ref('dim_events') }} ev3 where ev3.event_type = 'package_shipped'
),
order_delivered as (
    select order_id,delivered_at as order_delivered_date from {{ ref('dim_orders') }} do3 where do3.status='delivered'
)
SELECT 
    do2.user_id
    ,do2.order_id
    ,do2.address_id
    ,do2.order_date
    ,do2.order_cost
    ,do2.shipping_cost
    ,do2.order_total
    ,os2.ship_date
    ,od2.order_delivered_date
    ,do2.estimated_delivery_at
FROM {{ ref('dim_orders') }} do2
JOIN order_shipped os2 ON os2.order_id = do2.order_id
JOIN order_delivered od2 ON od2.order_id = do2.order_id