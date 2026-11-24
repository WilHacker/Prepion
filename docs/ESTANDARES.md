# Estándares de Prepion

Basados en el estándar de ArcuSIS, adaptados a **Python (backend)** y **Dart/Flutter (app)**. Aplican a todo el repositorio. Si algo choca con esta guía, la guía gana; para cambiarla, se edita este archivo.

---

## 1. Idioma híbrido

**Regla:** el **dominio** (datos, negocio, mensajes) va en **español**; los nombres **estructurales/técnicos** van en **inglés**. Solo el nombre técnico: lo que hay dentro sigue en español.

| Técnico (inglés) | Dominio (español) |
|---|---|
| `app`, `core`, `shared`, `features`, `domain`, `application`, `infrastructure`, `data`, `presentation`, `http`, `persistence`, `adapters`, `ports`, `use_cases`, `dto`, `pages`, `widgets`, `providers`, `config`, `health`, `auth`, `utils`, `tests`, `docs` | `preguntas`, `examenes`, `temas`, `respuestas`, `practica`, `progreso`, `repasos`, `conocimiento`, `reportes`, `sincronizacion`, `cuentas`, `inicio`, `configuracion` |

### Convenciones por elemento

| Elemento | Python (backend) | Dart (app) |
|---|---|---|
| Variables y funciones | `snake_case`, español: `obtener_preguntas` | `lowerCamelCase`, español: `obtenerPreguntas` |
| Booleanos | `es_`/`tiene_`/`puede_`/`debe_`: `es_anonimo` | `es`/`tiene`/`puede`/`debe`: `esAnonimo` |
| Clases y tipos | `PascalCase`, español: `Pregunta`, `CrearCuentaRequest` | `PascalCase`, español: `Pregunta`, `TarjetaPregunta` |
| Constantes | `UPPER_SNAKE_CASE`: `MAX_PREGUNTAS_POR_DIA` | `lowerCamelCase` (estilo Dart): `maxPreguntasPorDia` |
| Archivos | `snake_case.py`: `crear_cuenta.py` | `snake_case.dart`: `tarjeta_pregunta.dart` |
| Carpetas de dominio | español, minúscula: `features/preguntas/` | español, minúscula: `features/practica/` |
| Carpetas técnicas | inglés, minúscula: `infrastructure/` | inglés, minúscula: `presentation/` |
| Providers (Riverpod) | — | nombre + `Provider`: `preguntasDelDiaProvider` |
| Tablas de BD | `snake_case`, plural, español: `preguntas`, `paquetes_conocimiento` | — |
| Columnas de BD | `snake_case`, español: `creado_en`, `es_anonimo` | — |
| Rutas de la API | `kebab-case`, plural, español, prefijo `/api`: `/api/preguntas`, `/api/paquetes-conocimiento` | — |
| JSON de la API | `camelCase`, español: `{"creadoEn": "..."}` (alias de Pydantic) | igual al consumirlo |
| Variables de entorno | `UPPER_SNAKE_CASE`: `DATABASE_URL` | `--dart-define=API_URL=...` |
| Errores de dominio | `<Entidad><Problema>Error`: `PreguntaNoEncontradaError` | igual |

**Excepciones:** palabras técnicas sin traducción natural se quedan en inglés (`health`, `auth`, `token`, `id`). Nombres de librerías y de sus objetos no se traducen.

**Textos visibles:** todo lo que ve el usuario, en español.

---

## 2. Arquitectura del backend: hexagonal + features

Cada **feature** es una porción vertical del negocio y adentro sigue la **arquitectura hexagonal** (puertos y adaptadores).

```
backend/
├── app/
│   ├── main.py                 crea la app FastAPI y registra los routers
│   ├── core/                   configuración, sesión de BD, seguridad (técnico)
│   ├── shared/
│   │   └── domain/             DominioError base y tipos comunes
│   └── features/
│       └── <feature>/
│           ├── domain/         entidades, reglas, errores y PUERTOS (interfaces)
│           ├── application/    casos de uso (use_cases/) y dto/ (requests, responses)
│           └── infrastructure/ ADAPTADORES: http/ (routers FastAPI),
│                               persistence/ (repositorios SQLModel), adapters/ (PyMuPDF, pyBKT, girth…)
└── tests/
    └── features/<feature>/     espejo de app/features
```

### Regla de dependencias (obligatoria)
```
infrastructure  →  application  →  domain
```
- `domain/` **no importa** FastAPI, SQLModel, PyMuPDF ni ninguna librería externa: solo Python puro.
- `application/` usa los puertos del dominio; no sabe si la BD es PostgreSQL ni si la entrada es HTTP.
- `infrastructure/` implementa los puertos (adaptadores) y expone los casos de uso por HTTP.
- Una feature no importa el interior de otra; si necesita algo, lo pide por un puerto.
- Las carpetas se crean **solo cuando hacen falta**.

