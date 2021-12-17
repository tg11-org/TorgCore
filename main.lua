--=================================================================
-- Torg Server Management
-- By p05, TrentonGage11
-- Originated from Titch (Check README)
--=================================================================
-- Put a way for people to contact you here, Discord, Email, Phone..
local HowToContact    = "Example#0123, example@example.com or (555) 555-5555" -- Change this to whatever method you like
local AllowGuests     = false
local AllowGuestChat  = false
local ProfanityBlock  = false	-- This takes priority over the filter, so if you have them both set to true
local ProfanityFilter = true	-- it will default to blocking the message.
blacklist = {
	"Player1",
	"Player2",
	"Player3"
	}
--  ↑ Formatting above is how it must be or it won't work correctly.
local bannedMessage = "You've Been Banned from this server! Contact the server manager here:"..HowToContact
local noGuestsMessage = "You must be signed in to join this server!"
local noGuestChatMessage = "Sorry chat is disabled for guest players on this server. Please register for a BeamMP Account to use the Chat functionality."
--=================================================================
-- DO NOT TOUCH BEYOND THIS POINT 
--=================================================================
-- idk what this is for

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

-- Events

function onInit()
	chatfilter = loadWordlist()
	Modules = {}
	Commands = loadCommandsModule()
	Permissions = loadPermissionsModule()
	parsePermissionsFile()
	Permissions.loaded()
	Commands.loaded()
	core_log("Torg Loaded!")
end

function onChatMessage(id, name, message)
	local identifiers = GetPlayerIdentifiers(id)
	if identifiers == nil and not AllowGuestChat then -- the nil means they are a guest
		SendChatMessage(id, noGuestChatMessage)
		return 1
	end
	if decider(id, name, message) == 0 then return 1 end
	if ProfanityBlock then -- Block Profanity
		for k,p in ipairs(chatfilter) do
			if string.find(message, p, 1, true) then
				SendChatMessage(id, "You message did not go through because it contains profanity.")
				return 1
			end
		end
	end
	if ProfanityFilter then -- Remove Profanityfor k,p in ipairs(chatfilter) do
		for k,p in ipairs(chatfilter) do
			if string.find(message, p, 1, true) then
				message = string.gsub(message, p, string.rep('*', string.len(p)))
			end
		end
		message = "{"..name.."}"..message
		SendChatMessage(-1, message)
		return 1
	end
end

function onPlayerAuth(name, role, isGuest)
  info_log("Event onPlayerAuth(name="..name..",role="..role..",guest?="..tostring(isGuest)..")")
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
    info_log("onPlayerAuth Breaking, player is a guest.")
    return noGuestsMessage
  end
  if blocked then 
    info_log("onPlayerAuth Breaking, player is blocked.")
    return bannedMessage
  end
  info_log("End onPlayerAuth")
end
function delayedWelcome(playerID)
	Sleep(20000)
	SendChatMessage(playerID, "Information to know:")
	if ProfanityBlock then
		SendChatMessage(playerID, "Profanity will be blocked")
	end
	if ProfanityFilter and ProfanityBlock == false then
		SendChatMessage(playerID, "Profanity will be replaced with `*`'s")
	end
	SendChatMessage(playerID, "Griefing will result in a server ban")
	SendChatMessage(playerID, "and to report someone griefing")
	SendChatMessage(playerID, "dm me on discord or send me an email")
	SendChatMessage(playerID, "TrentonGage11#0594, gage@tg11.org")
end

RegisterEvent("onPlayerAuth","onPlayerAuth")
RegisterEvent("onChatMessage","onChatMessage")
RegisterEvent("onPlayerJoin","delayedWelcome")
