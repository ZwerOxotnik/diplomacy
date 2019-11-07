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

-- You can write and receive any information on the links below.
-- Source: https://gitlab.com/ZwerOxotnik/diplomacy
-- Mod portal: https://mods.factorio.com/mod/diplomacy
-- Homepage: https://forums.factorio.com/viewtopic.php?f=190&t=64630

local color_map = require("diplomacy/color_map")
local set_politice = require("diplomacy/util").set_politice
local destroy_diplomacy_selection_frame = require("diplomacy/gui/frames/diplomacy_selection").destroy
require("diplomacy/commands")
local update_diplomacy_frame = require("diplomacy/gui/frames/diplomacy").update
local create_diplomacy_frame = require("diplomacy/gui/frames/diplomacy").create
local select_diplomacy = require("diplomacy/gui/select_diplomacy")
local confirm_diplomacy = require("diplomacy/gui/confirm_diplomacy")
local mod_gui = require("mod-gui")

local module = {}
module.version = "2.5.2"
module.events = {}
module.self_events = require("diplomacy/self_events")

local function get_event(event)
	if type(event) == "number" then
		return event
	else
		return defines.events[event] --or event
	end
end

-- This function for compatibility with "Event listener" module and into other modules
local function put_event(event, func)
	event = get_event(event)
	if event then
		module.events[event] = func
		if Event then
			Event.register(event, func)
		end
		return true
	else
		log("The event is nil")
		-- error("The event is nil")
	end
	return false
end

local function destroy_button(player)
	local diplomacy_button = mod_gui.get_button_flow(player).diplomacy_button
	if diplomacy_button then
		diplomacy_button.destroy()
	end
end

module.create_button = function(player)
	destroy_button(player)
	if player.spectator then return end
	mod_gui.get_button_flow(player).add{
		type = "button",
		caption = {"mod-name.diplomacy"},
		name = "diplomacy_button",
		style = mod_gui.button_style
	}
end

local function destroy_diplomacy_gui(player)
	local diplomacy_frame = player.gui.center.diplomacy_frame
	if diplomacy_frame then
		diplomacy_frame.destroy()
	end
end

module.destroy_gui = function(player)
	destroy_button(player)
	destroy_diplomacy_gui(player)
	destroy_diplomacy_selection_frame(player)
end

local function protect_from_theft_of_electricity(event)
	-- Validation of data
	local entity = event.created_entity
	if not (entity and entity.valid) then return end

	local force = entity.force
	if entity.type == "electric-pole" then
		local copper_neighbours = entity.neighbours["copper"]
		for _, neighbour in pairs(copper_neighbours) do
			if force ~= neighbour.force then
				if not force.get_cease_fire(neighbour.force) then
					entity.disconnect_neighbour(neighbour)
				end
			end
		end
	end
end

local function is_forbidden_entity_diplomacy(entity)
	if entity.type:find("turret") then return true end
	if entity.type:find("wagon") then return true end
	if entity.type == "locomotive" then return true end
	if entity.type == "car" then return true end
	if entity.type == "roboport" then return true end
	if entity.type == "radar" then return true end
	if entity.type == "rocket-silo" then return true end
	return false
end

local function forbidden_entity_mine(event)
	-- Validation of data
	local player = game.players[event.player_index]
	if player.selected == nil then return end
	local entity = player.selected
	if not (entity and entity.valid) then return end
	local force = player.force
	local mining_force = entity.force
	if not force.get_friend(mining_force) or force == mining_force then return end

	local max_health = game.entity_prototypes[entity.name].max_health
	if max_health >= settings.global["diplomacy_HP_forbidden_entity_on_mined"].value or is_forbidden_entity_diplomacy(entity) then
		player.clear_selected_entity()
	end
end

