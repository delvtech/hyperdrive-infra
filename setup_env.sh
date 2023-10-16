#!/bin/bash

# This script uses flags to create a `.env` file for docker compose
# each optional argument adds a new component to the `.env` file

# Check if no arguments or --help is passed
if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]]; then
    echo "Usage: ./setup_env.sh [flags]"
    echo "Flags:"
    echo "  --anvil          : Spin up an Anvil node, deploy Hyperdrive to it, and serve artifacts on an nginx server."
    echo "  --data           : Runs the data framework, querying the chain and writing to postgres."
    echo "  --frontend       : Build the frontend container."
    echo "  --ports          : Expose docker images to your machine, as specified in env/env.ports."
    echo "  --fund-accounts  : Fund accounts from /accounts/balances.json."
    echo "  --all            : Fund accounts and enable all components: anvil, bots, frontend, and ports."
    echo "  --competition    : Fund accounts and enable anvil, bots and ports. Use this for a trading competition deployment."
    echo "  --develop        : Fund accounts and enable anvil, bots and ports. Suitable for local development work."
    echo "  --dynamic-rate   : Yield source will have a dynamic variable rate."
    exit 0
fi

# Parse all of the arguments
## Initialize variables
ANVIL=false
PORTS=false
FRONTEND=false
POSTGRES=false
DATA=false
FUND_ACCOUNTS=false
COMPETITION=false
DYNAMIC_RATE=false

## Loop through the arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            ANVIL=true
            FRONTEND=true
            POSTGRES=true
            PORTS=true
            DATA=true
            FUND_ACCOUNTS=true
            DYNAMIC_RATE=true
            ;;
        --competition)
            ANVIL=true
            PORTS=true
            DATA=true
            FUND_ACCOUNTS=true
            COMPETITION=true
            DYNAMIC_RATE=true
            ;;
        --develop)
            ANVIL=true
            POSTGRES=true
            PORTS=true
            DATA=true
            FUND_ACCOUNTS=true
            ;;
        --anvil)
            ANVIL=true
            ;;
        --data)
            DATA=true
            ;;
        --dynamic-rate)
            DYNAMIC_RATE=true
            ;;
        --postgres)
            POSTGRES=true
            ;;
        --frontend)
            FRONTEND=true
            ;;
        --ports)
            PORTS=true
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
data_compose="docker-compose.data.yaml"
rate_bot_compose="docker-compose.rate-bot.yaml"
frontend_compose="docker-compose.frontend.yaml"
postgres_compose="docker-compose.postgres.yaml"
testnet_compose="docker-compose.testnet.yaml"
ports_compose="docker-compose.ports.yaml"
full_compose_files="COMPOSE_FILE=$anvil_compose:$data_compose:$frontend_compose:$postgres_compose:$rate_bot_compose:"
if $COMPETITION; then
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
frontend_profile="frontend"
postgres_profile="postgres"
data_profile="data"
fund_accounts_profile="fund-accounts"
competition_profile="competition"
dynamic_rate_profile="dynamic-rate"
full_compose_profiles="COMPOSE_PROFILES="
if $FRONTEND; then
    full_compose_profiles+="$frontend_profile,"
fi
if $POSTGRES; then
    full_compose_profiles+="$postgres_profile,"
fi
if $DATA; then
    full_compose_profiles+="$data_profile,"
fi
if $FUND_ACCOUNTS; then
    full_compose_profiles+="$fund_accounts_profile,"
fi
if $COMPETITION; then
    full_compose_profiles+="$competition_profile,"
fi
if $DYNAMIC_RATE; then
    full_compose_profiles+="$dynamic_rate_profile,"
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

# optionally add an env.frontend to .env file if --frontend
if $FRONTEND; then
    echo "" >>.env
    cat env/env.frontend >>.env
fi

# optionally add an env.frontend to .env file if --postgres or --data
# POSTGRES uses these flags to launch postgres, DATA uses these flags to connect
if $POSTGRES || $DATA; then
    echo "" >>.env
    cat env/env.postgres >> .env
fi

# optionally add an env.time to .env file if --competition
if $COMPETITION; then
    echo "" >>.env
    cat env/env.time >>.env
fi

echo "Environment filed created at .env"
