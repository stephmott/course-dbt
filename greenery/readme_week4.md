### HW WEEK 4 
PART 1: 

I was able to set up a snapshot model, /snapshot/orders.sql that checked the estimated_delivery_at date for any changes. At first I used the created_at field, but finally realized it didn't change at all, and got the history going with the estimated_delivery_at field!!

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

[fact_funnel.sql](https://github.com/stephmott/course-dbt/tree/main/greenery/models/marts/product/fact_funnel.sql)


Funnel Results:
```
                                          count     lag     drop_off
                                          
Page_View,Add_to_Cart, or Checkout Event    578     null    null
Add_to_Cart or Checkout Event               467     578     0.19
Checkout Event                              361     467     0.23
```

### PART 3: Reflection questions
#### 3A. if your organization is thinking about using dbt, how would you pitch the value of dbt/analytics engineering to a decision maker at your organization?

University of California Santa Cruz (UCSC) and our group, Data Management, are not currently using dbt, but we are educating ourselves and hope to use it in the future. I think my boss has the power to decide to use it, and I think he is planning on using it for future projects which is a really good thing, but I think it is good to be able to say what the benefits are to folks we interface with and explain what it does so they see the value as well. 
1) Seemless interface with Git and database, so there is no 'by hand' or even 'by script' loading of tables, or making changes. It is all saved in the models and in git where we run our models from.
2) table load dependencies are transparent with the DAG's, so no searching through code or having to document what you have done--its just there! (YOu do need to put in the descriptions though), but then it is self documenting. Also great metadata about run times, etc. (More metrics coming soon!)
3) Built-in testing of field values and indexes
4) Mostly Database agnostic, so it's easy to change from one source to another (dev to prod), and easier from one type of database to another (Postgres to Snowflake)
5) Flexible: can write macros, add packages, and has table processing types like snapshot built in
6) Easier for non programmers to understand and use

#### 3B. Setting up for production / scheduled dbt run of your project

I'm pretty interested in investigating Dagster and Airflow as these are open source. I used dbt Cloud when taking the Fundamentals course, but a deeper dive might be good on that one too. 

0) Of course, we would do 'dbt snapshot', 'dbt run' and 'dbt test'
1) Next, I think I would add the steps to generate the docs files and load them into some tables, figuring out what is the best way to store them for easy searching.
2) Then I would like to record some easy metadata on the runs like runtime and errors on each model,  and look at storing run_results.json somewhere in my database for analysis. And later, expand on this as we understand what information is available. This could also be put into a dashboard. 
