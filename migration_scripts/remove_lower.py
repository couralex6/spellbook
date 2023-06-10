# find all .sql files in the models directory and remove the lower() function around ethereum addresses

import os
import re

def main():
    for root, dirs, files in os.walk('models'):
        for file in files:
            if file.endswith('.sql'):
                with open(os.path.join(root, file), 'r') as f:
                    text = f.read()
                    text = remove_lower(text)
                with open(os.path.join(root, file), 'w') as f:
                    f.write(text)


def remove_lower(text):
    return re.sub(r"lower\((0x[a-fA-F0-9]{40})\)", r"\1", text)

test_string = """
WITH dodo_view_markets (market_contract_address, base_token_symbol, quote_token_symbol, base_token_address, quote_token_address) AS 
(
    VALUES
    (lower(0xFE176A2b1e1F67250d2903B8d25f56C0DaBcd6b2), 'WETH', 'USDC', lower(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1), lower(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8)),
    (lower(0xe4B2Dfc82977dd2DCE7E8d37895a6A8F50CbB4fB), 'USDT', 'USDC', lower(0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9), lower(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8)),
    (lower(0xb42a054D950daFD872808B3c839Fbb7AFb86E14C), 'WBTC', 'USDC', lower(0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f), lower(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8))
)
"""



if __name__ == '__main__':
    # print(remove_lower(test_string))
    main()