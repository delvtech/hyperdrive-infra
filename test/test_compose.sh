dirname=$(basename $(pwd))

# Runs before exiting regardless of the reason (error or not).
trap 'echo "Taking down containers..."; docker compose down -v' EXIT

docker compose up -d

# The mine service should exit with a zero error code.
echo "Waiting for mine service to finish..."
MINE_ERROR=$(docker wait $dirname-mine-1)
if [ $MINE_ERROR -ne 0 ]; then
  echo "Mine service exited with an error:"
  docker logs $dirname-mine-1
  exit 1
fi

# The fund-accounts should exit with a zero error code.
echo "Waiting for fund-accounts service to finish..."
FUND_ACCOUNTS_ERROR=$(docker wait $dirname-fund-accounts-1)
echo "Fund accounts service exited with code $FUND_ACCOUNTS_ERROR"
if [ $FUND_ACCOUNTS_ERROR -ne 0 ]; then
  echo "Fund accounts service exited with an error:"
  docker logs $dirname-fund-accounts-1
  exit 1
fi

# The ethereum service should be running.
if [ -z "$(docker compose ps -q ethereum)" ]; then
  echo "Ethereum service exited unexpectedly:"
  docker logs $dirname-ethereum-1
  exit 1
fi

# The artifacts service should be running.
if [ -z "$(docker compose ps -q artifacts)" ]; then
  echo "Artifacts service exited unexpectedly:"
  docker logs $dirname-artifacts-1
  exit 1
fi

# The checkpoint-bot service should be running.
if [ -z "$(docker compose ps -q checkpoint-bot)" ]; then
  echo "Checkpoint bot service exited unexpectedly:"
  docker logs $dirname-checkpoint-bot-1
  exit 1
fi

# The rate-bot service should be running.
if [ -z "$(docker compose ps -q rate-bot)" ]; then
  echo "Rate bot service exited unexpectedly:"
  docker logs $dirname-rate-bot-1
  exit 1
fi

# The data service should be running.
if [ -z "$(docker compose ps -q data)" ]; then
  echo "Data service exited unexpectedly:"
  docker logs $dirname-data-1
  exit 1
fi

# The dashboard service should be running.
if [ -z "$(docker compose ps -q dashboard)" ]; then
  echo "Dashboard service exited unexpectedly:"
  docker logs $dirname-dashboard-1
  exit 1
fi

# The db service should be running.
if [ -z "$(docker compose ps -q db)" ]; then
  echo "DB service exited unexpectedly:"
  docker logs $dirname-db-1
  exit 1
fi

# The frontend service should be running.
if [ -z "$(docker compose ps -q frontend)" ]; then
  echo "Frontend service exited unexpectedly:"
  docker logs $dirname-frontend-1
  exit 1
fi

echo "Containers ran successfully!"
