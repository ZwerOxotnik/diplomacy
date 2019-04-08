-- Copyright (c) 2018-2019 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the MIT licence;

local create_diplomacy_selection_frame = require("diplomacy/gui/frames/diplomacy_selection").create
local cancel_request_diplomacy_force = require("diplomacy/util").cancel_request_diplomacy_force
local get_stance_diplomacy = require("diplomacy/util").get_stance_diplomacy
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

modules.for_secondary_chat = {}
modules.for_secondary_chat.events = {}
modules.for_secondary_chat.handle_events = function()
	-- Searching events "on_round_start" and "on_round_end"
	for interface_name, _ in pairs( remote.interfaces ) do
		local function_name = "get_event_name"
		-- Is the event of interface exist?
		if remote.interfaces[interface_name][function_name] then
			local ID_1 = remote.call(interface_name, function_name, "on_round_start")
			local ID_2 = remote.call(interface_name, function_name, "on_round_end")
			if (type(ID_1) == "number") and (type(ID_2) == "number") then
				if (script.get_event_handler(ID_1) == nil) and (script.get_event_handler(ID_2) == nil) then
					local interface_function = "get_teams"

					-- Attach "on_round_start" event for creating gui
					put_event(ID_1, function()
						local diplomacy = global.diplomacy
						if remote.interfaces[interface_name] then
							if remote.interfaces[interface_name][interface_function] then
								diplomacy.teams = remote.call(interface_name, interface_function)
								for _, player in pairs(game.players) do
									modules.diplomacy.create_button(player)
									global.diplomacy.locked_teams = false
									return
								end
							end
						end
					end, modules.for_secondary_chat)

					-- Attach "on_round_end" event for destroyng gui
					put_event(ID_2, function()
						local diplomacy = global.diplomacy
						if remote.interfaces[interface_name] then
							if remote.interfaces[interface_name][interface_function] then
								diplomacy.teams = {}
								for _, player in pairs(game.players) do
									modules.diplomacy.destroy_gui(player)
									global.diplomacy.locked_teams = true
								end
							end
						end
					end, modules.for_secondary_chat)
				end
			end
		end
	end

	-- TODO: refactor this
	local function_name = "get_event_name"
	local interface_name = "secondary-chat"
	if remote.interfaces[interface_name] and remote.interfaces[interface_name][function_name]
	   and remote.interfaces[interface_name]["get_interactions_table_gui"]
	   and remote.interfaces[interface_name]["update_chat_and_drop_down"] then

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
			local function create_selecting_diplomacy_gui(gui, stance)
				destroy_selecting_diplomacy_gui(gui)
				local diplomacy = gui.add{type = "table", name = "diplomacy", column_count = 8}

				local type = "sprite-button"
				if stance == "ally" then
					diplomacy.add{type = type, name = "scd_set_war", sprite = "virtual-signal/signal-red"}
					diplomacy.add{type = type, name = "scd_set_neutral", sprite = "virtual-signal/signal-white"}
				elseif stance == "enemy" then
					diplomacy.add{type = type, name = "scd_set_neutral", sprite = "virtual-signal/signal-white"}
					diplomacy.add{type = type, name = "scd_set_ally", sprite = "virtual-signal/signal-green"}
				else -- if stance == "neutral" then
					diplomacy.add{type = type, name = "scd_set_war", sprite = "virtual-signal/signal-red"}
					diplomacy.add{type = type, name = "scd_set_ally", sprite = "virtual-signal/signal-green"}
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

				local stance = get_stance_diplomacy(player.force, selected_faction)
				create_selecting_diplomacy_gui(interaction_gui, stance)
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
					if not parent then return end

					if gui.name == "scd_set_war" then
						local player_force = player.force
						local drop_down = parent.parent.targets_drop_down
						local other_force = game.forces[drop_down.items[drop_down.selected_index]]
						if other_force and other_force.valid then
							local stance = get_stance_diplomacy(player_force, other_force)
							if stance ~= "enemy" then
								set_politice["enemy"](other_force, player_force)
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
							local stance = get_stance_diplomacy(player_force, other_force)
							if stance == "ally" then
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
							local stance = get_stance_diplomacy(player_force, other_force)
							if stance == "ally" then
								set_politice["neutral"](other_force, player_force)
								game.print({"team-changed-diplomacy", player_force.name, other_force.name, {"neutral"}})
								other_force.print({"player-changed-diplomacy", player.name, player_force.name})
								player_force.print({"player-changed-diplomacy", player.name, other_force.name})
								cancel_request_diplomacy_force(player_force, other_force)
								local interaction_gui = remote.call(interface_name, "get_interactions_table_gui", player)
								remote.call(interface_name, "update_chat_and_drop_down", interaction_gui.chat_drop_down, player)
							elseif stance == "enemy" then
								create_diplomacy_selection_frame(other_force, player_force.name, "neutral")
								other_force.print({"player-changed-diplomacy", player.name, player_force.name})
								player_force.print({"player-changed-diplomacy", player.name, other_force.name})
							else --if stance == "neutral" then
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
modules.for_secondary_chat.on_init = modules.for_secondary_chat.handle_events

return modules
