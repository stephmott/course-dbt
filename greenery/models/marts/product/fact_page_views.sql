{{
  config(
    materialized='table'
  )
}}
SELECT 
    pv.user_id
    ,pv.order_id
    ,pv.event_type
    ,(select count(*) from {{ ref('int_page_views') }} pv2 
        where pv2.user_id = pv.user_id and pv2.order_id = pv.order_ida 
        and pv2.session_id = pv.session_id and pv2.event_type = pv.event_type ) as number_of_sessions
    ,AVG(CASE pv.stop_time
        WHEN NULL then NULL
        ELSE pv.stop_time - pv.start_time
    ))as event_type_duration
    
    NVL(select sum() from {{ ref('int_page_views') }} do3 where do3.user_id = do2.user_id) as total_spent
    ,(select avg(order_total) from {{ ref('int_page_views') }} do3 where do3.user_id = do2.user_id) as avg_spent_order
    ,(select avg(do3.ship_date - do3.order_date) from {{ ref('int_page_views') }} do3 where do3.user_id = do2.user_id) as avg_prep_time
    ,(select avg(do3.order_delivered_date - do3.ship_date ) from {{ ref('int_page_views') }} do3 where do3.user_id = do2.user_id) as avg_ship_time
FROM {{ ref('int_page_views') }} pv
group by pv.user_id,pv.order_id,pv.event_type
