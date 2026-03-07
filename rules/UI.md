# M3E Collection - API Reference Corregida

> **Nota importante:** Esta documentación refleja la API real descubierta durante la implementación. Algunos ejemplos de la documentación oficial pueden no ser exactos.

## API CORRECTA - Resumen de Componentes Verificados

### ✅ ButtonM3E (Verificado y Funcionando)

```dart
import 'package:button_m3e/button_m3e.dart';

// API CORRECTA:
ButtonM3E(
  onPressed: () {},
  label: const Text('Save'),
  icon: const Icon(Icons.save),           // Opcional
  style: ButtonM3EStyle.filled,           // filled, tonal, elevated, outlined, text
  size: ButtonM3ESize.md,                 // xs, sm, md, lg, xl
  isSelected: false,                      // Para toggle buttons
  enabled: true,
  tooltip: 'Guardar',
)

// ❌ NO EXISTEN (errores de documentación):
// - ButtonM3E.filled() - No hay constructores nombrados
// - variant: ButtonM3EVariant.xxx - No existe el parámetro 'variant'
// - shapeFamily: ButtonM3EShapeFamily.xxx - No existe el parámetro 'shapeFamily'
```

### ✅ IconButtonM3E (Verificado y Funcionando)

```dart
import 'package:icon_button_m3e/icon_button_m3e.dart';

// API CORRECTA:
IconButtonM3E(
  variant: IconButtonM3EVariant.filled,   // standard, filled, tonal, outlined
  size: IconButtonM3ESize.md,             // xs, sm, md, lg, xl
  width: IconButtonM3EWidth.defaultWidth, // defaultWidth, narrow, wide
  icon: const Icon(Icons.favorite),
  selectedIcon: const Icon(Icons.favorite_filled), // Para toggle
  isSelected: false,
  onPressed: () {},
  tooltip: 'Add to favorites',
)
```

### ✅ AppBarM3E (Verificado y Funcionando)

```dart
import 'package:app_bar_m3e/app_bar_m3e.dart';

// API CORRECTA:
AppBarM3E(
  leading: IconButtonM3E(...),
  titleText: 'Título',
  title: Row(...),                        // Alternativa a titleText
  actions: [IconButtonM3E(...)],
  centerTitle: true,
  shapeFamily: AppBarM3EShapeFamily.round, // round, square
  density: AppBarM3EDensity.regular,       // regular, compact
)

// Sliver variant:
SliverAppBarM3E(
  variant: AppBarM3EVariant.large,         // medium, large
  titleText: 'Título',
  pinned: true,
)
```

### ✅ LoadingIndicatorM3E (Verificado y Funcionando)

```dart
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

// API CORRECTA:
const LoadingIndicatorM3E(),                           // Default
const LoadingIndicatorM3E(
  variant: LoadingIndicatorM3EVariant.contained,       // default, contained
),

// Con colores y shapes personalizados:
LoadingIndicatorM3E(
  color: Colors.teal,
  polygons: const [
    MaterialShapes.sunny,
    MaterialShapes.cookie9Sided,
    MaterialShapes.pill,
  ],
)
```

### ✅ NavigationBarM3E (Verificado y Funcionando)

```dart
import 'package:navigation_bar_m3e/navigation_bar_m3e.dart';

// API CORRECTA:
NavigationBarM3E(
  destinations: const [
    NavigationDestinationM3E(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestinationM3E(
      icon: Icon(Icons.search),
      label: 'Search',
      badgeCount: 3,                        // Badge numérico
    ),
    NavigationDestinationM3E(
      icon: Icon(Icons.person),
      label: 'Profile',
      badgeDot: true,                       // Badge dot
    ),
  ],
  selectedIndex: 0,
  onDestinationSelected: (i) {},
  labelBehavior: NavBarM3ELabelBehavior.onlySelected,  // alwaysShow, onlySelected, alwaysHide
  indicatorStyle: NavBarM3EIndicatorStyle.pill,        // pill, underline, none
  size: NavBarM3ESize.medium,                          // small, medium
  density: NavBarM3EDensity.regular,                   // regular, compact
  shapeFamily: NavBarM3EShapeFamily.round,             // round, square
)
```

### ✅ FabM3E / ExtendedFabM3E (Verificado y Funcionando)

```dart
import 'package:fab_m3e/fab_m3e.dart';

// API CORRECTA - FabM3E:
FabM3E(
  icon: const Icon(Icons.add),
  kind: FabM3EKind.primary,        // primary, secondary, tertiary, surface
  size: FabM3ESize.regular,        // small, regular, large
  onPressed: () {},
)

// API CORRECTA - ExtendedFabM3E:
ExtendedFabM3E(
  icon: const Icon(Icons.edit),
  label: const Text('Compose'),
  kind: FabM3EKind.secondary,
  onPressed: () {},
)

// API CORRECTA - FabMenuM3E:
FabMenuM3E(
  controller: FabMenuController(),
  alignment: Alignment.bottomRight,
  direction: FabMenuDirection.up,   // up, down, left, right
  primaryFab: FabM3E(
    icon: const Icon(Icons.add),
    onPressed: controller.toggle,
  ),
  items: [
    FabMenuItem(
      icon: const Icon(Icons.photo),
      label: const Text('Photo'),
      onPressed: () {},
    ),
  ],
)
```

### ✅ ToolbarM3E (Verificado y Funcionando)

```dart
import 'package:toolbar_m3e/toolbar_m3e.dart';

// API CORRECTA:
ToolbarM3E(
  leading: const BackButton(),
  titleText: 'Selection',
  subtitleText: '3 items',
  actions: [
    ToolbarActionM3E(
      icon: Icons.search,
      onPressed: () {},
      tooltip: 'Search',
    ),
    ToolbarActionM3E(
      icon: Icons.delete_outline,
      onPressed: () {},
      tooltip: 'Delete',
      isDestructive: true,
      label: 'Delete',              // Usado en overflow menu
    ),
  ],
  maxInlineActions: 2,              // Acciones extra van a overflow menu
  variant: ToolbarM3EVariant.tonal, // surface, tonal, primary
  size: ToolbarM3ESize.medium,      // small, medium, large
  density: ToolbarM3EDensity.regular,
  shapeFamily: ToolbarM3EShapeFamily.round,
)
```

### ✅ SplitButtonM3E (Verificado y Funcionando)

```dart
import 'package:split_button_m3e/split_button_m3e.dart';

// API CORRECTA:
SplitButtonM3E<String>(
  size: SplitButtonM3ESize.md,                   // xs, sm, md, lg, xl
  shape: SplitButtonM3EShape.round,              // round, square
  emphasis: SplitButtonM3EEmphasis.tonal,        // filled, tonal, elevated, outlined, text
  label: 'Save',
  leadingIcon: Icons.save_outlined,
  onPressed: () => debugPrint('Primary pressed'),
  items: const [
    SplitButtonM3EItem<String>(
      value: 'draft',
      child: 'Save as draft',
    ),
    SplitButtonM3EItem<String>(
      value: 'close',
      child: 'Save & close',
    ),
  ],
  onSelected: (v) => debugPrint('Selected: $v'),
  leadingTooltip: 'Save',
  trailingTooltip: 'Open menu',
)
```

### ✅ SliderM3E / RangeSliderM3E (Verificado y Funcionando)

