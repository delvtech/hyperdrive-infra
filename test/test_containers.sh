# The hyperdrive image that the infra containers are being developed for
export HYPERDRIVE_IMAGE=ghcr.io/delvtech/hyperdrive/devnet:0.0.11

echo "Testing containers with Hyperdrive image $HYPERDRIVE_IMAGE"

dir_path=$(dirname $(realpath $0))
timestamp=$(date +%s)

export ARTIFACTS_IMAGE="test/artifacts:$timestamp"
export FUND_ACCOUNTS_IMAGE="test/fund-accounts:$timestamp"

echo "Building containers..."
docker build containers/artifacts -t "$ARTIFACTS_IMAGE"
docker build containers/fund-accounts -t "$FUND_ACCOUNTS_IMAGE"

sh test/test_compose.sh

echo "Removing containers..."
docker image rm "$ARTIFACTS_IMAGE"
docker image rm "$FUND_ACCOUNTS_IMAGE"
