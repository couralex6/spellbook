{{ config(
    alias = 'events',
    partition_by = ['block_date'],
    materialized = 'incremental',
    file_format = 'delta',
    incremental_strategy = 'merge',
    unique_key = ['block_date', 'unique_trade_id'],
    post_hook='{{ expose_spells(\'["ethereum"]\',
                                "project",
                                "blur",
                                \'["hildobby","pandajackson42"]\') }}')
}}

{% set project_start_date = '2022-10-18' %}
{% set seaport_usage_start_date = '2023-01-25' %}

SELECT
    'ethereum' AS blockchain
    , 'blur' AS project
    , 'v1' AS version
    , CAST(date_trunc('day', bm.evt_block_time) AS timestamp) AS block_date
    , CAST(bm.evt_block_time AS timestamp) AS block_time
    , CAST(bm.evt_block_number AS double) AS block_number
    , CAST(json_extract_scalar(bm.sell, '$.tokenId') AS varchar) AS token_id
    , nft.standard AS token_standard
    , nft.name AS collection
    , CASE WHEN CAST(JSON_EXTRACT_SCALAR(bm.buy, '$.amount') AS DOUBLE) = 1 THEN 'Single Item Trade'
            ELSE 'Bundle Trade'
            END AS trade_type
    , CAST(JSON_EXTRACT_SCALAR(bm.buy, '$.amount') AS DOUBLE) AS number_of_items
    , 'Trade' AS evt_type
    , CASE WHEN JSON_EXTRACT_SCALAR(bm.sell, '$.trader') = agg.contract_address THEN et."from" ELSE JSON_EXTRACT_SCALAR(bm.sell, '$.trader') END AS seller
    , CASE WHEN JSON_EXTRACT_SCALAR(bm.buy, '$.trader') = agg.contract_address THEN et."from" ELSE JSON_EXTRACT_SCALAR(bm.buy, '$.trader') END AS buyer
    , CASE WHEN JSON_EXTRACT_SCALAR(bm.buy, '$.matchingPolicy') IN (0x00000000006411739da1c40b106f8511de5d1fac, 0x0000000000dab4a563819e8fd93dba3b25bc3495) THEN 'Buy'
        WHEN JSON_EXTRACT_SCALAR(bm.buy, '$.matchingPolicy') IN (0x0000000000b92d5d043faf7cecf7e2ee6aaed232) THEN 'Offer Accepted'
        WHEN et."from" = JSON_EXTRACT_SCALAR(bm.buy, '$.trader') THEN 'Buy'
        WHEN et."from" = JSON_EXTRACT_SCALAR(bm.sell, '$.trader') THEN 'Offer Accepted'
        ELSE 'Unknown'
        END AS trade_category
    , CAST(JSON_EXTRACT_SCALAR(bm.buy, '$.price') AS DOUBLE) AS amount_raw
    , CASE WHEN JSON_EXTRACT_SCALAR(bm.buy, '$.paymentToken') IN (0x0000000000000000000000000000000000000000, 0x0000000000a39bb272e79075ade125fd351887ac) THEN CAST(JSON_EXTRACT_SCALAR(bm.buy, '$.price') / POWER(10, 18) AS double)
        ELSE CAST(JSON_EXTRACT_SCALAR(bm.buy, '$.price') / POWER(10, pu.decimals) AS double)
        END AS amount_original
    , CASE WHEN JSON_EXTRACT_SCALAR(bm.buy, '$.paymentToken') IN (0x0000000000000000000000000000000000000000, 0x0000000000a39bb272e79075ade125fd351887ac) THEN CAST(pu.price * JSON_EXTRACT_SCALAR(bm.buy, '$.price') / POWER(10, 18) AS double)
        ELSE CAST(pu.price * JSON_EXTRACT_SCALAR(bm.buy, '$.price') / POWER(10, pu.decimals) AS double)
        END AS amount_usd
    , CASE WHEN JSON_EXTRACT_SCALAR(bm.buy, '$.paymentToken') IN (0x0000000000000000000000000000000000000000, 0x0000000000a39bb272e79075ade125fd351887ac) THEN 'ETH'
        ELSE pu.symbol
        END AS currency_symbol
    , CASE
        WHEN json_extract_scalar(bm.buy, '$.paymentToken') IN (0x0000000000000000000000000000000000000000, 0x0000000000a39bb272e79075ade125fd351887ac)
        THEN 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
    ELSE JSON_EXTRACT_SCALAR(bm.buy, '$.paymentToken')
    END AS currency_contract
    , bm.contract_address AS project_contract_address
    , JSON_EXTRACT_SCALAR(bm.buy, '$.collection') AS nft_contract_address
    , coalesce(agg.name,agg_m.aggregator_name) AS aggregator_name
    , agg.contract_address AS aggregator_address
    , bm.evt_tx_hash AS tx_hash
    , et."from" AS tx_from
    , et."to" AS tx_to
    , CAST(0 AS DOUBLE) AS platform_fee_amount_raw
    , CAST(0 AS DOUBLE) AS platform_fee_amount
    , CAST(0 AS DOUBLE) AS platform_fee_amount_usd
    , CAST(0 AS DOUBLE) AS platform_fee_percentage
    , CAST(COALESCE(JSON_EXTRACT_SCALAR(bm.buy, '$.price') * JSON_EXTRACT_SCALAR(JSON_EXTRACT(bm.sell, '$.fees[0]'), '$.rate') / 10000, 0) AS DOUBLE) AS royalty_fee_amount_raw
    , CASE
        WHEN JSON_EXTRACT_SCALAR(bm.buy, '$.paymentToken') IN (0x0000000000000000000000000000000000000000, 0x0000000000a39bb272e79075ade125fd351887ac)
        THEN CAST(COALESCE(JSON_EXTRACT_SCALAR(bm.buy, '$.price') / POWER(10, 18) * JSON_EXTRACT_SCALAR(JSON_EXTRACT(bm.sell, '$.fees[0]'), '$.rate') / 10000, 0) AS DOUBLE)
        ELSE CAST(COALESCE(JSON_EXTRACT_SCALAR(bm.buy, '$.price') / POWER(10, pu.decimals) * JSON_EXTRACT_SCALAR(JSON_EXTRACT(bm.sell, '$.fees[0]'), '$.rate') / 10000, 0) AS DOUBLE)
        END AS royalty_fee_amount
    , CASE
        WHEN JSON_EXTRACT_SCALAR(bm.buy, '$.paymentToken') IN (0x0000000000000000000000000000000000000000, 0x0000000000a39bb272e79075ade125fd351887ac)
        THEN CAST(COALESCE(pu.price * JSON_EXTRACT_SCALAR(bm.buy, '$.price') / POWER(10, 18) * JSON_EXTRACT_SCALAR(JSON_EXTRACT(bm.sell, '$.fees[0]'), '$.rate') / 10000, 0) AS DOUBLE)
        ELSE CAST(COALESCE(pu.price * JSON_EXTRACT_SCALAR(bm.buy, '$.price') / POWER(10, pu.decimals) * JSON_EXTRACT_SCALAR(JSON_EXTRACT(bm.sell, '$.fees[0]'), '$.rate') / 10000, 0) AS DOUBLE)
        END AS royalty_fee_amount_usd
    , CAST(COALESCE(JSON_EXTRACT_SCALAR(JSON_EXTRACT(bm.sell, '$.fees[0]'), '$.rate') / 100, 0) AS DOUBLE) AS royalty_fee_percentage
    , JSON_EXTRACT_SCALAR(JSON_EXTRACT(bm.sell, '$.fees[0]'), '$.recipient') AS royalty_fee_receive_address

    , CASE
            WHEN json_extract_scalar(json_extract(bm.sell, '$.fees[0]'), '$.recipient') IS NOT NULL AND json_extract_scalar(bm.buy, '$.paymentToken') IN (0x0000000000000000000000000000000000000000, 0x0000000000a39bb272e79075ade125fd351887ac)
            THEN 'ETH'
          WHEN json_extract_scalar(json_extract(bm.sell, '$.fees[0]'), '$.recipient') IS NOT NULL
          THEN pu.symbol
        END AS royalty_fee_currency_symbol
        , CAST('ethereum-blur-v1-' || bm.evt_block_number || '-' || bm.evt_tx_hash || '-' || bm.evt_index AS varchar) AS unique_trade_id
