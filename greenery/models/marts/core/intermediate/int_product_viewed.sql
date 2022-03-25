{{
  config(
    materialized='table'
  )
}}
with product_viewed as (
    select session_id,product_id,max(created_at) as view_time from {{ ref('dim_events') }}
    where product_id is not null and event_type = 'page_view'
    group by session_id,product_id
    order by session_id
)
select * from product_viewed