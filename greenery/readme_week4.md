### HW PART 1: 

I was able to set up a snapshot model, /snapshot/orders.sql that checked the estimated_delivery_at date for any changes. At first I used the created_at field, but finally realized it didn't change at all, and got the history going!!

Code: 
```
{% snapshot orders_snapshot %}

  {{
    config(
      target_schema='snapshots',
      unique_key='order_id',
      strategy='timestamp',
      updated_at='estimated_delivery_at',
    )
  }}

  SELECT * FROM {{ source('tutorial', 'orders') }}

{% endsnapshot %}
```

### PART 2 (Product Funnel):

I created the 3-level funnel using a granularity of session_id by product_id which made it a bit more difficult because the product_id is not in the events table for a checkout event as it's by session, not product. I had previously created an intermediate model, /core/intermediate/int_conv_by_product for a previous assignment, and this has the checkout/purchase event information by session and product. I used this model for the session checkout event info by product, unioned with a simple CTE from the events model for the event_types page_view and add_to_cart to complete the funnel.

[fact_funnel.sql](https://github.com/stephmott/course-dbt/greenery/models/marts/product/fact_funnel.sql)

Funnel Results:
```
Page_View,Add_to_Cart, or Checkout Event          578
Add_to_Cart or Checkout Event                     467
Checkout Event                                    361
```

### PART 3:
[Created post-hook and on-run-end](https://github.com/taylor67/course-dbt/blob/main/greenery/dbt_project.yml)
* "post-hooks to grant straight away" - [doc](https://discourse.getdbt.com/t/the-exact-grant-statements-we-use-in-a-dbt-project/430)
 - not sure if these two things in combo would make sense like this - what's the value of running grant `select` right when the model is built with the `post-hook`, but not granting `usage` until `on-run-end`? but this is how it's done in that linked doc.

### PART 4:
dbt `group_by` util used in [int_orders](https://github.com/taylor67/course-dbt/blob/main/greenery/models/marts/core/int_orders.sql)