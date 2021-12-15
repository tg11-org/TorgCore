require("Resources/Server/TorgCore/utils/utils")
local Module = {}
permission = {group=nil, value=nil, members={}}
function permission:new(group, value, members)
	local _perm = permission
	_perm.group = group
	_perm.value = value
	return _perm
end
administrator = permission:new("administrator", 2)
moderator = permission:new("moderator", 1)
member = permission:new("member", 0)
-- BeamMP Permissions
function checkGroup(name)
	if name == 'TrentonGage11' then
		return administrator
	else
		return member
	end
end

function parsePermissionsFile()
	local raw_data = linesfrom("./Resources/Server/TorgCore/utils/permissions.yaml")
	local data = {}
	local index = 0
	local temp = {}
	for _,line in ipairs(raw_data) do
		if line:endswith(':') then
			data[index] = line:removelastchar()
			index = index + 1
		else
			if line:startswith('  - ')
				line = line:sub(5)
				_line = line:split(", ")
				for _,line_ in ipairs(_line) do
					if line_ ~= "" then
						temp[#temp+1] = line_
					end
				end
			end
		end
	end
end

function loadPermissionsModule()
	Module.administrator = administrator
	Module.permission = permission
	Module.checkGroup = checkGroup
	Module.moderator = moderator
	Module.member = member
	return Module
end
