local M = {}
function try(what)
   status, result = pcall(what[1])
   if not status then
      what[2](result)
   end
   return result
end

function catch(what)
   return what[1]
end

function check(tablex, valuex)
  for index,value in ipairs(tablex) do
    if valuex == value then return true end
  end
  return false
end

local function file_exists(file) 
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

function linesfrom(file)
  if not file_exists(file) then
    return {}
  end
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

function loadWordlist()
  x = linesfrom("./Resources/Server/TorgCore/utils/bannedwords.txt")
  return x
end

string.startswith = function(self, str)
  return self:find('^'..str) ~= nil
end

string.endswith = function(self, str)
	return self:find(str..'$') ~= nil
end

string.split = function (s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

string.removefirstchar = function(self)
  return self:sub(2)
end

string.removelastchar = function(self)
  return self:sub(0,string.len(tstr)-1)
end
