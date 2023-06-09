{% macro expose_spells(blockchains, spell_type, spell_name, contributors) %}
{%- if target.name == 'prod' or True -%} -- TODO: Only enable this in prod before launching
        ALTER {{"view" if model.config.materialized == "view" else "table"}} {{ this }}
        SET PROPERTIES extra_properties = map_from_entries(ARRAY[
        ROW('dune.public', 'true'),
        ROW('dune.data_explorer.blockchains', '{{ blockchains }}'),     -- e.g., ["ethereum","solana"]
        ROW('dune.data_explorer.category', 'abstraction'),
        ROW('dune.data_explorer.abstraction.type', '{{ spell_type }}'), -- 'project' or 'sector'
        ROW('dune.data_explorer.abstraction.name', '{{ spell_name }}'), -- 'aave' or 'uniswap'
        ROW('dune.data_explorer.contributors','{{ contributors }}')   -- e.g., ["soispoke","jeff_dude"]
        )
{%- else -%}
{%- endif -%}
{%- endmacro -%}
