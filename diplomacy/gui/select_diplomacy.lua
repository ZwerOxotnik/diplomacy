--[[
Copyright 2018-2022 ZwerOxotnik <zweroxotnik@gmail.com>

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

local set_politice = require("diplomacy/util").set_politice
local destroy_diplomacy_selection_frame = require("diplomacy/gui/frames/diplomacy_selection").destroy
local cancel_request_diplomacy_force = require("diplomacy/util").cancel_request_diplomacy_force
local get_stance_diplomacy_type = require("diplomacy/util").get_stance_diplomacy_type
local update_diplomacy_frame = require("diplomacy/gui/frames/diplomacy").update
local create_diplomacy_selection_frame = require("diplomacy/gui/frames/diplomacy_selection").create

local function confirm_diplomacy(event)
	local gui = event.element
	local player = game.get_player(event.player_index)
	local diplomacy_table = gui.parent.diplomacy_inner_frame.diplomacy_scrollpane.diplomacy_table
	local some_change = false
	local player_force = player.force
	for _, child in pairs(diplomacy_table.children) do
		if child.type == "checkbox" and child.state then
			if child.name:find("_ally") then
				local name = child.name:gsub("_ally", "")
				local force = game.forces[name]
				local stance_type = get_stance_diplomacy_type(player_force, force)
				if stance_type ~= FILTER_DIPLOMACY_TYPE_ALLY then
					create_diplomacy_selection_frame(force, player_force.name, "ally")
					force.print({"player-changed-diplomacy", player.name, player_force.name})
					player_force.print({"player-changed-diplomacy", player.name, force.name})
					some_change = true
				end
			elseif child.name:find("_neutral") then
				local name = child.name:gsub("_neutral", "")
				local force = game.forces[name]
				local stance_type = get_stance_diplomacy_type(player_force, force)
				if stance_type ~= FILTER_DIPLOMACY_TYPE_NEUTRAL then
					if stance_type == FILTER_DIPLOMACY_TYPE_ALLY then
						set_politice["neutral"](force, player_force, player.index)
						game.print({"team-changed-diplomacy", player_force.name, force.name, {"neutral"}})
						force.print({"player-changed-diplomacy", player.name, player_force.name})
						player_force.print({"player-changed-diplomacy", player.name, force.name})
						cancel_request_diplomacy_force(player_force, force)
					else
						create_diplomacy_selection_frame(force, player_force.name, "neutral")
						force.print({"player-changed-diplomacy", player.name, player_force.name})
						player_force.print({"player-changed-diplomacy", player.name, force.name})
					end
					some_change = true
				end
			elseif child.name:find("_enemy") then
				local name = child.name:gsub("_enemy", "")
				local force = game.forces[name]
				local stance_type = get_stance_diplomacy_type(player_force, force)
				if stance_type ~= FILTER_DIPLOMACY_TYPE_ENEMY then
					set_politice["enemy"](force, player_force, player.index)
					game.print({"team-changed-diplomacy", player_force.name, force.name, {"enemy"}})
					force.print({"player-changed-diplomacy", player.name, player_force.name})
					player_force.print({"player-changed-diplomacy", player.name, force.name})
					cancel_request_diplomacy_force(player_force, force)
					some_change = true
				end
			end
		end
	end

	if some_change then
		update_diplomacy_frame()
	end
	if player.gui.screen.diplomacy_frame then
		player.gui.screen.diplomacy_frame.destroy()
	end
end


local select_diplomacy = {}

select_diplomacy.diplomacy_check_press = function(gui)
	local gui_name = gui.name
	if not (gui_name:find("_enemy")
		or gui_name:find("_neutral")
		or gui_name:find("_ally")) then
		return
	end

	if not gui.state then
		gui.state = true
		return
	end

	local index = 1
	local children = gui.parent.children
	for k, child in pairs(children) do
		if child.name == gui_name then
			index = k
			break
		end
	end

	if gui_name:find("_neutral") then
		children[index+1].state = false
		children[index-1].state = false
	elseif gui_name:find("_ally") then
		children[index-2].state = false
		children[index-1].state = false
	else
		children[index+1].state = false
		children[index+2].state = false
	end
end

select_diplomacy.on_player_left_game = function(player)
	destroy_diplomacy_selection_frame(player)
	update_diplomacy_frame()
end

local button_press_functions = {
	["diplomacy_cancel"] = function(event) game.get_player(event.player_index).diplomacy_frame.destroy() end,
	["confirm_diplomacy"] = confirm_diplomacy,
}

select_diplomacy.on_gui_click = function(event)
	local gui = event.element
	local button_function = button_press_functions[gui.name]
	if button_function then
		button_function(event)
	end
end

return select_diplomacy
