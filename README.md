# Noctalia Plugins

Personal collection of [Noctalia](https://github.com/noctalia-dev/noctalia) plugins.

## Plugins

### OKX Monitor

Track OKX positions and total floating PnL in the bar, with a position list in the panel.

- **ID**: `wktl/okx-monitor`
- **Version**: 1.1.0
- **Features**:
  - Position monitoring
  - Total floating PnL (amount + ratio) in the bar
  - Position list panel (name, PnL, ratio)

## Installation

Add this repository as a plugin source in your Noctalia configuration:

```nix
plugins = {
  enabled = [
    "wktl/okx-monitor"
  ];
  source = [
    {
      enabled = true;
      name = "wktl";
      kind = "git";
      location = "https://github.com/lcx12901/noctalia-plugins";
      auto_update = true;
    }
  ];
};
```

## License

MIT

