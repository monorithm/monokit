# Monokit gallery

This runnable example targets web, Android, and iOS. It is a named-route,
multi-screen documentation app for the complete Monokit widget system. Routes
use the token-timed fade transition supplied by `MonokitApp`.

- **Overview** — Monokit architecture, theme tokens, and component groups.
- **Foundations** — app shell, responsive chrome, motion, backdrops, icons, and automatic scopes.
- **Actions & feedback** — buttons, badges, cards, alerts, progress, loading, avatars, and attachments.
- **Forms** — field composition, text inputs, OTP, selection controls, comboboxes, and stateful form examples.
- **Navigation** — menus, breadcrumbs, tabs, accordions, pagination, and the responsive sidebar.
- **Overlays** — dialogs, drawers, sheets, popovers, tooltips, hover cards, contextual menus, dropdowns, and commands.
- **Messaging** — message anatomy, bubbles, reactions, attachments, aliases, and a live message scroller.
- **Primitives** — interaction states, pressables, focus rings, overlay handles, resolvers, and the Material adapter.

Use the header menu or the persistent sidebar to move between routes. Route
selections keep normal navigator history, so browser and platform Back return
through the documentation. Each card contains a live component example and,
where useful, a small usage sketch.

Run the gallery in Chrome for the fastest iteration loop:

```bash
flutter run -d chrome
```

Or build an Android debug APK:

```bash
flutter build apk --debug
```
