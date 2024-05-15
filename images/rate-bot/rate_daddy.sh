#!/bin/sh
set -x

# Get the base token address from /artifact/addresses.json
# CONTRACT_ADDRESS=$(jq -r '.mockHyperdrive' /artifacts/addresses.json)

# VAULT_ADDRESS=$(cast call ${CONTRACT_ADDRESS} "vaultSharesToken()(address)" --rpc-url ${RPC_URL})
NEW_RATE=$(echo "scale=16; 3+$(od -t u2 -An -N2 /dev/random)/(2 ^ 16)"| bc |sed 's/\.//g')
cast send --from ${ETH_FROM} --private-key ${PRIVATE_KEY} ${VAULT_ADDRESS} "setRate(uint256)" $NEW_RATE --rpc-url ${RPC_URL} --priority-gas-price 1000000