```dart
import 'package:slider_m3e/slider_m3e.dart';

// API CORRECTA - SliderM3E:
SliderM3E(
  value: 0.35,
  onChanged: (v) {},
  min: 0,
  max: 100,
  divisions: 10,
  size: SliderM3ESize.large,           // small, medium, large
  emphasis: SliderM3EEmphasis.primary, // primary, secondary, tertiary
  shapeFamily: SliderM3EShapeFamily.round, // round, square
  startIcon: const Icon(Icons.volume_mute),
  endIcon: const Icon(Icons.volume_up),
  label: '35%',
)

// API CORRECTA - RangeSliderM3E:
RangeSliderM3E(
  values: const RangeValues(0.2, 0.8),
  onChanged: (r) {},
  divisions: 8,
  size: SliderM3ESize.medium,
  emphasis: SliderM3EEmphasis.secondary,
  shapeFamily: SliderM3EShapeFamily.square,
)
```

### ✅ ButtonGroupM3E (Verificado y Funcionando)

```dart
import 'package:button_group_m3e/button_group_m3e.dart';

// API CORRECTA:
ButtonGroupM3E(
  actions: [
    ButtonGroupM3EAction(
      label: const Text('One'),
      onPressed: () {},
    ),
    ButtonGroupM3EAction(
      label: const Text('Two'),
      icon: const Icon(Icons.star),
      onPressed: () {},
      style: ButtonM3EStyle.filled,
    ),
  ],
  overflow: ButtonGroupM3EOverflow.menu,  // menu, scroll, none
  type: ButtonGroupM3EType.standard,       // standard, connected
  shape: ButtonGroupM3EShape.round,        // round, square
  size: ButtonM3ESize.md,
  density: ButtonGroupM3EDensity.regular,  // regular, compact
  groupSelection: true,                    // Modo selección múltiple
  selectedIndex: 0,
  equalizeWidths: true,
)
```

### ✅ Progress Indicator M3E (Verificado y Funcionando)

```dart
import 'package:progress_indicator_m3e/progress_indicator_m3e.dart';

// API CORRECTA - Circular:
const CircularProgressIndicatorM3E()

// API CORRECTA - Linear:
const LinearProgressIndicatorM3E(
  value: 0.6,  // null para indeterminate
)
```

### ✅ NavigationRailM3E (Verificado y Funcionando)

```dart
import 'package:navigation_rail_m3e/navigation_rail_m3e.dart';

// API CORRECTA:
NavigationRailM3E(
  type: NavigationRailM3EType.expanded,     // collapsed, expanded
  modality: NavigationRailM3EModality.standard, // standard, modal
  selectedIndex: 0,
  onDestinationSelected: (i) {},
  onTypeChanged: (t) {},
  fab: NavigationRailM3EFabSlot(
    icon: const Icon(Icons.add),
    label: 'New',
    onPressed: () {},
  ),
  sections: [
    NavigationRailM3ESection(
      header: const Text('Main'),
      destinations: [
        NavigationRailM3EDestination(
          icon: const Icon(Icons.edit_outlined),
          selectedIcon: const Icon(Icons.edit),
          label: 'Edit',
          largeBadgeCount: 0,
        ),
        NavigationRailM3EDestination(
          icon: const Icon(Icons.star_outline),
          selectedIcon: const Icon(Icons.star),
          label: 'Starred',
          smallBadge: true,
        ),
      ],
    ),
  ],
)
```

---

## ⚠️ Componentes Estándar con Tema M3E

Algunos componentes no tienen versión M3E específica pero funcionan con el tema M3E aplicado:

```dart
// Card con tokens M3E:
Card(
  elevation: 0,
  color: m3e.colors.surfaceContainerHigh,
  margin: EdgeInsets.symmetric(
    horizontal: m3e.spacing.md,
    vertical: m3e.spacing.xs,
  ),
  child: ...,
)

// SnackBar estándar (con colores del tema M3E):
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Message'),
    // Los colores vienen del tema M3E automáticamente
  ),
)

// AlertDialog estándar (con colores del tema M3E):
AlertDialog(
  icon: Icon(Icons.info),
  title: Text('Title'),
  content: Text('Content'),
  actions: [
    ButtonM3E(...),  // Usar ButtonM3E para botones M3E
  ],
)
```

---

## 📦 Dependencias Necesarias

```yaml
dependencies:
  flutter:
    sdk: flutter
  m3e_collection: ^0.3.7

  # Dependencias explícitas (no se exportan desde m3e_collection):
  m3e_design: ^0.2.1
  app_bar_m3e: ^0.1.2
  button_m3e: ^0.1.2
  button_group_m3e: ^0.3.1
  fab_m3e: ^0.1.1
  icon_button_m3e: ^0.2.1
  loading_indicator_m3e: ^0.1.1
  navigation_bar_m3e: ^0.1.1
  navigation_rail_m3e: ^0.3.5
  progress_indicator_m3e: ^0.1.1
  slider_m3e: ^0.1.1
  split_button_m3e: ^0.2.1
  toolbar_m3e: ^0.1.1
```

---

## 🔧 Tema M3E - Configuración

```dart
import 'package:m3e_design/m3e_design.dart';

// Opción 1: Usar ThemeData estándar (los componentes M3E leen el tema)
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
  // Los componentes M3E leen Theme.of(context).extension<M3ETheme>()
)

// Opción 2: Acceder a tokens M3E manualmente:
final m3e = Theme.of(context).extension<M3ETheme>() ??
            M3ETheme.defaults(Theme.of(context).colorScheme);

// Usar tokens:
// - m3e.colors.surface, onSurface, primaryContainer, etc.
// - m3e.spacing.xs, sm, md, lg, xl
// - m3e.type (tipografía con variantes emphasized)
```

---

# Documentación Original de m3e_collection

m3e_design
Design language core for Material 3 Expressive (Flutter). Provides ThemeExtension and token accessors for color, typography, shapes, spacing, motion.

Live demo (Gallery)
Explore the components using this design system in the M3E Gallery (GitHub Pages):

https://.github.io/material_3_expressive/

To run the Gallery locally:

cd apps/gallery
flutter run -d chrome
Last updated: 2025-10-25

Detailed Guide
What this package provides
The design language core for Material 3 Expressive:

M3ETheme ThemeExtension providing tokens for color, typography, shapes, spacing, elevation, and motion.
Utilities to derive expressive surfaces (e.g., surfaceContainer levels) and harmonize with dynamic colors.
Installation
dependencies:
  m3e_design: ^0.1.0
  dynamic_color: ^1.8.1
Minimum SDK: Dart >=3.5.0.

Quick start: one-liner theme
Widget buildApp() {
  return MaterialApp(
    theme: ColorScheme.fromSeed(seedColor: Colors.teal).toM3EThemeData(),
    home: const MyHomePage(),
  );
}
With dynamic color (Android 12+), setting both light and dark themes:

Widget buildDynamicApp() {
  return DynamicColorBuilder(
    builder: (lightDynamic, darkDynamic) {
      final light = lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.teal);
      final dark = darkDynamic ??
          ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark);
      return MaterialApp(
        theme: light.toM3EThemeData(),
        darkTheme: dark.toM3EThemeData(),
        home: const MyHomePage(),
      );
    },
  );
}
Alternative approach: withM3ETheme
The alternative approach is to use the withM3ETheme ThemeExtension, which is a convenience wrapper around the ThemeData constructor.

