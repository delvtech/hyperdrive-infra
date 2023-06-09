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

# Fill the .env file with the ENV variables in order
devnet_compose="docker-compose.devnet.yaml"
bot_compose="docker-compose.bots.yaml"
frontend_compose="docker-compose.frontend.yaml"
ports_compose="docker-compose.ports.yaml"

full_compose="COMPOSE_FILE="
if $DEVNET; then
    full_compose+="$devnet_compose:"
fi
if $BOTS; then
    full_compose+="$bot_compose:"
fi
if $frontend; then
    full_compose+="$frontend_compose:"
fi
if $PORTS; then
    full_compose+="$ports_compose:"
fi
# Check if ":" is at the end of the string
if [[ $full_compose == *":" ]]; then
    # Remove ":" from the end of the string
    full_compose=${full_compose%:}
fi

echo $full_compose >> .env

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