### Features previstas
| Feature | Qué cubre | Adaptadores principales |
|---|---|---|
| `health` | Estado del servicio | http |
| `examenes` | Detectar, descargar y extraer exámenes de la FCyT | requests/BeautifulSoup, PyMuPDF |
| `preguntas` | Banco de preguntas, curación, versiones | SQLModel, exportar JSON |
| `auth` | Anónimo, cuenta con correo, código de recuperación | Argon2, JWT, SQLModel |
| `sincronizacion` | Recibir respuestas en lotes, progreso respaldado | SQLModel |
| `conocimiento` | Recalibrar el ML y publicar el paquete de conocimiento | pyBKT, girth, fsrs, pandas |
| `reportes` | Reportes de errores en preguntas | SQLModel |

### Errores
- Los casos de uso lanzan **errores de dominio** (`DominioError` y subclases) en español.
- Un **manejador global** en `core/` los traduce a HTTP con formato RFC 9457 (`application/problem+json`).

| Error de dominio | HTTP |
|---|---|
| `...NoEncontradaError` / `...NoEncontradoError` | 404 |
| `...YaExisteError`, conflicto de estado | 409 |
| `...InvalidaError`, regla incumplida | 422 |
| Sin sesión / credenciales | 401 |
| Validación de entrada (Pydantic) | 400/422 |

- Mensajes claros, **sin datos sensibles**; el detalle técnico va al log.

---

## 3. Arquitectura de la app: features

```
app/lib/
├── main.dart                   arranque
├── app/                        App, router (go_router), tema (técnico)
├── shared/                     widgets, utils, database (drift), network (dio), notifications
└── features/
    └── <feature>/
        ├── data/               fuentes de datos, modelos JSON/drift, implementación de repositorios
        ├── domain/             entidades y reglas puras (BKT, sesión diaria, FSRS envuelto)
        └── presentation/       pages/, widgets/, providers/ (Riverpod)

app/test/features/<feature>/    espejo de lib/features
```

- `domain/` es Dart puro: sin Flutter, sin drift, sin dio. Así se prueba sin emulador.
- `presentation/` → `domain/` ← `data/`. `domain/` no importa `data/` ni `presentation/`.
- Una feature no importa el interior de otra; lo compartido va a `shared/`. `shared/` no importa features.
- Las carpetas se crean solo cuando hacen falta.

### Features previstas
| Feature | Casos de uso |
|---|---|
| `inicio` | Primer uso, sin cuenta / con cuenta (CU-E01) |
| `practica` | Sesión diaria, responder, explicación, repaso espaciado, práctica por tema (CU-E04–E07) |
| `progreso` | Dominio por tema, nivel de preparación, reporte (CU-E09–E11) |
| `configuracion` | Hora, cantidad, fecha del examen (CU-E16) |
| `cuentas` | Registro, login, recuperación, borrar cuenta (CU-E17, E19–E23) |
| `sincronizacion` | Cola de respuestas, banco y paquete de conocimiento (CU-E15, E18) |

---

## 4. Base de datos y migraciones

| Tema | Decisión |
|---|---|
| Herramienta | **Alembic** sobre los modelos SQLModel |
| Modelos | `features/<feature>/infrastructure/persistence/tablas.py`, clases `<Entidad>Tabla` (`PreguntaTabla` → tabla `preguntas`) |
| Registro | `app/core/models.py` importa todas las tablas para que Alembic las vea: **toda tabla nueva se agrega ahí** |
| Base común | `TablaBase` (UUID + `creado_en` + `actualizado_en`) en `shared/infrastructure/persistence/tabla_base.py` |
| Nombres de llaves e índices | Convención fija (`pk_preguntas`, `fk_preguntas_examen_id_examenes`, `uq_…`, `ix_…`) |
| Versiones | `backend/migrations/versions/AAAAMMDD_HHMM_descripcion.py`, versionadas en Git |
| Conexión | `DATABASE_URL` (obligatoria; en `.env` para la PC, en docker-compose para los contenedores) |

### Flujo
```bash
cd backend
uv run alembic revision --autogenerate -m "agregar tabla x"   # 1. generar
# 2. revisar a mano el archivo generado
uv run alembic upgrade head                                   # 3. aplicar
uv run alembic check                                          # 4. confirmar que no falta nada
```
- **Nunca editar una migración ya aplicada**: se crea otra nueva.
- Toda migración tiene `downgrade()`; CI la prueba (aplicar → revertir → reaplicar → `alembic check`).
- En Docker, la `api` aplica las migraciones al arrancar y solo sirve si salieron bien.