FROM {{ source('blur_ethereum','BlurExchange_evt_OrdersMatched') }} bm
JOIN {{ source('ethereum','transactions') }} et ON et.block_number=bm.evt_block_number
    AND et.hash=bm.evt_tx_hash
    {% if not is_incremental() %}
    AND et.block_time >= timestamp TIMESTAMP '{{project_start_date}}'
    {% endif %}
    {% if is_incremental() %}
    AND et.block_time >= date_trunc('day', now() - interval '1' week)
    {% endif %}
LEFT JOIN {{ ref('nft_ethereum_aggregators') }} agg ON agg.contract_address=et.to
LEFT JOIN {{ ref('nft_ethereum_aggregators_markers') }} agg_m
    ON substr(et.data, -agg_m.hash_marker_size) = agg_m.hash_marker
LEFT JOIN {{ source('prices','usd') }} pu ON pu.blockchain='ethereum'
    AND pu.minute=date_trunc('minute', bm.evt_block_time)
    AND (pu.contract_address=JSON_EXTRACT_SCALAR(bm.buy, '$.paymentToken')
        OR (pu.contract_address=0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 AND JSON_EXTRACT_SCALAR(bm.buy, '$.paymentToken')=0x0000000000000000000000000000000000000000)
        OR (pu.contract_address=0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 AND JSON_EXTRACT_SCALAR(bm.buy, '$.paymentToken')=0x0000000000a39bb272e79075ade125fd351887ac))
    {% if not is_incremental() %}
    AND pu.minute >= timestamp TIMESTAMP '{{project_start_date}}'
{% endif %}
{% if is_incremental() %}
AND pu.minute >= date_trunc('day', now() - interval '1' week)
{% endif %}
LEFT JOIN {{ ref('tokens_ethereum_nft') }} nft ON json_extract_scalar(bm.buy, '$.collection') = nft.contract_address
{% if is_incremental() %}
WHERE bm.evt_block_time >= date_trunc('day', now() - interval '1' week)
{% endif %}

