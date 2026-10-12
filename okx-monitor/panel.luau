--!nonstrict
-- OKX Position Panel — lists open positions: name, floating PnL, ratio.
-- Reads positions from noctalia.state.
-- Panel does NOT support state.watch — polls via update() only.

local positions = {}
local mode = "demo"

local function cleanInstId(instId)
  if not instId then return "?" end
  return instId:gsub("-USDT%-SWAP$", ""):gsub("-SWAP$", "")
end

local function formatPrice(price)
  local p = tonumber(price)
  if not p then return "--" end
  local sign = p > 0 and "+" or ""
  return sign .. string.format("%.2f", p)
end

local function formatRatio(ratio)
  local r = tonumber(ratio)
  if not r then return "--" end
  local sign = r > 0 and "+" or ""
  return sign .. string.format("%.2f%%", r * 100)
end

local function pnlColor(value)
  local v = tonumber(value)
  if not v then return "on_surface_variant" end
  if v > 0 then return "tertiary" end
  if v < 0 then return "error" end
  return "on_surface_variant"
end

local function renderPositionRow(p)
  local instId = p.instId or "?"
  local upl = p.upl or "0"
  local uplRatio = p.uplRatio or "0"
  local color = pnlColor(upl)

  return ui.row({
    justify = "space_between",
    align = "center",
    paddingH = 16,
    paddingV = 12,
    fill = "surface_variant/0.35",
    radius = 6,
    border = "outline",
    borderWidth = 1,
  }, {
    ui.label({ text = cleanInstId(instId), fontSize = 14, fontWeight = "bold", color = "on_surface", width = 120 }),
    ui.label({ text = formatPrice(upl) .. " USDT", fontSize = 14, fontWeight = "bold", color = color, width = 140, textAlign = "right" }),
    ui.label({ text = formatRatio(uplRatio), fontSize = 14, fontWeight = "bold", color = color, width = 100, textAlign = "right" }),
  })
end

local function render()
  if #positions == 0 then
    panel.render(ui.column({ gap = 12, padding = 24, align = "center" }, {
      ui.label({ text = "暂无持仓", fontSize = 16, color = "on_surface_variant" }),
      ui.label({ text = "模式: " .. mode, fontSize = 12, color = "on_surface_variant" }),
    }))
    return
  end

  -- Total row
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
  local total_color = pnlColor(total_upl)

  local children = {
    ui.row({ justify = "space_between" }, {
      ui.label({ text = "OKX 持仓", fontSize = 18, fontWeight = "bold", color = "primary" }),
      ui.label({ text = "模式: " .. mode, fontSize = 12, color = "on_surface_variant" }),
    }),
    ui.row({ justify = "space_between", paddingH = 16, paddingV = 4 }, {
      ui.label({ text = "名称", fontSize = 11, color = "on_surface_variant", width = 120 }),
      ui.label({ text = "浮动收益", fontSize = 11, color = "on_surface_variant", width = 140, textAlign = "right" }),
      ui.label({ text = "百分比", fontSize = 11, color = "on_surface_variant", width = 100, textAlign = "right" }),
    }),
  }

  local rows = {}
  for _, p in ipairs(positions) do
    table.insert(rows, renderPositionRow(p))
  end
  table.insert(children, ui.column({ gap = 8, flexGrow = 1 }, rows))

  -- Total summary at bottom
  table.insert(children, ui.row({ justify = "space_between", paddingH = 16, paddingV = 8 }, {
    ui.label({ text = "总浮动收益", fontSize = 13, fontWeight = "bold", color = "on_surface" }),
    ui.label({
      text = formatPrice(total_upl) .. " USDT" .. (total_ratio and ("  " .. formatRatio(total_ratio)) or ""),
      fontSize = 13,
      fontWeight = "bold",
      color = total_color,
    }),
  }))

  panel.render(ui.column({ gap = 12, padding = 16, flexGrow = 1 }, children))
end

-- Read positions from state
local function syncState()
  local raw = noctalia.state.get("okx-monitor.positions")
  if raw and type(raw) == "table" then
    if raw.positions then positions = raw.positions end
    if raw._mode then mode = raw._mode end
  end
end

function onOpen(_context)
  syncState()
  panel.setWantsSecondTicks(true)
  render()
end

function update()
  syncState()
  render()
end
