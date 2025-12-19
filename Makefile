COMPOSE ?= docker compose

.PHONY: up down stop start

## Levanta nginx recreando el contenedor para aplicar cambios.
up:
$(COMPOSE) up -d --force-recreate

## Detiene y elimina los contenedores/recursos creados por docker-compose.
down:
$(COMPOSE) down

## Detiene el contenedor sin eliminarlo.
stop:
$(COMPOSE) stop

## Inicia un contenedor previamente creado.
start:
$(COMPOSE) start
