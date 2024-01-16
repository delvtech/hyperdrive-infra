FROM node:lts

WORKDIR ./src

COPY ./package.json ./package.json
COPY ./index.js ./index.js
COPY ./yarn.lock ./yarn.lock

RUN chmod -R a+w ./

RUN yarn
ENTRYPOINT yarn start