# Hyperdrive Infrastructure

All of the infrastructure related to Hyperdrive is held within a single docker
compose app.

## Running the Hyperdrive Testnet

To run the Hyperdrive testnet as a daemon, run the following command:

```
docker compose up -d
```

This will spin up several services:
- ethereum: Runs an Ethereum node.
- migrations: Migrates the Hyperdrive contracts onto the Ethereum node.
- artifacts: A file server that serves up artifacts about the Hyperdrive deployment.
