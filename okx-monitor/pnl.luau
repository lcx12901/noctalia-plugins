--!nonstrict
-- OKX PnL bar widget — shows total floating PnL (amount + ratio) across all
-- positions, plus total USDT assets (Σ). Click to open the panel.

local positions = {}
local balance = nil
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

local function formatAssets(value)
  local v = tonumber(value)
  if not v then return "Σ --" end
  return "Σ " .. string.format("%.2f", v)
end

local function render()
  local prefix = mode == "live" and "⚡ " or "₿ "

  local pnl_color = "on_surface_variant"
  local pnl_text = prefix .. "--"

  if #positions > 0 then
    -- Sum total PnL and margin across positions. Cross-margin positions have
    -- an empty `margin` field; initial margin requirement (`imr`) is the
    -- reliable base for the aggregate ratio (uplRatio = upl / imr per OKX).
    local total_upl = 0
    local total_margin = 0
    local has_margin = false

    for _, p in ipairs(positions) do
      total_upl = total_upl + (tonumber(p.upl) or 0)
      local margin = tonumber(p.imr) or tonumber(p.margin)
      if margin and margin ~= 0 then
        total_margin = total_margin + margin
        has_margin = true
      end
    end

    local total_ratio = has_margin and total_margin ~= 0 and (total_upl / total_margin) or nil
    pnl_color = getPnlColor(total_upl)
    pnl_text = prefix .. formatPnl(total_upl) .. " USDT" .. (total_ratio and formatRatio(total_ratio) or "")
  end

  local children = {
    ui.glyph({ name = "chart-line", color = pnl_color }),
    ui.label({ text = pnl_text, fontWeight = "bold", color = pnl_color }),
  }

  -- Total USDT assets, refreshed with the balance state
  if balance then
    table.insert(children, ui.label({
      text = formatAssets(balance.eq),
      fontWeight = "bold",
      color = "on_surface",
    }))
  end

  barWidget.render(ui.row({ gap = 6, align = "center" }, children))
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

noctalia.state.watch("okx-monitor.balance", function(value)
  balance = value
  render()
end)

noctalia.state.watch("okx-monitor.mode", function(value)
  mode = value or "demo"
  render()
end)

function onClick()
  noctalia.togglePanel("wktl/okx-monitor:panel")
end
