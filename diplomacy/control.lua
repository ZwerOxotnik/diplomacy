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

-- You can write and receive any information on the links below.
-- Source: https://gitlab.com/ZwerOxotnik/diplomacy
-- Mod portal: https://mods.factorio.com/mod/diplomacy
-- Homepage: https://forums.factorio.com/viewtopic.php?f=190&t=64630

local color_map = require("diplomacy/color_map")
local set_politice = require("diplomacy/util").set_politice
local destroy_diplomacy_selection_frame = require("diplomacy/gui/frames/diplomacy_selection").destroy
local update_diplomacy_frame = require("diplomacy/gui/frames/diplomacy").update
local select_diplomacy = require("diplomacy/gui/select_diplomacy")
local confirm_diplomacy = require("diplomacy/gui/confirm_diplomacy")
local mod_gui = require("mod-gui")

local mod = {}
mod.events = {}
mod.add_commands = require("diplomacy/commands").add_commands


--#region Constants
local FORBIDDEN_TYPES = {
	["artillery-wagon"] = true,
	["electric-turret"] = true,
	["spider-vehicle"] = true,
	["fluid-turret"] = true,
	["rocket-silo"] = true,
	["cargo-wagon"] = true,
	["fluid-wagon"] = true,
	["ammo-turret"] = true,
	["locomotive"] = true,
	["character"] = true,
	["roboport"] = true,
	["radar"] = true,
	["car"] = true
}
--#endregion


--#region Settings
local diplomacy_HP_forbidden_entity_on_killed = settings.global["diplomacy_HP_forbidden_entity_on_killed"].value
local diplomacy_HP_forbidden_entity_on_mined = settings.global["diplomacy_HP_forbidden_entity_on_mined"].value
--#endregion



local function destroy_button(player)
	local diplomacy_button = mod_gui.get_button_flow(player).diplomacy_button
	if diplomacy_button then
		diplomacy_button.destroy()
	end
end

local function create_button(player)
	local button_flow = mod_gui.get_button_flow(player)
	if button_flow.diplomacy_button then
		button_flow.diplomacy_button.destroy()
	end
	button_flow.add{
		type = "sprite-button",
		sprite = "virtual-signal/diplomacy",
		hovered_sprite = "diplomacy_black",
		clicked_sprite = "diplomacy_black",
		name = "diplomacy_button",
		style = "slot_button",
		tooltip = {"mod-name.diplomacy"}
	}
end
mod.create_button = create_button

local function destroy_diplomacy_gui(player)
	local diplomacy_frame = player.gui.screen.diplomacy_frame
	if diplomacy_frame then
		diplomacy_frame.destroy()
	end
end

mod.destroy_gui = function(player)
	destroy_button(player)
	destroy_diplomacy_gui(player)
	destroy_diplomacy_selection_frame(player)
end

local function forbidden_entity_mine(event)
	-- Validation of data
	local player = game.get_player(event.player_index)
	local entity = player.selected
	if not (entity and entity.valid) then return end
	if player.controller_type == defines.controllers.editor then return end
	local force = player.force
	local mining_force = entity.force
	if not force.get_friend(mining_force) or force == mining_force then return end

	local max_health = game.entity_prototypes[entity.name].max_health
	if max_health >= diplomacy_HP_forbidden_entity_on_mined or FORBIDDEN_TYPES[entity.type] then
		player.clear_selected_entity()
	end
end

local function forbidden_entity_mined(event)
	-- Validation of data
	local entity = event.entity
	if not (entity and entity.valid) then return end
	local force = entity.force
	local player = game.get_player(event.player_index)
	if player.controller_type == defines.controllers.editor then return end
	local mining_force = player.force
	if force == mining_force or not force.get_friend(mining_force) then return end

	local max_health = game.entity_prototypes[entity.name].max_health
	if max_health >= diplomacy_HP_forbidden_entity_on_mined or FORBIDDEN_TYPES[entity.type] then
		set_politice["neutral"](force, mining_force, event.player_index)
		game.print({"team-changed-diplomacy", mining_force.name, force.name, {"neutral"}})
		mining_force.print({"player-changed-diplomacy", player.name, force.name})
		force.print({"player-changed-diplomacy", player.name, mining_force.name})
	end
