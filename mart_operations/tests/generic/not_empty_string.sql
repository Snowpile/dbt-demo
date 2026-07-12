{% test not_empty_string(model, column_name) %}
-- Custom generic test: fails for rows where a text column is null or blank
-- (empty or whitespace-only after trimming).
select {{ column_name }}
from {{ model }}
where {{ column_name }} is null
   or length(trim({{ column_name }})) = 0
{% endtest %}
