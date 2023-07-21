FROM ghcr.io/foundry-rs/foundry:master

WORKDIR /src

COPY ./fund_accounts.sh ./fund_accounts.sh

ENV ETH_FROM=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
ENV PRIVATE_KEY=ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
ENV RPC_URL=http://ethereum:8545

RUN apk add --no-cache jq curl
RUN chmod +x ./fund_accounts.sh

ENTRYPOINT ["./fund_accounts.sh"]