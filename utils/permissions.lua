require("Resources/Server/TorgCore/utils/utils")
Module = {}
permissions = {}
permission = {group=nil, value=nil, members={}}
function permission:new(group, value, members)
	local _perm = permission
	_perm.members = members
	_perm.group = group
	_perm.value = value
	return _perm
end

function parsePermissionsFile()
	local raw_data = linesfrom("./Resources/Server/TorgCore/utils/permissions.yaml")
	local data = {}
	local index = 1
	local temp = {}
	for _,line in ipairs(raw_data) do
		if line:endswith(':') then
			temp = {}
			data[index] = line:removelastchar()
			index = index + 1
		else
			if line:startswith('  - ') then
				line = line:sub(5)
				_line = line:split(", ")
				for _,line_ in ipairs(_line) do
					if line_ ~= "" then
						temp[#temp+1] = line_
					end
				end
				data[index] = temp
				index = index + 1
			end
		end
	end
	return data
end

local function makePermissions()
	local data = parsePermissionsFile()
	administrator = permission:new()
	administrator.group = "administrator"
	administrator.value = 2
	administrator.members = data[2]
	moderator = permission:new()
	moderator.group = "moderator"
	moderator.value = 1
	moderator.members = data[4]
	member = permission:new()
	member.group = "member"
	member.value = 0
	member.members = {}
	permissions.administrator = administrator
	permissions.moderator = moderator
	permissions.member = member
	Module.administrators = data[2]
	Module.moderators = data[4]
	return permissions
end

local function loaded()
	perm_log("Loaded!")
end

function loadPermissionsModule()
	local permissions = makePermissions()
	Module.loaded = loaded
	return Module
end
