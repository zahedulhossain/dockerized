FROM docker.io/zahedulhossain/laravel:10.2.4 as base-php

FROM node:18.16.1-slim

LABEL maintainer="Zahedul Hossain <md.zahedulhossain@gmail.com>"

# Setup docker arguments.
ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""
ARG NO_PROXY="localhost,127.0.0.1"
ARG TIMEZONE="Asia/Dhaka"

# Setup some enviornment variables.
ENV http_proxy="${HTTP_PROXY}" \
    https_proxy="${HTTPS_PROXY}" \
    no_proxy="${NO_PROXY}" \
    TZ="${TIMEZONE}"

USER root

ARG UID="1000"
ARG GID="1000"

RUN userdel -r node \
    && groupadd --gid ${GID} app \
    && useradd --uid ${UID} --create-home --system --comment "App User" --shell /bin/bash --gid app app \
    && mkdir -p /var/www/html \
    && chown -R app:app /var/www/html

WORKDIR /var/www/html

COPY --chown=app:app ./src/package*.json ./

USER app

RUN echo "-- Set NPM Proxy --" \
        && if [ ! -z "${HTTP_PROXY}" ]; then \
          npm config set proxy "${HTTP_PROXY}" \
        ;fi \
        && if [ ! -z "${HTTPS_PROXY}" ]; then \
            npm config set https-proxy "${HTTPS_PROXY}" \
        ;fi \
        && if [ ! -z "${NO_PROXY}" ]; then \
            npm config set noproxy "${NO_PROXY}" \
        ;fi \
    && echo "-- Install Local NPM Packages --" \
        && npm i --ignore-scripts --no-audit \
    && echo "-- Remove Proxy --" \
        && npm config rm proxy \
        && npm config rm https-proxy \
        && npm config rm noproxy

COPY --chown=app:app ./src/bootstrap ./bootstrap
COPY --chown=app:app ./src/resources ./resources
COPY --chown=app:app ./src/public ./public
#COPY --chown=app:app ./src/jsconfig.json ./
COPY --chown=app:app ./src/vite.config.js ./
#COPY --chown=app:app --from=base-php /var/www/html/vendor/tightenco ./vendor/tightenco

USER root

ARG SHOULD_CHOWN_TO_APP="true"

RUN if [ "${SHOULD_CHOWN_TO_APP}" = "true" ]; then \
        chown -R app:app . \
    ;fi

USER app

RUN npm run build

STOPSIGNAL SIGTERM

# Unset Proxy ENVs
ENV http_proxy="" \
    https_proxy="" \
    no_proxy="" \
    TZ=""

CMD [ "npm", "run", "dev" ]
