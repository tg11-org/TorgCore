local colors = {}
function getcolors()
  colors.reset      = "[0m"
  colors.bold       = "[1m"
  colors.b          = "[1m"
  colors.underline  = "[4m"
  colors.ul         = "[4m"
  colors.inverse    = "[7m"
  colors.inv        = "[7m"
  colors.fgwhite    = "[37m"
  colors.fgbwhite   = "[97m"
  colors.fggray     = "[90m"
  colors.fggrey     = "[90m"
  colors.fgblack    = "[30m"
  colors.fgred      = "[31m"
  colors.fglred     = "[91m"
  colors.fggreen    = "[32m"
  colors.fglgreen   = "[92m"
  colors.fgyellow   = "[33m"
  colors.fglyellow  = "[93m"
  colors.fgblue     = "[34m"
  colors.fglblue    = "[94m"
  colors.fgmagenta  = "[35m"
  colors.fglmagenta = "[95m"
  colors.fgcyan     = "[36m"
  colors.fgteal     = "[96m"
  colors.bgblack    = "[40m"
  colors.bggray     = "[100m"
  colors.bggrey     = "[100m"
  colors.bglgray    = "[47m"
  colors.bglgrey    = "[47m"
  colors.bgwhite    = "[107m"
  colors.bgred      = "[41m"
  colors.bglred     = "[101m"
  colors.bggreen    = "[42m"
  colors.bglgreen   = "[102m"
  colors.bgyellow   = "[43m"
  colors.bglyellow  = "[103m"
  colors.bgblue     = "[44m"
  colors.bglblue    = "[104m"
  colors.bgmagenta  = "[45m"
  colors.bglmagenta = "[105m"
  colors.bgcyan     = "[46m"
  colors.bgteal     = "[106m"
  return colors
end

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

function loadBlacklist()
  y = linesfrom("./Resources/Server/TorgCore/blacklist.txt")
  return y
end

function writeBlacklist(alteration, _type)
  local _content = loadBlacklist()
  if _type == 0 then  -- 0 is add
    local f = io.open("./Resources/Server/TorgCore/blacklist.txt", "a")
    f:write("\n"..alteration)
    f:close()
    return 0
  elseif _type == 1 then -- 1 is remove
    local f = io.open("./Resources/Server/TorgCore/blacklist.txt", "w")
    f:write("")
    f:close()
    local f = io.open("./Resources/Server/TorgCore/blacklist.txt", "a")
    for _,line in ipairs(_content) do
      if line ~= alteration then
        f:write(line)
      end
    end
    f:close()
    return 0
  else
    return 1
  end
end

function writeBan(name, reason)
  local f = io.open("./Resources/Server/TorgCore/bans/"..name..".txt", "w")
  formatted = "["..os.date().."] "..name.." was banned for:"..reason
  f:write(formatted)
  f:close()
end

string.startswith = function(self, str)
  return self:find('^'..str) ~= nil
end

string.endswith = function(self, str)
	return self:find(str..'$') ~= nil
end

string.split = function (self, delimiter)
    result = {};
    for match in (self..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

string.removefirstchar = function(self)
  return self:sub(2)
end

string.removelastchar = function(self)
  return self:sub(0,string.len(self)-1)
end

c = getcolors()

function deb_log(dolog, message)
  if dolog == true then
    print(c.fgcyan.."[Torg:"..c.fgbwhite.."Debug"..c.fgcyan.."] "..c.reset..c.fglyellow..message..c.reset)
  end
end

function info_log(message)
  print(c.fgcyan.."[Torg:"..c.fglmagenta.."Info"..c.fgcyan.."] "..c.reset..c.fggreen..message..c.reset)
end

function warn_log(message)
  print(c.fgcyan.."[Torg:"..c.fglyellow.."Warning"..c.fgcyan.."] "..c.reset..c.fggreen..message..c.reset)
end

function err_log(message)
  print(c.fgcyan.."[Torg:"..c.fglred.."Error"..c.fgcyan.."] "..c.reset..c.fggreen..message..c.reset)
end

function fat_log(message)
  print(c.fgcyan.."[Torg:"..c.fglred.."Fatal"..c.fgcyan.."] "..c.reset..c.fggreen..message..c.reset)
end

function core_log(message)
  print(c.fgcyan.."[Torg:"..c.fgteal.."Core"..c.fgcyan.."] "..c.reset..c.fggreen..message..c.reset)
end

function cmd_log(message)
  print(c.fgcyan.."[Torg:"..c.fgyellow.."Commands"..c.fgcyan.."] "..c.reset..c.fggreen..message..c.reset)
end

function perm_log(message)
  print(c.fgcyan.."[Torg:"..c.fgred.."Permissions"..c.fgcyan.."] "..c.reset..c.fggreen..message..c.reset)
end
