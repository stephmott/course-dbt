{{
  config(
    materialized='table'
  )
}}

SELECT 
    product_id
    ,name
    ,price
    ,inventory
FROM {{ref('stg_products')}}