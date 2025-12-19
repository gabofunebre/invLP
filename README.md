# Landing estática con nginx

Docker Compose para servir la landing incluida en `index.html` usando nginx dentro de la red Docker `inv_net`. No se exponen
puertos al host; el acceso externo se realiza mediante el cloudflared que ya tienes corriendo en la misma red Docker.

## Estructura de carpetas

```
.
├── nginx/
│   └── default.conf
├── docker-compose.yml
├── index.html
└── README.md
```

## Requisitos previos
- Docker y Docker Compose instalados.
- Red Docker externa existente llamada `inv_net` (la misma donde corre tu contenedor de cloudflared).
- Una instancia de cloudflared ya levantada y conectada a `inv_net` para exponer el servicio. No se requiere token ni archivo
  `.env` en este repositorio.

Si la red externa no existe aún:
```bash
docker network create inv_net
```

## Pasos de uso
1. **Clonar/ubicar los archivos** en la máquina donde se ejecutará Docker.

2. **Levantar nginx**
   ```bash
   docker compose up -d
   ```

3. **Ver logs**
   ```bash
   docker compose logs -f nginx
   ```

4. **Apagar/encender**
   ```bash
   docker compose down      # Apagar
   docker compose up -d     # Encender nuevamente
   ```

5. **Probar desde dentro de Docker (sin puertos publicados)**
   - Usando `docker compose exec` dentro del contenedor nginx:
     ```bash
     docker compose exec nginx wget -qO- http://localhost:8080/health
     ```
   - Desde un contenedor temporal en la red `inv_net`:
     ```bash
     docker run --rm -it --network inv_net curlimages/curl:8.8.0 http://landingInvernaderos:8080/health
     ```

## Notas de configuración
- nginx escucha en `8080` dentro de la red `inv_net` y sirve `/usr/share/nginx/html/index.html` (montado desde `index.html`).
- No se publican puertos al host; se asume que el cloudflared existente redirige el tráfico externo hacia este contenedor.
- La ruta `/health` devuelve 200 para healthchecks. Los estáticos comunes (css/js/img/fonts) llevan caché de 7 días;
  `index.html` se sirve sin caché agresiva.
