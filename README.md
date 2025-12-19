# Landing estática con nginx + cloudflared

Configuración de Docker Compose para servir la landing estática ubicada en `/WDPassportGabo/Servicios/invLP` usando nginx y un túnel de Cloudflare sin exponer puertos al host.

## Estructura de carpetas

```
.
├── cloudflared/
│   └── config.yml
├── nginx/
│   └── default.conf
├── docker-compose.yml
├── .env.example
└── README.md
```

## Requisitos previos
- Docker y Docker Compose instalados.
- Acceso a la carpeta de la landing: `/WDPassportGabo/Servicios/invLP` (contiene `index.html`).
- Token del túnel ya creado en Cloudflare (`TUNNEL_TOKEN`).

## Pasos de uso
1. **Crear carpeta del proyecto**
   ```bash
   mkdir -p ~/invLP && cd ~/invLP
   ```

2. **Copiar/ubicar los archivos**
   Coloca dentro de la carpeta los archivos `docker-compose.yml`, `nginx/default.conf`, `cloudflared/config.yml`, `.env.example` y este `README.md` (manteniendo la misma estructura de carpetas mostrada arriba).

3. **Configurar el token en `.env`**
   ```bash
   cp .env.example .env
   # Edita .env y reemplaza TUNNEL_TOKEN con el token real de Cloudflare
   ```

4. **Levantar los servicios**
   ```bash
   docker compose up -d
   ```

5. **Ver logs**
   ```bash
   docker compose logs -f nginx
   docker compose logs -f cloudflared
   ```

6. **Apagar/encender**
   ```bash
   docker compose down      # Apagar
   docker compose up -d     # Encender nuevamente
   ```

7. **Probar desde dentro de Docker (sin puertos publicados)**
   - Usando `docker compose exec` dentro del contenedor nginx:
     ```bash
     docker compose exec nginx wget -qO- http://localhost:8080/health
     ```
   - Desde un contenedor temporal en la red `inv_net`:
     ```bash
     docker run --rm -it --network inv_net curlimages/curl:8.8.0 http://landingInvernaderos:8080/health
     ```

## Notas de configuración
- No se publican puertos al host; todo el tráfico pasa por el túnel de Cloudflare hacia `inv.gabo.ar`.
- nginx escucha en el puerto interno `8080` dentro de la red `inv_net` y sirve `/usr/share/nginx/html` en modo de solo lectura desde `/WDPassportGabo/Servicios/invLP`.
- La directiva `/health` devuelve 200 para healthchecks. Los estáticos comunes (css/js/img/fonts) llevan caché de 7 días; `index.html` se sirve sin caché agresiva.
- Cloudflared enruta `inv.gabo.ar` hacia `http://landingInvernaderos:8080` usando el token almacenado en `.env`.
