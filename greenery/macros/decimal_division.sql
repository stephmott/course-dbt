{% macro decimal_division(numerator, denominator=1) %}
    {% if denominator == 0 %}
        0
    {% else %}
        {{ numerator }} ::decimal/({{ denominator }}::decimal)
    {% endif %}
{% endmacro %}