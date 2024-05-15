#!/bin/sh
set -x

# Wait until the Ethereum node is ready
while true; do
  if curl -s -X POST --header "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}' ${RPC_URL} | grep -q "result"; then
    break
  fi
  echo "Waiting for Ethereum node to be ready..."
  sleep 2
done

SCRIPT_DIR="$(dirname $0)"

watch -n ${WAIT_TIME} ${SCRIPT_DIR}/rate_daddy.sh
