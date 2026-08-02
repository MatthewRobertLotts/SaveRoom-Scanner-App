# Flutter Modern UI Recommendations for SaveRoom Scanner

Tags: #type/report #flutter #ui #saveroom

## Overview

This report maps the supplied **Flutter Modern UI Widgets, Themes & Package Stack** report to the current SaveRoom Scanner App at repo HEAD `dec6dd6` / UI milestone `9f805bd`.

The source report is directionally strong, especially its preference for Material 3, native Flutter widgets, responsive layouts, accessible controls, layered dark surfaces, and restrained motion. Its proposed production dependency stack is too broad for the current app. SaveRoom already has an accepted Collector Pro layout, a working Material 3 theme, stable named routes, a reliable image-candidate fallback system, and only one non-Flutter runtime dependency (`http`). Replacing those working parts would add migration risk without unlocking a current user need.

**Recommendation:** keep native Material 3 and the current architecture. Implement a small native-widget/accessibility pass first. Add specialised packages only when real backend data or measured shortcomings justify them.

## Current Project Baseline

| Area | Current implementation | Assessment |
|---|---|---|
| Theme | Material 3, seed-generated dark `ColorScheme`, custom cards/buttons/type in `lib/app/app_theme.dart` | Good base; deepen with native component themes rather than replacing it |
| Home | Dashboard hero, metric cards, 2×2 action grid, recent-card rail in `lib/features/home/home_screen.dart` | Already matches the report's dashboard direction |
| Card detail | Accepted Collector Pro image/facts layout, overview/evidence/history visual strip, bottom actions in `lib/features/cards/card_detail_screen.dart` | Preserve; avoid a speculative sliver rewrite |
| Images | Candidate retry, timeouts, proportional 5:7 rendering and `BoxFit.contain` in `lib/widgets/card_image_panel.dart` and `card_thumbnail.dart` | Working specialised implementation; do not replace yet |
| Search | Debounced API search, stale-request guard, filters, large result rows in `lib/features/scanner/scanner_screen.dart` | `SearchAnchor` would not improve the real search flow |
| Routing | Small named-route map in `lib/app/app_routes.dart` | Adequate until deep links or route restoration are required |
| State | `FutureBuilder`, local `State`, and `ValueNotifier` for recent cards | Adequate for current screen/data complexity |
| Dependencies | Flutter + `http` only | Excellent; keep it lean |

## Implement Next: Native Flutter Only

### 1. Accessibility and responsive hardening — highest value

**Where**

- `lib/features/cards/card_detail_screen.dart`
- `lib/widgets/card_image_panel.dart`
- `lib/widgets/card_thumbnail.dart`
- `lib/features/scanner/scanner_screen.dart`
- relevant widget tests under `test/`

**Worth implementing**

- Test the accepted screens at 200% text scale and narrow landscape widths.
- Add useful `Semantics` labels to card art, scanner capture control, icon-only controls and status indicators.
- Keep interactive targets at least 48 logical pixels.
- Replace fixed-height assumptions only where UAT/tests prove clipping.
- Use `LayoutBuilder` based on available width, not device-type checks.

**Specific issue to verify:** `_collectorProHeader()` says the split layout is for widths above 600dp, but currently sets `wide = constraints.maxWidth >= 360`. That sends almost every normal phone into the horizontal split. Verify on the emulator before changing it; if text scaling or narrow-screen UAT shows wrapping, make the breakpoint match the actual layout requirement rather than adding another responsive package.

**Why now:** this protects the layout already approved by Matthew and catches real usability regressions without changing the design system.

### 2. Full-screen card zoom with `InteractiveViewer`

**Where**

- `lib/widgets/card_image_panel.dart`

**Implementation direction**

- Make the successfully loaded card image tappable.
- Open a native full-screen dialog or route containing `InteractiveViewer`.
- Reuse the existing image candidate and fallback logic.
- Add a semantic label and obvious close control.

