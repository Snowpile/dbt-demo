{% test accepted_range(model, column_name, min_value=none, max_value=none, inclusive=true) %}
-- Custom generic test with arguments: fails for rows where the numeric column
-- falls outside [min_value, max_value]. Bounds are optional and inclusive by default.
with validation as (
    select {{ column_name }} as val
    from {{ model }}
    where {{ column_name }} is not null
)

select val
from validation
where
    {% if min_value is not none %}
        val {{ '<' if inclusive else '<=' }} {{ min_value }}
        {% if max_value is not none %} or {% endif %}
    {% endif %}
    {% if max_value is not none %}
        val {{ '>' if inclusive else '>=' }} {{ max_value }}
    {% endif %}
    {% if min_value is none and max_value is none %}
        false
    {% endif %}
{% endtest %}
