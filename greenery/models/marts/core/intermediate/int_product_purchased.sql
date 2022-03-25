{{
  config(
    materialized='table'
  )
}}

with product_purchased as (
    select de.session_id,de.order_id,oi.product_id 
    from {{ ref('dim_order_items') }} oi
    join {{ ref('dim_events') }} de on de.order_id = oi.order_id 
    where de.event_type = 'checkout' and de.order_id is not null
)
select * from product_purchased