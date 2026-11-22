# Historias de Usuario (HUs) e Issues — Prepion

Documento oficial de historias de usuario y división de trabajo Frontend / Backend para el equipo de desarrollo de **Prepion** (Hackaton Abstracthon 2026 · Track 02 Educación).

Basado en la arquitectura hexagonal + features del backend, arquitectura por features de Flutter, y los estándares de [`docs/ESTANDARES.md`](ESTANDARES.md). Diseño visual: [`docs/brand_ui_design_system_skill.md`](brand_ui_design_system_skill.md).

---

## 👥 Reparto del Equipo de Desarrollo (5 Integrantes)

> Completar la columna **Integrante** con el usuario de GitHub de cada uno, y asignar los issues en GitHub. Para poder asignarlos, cada integrante debe ser colaborador del repositorio.

| Rol | Integrante (GitHub) | Rol Principal | Módulos y Tecnologías |
|---|---|---|---|
| **Persona 1** | _por definir_ | Machine Learning & Extracción | Extracción de PDF con PyMuPDF, recorte de fórmulas, scripts IRT (`girth`) y BKT (`pyBKT`), recalibración del servidor en Docker (`ml`). |
| **Persona 2** | _por definir_ | Curación del Banco de Preguntas | Revisión, resolución y verificación cruzada de respuestas (Google Sheets/CSV), exportación a JSON (`banco_v1.json`), control de calidad pedagógico. |
| **Persona 3** | _por definir_ | Frontend: UI, Flujos y Navegación | Pantallas Flutter (Onboarding, Práctica, Catálogo, Métricas con `fl_chart`, Auth), componentes visuales, `go_router`, tema según el design system y accesibilidad. |
| **Persona 4** | _por definir_ | Frontend: Datos Locales, FSRS y Notificaciones | Base de datos local Drift (`app_database.dart`), algoritmo FSRS (`fsrs 2.0.1`), BKT local, `flutter_local_notifications`, cola offline. |
| **Persona 5** | _por definir_ | Backend: API FastAPI, BD, Auth y Docker | Endpoints FastAPI, SQLModel, PostgreSQL 16, migraciones Alembic, autenticación (Argon2 + PyJWT), sincronización en lote, soporte de Docker y pitch. |

**Antes de empezar, cada integrante:** clona el repo y corre `pnpm install` (activa los hooks de formato y commits), `flutter pub get` en `app/` y `uv sync --all-groups` en `backend/`. Ver el [README general](../README.md).

---

## 📐 Contrato común de la API (aplica a todas las historias)

Para que frontend y backend hablen el mismo idioma:

| Tema | Regla |
|---|---|
| Prefijo | Todas las rutas bajo `/api`; recursos en español, plural y `kebab-case` (`/api/paquetes-conocimiento`) |
| JSON | Campos en `camelCase` y en español (`idEvento`, `preguntaId`, `esCorrecta`, `tiempoMs`, `respondidaEn`). En la base de datos las columnas siguen en `snake_case` |
| Identidad | **Siempre con token**: el usuario anónimo recibe uno al abrir la app (`POST /api/auth/anonimo`, HU-02); el usuario con cuenta, al iniciar sesión (HU-07). Se envía como `Authorization: Bearer <token>` y el backend obtiene el usuario **del token**, nunca de un campo que mande el cliente |
| Errores | Errores de dominio en español → `application/problem+json` (RFC 9457) |
| Cliente HTTP | `clienteApiProvider` (`lib/shared/network/api_client.dart`): conexión 10 s, respuesta 30 s |
| Tiempo | Fechas en ISO 8601 UTC |
| Cambios de tablas | Toda columna nueva va en una **migración Alembic nueva** (nunca se edita la inicial) |

---

## 🗺️ Matriz del Backlog y Prioridades