### Tablas actuales (migración `crear tablas iniciales`)
`usuarios`, `examenes`, `temas`, `preguntas`, `banco_versiones`, `respuestas` (llave `id_evento` generada en el celular), `paquetes_conocimiento`, `reportes`.

### App (base local)
- **drift** en `lib/shared/database/app_database.dart`; cada feature agrega sus tablas ahí y sube `schemaVersion` con su migración.
- Código generado (`*.g.dart`) **se versiona en Git**; se regenera con `dart run build_runner build --delete-conflicting-outputs`.

---

## 5. Todo dockerizado

Todo lo que corre del lado del servidor vive en `docker-compose.yml`:

| Servicio | Imagen | Uso |
|---|---|---|
| `postgres` | `postgres:16` | Base de datos |
| `api` | `backend/Dockerfile` (target `api`) | Aplica `alembic upgrade head` y sirve FastAPI |
| `ml` | `backend/Dockerfile` (target `ml`) | Extracción de PDF y recalibración del ML (perfil `ml`, se corre bajo demanda) |
| `n8n` | `n8nio/n8n` | Recolección y tareas programadas (perfil `automatizacion`, opcional) |

- La **app Flutter no se dockeriza**: corre en el celular o emulador y apunta a la API (`--dart-define=API_URL=http://<IP>:8800`).
- Puertos en esta PC: Windows reserva rangos de puertos que cambian al reiniciar → API en **8800**.

---

## 6. Calidad automática (obligatoria)

Herramientas en la raíz (`package.json`, con **pnpm**) para todo el monorepo:

| Momento | Qué se ejecuta | Herramienta |
|---|---|---|
| `git commit` (pre-commit) | Formato y lint **solo de los archivos preparados** | Husky + lint-staged → `ruff format` + `ruff check --fix` (Python), `dart format` (Dart) |
| `git commit` (commit-msg) | Valida el mensaje con Conventional Commits | commitlint |
| `git push` (pre-push) | `pnpm run check`: formato, lint, tipos, análisis y **pruebas unitarias con cobertura ≥ 80 %** | ruff, mypy (estricto), flutter analyze `--fatal-infos`, pytest + pytest-cov, flutter test + `scripts/verificar-cobertura.mjs` |
| GitHub (push a `main` y Pull Request) | Lo mismo en CI + validación de commits del PR | GitHub Actions (`.github/workflows/ci.yml`) |

### Comandos
| Comando | Uso |
|---|---|
| `pnpm install` | Instala las herramientas y activa los hooks de Git (una vez por persona) |
| `pnpm run commit` | **Commit guiado** (commitizen): pregunta tipo, alcance y descripción |
| `pnpm run format` | Formatea backend y app |
| `pnpm run lint` | Formato (verificación), lint, tipos y análisis |
| `pnpm run test` | Pruebas unitarias de ambos con cobertura mínima |
| `pnpm run check` | `lint` + `test` (lo mismo que el pre-push) |

### Mensajes de commit
```
tipo(alcance): descripción en español y en minúscula
```
- Tipos: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
- Alcances permitidos: `app`, `backend`, `ml`, `docker`, `ci`, `docs`, `deps`.
- Máximo 100 caracteres. Ejemplo: `feat(app): agregar pantalla de práctica diaria`.

### Reglas de código verificadas
- **Python:** ruff con reglas E, W, F, I (orden de imports), N (nombres), UP, B, SIM, S (seguridad), T20 (sin `print`); mypy en modo estricto.
- **Dart:** `flutter_lints` + `strict-casts`, `strict-inference`, `strict-raw-types`, comillas simples, imports con `package:`, sin `print`, `final` en variables locales, futures no ignorados.
- **Cobertura mínima:** 80 % en backend (`app/`) y en la app (`lib/`, sin `main.dart` ni archivos generados).
- No se usa `--no-verify` para saltarse los hooks.

---

## 7. Comentarios, tests y Git

- **Comentarios:** solo el **por qué** (regla no obvia, workaround, límite conocido). Docstrings en español solo en funciones públicas del dominio y del ML.
- **Tests:** descripciones en español y estructura **AAA** (Preparar · Actuar · Verificar), un comportamiento por test.
  - Python: `test_<resultado>_cuando_<condicion>` → `test_devuelve_ok_cuando_el_servicio_esta_vivo`.
  - Dart: `test('devuelve ... cuando ...', () {...})`.
- **Git:** Conventional Commits (`feat:`, `fix:`, `docs:`…). **Ningún agente hace commit ni push**; el equipo lo hace a mano.
