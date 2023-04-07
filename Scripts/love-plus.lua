-- Made by NicePotato

local lovePlus = {}
lovePlus.mt = {}

lovePlus.version = 1

local giveErr

lovePlus.mt.__index = function(_, key)
    return lovePlus[key]
end

local function errorWithCheck(msg)
    if giveErr == true then
        love.errorhandler(msg)
    end
end

function lovePlus.loadImage(filename, giveError)
    giveErr = giveError or true
    if love.filesystem.getInfo(filename) then
        return love.graphics.newImage(filename)
    else
        love.errorhandler("Could not load image: " .. filename)
        return nil
    end
end


function lovePlus.lerp(a, b, t)
    return a + (b - a) * t
end

function lovePlus.clamp(x, min, max)
    return math.min(math.max(x, min), max)
end

function lovePlus.round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function lovePlus.rgb(r,g,b)
    return {r/255, g/255, b/255}
end

function lovePlus.pointWithin(x, y, x1, y1, x2, y2)
    local minX = math.min(x1, x2)
    local maxX = math.max(x1, x2)
    local minY = math.min(y1, y2)
    local maxY = math.max(y1, y2)
    if x >= minX and x <= maxX and y >= minY and y <= maxY then
        return true
    else
        return false
    end
end

function lovePlus.printTable(tbl, max)
    max = max or 16 -- maximum the function will go before overflowing
    local depth = 1 -- default depth is 1
    local indent = string.rep("  ", depth - 1) -- indentation for current depth

    for k, v in pairs(tbl) do
        if depth >= max then
            print(indent.."...(overflow)")
            return
        end
        if type(v) == "table" and depth > 0 then
            if next(v) == nil then
                print(indent..k.." = {}")
            else
                print(indent..k.." = {")
                lovePlus.printTable(v, depth + 1)
                print(indent.."}")
            end
        elseif type(v) == "string" then
            print(indent..k..' = "'..v..'"')
        else
            print(indent..k.." = "..tostring(v))
        end
    end
end

function lovePlus.duplicateValue(value)
    local valueType = type(value)
    local copyValue

    if valueType == "table" then
        copyValue = {}
        for key, val in pairs(value) do
            copyValue[lovePlus.duplicateValue(key)] = lovePlus.duplicateValue(val)
        end
    elseif valueType == "function" then
        -- Functions cannot be copied in Lua, so we return nil for them
        copyValue = nil
    else
        copyValue = value
    end
    return copyValue
end

function lovePlus.getFileInfo(file)
	if type(file) ~= "string" then
		return "error", "Invalid argument: expected string, got " .. type(file)
	end

	local fileInfo = love.filesystem.getInfo(file)
	if not fileInfo then
		return "error", "File not found: " .. file
	end

	local fileType = fileInfo.type

	if fileType ~= "file" and fileType ~= "directory" and fileType ~= "symlink" then
		return "error", "Invalid file type: " .. fileType
	end

	local name, ext = file:match("(.+)%.(%w+)$")

	if not name then
		name = file
	end

	return fileType, name, ext
end

function lovePlus.getRealPath(file)
    if type(file) ~= "string" then
      return "error", "Invalid argument: expected string, got " .. type(file)
    end
  
    if file:sub(1, 1) == "/" or file:sub(2, 2) == ":" then -- absolute path
        return file
    else -- relative path
        local realDir = love.filesystem.getRealDirectory("/")
        local realPath = realDir .. "/" .. file
        return realPath
    end
end

function lovePlus.numberToString(num, places)
    local str = tostring(num)
    while #str < places do
      str = "0" .. str
    end
    return str
end

function lovePlus.tableToString(tbl, indent)
    if not indent then indent = 0 end
    local str = ""
    local indentStr = string.rep(" ", indent * 2)
    local braces = ""
    local hasContent = false
    if type(tbl) == "table" then
      if next(tbl) == nil then
        str = indentStr .. "{}"
        return str
      end
      braces = "{\n"
    end
    local i = 0
    for k, v in pairs(tbl) do
      local keyStr = tostring(k)
      if type(k) == "number" then
        keyStr = "[" .. keyStr .. "]"
      elseif type(k) == "string" then
        keyStr = '"' .. k .. '"'
      end
      local valueStr = ""
      if type(v) == "table" then
        valueStr = lovePlus.tableToString(v, indent + 1)
      elseif type(v) == "string" then
        valueStr = '"' .. v .. '"'
      elseif v == nil then
        valueStr = "<nil>"
      else
        valueStr = tostring(v)
      end
      str = str .. indentStr .. braces .. keyStr .. " = " .. valueStr
      if i < #tbl then
        str = str .. ","
      end
      str = str .. "\n"
      hasContent = true
      i = i + 1
      braces = ""
    end
    if type(tbl) == "table" then
      if hasContent then
        braces = string.rep(" ", (indent - 1) * 2)
        str = str .. braces .. "}"
        if indent > 0 then
          str = str .. ","
        end
        str = str .. "\n"
      else
        str = indentStr .. "}\n"
      end
    end
    return str
  end

function lovePlus.createDirectory(path)
    local success, errormsg
  
    if love.system.getOS() == "Windows" then
      success, errormsg = os.execute("mkdir \"" .. path .. "\"")
    else
      success, errormsg = os.execute("mkdir -p \"" .. path .. "\"")
    end
  
    if success then
      return true
    elseif errormsg:find("File exists") then
      -- Directory already exists, return true
      return true
    else
      -- Directory creation failed, try to create it by creating a file
      local file, errmsg = io.open(path .. "/.dummyfile", "w")
      if file then
        file:close()
        os.remove(path .. "/.dummyfile")
        return true
      else
        return false, errmsg
      end
    end
  end
  
  function lovePlus.deleteDirectory(path)
    local command = ""
    
    -- Windows command
    if love.system.getOS() == "Windows" then
      command = "rmdir /s /q " .. '"' .. path .. '"'
    -- Unix/Linux command
    else
      command = "rm -rf " .. '"' .. path .. '"'
    end
    
    local status, result = os.execute(command)
    
    if status ~= 0 then
      print("Error deleting directory: " .. result)
    end
  end
  

return lovePlus