FROM ghcr.io/foundry-rs/foundry:master
WORKDIR /src

COPY ./rate_daddy.sh ./rate_daddy.sh

ENV ETH_FROM=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
ENV PRIVATE_KEY=ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
ENV CONTRACT_ADDRESS=http://ethereum:8545
ENV RPC_URL=http://ethereum:8545

RUN apk add --no-cache jq curl
RUN chmod +x ./rate_daddy.sh
ENTRYPOINT ["watch", "-n", "5", "./rate_daddy.sh"]


#RUN chmod 0644 /etc/cron.d/crontab
#RUN crontab /etc/cron.d/crontab
#RUN touch /var/log/cron.log

#CMD cron && tail -f /var/log/cron.log
