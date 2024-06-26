####################################################################################################
# install stage
####################################################################################################

FROM node:20-bullseye-slim as develop-stage

WORKDIR /app

USER root

RUN apt-get update && apt-get -y install dumb-init

RUN npm install -g pnpm && chown -R node:node /app

USER node

COPY package.json pnpm-lock.yaml docker_stats_exporter.js /app/

RUN pnpm install --frozen-lockfile --ignore-scripts

####################################################################################################
# production stage
####################################################################################################

FROM node:20-bullseye-slim as production

WORKDIR /app

COPY --from=develop-stage /app/ /app
COPY --from=develop-stage /usr/bin/dumb-init /usr/bin/dumb-init

EXPOSE 9487

ENV DOCKERSTATS_PORT=9487 DOCKERSTATS_INTERVAL=15 DEBUG=0

ENTRYPOINT [ "/usr/bin/dumb-init", "--" ]

CMD [ "npm", "start" ]