end

local function check_stance_on_entity_died(event)
	local entity = event.entity
	local force = entity.force
	local killing_force = event.force
	if not force.get_cease_fire(killing_force) or killing_force == force then return end

	-- Find in list the teams
	local teams = global.diplomacy.teams
	if teams then
		local found_1st = false
		local found_2nd = false
		for _, team in pairs(teams) do
			if force.name == team.name then
				found_1st = true
			elseif killing_force.name == team.name then
				found_2nd = true
			end
		end
		if not (found_1st and found_2nd) then return end
	end

	-- Change policy between teams and print information
	local cause = event.cause
	if cause and cause.valid then
		local causer_index = nil
		if force.get_friend(killing_force) then
			if game.entity_prototypes[entity.name].max_health >= diplomacy_HP_forbidden_entity_on_killed or FORBIDDEN_TYPES[entity.type] then
				game.print({"team-changed-diplomacy", killing_force.name, force.name, {"enemy"}})
				if cause.type == "character" then
					causer_index = cause.player.index
					killing_force.print({"player-changed-diplomacy", cause.player.name, force.name})
					force.print({"player-changed-diplomacy", cause.player.name, killing_force.name})
				elseif cause.type == "car" then
					local passenger = cause.get_passenger()
					local driver = cause.get_driver()
					if passenger and driver then
						causer_index = driver.player.index
						killing_force.print({"player-changed-diplomacy", driver.player.name.." & "..passenger.player.name, force.name})
						force.print({"player-changed-diplomacy", driver.player.name.." & "..passenger.player.name, killing_force.name})
					elseif passenger then
						causer_index = passenger.player.index
						killing_force.print({"player-changed-diplomacy", passenger.player.name, force.name})
						force.print({"player-changed-diplomacy", passenger.player.name, killing_force.name})
					elseif driver then
						causer_index = driver.player.index
						killing_force.print({"player-changed-diplomacy", driver.player.name, force.name})
						force.print({"player-changed-diplomacy", driver.player.name, killing_force.name})
					else
						killing_force.print({"player-changed-diplomacy", cause.localised_name, force.name})
						force.print({"player-changed-diplomacy", cause.localised_name, killing_force.name})
					end
				else
					killing_force.print({"player-changed-diplomacy", cause.localised_name, force.name})
					force.print({"player-changed-diplomacy", cause.localised_name, killing_force.name})
				end
				set_politice["enemy"](force, killing_force, causer_index)
			else
				game.print({"team-changed-diplomacy", killing_force.name, force.name, {"neutral"}})
				killing_force.print({"player-changed-diplomacy", cause.localised_name, force.name})
				force.print({"player-changed-diplomacy", cause.localised_name, killing_force.name})
				if cause.type == "character" then
					causer_index = cause.player.index
					killing_force.print({"player-changed-diplomacy", cause.player.name, force.name})
					force.print({"player-changed-diplomacy", cause.player.name, killing_force.name})
				elseif cause.type == "car" then
					local passenger = cause.get_passenger()
					local driver = cause.get_driver()
					if passenger and driver then
						causer_index = driver.player.index
						killing_force.print({"player-changed-diplomacy", driver.player.name .. " & " .. passenger.player.name, force.name})
						force.print({"player-changed-diplomacy", driver.player.name .. " & " .. passenger.player.name, killing_force.name})
					elseif passenger then
						causer_index = passenger.player.index
						killing_force.print({"player-changed-diplomacy", passenger.player.name, force.name})
						force.print({"player-changed-diplomacy", passenger.player.name, killing_force.name})
					elseif driver then
						causer_index = driver.player.index
						killing_force.print({"player-changed-diplomacy", driver.player.name, force.name})
						force.print({"player-changed-diplomacy", driver.player.name, killing_force.name})
					else
						killing_force.print({"player-changed-diplomacy", cause.localised_name, force.name})
						force.print({"player-changed-diplomacy", cause.localised_name, killing_force.name})
					end
				else
					killing_force.print({"player-changed-diplomacy", cause.localised_name, force.name})
					force.print({"player-changed-diplomacy", cause.localised_name, killing_force.name})
				end
				set_politice["neutral"](force, killing_force, causer_index)
			end
		elseif force.get_cease_fire(killing_force) then
			set_politice["enemy"](force, killing_force)
			game.print({"team-changed-diplomacy", killing_force.name, force.name, {"enemy"}})
			killing_force.print({"player-changed-diplomacy", cause.localised_name, force.name})
			force.print({"player-changed-diplomacy", cause.localised_name, killing_force.name})
		end
	else
		if force.get_friend(killing_force) then
			if game.entity_prototypes[entity.name].max_health >= diplomacy_HP_forbidden_entity_on_killed or FORBIDDEN_TYPES[entity.type] then
				set_politice["enemy"](force, killing_force)
				game.print({"team-changed-diplomacy", killing_force.name, force.name, {"enemy"}})
				killing_force.print({"player-changed-diplomacy", "ANY", force.name})
				force.print({"player-changed-diplomacy", "ANY", killing_force.name})
			else
				set_politice["neutral"](force, killing_force)
				game.print({"team-changed-diplomacy", killing_force.name, force.name, {"neutral"}})
				killing_force.print({"player-changed-diplomacy", "ANY", force.name})
				force.print({"player-changed-diplomacy", "ANY", killing_force.name})
			end
		elseif force.get_cease_fire(killing_force) then
			set_politice["enemy"](force, killing_force)
			game.print({"team-changed-diplomacy", killing_force.name, force.name, {"enemy"}})
			killing_force.print({"player-changed-diplomacy", "ANY", force.name})
			force.print({"player-changed-diplomacy", "ANY", killing_force.name})
		end
	end