local function forbidden_entity_mined(event)
	-- Validation of data
	local entity = event.entity
	if not (entity and entity.valid) then return end
	local force = entity.force
	local player = game.players[event.player_index]
	local mining_force = player.force
	if force == mining_force or not force.get_friend(mining_force) then return end

	local max_health = game.entity_prototypes[entity.name].max_health
	if max_health >= settings.global["diplomacy_HP_forbidden_entity_on_mined"].value or is_forbidden_entity_diplomacy(entity) then
		set_politice["neutral"](force, mining_force)
		game.print({"team-changed-diplomacy", mining_force.name, force.name, {"neutral"}})
		mining_force.print({"player-changed-diplomacy", player.name, force.name})
		force.print({"player-changed-diplomacy", player.name, mining_force.name})
	end
end

local function check_stance_when_killed(event)
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
		if force.get_friend(killing_force) then
			if game.entity_prototypes[entity.name].max_health >= settings.global["diplomacy_HP_forbidden_entity_on_killed"].value or is_forbidden_entity_diplomacy(entity) or
					entity.type == "character" then
				set_politice["enemy"](force, killing_force)
				game.print({"team-changed-diplomacy", killing_force.name, force.name, {"enemy"}})
				if cause.type == "character" then
					killing_force.print({"player-changed-diplomacy", cause.player.name, force.name})
					force.print({"player-changed-diplomacy", cause.player.name, killing_force.name})
				elseif cause.type == "car" then
					local passenger = cause.get_passenger()
					local driver = cause.get_driver()
					if passenger and driver then
						killing_force.print({"player-changed-diplomacy", driver.player.name.." & "..passenger.player.name, force.name})
						force.print({"player-changed-diplomacy", driver.player.name.." & "..passenger.player.name, killing_force.name})
					elseif passenger then
						killing_force.print({"player-changed-diplomacy", passenger.player.name, force.name})
						force.print({"player-changed-diplomacy", passenger.player.name, killing_force.name})
					elseif driver then
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
			else
				set_politice["neutral"](force, killing_force)
				game.print({"team-changed-diplomacy", killing_force.name, force.name, {"neutral"}})
				killing_force.print({"player-changed-diplomacy", cause.localised_name, force.name})
				force.print({"player-changed-diplomacy", cause.localised_name, killing_force.name})
				if cause.type == "character" then
					killing_force.print({"player-changed-diplomacy", cause.player.name, force.name})
					force.print({"player-changed-diplomacy", cause.player.name, killing_force.name})
				elseif cause.type == "car" then
					local passenger = cause.get_passenger()
					local driver = cause.get_driver()
					if passenger and driver then
						killing_force.print({"player-changed-diplomacy", driver.player.name .. " & " .. passenger.player.name, force.name})
						force.print({"player-changed-diplomacy", driver.player.name .. " & " .. passenger.player.name, killing_force.name})
					elseif passenger then
						killing_force.print({"player-changed-diplomacy", passenger.player.name, force.name})
						force.print({"player-changed-diplomacy", passenger.player.name, killing_force.name})
					elseif driver then
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
			end
		elseif force.get_cease_fire(killing_force) then
			set_politice["enemy"](force, killing_force)
			game.print({"team-changed-diplomacy", killing_force.name, force.name, {"enemy"}})
			killing_force.print({"player-changed-diplomacy", cause.localised_name, force.name})
			force.print({"player-changed-diplomacy", cause.localised_name, killing_force.name})
		end
	else
		if force.get_friend(killing_force) then
			if game.entity_prototypes[entity.name].max_health >= settings.global["diplomacy_HP_forbidden_entity_on_killed"].value or is_forbidden_entity_diplomacy(entity) or
					entity.type == "character" then
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
	-- Validation of data
	local entity = event.entity
	if not (entity and entity.valid) then return end
	local force = entity.force
	if not (force and force.valid) then return end
	local killing_force = event.force
	if not (killing_force and killing_force.valid) then return end

	check_stance_when_killed(event)
end

local function on_player_created(event)
	-- Validation of data
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end

	create_diplomacy_frame(player)
	module.create_button(player)
end

