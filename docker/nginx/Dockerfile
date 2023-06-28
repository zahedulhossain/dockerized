#FROM ${NODE_IMAGE_NAME}:${NODE_IMAGE_TAG} as node-image

FROM nginx:1.25.1

LABEL maintainer="Zahedul Hossain <md.zahedulhossain@gmail.com>"

ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""
ARG NO_PROXY="localhost,127.0.0.1"
ARG TIMEZONE="Asia/Dhaka"

ENV http_proxy="${HTTP_PROXY}" \
    https_proxy="${HTTPS_PROXY}" \
    no_proxy="${NO_PROXY}" \
    TZ="${TIMEZONE}"

USER root

#COPY ./docker/config/trust-ca/* /usr/local/share/ca-certificates/

RUN echo "-- Set Timezone --" \
        && export TERM=xterm \
        && echo "${TZ}" > /etc/timezone \
        && rm /etc/localtime \
        && dpkg-reconfigure -f noninteractive tzdata \
    && echo "-- Trust CA Certs --" \
        && update-ca-certificates \
    && echo "-- Install APT Dependencies --" \
        && apt update \
        && apt upgrade -y \
        && apt install dialog ssl-cert -y \
    && echo "-- Clean Up --" \
        && apt-get clean -y \
        && apt-get autoremove -y \
        && rm -f /etc/nginx/conf.d/*.conf

ARG UID="1000"
ARG GID="1000"

RUN groupadd --gid ${GID} app \
    && useradd --uid ${UID} --create-home --system --comment "App User" --shell /bin/bash -G ssl-cert --gid app app

ENV NGINX_CONF_USER="app app" \
    NGINX_CONF_HTTP_CLIENT_MAX_BODY_SIZE="2m" \
    NGINX_VHOST_DNS_RESOLVER_IP="127.0.0.11" \
    NGINX_VHOST_ENABLE_HTTP_TRAFFIC="true" \
    NGINX_VHOST_ENABLE_HTTPS_TRAFFIC="false" \
    NGINX_VHOST_UPSTREAM_PHPFPM_SERVICE_HOST_PORT="laravel-app:9000" \
    NGINX_VHOST_SSL_CERTIFICATE="/etc/ssl/certs/ssl-cert-snakeoil.pem" \
    NGINX_VHOST_SSL_CERTIFICATE_KEY="/etc/ssl/certs/ssl-cert-snakeoil.key" \
    NGINX_VHOST_HTTP_SERVER_NAME="_" \
    NGINX_VHOST_HTTPS_SERVER_NAME="_" \
    NGINX_VHOST_FASTCGI_PARAM_X_FORWARDED_PORT="80"

# Add Nginx Configs
COPY --chown=app:app ./docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY --chown=app:app ./docker/nginx/conf.d/*.conf /etc/nginx/conf.d/
COPY --chown=app:app ./docker/nginx/includes/*.conf /etc/nginx/includes/

# Add Certs
#COPY --chown=app:app ./docker/config/certs/* /etc/ssl/certs/

# Remove the Additional Entrypoints that comes with the image
RUN rm -rf /docker-entrypoint.d/*.sh

# Add our own Additional Entrypoints
COPY --chown=app:app ./docker/nginx/entrypoint.sh /docker-entrypoint.sh

WORKDIR /var/www/html

COPY --chown=app:app ./src/public ./public

# --from does not support ARG
# Ref: https://stackoverflow.com/a/69303997
#COPY --chown=app:app --from=node-image /var/www/html/public/build ./public/build

RUN chmod ugo+x /docker-entrypoint.sh \
    && touch /var/run/nginx.pid \
    && chown -R app:app /var/www/html /etc/nginx/ /run/nginx.pid /var/cache/nginx /var/log/nginx

ARG SHOULD_CHOWN_TO_APP="true"

RUN if [ "${SHOULD_CHOWN_TO_APP}" = "true" ]; then \
        chown -R app:app . \
    ;fi

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD ["nginx"]

USER app