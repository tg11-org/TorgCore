require("Resources/Server/PlayerManager/utils/utils")
require("Resources/Server/PlayerManager/utils/permissions")
local permissionsModule = loadPermissionsModule()
local Module = {}
-- Command Handler
function decider(authID, authName, raw_message)
	raw_message = raw_message:sub(2)
	if string.startswith(raw_message, "/") then
		command_strings = raw_message:sub(2)
		command_strings = string.split(command_strings, " ")
		command = command_strings[1]
		if command == "help" then
			help(authID, command_strings[2])
		--else if 
		end
		return 0
	end
end

-- Chat Commands 
-- Help: /help [command]
function help(authID, command)
--	if command == nil then
--		if 0 >= 0 then
			SendChatMessage(authID, "^6<=^r ^3Commands for^r ^a[^6tg11^b.^2org^r^a]^r ^6=>^r")
			SendChatMessage(authID, "^6/help ^2[command]^r")
			SendChatMessage(authID, "^7 shows you this command^r")
			SendChatMessage(authID, "^7 or help on another command^r")
--		end
--	end
end
-- Kick: /kick <playerID> [message]
function kick(kickID, authID, message)
	name = GetPlayerName(kickID)
	if 2 >= 2 then
		DropPlayer(kickID, message)
		SendChatMessage(-1, "The player `"..name.."` has been kicked from the server!")
	else
		SendChatMessage(authID, "You do not have a high enough server permission to do that.")
	end
end


-- 
function loadCommandsModule()
	Module['decider'] = decider
	Module['help'] = help
	return Module
end