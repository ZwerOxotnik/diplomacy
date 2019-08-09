--[[
Copyright 2018-2019 ZwerOxotnik <zweroxotnik@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]--

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
