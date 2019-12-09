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
local update_diplomacy_frame = require("diplomacy/gui/frames/diplomacy").update
local set_politice = require("diplomacy/util").set_politice

local function diplomacy_selected_frame(player)
	local frame = player.gui.left.diplomacy_selection_frame
	local force = player.force
	local other_force = game.forces[frame.holding_table_chat_label.diplomacy_other_force_label.caption]
	if not other_force then return end
	local stance = frame.holding_table_chat_label.diplomacy_stance_label.caption

	set_politice[stance](force, other_force, player.index)
	game.print({"team-changed-diplomacy", force.name, other_force.name, {stance}})
	other_force.print({"player-changed-diplomacy", player.name, force.name})
	force.print({"player-changed-diplomacy", player.name, other_force.name})

	interface_name = "secondary-chat"
	function_name = "update_chat_for_force"
	if remote.interfaces[interface_name] and remote.interfaces[interface_name][function_name] then
		remote.call(interface_name, function_name, force)
		remote.call(interface_name, function_name, other_force)
	end
end

local confirm_diplomacy = {}

confirm_diplomacy.on_gui_click = function(player, gui_name)
	if gui_name == "cancel_button_dipl" then
		local force = player.force
		for _, target in pairs(force.connected_players) do
			destroy_diplomacy_selection_frame(target)
		end
	elseif gui_name == "accept_button_dipl" then
		local force = player.force
		diplomacy_selected_frame(player)
		for _, target in pairs(force.connected_players) do
			destroy_diplomacy_selection_frame(target)
		end
		update_diplomacy_frame()
	end
end

return confirm_diplomacy
