{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if target.name == 'prod' or target.schema == 'wizard' and custom_schema_name is not none -%}

        delta_prod.{{ custom_schema_name | trim }}

    {%- elif target.schema.startswith("git_") -%}

        {{ 'test_schema' }}

    {%- elif custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}

        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
