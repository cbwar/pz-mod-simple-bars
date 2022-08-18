require("CBWSimpleBarsCommon")

CBWSimpleBars = {}
CBWSimpleBars.MOD_ID = "CBWSimpleBars"
CBWSimpleBars.CONFIG_FILE = "config.json"
CBWSimpleBars.VERSION = "0.1"
CBWSimpleBars.MIN_GAME_VERSION = 4100
CBWSimpleBars.DEBUG = true

local function CBW_debug(message)
    if CBWSimpleBars.DEBUG == false then
        return
    end
    print(CBWSimpleBars.MOD_ID .. ": " .. message)
end

local function CBW_info(message)
    print(CBWSimpleBars.MOD_ID .. ": " .. message)
end

CBW_info("---- Loading Mod -----")
CBW_debug("MOD_ID = " .. CBWSimpleBars.MOD_ID)
CBW_debug("CONFIG_FILE = " .. CBWSimpleBars.CONFIG_FILE)
CBW_debug("VERSION = " .. CBWSimpleBars.VERSION)
CBW_debug("MIN_GAME_VERSION = " .. CBWSimpleBars.MIN_GAME_VERSION)

if CBW_minimum_version(CBWSimpleBars.MIN_GAME_VERSION) == false then
    CBW_info("---- Error loading mod, game version does not match minimum version-----")
    return
end

local config = CBW_decode_json(CBWSimpleBars.MOD_ID, CBWSimpleBars.CONFIG_FILE)
if CBWSimpleBars.DEBUG then
    CBW_dump_table(config)
end
CBW_info("---- Mod loaded successfully -----")

local function CBWSimpleBars_on_create_player(playerIndex, isoPlayer)
    CBW_debug("into create player #" .. playerIndex)

    -- Make sure this is a local player only.
    if not isoPlayer:isLocalPlayer() then
        CBW_debug("player is not local")
        return
    end
    frameRate = getPerformance():getFramerate()
    tickRate = 60 + frameRate

end

Events.OnCreatePlayer.Add(CBWSimpleBars_on_create_player)

-- CBWSimpleBars:loadConfig()
-- print(CBW_SimpleBars.config["bars"])

-- Bar = {
--     ["height"] = 80,
--     ["width"] = 10,
-- }
-- Bar.__index = Bar
-- function Bar:debug()
--     print("----- Bar")
--     print("-- name = " .. self.name)
--     print("-- position: " .. self.height .. "," .. self.width)
--     print("-- color: " .. table.concat(self.color, ','))
--     print("----- /Bar")
-- end

-- HealthBar = {}
-- HealthBar.__index = HealthBar
-- setmetatable(HealthBar, Bar)

-- function HealthBar.new()
--     local instance = setmetatable({}, HealthBar)
--     instance.name = 'healthbar'
--     instance.position = { 70, 70 }
--     instance.color = { 255, 110, 0, 1 }
--     return instance
-- end

-- function getBars()
--     local bars = {}
--         -- HealthBar.new()
--     return bars
-- end

-- function debugBars()
--     local bars = getBars()
--     for i = 1, #bars do
--         bars[i].debug()
--     end
-- end

-- print("Mod Loaded")
-- debugBars()
-- Events.OnPlayerUpdate.Add(debugBars)
