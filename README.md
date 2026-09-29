# Noctalia Plugins

Personal collection of [Noctalia](https://github.com/noctalia-dev/noctalia) plugins.

## Plugins

### OKX Monitor

Track OKX positions, PnL, and K-line charts in the bar.

- **ID**: `wktl/okx-monitor`
- **Version**: 1.0.0
- **Features**:
  - Position monitoring
  - Real-time PnL tracking
  - K-line chart visualization

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

