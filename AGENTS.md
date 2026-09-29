# Noctalia Plugin Development Guidelines

This document provides guidelines for creating and updating plugins for [Noctalia](https://github.com/noctalia-dev/noctalia) in this repository.

## Project Structure

Each plugin MUST be contained within its own directory named after the plugin's slug (the part of the ID after the `/`).

```
noctalia-plugins/
├── catalog.toml             # Registry of all plugins in this repo (optional if not publishing to community)
├── plugin-slug/
│   ├── plugin.toml          # Plugin manifest (metadata, entries, settings)
│   ├── translations/
│   │   └── en.json          # Localization strings (required if label_keys are used)
│   ├── service.luau         # Background service logic (optional)
│   ├── widget.luau          # Bar widget logic (optional)
│   └── panel.luau           # Panel UI logic (optional)
```

## Configuration Files

### `catalog.toml`
The root `catalog.toml` lists all available plugins for discovery in this repository.

```toml
[[plugin]]
id = "author/plugin-slug"
name = "Plugin Display Name"
version = "1.0.0"
updated_at = 1790663319
added_at = 1790663319
author = "author"
license = "MIT"
icon = "chart"                # Tabler icon name
description = "Short description of the plugin."
plugin_api = 3                # Must match plugin.toml
tags = ["tag1", "tag2"]
```

### `plugin.toml`
Each plugin MUST have a `plugin.toml` defining its identity, components, and settings.

**Required Fields:**
- `id`: Format `<author>/<plugin-name>` (e.g., `me/hello`). Must be lowercase alphanumeric with dots, dashes, or underscores.
- `name`: Display name.
- `version`: Semver `MAJOR.MINOR.PATCH`.
- `plugin_api`: Minimum API level required (currently 3–32).
- `author`: Author name.
- `license`: License identifier (defaults to MIT).

**Optional Fields:**
- `icon`: Tabler icon name.
- `description`: Max 120 chars.
- `tags`: Array of strings for catalog search.
- `dependencies`: Array of external tool names (metadata only).

**Entry Types (Array of Tables):**
- `[[widget]]`: Bar widget.
- `[[service]]`: Headless background service.
- `[[panel]]`: Pop-up surface.
- `[[shortcut]]`: Control-center tile.
- `[[launcher_provider]]`: Answers queries behind a prefix.
- `[[desktop_widget]]`: Desktop tile.

**Example:**
```toml
id         = "me/hello"
name       = "Hello"
version    = "1.0.0"
plugin_api = 3
author     = "me"

[[widget]]
id    = "hello"
entry = "widget.luau"
  [[widget.setting]]
  key       = "label"
  type      = "string"
  label_key = "settings.label.label"
  default   = "Hello"

[[service]]
id    = "ticker"
entry = "ticker.luau"
```

## Coding Standards

### Language
- All logic MUST be written in **Luau**.
- Scripts MUST start with the strictness mode comment:
  ```lua
  --!nonstrict
  ```
- Use `nonstrict` mode (as defined in `.luaurc`).

### Localization
- All user-facing strings MUST be externalized in `translations/<lang>.json`.
- Reference strings in code via their keys (e.g., `settings.mode.label`).
- **Never hardcode** display text in Luau files.

### Entry Point Functions
Noctalia calls specific global functions based on the entry type:

| Function | Widget | Shortcut | Launcher | Desktop | Panel | Service |
|----------|--------|----------|----------|---------|-------|---------|
| `update()` | ✓ | ✓ | ✓ | ✓ | | every tick |
| `onClick()` | ✓ | ✓ | | | | click |
| `onRightClick()` | ✓ | | | | | right-click |
| `onMiddleClick()` | ✓ | | | | | middle-click |
| `onScroll(axis, steps, startsGesture)` | ✓ | | | | | scroll |
| `onQuery(text)` | | | ✓ | | | launcher query |
| `onActivate(id)` | | | ✓ | | | result selected |
| `onOpen(context)` / `onClose()` | | | | | ✓ | panel open/close |
| `onEnable()` | | | | | | ✓ | plugin enabled |
| `onConfigChanged()` | | | | | | ✓ | settings changed |
| `onExit(signal, reason)` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | cleanup |
| `onIpc(event, payload)` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | IPC message |

### Service State Sharing
Services can share state with widgets via the `noctalia.state` API:
```lua
noctalia.state.set("tick", count)
noctalia.state.get("tick")
noctalia.state.watch("tick", function(value) ... end)
```

### Widget Presentation
Widgets use the `barWidget` API to update their appearance:
```lua
barWidget.setText("Hello")
barWidget.setGlyph("puzzle")
barWidget.setTooltip("CPU: 42%")
barWidget.setColor("primary")
barWidget.setFont("JetBrains Mono", "text")
barWidget.setVisible(true)
barWidget.render(tree)  -- declarative alternative
```

## Updating Plugins

1.  **Update Version**: Increment the `version` field in both `plugin.toml` and `catalog.toml`.
2.  **Update Metadata**: Ensure `catalog.toml` remains in sync with `plugin.toml`.
3.  **Translations**: Add new keys to `translations/en.json` (and other languages if supported).

## Adding New Plugins

1.  Create a new directory for the plugin slug.
2.  Add a `plugin.toml` with the required metadata and entry definitions.
3.  Implement the plugin logic in `.luau` files (remembering `--!nonstrict`).
4.  Register the plugin in the root `catalog.toml`.

## Local Development

1.  Place the plugin directory under `$XDG_DATA_HOME/noctalia/plugins/<plugin>/`.
2.  Alternatively, add a path source:
    ```bash
    noctalia msg plugins source add my-dev path ~/dev/noctalia-plugins
    ```
3.  Test via IPC:
    ```bash
    noctalia msg plugin me/hello:hello focused greet "hi there"
    noctalia msg panel-toggle me/hello:panel
    ```
4.  Hot reload: `.luau` edits reload automatically; manifest changes need a config reload.
