{% test not_negative(model, column_name) %}
-- Custom generic test: fails for any row where the column is negative.
select {{ column_name }}
from {{ model }}
where {{ column_name }} < 0
{% endtest %}