Widget build(BuildContext context) {
  return MaterialApp(
    theme: withM3ETheme(
      ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
    ),
    home: const MyHomePage(),
    );
}
Widget build(BuildContext context) {
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return MaterialApp(
            theme: withM3ETheme(
              ThemeData(
                colorScheme: lightDynamic ?? App._defaultLightColorScheme,
                useMaterial3: true,
              ),
            ),
            darkTheme: withM3ETheme(
              ThemeData(
                colorScheme: darkDynamic ?? App._defaultDarkColorScheme,
                useMaterial3: true,
                brightness: Brightness.dark,
              ),
            ),
            home: const MyHomePage(),
          );
        },
      ),
    }
Token overview
Colors: surface, onSurface, container tiers, primary/secondary/tertiary, outline, inverse, etc.
Typography: headline/title/label/body scales incl. emphasized variants.
Shapes: round/square families, radii by size category.
Spacing: xs→xl ramps for consistent paddings.
Motion: durations/easings for expressive transitions.
Used by
All sibling packages in this monorepo use M3E tokens for consistent UI.

app_bar_m3e
Expressive App Bar for Flutter (Material 3 Expressive).
Small (standard) bar for Scaffold.appBar, plus Medium & Large collapsing variants via a sliver.

Uses m3e_design tokens for color, typography, spacing, and shapes.

Monorepo Setup
Place alongside m3e_design in your repo:

packages/
  m3e_design/
  app_bar_m3e/
pubspec.yaml references ../m3e_design by default.

API
Small App Bar
AppBarM3E(
  leading: IconButton(icon: const BackButtonIcon(), onPressed: () {}),
  titleText: 'Inbox',
  actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
  centerTitle: false,
  shapeFamily: AppBarM3EShapeFamily.round,
  density: AppBarM3EDensity.regular,
);
Use in a Scaffold:

Scaffold(
  appBar: const AppBarM3E(titleText: 'Inbox'),
  body: ...
);
Sliver App Bar (Medium / Large)
CustomScrollView(
  slivers: [
    SliverAppBarM3E(
      variant: AppBarM3EVariant.large,
      titleText: 'Gallery',
      pinned: true,
    ),
    // ... content slivers
  ],
);
variant: medium uses expanded height ≈112dp (collapses to ~64dp).
variant: large uses expanded height ≈152dp (collapses to ~64dp).
Colors, shapes, and typography come from m3e_design's M3ETheme extension.
Theme Integration
app_bar_m3e reads the M3ETheme extension from your ThemeData:

final m3e = Theme.of(context).extension<M3ETheme>() ??
            M3ETheme.defaults(Theme.of(context).colorScheme);
It uses:

m3e.colors.surfaceContainerHigh for background
m3e.type.titleLarge for collapsed titles
m3e.type.headlineSmallEmphasized for expanded titles
m3e.shapes.round|square for container shape
m3e.spacing.md for horizontal padding
Override by supplying backgroundColor, foregroundColor, toolbarHeight, etc.

Notes
For collapsing behavior, use the sliver variant inside a CustomScrollView.
AppBarM3E (small) is a PreferredSizeWidget suitable for Scaffold.appBar.
Medium/Large variants rely on FlexibleSpaceBar for expanded titles.
When density: compact, default heights reduce by ~8dp.
License
MIT

Live demo (Gallery)
Explore this component in the M3E Gallery (GitHub Pages):

https://.github.io/material_3_expressive/

To run the Gallery locally:

cd apps/gallery
flutter run -d chrome
Last updated: 2025-10-23

Detailed Guide
What this package provides
A family of Material 3 Expressive app bars:

AppBarM3E — small/standard bar for Scaffold.appBar.
SliverAppBarM3E — Medium and Large collapsing variants for CustomScrollView.
All variants are powered by m3e_design tokens for consistent color, typography, and shape.

Installation
Monorepo (local path): already configured in this repo. Ensure packages/m3e_design exists.
Pub (when published): add to pubspec.yaml
dependencies:
  app_bar_m3e: ^0.1.0
  m3e_design: ^0.1.0
Minimum SDK: Dart >=3.5.0; Flutter >=3.22.0.

Dependencies
flutter
m3e_design
Quick start
Scaffold(
  appBar: const AppBarM3E(
    titleText: 'Inbox',
  ),
  body: ...,
);
Medium/Large collapsing:

CustomScrollView(
  slivers: [
    SliverAppBarM3E(
      variant: AppBarM3EVariant.large, // or AppBarM3EVariant.medium
      titleText: 'Gallery',
      pinned: true,
    ),
    // content...
  ],
)
Key parameters
titleText: String? — Text title when you don't pass a custom title widget.
title: Widget? — Custom title; overrides titleText.
leading: Widget? — Leading widget (e.g. Back button).
actions: List — Trailing actions.
centerTitle: bool — Centers the title on platforms that prefer it.
backgroundColor / foregroundColor: Color? — Override token-driven colors.
density: AppBarM3EDensity — compact/regular.
shapeFamily: AppBarM3EShapeFamily — round or square corners.
variant (SliverAppBarM3E): medium or large.
pinned / floating / snap (Sliver): Standard sliver app bar behaviors.
Theming with m3e_design
App bars read the M3ETheme extension from ThemeData. Example:

final base = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal));
final m3e = M3ETheme.defaults(base.colorScheme);
final theme = base.copyWith(extensions: [m3e]);
Accessibility
Meets 48×48 dp minimum hit target recommendations via tokens.
Proper contrast from token-driven color system.

button_m3e
Material 3 Expressive Buttons for Flutter — sizes XS→XL, round/square shapes, toggle selection, and 5 styles (filled/tonal/elevated/outlined/text).

See lib/src/button_tokens_adapter.dart for measurements & color mapping.

Live demo (Gallery)
Explore this component in the M3E Gallery (GitHub Pages):

https://.github.io/material_3_expressive/

To run the Gallery locally:

cd apps/gallery
flutter run -d chrome
Last updated: 2025-10-23

Detailed Guide
What this package provides
Material 3 Expressive buttons with 5 variants (filled, tonal, elevated, outlined, text), sizes XS–XL, round/square shapes, and optional toggle selection.

Installation
Monorepo (local path): already configured in this repo alongside m3e_design.
Pub (when published):
dependencies:
  button_m3e: ^0.1.0
  m3e_design: ^0.1.0
Minimum SDK: Dart >=3.5.0; Flutter >=3.19.0.

Dependencies
flutter
m3e_design
Quick start
ButtonM3E.filled(
  onPressed: () {},
  label: const Text('Save'),
  icon: const Icon(Icons.save),
  size: ButtonM3ESize.md,
  shapeFamily: ButtonM3EShapeFamily.round,
);
Key parameters
onPressed / onLongPress: callbacks for activation/long-press.
label: Widget? — Button label; omit for icon-only variants.
icon: Widget? — Optional leading icon.
isSelected: bool — Toggle selection state (for toggleable styles).
variant/style: ButtonM3EVariant — filled | tonal | elevated | outlined | text.
size: ButtonM3ESize — xs | sm | md | lg | xl.
shapeFamily: ButtonM3EShapeFamily — round or square.
tooltip / semanticsLabel: String? — Accessibility hints.
enabled: bool — Whether the button is interactive.
Theming with m3e_design
Buttons take colors, shapes, and spacing from M3ETheme. Override via properties or ThemeData when needed.

