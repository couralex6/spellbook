{{ config(
        alias ='trades'
        )
}} {% set uniswap_models = [
'uniswap_v1_ethereum_trades'
,'uniswap_v2_ethereum_trades'
,'uniswap_v3_ethereum_trades'
] %} SELECT * FROM (SELECT blockchain, project, version, block_date, block_time, token_bought_symbol, token_sold_symbol, token_pair, CAST(token_bought_amount AS DOUBLE), CAST(token_sold_amount AS DOUBLE), TRY_CAST(CAST(token_bought_amount_raw AS DOUBLE) AS DECIMAL(38, 0)) AS token_bought_amount_raw, TRY_CAST(CAST(token_sold_amount_raw AS DOUBLE) AS DECIMAL(38, 0)) AS token_sold_amount_raw, CAST(amount_usd AS DOUBLE), token_bought_address, token_sold_address, taker, maker, project_contract_address, tx_hash, tx_from, tx_to, trace_address, evt_index FROM {{ ref('dex_model') }}) {% if not loop.last %} UNION ALL {% endif %} {% endfor %}