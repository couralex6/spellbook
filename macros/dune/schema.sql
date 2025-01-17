{% macro create_schema(relation) -%}
  {{ adapter.dispatch('create_schema', 'dbt')(relation) }}
{% endmacro %}

{% macro default__create_schema(relation) -%}
  {% set s3_bucket = 'trino-dev-datasets-118330671040' %}
  {% do log('default__create_schema', info=true) %}
  {%- call statement('create_schema') -%}
   CREATE SCHEMA {{ relation }} WITH (location = 's3a://{{s3_bucket}}/hive')
  {% endcall %}
  {% do log('end', info=true) %}
{% endmacro %}
