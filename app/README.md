# Prepion — App móvil (Flutter)

App de práctica diaria para el examen de ingreso a la FCyT. Funciona **sin internet**: el banco de preguntas, el progreso y los recordatorios viven en el celular; el backend solo sincroniza. Antes de empezar, sigue la instalación del [README general](../README.md).

---

## Índice
1. [Requisitos](#1-requisitos)
2. [Instalación y configuración](#2-instalación-y-configuración)
3. [Correr la app](#3-correr-la-app)
4. [Compilar el APK](#4-compilar-el-apk)
5. [Arquitectura por features](#5-arquitectura-por-features)
6. [Cómo agregar algo nuevo](#6-cómo-agregar-algo-nuevo)
7. [Base local (drift) y código generado](#7-base-local-drift-y-código-generado)
8. [Pruebas y calidad](#8-pruebas-y-calidad)
9. [Configuración de Android](#9-configuración-de-android)
10. [Paquetes](#10-paquetes)

---

## 1. Requisitos
| Herramienta | Versión |
|---|---|
| Flutter (incluye Dart) | 3.50.1 · Dart 3.14 |
| Android Studio + SDK | Plataforma **37**, **NDK 28.2.13676358**, Command-line Tools, licencias aceptadas |
| Emulador o celular Android | Con depuración por USB si es físico |

`flutter doctor` debe mostrar `[√]` en **Flutter** y **Android toolchain**.

## 2. Instalación y configuración

Desde `app/`:
```bash
flutter pub get
```

### URL del backend
La app lee la URL del backend al compilar, con `--dart-define`:

| Dónde corre la app | Qué pasar |
|---|---|
| Emulador de Android | Nada: usa `http://10.0.2.2:8800` por defecto (`10.0.2.2` es tu PC vista desde el emulador) |
| Celular físico | `--dart-define=API_URL=http://<IP-de-tu-PC>:8800` (misma Wi-Fi) |
| Demo (túnel) | `--dart-define=API_URL=https://<url-del-tunel>` |

Se define en `lib/shared/config/app_config.dart`. El cliente HTTP (`lib/shared/network/api_client.dart`) agrega el prefijo `/api`.

> El HTTP sin cifrar hacia tu PC solo está permitido en **debug** (`android/app/src/debug/AndroidManifest.xml`).

## 3. Correr la app
Con el backend levantado (`docker compose up -d` en la raíz):

| Caso | Comando (desde `app/`) |
|---|---|
| Emulador | `flutter run` |
| Celular físico | `flutter run --dart-define=API_URL=http://<IP-de-tu-PC>:8800` |
| Ver dispositivos conectados | `flutter devices` |

Durante `flutter run`: `r` recarga en caliente, `R` reinicia y `q` sale.

## 4. Compilar el APK
| Tipo | Comando (desde `app/`) | Resultado |
|---|---|---|
| Debug | `flutter build apk --debug` | `build/app/outputs/flutter-apk/app-debug.apk` |
| Release | `flutter build apk --release` | `build/app/outputs/flutter-apk/app-release.apk` |

Si falla pidiendo el **NDK 28.2.13676358** o la **plataforma 37**, instálalos desde el SDK Manager de Android Studio ([README general, paso 3.7](../README.md#37-android-studio-y-componentes-del-sdk)).

> **iOS:** el mismo código sirve para iPhone, pero compilarlo requiere una Mac y publicarlo, una cuenta de desarrollador de Apple de pago. Queda para una versión futura.

## 5. Arquitectura por features

```
app/lib/
├── main.dart                    arranque: ProviderScope + PrepionApp
├── app/
│   ├── prepion_app.dart         MaterialApp.router y tema
│   └── router.dart              rutas (go_router)
├── shared/                      lo común a todas las features
│   ├── config/app_config.dart   API_URL
│   ├── network/api_client.dart  cliente Dio + clienteApiProvider
│   └── database/app_database.dart   base local drift + appDatabaseProvider
└── features/<feature>/
    ├── data/                    fuentes de datos, modelos, repositorios
    ├── domain/                  entidades y reglas puras (Dart puro, sin Flutter)
    └── presentation/            pages/, widgets/, providers/ (Riverpod)

app/test/                        espejo de lib/
```

- **Dependencias:** `presentation → domain ← data`. `domain` no importa Flutter, drift ni dio, así se prueba sin emulador.
- Una feature **no importa el interior de otra**; lo compartido va a `shared/`, y `shared/` no importa features.
- **Features previstas:** `inicio`, `practica`, `progreso`, `configuracion`, `cuentas`, `sincronizacion`.
- **Estado:** Riverpod (`flutter_riverpod`). **Navegación:** go_router.
- **Idioma híbrido:** dominio en español (`obtenerPreguntas`, `TarjetaPregunta`, `preguntasDelDiaProvider`), estructura técnica en inglés (`presentation`, `widgets`). Detalle en [`docs/ESTANDARES.md`](../docs/ESTANDARES.md).

## 6. Cómo agregar algo nuevo

### Una pantalla
1. Página en `lib/features/<feature>/presentation/pages/<nombre>_page.dart`.
2. Ruta en `lib/app/router.dart`.
3. Prueba de widget en `test/features/<feature>/presentation/pages/`.

### Una regla de negocio (por ejemplo, el modelo de conocimiento)
1. Dart puro en `lib/features/<feature>/domain/`.
2. Prueba unitaria en `test/features/<feature>/domain/`, con casos calculados a mano.

### Un dato del backend
1. Llamada en `lib/features/<feature>/data/` usando `clienteApiProvider`.
2. Convierte el JSON a entidades del dominio antes de llegar a la pantalla.

## 7. Base local (drift) y código generado
- La base vive en `lib/shared/database/app_database.dart` (esquema versión 1). Cada feature agrega sus tablas en `@DriftDatabase(tables: [...])`.
- Al cambiar el esquema: sube `schemaVersion` y agrega su migración en drift.
- Tras cambiar tablas o modelos con anotaciones, regenera el código:
```bash
dart run build_runner build --delete-conflicting-outputs
```
- Los archivos generados (`*.g.dart`, `*.freezed.dart`) **se suben a Git** y no se editan a mano.

## 8. Pruebas y calidad

| Comando (desde `app/`) | Qué hace |
|---|---|
| `flutter test` | Pruebas unitarias y de widgets |
| `flutter test --coverage` | Igual, generando `coverage/lcov.info` |
| `dart format lib test` | Formatea el código |
| `flutter analyze --fatal-infos` | Análisis estricto; cualquier aviso es error |

Desde la raíz:
```bash
pnpm run test:app
```
Corre las pruebas y **falla si la cobertura baja del 80 %** (sin contar `main.dart` ni archivos generados).

- Pruebas en español con estructura **AAA**: `test('devuelve … cuando …', () { … })`.
- Reglas activas: `strict-casts`, `strict-inference`, `strict-raw-types`, comillas simples, imports con `package:`, sin `print`, `final` en variables locales y futures no ignorados (`analysis_options.yaml`).

## 9. Configuración de Android
Ya está hecha; esto explica qué hay y por qué.

| Archivo | Configuración | Motivo |
|---|---|---|
| `android/app/build.gradle.kts` | `compileSdk` ≥ 37 | Lo exige `flutter_local_notifications` 23 |
| `android/app/build.gradle.kts` | Desugaring + `desugar_jdk_libs` y `multiDexEnabled` | Requerido por las notificaciones programadas |
| `android/app/src/main/AndroidManifest.xml` | Permisos `INTERNET` y `RECEIVE_BOOT_COMPLETED` | Llamar al backend y reprogramar el recordatorio tras reiniciar |
| `android/app/src/main/AndroidManifest.xml` | Receptores `ScheduledNotificationReceiver` y `ScheduledNotificationBootReceiver` | Mostrar las notificaciones programadas |
| `android/app/src/debug/AndroidManifest.xml` | `usesCleartextTraffic="true"` | HTTP hacia el backend local, solo en debug |
| Identificador | `com.prepion.prepion` | Paquete de la app |

## 10. Paquetes

| Paquete | Uso |
|---|---|
| `go_router` | Navegación |
| `flutter_riverpod` | Estado |
| `drift`, `drift_flutter`, `path_provider`, `path` | Base de datos local (SQLite) |
| `shared_preferences` | Preferencias simples (hora del recordatorio, preguntas por día) |
| `flutter_local_notifications`, `timezone`, `flutter_timezone` | Recordatorio diario sin servidor |
| `fsrs` | Repetición espaciada |
| `fl_chart` | Gráficos de progreso |
| `dio` | Llamadas al backend |
| `flutter_secure_storage` | Guardar la sesión de forma cifrada |
| `connectivity_plus` | Saber si hay internet para sincronizar |
| `uuid` | Identificadores (anónimo, eventos de respuesta) |
| `json_annotation`, `freezed_annotation` | Modelos JSON e inmutables |
| `build_runner`, `drift_dev`, `json_serializable`, `freezed` | Generación de código (solo desarrollo) |
| `flutter_lints` | Reglas de análisis |

Agregar un paquete:
```bash
flutter pub add <paquete>
```
Para desarrollo:
```bash
flutter pub add --dev <paquete>
```
