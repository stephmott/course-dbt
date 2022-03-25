{{
  config(
    materialized='table'
  )
}}

with conv_by_product as (
SELECT 
    du2.session_id
    ,pv.product_id
    ,ce.order_id
    ,CASE WHEN ce.session_id is null THEN 'N' else 'Y' end AS checkout_event
    ,ce.checkout_time
    ,CASE WHEN pp.product_id is null THEN 'N' else 'Y' end AS product_purchased
    ,pv.view_time
FROM {{ ref('dim_events') }} du2 
join {{ ref('int_product_viewed') }} pv on pv.session_id=du2.session_id -- only those products that were viewed, assuming product must be viewed to purchase item
left join {{ ref('int_checkout_event') }} ce on ce.session_id = du2.session_id --fill in if they had a checkout event
left join {{ ref('int_product_purchased') }} pp on pp.session_id=du2.session_id and pp.order_id = ce.order_id
  and pp.product_id = pv.product_id
)
select * from conv_by_product