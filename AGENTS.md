# Reglas para agentes de IA en Prepion

- **Control manual de Git (obligatorio):** ningún agente ejecuta `git commit` ni `git push`. Solo deja los cambios listos en local; el equipo revisa, hace commit y sube a mano.
- **Costo cero:** no agregar APIs, servicios ni hosting que funcionen con créditos o tarjeta.
- **Desarrollo 100 % local:** app, backend, PostgreSQL y n8n corren en la computadora del equipo; el despliegue es solo para la demo.
- **Calidad:** antes de dar algo por terminado, correr `pnpm run check` (formato, lint, tipos y pruebas con cobertura ≥ 80 %). No usar `--no-verify`.
- **Secretos:** nunca en el código ni en Git; van en `.env` (plantilla en `.env.example`).

- **Estándares obligatorios:** [`docs/ESTANDARES.md`](docs/ESTANDARES.md) — idioma híbrido (dominio en español, técnico en inglés), backend hexagonal + features, app por features, todo lo del servidor en Docker.

## Estructura
- `app/` — App móvil en Flutter (Android; iOS con el mismo código).
- `backend/` — API en FastAPI + PostgreSQL, y scripts de ML/extracción (grupo `ml` de uv).
- `docker-compose.yml` — postgres y api (con migraciones al arrancar), ml (perfil `ml`) y n8n (perfil `automatizacion`).
- Puertos: en esta PC Windows/Hyper-V reserva rangos de puertos que cambian al reiniciar (ver `netsh interface ipv4 show excludedportrange protocol=tcp`); por eso la API usa **8800**.
