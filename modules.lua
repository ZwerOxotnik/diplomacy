--[[
Copyright 2018-2020 ZwerOxotnik <zweroxotnik@gmail.com>

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

local create_diplomacy_selection_frame = require("diplomacy/gui/frames/diplomacy_selection").create
local cancel_request_diplomacy_force = require("diplomacy/util").cancel_request_diplomacy_force
local get_stance_diplomacy_type = require("diplomacy/util").get_stance_diplomacy_type
local set_politice = require("diplomacy/util").set_politice

local get_event
if event_listener then
	get_event = function(event)
		return defines.events[event] or event
	end
else
	get_event = function(event)
		if type(event) == "number" then
			return event
		else
			return defines.events[event]
		end
	end
end

-- This function for compatibility with "Event listener" module and into other modules
local function put_event(event, func, module)
	event = get_event(event)
	if event then
		module.events[event] = func
		event_listener.update_event(event)
		return true
	else
		log("The event is undefined")
		-- error("The event is undefined")
	end
	return false
end

local modules = {}
modules.diplomacy = require("diplomacy/control")
modules.restrict_building = require("modules/restrict_building")

-- TODO: refactor this module
modules.for_secondary_chat = {}
modules.for_secondary_chat.events = {}
modules.for_secondary_chat.check_events = function()
	global.diplomacy.registredPvPs = {}
	local function_name = "get_event_name"
	for interface_name, _ in pairs( remote.interfaces ) do
		if remote.interfaces[interface_name][function_name] then
			global.diplomacy.registredPvPs[interface_name] = true
		end
	end

	global.diplomacy.registredChat = nil
	local function_name = "get_event_name"
	local interface_name = "secondary-chat"
	local remote_interface = remote.interfaces[interface_name]
	if remote_interface and remote_interface[function_name]
		and remote_interface["get_interactions_table_gui"]
		and remote_interface["update_chat_and_drop_down"]
	then
		global.diplomacy.registredChat = true
	end
end
modules.for_secondary_chat.handle_events = function()
	---- https://mods.factorio.com/mod/diplomacy/discussion/5dd0603d34bde6000c15d8ae
    -- 	if global.diplomacy.registredPvPs then
    -- 		-- Handling events "on_round_start" and "on_round_end"
    -- 		for interface_name, _ in pairs( remote.interfaces ) do
    -- 			if global.diplomacy.registredPvPs[interface_name] then
    -- 				local function_name = "get_event_name"
    -- 				local ID_1 = remote.call(interface_name, function_name, "on_round_start")
    -- 				local ID_2 = remote.call(interface_name, function_name, "on_round_end")
    -- 				if (type(ID_1) == "number") and (type(ID_2) == "number") then
    -- 					if (script.get_event_handler(ID_1) == nil) and (script.get_event_handler(ID_2) == nil) then
    -- 						local interface_function = "get_teams"
    
    -- 						-- Attach "on_round_start" event for creating gui
    -- 						put_event(ID_1, function()
    -- 							local diplomacy = global.diplomacy
    -- 							if remote.interfaces[interface_name] then
    -- 								if remote.interfaces[interface_name][interface_function] then
    -- 									diplomacy.teams = remote.call(interface_name, interface_function)
    -- 									for _, player in pairs(game.players) do
    -- 										modules.diplomacy.create_button(player)
    -- 										global.diplomacy.locked_teams = false
    -- 										return
    -- 									end
    -- 								end
    -- 							end
    -- 						end, modules.for_secondary_chat)
    
    -- 						-- Attach "on_round_end" event for destroying gui
    -- 						put_event(ID_2, function()
    -- 							local diplomacy = global.diplomacy
    -- 							if remote.interfaces[interface_name] then
    -- 								if remote.interfaces[interface_name][interface_function] then
    -- 									diplomacy.teams = {}
    -- 									for _, player in pairs(game.players) do
    -- 										modules.diplomacy.destroy_gui(player)
    -- 										global.diplomacy.locked_teams = true
    -- 									end
    -- 								end
    -- 							end
    -- 						end, modules.for_secondary_chat)
    -- 					end
    -- 				end
    -- 			end
    -- 		end
    -- 	end

	-- TODO: refactor this
	local function_name = "get_event_name"
	local interface_name = "secondary-chat"
	local remote_interface = remote.interfaces[interface_name]
	if remote_interface and remote_interface[function_name] and global.diplomacy.registredChat then
		local ID_1 = remote.call(interface_name, function_name, "on_update_chat_and_drop_down")
		if type(ID_1) == "number" then
			-- TODO: refactor this
			local function destroy_selecting_diplomacy_gui(gui)
				local table = gui.diplomacy
				if table then
					table.destroy()
				end
			end

			-- TODO: refactor this
			local function create_selecting_diplomacy_gui(gui, stance_type)
				destroy_selecting_diplomacy_gui(gui)
				local diplomacy = gui.add{type = "table", name = "diplomacy", column_count = 8}

				local type = "sprite-button"
				if stance_type == FILTER_DIPLOMACY_TYPE_ALLY then
					diplomacy.add{type = type, name = "scd_set_war", sprite = "virtual-signal/enemy"}
					diplomacy.add{type = type, name = "scd_set_neutral", sprite = "virtual-signal/neutral"}
				elseif stance_type == FILTER_DIPLOMACY_TYPE_ENEMY then
					diplomacy.add{type = type, name = "scd_set_neutral", sprite = "virtual-signal/neutral"}
					diplomacy.add{type = type, name = "scd_set_ally", sprite = "virtual-signal/ally"}
				else -- if stance_type == FILTER_DIPLOMACY_TYPE_NEUTRAL then
					diplomacy.add{type = type, name = "scd_set_war", sprite = "virtual-signal/enemy"}
					diplomacy.add{type = type, name = "scd_set_ally", sprite = "virtual-signal/ally"}
				end
			end

			-- Attach "on_update_chat_and_drop_down" event for inserting gui with selecting diplomacy
			local is_added = put_event(ID_1, function(event)
				local player = game.players[event.player_index]
				local diplomacy = global.diplomacy
				if diplomacy.locked_teams then return end
				if diplomacy.who_decides_diplomacy == "team_leader" then
					local team_leader = player.force.connected_players[1]
					if player ~= team_leader then
						return
					end
				end

				local interaction_gui = remote.call(interface_name, "get_interactions_table_gui", player)
				if not (interaction_gui and interaction_gui.valid) then return end
				if event.chat_name ~= "faction" then destroy_selecting_diplomacy_gui(interaction_gui) return end
				local selected_faction = game.forces[event.target]
				if not selected_faction or selected_faction == player.force then destroy_selecting_diplomacy_gui(interaction_gui) return end

				local stance_type = get_stance_diplomacy_type(player.force, selected_faction)
				create_selecting_diplomacy_gui(interaction_gui, stance_type)
			end, modules.for_secondary_chat)

			if not is_added then
				put_event("on_gui_click", function() end, modules.for_secondary_chat)
			else
				put_event("on_gui_click", function(event)
					-- Validation of data
					local gui = event.element
					if not (gui and gui.valid and gui.name) then return end
					local player = game.players[event.player_index]
					if not (player and player.valid) then return end
					local parent = gui.parent
					if not parent or parent.name ~= "diplomacy" then return end

					if gui.name == "scd_set_war" then
						local player_force = player.force
						local drop_down = parent.parent.targets_drop_down
						local other_force = game.forces[drop_down.items[drop_down.selected_index]]
						if other_force and other_force.valid then
							local stance_type = get_stance_diplomacy_type(player_force, other_force)
							if stance_type ~= FILTER_DIPLOMACY_TYPE_ENEMY then
								set_politice["enemy"](other_force, player_force, player.index)
								game.print({"team-changed-diplomacy", player_force.name, other_force.name, {"enemy"}})
								other_force.print({"player-changed-diplomacy", player.name, player_force.name})
								player_force.print({"player-changed-diplomacy", player.name, other_force.name})
								cancel_request_diplomacy_force(player_force, other_force)
							end
						end
						local interaction_gui = remote.call(interface_name, "get_interactions_table_gui", player)
						remote.call(interface_name, "update_chat_and_drop_down", interaction_gui.chat_drop_down, player)
						return true
					elseif gui.name == "scd_set_ally" then
						local player_force = player.force
						local drop_down = parent.parent.targets_drop_down
						local other_force = game.forces[drop_down.items[drop_down.selected_index]]
						if other_force and other_force.valid then
							local stance_type = get_stance_diplomacy_type(player_force, other_force)
							if stance_type == FILTER_DIPLOMACY_TYPE_ALLY then
								local interaction_gui = remote.call(interface_name, "get_interactions_table_gui", player)
								remote.call(interface_name, "update_chat_and_drop_down", interaction_gui.chat_drop_down, player)
							else
								create_diplomacy_selection_frame(other_force, player_force.name, "ally")
								other_force.print({"player-changed-diplomacy", player.name, player_force.name})
								player_force.print({"player-changed-diplomacy", player.name, other_force.name})
							end
						else
							local interaction_gui = remote.call(interface_name, "get_interactions_table_gui", player)
							remote.call(interface_name, "update_chat_and_drop_down", interaction_gui.chat_drop_down, player)
						end
						return true
					elseif gui.name == "scd_set_neutral" then
						local player_force = player.force
						local drop_down = parent.parent.targets_drop_down
						local other_force = game.forces[drop_down.items[drop_down.selected_index]]
						if other_force and other_force.valid then
							local stance_type = get_stance_diplomacy_type(player_force, other_force)
							if stance_type == FILTER_DIPLOMACY_TYPE_ALLY then
								set_politice["neutral"](other_force, player_force, player.index)
								game.print({"team-changed-diplomacy", player_force.name, other_force.name, {"neutral"}})
								other_force.print({"player-changed-diplomacy", player.name, player_force.name})
								player_force.print({"player-changed-diplomacy", player.name, other_force.name})
								cancel_request_diplomacy_force(player_force, other_force)
								local interaction_gui = remote.call(interface_name, "get_interactions_table_gui", player)
								remote.call(interface_name, "update_chat_and_drop_down", interaction_gui.chat_drop_down, player)
							elseif stance_type == FILTER_DIPLOMACY_TYPE_ENEMY then
								create_diplomacy_selection_frame(other_force, player_force.name, "neutral")
								other_force.print({"player-changed-diplomacy", player.name, player_force.name})
								player_force.print({"player-changed-diplomacy", player.name, other_force.name})
							else --if stance_type == FILTER_DIPLOMACY_TYPE_NEUTRAL then
								local interaction_gui = remote.call(interface_name, "get_interactions_table_gui", player)
								remote.call(interface_name, "update_chat_and_drop_down", interaction_gui.chat_drop_down, player)
							end
						else
							local interaction_gui = remote.call(interface_name, "get_interactions_table_gui", player)
							remote.call(interface_name, "update_chat_and_drop_down", interaction_gui.chat_drop_down, player)
						end
						return true
					end
				end, modules.for_secondary_chat)
			end
		end
	end
end
modules.for_secondary_chat.on_load = modules.for_secondary_chat.handle_events
modules.for_secondary_chat.on_init = modules.for_secondary_chat.check_events
modules.for_secondary_chat.on_configuration_changed = function()
	modules.for_secondary_chat.check_events()
	modules.for_secondary_chat.handle_events()
end

return modules
