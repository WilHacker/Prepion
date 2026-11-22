# Prepion — Backend

API en **FastAPI** + **PostgreSQL** con migraciones **Alembic**, y scripts de **ML** (extracción de exámenes y recalibración del modelo). Antes de empezar, sigue la instalación del [README general](../README.md).

---

## Índice
1. [Qué hace el backend](#1-qué-hace-el-backend)
2. [Requisitos](#2-requisitos)
3. [Instalación y configuración](#3-instalación-y-configuración)
4. [Correr el backend](#4-correr-el-backend)
5. [Migraciones (Alembic)](#5-migraciones-alembic)
6. [Arquitectura: hexagonal + features](#6-arquitectura-hexagonal--features)
7. [Cómo agregar algo nuevo](#7-cómo-agregar-algo-nuevo)
8. [Pruebas y calidad](#8-pruebas-y-calidad)
9. [ML y extracción de exámenes](#9-ml-y-extracción-de-exámenes)
10. [Dependencias](#10-dependencias)

---

## 1. Qué hace el backend
- Publica el **banco de preguntas** por versión.
- Maneja **cuentas**: modo anónimo o cuenta con correo y contraseña (sin Google).
- **Sincroniza** las respuestas de la app sin duplicarlas.
- **Recalibra el ML** con los datos de todos los usuarios y publica el **paquete de conocimiento**.
- Recibe **reportes** de errores en preguntas.

## 2. Requisitos
| Herramienta | Versión |
|---|---|
| Python | 3.13 |
| uv | 0.12 |
| Docker Desktop | para PostgreSQL (y para correr todo en contenedores) |

## 3. Instalación y configuración

### 3.1 Instalar dependencias
Desde `backend/`:
```bash
uv sync --all-groups
```
Esto crea `.venv/` e instala tres grupos:

| Grupo | Para qué | Cuándo se usa |
|---|---|---|
| (principal) | API: FastAPI, SQLModel, Alembic, seguridad | Siempre |
| `dev` | Pruebas y calidad: pytest, pytest-cov, httpx2, ruff, mypy | Desarrollo y CI |
| `ml` | PyMuPDF, pyBKT, girth, fsrs, pandas, sympy, matplotlib… | Extracción de PDF y ML |

### 3.2 Variables de entorno
El backend lee el `.env` de la **raíz del repo** (también acepta uno en `backend/`).

| Variable | Obligatoria | Ejemplo |
|---|---|---|
| `DATABASE_URL` | Sí (falla al arrancar si falta) | `postgresql+psycopg://prepion:<clave>@localhost:5432/prepion` |

Dentro de Docker, `docker-compose.yml` arma `DATABASE_URL` con el host `postgres`.

### 3.3 Base de datos
PostgreSQL corre en Docker. Desde la raíz del repo:
```bash
docker compose up -d postgres
```

## 4. Correr el backend

### Opción A: todo en Docker (recomendada)
Desde la raíz del repo:
```bash
docker compose up -d --build
```
`migrate` aplica las migraciones y luego arranca `api` en <http://localhost:8800>.

### Opción B: en tu PC, con recarga automática
Con PostgreSQL levantado y las migraciones aplicadas (sección 5), desde `backend/`:
```bash
uv run uvicorn app.main:app --reload --port 8800
```

| Dirección | Qué es |
|---|---|
| <http://localhost:8800/api/health> | Estado del servicio: `{"estado":"ok"}` |
| <http://localhost:8800/docs> | Documentación interactiva (Swagger) |

> Se usa el puerto **8800** porque Windows reserva el 8000 en esta PC.

## 5. Migraciones (Alembic)

| Paso | Comando (desde `backend/`) |
|---|---|
| 1. Generar una migración tras cambiar modelos | `uv run alembic revision --autogenerate -m "agregar tabla x"` |
| 2. **Revisar a mano** el archivo en `migrations/versions/` | — |
| 3. Aplicarla | `uv run alembic upgrade head` |
| 4. Confirmar que modelos y migraciones coinciden | `uv run alembic check` |
| Revertir la última | `uv run alembic downgrade -1` |
| Ver la versión actual | `uv run alembic current` |
| Ver el historial | `uv run alembic history` |

**Reglas:**
- **Nunca editar una migración ya aplicada**: se crea una nueva.
- Toda migración tiene `downgrade()`. CI aplica → revierte → reaplica → `alembic check`.
- Los archivos se llaman `AAAAMMDD_HHMM_descripcion.py`.
- La URL de conexión sale de `DATABASE_URL`; nunca se escribe en `alembic.ini`.

**Tablas actuales** (migración `crear tablas iniciales`): `usuarios`, `examenes`, `temas`, `preguntas`, `banco_versiones`, `respuestas`, `paquetes_conocimiento`, `reportes`.

## 6. Arquitectura: hexagonal + features

```
backend/
├── app/
│   ├── main.py                  create_app(): registra errores y routers
│   ├── core/
│   │   ├── config.py            configuración (DATABASE_URL)
│   │   ├── database.py          engine y get_session()
│   │   ├── errors.py            errores de dominio → problem+json (RFC 9457)
│   │   └── models.py            registra todas las tablas para Alembic
│   ├── shared/
│   │   ├── domain/errores.py    DominioError y subclases
│   │   └── infrastructure/persistence/tabla_base.py   UUID + creado_en + actualizado_en
│   └── features/<feature>/
│       ├── domain/              entidades, reglas, errores y puertos (Python puro)
│       ├── application/         use_cases/ y dto/
│       └── infrastructure/      http/ (routers), persistence/ (tablas, repositorios), adapters/
├── migrations/                  Alembic (env.py y versions/)
└── tests/                       espejo de app/
```

- **Regla de dependencias:** `infrastructure → application → domain`. `domain` no importa FastAPI, SQLModel ni librerías externas.
- **Features:** `health`, `examenes`, `preguntas`, `auth`, `sincronizacion`, `conocimiento`, `reportes`.
- **Errores:** los casos de uso lanzan errores de dominio (`RecursoNoEncontradoError` → 404, `ConflictoError` → 409, `ReglaDeNegocioError` → 422); `core/errors.py` los convierte en `application/problem+json`.
- **Idioma híbrido:** dominio en español (`obtener_preguntas`, `PreguntaTabla`), estructura técnica en inglés. Detalle en [`docs/ESTANDARES.md`](../docs/ESTANDARES.md).

## 7. Cómo agregar algo nuevo

### Un endpoint
1. Caso de uso en `features/<feature>/application/use_cases/`.
2. Si necesita datos, define un **puerto** (interfaz) en `domain/` y su **adaptador** en `infrastructure/persistence/`.
3. Router en `features/<feature>/infrastructure/http/router.py` (rutas `kebab-case`, plural, en español).
4. Regístralo en `create_app()` (`app/main.py`) con `prefix="/api"`.
5. Prueba en `tests/features/<feature>/`.

### Una tabla
1. Clase `<Entidad>Tabla(TablaBase, table=True)` en `features/<feature>/infrastructure/persistence/tablas.py`, con `__tablename__` en `snake_case` plural.
2. Impórtala en `app/core/models.py`.
3. Genera, revisa y aplica la migración (sección 5).

## 8. Pruebas y calidad

| Comando (desde `backend/`) | Qué hace |
|---|---|
| `uv run pytest` | Pruebas con cobertura; **falla si baja del 80 %** |
| `uv run ruff format .` | Formatea el código |
| `uv run ruff check .` | Lint (imports, nombres, bugs, seguridad, sin `print`) |
| `uv run mypy` | Tipos en modo estricto |

- Pruebas en español con estructura **AAA**: `test_<resultado>_cuando_<condicion>`.
- Desde la raíz, `pnpm run check` corre todo esto junto con la app (es lo que corre el `git push`).

## 9. ML y extracción de exámenes
Las tareas pesadas corren en el contenedor `ml` (perfil bajo demanda), con la carpeta `data/` montada en `/srv/data`:
```bash
docker compose run --rm ml <comando>
```
En la PC, con el grupo `ml` instalado:
```bash
uv run --group ml python <script>
```

> `scikit-learn` está fijado en `<1.8` porque **pyBKT** falla al importarse con versiones más nuevas.

### Del PDF al banco de preguntas (curación)
Los comandos se corren desde `backend/` con el grupo `ml` instalado.

1. **Extraer** el examen a un borrador CSV (y recortar como imagen las preguntas con fórmulas o gráficos). El PDF se descarga a mano a `data/examenes_pdf/`; nunca pisa un CSV existente:
   ```bash
   uv run python -m app.features.examenes.infrastructure.cli extraer ../data/examenes_pdf/2026-2-1op.pdf ../data/borradores/2026-2-1op.csv --imagenes ../data/imagenes
   ```
   Un mismo PDF puede traer varias series con la numeración repetida: los códigos quedan como `S1-A1`, `S2-A1` y las preguntas repetidas se marcan con `estado = duplicada`.
2. **Curar** el CSV (Excel o Google Sheets): completar `respuesta` (A–E), `tema`, `explicacion` y poner `estado = publicada`.
3. **Exportar** el banco y copiar las imágenes a la app:
   ```bash
   uv run python -m app.features.examenes.infrastructure.cli exportar ../data/borradores/2026-2-1op.csv ../app/assets/datos/banco_semilla.json --examen 2026-2-1op.pdf --copiar-imagenes ../data/imagenes ../app/assets/imagenes
   ```
   Si algo falta, lista todos los problemas de una vez.
4. **Publicar** el banco en el servidor (cada versión nueva lleva un `version` mayor):
   ```bash
   uv run python -m app.features.preguntas.infrastructure.cli publicar ../app/assets/datos/banco_semilla.json
   ```
   La app lo consulta con `GET /api/preguntas/banco/actual` y lo descarga con `GET /api/preguntas/banco/descargar/{version}`.

## 10. Dependencias

| Paquete | Uso |
|---|---|
| `fastapi`, `uvicorn[standard]` | API y servidor |
| `sqlmodel`, `psycopg[binary]` | Modelos y conexión a PostgreSQL |
| `alembic` | Migraciones |
| `pydantic-settings` | Configuración desde el entorno |
| `argon2-cffi`, `pyjwt`, `slowapi`, `email-validator` | Contraseñas, sesiones, límite de intentos, validación de correo |
| `pytest`, `pytest-cov`, `httpx2`, `ruff`, `mypy` | Pruebas y calidad (grupo `dev`) |
| `pymupdf`, `requests`, `beautifulsoup4` | Descarga y extracción de exámenes (grupo `ml`) |
| `pybkt`, `girth`, `fsrs`, `numpy`, `pandas`, `scipy`, `scikit-learn` | Modelos de conocimiento, dificultad y repetición espaciada (grupo `ml`) |
| `sympy`, `matplotlib` | Verificar respuestas y convertir LaTeX a imagen (grupo `ml`) |

Agregar una dependencia:
```bash
uv add <paquete>
```
Agregarla a un grupo:
```bash
uv add --group ml <paquete>
```
