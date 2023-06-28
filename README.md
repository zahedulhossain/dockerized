# Laravel Dockerized

## Requirements
- Docker [🔗](https://docs.docker.com/desktop/)

## Installation

### Copy env files

- In `/docker` directory
- Copy `.env.example` to `.env` file.

- In `/docker/env` directory
- Make an `env` copy from the `example` files.

### Configure compose.override.yaml

- In `/docker` directory
- Copy `compose.override.yaml.example` to `compose.override.yaml` file.
- Edit `compose.override.yaml`.


- Create a network interface named 'local-net' by running: `docker network create local-net`
- Edit the network aliases as per your need.

### Configure .env for docker

- In `/docker` directory
- Edit `.env` file
- Add Proxy settings, if needed:
    - `PROXY_HTTP=http://proxy-address:port/`
    - `PROXY_HTTPS=https://proxy-address:port/`
    - `PROXY_NO=localhost,127.0.0.*`
- To install packages via apt, add them in:
    - `APP_EXTRA_INSTALL_APT_PACKAGES`
- For php extensions, add them in:
    - `APP_EXTRA_INSTALL_PHP_EXTENSIONS`

### Configure .env for app

- In `/src` directory
- Copy `.env.example` to `.env` file.
- Edit `.env` file
- App
    - `APP_NAME=your-domain-name.com`
    - For SSL, update `http` to `https` at `APP_URL=`.
    - `APP_TIMEZONE=Asia/Dhaka`
    - Set `APP_DEBUG=true`
    - Set `APP_ENV=local`

- Database
    - `DB_HOST=local-net` (enter docker mysql service network name)
    - `DB_PORT=3306`
    - `DB_DATABASE=your_db_name`
    - `DB_USERNAME=your_db_username`
    - `DB_PASSWORD=your_db_pass`
    - `DB_ROOT_PASSWORD=your_root_db_pass`

- Do any other configurations as needed.

## Run the services

From `docker/` directory, run commands

First build the `node` service  
(required for CSS/JS assets compilation using `vite` [🔗](https://laravel.com/docs/10.x/vite).)

- `docker-compose build node`
- `docker-compose run --rm node npm ci`

Now build the `web` and `app` service

- `docker-compose build web app`
- `docker-compose up -d`
- `docker-compose exec app bash`
- `composer install`

Application commands:
- `php artisan key:generate`
- `php artisan migrate`
- `php artisan db:seed`

Now you are ready to browse the app. 
- Open the APP_URL http://localhost:8080 in a browser.

## Directory Permissions

Make sure the following directories are writeable:

- `bootstrap/cache/`
- `storage/`

You can ensure this by setting your uid and gid in docker `.env` file.
For example,
- `UID=1000`
- `GID=1000`