{{ config(
        schema = 'ovm_optimism'
        , alias='l2_token_factory'
        , materialized = 'incremental'
        , file_format = 'delta'
        , incremental_strategy = 'merge'
        , unique_key = ['l1_token', 'l2_token']
        , post_hook='{{ expose_spells(\'["optimism"]\',
                                  "project",
                                  "ovm_optimism",
                                  \'["msilb7"]\') }}'
        ,depends_on=['tokens_optimism_erc20','tokens_erc20']
  )
}} SELECT contract_address AS factory_address, _l1Token AS l1_token, _l2Token AS l2_token, _symbol AS symbol, _name AS name, decimals, call_tx_hash, call_block_time, call_block_number FROM (SELECT c1.contract_address, c1._l1Token, tc._l2Token, _symbol, _name, COALESCE(t.decimals, 18) AS decimals, c1.call_tx_hash, c1.call_block_time, c1.call_block_number FROM {{ source('ovm_optimism','L2StandardTokenFactory_call_createStandardL2Token') }} AS c1 INNER JOIN {{ source('ovm_optimism','L2StandardTokenFactory_evt_StandardL2TokenCreated') }} AS tc ON c1.call_block_number = tc.evt_block_number AND c1.call_tx_hash = tc.evt_tx_hash AND tc.evt_block_time >= DATE_TRUNC('day', NOW() - INTERVAL '7' day /* week doesnt work in duneSQL */) LEFT JOIN {{ ref('tokens_ethereum_erc20') }} AS t ON t.contract_address = c1._l1Token{% if is_incremental() %}  WHERE call_success = TRUE AND c1.call_block_time >= DATE_TRUNC('day', NOW() - INTERVAL '7' day /* week doesnt work in duneSQL */) UNION ALL SELECT c2.contract_address, c2._l1Token, _l2Token, _symbol, _name, COALESCE(t.decimals, 18) AS decimals, c2.call_tx_hash, c2.call_block_time, c2.call_block_number FROM {{ source('ovm_optimism','OVM_L2StandardTokenFactory_call_createStandardL2Token') }} AS c2 INNER JOIN {{ source('ovm_optimism','OVM_L2StandardTokenFactory_evt_StandardL2TokenCreated') }} AS tc ON c2.call_block_number = tc.evt_block_number AND c2.call_tx_hash = tc.evt_tx_hash AND tc.evt_block_time >= DATE_TRUNC('day', NOW() - INTERVAL '7' day /* week doesnt work in duneSQL */) LEFT JOIN {{ ref('tokens_ethereum_erc20') }} AS t ON t.contract_address = c2._l1Token{% if is_incremental() %}  WHERE call_success = TRUE AND c2.call_block_time >= DATE_TRUNC('day', NOW() - INTERVAL '7' day /* week doesnt work in duneSQL */)) AS a