Accessibility
Ensures minimum 48×48 dp tap target size via layout tokens.
Focus, hover, and pressed states follow Material 3 guidance.

button_group_m3e
Material 3 Expressive grouped button layout and overflow management.

Current API (0.3.0)
children has been removed. Provide actions: List<ButtonGroupM3EAction>.

ButtonGroupM3E(
  actions: [
    ButtonGroupM3EAction(label: const Text('One'), onPressed: () {}),
    ButtonGroupM3EAction(label: const Text('Two'), onPressed: () {}),
    ButtonGroupM3EAction(label: const Text('Three'), onPressed: () {}),
  ],
  overflow: ButtonGroupM3EOverflow.menu, // default
)
Actions
class ButtonGroupM3EAction {
  const ButtonGroupM3EAction({
    required Widget label,
    Widget? icon,
    VoidCallback? onPressed,
    bool enabled = true,
    ButtonM3EStyle style = ButtonM3EStyle.filled,
    bool toggleable = false,
    bool selected = false,
    ValueChanged<bool>? onSelectedChange,
    ButtonM3EShape? shape,
  });
}
Group selection
Enable segmented styling:

int selectedIndex = 0;
ButtonGroupM3E(
  groupSelection: true,
  selectedIndex: selectedIndex,
  actions: [
    ButtonGroupM3EAction(label: const Text('Day'), onPressed: () => setState(() => selectedIndex = 0)),
    ButtonGroupM3EAction(label: const Text('Week'), onPressed: () => setState(() => selectedIndex = 1)),
    ButtonGroupM3EAction(label: const Text('Month'), onPressed: () => setState(() => selectedIndex = 2)),
  ],
)
Shape rules when groupSelection is true:

Selected button: fully round.
First & last (unselected): round.
Middle unselected buttons: square.
Overflow
menu (default): shows what fits + overflow trigger with remaining actions in a bottom sheet.
scroll: scrolls along main axis when constrained.
none: no handling (may overflow if parent allows).
Other parameters
type: standard | connected (divider seams, zero spacing)
shape: square | round (base shape family)
size: xs | sm | md | lg | xl
density: regular | compact
Layout: direction, wrap, spacing, runSpacing, alignment options.
equalizeWidths: enforce min widths per size for even visual rhythm.
Versioning
0.3.0 – BREAKING: removed children. Use actions.

ab_m3e
Material 3 Expressive Floating Action Buttons for Flutter:

FabM3E: circular FAB (small / regular / large)
ExtendedFabM3E: pill-shaped FAB with label (and optional icon)
FabMenuM3E: FAB menu (speed dial) with animated items (up/down/left/right)
All components read M3E tokens from m3e_design (ThemeExtension).

Monorepo Layout
packages/
  m3e_design/
  fab_m3e/
This package's pubspec.yaml references ../m3e_design.

Usage
FAB
import 'package:fab_m3e/fab_m3e.dart';

FabM3E(
  icon: const Icon(Icons.add),
  kind: FabM3EKind.primary,
  size: FabM3ESize.regular,
  onPressed: () {},
);
Extended FAB
ExtendedFabM3E(
  icon: const Icon(Icons.edit),
  label: const Text('Compose'),
  kind: FabM3EKind.secondary,
  onPressed: () {},
);
FAB Menu (Speed dial)
final controller = FabMenuController();

FabMenuM3E(
  controller: controller,
  alignment: Alignment.bottomRight,
  direction: FabMenuDirection.up,
  primaryFab: FabM3E(icon: const Icon(Icons.add), onPressed: controller.toggle),
  items: [
    FabMenuItem(
      icon: const Icon(Icons.photo),
      label: const Text('Photo'),
      onPressed: () {},
    ),
    FabMenuItem(
      icon: const Icon(Icons.note),
      label: const Text('Note'),
      onPressed: () {},
    ),
  ],
);
Theming via m3e_design
Background/foreground colors derive from kind:
primary → primaryContainer / onPrimaryContainer
secondary → secondaryContainer / onSecondaryContainer
tertiary → tertiaryContainer / onTertiaryContainer
surface → surfaceContainerHigh / onSurface
Sizes: small ≈40dp, regular ≈56dp, large ≈96dp
Extended FAB height ≈56dp
Elevations: rest 6, hover 8, pressed 12 (tweak in code or via tokens)
Shapes: round/square from m3e_design.shapes (extended uses StadiumBorder)
Notes
FabM3E uses RawMaterialButton to directly inject shape/elevation/colors with tokens.
ExtendedFabM3E uses Material + InkWell with stadium shape and token paddings.
FabMenuM3E stacks items near the primary FAB and animates scale + fade.
Provide your own Hero tags if coordinating transitions across pages.
License
MIT

Live demo (Gallery)
Explore this component in the M3E Gallery (GitHub Pages):

https://.github.io/material_3_expressive/

To run the Gallery locally:

cd apps/gallery
flutter run -d chrome
Last updated: 2025-10-23

Detailed Guide
What this package provides
Material 3 Expressive Floating Action Buttons:

FabM3E (standard)
ExtendedFabM3E (icon + label)
FabMenuM3E (expandable menu of FAB actions)
Installation
Monorepo (local path): already configured alongside m3e_design.
Pub (when published):
dependencies:
  fab_m3e: ^0.1.0
  m3e_design: ^0.1.0
Minimum SDK: Dart >=3.5.0; Flutter >=3.22.0.

Dependencies
flutter
m3e_design
Quick start
// Standard FAB
FabM3E(
  icon: const Icon(Icons.add),
  onPressed: () {},
)

// Extended FAB
ExtendedFabM3E(
  icon: const Icon(Icons.add),
  label: const Text('Add'),
  onPressed: () {},
)

// FAB Menu (example)
FabMenuM3E(
  children: [
    FabM3E(icon: const Icon(Icons.edit), onPressed: () {}),
    FabM3E(icon: const Icon(Icons.share), onPressed: () {}),
  ],
)
Key parameters
icon: Widget — Required for FabM3E and ExtendedFabM3E.
label: Widget? — Text label for ExtendedFabM3E.
onPressed: VoidCallback? — Action callback.
tooltip / semanticsLabel: String? — A11y hints.
shapeFamily: M3E shape family as exposed by tokens.
heroTag: Object? — For hero transitions.
mini: bool — Compact FAB sizing.
Theming with m3e_design
Colors/elevation/shape are token-driven via M3ETheme.

Accessibility
56dp standard, 40dp mini; high-contrast focus and pressed states.

icon_button_m3e
Expressive Material 3 icon button for Flutter — IconButtonM3E — with five sizes (XS–XL), four variants (standard, filled, tonal, outlined), round/square shapes, toggle support, and guaranteed 48×48dp tap targets (even when visual size is 32/40).

Highlights
Sizes: M3EIconButtonSize = XS, SM, MD, LG, XL
Widths: M3EIconButtonWidth = default, narrow, wide
Variants: standard, filled, tonal, outlined
Shapes: round (pill) or square (rounded rect)
Toggle: isSelected + selectedIcon
A11y: min 48×48dp hit target; semantics label/selected state
Tokens: centralized static values in M3EIconButtonTokens (no ThemeExtension)
Install
dependencies:
  icon_button_m3e:
    path: ../icon_button_m3e  # or from pub once published
Quick Start
import 'package:icon_button_m3e/icon_button_m3e.dart';

