"""
Script to translate spells found in spellbook repository.

Command to find paths for all SQL files for a given model:

dbt ls --resource-type model --output path --select +uniswap_trades


"""

import os
from fnmatch import fnmatch
import requests
import json


# # Directory containing spells
# SPELLS_MODEL_PATH = "/Users/couralex/src/spellbook/models"

# # We are interested in files whose name ends with .sql
# pattern = "*.sql"

# # Walking the directory to find all spells
# for path, subdirs, files in os.walk(SPELLS_MODEL_PATH):
#     for name in files:
#         if fnmatch(name, pattern):
#             print(os.path.join(path, name))

def translate_query(query):
    url = "http://localhost:8000"
    payload = {
        "query": query,
        "dataset": "spark",
        "dialect": "spark"
    }
    response = requests.post(url, json=payload)
    if response.status_code == 200:
        # print("Success")
        query = json.loads(response.text)["translated"]
        return query
    else:
        print(f"Request failed with error code {response.status_code}")
        print(json.loads(response.text))
        return "error"


def translate_one_spell(base_path, query_to_test):
    """
    Translates a single spell and returns the translated query and the original query
    """
    with open(base_path + query_to_test) as f:
        original = f.read()
        translated = translate_query(original)
        return translated, original


def spell_exists(base_path, query):
    """
    Checks if a spell exists in the spellbook repository
    """
    full_path = base_path + query
    return os.path.exists(full_path)


def translate_list(base_path, queries):
    """
    Translates a list of spells and prints the translated query
    """
    for query in queries:
        print(translate_one_spell(base_path, query)[0])


def translate_list_to_file(base_path, queries):
    """
    Translates a list of spells and writes the translated query to a file.
    Translated files are written to the same directory as the original file, but with the extension .translated.sql .
    """
    correct_count = 0
    total_count = 0
    for query in queries:
        full_path = base_path + query

        if not spell_exists(base_path, query):
            print(f"Spell {query} does not exist")
            continue

        total_count += 1
        translated, original = translate_one_spell(base_path, query)

        if translated != "error":
            correct_count += 1
            translated_path = full_path.replace(".sql", ".translated.sql")
            with open(translated_path, "w") as f:
                f.write(translated)
        else:
            print(f"Error with {query}")

    print("========================================================")
    print(f"Translated {correct_count} out of {total_count} spells")


base_path = "/Users/couralex/src/spellbook/"
query_to_test = "models/uniswap/arbitrum/uniswap_arbitrum_trades.sql"
queries = [
    "models/ovm/optimism/ovm_optimism_l2_token_factory.sql",
    "models/tokens/arbitrum/tokens_arbitrum_erc20.sql",
    "models/tokens/avalanche_c/tokens_avalanche_c_erc20.sql",
    "models/tokens/bnb/tokens_bnb_bep20.sql",
    "models/tokens/tokens_erc20.sql",
    "models/tokens/ethereum/tokens_ethereum_erc20.sql",
    "models/tokens/fantom/tokens_fantom_erc20.sql",
    "models/tokens/gnosis/tokens_gnosis_erc20.sql",
    "models/tokens/optimism/tokens_optimism_erc20.sql",
    "models/tokens/optimism/tokens_optimism_erc20_bridged_mapping.sql",
    "models/tokens/polygon/tokens_polygon_erc20.sql",
    "models/uniswap/arbitrum/uniswap_arbitrum_trades.sql",
    "models/uniswap/ethereum/uniswap_ethereum_trades.sql",
    "models/uniswap/optimism/uniswap_optimism_ovm1_pool_mapping.sql",
    "models/uniswap/optimism/uniswap_optimism_pools.sql",
    "models/uniswap/optimism/uniswap_optimism_trades.sql",
    "models/uniswap/polygon/uniswap_polygon_trades.sql",
    "models/uniswap/uniswap_trades.sql",
    "models/uniswap/ethereum/uniswap_v1_ethereum_trades.sql",
    "models/uniswap/ethereum/uniswap_v2_ethereum_trades.sql",
    "models/uniswap/arbitrum/uniswap_v3_arbitrum_trades.sql",
    "models/uniswap/ethereum/uniswap_v3_ethereum_trades.sql",
    "models/uniswap/optimism/uniswap_v3_optimism_trades.sql",
    "models/uniswap/polygon/uniswap_v3_polygon_trades.sql"
]

compiled_base_path = "/Users/couralex/src/spellbook/target/compiled/spellbook/"

# translate_list(compiled_base_path, queries)
# translate_list_to_file(compiled_base_path, queries)

print(translate_one_spell(base_path, query_to_test))


# translate_list_to_file(compiled_base_path, full_list)
