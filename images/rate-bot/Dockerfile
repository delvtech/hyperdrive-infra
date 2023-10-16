FROM ghcr.io/foundry-rs/foundry:master
WORKDIR /src

COPY ./rate_daddy.sh ./rate_daddy.sh

ENV ETH_FROM=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
ENV PRIVATE_KEY=ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
ENV CONTRACT_ADDRESS=0xd8058efe0198ae9dD7D563e1b4938Dcbc86A1F81
ENV RPC_URL=http://ethereum:8545
ENV WAIT_TIME=5
RUN apk add --no-cache jq curl bc sed
RUN chmod +x ./rate_daddy.sh

ENTRYPOINT ["watch", "-n", "1800", "./rate_daddy.sh"]


