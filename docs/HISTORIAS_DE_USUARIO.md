# Historias de Usuario (HUs) e Issues — Prepion

Documento oficial de historias de usuario y división de trabajo Frontend / Backend para el equipo de desarrollo de **Prepion** (Hackaton Abstracthon 2026 · Track 02 Educación).

Basado en la arquitectura hexagonal + features del backend, arquitectura por features de Flutter, y los estándares de [`docs/ESTANDARES.md`](ESTANDARES.md).

---

## 👥 Reparto del Equipo de Desarrollo (5 Integrantes)

| Integrante | Rol Principal | Módulos y Tecnologías |
|---|---|---|
| **Persona 1** | Machine Learning & Extracción | Extracción de PDF con PyMuPDF, recorte de fórmulas, scripts IRT (`girth`) y BKT (`pyBKT`), recalibración del servidor en Docker (`ml`). |
| **Persona 2** | Curación del Banco de Preguntas | Revisión, resolución y verificación cruzada de respuestas (Google Sheets/CSV), exportación a JSON (`banco_v1.json`), control de calidad pedagógico. |
| **Persona 3** | Frontend: UI, Flujos y Navegación | Pantallas Flutter (Onboarding, Práctica, Catálogo, Métricas con `fl_chart`, Auth), componentes visuales, `go_router`, temas y accesibilidad. |
| **Persona 4** | Frontend: Datos Locales, FSRS y Notificaciones | Base de datos local Drift (`app_database.dart`), algoritmo FSRS (`fsrs 2.0.1`), BKT local, `flutter_local_notifications`, cola offline. |
| **Persona 5** | Backend: API FastAPI, BD, Auth y Docker | Endpoints FastAPI, SQLModel, PostgreSQL 16, migraciones Alembic, autenticación (Argon2 + PyJWT), sincronización en lote, soporte de Docker y pitch. |

---

## 🗺️ Matriz del Backlog y Prioridades