end

local function on_entity_died(event)
	pcall(check_stance_on_entity_died, event)
end

local function on_player_created(event)
	-- Validation of data
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end

	global.diplomacy.players[event.player_index] = {}
	create_button(player)
end

local STATE_GUIS = {
	["diplomacy_table"] = function(event)
		select_diplomacy.diplomacy_check_press(event)
	end,
	["d_show_players_state"] = function(event, player, element)
		global.diplomacy.players[event.player_index].show_players_state = element.state
		update_diplomacy_frame(player)
	end,
}
local function on_gui_checked_state_changed(event)
	local f = STATE_GUIS[event.element.parent.name]
	if f then f(event.element, game.get_player(event.player_index), event) end
end

local function on_gui_selection_state_changed(event)
	if event.element.name == "d_filter_of_diplomacy_stance" then
		local player = game.get_player(event.player_index)
		global.diplomacy.players[event.player_index].filter_of_diplomacy_stance = event.element.selected_index
		update_diplomacy_frame(player)
	end
end


local GUIS = {
	["mod_gui_inner_frame"] = function(element, player, event)
		select_diplomacy.on_gui_click(event)
	end,
	["diplomacy_frame"] = function(element, player, event)
		select_diplomacy.on_gui_click(event)
	end,
	["diplomacy_selection_frame"] = function(element, player, event)
		confirm_diplomacy.on_gui_click(player, element.name)
	end,
	["holding_table_buttons"] = function(element, player, event)
		confirm_diplomacy.on_gui_click(player, element.name)
	end,
}
local function on_gui_click(event)
	local f = GUIS[event.element.parent.name]
	if f then f(event.element, game.get_player(event.player_index), event) end
end

