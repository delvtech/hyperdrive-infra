# Service Bots
Infra can be used to run service bots on a remote chain (e.g., Sepolia testnet).

- Setup infra as documented in the [README](README.md#setup).
- Run `./setup_env.sh --remote-service-bots`
- Edit the generated `.env` file and replace the following fields:
  - `RPC_URI`: The URI to the RPC for connecting to the chain.
  - `REGISTRY_ADDRESS`: The contract address of the hyperdrive registry.
  - `CHECKPOINT_BOT_KEY`: The private key of the account that's making checkpoints.
  - `ROLLBAR_API_KEY`: The API key for Rollbar for logging.
- Run `docker compose up -d` to bring up bots.

The above will run (1) checkpoint bots and (2) invariance check bots on all registered pools.
