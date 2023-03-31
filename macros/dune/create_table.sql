{% macro properties(properties, relation) %}
  {% do log(relation, info=true) %}

  {% set s3_bucket = var('DBT_ENV_CUSTOM_ENV_S3_BUCKET', 'local') %}
  {%- if properties is not none -%}
      WITH (
          location = 's3a://{{s3_bucket}}/hive/{{relation.schema}}/{{relation.identifier | replace("__dbt_tmp","")}}'
          {%- for key, value in properties.items() -%}
            {{ key }} = {{ value }}
            {%- if not loop.last -%}{{ ',\n  ' }}{%- endif -%}
          {%- endfor -%}
      )
  {%- else -%}
      WITH (
          location = 's3a://{{s3_bucket}}/hive/{{relation.schema}}/{{relation.identifier | replace("__dbt_tmp","")}}'
      )
  {%- endif -%}
{%- endmacro -%}


{% macro trino__create_table_as(temporary, relation, sql) -%}
  {%- set _properties = config.get('properties') -%}
  create table {{ relation }}
    {{ properties(_properties, relation) }}
  as (
    {{ sql }}
  );
{% endmacro %}

{% macro trino__create_table(temporary, relation, sql) -%}
{%- set _properties = config.get('properties') -%}
create table {{ relation }}
    {{ properties(_properties, relation) }}
as (
    {{ sql }}
);
{% endmacro %}

{% macro trino__create_view_as(temporary, relation, sql) -%}
{%- set _properties = config.get('properties') -%}
create view {{ relation }}
    {{ properties(_properties, relation) }}
as (
    {{ sql }}
);
{% endmacro %}

{% macro trino__create_view(temporary, relation, sql) -%}
{%- set _properties = config.get('properties') -%}
create view {{ relation }}
    {{ properties(_properties, relation) }}
as (
    {{ sql }}
);
{% endmacro %}

{% macro trino__create_schema(schema) -%}
create schema if not exists {{ schema }}
{%- endmacro %}

{% macro trino__drop_schema(schema) -%}
drop schema if exists {{ schema }}
{%- endmacro %}

{% macro trino__drop_table(relation) -%}
drop table if exists {{ relation }}
{%- endmacro %}

{% macro trino__drop_view(relation) -%}
drop view if exists {{ relation }}
{%- endmacro %}

{% macro trino__rename_relation(from_relation, to_relation) -%}
rename table {{ from_relation }} to {{ to_relation }}
{%- endmacro %}

{% macro trino__rename_table(from_relation, to_relation) -%}
rename table {{ from_relation }} to {{ to_relation }}
{%- endmacro %}

{% macro trino__rename_view(from_relation, to_relation) -%}
rename view {{ from_relation }} to {{ to_relation }}
{%- endmacro %}

{% macro trino__truncate_relation(relation) -%}
truncate table {{ relation }}
{%- endmacro %}

{% macro trino__truncate_table(relation) -%}
truncate table {{ relation }}
{%- endmacro %}

{% macro trino__truncate_view(relation) -%}
truncate table {{ relation }}
{%- endmacro %}

{% macro trino__drop_relation(relation) -%}
{% if relation.type == 'table' %}
    {{ adapter.dispatch('drop_table', 'dbt')(relation) }}
{% elif relation.type == 'view' %}
    {{ adapter.dispatch('drop_view', 'dbt')(relation) }}
{% endif %}
{%- endmacro %}