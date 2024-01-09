FROM node:lts

WORKDIR ./src

COPY ./package.json ./package.json
COPY ./index.js ./index.js
COPY ./yarn.lock ./yarn.lock

# ENV PRIVATE_KEY=0x0f1616bb59774b929ba5256c2204123d9dedc4c142d013179b90f929997d119b
ENV PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
ENV RPC_URL=http://ethereum:8545
ENV CHAIN_ID=42069

RUN chmod -R a+w ./

RUN yarn
ENTRYPOINT yarn start