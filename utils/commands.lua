require("Resources/Server/TorgCore/utils/utils")
require("Resources/Server/TorgCore/utils/permissions")
local permissions = loadPermissionsModule()
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
		elseif command == "kick" then
			kick(command_strings[2], authID, command_strings[3])
		else
			SendChatMessage(authID, "^4Error!^c Unknown command: ^r"..command)
		end
		return 0
	end
	return 1
end

-- Chat Commands 
-- Help: /help [command]
function help(authID, authName, command)
	if command == nil then
		SendChatMessage(authID, "^6<=^r ^3Commands for^r ^a[^6tg11^b.^2org^r^a]^r ^6=>^r")
		SendChatMessage(authID, "^6/help ^2[command]^r")
		SendChatMessage(authID, "^7 shows you this command^r")
		SendChatMessage(authID, "^7 or help on another command^r")
	elseif command == "kick" then
		if check(permissions.moderators, authName) == true or check(permissions.administrators, authName) == true then
			SendChatMessage(authID, "^6/kick ^a<user> ^2[reason]^r")
		else
			SendChatMessage(authID, "^4You are not permitted to run this command!^r")
		end
	else
		SendChatMessage(authID, "^4Error!^c Unknown command: ^r"..command)
	end
end
-- Kick: /kick <playerID> [message]
function kick(kickID, authID, message)
	name = GetPlayerName(kickID)
	if check(permissions.moderators, authName) == true or check(permissions.administrators, authName) == true then
		DropPlayer(kickID, message)
		SendChatMessage(-1, "The player `"..name.."` has been kicked from the server!")
	else
		SendChatMessage(authID, "You do not have a high enough server permission to do that.")
	end
end



local function loaded()
	cmd_log("Loaded!")
end

function loadCommandsModule()
	Module.decider = decider
	Module.help = help
	Module.loaded = loaded
	return Module
end
