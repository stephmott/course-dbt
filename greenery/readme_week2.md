### Week 2 Project questions:
- What is our user repeat rate? 99/124=.798 or about 80%
(Repeat Rate = Users who purchased 2 or more times / users who purchased)

    >with user_order as (  
        select user_id,count(*) as order_count from dbt_stephanie_m.stg_orders    
        group by user_id   
    )
    select count(ui3.user_id) from user_order ui3 where ui3.order_count >= 2;  (99)

    with user_order as (  
        select user_id,count(*) as order_count from dbt_stephanie_m.stg_orders    
        group by user_id   
    )
    select count(ui3.user_id) from user_order ui3 where ui3.order_count >= 1; (124)



- What are good indicators of a user who will likely purchase again?

    >Good indicators would be users that have purchased several times (or maybe at least twice) and have given good reviews if questioned about the site. Time browsing on the site may be a good indicator, or at least they are thinking about it.

- What about indicators of users who are likely NOT to purchase again? If you had more data, what features would you want to look into to answer this question?

    >Users that have never purchased, or have spent less than one minute on the site are not likely to make a purchase. Users that never received their package (lost) will probably not order again, or if their order took too long to get to them. You might want to find out why a user did not spend more time browsing the website, so you could add a survey at the end of a session to rate the website--perhaps they had trouble navigating the site or could not find their product.