IconButtonM3E(
  variant: IconButtonM3EVariant.filled,
  size: M3EIconButtonSize.md,
  width: M3EIconButtonWidth.defaultWidth,
  icon: const Icon(Icons.mic),
  tooltip: 'Start recording',
  onPressed: () {},
);
Toggle
bool isFav = false;

IconButtonM3E(
  variant: IconButtonM3EVariant.tonal,
  isSelected: isFav,
  icon: const Icon(Icons.favorite_border),
  selectedIcon: const Icon(Icons.favorite),
  tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
  onPressed: () => setState(() => isFav = !isFav),
);
Sizing
Visual container sizes come from tokens: M3EIconButtonTokens.visual[size][width].
Minimum interactive target sizes come from M3EIconButtonTokens.target[size][width].
XS/SM enforce at least 48×48; others match their visual sizes.
Icon glyph sizes are in M3EIconButtonTokens.icon[size].
For example (default width):

XS: 32×32 visual, 48×48 target
SM: 40×40 visual, 48×48 target (SM wide: 52×48)
MD: 56×56
LG: 96×96
XL: 136×136
Colors and shapes
Colors are derived from your ThemeData.colorScheme:
standard: transparent bg, onSurfaceVariant fg (selected uses primary)
filled: primary bg, onPrimary fg
tonal: secondaryContainer bg, onSecondaryContainer fg
outlined: transparent bg, primary fg, outline border
Shapes: M3EIconButtonShapeVariant.round (pill) or .square (rounded square).
Pressed state uses a shared, more-square radius per size.
If used as a toggle, selected state flips round/square for expressive feel.
Example
Run the example app:

cd example
flutter run
License
MIT

Live demo (Gallery)
Explore this component in the M3E Gallery (GitHub Pages):

https://.github.io/material_3_expressive/

To run the Gallery locally:

cd apps/gallery
flutter run -d chrome
Last updated: 2025-10-23

Detailed Guide
What this package provides
Material 3 Expressive IconButtonM3E with multiple sizes, variants (filled/tonal/outlined/standard), round/square shapes, optional toggle selection, and accessible 48×48dp hit targets.

Installation
Monorepo (local path): already part of this repo.
Pub (when published):
dependencies:
  icon_button_m3e: ^0.1.1
Minimum SDK: Dart >=3.9.2; Flutter >=1.17.0.

Dependencies
flutter
Quick start
IconButtonM3E.filled(
  icon: const Icon(Icons.favorite),
  onPressed: () {},
  size: IconButtonM3ESize.md,
  shapeFamily: IconButtonM3EShapeFamily.round,
)
Key parameters
icon: Widget — Required.
onPressed / onLongPress: callbacks for activation.
isSelected: bool — Toggle state for selectable variants.
variant: IconButtonM3EVariant — filled | tonal | outlined | standard.
size: IconButtonM3ESize — xs | sm | md | lg.
shapeFamily: IconButtonM3EShapeFamily — round | square.
tooltip / semanticsLabel: String? — A11y hints.
Accessibility
Ensures minimum 48×48 dp touch target; focus and hover visuals included.