UNION ALL

SELECT
    'ethereum' AS blockchain
    , 'blur' AS project
    , 'v1' AS version
    , CAST(date_trunc('day', s.evt_block_time) AS timestamp) AS block_date
    , CAST(s.evt_block_time AS timestamp) AS block_time
    , CAST(s.evt_block_number AS double) AS block_number
    , CAST(json_extract_scalar(s.offer[0], '$.identifier') AS varchar) AS token_id
    , nft_tok.standard AS token_standard
    , nft_tok.name AS collection
    , CASE WHEN json_extract_scalar(s.offer[0], '$.amount') = '1' THEN 'Single Item Trade' ELSE 'Bundle Trade' END AS trade_type
    , CAST(json_extract_scalar(s.offer[0], '$.amount') AS DOUBLE) AS number_of_items
    , 'Trade' AS evt_type
    , s.offerer AS seller
    , s.recipient AS buyer
    , 'Buy' AS trade_category
    , CAST(json_extract_scalar(s.consideration[0], '$.amount') + json_extract_scalar(s.consideration[1], '$.amount') AS DOUBLE) AS amount_raw
    , CAST((json_extract_scalar(s.consideration[0], '$.amount')+json_extract_scalar(s.consideration[1], '$.amount'))/POWER(10, 18) AS double) AS amount_original
    , CAST(pu.price*(json_extract_scalar(s.consideration[0], '$.amount')+json_extract_scalar(s.consideration[1], '$.amount'))/POWER(10, 18) AS double) AS amount_usd
    , CASE WHEN json_extract_scalar(s.consideration[0], '$.token')=0x0000000000000000000000000000000000000000 THEN 'ETH' ELSE currency_tok.symbol END AS currency_symbol
    , json_extract_scalar(s.consideration[0], '$.token') AS currency_contract
    , s.contract_address AS project_contract_address
    , json_extract_scalar(s.offer[0], '$.token') AS nft_contract_address
    , CAST(NULL AS varchar) AS aggregator_name
    , CAST(NULL AS varchar) AS aggregator_address
    , s.evt_tx_hash AS tx_hash
    , tx."from" AS tx_from
    , tx."to" AS tx_to
    , CAST(0 AS DOUBLE) AS platform_fee_amount_raw
    , CAST(0 AS DOUBLE) AS platform_fee_amount
    , CAST(0 AS DOUBLE) AS platform_fee_amount_usd
    , CAST(0 AS DOUBLE) AS platform_fee_percentage
    , LEAST(CAST(json_extract_scalar(s.consideration[0], '$.amount') AS DOUBLE), CAST(json_extract_scalar(s.consideration[1], '$.amount') AS DOUBLE)) AS royalty_fee_amount_raw
    , LEAST(CAST(json_extract_scalar(s.consideration[0], '$.amount') AS DOUBLE), CAST(json_extract_scalar(s.consideration[1], '$.amount') AS DOUBLE))/POWER(10, 18) AS royalty_fee_amount
    , pu.price*LEAST(CAST(json_extract_scalar(s.consideration[0], '$.amount') AS DOUBLE), CAST(json_extract_scalar(s.consideration[1], '$.amount') AS DOUBLE))/POWER(10, 18) AS royalty_fee_amount_usd
    , 100.0*LEAST(CAST(json_extract_scalar(s.consideration[0], '$.amount') AS DOUBLE), CAST(json_extract_scalar(s.consideration[1], '$.amount') AS DOUBLE))
        /CAST(CAST(json_extract_scalar(s.consideration[0], '$.amount') AS DOUBLE)+CAST(json_extract_scalar(s.consideration[1], '$.amount') AS DOUBLE) AS DOUBLE) AS royalty_fee_percentage
    , CASE WHEN json_extract_scalar(s.consideration[0], '$.token')=0x0000000000000000000000000000000000000000 THEN 'ETH' ELSE currency_tok.symbol END AS royalty_fee_currency_symbol
    , CASE WHEN json_extract_scalar(s.consideration[0], '$.recipient')!=s.recipient THEN json_extract_scalar(s.consideration[0], '$.recipient')
        ELSE json_extract_scalar(s.consideration[1], '$.recipient')
        END AS royalty_fee_receive_address
    , CAST('ethereum-blur-v1-' || s.evt_block_number || '-' || s.evt_tx_hash || '-' || s.evt_index AS varchar) AS unique_trade_id
