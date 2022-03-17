{{
  config(
    materialized='table'
  )
}}

SELECT 
    order_id
    ,promo_id
    ,user_id
    ,address_id
    ,created_at as order_date
    ,order_cost
    ,shipping_cost
    ,order_total
    ,tracking_id
    ,shipping_service
    ,estimated_delivery_at
    ,delivered_at
    ,status
FROM {{ ref('stg_orders') }}