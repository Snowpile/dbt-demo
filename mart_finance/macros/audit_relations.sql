{% macro audit_relations() %}
    {#-
      run-operation demo: prints a live row count for each finance mart.
      Invoke with:  dbt run-operation audit_relations
      Uses run_query() (the friendly wrapper around the statement() block) so it
      executes against the warehouse at runtime rather than at parse time.
    -#}
    {% set marts = ['finance_fct_order_revenue', 'finance_fct_daily_revenue', 'finance_dim_product'] %}
    {% if execute %}
        {% for mart in marts %}
            {% set query %}
                select count(*) as row_count from {{ ref(mart) }}
            {% endset %}
            {% set results = run_query(query) %}
            {{ log("audit_relations: " ~ mart ~ " = " ~ results.columns[0].values()[0] ~ " rows", info=true) }}
        {% endfor %}
    {% endif %}
{% endmacro %}
