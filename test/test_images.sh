# The devnet image that the infra images are being developed for
export DEVNET_IMAGE=ghcr.io/delvtech/hyperdrive/devnet:0.0.11

echo "Testing images with devnet image $DEVNET_IMAGE"

timestamp=$(date +%s)

export ARTIFACTS_IMAGE="test/artifacts:$timestamp"
export FUND_ACCOUNTS_IMAGE="test/fund-accounts:$timestamp"

echo "Building images..."
docker build images/artifacts -t "$ARTIFACTS_IMAGE"
docker build images/fund-accounts -t "$FUND_ACCOUNTS_IMAGE"

sh test/test_compose.sh

echo "Removing images..."
docker image rm "$ARTIFACTS_IMAGE"
docker image rm "$FUND_ACCOUNTS_IMAGE"
