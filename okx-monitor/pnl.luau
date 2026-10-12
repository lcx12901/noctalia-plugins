--!nonstrict
-- OKX PnL bar widget — shows total floating PnL (amount + ratio) across all positions.
-- Tertiary color for positive, error for negative. Click to open the panel.

local positions = {}
local mode = "demo"

local function formatPnl(value)
  local v = tonumber(value)
  if not v then return "--" end
  local sign = v > 0 and "+" or ""
  return sign .. string.format("%.2f", v)
end

local function formatRatio(value)
  local v = tonumber(value)
  if not v then return "" end
  local sign = v > 0 and "+" or ""
  return " (" .. sign .. string.format("%.2f%%", v * 100) .. ")"
end

-- Theme color roles: tertiary = positive, error = negative
local function getPnlColor(value)
  local v = tonumber(value)
  if not v then return "on_surface_variant" end
  if v > 0 then return "tertiary" end
  if v < 0 then return "error" end
  return "on_surface_variant"
end

local function render()
  local prefix = mode == "live" and "⚡ " or "₿ "

  if #positions == 0 then
    barWidget.render(ui.row({ gap = 6, align = "center" }, {
      ui.glyph({ name = "chart-line", color = "on_surface_variant" }),
      ui.label({ text = prefix .. "--", color = "on_surface_variant" }),
    }))
    return
  end

  -- Sum total PnL and margin across positions
  local total_upl = 0
  local total_margin = 0
  local has_margin = false

  for _, p in ipairs(positions) do
    total_upl = total_upl + (tonumber(p.upl) or 0)
    local margin = tonumber(p.margin)
    if margin then
      total_margin = total_margin + margin
      has_margin = true
    end
  end

  local total_ratio = has_margin and total_margin ~= 0 and (total_upl / total_margin) or nil
  local color = getPnlColor(total_upl)

  barWidget.render(ui.row({ gap = 6, align = "center" }, {
    ui.glyph({ name = "chart-line", color = color }),
    ui.label({
      text = prefix .. formatPnl(total_upl) .. " USDT" .. (total_ratio and formatRatio(total_ratio) or ""),
      fontWeight = "bold",
      color = color,
    }),
  }))
end

function update()
  render()
end

noctalia.state.watch("okx-monitor.positions", function(value)
  if value and value.positions then
    positions = value.positions
  end
  render()
end)

noctalia.state.watch("okx-monitor.mode", function(value)
  mode = value or "demo"
  render()
end)

function onClick()
  noctalia.togglePanel("wktl/okx-monitor:panel")
end
