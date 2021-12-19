--=================================================================
-- Torg Server Management
-- By p05, TrentonGage11
-- Originated from Titch (Check README)
--=================================================================

-- Put a way for people to contact you here, Discord, Email, Phone..

local HowToContact    = "Example#0123, example@example.com or (555) 555-5555" -- Change this to whatever method you like
local AllowGuests     = false
local AllowGuestChat  = false
local ColorChat       = true
local ProfanityBlock  = false	-- This takes priority over the filter, so if you have them both set to true
local ProfanityFilter = true	-- it will default to blocking the message.

--  ↑ Formatting above is how it must be or it won't work correctly.

local bannedMessage = "You've Been Banned from this server! Contact the server manager here:"..HowToContact
local noGuestsMessage = "You must be signed in to join this server!"
local noGuestChatMessage = "Sorry chat is disabled for guest players on this server. Please register for a BeamMP Account to use the Chat functionality."
local noProfanityMessage = "You message did not go through because it contains profanity."

-- This is the delay to reload the permissions.yaml, bannedwords.txt and blacklist.txt
-- Defalt is 600000 (in ms), that's 5 minutes
local ReloadDelay = 600000

-- Debug log, just shows extra information is set to true
-- this is per file, so if you wish to turn on it on
-- you would want to do it in all of the files

_deb = true
deb_log(_deb, "Debuggin Enabled")
--=================================================================
-- DO NOT TOUCH BEYOND THIS POINT 
--=================================================================

package.path = 'Resources/Server/TorgCore/;Resources/Server/TorgCore/lua/console/?.lua;Resources/Server/TorgCore/lua/gui/?.lua;Resources/Server/TorgCore/lua/common/?.lua;Resources/Server/TorgCore/lua/common/socket/?.lua;Resources/Server/TorgCore/lua/?.lua;Resources/Server/TorgCore/?.lua;' .. package.path
package.cpath = ''
require("/utils/utils")
core_log("Loading Modules...")
require("/utils/commands")
require("/utils/permissions")

local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function onInit()
	chatfilter = loadWordlist()
	playerTable = {}
	Commands = loadCommandsModule()
	Permissions = loadPermissionsModule()
	blacklist = loadBlacklist()
	parsePermissionsFile()
	Permissions.loaded()
	Commands.loaded()
	core_log("Torg Loaded!")
end

function filterProfanity(id, name, message)
	for k,p in ipairs(chatfilter) do
		if string.find(message, p, 1, true) then
			message = string.gsub(message, p, string.rep('*', string.len(p)))
		end
	end
	return message
end

function onChatMessage(id, name, message)
	local identifiers = GetPlayerIdentifiers(id)
	if identifiers == nil and not AllowGuestChat then -- the nil means they are a guest
		SendChatMessage(id, noGuestChatMessage)
		return 1
	end
	decided = decider(id, name, message, playerTable)
	if decided == 0 then
		return 1
	elseif decided == 2 then
		core_log("Reloading Data...")
		onInit()
		deb_log(_deb, "Reloading Player List")
		playerTable = GetPlayers()
		return 1
	end
	if ProfanityBlock then -- Block Profanity
		for k,p in ipairs(chatfilter) do
			if string.find(message, p, 1, true) then
				SendChatMessage(id, noProfanityMessage)
				return 1
			end
		end
	end
	if ColorChat == true then
		-- Color Fomatting for In-Game-Chat
		-- Good Colors: Yellow, Light Blue, Light Green, Pink and ofc White
		-- ^r = Reset
		-- ^p = Newline
		-- ^n = Underline
		-- ^l = Bold
		-- ^m = Strike-Through
		-- ^o = Italic
		-- ^0 = Black
		-- ^1 = Blue
		-- ^2 = Green
		-- ^3 = Cyan
		-- ^4 = Red
		-- ^5 = Purple
		-- ^6 = Gold
		-- ^7 = Grey
		-- ^8 = Dark Gray
		-- ^9 = Light Purple
		-- ^a = Light Green
		-- ^b = Teal
		-- ^c = Dark Orange
		-- ^d = Light Pink
		-- ^e = Yellow
		-- ^f = White
		-- Always put `^r` at the end
		--=============================================================================
		--  Default Administrator Format: message = "^6^l"..name.."^r"..message.."^r"
		message = message:gsub("^", "^^")
		if check(Permissions.administrators, name) == true then
			message = "^6^l"..name.."^r"..message.."^r"
		elseif check(Permissions.moderators, name) == true then
	--  Default Moderator Format:         message = "^e^l"..name.."^r"..message.."^r"
			message = "^e^l"..name.."^r"..message.."^r"
		elseif name:startswith("guest") == true then
		--  Default Guest Format:         message = "^9^l"..name.."^r"..message.."^r"
			message = "^9^l"..name.."^r"..message.."^r"
		else
		--  Default Member Format:        message = "^c^l"..name.."^r"..message.."^r"
			message = "^c^l"..name.."^r"..message.."^r"
		end
		--=============================================================================
	end
	if ProfanityFilter then 
		message = filterProfanity(id, name, message)
	end
	if ColorChat == true or ProfanityFilter == true then
		SendChatMessage(-1, message)
		return 1
	end
end

function onPlayerAuth(name, role, isGuest)
  deb_log(_deb, "Event onPlayerAuth(name="..name..",role="..role..",guest?="..tostring(isGuest)..")")
  local playerList = GetPlayers()
  blocked = false
  -- Try-Catch Block for block check
  try {
    function()
      blocked = check(blacklist, name)
	end,
	catch {
      function(error)
        err_log("Error @ onPlayerAuth: " .. error)
     end
    }
  }
  if isGuest and not AllowGuest then
    deb_log(_deb, "onPlayerAuth Breaking, player is a guest.")
    return noGuestsMessage
  end
  if blocked then 
    deb_log(_deb, "onPlayerAuth Breaking, player is blocked.")
    return bannedMessage
  end
  deb_log(_deb, "End onPlayerAuth")
end

function newJoin(playerID)
	playerTable[playerID] = GetPlayerName(playerID)
	deb_log(_deb, "Set player "..playerID..":"..playerTable[playerID]..".")
end

function delayedWelcome(playerID)
	Sleep(16000)
	SendChatMessage(playerID, "Information to know:")
	if ProfanityBlock then
		SendChatMessage(playerID, "Profanity will be blocked")
	end
	if ProfanityFilter and ProfanityBlock == false then
		SendChatMessage(playerID, "Profanity will be replaced with `*`'s")
	end
	SendChatMessage(playerID, "Griefing will result in a server ban")
	SendChatMessage(playerID, "and to report someone griefing")
	SendChatMessage(playerID, "contact the server owner or an admin")
	SendChatMessage(playerID, HowToContact)
end

function onPlayerDisconnect(playerID)
	deb_log(_deb, "Removed player "..playerID..":"..playerTable[playerID]..".")
	playerTable[playerID] = nil
end

function autoReload()
	deb_log(_deb, "Reloading Data...")
	onInit()
	Sleep(ReloadDelay)
end

CreateThread("autoReload", 1)
RegisterEvent("onPlayerAuth","onPlayerAuth")
RegisterEvent("onPlayerJoin","newJoin")
RegisterEvent("onChatMessage","onChatMessage")
RegisterEvent("onPlayerDisconnect","onPlayerDisconnect")
RegisterEvent("onPlayerJoin","delayedWelcome")
