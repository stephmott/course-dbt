### Week 1 Project questions:
- How many users do we have? 130

    >select count(distinct user_id) from dbt_stephanie_m.stg_users;

- On average, how many orders do we receive per hour?  7.5208333333333333

    >with order_count as (  
        select date(created_at) as date_created,extract(hour from created_at)   as hour_created,count(\*) as num_orders  
        from dbt_stephanie_m.stg_orders  
        group by date(created_at),extract(hour from created_at)  
    )  
    select avg(num_orders) from order_count;  

- On average, how long does an order take from being placed to being delivered?   3 days 21:24:11.803279

    >select avg(delivered_at - created_at) from dbt_stephanie_m.stg_orders       where delivered_at is not null;  

- How many users have only made one purchase? 25  

    >with user_order as (   
        select user_id,count(\*) as order_count from dbt_stephanie_m.stg_orders    
        group by user_id  
    )  
    select count(*) from user_order where order_count = 1  

- Two purchases? 28  

    >with user_order as (  
        select user_id,count(\*) as order_count from dbt_stephanie_m.stg_orders    
        group by user_id   
    )  
    select count(\*) from user_order where order_count = 2;  

- Three+ purchases? 71  

    >with user_order as (  
        select user_id,count(\*) as order_count from dbt_stephanie_m.stg_orders    
        group by user_id   
    )  
    select count(\*) from user_order where order_count >= 3;  

- On average, how many unique sessions do we have per hour? 16.3275862068965517

    >with sessions_count as (  
        select session_id,date(created_at) as date_created,extract(hour from created_at) as hour_created,count(\*) as num_sessions   
        from dbt_stephanie_m.stg_events   
        group by session_id,date(created_at),extract(hour from created_at)  
    ),  
    num_sessions_per_hour as (  
        select date_created,hour_created,count(\*) as num_unique_sessions   
        from sessions_count   
        group by date_created,hour_created  
     )  
    select avg(num_unique_sessions) from num_sessions_per_hour;      