# Landing estática con nginx + cloudflared

Configuración de Docker Compose para servir la landing estática incluida en este repositorio (archivo `index.html`) con nginx y un túnel de Cloudflare. No se publican puertos al host: el sitio queda accesible únicamente dentro de la red Docker `inv_net` y a través del túnel.

## Estructura de carpetas

```
.
├── cloudflared/
│   └── config.yml
├── nginx/
│   └── default.conf
├── docker-compose.yml
├── .env.example
├── index.html
└── README.md
```

## Requisitos previos
- Docker y Docker Compose instalados.
- Red Docker externa creada o existente llamada `inv_net` (es la misma donde está corriendo cloudflared).
- Token del túnel ya creado en Cloudflare (`TUNNEL_TOKEN`).

Para crear la red externa en caso de que no exista:
```bash
docker network create inv_net
```

## Pasos de uso
1. **Clonar/ubicar los archivos**
   Coloca este repositorio en la máquina donde se ejecutará Docker.

2. **Configurar el token en `.env`**
   ```bash
   cp .env.example .env
   # Edita .env y reemplaza TUNNEL_TOKEN con el token real de Cloudflare
   ```

3. **Levantar los servicios**
   ```bash
   docker compose up -d
   ```

4. **Ver logs**
   ```bash
   docker compose logs -f nginx
   docker compose logs -f cloudflared
   ```

5. **Apagar/encender**
   ```bash
   docker compose down      # Apagar
   docker compose up -d     # Encender nuevamente
   ```

6. **Probar desde dentro de Docker (sin puertos publicados)**
   - Usando `docker compose exec` dentro del contenedor nginx:
     ```bash
     docker compose exec nginx wget -qO- http://localhost:8080/health
     ```
   - Desde un contenedor temporal en la red `inv_net`:
     ```bash
     docker run --rm -it --network inv_net curlimages/curl:8.8.0 http://landingInvernaderos:8080/health
     ```

## Notas de configuración
- nginx escucha en el puerto interno `8080` dentro de la red `inv_net` y sirve `/usr/share/nginx/html/index.html` en modo de solo lectura desde el archivo `index.html` incluido en el repositorio.
- No se publican puertos al host; todo el tráfico pasa por el túnel de Cloudflare hacia `inv.gabo.ar`.
- La directiva `/health` devuelve 200 para healthchecks. Los estáticos comunes (css/js/img/fonts) llevan caché de 7 días; `index.html` se sirve sin caché agresiva.
- Cloudflared enruta `inv.gabo.ar` hacia `http://landingInvernaderos:8080` usando el token almacenado en `.env`.
