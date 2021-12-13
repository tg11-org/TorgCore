require("Resources/Server/PlayerManager/utils/utils")
local Module = {}
-- BeamMP Permissions
function addToGroup(name, group)
end
function removeFromGroup(name, group)
end
function checkGroup(name)
	local permissions = {}
	if name == 'TrentonGage11' then
		permissions['group'] = 'administrator'
		permissions['value'] = 2
		return permissions
	else
		permissions['group'] = 'member'
		permissions['value'] = 0
		return permissions
	end
end
function loadPermissionsModule()
	Module.setGroup = setGroup
	return Module
end