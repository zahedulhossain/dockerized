# Dockerized
Web development without software installations

## Setup
First in the root directory
- Copy `.env.example` to `.env`
- Edit `.env` and include the `compose.yml` files to `COMPOSE_FILE`, based on your need
- Copy `docker-compose.yml.example` to `docker-compose.yml`
- Keep only the services you need 

Then for each service that you want to run,
- Go to the service directory
- Copy `.env.example` to `.env`
- Edit `.env` according to your need

Now from the root directory run
```
docker compose up
```