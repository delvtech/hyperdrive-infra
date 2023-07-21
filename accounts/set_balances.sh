#!/bin/sh

set -ex

# Load list of accounts to fund
# accounts_and_balances=$(curl -s ${BALANCES_URL} | jq -r 'to_entries|map("\(.key) \(.value)")|.[]')
accounts_and_balances=$(jq -r 'to_entries|map("\(.key) \(.value)")|.[]' /accounts/balances.json)

echo "$accounts_and_balances" | while read account balance; do
  # Convert balance to wei as a hex string
  balance_hex="0x$(echo "obase=16; scale=0; $balance * 10^18 / 1" | bc)"

  # Create a JSON payload for the anvil_setBalance RPC method
  data='{"jsonrpc":"2.0","method":"anvil_setBalance","params":["'$account'", "'$balance_hex'"],"id":1}'

  # # Send the RPC request to the node
  curl -X POST --header "Content-Type: application/json" --data "$data" ${RPC_URL}
done