| Código | Issue | Título | Front | Back / ML | Prioridad | Estimación |
|---|---|---|---|---|---|---|
| **HU-01** | [#1](https://github.com/WilHacker/Prepion/issues/1) | Banco de Preguntas Oficiales y Curadas | Persona 4 & 2 | Persona 1 & 2 | 🟢 MVP | 8 pts |
| **HU-02** | [#2](https://github.com/WilHacker/Prepion/issues/2) | Onboarding y Configuración de Estudio sin Fricción | Persona 3 | Persona 5 | 🟢 MVP | 3 pts |
| **HU-03** | [#3](https://github.com/WilHacker/Prepion/issues/3) | Práctica Diaria Inteligente y Repaso Espaciado (FSRS) | Persona 3 & 4 | Persona 5 | 🟢 MVP | 13 pts |
| **HU-04** | [#4](https://github.com/WilHacker/Prepion/issues/4) | Recordatorios Diarios y Notificaciones Locales Offline | Persona 4 & 3 | — | 🟢 MVP | 3 pts |
| **HU-05** | [#5](https://github.com/WilHacker/Prepion/issues/5) | Práctica Libre por Materia y Tema Específico | Persona 3 & 4 | Persona 5 | 🟢 MVP | 5 pts |
| **HU-06** | [#6](https://github.com/WilHacker/Prepion/issues/6) | Panel de Progreso, Nivel de Preparación y Métricas | Persona 3 & 4 | Persona 1 | 🟢 MVP | 8 pts |
| **HU-07** | [#7](https://github.com/WilHacker/Prepion/issues/7) | Autenticación con Correo, Respaldo y Código de Recuperación | Persona 3 | Persona 5 | 🟡 MVP Secundario | 8 pts |
| **HU-08** | [#8](https://github.com/WilHacker/Prepion/issues/8) | Sincronización Bidireccional Offline-First | Persona 4 | Persona 5 & 1 | 🟡 MVP Secundario | 8 pts |
| **HU-09** | [#9](https://github.com/WilHacker/Prepion/issues/9) | Sistema de Reporte de Errores en Preguntas | Persona 3 & 4 | Persona 5 | 🟡 Secundario / Demo | 3 pts |

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
1. **Esquema Drift Local:** Definir tablas `examenes`, `temas`, `preguntas` en `lib/shared/database/app_database.dart` con soporte de claves primarias UUID, campos de texto, opciones múltiples (A–E), ruta o URI de imagen para fórmulas, explicación didáctica y cita de fuente.
2. **Semilla Inicial (Offline-First):** Crear servicio de carga inicial en `lib/features/practica/data/banco_local_service.dart` que al primer inicio de la app importe `assets/datos/banco_semilla.json` a la base de datos local Drift en una transacción rápida (<500 ms).
3. **Renderizado de Fórmulas e Imágenes:** Componente `TarjetaEnunciado` capaz de alternar entre texto markdown simple y renderizado de imágenes recortadas (`Image.asset` o `Image.file`) cuando el campo `rutaImagen` esté presente.

#### ⚙️ Componente Backend & ML (FastAPI / Python) — Asignados: Persona 1 & Persona 2
1. **Extractor de PDF con PyMuPDF (`backend/app/features/examenes` / scripts):** Script en el contenedor `ml` que lee `data/examenes_pdf/2026-2-1op.pdf`, detecta secciones (Biología, Química, Aritmética, Geometría, Física), extrae enunciados/opciones y recorta las áreas con fórmulas matemáticas a imágenes PNG optimizadas en `data/imagenes/`.
2. **Generador y Validador del Banco JSON:** Script de exportación que toma las respuestas curadas (doble verificación en Google Sheets o CSV) y genera `banco_v1.json` validando tipos con Pydantic.
3. **Endpoint HTTP de Consulta:** En `features/preguntas/infrastructure/http/router.py`:
   - `GET /api/preguntas/banco/actual` → devuelve metadata de la versión actual del banco y URL/payload del JSON.
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
3. **Acceso Anónimo Predeterminado:** Botón principal *"Empezar a practicar ahora"* que genera un UUID v4 local (`id_usuario_local`) guardado en `shared_preferences` y navega a la vista principal. Opción secundaria *"Ya tengo cuenta / Iniciar sesión"*.

#### ⚙️ Componente Backend (FastAPI) — Asignado: Persona 5
1. **Esquema de Usuario Anónimo:** Asegurar que los endpoints del backend acepten `X-Usuario-Id` (UUID) anónimo sin requerir Bearer Token en cabecera HTTP para la recolección de eventos.
2. **Parámetros Públicos:** Endpoint `GET /api/configuracion/parametros-publicos` que devuelve fechas tentativas de admisión y rangos recomendados de preguntas diarias.

#### ✅ Criterios de Aceptación
- [ ] El postulante entra a la pantalla de estudio en menos de 3 toques de pantalla desde la instalación.
- [ ] No se exige ningún dato personal (ni correo, ni nombre, ni teléfono, ni carnet).
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
   - `HojaExplicacion`: modal o panel inferior que aparece al responder, coloreando verde (acierto) o rojo (fallo), mostrando la respuesta correcta, la explicación pedagógica y el botón *"Siguiente"*.
   - `ResumenSesionPage`: pantalla final con métricas de la sesión (aciertos/fallos, tiempo total, racha de días actualizada).
2. **Lógica de Repetición Espaciada FSRS en Dart puro (`features/practica/domain/`):**
   - Integración con el paquete `fsrs: ^2.0.1`.
   - Mapeo de la respuesta del usuario (Fallo = Again, Acierto con duda = Hard, Acierto normal = Good, Muy fácil = Easy).
   - Cálculo del nuevo estado (Estabilidad $S$, Dificultad $D$, Próximo Repaso en días).
   - Guardado local en tabla Drift `tarjetas_fsrs` y registro del evento en `respuestas_locales`.

#### ⚙️ Componente Backend (FastAPI) — Asignado: Persona 5
1. **Recepción de Respuestas:** Endpoint `POST /api/sincronizacion/respuestas` que valida una lista de respuestas con DTO `RespuestaEventoCreate` (`id_evento`, `id_pregunta`, `opcion_elegida`, `es_correcta`, `tiempo_respuesta_ms`, `respondido_en`).
2. **Persistencia SQLModel:** Almacenamiento en tabla `respuestas` de PostgreSQL con clave primaria `id_evento` provista por el cliente para evitar duplicados.

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
1. **Servicio de Notificaciones Locales (`features/practica/data/`):**
   - Configuración de `flutter_local_notifications` con soporte de Android 13+ (permiso `POST_NOTIFICATIONS` y `SCHEDULE_EXACT_ALARM`).
   - Inicialización de zonas horarias con `timezone` y `flutter_timezone`.
   - Programación de alarma diaria recurrente a la hora seleccionada por el postulante: *"Tus 10 preguntas de hoy te esperan (5 min)"*.
   - Cancelación o postergación automática si el usuario ya completó su sesión del día antes de la hora configurada.
2. **Deep Linking Local:** Al tocar la notificación, la app debe abrirse directamente en la ruta `/practica` de `go_router`.
3. **Control en Ajustes:** Switch para activar/desactivar recordatorios y selector de hora en `ConfiguracionPage`.

#### ⚙️ Componente Backend
- *No requiere infraestructura de backend (100% local, costo cero, sin cuotas de Firebase Cloud Messaging).*

#### ✅ Criterios de Aceptación
- [ ] La notificación se dispara a la hora configurada incluso con la app cerrada y sin conexión a internet.
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
2. **Modo Práctica Libre:**
   - Permite lanzar una sesión con filtros (`id_materia`, `id_tema`).
   - Muestra preguntas en modo entrenamiento continuo sin límite estricto de 10 preguntas.
   - Las respuestas actualizan el dominio del tema en Drift pero no interfieren negativamente con la cola FSRS de la práctica diaria programada.

#### ⚙️ Componente Backend (FastAPI) — Asignado: Persona 5
1. **Endpoint de Árbol Temático:**
   - `GET /api/temas` en `features/examenes/infrastructure/http/router.py`: devuelve el listado jerárquico de materias y temas con su código y descripción.
2. **Filtro de Preguntas por Tema:**
   - `GET /api/preguntas?materiaId={id}&temaId={id}`: permite consultar preguntas filtradas para previsualización o administración.

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
   - Actualización de $P(L_t)$ tras cada respuesta usando parámetros base: $P(L_0)=0.1$, $P(T)=0.15$, $P(G)=0.2$, $P(S)=0.1$.

#### ⚙️ Componente Backend & ML (Python) — Asignado: Persona 1
1. **Calibración IRT con `girth` en Contenedor `ml`:** Script que procesa matrices de aciertos de preguntas y estima la dificultad real $b_i$ de cada ítem con el modelo de 2 parámetros (2PL).
2. **Exportación de Parámetros de Referencia:** Generación de archivo `parametros_conocimiento_v1.json` con los pesos de dificultad para afinar la estimación del cliente.

#### ✅ Criterios de Aceptación
- [ ] El panel de progreso se actualiza reactivamente tan pronto como el estudiante termina una sesión de preguntas.
- [ ] Los gráficos de `fl_chart` son fluidos, legibles y adaptados a temas claro/oscuro.
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
   - Pantalla de `CodigoRecuperacionDialog`: permite generar, ver y copiar el código anónimo en texto legible.
   - Sincronización al vincular: une el historial local anónimo (`id_usuario_local`) con la nueva cuenta creada sin duplicar respuestas.

#### ⚙️ Componente Backend (FastAPI) — Asignado: Persona 5
1. **Endpoints de Auth (`features/auth/infrastructure/http/router.py`):**
   - `POST /api/auth/registro`: recibe correo y contraseña, valida formato, genera hash Argon2 con `argon2-cffi`, inserta en tabla `usuarios`.
   - `POST /api/auth/login`: valida credenciales, emite JWT firmado con expiración (PyJWT).
   - `POST /api/auth/codigo-recuperacion`: genera o valida código seguro de recuperación para usuarios sin correo.
   - `POST /api/auth/vincular-anonimo`: asocia las respuestas registradas bajo un UUID anónimo a la cuenta del usuario autenticado.
   - Rate limiting aplicado con `slowapi` en rutas de login y registro.
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
   - Cada evento se genera con un UUID `id_evento`.
2. **Sincronizador en Segundo Plano:**
   - Listener de conectividad con `connectivity_plus`.
   - Cliente HTTP `Dio` configurado con timeouts de 5s y reintentos silenciosos sin bloquear la UI del usuario.
   - Descarga de versión de banco de preguntas si hay actualización disponible.

#### ⚙️ Componente Backend & ML (FastAPI / Python) — Asignados: Persona 5 & Persona 1
1. **Endpoint de Lote Idempotente (`features/sincronizacion/infrastructure/http/router.py`):**
   - `POST /api/sincronizacion/lote`: recibe array de hasta 100 eventos de respuesta, los inserta en `respuestas` usando `ON CONFLICT (id_evento) DO NOTHING`. Devuelve cantidad de eventos procesados y versión activa del banco.
2. **Publicación de Paquetes de Conocimiento:**
   - Endpoint `GET /api/paquetes-conocimiento/actual`: expone los parámetros globales calibrados por el script de ML.

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
   - Si no hay internet, el reporte se guarda en la cola local de Drift y se marca para sincronización futura.
   - Mensaje de confirmación: *"Gracias por tu reporte. Nuestro equipo de curación lo revisará."*

#### ⚙️ Componente Backend (FastAPI) — Asignado: Persona 5
1. **Endpoint de Reportes (`features/reportes/infrastructure/http/router.py`):**
   - `POST /api/reportes`: recibe `id_pregunta`, `tipo_reporte`, `comentario` y `id_usuario_local`.
   - Inserta en la tabla `reportes` con estado inicial `pendiente`.
2. **Listado para Curadores:**
   - `GET /api/reportes/pendientes`: endpoint interno para listar preguntas marcadas para revisión.

#### ✅ Criterios de Aceptación
- [ ] El envío del reporte no interrumpe el flujo de la sesión de práctica diaria.
- [ ] El reporte se registra exitosamente en la base de datos de PostgreSQL para su posterior resolución.

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
