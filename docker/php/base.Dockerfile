FROM php:8.2.7-fpm

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
    TZ="${TIMEZONE}" \
    COMPOSER_VERSION="2.5.8" \
    COMPOSER_HOME="/usr/local/composer"

USER root

# Install & manage application dependencies
RUN echo "-- Configure Timezone --" \
        && echo "${TIMEZONE}" > /etc/timezone \
        && rm /etc/localtime \
        && dpkg-reconfigure -f noninteractive tzdata \
    && echo "-- Install/Upgrade APT Dependencies --" \
        && apt update \
        && apt upgrade -y \
        && apt install -V -y --no-install-recommends --no-install-suggests \
            bc \
            curl \
            openssl \
            unzip \
            zip \
    && echo "-- Install PHP Extensions --" \
        && if [ ! -z "${HTTP_PROXY}" ]; then \
            pear config-set http_proxy ${HTTP_PROXY} \
        ;fi \
        && curl -L -o /usr/local/bin/install-php-extensions https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
        && chmod a+x /usr/local/bin/install-php-extensions \
        && sync \
        && install-php-extensions \
            bcmath \
            exif \
            fileinfo \
            gettext \
            intl \
            opcache \
            pcntl \
            pdo \
            pdo_mysql \
            redis \
            uuid \
            xml \
            zip \
        && if [ ! -z "${HTTP_PROXY}" ]; then \
            pear config-set http_proxy "" \
        ;fi \
    && echo "--- Clean Up ---" \
        && apt clean -y \
        && apt autoremove -y \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# PHP Composer Installation & Directory Permissions
RUN curl -L -o /usr/local/bin/composer https://github.com/composer/composer/releases/download/${COMPOSER_VERSION}/composer.phar \
    && mkdir -p ${COMPOSER_HOME}/cache /tmp/xdebug/ \
    && chmod ugo+sw ${COMPOSER_HOME}/cache /tmp/xdebug/ \
    && mkdir /run/php \
    && chmod ugo+x /usr/local/bin/composer \
    && composer --version

# PHP INI envs
ENV PHP_INI_OUTPUT_BUFFERING=4096 \
    PHP_INI_MAX_EXECUTION_TIME=60 \
    PHP_INI_MAX_INPUT_TIME=60 \
    PHP_INI_MEMORY_LIMIT="256M" \
    PHP_INI_DISPLAY_ERRORS="Off" \
    PHP_INI_DISPLAY_STARTUP_ERRORS="Off" \
    PHP_INI_POST_MAX_SIZE="2M" \
    PHP_INI_FILE_UPLOADS="On" \
    PHP_INI_UPLOAD_MAX_FILESIZE="2M" \
    PHP_INI_MAX_FILE_UPLOADS="2" \
    PHP_INI_ALLOW_URL_FOPEN="On" \
    PHP_INI_ERROR_LOG="" \
    PHP_INI_DATE_TIMEZONE="${TIMEZONE}" \
    PHP_INI_SESSION_SAVE_HANDLER="files" \
    PHP_INI_SESSION_SAVE_PATH="/tmp" \
    PHP_INI_SESSION_USE_STRICT_MODE=0 \
    PHP_INI_SESSION_USE_COOKIES=1 \
    PHP_INI_SESSION_USE_ONLY_COOKIES=1 \
    PHP_INI_SESSION_NAME="APP_SSID" \
    PHP_INI_SESSION_COOKIE_SECURE="On" \
    PHP_INI_SESSION_COOKIE_LIFETIME=0 \
    PHP_INI_SESSION_COOKIE_PATH="/" \
    PHP_INI_SESSION_COOKIE_DOMAIN="" \
    PHP_INI_SESSION_COOKIE_HTTPONLY="On" \
    PHP_INI_SESSION_COOKIE_SAMESITE="" \
    PHP_INI_SESSION_UPLOAD_PROGRESS_NAME="APP_UPLOAD_PROGRESS" \
    PHP_INI_OPCACHE_ENABLE=1 \
    PHP_INI_OPCACHE_ENABLE_CLI=0 \
    PHP_INI_OPCACHE_MEMORY_CONSUMPTION=256 \
    PHP_INI_OPCACHE_INTERNED_STRINGS_BUFFER=16 \
    PHP_INI_OPCACHE_MAX_ACCELERATED_FILES=100000 \
    PHP_INI_OPCACHE_MAX_WASTED_PERCENTAGE=25 \
    PHP_INI_OPCACHE_USE_CWD=0 \
    PHP_INI_OPCACHE_VALIDATE_TIMESTAMPS=0 \
    PHP_INI_OPCACHE_REVALIDATE_FREQ=0 \
    PHP_INI_OPCACHE_SAVE_COMMENTS=0 \
    PHP_INI_OPCACHE_ENABLE_FILE_OVERRIDE=1 \
    PHP_INI_OPCACHE_MAX_FILE_SIZE=0 \
    PHP_INI_OPCACHE_FAST_SHUTDOWN=1

ENV PHPFPM_CONF_WWW_USER="www-data" \
    PHPFPM_CONF_WWW_GROUP="www-data" \
    PHPFPM_CONF_WWW_LISTEN=9000 \
    PHPFPM_CONF_WWW_LISTEN_OWNER="www-data" \
    PHPFPM_CONF_WWW_LISTEN_GROUP="www-data" \
    PHPFPM_CONF_WWW_LISTEN_MODE=0660 \
    PHPFPM_CONF_WWW_PM="dynamic" \
    PHPFPM_CONF_WWW_PM_MAX_CHILDREN=5 \
    PHPFPM_CONF_WWW_PM_START_SERVERS=2 \
    PHPFPM_CONF_WWW_PM_MIN_SPARE_SERVERS=1 \
    PHPFPM_CONF_WWW_PM_MAX_SPARE_SERVERS=3 \
    PHPFPM_CONF_WWW_PM_PROCESS_IDLE_TIMEOUT="10s" \
    PHPFPM_CONF_WWW_PM_MAX_REQUESTS=0

WORKDIR /var/www/html

COPY --chown=www-data:www-data ./src/composer*.json ./src/composer*.lock /var/www/html/

USER www-data

# Installing the packages here to cache them
# So further installs from child images will
# download less / no dependencies.
RUN composer install --no-interaction --no-scripts --no-autoloader

COPY ./docker/php/php.ini /usr/local/etc/php/php.ini
COPY ./docker/php/www.conf /usr/local/etc/php-fpm.d/www.conf

# Copy Schedule Command
COPY ./docker/php/run-scheduler.sh /

# Unset proxy, timezone ENVs
ENV http_proxy="" \
    https_proxy="" \
    no_proxy="" \
    TZ=""
