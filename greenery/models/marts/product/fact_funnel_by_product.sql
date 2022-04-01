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
funnel_steps as (
select 'Page_View,Add_to_Cart, or Checkout Event' as step,product_id, COUNT(*) from level_1 group by product_id
  union -- joins the output of queries together (as long as they have the same columns)
select 'Add_to_Cart or Checkout Event' as step, product_id, COUNT(*) from level_2 group by product_id
  union
select 'Checkout Event' as step, product_id, COUNT(*)  from level_3 group by product_id 
order by count desc -- applies to the whole result set
),
funnel_by_product as (
select
    product_id
    ,step
  ,(case when fs.step = 'Page_View,Add_to_Cart, or Checkout Event' then 1
        when fs.step = 'Add_to_Cart or Checkout Event' then 2
        else 3
    end) as step_num
  ,count
  ,(case when fs.step = 'Page_View,Add_to_Cart, or Checkout Event' then null 
         when fs.step = 'Add_to_Cart or Checkout Event' then 
            (select count from funnel_steps fs2 where fs2.step = 'Page_View,Add_to_Cart, or Checkout Event' and fs2.product_id = fs.product_id)
         when fs.step = 'Checkout Event' then
          (select count from funnel_steps fs2 where fs2.step = 'Add_to_Cart or Checkout Event' and fs2.product_id = fs.product_id)
    end) as lag_num
 -- ,round((1.0 - count::numeric/lag_num::numeric),2) as drop_off
from funnel_steps fs
order by product_id,step
)
select *
,round((1.0 - count::numeric/lag_num::numeric),2) as drop_off
 from funnel_by_product
order by product_id,step_num