local function on_player_changed_force(event)
	local player = game.get_player(event.player_index)

	-- TODO: tests for checking special opimization
	--       between "on_player_changed_force" and "on_forces_merging" and "on_forces_merged"

	destroy_diplomacy_selection_frame(player)
	update_diplomacy_frame()
end

-- local function on_forces_merging(event)
-- 	for _, player in pairs(event.source.players) do
-- 		destroy_diplomacy_selection_frame(player)
-- 	end

-- 	update_diplomacy_frame()
-- end


local mod_settings = {
	["who_decides_diplomacy"] = function(value)
		global.diplomacy.who_decides_diplomacy = value
	end,
	["diplomacy_visible_all_teams"] = function(value)
		update_diplomacy_frame()
	end,
	["diplomacy_HP_forbidden_entity_on_killed"] = function(value)
		diplomacy_HP_forbidden_entity_on_killed = value
	end,
	["disable_diplomacy_on_entity_died"] = function(value)
		if value then
			mod.events[defines.events.on_entity_died] = function() end
		else
			mod.events[defines.events.on_entity_died] = on_entity_died
		end
		event_listener.update_event(mod, defines.events.on_entity_died)
	end,
	["diplomacy_HP_forbidden_entity_on_mined"] = function(value)
		diplomacy_HP_forbidden_entity_on_mined = value
		if value == 0 then
			mod.events[defines.events.on_player_mined_entity] = function() end
		else
			if settings.global["diplomacy_allow_mine_entity"].value then
				mod.events[defines.events.on_player_mined_entity] = forbidden_entity_mined
			else
				mod.events[defines.events.on_player_mined_entity] = function() end
			end
		end
		if settings.global["diplomacy_allow_mine_entity"].value then
			mod.events[defines.events.on_selected_entity_changed] = function() end
		else
			mod.events[defines.events.on_selected_entity_changed] = forbidden_entity_mine
		end
		event_listener.update_event(mod, defines.events.on_player_mined_entity)
		event_listener.update_event(mod, defines.events.on_selected_entity_changed)
	end,
	["diplomacy_allow_mine_entity"] = function(value)
		if diplomacy_HP_forbidden_entity_on_mined == 0 then
			mod.events[defines.events.on_player_mined_entity] = function() end
		else
			if value then
				mod.events[defines.events.on_player_mined_entity] = forbidden_entity_mined
			else
				mod.events[defines.events.on_player_mined_entity] = function() end
			end
		end
		if value then
			mod.events[defines.events.on_selected_entity_changed] = function() end
		else
			mod.events[defines.events.on_selected_entity_changed] = forbidden_entity_mine
		end
		event_listener.update_event(mod, defines.events.on_player_mined_entity)
		event_listener.update_event(mod, defines.events.on_selected_entity_changed)
	end,
}
local function on_runtime_mod_setting_changed(event)
	-- if event.setting_type ~= "runtime-global" then return end

	local f = mod_settings[event.setting]
	if f then f(settings.global[event.setting].value) end
end

local function on_player_left_game(event)
	-- Validation of data
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end

	select_diplomacy.on_player_left_game(player)
end

local function on_force_created(event)
	-- Validation of data
	local force = event.force
	if not (force and force.valid) then return end

	update_diplomacy_frame()
end

local function update_global_data()
	global.diplomacy = global.diplomacy or {}
	local diplomacy = global.diplomacy
	diplomacy.teams = diplomacy.teams or nil
	diplomacy.locked_teams = diplomacy.locked_teams or false
	diplomacy.who_decides_diplomacy = diplomacy.who_decides_diplomacy or settings.global["who_decides_diplomacy"].value
	diplomacy.color_map = diplomacy.color_map or color_map.get()
	diplomacy.players = diplomacy.players or {}

	if not game then return end

	local players_data = diplomacy.players
	for player_index in pairs(game.players) do
		if players_data[player_index] == nil then
			players_data[player_index] = {}
		end
	end
end
mod.on_init = update_global_data

