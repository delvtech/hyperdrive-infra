#!/bin/bash

# This script uses flags to create a `.env` file for docker compose
# each optional argument adds a new component to the `.env` file

# Check if no arguments or --help is passed
if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]]; then
    echo "Usage: ./setup_env.sh [flags]"
    echo "Flag Groups:"
    echo "  --all            : Fund accounts and enable all components: anvil, data, postgres, frontend, and ports."
    echo "  --develop        : Fund accounts and enable anvil, data, and ports. Suitable for local development work."
    echo "Flags:"
    echo "  --anvil          : Spin up an Anvil node, deploy Hyperdrive to it, and serve artifacts on an nginx server."
    echo "  --blocktime      : Sets the anvil node to run in blocktime mode."
    echo "  --testnet        : Uses the testnet hyperdrive image with restricted mint access."
    echo "  --frontend       : Build the frontend container."
    echo "  --postgres       : Runs a postgres db container for storing data."
    echo "  --data           : Runs the data framework, querying the chain and writing to postgres."
    echo "  --service-bots   : Runs checkpoint bot and invariance check bots on the chain."
    echo "  --random-bots    : Runs random bots on the chain."
    echo "  --ports          : Expose docker images to your machine, as specified in env/env.ports."
    echo "  --fund-accounts  : Fund accounts from /accounts/balances.json."
    echo "  --rate-bot       : Yield source will have a dynamic variable rate."
    exit 0
fi

# Parse all of the arguments
## Initialize variables
ANVIL=false
BLOCKTIME=false
TESTNET=false
FRONTEND=false
POSTGRES=false
DATA=false
PORTS=false
SERVICE_BOTS=false
RANDOM_BOTS=false
RATE_BOT=false
FUND_ACCOUNTS=false

## Loop through the arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        # Flag groups
        --all)
            ANVIL=true
            # Don't run blocktime here, we want chain to be in fast mode
            # Don't run testnet image here since random bots need to be able to mint
            FRONTEND=true
            POSTGRES=true
            DATA=true
            PORTS=true
            SERVICE_BOTS=true
            RANDOM_BOTS=true
            RATE_BOT=true
            FUND_ACCOUNTS=true
            ;;
        --develop)
            ANVIL=true
            POSTGRES=true
            DATA=true
            PORTS=true
            FUND_ACCOUNTS=true
            ;;
        # Flags
        --anvil)
            ANVIL=true
            ;;
        --blocktime)
            BLOCKTIME=true
            ;;
        --testnet)
            TESTNET=true
            ;;
        --frontend)
            FRONTEND=true
            ;;
        --data)
            DATA=true
            ;;
        --postgres)
            POSTGRES=true
            ;;
        --ports)
            PORTS=true
            ;;
        --service-bots)
            SERVICE_BOTS=true
            ;;
        --rate-bot)
            RATE_BOT=true
            ;;
        --fund-accounts)
            FUND_ACCOUNTS=true
            ;;
        *)
            echo "Unknown flag: $1"
            ;;
    esac
    shift
done

# Make a new .env file
rm -f .env
touch .env
echo "# Environment for Docker compose" >>.env

# Set up the COMPOSE_FILE environment variable. To ensure that we don't
# experience issues with missing "image" or "build" fields, we always include
# all of the services in the compose context. We determine which layers are
# turned on using docker compose profiles.
anvil_compose="docker-compose.anvil.yaml"
blocktime_compose="docker-compose.blocktime.yaml"
testnet_compose="docker-compose.testnet.yaml"
frontend_compose="docker-compose.frontend.yaml"
postgres_compose="docker-compose.postgres.yaml"
data_compose="docker-compose.data.yaml"
service_bots_compose="docker-compose.agent0-bots.yaml"
ports_compose="docker-compose.ports.yaml"

# We default to using profiles to control which services are turned on.
full_compose_files="COMPOSE_FILE=$anvil_compose:$frontend_compose:$postgres_compose:$data_compose:$service_bots_compose:"
# We only add controls here if these compose files update existing services.
if $BLOCKTIME; then
    full_compose_files+="$blocktime_compose:"
fi
if $TESTNET; then
    full_compose_files+="$testnet_compose:"
fi
if $PORTS; then
    full_compose_files+="$ports_compose:"
fi

# Check if ":" is at the end of the string
if [[ $full_compose_files == *":" ]]; then
    # Remove ":" from the end of the string
    full_compose_files=${full_compose_files%:}
fi

# Append the COMPOSE_FILE environment variable to the .env file
echo $full_compose_files >>.env

# Set up the COMPOSE_PROFILES environment variable. This toggles which layers
# should be started.
blocktime_profile="blocktime"
frontend_profile="frontend"
postgres_profile="postgres"
data_profile="data"
service_bots_profile="service-bots"
random_bots_profile="random-bots"
rate_bot_profile="rate-bot"
fund_accounts_profile="fund-accounts"
full_compose_profiles="COMPOSE_PROFILES="
if $BLOCKTIME; then
    full_compose_profiles+="$blocktime_profile,"
fi
if $FRONTEND; then
    full_compose_profiles+="$frontend_profile,"
fi
if $POSTGRES; then
    full_compose_profiles+="$postgres_profile,"
fi
if $DATA; then
    full_compose_profiles+="$data_profile,"
fi
if $SERVICE_BOTS; then
    full_compose_profiles+="$service_bots_profile,"
fi
if $RANDOM_BOTS; then
    full_compose_profiles+="$random_bots_profile,"
fi
if $RATE_BOT; then
    full_compose_profiles+="$rate_bot_profile,"
fi
if $FUND_ACCOUNTS; then
    full_compose_profiles+="$fund_accounts_profile,"
fi
# Check if "," is at the end of the string
if [[ $full_compose_profiles == *"," ]]; then
    # Remove "," from the end of the string
    full_compose_profiles=${full_compose_profiles%,}
fi

# Append the COMPOSE_PROFILES environment variable to the .env file
echo $full_compose_profiles >>.env

# cat env.common and env.ports to the .env file
echo "" >>.env
cat env/env.common >> .env
echo "" >>.env
cat env/env.ports >>.env

# cat env.images to the .env file. We have to manage conflicts between different
# anvil images here, so we do it manually.
echo "" >>.env
cat env/env.images >>.env
source env/env.images

# optionally cat env.anvil to .env file if --anvil
if $ANVIL; then
    echo "" >>.env
    cat env/env.anvil >>.env
fi

# optionally add an env.time to .env file if --blocktime
if $BLOCKTIME; then
    echo "" >>.env
    cat env/env.time >>.env
fi

# optionally add an env.frontend to .env file if --frontend
if $FRONTEND; then
    echo "" >>.env
    cat env/env.frontend >>.env
fi

# optionally add an env.frontend to .env file if --postgres or --data
# POSTGRES uses these flags to launch postgres. 
# All agent0 images uses these flags to connect
if $POSTGRES || $DATA || $SERVICE_BOTS || $RANDOM_BOTS || $RATE_BOT; then
    echo "" >>.env
    cat env/env.postgres >> .env
fi

echo "Environment filed created at .env"
