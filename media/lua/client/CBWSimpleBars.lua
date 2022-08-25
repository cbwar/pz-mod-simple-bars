require("CBWSimpleBarsCommon")
require "ISUI/ISPanel"

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

ISPanelWithTooltip = ISPanel:derive("ISPanelWithTooltip")
function ISPanelWithTooltip:updateTooltip()
    if self:isMouseOver() and self.tooltip then
        local text = self.tooltip
        if not self.tooltipUI then
            self.tooltipUI = ISToolTip:new()
            self.tooltipUI:setOwner(self)
            self.tooltipUI:setVisible(false)
            self.tooltipUI:setAlwaysOnTop(true)
        end
        if not self.tooltipUI:getIsVisible() then
            if string.contains(self.tooltip, "\n") then
                self.tooltipUI.maxLineWidth = 1000 -- don't wrap the lines
            else
                self.tooltipUI.maxLineWidth = 300
            end
            self.tooltipUI:addToUIManager()
            self.tooltipUI:setVisible(true)
        end
        self.tooltipUI.description = text
        self.tooltipUI:setDesiredPosition(getMouseX(), self:getAbsoluteY() + self:getHeight() + 8)
    else
        if self.tooltipUI and self.tooltipUI:getIsVisible() then
            self.tooltipUI:setVisible(false)
            self.tooltipUI:removeFromUIManager()
        end
    end
end

