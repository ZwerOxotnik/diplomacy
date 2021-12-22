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

local LABEL = {type = "label"}
local LABEL_FONT_COLORS = {
	[FILTER_DIPLOMACY_TYPE_ALLY] = {r = 0.5, g = 1, b = 0.5},
	[FILTER_DIPLOMACY_TYPE_ENEMY] = {r = 1, g = 0.5, b = 0.5}
}


local get_stance_diplomacy_type = require("diplomacy/util").get_stance_diplomacy_type
local get_stance_name_diplomacy_by_type = require("diplomacy/util").get_stance_name_diplomacy_by_type
local diplomacy_frame = {}

local function add_player_list_gui(force, gui)
	if not (force and force.valid) then return end

	if #force.players == 0 then
		gui.add(LABEL).caption = {"size.none"}
		return
	end

	local scroll = gui.add{type = "scroll-pane"}
	scroll.style.maximal_height = 120
	local name_table = scroll.add{type = "table", column_count = 1}
	name_table.style.vertical_spacing = 0
	local added = {}
	local first = true

	if #force.connected_players > 0 then
		local online_names = ""
		for _, player in pairs( force.connected_players ) do
			if not first then
				online_names = online_names .. ", "
			end
			first = false
			online_names = online_names .. player.name
			added[player.name] = true
		end
		local online_label = name_table.add{type = "label", caption = {"online", online_names}}
		online_label.style.single_line = false
		online_label.style.maximal_width = 180
	end

	first = true
	if #force.players > #force.connected_players then
		local offline_names = ""
		for _, player in pairs(force.players) do
			if not added[player.name] then
			if not first then
				offline_names = offline_names .. ", "
			end
			first = false
			offline_names = offline_names .. player.name
			added[player.name] = true
			end
		end

		local offline_label = name_table.add{type = "label", caption = {"offline", offline_names}}
		offline_label.style.single_line = false
		offline_label.style.font_color = {r = 0.7, g = 0.7, b = 0.7}
		offline_label.style.maximal_width = 180
	end
end

local function get_color_force(force)
	if #force.players == 0 then
		return {}
	else
		return force.players[1].color
	end
end

local function get_color_team(team, lighten)
	local force = game.forces[team.name]
	if force == team then
		return get_color_force(force)
	elseif team.color and global.diplomacy.color_map[team.color] then
		local c = global.diplomacy.color_map[team.color]
		if lighten then
			return {r = 1 - (1 - c.r) * 0.5, g = 1 - (1 - c.g) * 0.5, b = 1 - (1 - c.b) * 0.5, a = 1}
		end
		return c
	else
		return get_color_force(team)
	end
end

local function create_diplomacy_table(gui, player_settings)
	if gui.diplomacy_table then
		gui.diplomacy_table.destroy()
	end

	local column_count = 6
	if player_settings.show_players_state == false then
		column_count = column_count - 1
	end
	local diplomacy_table = gui.add{type = "table", name = "diplomacy_table", column_count = column_count}
	diplomacy_table.style.horizontal_spacing = 16
	diplomacy_table.style.vertical_spacing = 8
	diplomacy_table.draw_horizontal_lines = true
	diplomacy_table.draw_vertical_lines = true
	return diplomacy_table
end

