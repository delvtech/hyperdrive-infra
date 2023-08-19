dirname=$(basename $(pwd))

docker compose up -d

# The mine service should exit with a zero error code.
echo "Waiting for mine service to finish..."
MINE_ERROR=$(docker wait $dirname-mine-1)
if [ $MINE_ERROR -ne 0 ]; then
  echo "Mine service exited with an error"
  exit 1
fi

# The fund-accounts should exit with a zero error code.
echo "Waiting for fund-accounts service to finish..."
FUND_ACCOUNTS_ERROR=$(docker wait $dirname-fund-accounts-1)
if [ $FUND_ACCOUNTS_ERROR -ne 0 ]; then
  echo "Fund accounts service exited with an error"
  exit 1
fi

# The ethereum service should be running.
if [ -z "$(docker compose ps -q ethereum)" ]; then
  echo "Ethereum service exited unexpectedly"
  exit 1
fi

# The artifacts service should be running.
if [ -z "$(docker compose ps -q artifacts)" ]; then
  echo "Artifacts service exited unexpectedly"
  exit 1
fi

# The checkpoint-bot service should be running.
if [ -z "$(docker compose ps -q checkpoint-bot)" ]; then
  echo "Checkpoint bot service exited unexpectedly"
  exit 1
fi

# The data service should be running.
if [ -z "$(docker compose ps -q data)" ]; then
  echo "Data service exited unexpectedly"
  exit 1
fi

# The username reg service should be running.
if [ -z "$(docker compose ps -q username-reg)" ]; then
  echo "Username reg service exited unexpectedly"
  exit 1
fi

# The dashboard service should be running.
if [ -z "$(docker compose ps -q dashboard)" ]; then
  echo "Dashboard service exited unexpectedly"
  exit 1
fi

# The db service should be running.
if [ -z "$(docker compose ps -q db)" ]; then
  echo "DB service exited unexpectedly"
  exit 1
fi

# The hyperdrive-monorepo service should be running.
if [ -z "$(docker compose ps -q hyperdrive-monorepo)" ]; then
  echo "Hyperdrive monorepo service exited unexpectedly"
  exit 1
fi

echo "Taking down containers..."
docker compose down -v

echo "Containers ran successfully!"
