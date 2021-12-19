require("Resources/Server/TorgCore/utils/utils")
require("Resources/Server/TorgCore/utils/permissions")
local permissions = loadPermissionsModule()
local Module = {}
_deb = true
-- Command Handler
function decider(authID, authName, raw_message, playerTable)
	raw_message = raw_message:sub(2)
	if string.startswith(raw_message, "/") then
		command_strings = raw_message:sub(2)
		command_strings = string.split(command_strings, " ")
		if command_strings[2] ~= nil and command_strings[2] ~= nil then
			toremove = "/"..command_strings[1].." "..command_strings[2]
		elseif command_strings[1] ~= nil and command_strings[2] == nil then
			toremove = "/"..command_strings[1]
		else
			toremove = "/"
		end
		reason = raw_message:gsub(toremove, "")
		command = command_strings[1]
		deb_log(_deb, authName.." want's to run the command "..command..".")
		if command == "help" then
			help(authID, authName, command_strings[2])
		elseif command == "kick" then
			kick(command_strings[2], authName, authID, reason, playerTable)
		elseif command == "ban" then
			local x = ban(command_strings[2], authName, authID, reason, playerTable)
			if x == 2 then return 2 end
		elseif command == "unban" then
			local x = unban(command_strings[2], authName, authID)
			if x == 2 then return 2 end
		elseif command == "reload" then
			local x = reload(authID, authName)
			if x == 2 then return 2 end
		else
			SendChatMessage(authID, "^4Error!^c Unknown command: ^r"..command)
		end
		return 0
	end
	return 1
end

function checkPermissions(authID, authName, permissionLevel)
	if permissionLevel == 1 then
		if check(permissions.moderators, authName) == true or check(permissions.administrators, authName) == true then
			return true
		end
	elseif permissionLevel == 2 then
		if check(permissions.administrators, authName) == true then
			return true
		end
	else
		SendChatMessage(authID, "^4You do not have a high enough server permission to do that.^r")
		return false
	end
end

-- Chat Commands 

-- Help: /help [command]
function help(authID, authName, command)
	if command == nil or command == "help" then
		SendChatMessage(authID, "^6<=^r ^3Commands for^r ^a[^6tg11^b.^2org^r^a]^r ^6=>^r")
		SendChatMessage(authID, "^6/help ^2[command]^r")
		SendChatMessage(authID, "^7 shows you this command^r")
		SendChatMessage(authID, "^7 or help on another command^r")
		SendChatMessage(authID, "^7===========================^r")
		SendChatMessage(authID, "^7Commands: help, kick ban/unban^r")
		SendChatMessage(authID, "^7reload^r")
	elseif command == "kick" then
		if checkPermissions(authID, authName, 1) == true then
			SendChatMessage(authID, "^6/kick ^a< user > ^2[reason]^r")
		end
	elseif command == "ban" then
		if checkPermissions(authID, authName, 2) == true then
			SendChatMessage(authID, "^6/ban ^a< user > ^2[reason]^r")
		end
	elseif command == "unban" then
		if checkPermissions(authID, authName, 2) == true then
			SendChatMessage(authID, "^6/unban ^a< user >^r")
		end
	elseif command == "reload" then
		if checkPermissions(authID, authName, 2) == true then
			SendChatMessage(authID, "^6/reload ^e| Reloads a few files so the server")
			SendChatMessage(authID, "^edoesn't require a restart.")
		end
	else
		SendChatMessage(authID, "^4Error!^c Unknown command: ^r"..command)
	end
end
-- Kick: /kick <name> [reason]
function kick(kickName, authName, authID, reason, playerTable)
	if check(permissions.moderators, authName) == true or check(permissions.administrators, authName) == true then
		if kickName == nil then
			SendChatMessage(authID, "^4You cannot kick a non-existant player!^r")
			return 0
		end
		if kickName == authName then
			SendChatMessage(authID, "^4You cannot kick yourself!^r")
			return 0
		end
		for id = 0,#playerTable do
			_name = GetPlayerName(id)
			deb_log(_deb, "ID:"..id.." NAME:".._name)
			deb_log(_deb, "ID:"..id.." NAME:".._name)
			if _name == kickName then
				kickID = id
			end
		end
		if kickID == nil then
			SendChatMessage(authID, "^4The player ^3`"..kickName.."`^4 could not be found!^r")
			return 0
		else
			if type(reason) == "table" or reason == nil or reason == "" or reason == " " then
				reason = "You kave been kicked from the server!"
			end
			DropPlayer(kickID, reason)
			SendChatMessage(-1, "^6The player ^e`"..kickName.."`^6 has been ^4kicked^6 from the server!^r")
		end
	else
		SendChatMessage(authID, "^4You do not have a high enough server permission to do that.^r")
	end
end
-- Ban: /ban <name> [reason]
function ban(banName, authName, authID, reason, playerTable)
	if check(permissions.moderators, authName) == true or check(permissions.administrators, authName) == true then
		if banName == nil then
			SendChatMessage(authID, "^4You cannot ban a non-existant player!^r")
			return 0
		end
		if banName == authName then
			SendChatMessage(authID, "^4You cannot ban yourself!^r")
			return 0
		end
		for id = 0,#playerTable do
			_name = GetPlayerName(id)
			deb_log(_deb, "ID:"..id.." NAME:".._name)
			if _name == banName then
				banID = id
			end
		end
		if banID == nil then
			SendChatMessage(authID, "^4The player ^3`"..banName.."`^4 could not be found..^r")
			SendChatMessage(authID, "^4Adding the name^3`"..banName.."`^4 to the blacklist!^r")
		end
		if type(reason) == "table" or reason == nil or reason == "" or reason == " " then
			reason = "You kave been banned from the server!"
		end
		if banID ~= nil then
			DropPlayer(banID, reason)
		end
		writeBlacklist(banName, 0)
		writeBan(banName, reason)
		SendChatMessage(-1, "^6The player ^e`"..banName.."`^6 has been ^4banned^6 from the server!^r")
		return 2
	else
		SendChatMessage(authID, "^4You do not have a high enough server permission to do that.^r")
	end
end
-- Ban: /unban <name>
function unban(banName, authName, authID)
	if check(permissions.moderators, authName) == true or check(permissions.administrators, authName) == true then
		if banName == nil then
			SendChatMessage(authID, "^4You cannot unban a non-existant player!^r")
			return 0
		end
		if banName == authName then
			SendChatMessage(authID, "^4You cannot run this on yourself!^r")
			return 0
		end
		writeBlacklist(banName, 1)
		SendChatMessage(-1, "^6The player ^e`"..banName.."`^6 has been ^4unbanned^6 from the server!^r")
		return 2
	else
		SendChatMessage(authID, "^4You do not have a high enough server permission to do that.^r")
	end
end

function reload(authID, authName)
	if checkPermissions(authID, authName, 2) == true then
		return 2
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