**Why:** it is immediately useful in a trading-card app and Flutter already provides the required pan/zoom behaviour. Do not add `extended_image` solely for zoom.

### 3. Replace decorative controls with real controls—or remove them

**Where**

- `_DetailTabs` in `lib/features/cards/card_detail_screen.dart`
- `_HomeBottomNav` in `lib/features/home/home_screen.dart`

**Current problem**

- `Overview / Evidence / History` looks interactive but is a static row.
- Home bottom navigation looks interactive but is a static row of labels.

**Recommendation**

- Do not build empty tab pages.
- Keep the detail strip only when it switches real content; then use native `SegmentedButton` or `TabBar.secondary`.
- When app-wide navigation is meant to work, replace `_HomeBottomNav` with Material 3 `NavigationBar` and wire the existing routes.
- Until those destinations are functional, removing misleading controls is better than adding placeholder navigation.

### 4. Centralise the existing theme slightly

**Where**

- `lib/app/app_theme.dart`
- existing shared widgets such as `section_card.dart`, `status_pill.dart`, and `saveroom_shell.dart`

**Worth implementing**

- Keep `ColorScheme.fromSeed` and Material 3.
- Move repeated component styling into native `ThemeData` component themes: `inputDecorationTheme`, `chipTheme`, `navigationBarTheme`, and button states when those components are used.
- Shift the current near-black background toward a slightly bluer layered background only if emulator UAT confirms the hierarchy improves.
- Use existing `ColorScheme` roles before inventing scanner-specific colours.

**Do not add a `ThemeExtension` yet.** Add one only when at least two real screens need the same specialist tokens, such as price-up/down, stale-data, confidence, and chart colours.

### 5. Subtle built-in state transitions

**Where**

- Search loading/error/empty transitions in `scanner_screen.dart`
- Price/no-price state in `card_detail_screen.dart`

**Worth implementing**

- Use `AnimatedSwitcher` for small state replacements where it reduces abrupt visual changes.
- Keep animation durations around 150–250ms.
- Respect reduced-motion settings.

**Do not add `flutter_animate` yet.** The app has no animation requirement that native implicit widgets cannot satisfy.

## Add Only When the Backing Feature Exists

| Widget/package | Decision | Add when | Where it would belong |
|---|---|---|---|
| `fl_chart` | Defer | The API exposes useful price-history points and the product needs 7D/30D/90D views | New market module under card detail |
| `SegmentedButton` | Use later | Raw/graded, currency, chart-period, or real detail sections have working state | Card detail market controls |
| `Badge` | Use later | Owned quantity, evidence counts, or alerts are real values | Identity strip, collection navigation |
| `showModalBottomSheet` | Use later | Add-to-inventory has a backend workflow | Card detail bottom action |
| `MenuAnchor` | Use later | Share/report/copy-card-key actions are implemented | Card detail app-bar actions |
| `flutter_svg` | Defer | Real set symbols, brand vectors or SVG badges are supplied | Card identity and set metadata |
| `Skeletonizer` | Defer | Emulator measurement shows detail loading causes unacceptable visual shift | Card detail loading state |
| `extended_image` | Defer | Disk caching/offline gallery/double-tap zoom cannot be handled cleanly by the existing image code | Shared card image widgets |
| `CarouselView` | Skip for now | Matthew explicitly re-approves variants or alternate images | Card detail variant browser |
| `DraggableScrollableSheet` | Defer | Evidence or inventory forms genuinely need an expandable scrolling sheet | Card detail actions/evidence |
| `two_dimensional_scrollables` | Defer | A desktop evidence table with pinned headers exists | Wide-screen market evidence |
| `NavigationRail` | Defer | Tablet/desktop becomes a supported workflow | App shell, not card detail |

## Packages Not Worth Adding Now

### `flex_color_scheme`

The app already has a short, readable Material 3 theme. FlexColorScheme would mostly replace code that is working. Reconsider only if maintaining light/dark schemes and many component states becomes genuinely repetitive.

### `google_fonts`

