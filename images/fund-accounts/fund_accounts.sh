#!/bin/sh

# Wait until the Ethereum node is ready
while true; do
  if curl -s -X POST --header "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}' ${RPC_URL} | grep -q "result"; then
    break
  fi
  echo "Waiting for Ethereum node to be ready..."
  sleep 1
done

echo "--------------------------------"
echo "        FUNDING ACCOUNTS        "
echo "--------------------------------"

# Load list of accounts to fund from /accounts/balances.json
accounts_and_balances=$(jq -r 'to_entries|map("\(.key) \(.value.eth) \(.value.tokens)")|.[]' /accounts/balances.json)

# Get the base token address from /artifact/addresses.json
base_token=$(jq -r '.baseToken' /artifacts/addresses.json)

# Set the balance for each account
while read -r account eth_balance token_balance; do
  # Convert balances to wei as a hex string
  eth_balance_hex="0x$(echo "obase=16; scale=0; $eth_balance * 10^18 / 1" | bc)"
  token_balance_hex="0x$(echo "obase=16; scale=0; $token_balance * 10^18 / 1" | bc)"

  # Create a JSON payload for the anvil_setBalance RPC method
  data='{"jsonrpc":"2.0","method":"anvil_setBalance","params":["'$account'", "'$eth_balance_hex'"],"id":1}'

  # Send the RPC request to the node
  curl -X POST --header "Content-Type: application/json" --data "$data" ${RPC_URL}

  # Mint base tokens
  cast send "$base_token" "mint(address,uint256)" "$account" "$token_balance_hex" --rpc-url ${RPC_URL} --private-key ${PRIVATE_KEY} --gas-limit 500000
  if [ $? -ne 0 ]; then
    exit 1
  fi
done <<EOF
$accounts_and_balances
EOF

echo "--------------------------------"
echo " ACCOUNTS FUNDED SUCCESSFULLY!! "
echo "--------------------------------"
