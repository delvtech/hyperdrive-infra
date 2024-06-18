[![license: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-lightgrey)](http://www.apache.org/licenses/LICENSE-2.0)
[![DELV - Terms of Service](https://img.shields.io/badge/DELV-Terms_of_Service-orange)](https://delv-public.s3.us-east-2.amazonaws.com/delv-terms-of-service.pdf)

# [Hyperdrive](https://hyperdrive.delv.tech) Infrastructure

All of the infrastructure related to Hyperdrive is held within a single docker
compose app. The compose app is composed of several services:
- ethereum: Runs an Ethereum node.
- migrations: Migrates the Hyperdrive contracts onto the Ethereum node.
- artifacts: A file server that serves up artifacts about the Hyperdrive deployment.
- frontend: A full monorepo with a trading UI and supporting packages
- data: A service that gathers data from the chain and deploys a data dashboard.
- bots: Bot services for running auto trades on a chain.

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

- `--anvil` : Spin up an Anvil node, deploy Hyperdrive to it, and serve artifacts on an nginx server.
- `--blocktime` : Sets the anvil node to run in blocktime mode.
- `--testnet` : Uses the testnet hyperdrive image with restricted mint access.
- `--frontend` : Build the frontend container.
- `--postgres` : Launches a local postgres server for the data pipeline.
- `--data` : Runs the data framework, querying the chain and writing to postgres.
- `--service-bot` : Runs checkpoint bot and invariance check bots on the chain."
- `--random-bot` : Runs random bots on the chain.
- `--ports` : Expose docker images to your machine, as specified in `env/env.ports`.
- `--fund-accounts` : Fund accounts from `/accounts/balances.json`.
- `--rate-bot` : Yield source will have a dynamic variable rate.

We also support shortcuts for common combinations. The most inclusive tag used will take priority.

- `--all` : Fund accounts and enable all components: anvil, data, postgres, frontend, and ports.
- `--develop` : Fund accounts and enable anvil, data, and ports. Suitable for local development work.
- `--remote-service-bots`: Runs service bots on a remote chain. See [Service Bots](./service-bots.md) for more details.

You can also change the tags in `env/env.images` to modify which docker image you build from.

## Pulling the images

Run `docker compose pull`

## Running the app

`docker compose up` runs the chosen environment. Add the `-d` flag to detach and run in background.

See the status of the running containers with `docker ps` or real-time info with `docker stats`.

See live logs with `docker logs CONTAINER_NAME -f`.

## Tearing down the app

Run `docker compose down -v`. The `-v` ensures that storage volumes are deleted.


## Disclaimer

This project is a work-in-progress.
The language used in this code and documentation is not intended to, and does not, have any particular financial, legal, or regulatory significance.

---

Copyright © 2024  DELV

Licensed under the Apache License, Version 2.0 (the "OSS License").

By accessing or using this code, you signify that you have read, understand and agree to be bound by and to comply with the [OSS License](http://www.apache.org/licenses/LICENSE-2.0) and [DELV's Terms of Service](https://delv-public.s3.us-east-2.amazonaws.com/delv-terms-of-service.pdf). If you do not agree to those terms, you are prohibited from accessing or using this code.

Unless required by applicable law or agreed to in writing, software distributed under the OSS License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the OSS License and the DELV Terms of Service for the specific language governing permissions and limitations.