| Código | Issue | Título | Front | Back / ML | Prioridad | Estimación | Responsable | Estado |
|---|---|---|---|---|---|---|---|---|
| **HU-01** | [#1](https://github.com/WilHacker/Prepion/issues/1) | Banco de Preguntas Oficiales y Curadas | Persona 4 & 2 | Persona 1 & 2 | 🟢 MVP | 8 pts | `WilHacker` | En revisión (faltan 2 firmas) |
| **HU-02** | [#2](https://github.com/WilHacker/Prepion/issues/2) | Onboarding y Configuración de Estudio sin Fricción | Persona 3 | Persona 5 | 🟢 MVP | 3 pts | `camilonogales96` | Cerrado |
| **HU-03** | [#3](https://github.com/WilHacker/Prepion/issues/3) | Práctica Diaria Inteligente y Repaso Espaciado (FSRS) | Persona 3 & 4 | Persona 5 | 🟢 MVP | 13 pts | `WilHacker` | Cerrado |
| **HU-04** | [#4](https://github.com/WilHacker/Prepion/issues/4) | Recordatorios Diarios y Notificaciones Locales Offline | Persona 4 & 3 | — | 🟢 MVP | 3 pts | `camilonogales96` | Abierto |
| **HU-05** | [#5](https://github.com/WilHacker/Prepion/issues/5) | Práctica Libre por Materia y Tema Específico | Persona 3 & 4 | Persona 5 | 🟢 MVP | 5 pts | `giulilvsmrk` | Abierto |
| **HU-06** | [#6](https://github.com/WilHacker/Prepion/issues/6) | Panel de Progreso, Nivel de Preparación y Métricas | Persona 3 & 4 | Persona 1 | 🟢 MVP | 8 pts | `WilHacker` | Cerrado |
| **HU-07** | [#7](https://github.com/WilHacker/Prepion/issues/7) | Autenticación con Correo, Respaldo y Código de Recuperación | Persona 3 | Persona 5 | 🟡 MVP Secundario | 8 pts | `alejandroRaynerIllanes` | Abierto |
| **HU-08** | [#8](https://github.com/WilHacker/Prepion/issues/8) | Sincronización Bidireccional Offline-First | Persona 4 | Persona 5 & 1 | 🟡 MVP Secundario | 8 pts | `jhoanclaure` | Abierto |
| **HU-09** | [#9](https://github.com/WilHacker/Prepion/issues/9) | Sistema de Reporte de Errores en Preguntas | Persona 3 & 4 | Persona 5 | 🟡 Secundario / Demo | 3 pts | `jhoanclaure` | Abierto |
| **Fix Auth** | [#11](https://github.com/WilHacker/Prepion/issues/11) | Reemplazar cabecera `X-Usuario-Id` por token JWT anónimo | Persona 4 | Persona 5 | 🟢 MVP (Seguridad) | — | _por asignar_ | Abierto |

---

## Detalle de Historias de Usuario

---

### HU-01: Extracción, Curación y Carga Inicial del Banco de Preguntas

- **Prioridad:** 🟢 MVP (Imprescindible para la demo)
- **Casos de Uso Relacionados:** CU-P02, CU-P03, CU-P05, CU-P06, CU-P07, CU-P08, CU-P09
- **Etiquetas en GitHub:** `hu`, `frontend`, `backend`, `ml`, `mvp`

#### Historia
> **Como** curador pedagógico y estudiante postulante,  
> **Quiero** disponer de un banco de preguntas reales extraídas de exámenes de la FCyT (empezando por 2026-2-1op) con respuestas verificadas y fórmulas correctamente renderizadas,  
> **Para** practicar con preguntas oficiales, confiables y con formato idéntico al examen de admisión.

#### 📱 Componente Frontend (Flutter) — Asignados: Persona 4 & Persona 2
1. **Esquema Drift Local:** Definir tablas `examenes`, `temas`, `preguntas` en `lib/shared/database/app_database.dart` con soporte de claves primarias UUID, campos de texto, opciones múltiples (A–E), ruta o URI de imagen para fórmulas, explicación didáctica y cita de fuente. Subir `schemaVersion` y regenerar con `build_runner`.
2. **Semilla Inicial (Offline-First):** Crear servicio de carga inicial en `lib/features/practica/data/banco_local_service.dart` que al primer inicio de la app importe `assets/datos/banco_semilla.json` a la base de datos local Drift en una transacción rápida (<500 ms).
3. **Renderizado de Fórmulas e Imágenes:** Componente `TarjetaEnunciado` capaz de alternar entre texto simple y renderizado de imágenes recortadas (`Image.asset` o `Image.file`, con zoom vía `InteractiveViewer`) cuando el campo `rutaImagen` esté presente.

#### ⚙️ Componente Backend & ML (FastAPI / Python) — Asignados: Persona 1 & Persona 2
1. **Extractor de PDF con PyMuPDF (`backend/app/features/examenes`):** Adaptador en `infrastructure/adapters/` ejecutado en el contenedor `ml` que lee `data/examenes_pdf/2026-2-1op.pdf`, detecta secciones (Biología, Química, Aritmética-Álgebra, Geometría-Trigonometría, Física), extrae enunciados/opciones y recorta las áreas con fórmulas matemáticas a imágenes PNG optimizadas en `data/imagenes/`.
2. **Generador y Validador del Banco JSON:** Script de exportación que toma las respuestas curadas (doble verificación en Google Sheets o CSV) y genera `banco_v1.json` validando tipos con Pydantic. Solo exporta preguntas en estado `publicada`.
3. **Endpoint HTTP de Consulta:** En `features/preguntas/infrastructure/http/router.py`:
   - `GET /api/preguntas/banco/actual` → devuelve la versión actual del banco (`version`, `cantidad`, `publicadaEn`).
   - `GET /api/preguntas/banco/descargar/{version}` → descarga del archivo JSON completo.

#### ✅ Criterios de Aceptación
- [ ] Al menos 1 examen oficial (40 preguntas de 2026-2-1op) curado: Biología y Química en texto limpio, Matemáticas con fórmulas recortadas legibles.
- [ ] Todas las preguntas incluidas tienen respuesta correcta verificada por dos personas y explicación de 1–3 líneas.
- [ ] La app en frío abre y carga el banco local sin conexión a internet ni llamadas de red.
- [ ] Cada pregunta muestra claramente su fuente oficial (ej. *"Examen de ingreso FCyT · 1.ª opción · 2-2026 · pregunta B18"*).

---

### HU-02: Onboarding, Configuración de Metas y Acceso sin Fricción

- **Prioridad:** 🟢 MVP
- **Casos de Uso Relacionados:** CU-E01, CU-E14, CU-E16
- **Etiquetas en GitHub:** `hu`, `frontend`, `backend`, `mvp`

#### Historia
> **Como** nuevo postulante a la universidad,  
> **Quiero** abrir la app, entender su propósito, configurar mi fecha de examen y meta diaria de preguntas, y empezar a practicar de inmediato sin estar obligado a registrarme,  
> **Para** no perder tiempo en formularios y comenzar a estudiar en menos de un minuto.

#### 📱 Componente Frontend (Flutter) — Asignado: Persona 3
1. **Vistas de Bienvenida:** Crear `OnboardingPage` en `lib/features/inicio/presentation/pages/onboarding_page.dart` con carrusel explicativo conciso (enfoque FCyT, práctica inteligente, 100% offline).
2. **Configurador de Metas:** Selector interactivo:
   - Fecha tentativa de examen (DatePicker).
   - Meta diaria: chips de selección rápida (5, 10 o 20 preguntas al día).
   - Hora habitual de estudio (TimePicker).
3. **Acceso Anónimo Predeterminado:** Botón principal *"Empezar a practicar ahora"*: la app entra **de inmediato** a la vista principal (no espera al servidor). En segundo plano, cuando haya internet, llama a `POST /api/auth/anonimo` y guarda el **token** y el **código de recuperación** en `flutter_secure_storage`. Las preferencias (fecha, meta, hora) van en `shared_preferences`. Opción secundaria *"Ya tengo cuenta / Iniciar sesión"*.

#### ⚙️ Componente Backend (FastAPI) — Asignado: Persona 5
1. **Usuario Anónimo con Token (`features/auth`):** `POST /api/auth/anonimo` crea una fila en `usuarios` con `es_anonimo = true` y devuelve `{ "usuarioId", "token", "codigoRecuperacion" }`. El token (JWT) identifica al usuario en todas las demás llamadas; **no se acepta un identificador enviado libremente por el cliente** (así nadie puede escribir datos a nombre de otro).
2. **Parámetros Públicos:** Endpoint `GET /api/configuracion/parametros-publicos` que devuelve fechas tentativas de admisión y rangos recomendados de preguntas diarias.

#### ✅ Criterios de Aceptación
- [ ] El postulante entra a la pantalla de estudio en menos de 3 toques de pantalla desde la instalación.
- [ ] No se exige ningún dato personal (ni correo, ni nombre, ni teléfono, ni carnet).
- [ ] Sin internet, la app funciona igual; el registro anónimo se completa cuando vuelve la conexión.
- [ ] La configuración elegida persiste localmente y se puede modificar posteriormente en Ajustes.

---

### HU-03: Práctica Diaria Inteligente y Repetición Espaciada (FSRS)

- **Prioridad:** 🟢 MVP
- **Casos de Uso Relacionados:** CU-E04, CU-E05, CU-E06, CU-E14
- **Etiquetas en GitHub:** `hu`, `frontend`, `backend`, `mvp`

#### Historia
> **Como** postulante que busca maximizar su retención,  
> **Quiero** recibir una sesión de práctica diaria adaptativa que combine preguntas para repasar (según el algoritmo FSRS) y preguntas nuevas de mis temas más flojos, recibiendo retroalimentación inmediata,  
> **Para** afianzar conceptos difíciles antes del examen y recordar lo aprendido a largo plazo.

#### 📱 Componente Frontend (Flutter) — Asignados: Persona 3 & Persona 4
1. **UI de Práctica (`features/practica/presentation/`):**
   - `PracticaPage`: barra de progreso superior (ej. 3/10), botón salir con confirmación.
   - `TarjetaPregunta`: render del enunciado, imagen si aplica, y opciones (A, B, C, D, E) en botones grandes y accesibles.
   - Botón *"No sé"* para evitar adivinaciones que distorsionen el modelo.
   - `HojaExplicacion`: modal o panel inferior que aparece al responder, coloreando verde (acierto) o rojo (fallo), mostrando la respuesta correcta, la explicación pedagógica y el botón *"Siguiente"*. **Si acertó**, muestra además dos botones opcionales: *"Me costó"* y *"Fue fácil"*.
   - `ResumenSesionPage`: pantalla final con métricas de la sesión (aciertos/fallos, tiempo total, racha de días actualizada).
2. **Lógica de Repetición Espaciada FSRS en Dart puro (`features/practica/domain/`):**
   - Integración con el paquete `fsrs: ^2.0.1`.
   - Mapeo de la respuesta a la calificación FSRS:

     | Respuesta del postulante | Calificación FSRS |
     |---|---|
     | Incorrecta o *"No sé"* | `Again` |
     | Correcta y tocó *"Me costó"* | `Hard` |
     | Correcta sin tocar nada (o pasó a *"Siguiente"*) | `Good` |
     | Correcta y tocó *"Fue fácil"* | `Easy` |

   - Cálculo del nuevo estado (Estabilidad $S$, Dificultad $D$, Próximo Repaso en días).
   - Guardado local en tabla Drift `tarjetas_fsrs` y registro del evento en `respuestas_locales` (con `idEvento` UUID) para enviarlo luego en lote (HU-08).

#### ⚙️ Componente Backend (FastAPI) — Asignado: Persona 5
1. **Recepción de Respuestas:** Se usa el endpoint de lote de la HU-08, `POST /api/sincronizacion/lote` (no hay un endpoint aparte). Cada evento: `{ "idEvento", "preguntaId", "opcionElegida", "esCorrecta", "tiempoMs", "respondidaEn" }`; el usuario sale del token.
2. **Persistencia SQLModel:** Tabla `respuestas` de PostgreSQL con clave primaria `id_evento` provista por el cliente para evitar duplicados. **Migración nueva** para agregar la columna `opcion_elegida` (la migración inicial no la tiene).

#### ✅ Criterios de Aceptación
- [ ] La sesión presenta exactamente la cantidad de preguntas fijada en la meta diaria del usuario.
- [ ] Al seleccionar una opción, se congela la interacción y se muestra inmediatamente la explicación didáctica y la clave correcta.
- [ ] Las preguntas falladas se reprograman para intervalos cortos (1 día), mientras que las acertadas amplían su intervalo según FSRS.
- [ ] La sesión funciona en su totalidad con el dispositivo en modo avión (sin internet).

---

### HU-04: Recordatorios Diarios y Notificaciones Locales Offline

- **Prioridad:** 🟢 MVP
- **Casos de Uso Relacionados:** CU-E03, CU-E16
- **Etiquetas en GitHub:** `hu`, `frontend`, `mvp`

#### Historia
> **Como** postulante ocupado,  
> **Quiero** recibir una notificación local en mi teléfono a la hora programada recordándome hacer mi práctica diaria de 5 a 10 minutos,  
> **Para** construir un hábito de estudio constante y no perder mi racha de preparación.

#### 📱 Componente Frontend (Flutter) — Asignados: Persona 4 & Persona 3
1. **Servicio de Notificaciones Locales (`lib/shared/notifications/`, lo usan varias features):**
   - Configuración de `flutter_local_notifications`. En Android 13+ se pide al usuario el permiso de notificaciones (`POST_NOTIFICATIONS`) en tiempo de ejecución.
   - **Alarma inexacta** (`AndroidScheduleMode.inexactAllowWhileIdle`): para un recordatorio diario basta y **no requiere** el permiso `SCHEDULE_EXACT_ALARM`, que en Android 14 obliga a mandar al usuario a Ajustes.
   - Inicialización de zonas horarias con `timezone` y `flutter_timezone`.
   - Programación de alarma diaria recurrente a la hora seleccionada por el postulante: *"Tus 10 preguntas de hoy te esperan (5 min)"*.
   - Cancelación o postergación automática si el usuario ya completó su sesión del día antes de la hora configurada.
   - Ya configurado en Android: desugaring, `compileSdk` 37, permiso `RECEIVE_BOOT_COMPLETED` y receptores para reprogramar tras reiniciar (ver [`app/README.md`](../app/README.md#9-configuración-de-android)).
2. **Deep Linking Local:** Al tocar la notificación, la app debe abrirse directamente en la ruta `/practica` de `go_router`.
3. **Control en Ajustes:** Switch para activar/desactivar recordatorios y selector de hora en `ConfiguracionPage` (feature `configuracion`).

#### ⚙️ Componente Backend
- *No requiere infraestructura de backend (100% local, costo cero, sin cuotas de Firebase Cloud Messaging).*

#### ✅ Criterios de Aceptación
- [ ] La notificación se dispara a la hora configurada (con unos minutos de margen, propio de la alarma inexacta) incluso con la app cerrada y sin conexión a internet.
- [ ] Al pulsar la notificación, la app abre directamente la pantalla de práctica diaria.
- [ ] Si el usuario ya practicó hoy, la notificación de ese día se omite o indica felicitación por racha.

---

### HU-05: Práctica Libre por Materia y Tema Específico

- **Prioridad:** 🟢 MVP
- **Casos de Uso Relacionados:** CU-E07
- **Etiquetas en GitHub:** `hu`, `frontend`, `backend`, `mvp`

#### Historia
> **Como** postulante que necesita reforzar un área específica,  
> **Quiero** poder explorar el catálogo de materias de la FCyT (Matemáticas, Física, Química, Biología) y elegir un tema particular para practicar preguntas solo de ese tema,  
> **Para** prepararme para un tema concreto que estoy cursando o en el que me siento inseguro.

#### 📱 Componente Frontend (Flutter) — Asignados: Persona 3 & Persona 4
1. **Navegación y Catálogo:**
   - Vista `CatalogoMateriasPage` con tarjetas visuales por materia (iconos, color distintivo, cantidad de preguntas disponibles).
   - Vista `TemasPorMateriaPage` con listado de temas (ej. en Química: Estequiometría, Gases, Enlace químico, Soluciones) y porcentaje de dominio actual del usuario.
   - Los datos salen de la base local Drift (funciona sin internet).
2. **Modo Práctica Libre:**
   - Permite lanzar una sesión filtrando por `materia` y `temaId`.
   - Muestra preguntas en modo entrenamiento continuo sin límite estricto de 10 preguntas.
   - Las respuestas actualizan el dominio del tema en Drift pero no interfieren negativamente con la cola FSRS de la práctica diaria programada.

#### ⚙️ Componente Backend (FastAPI) — Asignado: Persona 5
La tabla `temas` pertenece a la feature **`preguntas`**, y la materia es un **texto** (columna `materia`), no una tabla aparte. Ambos endpoints van en `features/preguntas/infrastructure/http/router.py`:
1. **Árbol Temático:** `GET /api/temas` → materias con sus temas: `[{ "materia": "Química", "temas": [{ "temaId", "nombre" }] }]`.
2. **Filtro de Preguntas:** `GET /api/preguntas?materia=Química&temaId={uuid}` → preguntas publicadas para previsualización o administración.

#### ✅ Criterios de Aceptación
- [ ] El postulante puede navegar a cualquier materia y ver la lista completa de sus temas asociados.
- [ ] Puede iniciar una tanda de preguntas exclusivas del tema elegido.
- [ ] Cada respuesta muestra la clave correcta y la explicación oficial.

---

### HU-06: Panel de Progreso, Nivel de Preparación y Métricas Visuales

- **Prioridad:** 🟢 MVP
- **Casos de Uso Relacionados:** CU-E09, CU-E11
- **Etiquetas en GitHub:** `hu`, `frontend`, `backend`, `ml`, `mvp`

#### Historia
> **Como** postulante que desea medir su avance,  
> **Quiero** ingresar a un panel de progreso que me muestre gráficos de dominio por materia, mi racha de días, los temas críticos que más me bajan el puntaje y una estimación de mi nivel de preparación,  
> **Para** tener claridad sobre mis fortalezas y debilidades sin falsas expectativas ni promesas engañosas.

#### 📱 Componente Frontend (Flutter) — Asignados: Persona 3 & Persona 4
1. **Diseño Visual con `fl_chart` (`features/progreso/presentation/`):**
   - `ProgresoPage`: tarjeta principal con medidor de nivel estimado (Bajo / Medio / Alto) acompañado de advertencia ética (*"Estimación basada en tu práctica; no garantiza la admisión"*).
   - Gráfico de barras o radar con el dominio porcentual en las 5 áreas del examen.
   - Indicador de racha activa (días seguidos practicando con icono de fuego).
   - Sección *"Temas que debes reforzar"*: lista de los 3 temas con menor probabilidad de dominio $P(L_t)$.
   - Contador de días restantes para el examen de admisión de la FCyT.
2. **Motor BKT Local (Bayesian Knowledge Tracing):**
   - Cálculo en Dart puro en `features/progreso/domain/bkt_servicio.dart`.
   - Actualización de $P(L_t)$ tras cada respuesta. **Parámetros iniciales** (por calibrar; los mismos de la referencia técnica del equipo): $P(L_0)=0.3$, $P(T)=0.1$, $P(G)=0.2$ (5 opciones), $P(S)=0.1$. Cuando llegue el paquete de conocimiento del servidor (HU-08), se usan sus valores por tema.

#### ⚙️ Componente Backend & ML (Python) — Asignado: Persona 1
1. **Calibración IRT con `girth` en Contenedor `ml`:** Script que procesa matrices de aciertos de preguntas y estima la dificultad real $b_i$ de cada ítem. **MVP con el modelo de 1 parámetro (Rasch, 1PL)**, que necesita menos datos; pasar a 2PL cuando haya suficientes respuestas. Para la demo, con respuestas simuladas.
2. **Exportación de Parámetros de Referencia:** Generación de `parametros_conocimiento_v1.json` con la dificultad por pregunta y los parámetros BKT por tema (`pyBKT`), publicado como paquete de conocimiento (HU-08).

#### ✅ Criterios de Aceptación
- [ ] El panel de progreso se actualiza reactivamente tan pronto como el estudiante termina una sesión de preguntas.
- [ ] Los gráficos de `fl_chart` son fluidos, legibles y usan la paleta del design system (base oscura `#0B1320`).
- [ ] Se destacan con semáforo (rojo/amarillo/verde) los temas que requieren atención inmediata.

---

### HU-07: Autenticación con Correo, Respaldo y Código de Recuperación

- **Prioridad:** 🟡 MVP Secundario (Siguiente bloque)
- **Casos de Uso Relacionados:** CU-E17, CU-E19, CU-E20, CU-E21, CU-E23
- **Etiquetas en GitHub:** `hu`, `frontend`, `backend`

#### Historia
> **Como** postulante que cambia de dispositivo o quiere asegurar su historial,  
> **Quiero** poder crear una cuenta con correo y contraseña propia (o usar un código de recuperación anónimo tipo `FCYT-XXXX-XXXX`),  
> **Para** respaldar mi progreso en el servidor y restaurarlo en otro teléfono sin depender de Google ni servicios externos.

#### 📱 Componente Frontend (Flutter) — Asignado: Persona 3
1. **Flujo de Cuentas (`features/cuentas/presentation/`):**
   - Pantalla `RegistroPage` y `LoginPage` con validaciones en tiempo real (correo válido, contraseña $\ge 8$ caracteres).
   - Manejo de token JWT mediante `flutter_secure_storage`.
   - `CodigoRecuperacionDialog`: muestra y permite copiar el código anónimo recibido en HU-02.
   - Al registrarse siendo anónimo, se vincula el historial con la nueva cuenta sin duplicar respuestas.

#### ⚙️ Componente Backend (FastAPI) — Asignado: Persona 5
1. **Endpoints de Auth (`features/auth/infrastructure/http/router.py`):**
   - `POST /api/auth/anonimo`: definido en HU-02.
   - `POST /api/auth/registro`: recibe correo y contraseña, valida formato, genera hash Argon2id con `argon2-cffi` y crea la cuenta.
   - `POST /api/auth/login`: valida credenciales y emite JWT firmado con expiración (PyJWT).
   - `POST /api/auth/vincular`: con el token anónimo, convierte ese mismo usuario en cuenta con correo; conserva sus respuestas.
   - `POST /api/auth/recuperar-codigo`: recibe el código de recuperación y devuelve un token para ese usuario (restaurar en otro teléfono).
   - `DELETE /api/auth/cuenta`: borra la cuenta y su progreso respaldado.
   - Rate limiting aplicado con `slowapi` en registro, login y recuperación.
2. **Manejo de Errores RFC 9457:** Lanzar `CredencialesInvalidasError` (401), `UsuarioYaExisteError` (409) con detalle seguro.

#### ✅ Criterios de Aceptación
- [ ] Contraseñas almacenadas exclusivamente con hashing Argon2id.
- [ ] Un usuario anónimo puede registrarse conservando el 100% de su racha y estadísticas previas.
- [ ] Un usuario sin cuenta puede migrar su progreso a otro teléfono ingresando su código de recuperación.

---

### HU-08: Sincronización Bidireccional Offline-First

- **Prioridad:** 🟡 MVP Secundario
- **Casos de Uso Relacionados:** CU-E18, CU-E15, CU-P13
- **Etiquetas en GitHub:** `hu`, `frontend`, `backend`, `ml`

#### Historia
> **Como** postulante que vive en zonas con conexión inestable,  
> **Quiero** que la aplicación funcione siempre sin internet y sincronice automáticamente mis respuestas en segundo plano cuando detecte conectividad,  
> **Para** no interrumpir nunca mi preparación y recibir nuevas preguntas y mejoras del modelo sin esfuerzo.

#### 📱 Componente Frontend (Flutter) — Asignado: Persona 4
1. **Cola de Eventos Offline en Drift:**
   - Tabla `cola_sincronizacion` que almacena respuestas y reportes con estado (`pendiente`, `enviado`, `fallido`).
   - Cada evento se genera con un UUID `idEvento`.
2. **Sincronizador en Segundo Plano:**
   - Listener de conectividad con `connectivity_plus`.
   - Cliente HTTP `clienteApiProvider` (conexión 10 s, respuesta 30 s) con reintentos silenciosos sin bloquear la UI del usuario.
   - Descarga de versión de banco de preguntas (HU-01) y del paquete de conocimiento si hay actualización disponible.

#### ⚙️ Componente Backend & ML (FastAPI / Python) — Asignados: Persona 5 & Persona 1
1. **Endpoint de Lote Idempotente (`features/sincronizacion/infrastructure/http/router.py`):**
   - `POST /api/sincronizacion/lote`: recibe hasta 100 eventos de respuesta (formato en HU-03), los inserta en `respuestas` usando `ON CONFLICT (id_evento) DO NOTHING`. Devuelve `{ "procesados", "versionBanco" }`. El usuario sale del token.
   - `GET /api/sincronizacion/progreso`: devuelve el progreso respaldado del usuario (para restaurar en otro teléfono, HU-07).
2. **Publicación de Paquetes de Conocimiento (`features/conocimiento`):**
   - `GET /api/paquetes-conocimiento/actual`: expone los parámetros globales calibrados por el script de ML (HU-06).

#### ✅ Criterios de Aceptación
- [ ] Cero bloqueos visuales o pantallas de carga molestas si se corta la conexión a internet.
- [ ] El envío de respuestas pendientes ocurre de forma silenciosa al reanudar la red.
- [ ] No se duplica ningún registro en PostgreSQL si el cliente reintenta enviar el mismo lote.

---

### HU-09: Sistema de Reporte de Errores en Preguntas

- **Prioridad:** 🟡 Secundario / Demo
- **Casos de Uso Relacionados:** CU-E13, CU-P10
- **Etiquetas en GitHub:** `hu`, `frontend`, `backend`

#### Historia
> **Como** postulante que detecta una anomalía en un ejercicio,  
> **Quiero** poder reportar un error en la pregunta (clave dudosa, imagen poco clara o texto roto) con un par de toques desde la misma pantalla de práctica,  
> **Para** ayudar a los curadores a corregir el banco y asegurar la calidad del material para toda la comunidad.

#### 📱 Componente Frontend (Flutter) — Asignados: Persona 3 & Persona 4
1. **Modal de Reporte:**
   - Botón discreto de bandera o *"Reportar error"* en la vista de explicación de la pregunta.
   - Opciones rápidas: *"Respuesta incorrecta"*, *"Imagen o fórmula borrosa"*, *"Error tipográfico"*, *"Otro"*.
   - Campo opcional de texto para comentarios adicionales.
2. **Almacenamiento Local del Reporte:**
   - Si no hay internet, el reporte se guarda en la cola local de Drift (HU-08) y se marca para sincronización futura.
   - Mensaje de confirmación: *"Gracias por tu reporte. Nuestro equipo de curación lo revisará."*

#### ⚙️ Componente Backend (FastAPI) — Asignado: Persona 5
1. **Endpoint de Reportes (`features/reportes/infrastructure/http/router.py`):**
   - `POST /api/reportes`: recibe `{ "preguntaId", "motivo", "comentario" }`; el usuario sale del token (anónimo o con cuenta).
   - Inserta en la tabla `reportes` con estado inicial `pendiente`. **Migración nueva** para agregar la columna `comentario` (la tabla inicial solo tiene `motivo`).
2. **Listado para Curadores:**
   - `GET /api/reportes/pendientes`: endpoint interno para listar preguntas marcadas para revisión.

#### ✅ Criterios de Aceptación
- [ ] El envío del reporte no interrumpe el flujo de la sesión de práctica diaria.
- [ ] El reporte se registra exitosamente en la base de datos de PostgreSQL para su posterior resolución.

---

## 🎨 Interfaz y Design System

El estándar visual está en [`docs/brand_ui_design_system_skill.md`](brand_ui_design_system_skill.md) (escrito con ejemplos web). En la app Flutter se aplica así:

- Los colores y tamaños se definen **una sola vez** en el tema (`ThemeData` / `ColorScheme`) en `lib/app/`; las pantallas no escriben colores a mano.
- **Poppins se incluye dentro de la app** (archivos de fuente en `assets/` declarados en `pubspec.yaml`), no se descarga de Google Fonts: la app debe funcionar sin internet.
- Contraste mínimo WCAG AA: texto oscuro `#0B1320` sobre los acentos vibrantes.

---

## 🧪 Estándares de Pruebas y Cobertura Obligatoria ($\ge 80\%$)

Cada Historia de Usuario completada debe incluir sus pruebas correspondientes:

1. **Frontend (Dart / Flutter):**
   - Pruebas unitarias de la lógica pura en `test/features/<feature>/domain/` (algoritmos FSRS, BKT, lógica de fechas).
   - Pruebas de repositorios Drift con base de datos en memoria (`test/features/<feature>/data/`).
   - Cobertura global verificada por `scripts/verificar-cobertura.mjs` $\ge 80\%$.
2. **Backend (Python / FastAPI):**
   - Pruebas unitarias y de integración en `tests/features/<feature>/` con `pytest`.
   - Uso de `TestClient` / `httpx2` para verificar códigos de estado HTTP, contratos RFC 9457 y migraciones.
   - Cobertura mínima obligatoria fijada en `pyproject.toml` con `--cov-fail-under=80`.
3. **Verificación Previa a Subir:**
   - Ejecutar obligatoriamente `pnpm run check` en la raíz del repositorio.
   - Commits con `pnpm run commit` (alcances permitidos: `app`, `backend`, `ml`, `docker`, `ci`, `docs`, `deps`).
