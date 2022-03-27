{{
  config(
    materialized='table'
  )
}}

{% set types = dbt_utils.get_column_values(table=ref('dim_events'), column='event_type', max_records=50) %}
with
{% for type in types %}
{{type}}_count as (
select count(*) as {{type}}_count from {{ ref('dim_events') }} where event_type = '{{type}}' 
)
{% if not loop.last %},{% endif %}
{% endfor %}
select 
{% for type in types %}
{{type}}_count.*
{% if not loop.last %},{% endif %}
{% endfor %}
from 
{% for type in types %}
{{type}}_count
{% if not loop.last %},{% endif %}
{% endfor %}



