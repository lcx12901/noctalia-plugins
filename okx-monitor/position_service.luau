--!nonstrict
-- OKX Position Monitor — headless service entry.
--
-- Calls okx CLI via noctalia.runAsync, publishes position data
-- to noctalia.state for widget and panel.

noctalia.setUpdateInterval(1000)

local STATE_DIR = noctalia.expandPath("~/.local/share/noctalia/plugins/okx-monitor")
local current_mode = noctalia.getConfig("mode") or "demo"
local pos_fetching = false

local function updatePositions()
  if pos_fetching then return end
  pos_fetching = true

  -- Global CLI flags must precede the module. Use --profile to select the
  -- matching API key+environment: --live/--demo only switch the endpoint and
  -- keep the default profile's key, causing HTTP 401 "APIKey does not match
  -- current environment" when the default profile is demo but mode is live.
  local profile_flag = current_mode == "live" and "--profile live" or "--profile demo"
  local cmd = "okx " .. profile_flag .. " account positions --instType SWAP --json 2>/dev/null"

  noctalia.runAsync(cmd, function(result)
    pos_fetching = false

    local stdout = (result and result.stdout) or ""
    stdout = stdout:gsub("^%s+", ""):gsub("%s+$", "")

    local state
    if stdout ~= "" and stdout ~= "[]" then
      local ok, positions = pcall(function()
        return noctalia.json.decode(stdout)
      end)
      if ok and type(positions) == "table" then
        state = { positions = positions, _updated_at = os.time(), _mode = current_mode }
      else
        state = { positions = {}, _updated_at = os.time(), _mode = current_mode, _error = "json_parse_failed" }
      end
    else
      state = { positions = {}, _updated_at = os.time(), _mode = current_mode }
    end

    noctalia.writeFile(STATE_DIR .. "/positions.json", noctalia.json.encode(state))
    noctalia.state.set("okx-monitor.positions", state)
  end)
end

noctalia.state.watch("okx-monitor.cmd", function(cmd)
  if cmd == "set_mode:demo" then
    current_mode = "demo"
    updatePositions()
  elseif cmd == "set_mode:live" then
    current_mode = "live"
    updatePositions()
  elseif cmd == "refresh" then
    updatePositions()
  end
end)

updatePositions()

function update()
  updatePositions()
end
