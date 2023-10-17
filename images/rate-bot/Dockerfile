FROM ghcr.io/foundry-rs/foundry:master
WORKDIR /src

COPY ./rate_daddy.sh ./rate_daddy.sh
COPY ./entry.sh ./entry.sh

ENV ETH_FROM=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
ENV PRIVATE_KEY=ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
ENV RPC_URL=http://ethereum:8545
ENV WAIT_TIME=10

RUN apk add --no-cache jq curl bc sed
RUN chmod +x ./rate_daddy.sh ./entry.sh

ENTRYPOINT ["./entry.sh"]
