{{
  config(
    materialized='table'
  )
}}

SELECT 
    pv.user_id
    ,pv.order_id
    ,pv.event_type
    ,count(distinct session_id) as number_of_sessions
    ,AVG(pv.stop_time - pv.start_time) as avg_event_type_duration
  FROM {{ ref('int_page_views') }} pv
where stop_time is not null  
group by pv.user_id,pv.order_id,pv.event_type
