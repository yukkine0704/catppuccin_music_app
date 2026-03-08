# Material Design 3 Expressive (M3E) - Directrices de Diseño

Este documento establece las reglas mandatorias para la generación y diseño de interfaces bajo el sistema Material Design 3 Expressive (M3E). El agente DEBE seguir estas directrices al pie de la letra para asegurar la coherencia técnica y estética del sistema.

---

## 1. Arquitectura de Tokens de Diseño

Los tokens actúan como la "fuente única de verdad". Queda estrictamente prohibido el uso de valores hardcodeados (hexadecimales, píxeles estáticos) en el código de componentes.

### Nomenclatura

`md.[clase].[propósito]` (Ej: md.sys.color.primary)

### Clases de Tokens

- **Reference (ref)**: Valores atómicos básicos (paletas tonales, familias de fuentes, medidas base)
- **System (sys)**: Decisiones semánticas que definen el tema (color dinámico, escala tipográfica, formas del sistema)
- **Component (comp)**: Atributos específicos asignados a elementos de un componente (Ej: md.comp.fab.primary.container.color)

---

## 2. Sistema de Color Dinámico (HCT)

Implementar el modelo HCT (Hue, Chroma, Tone) para garantizar accesibilidad y fidelidad perceptiva.

### Proceso de Generación

Extraer un color de origen (Source Color) y derivar 5 colores clave:

1. Primary
2. Secondary
3. Tertiary
4. Neutral
5. Neutral Variant

### Roles de Color (26 roles mandatorios)

| Rol | Uso |
|-----|-----|
| **Primary** | Elementos de máxima prominencia y estados activos |
| **Secondary** | Componentes menos destacados como chips de filtro |
| **Tertiary** | Acentos de contraste, campos de entrada e insignias |
| **Surface Container** | Utilizar los niveles Low, Normal, High, Highest para definir jerarquía sin depender exclusivamente de sombras |

### Accesibilidad

- Ratio de contraste mínimo **4.5:1** para texto pequeño
- Ratio de contraste mínimo **3:1** para texto grande o elementos gráficos esenciales

---

## 3. Escala Tipográfica y Énfasis

M3E utiliza una escala de **30 estilos** (15 Baseline + 15 Emphasized).

### Categorías

- Display
- Headline
- Title
- Body
- Label

### Uso de Emphasized

Aplicar estilos Emphasized (mayor peso visual) exclusivamente en:

- Momentos de selección
- Acciones críticas
- Titulares editoriales
- Mensajes no leídos

### Fuente

Se prefiere el uso de **Roboto Flex** (fuente variable) para ajustar ejes de peso y ancho dinámicamente según el contexto.

---

## 4. Física de Movimiento (Springs)

Sustituir curvas de duración fija por física de resortes para interacciones naturales.

### Parámetros

- **Stiffness** (Rigidez)
- **Damping** (Amortiguación)
- **Initial Velocity**

### Esquemas de Movimiento

| Esquema | Descripción |
|---------|-------------|
| **Expressive** | Incluye un rebote (overshoot) sutil. Obligatorio para "momentos heroicos" y cambios de estado destacados |
| **Standard** | Movimiento funcional que se asienta suavemente. Uso en aplicaciones de productividad o utilitarias |

### Tokens de Movimiento

Usar `md.sys.motion.spring.[velocidad].[tipo]`

- **Tipos**: Spatial (posición/tamaño) y Effects (color/opacidad)

---

## 5. Formas y Morfismo (Shape Morphing)

Uso activo de la librería de **35 formas** para comunicación visual.

### Shape Morphing

Implementar transiciones fluidas entre formas para indicar progreso o cambios de estado de interacción.

### Tensión Visual

Combinar intencionalmente formas redondeadas con formas cuadradas para romper la monotonía y dirigir el foco.

### Esquinas

Utilizar los nuevos tokens de radio:

- **Extra Extra Large**: 48dp
- **Full**: Para componentes circulares

---

## 6. Componentes Expressive Clave

Priorizar la implementación de estos componentes optimizados para M3E:

| Componente | Descripción |
|------------|-------------|
| **Split Button** | Separa una acción principal de un menú desplegable con rotación de icono al activarse |
| **Button Groups** | Contenedores de botones que reaccionan físicamente entre sí al ser presionados |
| **Toolbars (Floating/Docked)** | Sustituyen la antigua barra inferior. Son más cortas, flexibles y pueden ir acompañadas de un FAB |
| **Loading Indicators** | Utilizar formas de onda (waveforms) con morfismo para procesos de carga cortos (< 5s) |

---

## 7. Layout Adaptativo y Contención

Diseño basado en Paneles (Panes) que responden a **Clases de Tamaño de Ventana**.

### Estrategias Adaptativas

| Estrategia | Descripción |
|-----------|-------------|
| **Show/Hide** | Paneles que aparecen o desaparecen según el espacio |
| **Levitate** | Paneles que flotan sobre el contenido (Ej: Side sheets en tablets) |
| **Reflujo (Reflow)** | Reorganización de elementos para mantener el contexto |

### Contención (Containment)

Agrupar contenido relacionado en contenedores claros (Cards) para mejorar la escaneabilidad.

> **Nota**: Los usuarios identifican elementos clave hasta **4 veces más rápido** con una contención adecuada.

---

## 8. Estándares de Accesibilidad Inclusiva

### Objetivos Táctiles

Mínimo de **48x48dp** (~9mm) para asegurar la usabilidad en cualquier dispositivo.

### Estructura ARIA

Definir hitos (Landmarks) claros:

- navigation
- search
- main
- banner
- contentinfo

### Orden de Foco

Debe seguir el flujo lógico del DOM (izquierda a derecha, arriba hacia abajo).

### Navegación por Teclado

Asegurar que todos los flujos críticos sean completables mediante:

- Tab
- Enter
- Teclas de dirección

---

## Tácticas de Ejecución Final

### Identificar "Momentos Heroicos"

Seleccionar **1 o 2 interacciones clave por pantalla** para aplicar simultáneamente:

- Color vibrante
- Tipografía enfatizada
- Movimiento expresivo

### Priorizar Claridad sobre Estética

No comprometer la legibilidad ni la función principal por florituras visuales.

### Uso de Tokens Semánticos

**Siempre** asignar colores y tipografía según su función (purpose) y no por su apariencia visual inmediata.

---

> Este documento servirá como el "manual de instrucciones" definitivo para la implementación de Material Design 3 Expressive en el proyecto.
