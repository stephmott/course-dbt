{% macro max_checkout_time(session_id, product) %}
                (select created_at 
                from {{ ref('dim_order_items') }} oi
                join {{ ref('dim_events') }} de on de.order_id = oi.order_id 
                where de.event_type = 'checkout' and de.order_id is not null 
                and oi.product_id = '{{ product }}' and de.session_id = '{{ session_id }}'
                )
{% endmacro %}