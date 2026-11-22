# Prepion

App móvil **gratuita** para prepararse para el examen de ingreso a la **Facultad de Ciencias y Tecnología (FCyT) de la UMSS**, con preguntas de exámenes reales. Cada día recuerda practicar, repite lo que fallas y te dice en qué tema estás flojo. Funciona sin internet.

Proyecto de la **Abstracthon 2026** · Track Educación.

---

## Índice
1. [Cómo está organizado el repositorio](#1-cómo-está-organizado-el-repositorio)
2. [Qué hay que instalar (resumen)](#2-qué-hay-que-instalar-resumen)
3. [Instalación paso a paso desde cero](#3-instalación-paso-a-paso-desde-cero)
4. [Preparar el proyecto (una sola vez)](#4-preparar-el-proyecto-una-sola-vez)
5. [Trabajar día a día](#5-trabajar-día-a-día)
6. [Calidad y commits (obligatorio)](#6-calidad-y-commits-obligatorio)
7. [Solución de problemas](#7-solución-de-problemas)
8. [Más documentación](#8-más-documentación)

---

## 1. Cómo está organizado el repositorio

Es un **monorepo**: la app y el backend viven en el mismo repositorio.

| Carpeta / archivo | Qué contiene |
|---|---|
| [`app/`](app/README.md) | App móvil en **Flutter** (Android; iOS con el mismo código) |
| [`backend/`](backend/README.md) | API en **FastAPI** + **PostgreSQL**, migraciones con **Alembic** y scripts de ML |
| `docker-compose.yml` | Todos los servicios del servidor: PostgreSQL, migraciones, API, ML, n8n y Mailpit |
| [`docs/ESTANDARES.md`](docs/ESTANDARES.md) | Reglas del proyecto: idioma híbrido, arquitectura, migraciones, calidad |
| `scripts/` | Utilidades (por ejemplo, el verificador de cobertura de la app) |
| `data/` | Archivos locales (PDF descargados, imágenes); su contenido no se sube a Git |
| `package.json`, `.husky/`, `commitlint.config.mjs`, `.lintstagedrc.mjs` | Herramientas de calidad: hooks de Git, formato y commits convencionales |
| `.github/workflows/ci.yml` | Integración continua en GitHub |
| `.env.example` | Plantilla de variables de entorno (se copia a `.env`) |
| `AGENTS.md` | Reglas para asistentes de IA que trabajen en el repo |

```
Celular (app Flutter)  ──HTTP──▶  API FastAPI (Docker)  ──▶  PostgreSQL (Docker)
                                         ▲
                     n8n (Docker) ───────┘   recolección diaria de exámenes (scraping) y recalibración del modelo
```

---

## 2. Qué hay que instalar (resumen)

| Herramienta | Versión probada | Para qué se usa |
|---|---|---|
| **Git** | 2.5x | Clonar el repositorio y hacer commits |
| **Docker Desktop** (con Docker Compose) | Docker 29 · Compose 5 | Correr PostgreSQL, la API, n8n y Mailpit |
| **Python** | 3.13 | Backend y scripts de ML |
| **uv** | 0.12 | Instalar dependencias de Python y correr comandos del backend |
| **Node.js** | 22 o superior | Herramientas de calidad (hooks de Git, commitlint) |
| **pnpm** | 11 | Instalar las herramientas de calidad |
| **Flutter** (incluye Dart) | Flutter 3.50.1 · Dart 3.14 | App móvil |
| **Android Studio** | 2026.x | SDK de Android, emulador y componentes nativos |
| Componentes del SDK de Android | Plataforma **37**, **NDK 28.2.13676358**, Command-line Tools | Compilar la app para Android |

> Las instrucciones están pensadas para **Windows** (el equipo trabaja en Windows). En macOS o Linux los pasos son los mismos; solo cambia cómo se instala cada herramienta y cómo se edita el `PATH`.

---

## 3. Instalación paso a paso desde cero

Después de instalar cada herramienta, **cierra y vuelve a abrir la terminal** para que reconozca los comandos nuevos.

### 3.1 Git
1. Descarga e instala desde <https://git-scm.com/downloads>.
2. Verifica:
```bash
git --version
```
3. Configura tu nombre y correo (una sola vez por computadora):
```bash
git config --global user.name "Tu Nombre"
```
```bash
git config --global user.email "tu-correo@ejemplo.com"
```

### 3.2 Docker Desktop
1. Descarga e instala desde <https://www.docker.com/products/docker-desktop/>. En Windows deja activada la opción de **WSL 2**.
2. Abre Docker Desktop y espera a que diga que está corriendo.
3. Verifica:
```bash
docker --version
```
```bash
docker compose version
```

### 3.3 Python 3.13
1. Descarga e instala desde <https://www.python.org/downloads/>. En el instalador marca **"Add python.exe to PATH"**.
2. Verifica:
```bash
python --version
```

### 3.4 uv (gestor de Python)
1. Instala con el instalador oficial (PowerShell):
```bash
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```
2. Verifica:
```bash
uv --version
```

### 3.5 Node.js y pnpm
1. Instala Node.js (versión LTS) desde <https://nodejs.org/>.
2. Instala pnpm:
```bash
npm install -g pnpm
```
3. Verifica:
```bash
node --version
```
```bash
pnpm --version
```

### 3.6 Flutter
1. Descarga Flutter estable en tu carpeta de usuario (por ejemplo `C:\Users\<tu-usuario>\flutter`):
```bash
git clone --depth 1 -b stable https://github.com/flutter/flutter.git C:\Users\<tu-usuario>\flutter
```
2. Agrega `flutter\bin` al `PATH` de tu usuario (PowerShell; cambia `<tu-usuario>`):
```bash
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path","User") + ";C:\Users\<tu-usuario>\flutter\bin", "User")
```
3. **Cierra y abre la terminal** y verifica (la primera vez descarga Dart y el motor; tarda unos minutos):
```bash
flutter --version
```
4. Opcional: desactiva el envío de estadísticas de Flutter:
```bash
flutter --disable-analytics
```

### 3.7 Android Studio y componentes del SDK
1. Instala Android Studio desde <https://developer.android.com/studio> y ábrelo una vez para que descargue el SDK.
2. Abre el **SDK Manager**: en la pantalla de bienvenida, **More Actions → SDK Manager**; con un proyecto abierto, **File → Settings → Languages & Frameworks → Android SDK**.
3. Revisa que **Android SDK Location** sea `C:\Users\<tu-usuario>\AppData\Local\Android\Sdk`.
4. Pestaña **SDK Platforms**: marca **Android SDK Platform 37** (la exige el paquete de notificaciones).
5. Pestaña **SDK Tools**: marca **Show Package Details** y luego:
   - **Android SDK Command-line Tools (latest)**
   - **NDK (Side by side) → 28.2.13676358**
   - **Android SDK Platform-Tools**
6. Presiona **Apply** y espera a que termine.
7. Acepta las licencias de Android (responde `y` a cada una):
```bash
flutter doctor --android-licenses
```
8. Revisa que todo esté bien:
```bash
flutter doctor
```
Debe mostrar `[√]` en **Flutter** y **Android toolchain**.

### 3.8 Emulador o celular
- **Emulador:** en Android Studio, **Device Manager → Create Device**, elige un teléfono y una imagen de sistema reciente, y arráncalo.
- **Celular físico:** activa **Opciones de desarrollador → Depuración por USB** y conéctalo por cable. Verifica que aparezca con:
```bash
flutter devices
```

---

## 4. Preparar el proyecto (una sola vez)

### 4.1 Clonar
```bash
git clone <url-del-repositorio> Prepion
```
```bash
cd Prepion
```

### 4.2 Variables de entorno
Copia la plantilla y cambia la contraseña de PostgreSQL por una propia (en `POSTGRES_PASSWORD` **y** dentro de `DATABASE_URL`):
```bash
cp .env.example .env
```

| Variable | Para qué sirve |
|---|---|
| `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB` | Usuario, contraseña y nombre de la base que crea Docker |
| `DATABASE_URL` | Conexión del backend cuando se corre **desde la PC** (dentro de Docker, `docker-compose.yml` la arma solo) |

> `.env` **nunca** se sube a Git (está en `.gitignore`).

### 4.3 Herramientas de calidad y hooks de Git
Instala husky, lint-staged, commitlint y commitizen, y activa los hooks:
```bash
pnpm install
```

### 4.4 Dependencias del backend
```bash
cd backend
```
```bash
uv sync --all-groups
```
```bash
cd ..
```

### 4.5 Dependencias de la app
```bash
cd app
```
```bash
flutter pub get
```
```bash
cd ..
```

### 4.6 Levantar los servicios y crear la base de datos
```bash
docker compose up -d --build
```
Esto levanta, en orden: **postgres** → **migrate** (crea las tablas con Alembic y termina) → **api**, más **n8n** y **mailpit**.

| Servicio | Dirección | Para qué |
|---|---|---|
| API | <http://localhost:8800/api/health> | Debe responder `{"estado":"ok"}` |
| Documentación de la API | <http://localhost:8800/docs> | Probar endpoints desde el navegador |
| n8n | <http://localhost:5678> | Flujo programado que recolecta exámenes de la FCyT (ver [4.8](#48-recolección-automática-de-exámenes-n8n--scraping); crea tu usuario la primera vez) |
| Mailpit | <http://localhost:8525> | Ver los correos de prueba que envía el backend |
| PostgreSQL | `localhost:5432` | Conectar con un cliente de base de datos |

> En esta PC Windows reserva los puertos **7966–8065** (incluye 8000 y 8025). Por eso la API usa **8800** y Mailpit **8525**.

### 4.7 Verificar que todo funciona
```bash
pnpm run check
```
Corre formato, lint, tipos y pruebas con cobertura de backend y app. Si termina sin errores, el entorno está listo.


### 4.8 Recolección automática de exámenes (n8n + scraping)

La Facultad publica sus exámenes en <https://sagaa.fcyt.umss.edu.bo/admision/examenes.php>. Un flujo de **n8n** llama todos los días a las **03:00** (hora de La Paz) al endpoint `POST /api/examenes/recolectar` de la API, que lee esa página y **descarga a `data/examenes_pdf/` solo los PDF nuevos** (hasta 10 por corrida, de a uno y con pausas para no cargar el servidor de la Facultad).

**Activarlo (una vez):**
1. En `.env`, define `RECOLECCION_TOKEN` (clave que exige el endpoint; genera una con `python -c "import secrets; print(secrets.token_urlsafe(32))"`). Sin ella el endpoint responde 503.
2. Levanta la API y n8n: `docker compose up -d --build api n8n`.
3. Carga y activa los flujos guardados en `n8n/flujos/` (recolección y recalibración): `pnpm run n8n:importar`.

**Probarlo ahora:** abre <http://localhost:5678> (la primera vez crea tu usuario), entra al flujo **Recolección de exámenes FCyT** y pulsa *Execute workflow*; o desde la terminal: `docker compose exec -e N8N_RUNNERS_BROKER_PORT=5680 n8n n8n execute --id=recoleccion-examenes`. Verás los PDF nuevos en `data/examenes_pdf/`.

**Qué hace y qué no:**
- ✅ Recolecta: lee el catálogo, descarga solo lo nuevo, valida que cada URL sea del portal oficial y que el archivo sea un PDF (máx. 10 MB, sin seguir redirecciones).
- ❌ No extrae ni cura las preguntas: eso sigue siendo manual (extractor + CSV de curación, ver [`backend/README.md`](backend/README.md)), porque las respuestas hay que resolverlas y revisarlas entre personas.
- Si cambia el HTML de la página, el parser deja de encontrar filas y el flujo lo reporta con 0 exámenes.


### 4.9 Modelo de conocimiento (machine learning)

El servidor **aprende** y la app **usa** lo aprendido, también sin conexión:

```
n8n (cada día 03:30) ──▶ POST /api/conocimiento/recalibrar ──▶ calibra la dificultad de cada pregunta (IRT, Rasch 1PL)
                                                              └▶ guarda el paquete en `paquetes_conocimiento`
app ──▶ GET /api/paquetes-conocimiento/actual ──▶ caché local  >  paquete empaquetado en el APK  >  valores por defecto
```

- **Qué usa la app del paquete:** los parámetros **BKT por tema** (el nivel inicial de cada tema sale de la dificultad IRT de sus preguntas) en el panel de progreso, y la **dificultad de cada pregunta** para presentar primero las nuevas más fáciles dentro de cada materia. El panel muestra de qué versión y de qué origen son los datos.
- **Sin conexión o sin servidor** la app sigue igual: usa el último paquete descargado o el que viaja dentro del APK (`app/assets/datos/parametros_conocimiento.json`).
- ⚠️ **Honestidad sobre los datos:** mientras no exista la sincronización de respuestas (#8), el servidor no tiene respuestas reales y calibra con **respuestas simuladas** (origen `simulado`, 60 usuarios). Con respuestas reales de al menos 20 usuarios cambia solo a `real`. FSRS (repaso espaciado) y BKT (nivel) corren de verdad en el teléfono; el ajuste de BKT con pyBKT es trabajo futuro.
- Probar la recalibración ahora: `pnpm run n8n:importar`, luego en n8n ejecutar **Recalibración del modelo de conocimiento**, o `docker compose exec -e N8N_RUNNERS_BROKER_PORT=5680 n8n n8n execute --id=recalibrar-conocimiento`. Requiere un banco publicado: `cd backend && uv run python -m app.features.preguntas.infrastructure.cli publicar ../app/assets/datos/banco_semilla.json`.

---

## 5. Trabajar día a día

| Tarea | Comando |
|---|---|
| Levantar los servicios | `docker compose up -d` |
| Detenerlos | `docker compose stop` |
| Ver los logs de la API | `docker compose logs -f api` |
| Reconstruir tras cambiar dependencias del backend | `docker compose up -d --build` |
| Correr la app en el emulador | `cd app` y luego `flutter run` |
| Correr la app en un celular | `cd app` y luego `flutter run --dart-define=API_URL=http://<IP-de-tu-PC>:8800` |
| Crear una migración | ver [`backend/README.md`](backend/README.md#5-migraciones-alembic) |
| Tareas de ML bajo demanda | `docker compose run --rm ml <comando>` |
| Borrar la base y empezar de cero | `docker compose down -v` (⚠️ elimina todos los datos locales) |

**IP de tu PC:** en Windows, `ipconfig` → "Dirección IPv4" de tu red Wi-Fi. El celular debe estar en la **misma red**. Desde el **emulador** no hace falta: la app usa `http://10.0.2.2:8800` por defecto.

---

## 6. Calidad y commits (obligatorio)

Todo se valida automáticamente; nadie debe saltarse los hooks (`--no-verify`).

| Momento | Qué pasa |
|---|---|
| `git commit` | Se formatean y revisan **solo los archivos que cambiaste** (ruff para Python, `dart format` para Dart) y se valida el mensaje del commit |
| `git push` | Se corre `pnpm run check`: formato, lint, tipos, análisis y **pruebas unitarias con cobertura mínima del 80 %** |
| GitHub | La integración continua repite todo y prueba las migraciones |

### Cómo hacer un commit
```bash
git add .
```
```bash
pnpm run commit
```
El asistente pregunta el **tipo**, el **alcance** y la **descripción**, y arma el mensaje correcto:
```
feat(app): agregar pantalla de práctica diaria
```
- Tipos: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
- Alcances: `app`, `backend`, `ml`, `docker`, `ci`, `docs`, `deps`.
- Descripción en español y en minúscula, máximo 100 caracteres.

### Comandos de calidad
| Comando | Qué hace |
|---|---|
| `pnpm run format` | Formatea backend y app |
| `pnpm run lint` | Verifica formato, lint, tipos (mypy) y análisis de Flutter |
| `pnpm run test` | Pruebas de backend y app con cobertura mínima |
| `pnpm run check` | `lint` + `test` (lo mismo que corre al hacer push) |

---

## 7. Solución de problemas

| Problema | Causa | Solución |
|---|---|---|
| `flutter` / `uv` / `pnpm` "no se reconoce" | La terminal se abrió antes de instalar o de cambiar el `PATH` | Cierra y abre la terminal. En la misma sesión: `$env:Path += ";C:\Users\<tu-usuario>\flutter\bin"` |
| `flutter doctor`: "cmdline-tools component is missing" | Faltan las Command-line Tools | Instálalas desde el SDK Manager (paso 3.7) |
| `flutter doctor`: "Android license status unknown" | No se aceptaron las licencias | `flutter doctor --android-licenses` |
| El APK falla con "did not install NDK 28.2.13676358" | Falta el NDK | Instálalo desde SDK Tools con "Show Package Details" (paso 3.7) |
| El APK falla pidiendo `compileSdk 37` | Falta la plataforma 37 | Instálala desde SDK Platforms |
| Docker: "ports are not available … forbidden" | Windows tiene reservado ese puerto | Usa otro puerto en `docker-compose.yml` (por eso usamos 8800 y 8525). Ver reservas: `netsh interface ipv4 show excludedportrange protocol=tcp` |
| `docker compose` no responde | Docker Desktop no está abierto | Abre Docker Desktop y espera a que esté corriendo |
| La API no arranca y `migrate` termina con error | Una migración falló o la base tiene otra contraseña | `docker compose logs migrate`. Si cambiaste la contraseña después de crear la base: `docker compose down -v` y vuelve a levantar |
| La app en el celular no llega a la API | IP equivocada o redes distintas | Usa la IP de tu PC con `--dart-define=API_URL=...` y conecta ambos a la misma Wi-Fi |
| El commit es rechazado | El mensaje no sigue el formato | Usa `pnpm run commit` |
| `pyBKT` falla al importarse | Versión de scikit-learn incompatible | Ya está fijado `scikit-learn<1.8`; vuelve a correr `uv sync --all-groups` |

---

## 8. Más documentación

- [`app/README.md`](app/README.md): arquitectura, paquetes y comandos de la app.
- [`backend/README.md`](backend/README.md): arquitectura, migraciones, ML y comandos del backend.
- [`docs/ESTANDARES.md`](docs/ESTANDARES.md): idioma híbrido, arquitectura, base de datos, Docker y calidad.

## Fuente de las preguntas

[Exámenes pasados de la FCyT](https://sagaa.fcyt.umss.edu.bo/admision/examenes.php). Uso educativo y gratuito; cada pregunta cita su examen de origen.