FROM {{ source('seaport_ethereum','Seaport_evt_OrderFulfilled') }} s
INNER JOIN {{ source('ethereum', 'transactions') }} tx ON tx.block_number=s.evt_block_number
    AND tx.hash=s.evt_tx_hash
    {% if is_incremental() %}
    AND tx.block_time >= date_trunc('day', now() - interval '7' day)
    {% endif %}
    {% if not is_incremental() %}
    AND tx.block_time >= timestamp '{{seaport_usage_start_date}}'
    {% endif %}
LEFT JOIN {{ ref('tokens_ethereum_nft') }} nft_tok ON nft_tok.contract_address=JSON_EXTRACT_SCALAR(s.offer[0], '$.token')
LEFT JOIN {{ ref('tokens_ethereum_erc20') }} currency_tok ON currency_tok.contract_address=JSON_EXTRACT_SCALAR(s.consideration[0], '$.token')
LEFT JOIN {{ ref('prices_usd_forward_fill') }} pu ON ((pu.contract_address=JSON_EXTRACT_SCALAR(s.consideration[0], '$.token') AND pu.blockchain='ethereum')
        OR (JSON_EXTRACT_SCALAR(s.consideration[0], '$.token')=0x0000000000000000000000000000000000000000  AND pu.blockchain IS NULL AND pu.contract_address IS NULL AND pu.symbol='ETH'))
    AND pu.minute=date_trunc('minute', s.evt_block_time)
    {% if is_incremental() %}
    AND pu.minute >= date_trunc('day', now() - interval '7' day)
    {% endif %}
    {% if not is_incremental() %}
    AND pu.minute >= timestamp '{{seaport_usage_start_date}}'
    {% endif %}
WHERE s.zone=0x0000000000d80cfcb8dfcd8b2c4fd9c813482938
{% if is_incremental() %}
AND s.evt_block_time >= date_trunc('day', now() - interval '7' day)
{% endif %}
{% if not is_incremental() %}
AND s.evt_block_time >= timestamp '{{seaport_usage_start_date}}'
{% endif %}
