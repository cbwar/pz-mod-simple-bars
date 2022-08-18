json = require("lib/json")

local function CBW_debug(message)
    if CBWSimpleBars.DEBUG == false then
        return
    end
    print(CBWSimpleBars.MOD_ID .. ": " .. message)
end

--[[ 
    Reads a json file and returns the contents in a table
]]
function CBW_decode_json(modId, filename)
    CBW_debug("loading json file " .. filename)
    local reader = getModFileReader(modId, filename, true)
    if reader == nil then
        reader = getFileReader(filename, true)
    end

    local contents = ""
    local line = reader:readLine()
    while line do
        contents = contents .. line
        line = reader:readLine()
        if not line then
            break
        end
    end
    reader:close();
    return json.decode(contents)
end

--[[
    Dump table 
]]
function CBW_dump_table(tbl, indent)
    indent = indent or 0
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            CBW_dump_table(v, indent + 1)
        elseif type(v) == "boolean" then
            print(formatting .. (v and "TRUE" or "FALSE"))
        else
            print(formatting .. v)
        end
    end
end

--[[
    Returns false if the minimum version does not match 
]]
function CBW_minimum_version(version)
    local gameVersion = getCore():getVersionNumber():gsub("%.", "")
    CBW_debug("GAME VERSION = " .. gameVersion)
    return tonumber(gameVersion, 10) >= version
end
