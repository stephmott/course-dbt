{{
  config(
    materialized='table'
  )
}}
SELECT 
    do2.user_id
    ,(select count(*) from {{ ref('int_user_orders') }} do3 where do3.user_id = do2.user_id) as number_of_orders_delivered
    ,(select sum(order_total) from {{ ref('int_user_orders') }} do3 where do3.user_id = do2.user_id) as total_spent
    ,(select avg(order_total) from {{ ref('int_user_orders') }} do3 where do3.user_id = do2.user_id) as avg_spent_order
    ,(select avg(do3.ship_date - do3.order_date) from {{ ref('int_user_orders') }} do3 where do3.user_id = do2.user_id) as avg_prep_time
    ,(select avg(do3.order_delivered_date - do3.ship_date ) from {{ ref('int_user_orders') }} do3 where do3.user_id = do2.user_id) as avg_ship_time
FROM {{ ref('int_user_orders') }} do2
group by do2.user_id