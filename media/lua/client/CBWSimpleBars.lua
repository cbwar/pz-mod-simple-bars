require("CBWSimpleBarsCommon")

CBWSimpleBars = {}
CBWSimpleBars.MOD_ID = "CBWSimpleBars"
CBWSimpleBars.CONFIG_FILE = "config.json"

local function CBW_debug(message)
    if CBWSimpleBars.DEBUG == false then
        return
    end
    print(CBWSimpleBars.MOD_ID .. ": " .. message)
end

local function CBW_info(message)
    print(CBWSimpleBars.MOD_ID .. ": " .. message)
end

local function loadConfig()
    local config = CBW_decode_json(CBWSimpleBars.MOD_ID, CBWSimpleBars.CONFIG_FILE)
    CBWSimpleBars.VERSION = config["modVersion"]
    CBWSimpleBars.MIN_GAME_VERSION = config["minimumGameVersion"]
    CBWSimpleBars.DEBUG = config["debugMode"]
    return config
end

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

CBW_info("---- Loading Mod -----")
local config = loadConfig()

CBW_debug("MOD_ID = " .. CBWSimpleBars.MOD_ID)
CBW_debug("CONFIG_FILE = " .. CBWSimpleBars.CONFIG_FILE)
CBW_debug("VERSION = " .. CBWSimpleBars.VERSION)
CBW_debug("MIN_GAME_VERSION = " .. CBWSimpleBars.MIN_GAME_VERSION)

if CBW_minimum_version(CBWSimpleBars.MIN_GAME_VERSION) == false then
    CBW_info("---- Error loading mod, game version does not match minimum version-----")
    return
end

if CBWSimpleBars.DEBUG then
    CBW_dump_table(config)
end
CBW_info("---- Mod loaded successfully -----")

Events.OnCreatePlayer.Add(CBWSimpleBars_on_create_player)
