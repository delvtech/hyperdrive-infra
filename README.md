# Hyperdrive Infrastructure

All of the infrastructure related to Hyperdrive is held within a single docker
compose app. The compose app is composed of several services:
- ethereum: Runs an Ethereum node.
- migrations: Migrates the Hyperdrive contracts onto the Ethereum node.
- artifacts: A file server that serves up artifacts about the Hyperdrive deployment.
- hyperdrive-monorepo: A full monorepo with a trading UI and supporting packages

## Setup

[Install docker](https://docs.docker.com/engine/install/) on the machine that
will be used to run the compose app. Install the desktop app for most compatibility.

The docker compose app makes use of several images that are hosted on a private Github package. To access
these images, you will need to [create a Github personal access token (classic)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-personal-access-token-classic).

> If you're using linux and [Docker Desktop](https://docs.docker.com/desktop/)
> (which is [recommended for maximum compatibility](https://docs.docker.com/desktop/faqs/linuxfaqs/#why-does-docker-desktop-for-linux-run-a-vm))
> [configure](https://docs.docker.com/desktop/get-started/#credentials-management-for-linux-users) your [`pass`](https://wiki.archlinux.org/title/Pass)-based credential store
> (if you want a GPG key without a password, run `gpg --batch --passphrase '' --quick-gen-key your@email.com default default`).

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

- `--devnet` : Spin up an Anvil node, deploy Hyperdrive to it, and serve artifacts on an nginx server.
- `--data` : Runs the data framework, querying the chain and writing to postgres.
- `--frontend` : Build the frontend container.
- `--ports` : Expose docker images to your machine, as specified in `env/env.ports`.
- `--fund-accounts` : Fund accounts from `/accounts/balances.json`.

We also support shortcuts for common combinations. The most inclusive tag used will take priority.

- `--all` : Fund accounts and enable all components: devnet, bots, frontend, and ports.
- `--develop` : Fund accounts and enable devnet, bots and ports. Suitable for local development work.
- `--ec2` : Fund accounts and enable devnet, data, and ports. Need configuration to external postgres.

You can also change the tags in `env/env.tags` to modify which docker image you build from.

## Pulling the images

Run `docker compose pull`

## Running the app

`docker compose up` runs the chosen environment. Add the `-d` flag to detach and run in background.

See the status of the running containers with `docker ps` or real-time info with `docker stats`.

See live logs with `docker logs CONTAINER_NAME -f`.

## Tearing down the app

Run `docker compose down -v`. The `-v` ensures that storage volumes are deleted.