function ISPanelWithTooltip:prerender()
    -- Call parent
    -- parent:prerender
    if self.background then
        self:drawRectStatic(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
        self:drawRectBorderStatic(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    end
    -- /parent:prerender

    self:updateTooltip()
end

CBWSimpleBarsBar = ISPanelWithTooltip:derive("CBWSimpleBarsBar")
function CBWSimpleBarsBar:new(x, y, width, height, value, color, tooltip)
    local o = {}
    o = ISPanelWithTooltip:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = { r = 1, g = 1, b = 1, a = 0.2 }
    o.backgroundColor = { r = 100, g = 5, b = 5, a = 0.5 }
    o.value = value
    o.color = color
    o.iconWidth = 10
    o.textWidth = 30
    o.tooltip = tooltip or "" .. value .. "%"
    return o
end

function CBWSimpleBarsBar:createChildren()
    local w = (self.width - self.iconWidth - 2) * self.value / 100.0
    CBW_debug("w = " .. w)
    self.coloredBar = ISPanel:new(self.iconWidth + 2, 0, math.floor(w), self.height)
    self.coloredBar:initialise()
    self.coloredBar.showBorder = false
    self.coloredBar.borderColor.a = 0.0
    self.coloredBar.backgroundColor = { r = self.color.red, g = self.color.green, b = self.color.blue, a = self.color.alpha };
    self:addChild(self.coloredBar)
end

CBWSimpleBarsPanel = ISPanel:derive("CBWSimpleBarsPanel")
function CBWSimpleBarsPanel:new(x, y, width)
    local o = {}
    o = ISPanel:new(x, y, width, 0)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = { r = 1, g = 1, b = 1, a = 0.2 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.5 }
    o.anchorLeft = true
    o.anchorRight = true
    o.anchorTop = true
    o.anchorBottom = true
    o.moveWithMouse = true
    o.innerPadding = 10
    o.spaceBetweenItems = 5
    o.barsHeight = 10
    o.buttonsHeight = 20
    o.pushHeight = o.innerPadding
    return o
end
function CBWSimpleBarsPanel:pushButton(title, action)
    CBW_debug("new button created")
    local closeButton = ISButton:new(self.innerPadding, self.pushHeight,
            self.width - self.innerPadding * 2, self.buttonsHeight, title, self, action);
    closeButton:initialise();
    self.pushHeight = self.pushHeight + self.buttonsHeight + self.spaceBetweenItems
    self:refreshHeight()
    self:addChild(closeButton)
end
function CBWSimpleBarsPanel:pushBar(value, color)
    CBW_debug("new bar created with value = " .. value)
    local bar = CBWSimpleBarsBar:new(self.innerPadding, self.pushHeight, self.width - self.innerPadding * 2, self.barsHeight, value, color);
    bar:initialise()
    self.pushHeight = self.pushHeight + self.barsHeight + self.spaceBetweenItems
    self:refreshHeight()
    self:addChild(bar)
end
function CBWSimpleBarsPanel:show()
    self:setVisible(true)
end
function CBWSimpleBarsPanel:hide()
    self:setVisible(false)
end
function CBWSimpleBarsPanel:refreshHeight()
    self:setHeight(self.pushHeight - self.spaceBetweenItems + self.innerPadding)
end

function CBWSimpleBars_loadConfig()
    local config = CBW_decode_json(CBWSimpleBars.MOD_ID, CBWSimpleBars.CONFIG_FILE)
    CBWSimpleBars.VERSION = config["modVersion"]
    CBWSimpleBars.MIN_GAME_VERSION = config["minimumGameVersion"]
    CBWSimpleBars.DEBUG = config["debugMode"]
    CBWSimpleBars.CONFIG = config

    CBWSimpleBars.playerConfig = {
        ["0"] = config.defaults,
        ["1"] = config.defaults,
        ["2"] = config.defaults,
        ["3"] = config.defaults,
    }
    return config
end

function CBWSimpleBars_loadPlayerConfig(playerIndex)
    local file = "playerConfig_" .. playerIndex .. ".json"
    local config = CBW_decode_json(CBWSimpleBars.MOD_ID, file)
    if not config.position.x or not config.position.y then
        config["position"] = {
            ["x"] = CBWSimpleBars.CONFIG.defaults.position.x,
            ["y"] = CBWSimpleBars.CONFIG.defaults.position.y
        }
    end
    CBWSimpleBars.playerConfig[tostring(playerIndex)] = config
    return config
end

---createPanel
---@param playerConfig table
---@param playerIndex int
function CBWSimpleBars_createPanel(playerConfig, playerIndex)
    if CBWSimpleBars.panel and not CBWSimpleBars.DEBUG then
        CBW_debug("panel already created")
        return CBWSimpleBars.panel
    end
    CBW_debug("creating panel")
    CBWSimpleBars.panel = CBWSimpleBarsPanel:new(playerConfig.position.x, playerConfig.position.y, CBWSimpleBars.CONFIG.panelWidth)
    CBWSimpleBars.panel:initialise()

    for _, bar in pairs(CBWSimpleBars.CONFIG.bars) do
        local barValue = CBWSimpleBars_getPlayerData(bar.dataType, playerIndex)
        CBWSimpleBars.panel:pushBar(barValue, bar.color)
    end

    CBWSimpleBars.panel:pushButton("Close", CBWSimpleBars.panel.hide)
    CBWSimpleBars.panel:addToUIManager()
    return CBWSimpleBars.panel
end

---getPlayerData
---@param dataType string
---@param playerIndex int
function CBWSimpleBars_getPlayerData(dataType, playerIndex)
    local player = getSpecificPlayer(playerIndex)
    CBW_debug("get player data for " .. dataType)
    local stats = player:getStats()

    if dataType == "health" then
        return player:getBodyDamage():getHealth()
    elseif dataType == "stress" then
        return math.floor(stats:getStress() * 100)
    elseif dataType == "thirst" then
        return 100 - math.floor(stats:getThirst() * 100)
    elseif dataType == "hunger" then
        return 100 - math.floor(stats:getHunger() * 100)
    end
    return -1
end

---CBWSimpleBars_on_create_player
---@param playerIndex int
---@param player IsoPlayer
function CBWSimpleBars_onCreatePlayer(playerIndex, player)
    CBW_debug("into create player #" .. playerIndex)

    if player == nil then
        player = getSpecificPlayer(playerIndex)
    end

    -- Make sure this is a local player only.
    if not player:isLocalPlayer() then
        CBW_debug("player is not local")
        return
    end

    local playerConfig = CBWSimpleBars_loadPlayerConfig(playerIndex)
    CBWSimpleBars_createPanel(playerConfig, playerIndex)
    CBWSimpleBars.panel:show()
end

CBW_info("---- Loading Mod -----")
local config = CBWSimpleBars_loadConfig()

CBW_debug("MOD_ID = " .. CBWSimpleBars.MOD_ID)
CBW_debug("CONFIG_FILE = " .. CBWSimpleBars.CONFIG_FILE)
CBW_debug("VERSION = " .. CBWSimpleBars.VERSION)
CBW_debug("MIN_GAME_VERSION = " .. CBWSimpleBars.MIN_GAME_VERSION)

if CBW_minimum_version(CBWSimpleBars.MIN_GAME_VERSION) == false then
    CBW_info("---- Error loading mod, game version does not match minimum version-----")
    return
end

-- DEBUG
if CBWSimpleBars.DEBUG then
    CBW_dump_table(config)

    local function CBWSimpleBars_debug()
        CBWSimpleBars_onCreatePlayer(0)
    end
    Events.OnObjectRightMouseButtonUp.Add(CBWSimpleBars_debug)
end
-- /DEBUG
CBW_info("---- Mod loaded successfully -----")

---savePlayerConfig
---@param playerIndex int
---@param config table
function CBWSimpleBars_savePlayerConfig(playerIndex, config)
    local file = "playerConfig_" .. playerIndex .. ".json"
    CBW_save_file(CBWSimpleBars.MOD_ID, file, '{"position": {"x": ' .. config.position.x .. ',"y":' .. config.position.y .. '}}')
end

function CBWSimpleBars_saveAllPlayersConfig()
    CBW_debug("save all players config")
    if CBWSimpleBars.playerConfig then
        for playerIndex = 0, 3 do
            CBWSimpleBars_savePlayerConfig(playerIndex, CBWSimpleBars.playerConfig[tostring(playerIndex)])
        end
    end
end

Events.OnCreatePlayer.Add(CBWSimpleBars_onCreatePlayer)
Events.EveryHours.Add(CBWSimpleBars_saveAllPlayersConfig)

