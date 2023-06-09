# Hyperdrive Infrastructure

All of the infrastructure related to Hyperdrive is held within a single docker
compose app. The compose app is composed of several services:
- ethereum: Runs an Ethereum node.
- migrations: Migrates the Hyperdrive contracts onto the Ethereum node.
- artifacts: A file server that serves up artifacts about the Hyperdrive deployment.
- hyperdrive-monorepo: A full monorepo with a trading UI and supporting packages

## Setup

[Install docker](https://docs.docker.com/engine/install/) on the
machine that will be used to run the compose app.

Install docker compose in case you don't have it. Steps differ based on OS.
For MacOS, install the desktop image, then go through the startup steps.
On Linux, you may have `docker-compose` already, which you can substitute in.

The docker compose app makes use of several images that are hosted on a private Github package. To access
these images, you will need to [create a Github personal access token (classic)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-personal-access-token-classic).
The only permissions you need are assigned once you enable `read:packages`.
Once you have your personal access token, you will use it to login to the Github registry:

```
$ docker login ghcr.io -u USERNAME
Password:
```

Paste your personal access token in the `Password:` field that pops up.

## Setting up environment

We use an environment file, `.env`, to choose which containers to build together.
To select an environment, run `sh setup_env.sh` with one or more of the following flags:

`--devnet` : Build the devnet container.

`--bots` : Build the bot container.

`--frontend` : Build the frontend container.

`--ports` : Open up local ports in services the devnet container, as specified in `env/env.ports`.

We also support shortcuts for common combinations. Only one of these should be used at a time:

`--all` : Enable devnet, ports, bots, frontend

`--develop` : Enable devnet, ports

You can also change the tags in `env/env.tags` to modify which docker image you build from.

## Pulling the images

Run `docker compose pull`

## Running the app

Run `docker compose up -d` to run the compose app as a daemon process (in the background).

See the status of the running containers with `docker ps`.
Tail logs with `docker logs CONTAINER_NAME -f`.

## Tearing down the app

Run `docker compose down -v`. The `-v` ensures that the volumes that were
created are deleted.