diplomacy_frame.fill = function(player)
	local flow = player.gui.screen.diplomacy_frame
	if not flow then return end
	local gui = flow.diplomacy_inner_frame
	if not gui then return end

	local player_settings = global.diplomacy.players[player.index]

	-- Remember diplomacy table
	local diplomacy_scrollpane = gui.diplomacy_scrollpane
	local diplomacy_table
	local is_changed = false
	local temp_diplomacy_table = {}
	if not diplomacy_scrollpane then
		local scroll = gui.add{name = "diplomacy_scrollpane", type = "scroll-pane"}
		scroll.style.maximal_height = 320
		diplomacy_table = create_diplomacy_table(scroll, player_settings)
	else
		diplomacy_table = gui.diplomacy_scrollpane.diplomacy_table
		is_changed = true
		-- TODO: check
		for _, child in pairs(diplomacy_table.children) do
			if child.type == "checkbox" then
				temp_diplomacy_table[child.name] = {state = child.state}
			end
		end
		diplomacy_table = create_diplomacy_table(diplomacy_scrollpane, player_settings)
	end
	local add = diplomacy_table.add

	local table_list
	if player_settings.show_players_state then
		table_list = {"team-name", "gui-browse-games.players", "stance", "enemy", "neutral", "ally"}
	else
		table_list = {"team-name", "stance", "enemy", "neutral", "ally"}
	end

	-- TODO: improve
	for i=1, #table_list do
		local name = table_list[i]
		local label = add(LABEL)
		label.name = name
		label.caption = {name}
		label.style.font = "default-bold"
	end

	local diplomacy = global.diplomacy

	-- Find teams
	local forces = game.forces
	local teams
	local is_show_all_teams = false
	if settings.global["diplomacy_visible_all_teams"].value then
		teams = forces
		is_show_all_teams = true
	else
		teams = diplomacy.teams or forces
	end

	-- Fill the table
	for _, team in pairs(teams) do
		local force = forces[team.name]
		if force and force.valid then
			local stance_type = get_stance_diplomacy_type(player.force, force)
			if is_show_all_teams or diplomacy.teams ~= nil or #force.players ~= 0 then
				if player_settings.filter_of_diplomacy_stance == FILTER_DIPLOMACY_TYPE_ALL or stance_type == player_settings.filter_of_diplomacy_stance then
					-- TODO: improve
					local label = add(LABEL)
					label.name = team.name .. "_name"
					label.caption = team.name
					label.style.single_line = false
					label.style.maximal_width = 150
					label.style.font = "default-semibold"
					label.style.font_color = get_color_team(team, true)

					if player_settings.show_players_state then
						add_player_list_gui(force, diplomacy_table)
					end
					if force.name == player.force.name then
						add(LABEL)
						add(LABEL)
						add(LABEL)
						add(LABEL)
					else
						local stance_label = add(LABEL)
						stance_label.name = team.name .. "_stance"
						stance_label.caption = {get_stance_name_diplomacy_by_type(stance_type)}
						local font_color = LABEL_FONT_COLORS[stance_type]
						if font_color then
							stance_label.style.font_color = font_color
						end

						if is_changed then
							-- TODO: improve
							if temp_diplomacy_table[team.name .. "_enemy"] ~= nil then
								local state
								state = temp_diplomacy_table[team.name .. "_enemy"].state
								add{type = "checkbox", name = team.name .. "_enemy", state = state}
								state = temp_diplomacy_table[team.name .. "_neutral"].state
								add{type = "checkbox", name = team.name .. "_neutral", state = state}
								state = temp_diplomacy_table[team.name .. "_ally"].state
								add{type = "checkbox", name = team.name .. "_ally", state = state}
							else
								add{type = "checkbox", name = team.name .. "_enemy", state = (stance_type == FILTER_DIPLOMACY_TYPE_ENEMY)}
								add{type = "checkbox", name = team.name .. "_neutral", state = (stance_type == FILTER_DIPLOMACY_TYPE_NEUTRAL)}
								add{type = "checkbox", name = team.name .. "_ally", state = (stance_type == FILTER_DIPLOMACY_TYPE_ALLY)}
							end
						else
							add{type = "checkbox", name = team.name .. "_enemy", state = (stance_type == FILTER_DIPLOMACY_TYPE_ENEMY), enabled = not global.diplomacy.locked_teams}
							add{type = "checkbox", name = team.name .. "_neutral", state = (stance_type == FILTER_DIPLOMACY_TYPE_NEUTRAL), enabled = not global.diplomacy.locked_teams}
							add{type = "checkbox", name = team.name .. "_ally", state = (stance_type == FILTER_DIPLOMACY_TYPE_ALLY), enabled = not global.diplomacy.locked_teams}
						end
					end
				end
			end
		else
			log("!Game tick = " .. game.tick .. ": team '" .. team.name .. "' is not a force!")
		end
	end

	-- Create button "confirm"
	if not flow.confirm_diplomacy then
		local button = flow.add{type = "button", name = "confirm_diplomacy", caption = {"gui-tag-edit.confirm"}}
		-- if global.is_blacklist_diplomacy[player.force.name] ~= nil then
		--   button.enabled = false
		-- end
	end
end

diplomacy_frame.update = function(player)
	if player and player.valid and player.connected then
		diplomacy_frame.fill(player)
	else
		for _, _player in pairs(game.connected_players) do
			diplomacy_frame.fill(_player)
		end
	end
end

diplomacy_frame.create = function(player)
	local screen = player.gui.screen
	local frame = screen.diplomacy_frame
	if frame then
		frame.destroy()
		return
	end

	frame = screen.add{type = "frame", name = "diplomacy_frame", caption = {"mod-name.diplomacy"}, direction = "vertical"}
	frame.visible = true
	frame.location = {x = 0, y = 50}

	screen.add{type = "empty-widget", drag_target = frame}
	local player_settings = global.diplomacy.players[player.index]
	local table_settings = frame.add{type = "table", name = 'settings', column_count = 4}
	table_settings.add{type = "label", caption = {"", {"diplomacy.gui.show_players_state"}, {"colon"}}}
	if player_settings.show_players_state == nil then
		player_settings.show_players_state = true
	end
	local show_players_state = player_settings.show_players_state
	table_settings.add{type = "checkbox", name = "d_show_players_state", state = show_players_state}
	table_settings.add{type = "label", caption = {"", {"diplomacy.gui.filter_of_diplomacy_stance"}, {"colon"}}}
	if player_settings.filter_of_diplomacy_stance == nil then
		player_settings.filter_of_diplomacy_stance = FILTER_DIPLOMACY_TYPE_ALL
	end
	table_settings.add{type = "drop-down", name = "d_filter_of_diplomacy_stance", items = FILTER_DIPLOMACY_TYPE_ITEMS, selected_index = player_settings.filter_of_diplomacy_stance}

	local inner_frame = frame.add{type = "frame", style = "inside_shallow_frame", name = "diplomacy_inner_frame", direction = "vertical"}
	inner_frame.style.left_padding = 8
	inner_frame.style.top_padding = 8
	inner_frame.style.right_padding = 8
	inner_frame.style.bottom_padding = 8
	diplomacy_frame.fill(player)
end

return diplomacy_frame
