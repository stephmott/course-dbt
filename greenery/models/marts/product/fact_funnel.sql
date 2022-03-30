
{{
  config(
    materialized='table'
  )
}}
-- level_1: Unique Sessions,product_id with a page_view,add_to_cart, or checkout/purchase event for that product
with level_1 as (
  select
    distinct session_id,product_id,event_type,min(created_at) as event_time
  from {{ ref('dim_events') }} 
  where event_type in ('page_view','add_to_cart')
  group by session_id,product_id,event_type
  UNION
  select distinct session_id,product_id,'checkout' as event_type,min(checkout_time) as event_time
  from {{ ref('int_conv_by_product') }} 
  where checkout_event = 'Y' and product_purchased = 'Y'
  group by session_id,product_id
),

-- level_2: Unique Sessions,product_id with a add_to_cart or checkout/purchase event for that product
level_2 as (
  select
    distinct session_id,product_id,event_type,min(created_at) as event_time
  from {{ ref('dim_events') }} 
  where event_type in ('add_to_cart')
  group by session_id,product_id,event_type
  UNION
  select distinct session_id,product_id,'checkout' as event_type,min(checkout_time) as event_time
  from {{ ref('int_conv_by_product') }} 
  where checkout_event = 'Y' and product_purchased = 'Y'
  group by session_id,product_id
),

-- level_3: Unique Sessions,product_id with a checkout/purchase event for that product
level_3 as (
  select distinct session_id,product_id,'checkout' as event_type,min(checkout_time) as event_time
  from {{ ref('int_conv_by_product') }} 
  where checkout_event = 'Y' and product_purchased = 'Y'
  group by session_id,product_id
),
funnel_dropoff as (
select 'Page_View,Add_to_Cart, or Checkout Event' as step, COUNT(distinct session_id) from level_1
  union -- joins the output of queries together (as long as they have the same columns)
select 'Add_to_Cart or Checkout Event' as step, COUNT(distinct session_id) from level_2
  union
select 'Checkout Event' as step, COUNT(distinct session_id) from level_3
order by count desc -- applies to the whole result set
)

select * from funnel_dropoff
