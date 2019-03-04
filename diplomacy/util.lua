-- Copyright (c) 2018-2019 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the MIT licence;

local destroy_diplomacy_selection_frame = require("diplomacy/gui/frames/diplomacy_selection").destroy

local util = {}

util.set_politice = {
	ally = function(force, other_force)
		force.set_friend(other_force, true)
		force.set_cease_fire(other_force, true)
		other_force.set_friend(force, true)
		other_force.set_cease_fire(force, true)
	end,
	neutral = function(force, other_force)
		force.set_friend(other_force, false)
		force.set_cease_fire(other_force, true)
		other_force.set_friend(force, false)
		other_force.set_cease_fire(force, true)
	end,
	enemy = function(force, other_force)
		force.set_friend(other_force, false)
		force.set_cease_fire(other_force, false)
		other_force.set_friend(force, false)
		other_force.set_cease_fire(force, false)
	end
}

util.cancel_request_diplomacy_force = function(player_force, force)
	for _, other_player in pairs(force.connected_players) do
		local frame = other_player.gui.left.diplomacy_selection_frame
		if frame ~= nil then
			if player_force == game.forces[frame.holding_table_chat_label.diplomacy_other_force_label.caption] then
				destroy_diplomacy_selection_frame(other_player)
			end
		end
	end
end

util.get_stance_diplomacy = function(force, other_force)
	if force.get_friend(other_force) then
		return "ally"
	elseif force.get_cease_fire(other_force) then
		return "neutral"
	else
		return "enemy"
	end
end

return util
