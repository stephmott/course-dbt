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
    du2.user_id
    ,du2.order_id
    ,du2.order_date
    ,(SELECT min_date from first_order
            where first_order.user_id = du2.user_id) as first_order_date
    ,(SELECT max_date from last_order
            where last_order.user_id = du2.user_id) as last_order_date
    ,du2.status
    ,du2.order_total
    ,du2.promo_id
    ,(select sum(quantity) from {{ ref('dim_order_items') }} oit where oit.order_id = du2.order_id ) as number_of_items
FROM {{ ref('dim_orders') }} du2  