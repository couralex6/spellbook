{% macro mark_as_spell(this, materialization) %}
{%- if target.name == 'prod' or True -%} -- TODO: Only enable this in prod before launching
        ALTER {{"view" if materialization == "view" else "table"}} {{ this }}
        SET PROPERTIES extra_properties = map_from_entries (ARRAY[
        ROW('dune.data_explorer.category', 'abstraction')
        ])
{%- else -%}
{%- endif -%}
{%- endmacro -%}
