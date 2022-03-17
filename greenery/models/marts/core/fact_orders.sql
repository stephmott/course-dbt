{{
  config(
    materialized='table'
  )
}}

SELECT 
    du2.user_id
    ,du2.order_id
    ,du2.order_date
    ,CASE 
        WHEN du2.first_order_date=du2.order_date THEN 'Y'
        ELSE 'N'
    END as is_first_order
    ,CASE 
        WHEN du2.last_order_date=du2.order_date THEN 'Y'
        ELSE 'N'
    END as is_last_order
    ,du2.order_total as amount
    ,du2.promo_id
    ,du2.number_of_items
FROM {{ ref('int_fact_orders') }} du2 