local function on_gui_checked_state_changed(event)
	-- Validation of data
	local gui = event.element
	if not (gui and gui.valid) then return end
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end
	local parent = gui.parent
	if not parent then return end

	if parent.name == "diplomacy_table" then
		select_diplomacy.diplomacy_check_press(event)
	end
end

local function on_gui_click(event)
	-- Validation of data
	local gui = event.element
	if not (gui and gui.valid and gui.name) then return end
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end
	local parent = gui.parent
	if not parent then return end

	local parent_name = parent.name
	if parent_name == 'mod_gui_button_flow' or parent_name == 'diplomacy_frame' then
		select_diplomacy.on_gui_click(event)
		return true
	elseif parent_name == 'diplomacy_selection_frame' or parent_name == "holding_table_buttons" then
		confirm_diplomacy.on_gui_click(player, gui.name)
		return true
	end
end

local function on_player_changed_force(event)
	-- Validation of data
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end

	-- TODO: tests for checking special opimization
	--       between "on_player_changed_force" and "on_forces_merging" and "on_forces_merged"

	destroy_diplomacy_selection_frame(player)
	update_diplomacy_frame()
end

local function on_forces_merging(event)
	for _, player in pairs(event.source.players) do
		destroy_diplomacy_selection_frame(player)
	end

	update_diplomacy_frame()
end

local function check_stance_on_entity_damaged(event)
	-- Validation of data
	local entity = event.entity
	if not (entity and entity.valid) then return end
	local force = entity.force
	if not (force and force.valid) then return end
	local killing_force = event.force
	if not (killing_force and killing_force.valid) then return end
	if event.final_damage_amount < 1 then return end
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
		if game.entity_prototypes[entity.name].max_health >= settings.global["diplomacy_HP_forbidden_entity_on_damaged"].value then --entity.type == "rocket-silo"
			if force.get_cease_fire(killing_force) then
				set_politice["enemy"](force, killing_force)
				game.print({"team-changed-diplomacy", killing_force.name, force.name, {"enemy"}})
				if cause.type == "character" then
					killing_force.print({"player-changed-diplomacy", cause.player.name, force.name})
					force.print({"player-changed-diplomacy", cause.player.name, killing_force.name})
				elseif cause.type == "car" then
					local passenger = cause.get_passenger()
					local driver = cause.get_driver()
					if passenger and driver then
						killing_force.print({"player-changed-diplomacy", driver.player.name .. " & " .. passenger.player.name, force.name})
						force.print({"player-changed-diplomacy", driver.player.name .. " & " .. passenger.player.name, killing_force.name})
					elseif passenger then
						killing_force.print({"player-changed-diplomacy", passenger.player.name, force.name})
						force.print({"player-changed-diplomacy", passenger.player.name, killing_force.name})
					elseif driver then
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
			end
		end
	else
		if game.entity_prototypes[entity.name].max_health >= settings.global["diplomacy_HP_forbidden_entity_on_damaged"].value then --entity.type == "rocket-silo"
			if force.get_cease_fire(killing_force) then
				set_politice["enemy"](force, killing_force)
				game.print({"team-changed-diplomacy", killing_force.name, force.name, {"enemy"}})
				killing_force.print({"player-changed-diplomacy", "ANY", force.name})
				force.print({"player-changed-diplomacy", "ANY", killing_force.name})
			end
		end
	end
end

local function on_entity_damaged(event)
	if math.random(100) <= 3 then
		check_stance_on_entity_damaged(event)
	end
end

