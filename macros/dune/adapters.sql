{% macro md5_string(input_string=None) -%}
  {% if input_string is none -%}
    {% set input_string = modules.datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f') %}
  {%- endif %}
  {{- local_md5(input_string) -}}
{%- endmacro %}


{% macro properties(properties, relation) %}

  {% set s3_bucket = 'trino-dev-datasets-118330671040' %}
  {%- set unique_location = '_' ~ md5_string() -%}

  {%- if properties is not none -%}
      WITH (
          location = 's3a://{{s3_bucket}}/hive/{{relation.schema}}/{{relation.identifier | replace("__dbt_tmp",unique_location)}}'
          {%- for key, value in properties.items() -%}
            {{ key }} = {{ value }}
            {%- if not loop.last -%}{{ ',\n  ' }}{%- endif -%}
          {%- endfor -%}
      )
  {%- else -%}
      WITH (
          location = 's3a://{{s3_bucket}}/hive/{{relation.schema}}/{{relation.identifier | replace("__dbt_tmp",unique_location)}}'
      )
  {%- endif -%}
{%- endmacro -%}

{% macro trino__create_table_as(temporary, relation, sql) -%}
  {%- set _properties = config.get('properties') -%}
  create or replace table {{ relation }}
    {{ properties(_properties, relation) }}
  as (
    {{ sql }}
  );
{% endmacro %}