mod.on_configuration_changed = function(data)
	update_global_data()

	-- see https://mods.factorio.com/mod/diplomacy/discussion/5d4caea33fac7d000b20a3c9
	for _, player in pairs(game.players) do
		create_button(player) -- still there are some bugs
	end
end

local function on_player_joined_game(event)
	-- Validation of data
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end

	update_diplomacy_frame()
end

-- local function on_forces_merged(event)

-- end

local function on_player_removed(event)
	update_diplomacy_frame()
	global.diplomacy.players[event.player_index] = nil
end

mod.add_remote_interface = function()
	remote.remove_interface("diplomacy")
	remote.add_interface("diplomacy",
	{
		get_event_name = function(name)
			return diplomacy_events[name]
		end,
		get_data = function()
			return global.diplomacy
		end,
		add_team = function(team)
			local list = global.diplomacy.teams
			table.insert(list, team)
		end,
		set_teams = function(teams)
			global.diplomacy.teams = teams
		end,
		remove_team = function(name)
			local teams = global.diplomacy.teams
			for k, team in pairs(teams) do
				if team.name == name then
					table.remove(teams, k)
					return k
				end
			end

			return 0 -- not found
		end,
		find_team = function(name)
			local teams = global.diplomacy.teams
			for k, team in pairs(teams) do
				if team.name == name then
					return k
				end
			end

			return 0 -- not found
		end,
		delete_teams = function()
			global.diplomacy.teams = nil
		end,
		get_who_decides_diplomacy = function()
			return global.diplomacy.who_decides_diplomacy
		end,
		set_who_decides_diplomacy = function(target)
			global.diplomacy.who_decides_diplomacy = target
		end,
		get_locked_teams = function()
			return global.diplomacy.locked_teams
		end,
		set_locked_teams = function(bool)
			global.diplomacy.locked_teams = bool
			update_diplomacy_frame()
		end
	})
end

mod.actions_after_init = function()

end

-- For attaching events
mod.events[defines.events.on_entity_died] = on_entity_died
mod.events[defines.events.on_player_changed_force] = function(e) pcall(on_player_changed_force, e) end
mod.events[defines.events.on_player_created] = on_player_created
mod.events[defines.events.on_player_left_game] = on_player_left_game
mod.events[defines.events.on_player_removed] = on_player_removed
mod.events[defines.events.on_player_joined_game] = on_player_joined_game
mod.events[defines.events.on_gui_click] = function(e) pcall(on_gui_click, e) end
mod.events[defines.events.on_gui_checked_state_changed] = function(e) pcall(on_gui_checked_state_changed, e) end
mod.events[defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed
mod.events[defines.events.on_force_created] = on_force_created
-- mod.events[defines.events.on_force_friends_changed] = update_diplomacy_frame -- TODO: test it thoroughly
-- mod.events[defines.events.on_force_cease_fire_changed] = update_diplomacy_frame -- TODO: test it thoroughly
mod.events[defines.events.on_gui_selection_state_changed] = function(e) pcall(on_gui_selection_state_changed, e) end
-- mod.events[defines.events.on_forces_merged] = on_forces_merged

if settings.global["disable_diplomacy_on_entity_died"].value then
	mod.events[defines.events.on_entity_died] = function() end
else
	mod.events[defines.events.on_entity_died] = on_entity_died
end

if diplomacy_HP_forbidden_entity_on_mined == 0 then
	mod.events[defines.events.on_player_mined_entity] = function() end
else
	if settings.global["diplomacy_allow_mine_entity"].value then
		mod.events[defines.events.on_player_mined_entity] = forbidden_entity_mined
	else
		mod.events[defines.events.on_player_mined_entity] = function() end
	end
end
if settings.global["diplomacy_allow_mine_entity"].value then
	mod.events[defines.events.on_selected_entity_changed] = function() end
else
	mod.events[defines.events.on_selected_entity_changed] = forbidden_entity_mine
end

return mod
