--[[
Copyright 2018-2021 ZwerOxotnik <zweroxotnik@gmail.com>

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

util.get_stance_diplomacy_type = function(force, other_force)
	if force.get_friend(other_force) then
		return FILTER_DIPLOMACY_TYPE_ALLY
	elseif force.get_cease_fire(other_force) then
		return FILTER_DIPLOMACY_TYPE_NEUTRAL
	else
		return FILTER_DIPLOMACY_TYPE_ENEMY
	end
end

util.get_stance_name_diplomacy_by_type = function(type)
	if type == FILTER_DIPLOMACY_TYPE_ALLY then
		return "ally"
	elseif type == FILTER_DIPLOMACY_TYPE_NEUTRAL then
		return "neutral"
	else
		return "enemy"
	end
end

util.set_politice = {
	ally = function(force, other_force, player_index)
		local prev_relationship = util.get_stance_diplomacy(force, other_force)
		force.set_friend(other_force, true)
		force.set_cease_fire(other_force, true)
		other_force.set_friend(force, true)
		other_force.set_cease_fire(force, true)
		script.raise_event(diplomacy_events.on_ally, {source = force, destination = other_force, player_index = player_index, prev_relationship = prev_relationship})
	end,
	neutral = function(force, other_force, player_index)
		local prev_relationship = util.get_stance_diplomacy(force, other_force)
		force.set_friend(other_force, false)
		force.set_cease_fire(other_force, true)
		other_force.set_friend(force, false)
		other_force.set_cease_fire(force, true)
		script.raise_event(diplomacy_events.on_neutral, {source = force, destination = other_force, player_index = player_index, prev_relationship = prev_relationship})
	end,
	enemy = function(force, other_force, player_index)
		local prev_relationship = util.get_stance_diplomacy(force, other_force)
		force.set_friend(other_force, false)
		force.set_cease_fire(other_force, false)
		other_force.set_friend(force, false)
		other_force.set_cease_fire(force, false)
		script.raise_event(diplomacy_events.on_enemy, {source = force, destination = other_force, player_index = player_index, prev_relationship = prev_relationship})
	end
}

return util
