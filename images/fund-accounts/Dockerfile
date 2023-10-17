FROM ghcr.io/foundry-rs/foundry:master

WORKDIR /src

COPY ./fund_accounts.sh ./fund_accounts.sh

ENV ETH_FROM=0x6043bF4ec8834F918242BaCA0F1F3805F2a2988D
ENV PRIVATE_KEY=0f1616bb59774b929ba5256c2204123d9dedc4c142d013179b90f929997d119b
ENV RPC_URL=http://ethereum:8545

RUN apk add --no-cache jq curl
RUN chmod +x ./fund_accounts.sh

ENTRYPOINT ["./fund_accounts.sh"]