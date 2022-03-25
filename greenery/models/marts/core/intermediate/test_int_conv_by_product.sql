{{
  config(
    materialized='table'
  )
}}
with product_viewed as (
    select 
        session_id as pv_session
        ,product_id as pv_product
        ,view_time
    from {{ ref('int_product_viewed') }}
),
conv_by_product as (
SELECT 
    du2.session_id 
    ,pv_product
    ,ce.order_id
    ,CASE WHEN ce.session_id is null THEN 'N' else 'Y' end AS checkout_event
    ,ce.checkout_time
 --   ,CASE WHEN pp.product_id is null THEN 'N' else 'Y' end AS product_purchased
    ,{{max_checkout_time(session_id,pv_product)}}
FROM {{ ref('dim_events') }} du2 
join product_viewed on pv_session=du2.session_id -- only those products that were viewed, assuming product must be viewed to purchase item
left join {{ ref('int_checkout_event') }} ce on ce.session_id = du2.session_id --fill in if they had a checkout event
--left join {{ ref('int_product_purchased') }} pp on pp.session_id=du2.session_id and pp.order_id = ce.order_id
--  and pp.product_id = pv.product_id
)
select * from conv_by_product