ARG NODE_IMAGE_NAME
ARG NODE_IMAGE_TAG

FROM ${NODE_IMAGE_NAME}:${NODE_IMAGE_TAG} AS node-image

FROM docker.io/zahedulhossain/laravel:12.1.1

LABEL maintainer="Zahedul Hossain <zahedul.hossain@grameenphone.com>"

ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""
ARG NO_PROXY="localhost,127.0.0.1"
ARG TIMEZONE="Asia/Dhaka"
ARG EXTRA_INSTALL_APT_PACKAGES=""
ARG EXTRA_INSTALL_PHP_EXTENSIONS=""

ENV http_proxy="${HTTP_PROXY}" \
    https_proxy="${HTTPS_PROXY}" \
    no_proxy="${NO_PROXY}" \
    TZ="${TIMEZONE}"

USER root

#COPY ./docker/config/trust-ca/* /usr/local/share/ca-certificates/

RUN echo "--- Set Timezone ---" \
        && echo "${TZ}" > /etc/timezone \
        && rm /etc/localtime \
        && dpkg-reconfigure -f noninteractive tzdata \
    && echo "-- Trust CA Certs --" \
        && update-ca-certificates \
    && echo "-- Install APT Dependencies --" \
        && apt update \
        && apt upgrade -y \
        && if [ ! -z "${EXTRA_INSTALL_APT_PACKAGES}" ]; then \
            apt install -y ${EXTRA_INSTALL_APT_PACKAGES} \
        ;fi \
    && echo "-- Install PHP Extensions --" \
        && if [ ! -z "${EXTRA_INSTALL_PHP_EXTENSIONS}" ]; then \
            install-php-extensions ${EXTRA_INSTALL_PHP_EXTENSIONS} \
        ;fi \
    && echo "--- Clean Up ---" \
        && apt-get clean -y \
        && apt-get autoremove -y \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./docker/php/xdebug.ini /usr/local/etc/php/conf.d/zz-xdebug.ini

WORKDIR /var/www/html

ARG UID="1000"
ARG GID="1000"

RUN groupadd --gid ${GID} app \
    && useradd --uid ${UID} --create-home --system --comment "App User" --shell /bin/bash --gid app app \
    && chown -R app:app . ${COMPOSER_HOME}

USER app

ENV PHP_INI_XDEBUG_MODE="off" \
    PHP_INI_XDEBUG_OUTPUT_DIR="/tmp/xdebug/" \
    PHP_INI_XDEBUG_CLIENT_HOST="host.docker.internal" \
    PHP_INI_XDEBUG_CLIENT_PORT=10000 \
    PHP_INI_XDEBUG_START_WITH_REQUEST="yes"

# Copy Source Files
COPY --chown=app:app ./src/app ./app
COPY --chown=app:app ./src/bootstrap ./bootstrap
COPY --chown=app:app ./src/config ./config
COPY --chown=app:app ./src/database ./database
COPY --chown=app:app ./src/public ./public
COPY --chown=app:app ./src/resources ./resources
COPY --chown=app:app ./src/routes ./routes
COPY --chown=app:app ./src/storage ./storage
COPY --chown=app:app ./src/artisan ./

# --from does not support ARG
# Ref: https://stackoverflow.com/a/69303997
#COPY --chown=app:app --from=node-image /var/www/html/bootstrap/ssr ./bootstrap/ssr
COPY --chown=app:app --from=node-image /var/www/html/public/build ./public/build

USER root

ARG SHOULD_CHOWN_TO_APP="true"

RUN if [ "${SHOULD_CHOWN_TO_APP}" = "true" ]; then \
        chown -R app:app . \
    ;fi

USER app

# Composer Dump-Autoload
RUN COMPOSER_DISABLE_NETWORK=1 composer install --no-dev --optimize-autoloader --classmap-authoritative

CMD [ "php-fpm" ]
