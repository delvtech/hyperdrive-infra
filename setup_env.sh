#!/bin/bash

# This script uses flags to create a `.env` file for docker compose
# each optional argument adds a new component to the `.env` file

# Check if no arguments or --help is passed
if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]]; then
    echo "Usage: ./script_name.sh [flags]"
    echo "Flags:"
    echo "  --all      : Enable all components"
    echo "  --develop  : Enable development components"
    echo "  --devnet   : Enable devnet component"
    echo "  --bots     : Enable bots component"
    echo "  --frontend : Enable frontend component"
    echo "  --ports    : Enable ports component"
    exit 0
fi

# Parse all of the arguments
## Initialize variables
DEVNET=false
BOTS=false
PORTS=false
FRONTEND=false

## Loop through the arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            DEVNET=true
            BOTS=true
            FRONTEND=true
            PORTS=true
            ;;
        --develop)
            DEVNET=true
            PORTS=true
            ;;
        --devnet)
            DEVNET=true
            ;;
        --bots)
            BOTS=true
            ;;
        --botserver)
            BOTSERVER=true
            ;;
        --frontend)
            FRONTEND=true
            ;;
        --ports)
            PORTS=true
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
echo "# Environment for Docker compose" >> .env

# Set up the COMPOSE_FILE environment variable. To ensure that we don't
# experience issues with missing "image" or "build" fields, we always include
# all of the services in the compose context. We determine which layers are
# turned on using docker compose profiles.
devnet_compose="docker-compose.devnet.yaml"
bot_compose="docker-compose.bots.yaml"
botserver_compose="docker-compose.bot-server.yaml"
frontend_compose="docker-compose.frontend.yaml"
ports_compose="docker-compose.ports.yaml"
full_compose_files="COMPOSE_FILE=$devnet_compose:$bot_compose:$botserver_compose:$frontend_compose:"
if $PORTS; then
    full_compose_files+="$ports_compose:"
fi

# Check if ":" is at the end of the string
if [[ $full_compose_files == *":" ]]; then
    # Remove ":" from the end of the string
    full_compose_files=${full_compose_files%:}
fi

# Append the COMPOSE_FILE environment variable to the .env file
echo $full_compose_files >> .env

# Set up the COMPOSE_PROFILES environment variable. This toggles which layers
# should be started.
frontend_profile="frontend"
full_compose_profiles="COMPOSE_PROFILES="
if $FRONTEND; then
    full_compose_profiles+="$frontend_profile,"
fi
if $BOTS; then
    full_compose_profiles+="bots"
fi
if $BOTSERVER; then
    full_compose_profiles+="botserver"
fi
# Check if "," is at the end of the string
if [[ $full_compose_profiles == *"," ]]; then
    # Remove "," from the end of the string
    full_compose_profiles=${full_compose_profiles%,}
fi

# Append the COMPOSE_PROFILES environment variable to the .env file
echo $full_compose_profiles >> .env

# cat env.tags to the .env file
cat env/env.tags >> .env

# optionally cat env.ports to .env file if --ports
if $PORTS; then
    cat env/env.ports >> .env
fi

# optionally add an env.frontend to .env file if --frontend
if $FRONTEND; then
    cat env/env.frontend >> .env
fi

echo "Environment filed created at .env"