local function on_runtime_mod_setting_changed(event)
	if event.setting_type ~= "runtime-global" then return end

	local events = module.events
	if event.setting == "diplomacy_protection_from_theft_of_electricity" then
		if settings.global[event.setting].value then
			events.on_built_entity = protect_from_theft_of_electricity
			events.on_robot_built_entity = protect_from_theft_of_electricity
			event_listener.update_event("on_built_entity")
			event_listener.update_event("on_robot_built_entity")
		else
			events.on_built_entity = function() end
			events.on_robot_built_entity = function() end
			event_listener.update_event("on_built_entity")
			event_listener.update_event("on_robot_built_entity")
		end
	elseif event.setting == "diplomacy_on_entity_damaged_state" then
		if settings.global[event.setting].value then
			events.on_entity_damaged = on_entity_damaged
			event_listener.update_event("on_entity_damaged")
		else
			events.on_entity_damaged = function() end
			event_listener.update_event("on_entity_damaged")
		end
	elseif event.setting == "diplomacy_allow_mine_entity" then
		if settings.global[event.setting].value then
			events.on_selected_entity_changed = function() end
			events.on_player_mined_entity = forbidden_entity_mined
			event_listener.update_event("on_selected_entity_changed")
			event_listener.update_event("on_player_mined_entity")
		else
			events.on_player_mined_entity = function() end
			events.on_selected_entity_changed = forbidden_entity_mine
			event_listener.update_event("on_selected_entity_changed")
			event_listener.update_event("on_player_mined_entity")
		end
	elseif event.setting == "who_decides_diplomacy" then
		global.diplomacy.who_decides_diplomacy = settings.global[event.setting].value
	elseif event.setting == "diplomacy_visible_all_teams" then
		update_diplomacy_frame()
	end
end

local function on_player_left_game(event)
	-- Validation of data
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end

	select_diplomacy.on_player_left_game(player)
end

module.on_init = function()
	global.diplomacy = global.diplomacy or {}
	local diplomacy = global.diplomacy
	diplomacy.teams = diplomacy.teams or nil
	diplomacy.locked_teams = diplomacy.locked_teams or false
	diplomacy.who_decides_diplomacy = diplomacy.who_decides_diplomacy or settings.global["who_decides_diplomacy"].value
	diplomacy.color_map = diplomacy.color_map or color_map.get()
end

module.on_load = function()
	if not game then
		if global.diplomacy == nil then
			module.on_init()
		end
	end
end

-- see https://mods.factorio.com/mod/diplomacy/discussion/5d4caea33fac7d000b20a3c9
module.on_configuration_changed = function(data)
	for _, player in pairs(game.players) do
		module.create_button(player) -- still there are some bugs
	end
end

local function on_player_joined_game(event)
	-- Validation of data
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end

	update_diplomacy_frame()
end

-- local function on_forces_merged(event)

-- end

local function on_player_removed(event)
	update_diplomacy_frame()
end

remote.remove_interface("diplomacy")
remote.add_interface("diplomacy",
{
	get_event_name = function(name)
		return module.self_events[name]
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


-- For attaching events
put_event("on_entity_damaged", on_entity_damaged)
put_event("on_entity_died", on_entity_died)
put_event("on_player_changed_force", on_player_changed_force)
put_event("on_player_created", on_player_created)
put_event("on_player_left_game", on_player_left_game)
put_event("on_player_removed", on_player_removed)
put_event("on_player_joined_game", on_player_joined_game)
put_event("on_gui_click", on_gui_click)
put_event("on_gui_checked_state_changed", on_gui_checked_state_changed)
put_event("on_runtime_mod_setting_changed", on_runtime_mod_setting_changed)
-- put_event("on_forces_merged", on_forces_merged)

if not settings.global["diplomacy_protection_from_theft_of_electricity"].value then
	put_event("on_built_entity", function() end)
	put_event("on_robot_built_entity", function() end)
else
	put_event("on_built_entity", protect_from_theft_of_electricity)
	put_event("on_robot_built_entity", protect_from_theft_of_electricity)
end

if settings.global["diplomacy_on_entity_damaged_state"].value then
	put_event("on_entity_damaged", on_entity_damaged)
else
	put_event("on_entity_damaged", function() end)
end
if settings.global["diplomacy_allow_mine_entity"].value then
	put_event("on_selected_entity_changed", function() end)
else
	put_event("on_selected_entity_changed", forbidden_entity_mine)
end
if not settings.global["diplomacy_allow_mine_entity"].value then
	put_event("on_player_mined_entity", function() end)
else
	put_event("on_player_mined_entity", forbidden_entity_mined)
end

return module