loading_indicator_m3e
Material 3 Expressive Loading Indicator for Flutter — a morphing polygon that continuously rotates and morphs between shapes (ported from Android's Material3 LoadingIndicator).

Two configurations:

Default — container uses secondaryContainer, active indicator uses primary
Contained — container uses primaryContainer, active indicator uses onPrimaryContainer
Token-aligned sizes:

Container: 48 × 48dp
Active indicator size: 38dp
Container shape: full (pill/circular) corners
Usage
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

// Default
const LoadingIndicatorM3E();

// Contained
const LoadingIndicatorM3E(variant: LoadingIndicatorM3EVariant.contained);

// Custom colors, custom polygon sequence
LoadingIndicatorM3E(
  color: Colors.teal,
  polygons: const [
    MaterialShapes.sunny,
    MaterialShapes.cookie9Sided,
    MaterialShapes.pill,
  ],
);
Notes
The inner morph sequence and animation timings match the Compose implementation:
Morph interval ~650ms, global rotation ~4666ms
Active size is scaled to ~38dp inside the 48dp container to avoid clipping while rotating
Requires your monorepo m3e_design (for tokens) and material_new_shapes (for RoundedPolygon + Morph + MaterialShapes). The pubspec.yaml is set up with path: ../....
Monorepo Layout
packages/
  m3e_design/
  material_new_shapes/
  loading_indicator_m3e/
Accessibility
Pass semanticLabel and semanticValue to announce loading status if needed.

License
Android/Compose implementation © Google, Apache-2.0
This package MIT
Live demo (Gallery)
Explore this component in the M3E Gallery (GitHub Pages):

https://.github.io/material_3_expressive/

To run the Gallery locally:

cd apps/gallery
flutter run -d chrome
Last updated: 2025-10-23

Detailed Guide
What this package provides
Morphing polygon LoadingIndicatorM3E with Default and Contained variants, aligned with Material 3 Expressive motion and color tokens.

Installation
Monorepo (local path): already configured alongside m3e_design.
Pub (when published):
dependencies:
  loading_indicator_m3e: ^0.1.0
  m3e_design: ^0.1.0
Minimum SDK: Dart >=3.5.0; Flutter >=3.22.0.

Dependencies
flutter
m3e_design
material_new_shapes
Quick start
// Default (indeterminate)
const LoadingIndicatorM3E()

// Contained variant (e.g., inside a container)
const LoadingIndicatorContainedM3E(width: 48, height: 48)
Key parameters
size / width / height: dimensions of the indicator.
color: Color? — Override the token-driven color.
semanticsLabel: String? — Describe what is loading for screen readers.
Theming with m3e_design
Colors and easing come from tokens in M3ETheme; motion aligns with Material 3 Expressive guidelines.

Accessibility
Provide semanticsLabel to announce loading; avoid infinite animations for long periods.

progress_indicator_m3e (spec build)
Visual rules implemented

Active and track never overlap.
Circular ring is broken around the active sweep.
Squiggle variants (48/52) draw a sine-like stroke inside the ring with 2dp clearance.
Linear shows two lanes (active above, track below) with fixed gap and end-dot, per table.
Linear variants

flatXS — track 4, gap 4, dot Ø4, dotOffset 4, trailing 4
flatS — track 8, gap 4, dot Ø4, dotOffset 2, trailing 8
wavyM — track 4, wave amp 3, period 40, gap 4, dot Ø4, dotOffset 2, trailing 10
wavyL — track 8, wave amp 3, period 40, gap 4, dot Ø4, dotOffset 2, trailing 14
Live demo (Gallery)
Explore this component in the M3E Gallery (GitHub Pages):

https://.github.io/material_3_expressive/

To run the Gallery locally:

cd apps/gallery
flutter run -d chrome
Last updated: 2025-10-23

Detailed Guide
What this package provides
Material 3 Expressive progress indicators with token-aligned colors and shapes, providing circular and linear variants with determinate and indeterminate modes.

Installation
Monorepo (local path): already configured alongside m3e_design.
Pub (when published):
dependencies:
  progress_indicator_m3e: ^0.3.0
  m3e_design: ^0.1.0
Minimum SDK: Dart >=3.3.0; Flutter >=3.19.0.

Dependencies
flutter
m3e_design
Quick start
// Indeterminate
const CircularProgressIndicatorM3E()

// Determinate
const LinearProgressIndicatorM3E(value: 0.6)
Key parameters
value: double? — 0.0..1.0 for determinate; null for indeterminate.
semanticsLabel: String? — Describe progress for screen readers.
backgroundColor / color: Color? — Override token colors.
Theming with m3e_design
Colors, track heights, and indicator shapes are driven by M3E tokens.

Accessibility
Always provide semanticsLabel when indeterminate; ensure sufficient contrast.

navigation_bar_m3e
Material 3 Expressive Navigation Bar for Flutter with badges, pill/underline indicators, and token-driven styling.

NavigationBarM3E — wrapper around Flutter's NavigationBar with M3E tokens
NavigationDestinationM3E — destination data (icon, selectedIcon, label, badge)
NavBadgeM3E — small badge/dot utility for icons
All styling is driven by the m3e_design ThemeExtension (M3ETheme).

Monorepo Layout
packages/
  m3e_design/
  navigation_bar_m3e/
pubspec.yaml references ../m3e_design.

Usage
import 'package:navigation_bar_m3e/navigation_bar_m3e.dart';

final items = [
  const NavigationDestinationM3E(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    label: 'Home',
  ),
  const NavigationDestinationM3E(
    icon: Icon(Icons.search),
    label: 'Search',
    badgeCount: 3,
  ),
  const NavigationDestinationM3E(
    icon: Icon(Icons.person),
    label: 'Profile',
    badgeDot: true,
  ),
];

NavigationBarM3E(
  destinations: items,
  selectedIndex: 0,
  onDestinationSelected: (i) {},
  labelBehavior: NavBarM3ELabelBehavior.onlySelected,
  indicatorStyle: NavBarM3EIndicatorStyle.pill, // pill | underline | none
  size: NavBarM3ESize.medium,
  density: NavBarM3EDensity.regular,
  shapeFamily: NavBarM3EShapeFamily.round,
);
Tokens mapping
Container: surfaceContainerHigh
Indicator: secondaryContainer (color), pill shape by default; underline style uses a bottom border
Selected: onSecondaryContainer (icon/label)
Unselected: onSurfaceVariant
Label style: labelMedium
Heights: small ≈64dp, medium ≈80dp
Icon size: 24dp
Badges
Use badgeCount for numeric badges or badgeDot: true for a small dot. Colors default to errorContainer / onErrorContainer and can be overridden via NavBadgeM3E.

Accessibility
Provide semanticLabel per destination (used as tooltip) or on the bar.
Label behavior options: alwaysShow, onlySelected, or alwaysHide.
License
MIT

Live demo (Gallery)
Explore this component in the M3E Gallery (GitHub Pages):

https://.github.io/material_3_expressive/

To run the Gallery locally:

cd apps/gallery
flutter run -d chrome
Last updated: 2025-10-23

Detailed Guide
What this package provides
NavigationBarM3E with M3E tokens for colors and shapes, badges, and adaptive layout behavior.

Installation
Monorepo (local path): already configured alongside m3e_design.
Pub (when published):
dependencies:
  navigation_bar_m3e: ^0.1.0
  m3e_design: ^0.1.0
Minimum SDK: Dart >=3.5.0; Flutter >=3.22.0.

Dependencies
flutter
m3e_design
Quick start
int index = 0;

NavigationBarM3E(
  selectedIndex: index,
  onDestinationSelected: (i) => setState(() => index = i),
  destinations: const [
    NavigationDestinationM3E(icon: Icon(Icons.home), label: 'Home'),
    NavigationDestinationM3E(icon: Icon(Icons.search), label: 'Search'),
    NavigationDestinationM3E(icon: Icon(Icons.person), label: 'Profile'),
  ],
)
Key parameters
destinations: List — Destinations to render.
selectedIndex: int — Current selection.
onDestinationSelected: ValueChanged — Selection callback.
badgeBuilder / badgeCount: Optional badges per destination.
backgroundColor / indicatorColor: Color? — Override token-driven colors.
height / labelBehavior: Layout tweaks.
Theming with m3e_design
Colors/shape/typography adapt from the active M3ETheme extension.

Accessibility
Labels visible or via semantics; badges have semantics descriptions.

navigation_rail_m3e
Material 3 Expressive Navigation Rail for Flutter — featuring collapsed & expanded variants, modal and standard presentation, sections, badges, menu and FAB slots, and smooth expand/collapse transitions. Built to match the M3 Expressive spec and integrate with the m3e_design token package.



Highlights
Collapsed (96 dp) and Expanded (220–360 dp) rails with animated transition
Expanded modal presentation with scrim
Optional menu and FAB/Extended FAB slots
Item badges (large numeric & small dot)
Sections with headers; full-width hit targets
Token-driven colors, typography & shapes via m3e_design (with safe fallbacks)
Quick start
NavigationRailM3E(
  type: NavigationRailM3EType.expanded,
  modality: NavigationRailM3EModality.standard,
  selectedIndex: 0,
  onDestinationSelected: (i) => setState(() => _index = i),
  onTypeChanged: (t) => setState(() => type = t),
  fab: NavigationRailM3EFabSlot(icon: const Icon(Icons.add), label: 'New', onPressed: () {}),
  sections: [
    NavigationRailM3ESection(
      header: const Text('Main'),
      destinations: [
        NavigationRailM3EDestination(
          icon: const Icon(Icons.edit_outlined),
          selectedIcon: const Icon(Icons.edit),
          label: 'Edit',
          largeBadgeCount: 0,
        ),
        NavigationRailM3EDestination(
          icon: const Icon(Icons.star_outline),
          selectedIcon: const Icon(Icons.star),
          label: 'Starred',
          smallBadge: true,
        ),
      ],
    ),
  ],
);
See the /example app for a runnable demo.

Live demo (Gallery)
Explore this component in the M3E Gallery (GitHub Pages):

https://.github.io/material_3_expressive/

To run the Gallery locally:

cd apps/gallery
flutter run -d chrome
Last updated: 2025-10-23

Detailed Guide
What this package provides
NavigationRailM3E with collapsed/expanded states, standard/modal presentation, badges, sections, and slots for FAB/menu. Integrates tightly with M3E tokens.

Installation
Monorepo (local path): already configured alongside m3e_design, fab_m3e, icon_button_m3e, button_m3e.
Pub (when published):
dependencies:
  navigation_rail_m3e: ^0.1.0
  m3e_design: ^0.1.0
  fab_m3e: ^0.1.0
  icon_button_m3e: ^0.1.1
  button_m3e: ^0.1.0
Minimum SDK: Dart >=3.0.0.

Dependencies
flutter
m3e_design, fab_m3e, icon_button_m3e, button_m3e
Quick start
NavigationRailM3E(
  selectedIndex: 0,
  onDestinationSelected: (i) {},
  expanded: true,
  modal: false,
  leading: const FabM3E(icon: Icon(Icons.add)),
  destinations: const [
    NavigationRailDestinationM3E(icon: Icon(Icons.inbox), label: 'Inbox'),
    NavigationRailDestinationM3E(icon: Icon(Icons.send), label: 'Sent'),
  ],
)
Key parameters
expanded: bool — Expanded vs collapsed rail.
modal: bool — Modal overlay vs standard inline rail.
destinations: List — Items to render.
selectedIndex: int; onDestinationSelected: ValueChanged — Selection handling.
leading / trailing: Widget? — Header/footer area.
fab / menu slots: Widgets for actions and menus.
badgeBuilder / badgeCount: Optional per-item badges.
Theming with m3e_design
Rail colors, indicator style, and typography adapt from M3ETheme.

Accessibility
Keyboard navigation, focus order, and semantics supported.

slider_m3e
Material 3 Expressive Sliders for Flutter. Single-value and range sliders, with token-driven colors, sizes, and shapes.

SliderM3E — single-value slider, optional start/end icons, discrete or continuous
RangeSliderM3E — range selection with the same styling
sliderThemeM3E(...) — generate a SliderThemeData from M3E tokens
All styling reads the M3ETheme ThemeExtension from your m3e_design package.

Monorepo Layout
packages/
  m3e_design/
  slider_m3e/
pubspec.yaml references ../m3e_design.

Usage
import 'package:slider_m3e/slider_m3e.dart';

// Single slider
SliderM3E(
  value: 0.35,
  onChanged: (v) {},
  divisions: 10, // discrete
  size: SliderM3ESize.large,
  emphasis: SliderM3EEmphasis.primary,
  shapeFamily: SliderM3EShapeFamily.round, // or square (expressive)
  startIcon: const Icon(Icons.volume_mute),
  endIcon: const Icon(Icons.volume_up),
);

// Range slider
RangeSliderM3E(
  values: const RangeValues(0.2, 0.8),
  onChanged: (r) {},
  divisions: 8,
  size: SliderM3ESize.medium,
  emphasis: SliderM3EEmphasis.secondary,
  shapeFamily: SliderM3EShapeFamily.square,
);
Tokens mapping
Colors:
Active: primary / secondary / onSurface (by emphasis)
Inactive track: onSurface @ 24% opacity
Overlay: active color @ 12% opacity
Value indicator: secondaryContainer with onSecondaryContainer text
Sizes:
Track height: small ≈2dp, medium ≈4dp, large ≈6dp
Thumb radius: small ≈10dp, medium ≈12dp, large ≈14dp
Density: compact slightly reduces track and thumb sizes
Shapes: round uses round thumb, square uses a rounded-rect thumb for an expressive look
Accessibility
Set semanticLabel to announce values (percentage format by default).
Discrete sliders (with divisions) will show value indicators when showValueIndicator is enabled (or onlyForDiscrete by default).
License
MIT

Live demo (Gallery)
Explore this component in the M3E Gallery (GitHub Pages):

https://.github.io/material_3_expressive/

To run the Gallery locally:

cd apps/gallery
flutter run -d chrome
Last updated: 2025-10-23

Detailed Guide
What this package provides
SliderM3E and RangeSliderM3E that follow Material 3 Expressive tokens for colors, shapes, and density.

Installation
Monorepo (local path): already configured alongside m3e_design.
Pub (when published):
dependencies:
  slider_m3e: ^0.1.0
  m3e_design: ^0.1.0
Minimum SDK: Dart >=3.5.0; Flutter >=3.22.0.

Dependencies
flutter
m3e_design
Quick start
// Single-value slider
SliderM3E(
  value: value,
  onChanged: (v) => setState(() => value = v),
  min: 0,
  max: 100,
  divisions: 10,
  label: '$value',
)

// Range slider
RangeSliderM3E(
  values: range,
  onChanged: (r) => setState(() => range = r),
  min: 0,
  max: 100,
)
Key parameters
value: double — Current slider value (SliderM3E).
values: RangeValues — Current range (RangeSliderM3E).
onChanged: ValueChanged<double/RangeValues> — Callback for value changes.
min / max / divisions: Configure value domain and discrete steps.
label: String? — Optional value label.
activeColor / inactiveColor / thumbColor: Color? overrides.
Theming with m3e_design
Track shape, thickness, and colors follow M3E tokens; respects density.

Accessibility
Ensure sufficient contrast; provide semantics via labels when necessary.

split_button_m3e
Material 3 Expressive Split Button for Flutter. Two-segment control:

Leading: primary action (icon, label, or both)
Trailing: menu trigger (chevron)
All sizes, paddings, radii, and offsets are token-driven, aligned to measurement boards.

Quick start
import 'package:split_button_m3e/split_button_m3e.dart';

SplitButtonM3E<String>(
  size: SplitButtonM3ESize.md,
  shape: SplitButtonM3EShape.round,
  emphasis: SplitButtonM3EEmphasis.tonal,
  label: 'Save',
  leadingIcon: Icons.save_outlined,
  onPressed: () => debugPrint('Primary pressed'),
  items: const [
    SplitButtonM3EItem<String>(value: 'draft', child: 'Save as draft'),
    SplitButtonM3EItem<String>(value: 'close', child: 'Save & close'),
  ],
  onSelected: (v) => debugPrint('Selected: $v'),
  // Optional tooltips help with semantics and tests
  leadingTooltip: 'Save',
  trailingTooltip: 'Open menu',
);
Behavior and layout
Two segments with a fixed inner gap of 2dp.
Trailing chevron rotates 180° when the menu is open.
Menu opens aligned to the trailing edge of the arrow button (right edge in LTR, left in RTL).
Optical chevron offset is applied only in the unselected (closed) state for asymmetrical layout.
Pressed/expanded shape morph follows the expressive M3 pattern:
MD/LG/XL: when shape = round and arrow is pressed or menu is open, the trailing segment morphs into a perfect circle (diameter = control height), no inner padding, no optical offset.
XS/SM: no circle morph in selected state. The selected trailing segment uses a fixed total width of 48dp with side paddings of 13dp.
Each segment maintains a minimum touch target of 48dp.
Tokens (by size)
Heights

XS 32 · S 40 · M 56 · L 96 · XL 136
Trailing width (centered chevron)

XS 22 · S 22 · M 26 · L 38 · XL 50
Inner gap (between segments)

2dp
Inner corner radius (facing edges)

XS 4 · S 4 · M 4 · L 8 · XL 12
Icon sizes

XS 20 · S 24 · M 24 · L 32 · XL 40
Optical chevron offset (unselected/resting)

XS −1 · S −1 · M −2 · L −3 · XL −6
Asymmetrical (unselected) paddings and blocks

XS: leadingIconBlock 20, leftOuter 12, gap icon→label 4, labelRight 10, trailingLeftInner 12, rightOuter 14
S: leadingIconBlock 20, leftOuter 16, gap 8, labelRight 12, trailingLeftInner 12, rightOuter 14
M: leadingIconBlock 24, leftOuter 24, gap 8, labelRight 24, trailingLeftInner 13, rightOuter 17
L: leadingIconBlock 32, leftOuter 48, gap 12, labelRight 48, trailingLeftInner 26, rightOuter 32
XL: leadingIconBlock 40, leftOuter 64, gap 16, labelRight 64, trailingLeftInner 37, rightOuter 49
Symmetrical (selected) trailing segment

Trailing width (centered chevron) + side padding ×2
Side padding per size: XS 13 · S 13 · M 15 · L 29 · XL 43
Special case: XS/SM selected total width is 48 (22 + 13 + 13) with 13dp side padding; no full rounding.
Pressed morph radii

Per-size pressed radius tokens are applied to the pressed segment; when round and MD/LG/XL, trailing becomes a circle while pressed/open.
API summary
Props

size: SplitButtonM3ESize (xs, sm, md, lg, xl)
shape: SplitButtonM3EShape (round, square)
emphasis: SplitButtonM3EEmphasis (filled, tonal, elevated, outlined, text)
label: String? (leading segment)
leadingIcon: IconData? (leading segment icon)
onPressed: VoidCallback? (leading action)
items: List<SplitButtonM3EItem>? (trailing menu items), or
menuBuilder: List<PopupMenuEntry> Function(BuildContext)?
onSelected: ValueChanged? (when an item is chosen)
trailingAlignment: SplitButtonM3ETrailingAlignment (opticalCenter, geometricCenter)
leadingTooltip, trailingTooltip: String? (for semantics/UX)
enabled: bool (default true)
Items

const SplitButtonM3EItem<T>({
  required T value,
  required Object child, // plain string or Widget
  bool enabled = true,
});
Accessibility
Each segment is independently focusable; minimum 48×48dp hit target.
Tooltips provide accessible names; you can supply copy like “Open menu”.
Chevron rotation and selected state are conveyed via menu open/close.
Example (menuBuilder)
SplitButtonM3E<int>(
  size: SplitButtonM3ESize.md,
  shape: SplitButtonM3EShape.square,
  label: 'More',
  leadingIcon: Icons.more_horiz,
  onPressed: () => debugPrint('Primary'),
  menuBuilder: (context) => [
    const PopupMenuItem<int>(value: 1, child: Text('Option 1')),
    const PopupMenuItem<int>(value: 2, child: Text('Option 2')),
  ],
  onSelected: (v) => debugPrint('Picked $v'),
  trailingAlignment: SplitButtonM3ETrailingAlignment.opticalCenter,
);
Notes
Menu aligns to the trailing arrow’s edge (LTR right, RTL left).
Optical centering is applied only when the menu is closed (unselected asymmetrical state).
When shape=round and size is MD/LG/XL, the trailing segment becomes a perfect circle while pressed/open; XS/SM remain rectangular with the selected geometry (48 total width, 13 side padding).
License
MIT

Live demo (Gallery)
Explore this component in the M3E Gallery (GitHub Pages):

https://.github.io/material_3_expressive/

To run the Gallery locally:

cd apps/gallery
flutter run -d chrome
Last updated: 2025-10-23

Detailed Guide
What this package provides
SplitButtonM3E: a two-part button with a primary action and a dropdown menu, with sizes, variants, shapes, and accessible minimum hit targets. Keyboard navigation supported.

Installation
Monorepo (local path): already configured alongside m3e_design.
Pub (when published):
dependencies:
  split_button_m3e: ^0.1.0
  m3e_design: ^0.1.0
Minimum SDK: Dart >=3.9.2; Flutter >=1.17.0.

Dependencies
flutter
m3e_design
Quick start
SplitButtonM3E(
  label: const Text('Share'),
  primaryAction: () { /* do default share */ },
  menuItems: const [
    SplitButtonItemM3E(label: Text('Copy link'), value: 'copy'),
    SplitButtonItemM3E(label: Text('Email'), value: 'email'),
  ],
  onSelected: (value) {
    // handle from menu
  },
)
Key parameters
label: Widget — Visible label next to the caret.
primaryAction: VoidCallback — Action when the main segment is tapped.
menuItems: List — Menu options.
onSelected: ValueChanged — Callback when a menu item is chosen.
variant/style: filled | tonal | elevated | outlined.
size: xs | sm | md | lg | xl.
shapeFamily: round | square.
isExpanded: bool — Whether to take full width when allowed.
Accessibility
Both segments meet 48×48dp minimum size; keyboard and screen reader friendly.

toolbar_m3e
Material 3 Expressive toolbar for Flutter – a compact action bar that can host a title/subtitle, leading widget, inline actions, and an overflow menu. All styling is driven by m3e_design tokens.

ToolbarM3E — the main toolbar widget (PreferredSizeWidget) for use in Scaffold or as a standalone header
ToolbarActionM3E — action model consumed by the toolbar
Inline actions render as icon buttons; extra actions go into a PopupMenuButton overflow
Monorepo Layout
packages/
  m3e_design/
  toolbar_m3e/
pubspec.yaml references ../m3e_design.

Usage
import 'package:toolbar_m3e/toolbar_m3e.dart';

final actions = [
  ToolbarActionM3E(
    icon: Icons.search,
    onPressed: () {},
    tooltip: 'Search',
  ),
  ToolbarActionM3E(
    icon: Icons.share_outlined,
    onPressed: () {},
    tooltip: 'Share',
  ),
  ToolbarActionM3E(
    icon: Icons.delete_outline,
    onPressed: () {},
    tooltip: 'Delete',
    isDestructive: true,
    label: 'Delete', // used in overflow
  ),
];

ToolbarM3E(
  leading: const BackButton(),
  titleText: 'Selection',
  subtitleText: '3 items',
  actions: actions,
  maxInlineActions: 2, // remaining actions go to overflow
  variant: ToolbarM3EVariant.tonal, // surface | tonal | primary
  size: ToolbarM3ESize.medium,      // small | medium | large
  density: ToolbarM3EDensity.regular,
  shapeFamily: ToolbarM3EShapeFamily.round,
  centerTitle: false,
);
Tokens mapping
Container: surfaceContainerHigh (surface) / secondaryContainer (tonal) / primaryContainer (primary)
Foreground: onSurface / onSecondaryContainer / onPrimaryContainer
Shape: uses M3E round / square set (md radius)
Heights: small ≈40dp, medium ≈48dp, large ≈56dp
Icon size: 24dp
Padding: horizontal from tokens (spacing.md)
Overflow
Set maxInlineActions to the number of actions that should stay inline. Any additional actions go to the overflow menu (labels pulled from label or tooltip/semanticLabel). Destructive actions can be highlighted by isDestructive: true.

Accessibility
Provide semanticLabel on the toolbar if useful.
Actions expose tooltip and can set semanticLabel to improve assistive tech hints.
License
MIT

Live demo (Gallery)
Explore this component in the M3E Gallery (GitHub Pages):

https://.github.io/material_3_expressive/

To run the Gallery locally:

cd apps/gallery
flutter run -d chrome
Last updated: 2025-10-23

Detailed Guide
What this package provides
ToolbarM3E with token-driven size, density, color, shape, and overflow handling (e.g., automatic menu when there isn’t enough space).

Installation
Monorepo (local path): already configured alongside m3e_design and button/icon packages.
Pub (when published):
dependencies:
  toolbar_m3e: ^0.1.0
  m3e_design: ^0.1.0
Minimum SDK: Dart >=3.5.0; Flutter >=3.22.0.

Dependencies
flutter
m3e_design
Quick start
ToolbarM3E(
  actions: [
    ToolbarActionM3E(icon: Icons.copy, onPressed: () {}),
    ToolbarActionM3E(icon: Icons.paste, onPressed: () {}),
    ToolbarActionM3E(icon: Icons.delete_outline, onPressed: () {}),
  ],
  overflowBehavior: ToolbarOverflowBehaviorM3E.menu,
)
Key parameters
actions: List — Items shown on the toolbar.
overflowBehavior: menu | wrap | clip — How to handle overflow.
density: compact | regular — Affects height and spacing.
backgroundColor / foregroundColor: Color? overrides.
shapeFamily: round | square.
Theming with m3e_design
Toolbar colors, shape, and spacing come from M3ETheme tokens; density adjusts measurements.

Accessibility
Buttons maintain 48×48dp minimum; provide tooltips/semantics for each action.
