---
name: brand-ui-design-system
description: Estándar visual oficial para interfaces, documentos, presentaciones y componentes web utilizando la paleta de colores de alto contraste sobre base oscura (#0B1320), tipografía Poppins e lineamientos de integración de logo.
version: 1.0.0
tags: [ui, design-system, branding, poppins, dark-mode, colors]
---

# Skill: Estándar de Diseño Visual y Tipografía (Brand UI System)

Utiliza esta skill como fuente única de verdad cada vez que diseñes, maquetes, generes código (HTML/CSS, React, Tailwind, etc.) o crees documentos visuales y presentaciones. Respeta estrictamente los colores, jerarquías tipográficas y reglas de contraste aquí definidos.

---

## 1. Paleta de Colores Oficial

La interfaz se construye sobre una base nocturna profunda (`#0B1320`) combinada con cuatro acentos vibrantes de alto contraste. **No utilices colores fuera de este sistema** salvo los neutros de soporte para legibilidad de párrafos y superficies.

### Colores Principales (Paleta Base)

| Nombre | Código HEX | Rol Semántico | Uso Principal | Color de Texto Recomendado Encima |
| :--- | :--- | :--- | :--- | :--- |
| **Midnight Navy** | `#0B1320` | Fondo Principal (Canvas) | Fondo global de la app, encabezados oscuros, texto sobre botones claros/vibrantes. | `#F8FAFC` / `#FFF275` |
| **Naranja Solar** | `#F86624` | Primario / Acción / Crítico | Botones principales (CTA), acciones prioritarias, alertas críticas o peligro. | `#0B1320` (preferido) |
| **Azul Cielo** | `#2D9CDB` | Secundario / Info / Enlaces | Enlaces, estados informativos, botones secundarios, gráficos y datos. | `#0B1320` |
| **Amarillo Dorado** | `#F9C80E` | Alerta / Acento / Activo | Advertencias, indicadores de estado activo, badges destacados, iconos clave. | `#0B1320` |
| **Amarillo Brillo** | `#FFF275` | Resaltado / Énfasis Suave | Subrayados, etiquetas luminosas, estados hover sutiles, palabras clave en títulos. | `#0B1320` |

### Neutros y Superficies Derivadas (Soporte de UI)

Para mantener una lectura cómoda en textos largos y crear profundidad entre tarjetas sin romper la armonía de `#0B1320`:

| Nombre | Código HEX / RGBA | Uso |
| :--- | :--- | :--- |
| **Superficie Elevada** | `#131E30` | Tarjetas (cards), modales, barras laterales, inputs. |
| **Superficie Hover** | `#1B2A42` | Estados hover en filas, menús desplegables y tarjetas interactivas. |
| **Borde Sutil** | `rgba(255, 255, 255, 0.10)` | Divisores, bordes de inputs y contornos de tarjetas. |
| **Texto Principal** | `#F8FAFC` | Cuerpo de texto, párrafos largos y títulos estándar sobre fondo oscuro. |
| **Texto Secundario** | `#A3B1C6` | Subtítulos, descripciones, placeholders, metadatos y pies de foto. |

---

## 2. Estandarización de Tipografía (`Poppins`)

Toda la comunicación visual debe utilizar exclusivamente la familia **Poppins**.

### Importación (Web / CSS)

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet">
```

```css
font-family: 'Poppins', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
```

### Escala y Jerarquía de Textos y Títulos

| Elemento | Peso (Weight) | Tamaño (Desktop / Mobile) | Interlineado (Line Height) | Tracking (Letter Spacing) | Color Estándar |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **H1 (Título Principal / Hero)** | `800` (ExtraBold) o `700` (Bold) | `48px` / `32px` (`3rem` / `2rem`) | `1.15` | `-0.02em` | `#F8FAFC` (palabras clave en `#FFF275` o `#F9C80E`) |
| **H2 (Título de Sección)** | `700` (Bold) | `32px` / `24px` (`2rem` / `1.5rem`) | `1.25` | `-0.015em` | `#F8FAFC` (con acento/borde opcional en `#F86624`) |
| **H3 (Subtítulo / Título de Card)** | `600` (SemiBold) | `22px` / `18px` (`1.375rem` / `1.125rem`) | `1.35` | `-0.01em` | `#F8FAFC` o `#2D9CDB` |
| **H4 (Encabezado Menor)** | `600` (SemiBold) | `18px` / `16px` (`1.125rem` / `1rem`) | `1.4` | `0em` | `#F9C80E` |
| **Lead / Bajada** | `400` (Regular) | `18px` (`1.125rem`) | `1.6` | `0em` | `#A3B1C6` |
| **Body (Párrafo Estándar)** | `400` (Regular) | `16px` (`1rem`) | `1.65` | `0em` | `#F8FAFC` |
| **Body Small / Metadatos** | `400` (Regular) | `14px` (`0.875rem`) | `1.5` | `0.01em` | `#A3B1C6` |
| **Eyebrow / Categoría / Label** | `600` (SemiBold) — *MAYÚSCULAS* | `12px` (`0.75rem`) | `1.2` | `0.08em` | `#FFF275` o `#2D9CDB` |
| **Botones y CTAs** | `600` (SemiBold) | `15px` (`0.9375rem`) | `1.2` | `0.01em` | `#0B1320` (sobre botón sólido) |

---

## 3. Reglas de Integración del Logo

> **Nota de configuración:** Reemplaza las rutas de marcador de posición por el archivo oficial de tu logo (preferiblemente `.svg` con fondo transparente).

- **Ruta estándar del activo:** `./assets/logo.svg` (o `./assets/logo.png` en alta resolución `@2x`).
- **Ubicación principal:** Esquina superior izquierda en barras de navegación (Header) y centrado/izquierda en el pie de página (Footer) y pantallas de inicio de sesión.
- **Tamaño recomendado:**
  - *Navbar / Header:* Altura entre `32px` y `44px` (`width: auto`).
  - *Hero / Splash / Portadas:* Altura entre `64px` y `96px`.
  - *Tamaño mínimo legible:* Nunca menor a `24px` de altura.
- **Área de respeto (Clear Space):** Mantener un margen libre alrededor del logo equivalente al menos al 25% de su altura. No colocar texto ni botones pegados al isotipo.
- **Contraste y Fondo:**
  - Colocar el logo siempre sobre el fondo principal (`#0B1320`) o sobre una superficie elevada (`#131E30`).
  - No aplicar sombras pesadas, filtros de color no autorizados ni distorsionar su proporción (`object-fit: contain`).

---

## 4. Tokens Listos para Código (CSS Variables)

Incluye estas variables en la raíz de cualquier proyecto web para garantizar consistencia inmediata:

```css
:root {
  /* Paleta Oficial */
  --color-bg-primary: #0B1320;
  --color-brand-primary: #F86624;
  --color-brand-info: #2D9CDB;
  --color-brand-warning: #F9C80E;
  --color-brand-highlight: #FFF275;

  /* Superficies y Neutros */
  --color-surface: #131E30;
  --color-surface-hover: #1B2A42;
  --color-border: rgba(255, 255, 255, 0.10);
  --color-text-primary: #F8FAFC;
  --color-text-secondary: #A3B1C6;
  --color-text-on-accent: #0B1320;

  /* Tipografía */
  --font-family-base: 'Poppins', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;

  /* Radios y Sombras */
  --radius-sm: 6px;
  --radius-md: 12px;
  --radius-lg: 16px;
  --shadow-card: 0 8px 24px rgba(0, 0, 0, 0.35);
}
```

---

## 5. Estandarización de Componentes

### Botones
- **Primario (CTA):** Fondo `#F86624`, texto `#0B1320`, `font-weight: 600`. Hover: oscurecer sutilmente o añadir resplandor `box-shadow: 0 0 16px rgba(248, 102, 36, 0.4)`.
- **Secundario / Info:** Fondo `#2D9CDB`, texto `#0B1320`, `font-weight: 600`.
- **Acento / Destacado:** Fondo `#F9C80E`, texto `#0B1320`, `font-weight: 600`.
- **Fantasma (Ghost / Outline):** Fondo transparente, borde `1.5px solid #2D9CDB` (o `#FFF275`), texto del mismo color del borde.

### Tarjetas (Cards)
- Fondo `#131E30`, borde `1px solid rgba(255, 255, 255, 0.10)`, radio `12px`, padding `24px`.
- En estado activo o destacado, aplicar borde superior o izquierdo de `3px` en `#F86624`, `#2D9CDB` o `#F9C80E` según la categoría.

### Alertas, Badges y Notificaciones
- **Información:** Fondo `rgba(45, 156, 219, 0.15)`, borde `#2D9CDB`, texto/icono `#2D9CDB`.
- **Alerta / Precaución:** Fondo `rgba(249, 200, 14, 0.15)`, borde `#F9C80E`, texto/icono `#F9C80E`.
- **Crítico / Urgente:** Fondo `rgba(248, 102, 36, 0.15)`, borde `#F86624`, texto/icono `#F86624`.
- **Nuevo / Destacado:** Fondo `#FFF275`, texto `#0B1320` (ideal para píldoras o etiquetas pequeñas).

### Enlaces y Estados de Foco
- **Enlaces en texto:** Color `#2D9CDB`, subrayado en hover con cambio a `#FFF275`.
- **Focus visible (Accesibilidad):** `outline: 2px solid #FFF275; outline-offset: 2px;`.

---

## 6. Reglas de Oro y Restricciones (Checklist para el Agente)

Antes de entregar cualquier diseño o código con esta skill, verifica lo siguiente:

1. **Cero colores improvisados:** No introduzcas paletas externas ni colores por defecto de frameworks que contradigan `#0B1320`, `#F86624`, `#2D9CDB`, `#F9C80E` y `#FFF275`.
2. **Contraste obligatorio (WCAG AA+):** Sobre botones o bloques sólidos en `#FFF275`, `#F9C80E`, `#F86624` o `#2D9CDB`, usa siempre texto oscuro `#0B1320` para máxima legibilidad.
3. **Uso moderado de los acentos:** Aplica la regla **60-30-10** (60% fondo `#0B1320`, 30% superficies `#131E30` y texto `#F8FAFC`, 10% colores vibrantes de la paleta para guiar la vista).
4. **Tipografía consistente:** Carga siempre los pesos necesarios de **Poppins** (`400, 500, 600, 700, 800`) y respeta los saltos de jerarquía entre H1–H4 y cuerpo de texto.
5. **Presencia del logo:** Integra el espacio reservado para el logo respetando su proporción y área de respiro.