Do not add a runtime font package for visual polish alone. If the final brand requires Inter, bundle the font assets for deterministic offline builds. Android's current type remains acceptable until typography becomes a confirmed design requirement.

### `lucide_icons_flutter`

Current Material icons are consistent and already available. Adding Lucide would create an app-wide icon migration for a small stylistic gain. Reconsider only during a deliberate brand-system revision.

### `flutter_riverpod`

Current `FutureBuilder`, local state and `ValueNotifier` usage fit the app. Add Riverpod only when card detail has several independently refreshing resources—such as identity, market, evidence, variants and inventory—and the existing state handling becomes demonstrably tangled.

### `go_router`

The current route table is small and stable. Add `go_router` only when the app needs shareable/deep-linked card URLs, nested navigation, browser URL restoration or guarded auth routes.

### Forui / shadcn UI libraries

Do not mix another full component system into the accepted Material 3 app. A Forui/shadcn prototype would only make sense on an isolated branch if Matthew explicitly chooses a full visual-system redesign.

### Rive, Lottie, Wolt sheets, staggered grids and sliver helper packages

No current requirement justifies them. Native widgets cover the existing screens. Add one only for a named feature that cannot be kept small with Flutter itself.

## Source Report Recommendations to Reject for This Project

1. **Do not install the full proposed dependency set.** Eleven new runtime packages would create upgrade, compatibility and maintenance work before the corresponding features exist.
2. **Do not rebuild the accepted card detail around slivers immediately.** `CustomScrollView` and `SliverAppBar` are useful, but the present Collector Pro layout is approved and functional. Revisit when pinned navigation, tablet split layout or long market history makes the current `SaveRoomShell` inadequate.
3. **Do not add a variant carousel.** Variant/swipe UI was rejected in UAT and must remain out unless explicitly re-approved.
4. **Do not replace search with `SearchAnchor`.** The custom field already owns debounce, API state, stale-response protection, filters and result presentation.
5. **Do not replace working image fallback code just to gain caching.** Add caching only after measuring repeated network cost or defining offline requirements.
6. **Do not create empty Market, Variants and Collection modules.** Their backend data/workflows do not yet exist.

## Recommended Implementation Order

### Next small UI session

1. Add accessibility labels and a 200%-text/narrow-width widget check.
2. Verify and, only if needed, correct the card-detail responsive breakpoint.
3. Add native full-screen `InteractiveViewer` card zoom.
4. Remove or defer any control that still looks interactive but has no action.

This should remain a small native-Flutter change with no new dependencies.

### After v12.3/v12.4 backend foundations

1. Wire real inventory and wishlist actions through native modal sheets.
2. Introduce proper detail sections only when Overview/Market/Collection have real data.
3. Add Riverpod only if those independent asynchronous resources make current state handling unwieldy.
4. Add `fl_chart` only when price-history data is available and trustworthy.
5. Add deep linking/router changes only when cards need shareable URLs or auth guards.

## Decision Summary

| Priority | Decision |
|---|---|
| Implement next | Accessibility/text scaling, constraint-based responsive verification, native `InteractiveViewer`, honest interactive controls |
| Improve opportunistically | Native Material component themes and small `AnimatedSwitcher` transitions |
| Defer until data exists | Charts, inventory sheets, badges, SVG set symbols, skeleton loading, independent async state architecture |
| Skip | Variant carousel, full sliver rewrite, full package stack, alternate UI kits, decorative animation packages |

## Links

- Source: `../.hermes/desktop-attachments/Flutter_Modern_UI_Widgets_Themes_Report_2026-3.pdf`
- Current theme: `../lib/app/app_theme.dart`
- Home dashboard: `../lib/features/home/home_screen.dart`
- Card detail: `../lib/features/cards/card_detail_screen.dart`
- Search/scanner: `../lib/features/scanner/scanner_screen.dart`
- Card images: `../lib/widgets/card_image_panel.dart`
- Routes: `../lib/app/app_routes.dart`
- Roadmap: `ROADMAP.md`
