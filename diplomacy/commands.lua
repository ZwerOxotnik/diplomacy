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

local set_politice = require("diplomacy/util").set_politice
local cancel_request_diplomacy_force = require("diplomacy/util").cancel_request_diplomacy_force
local get_stance_diplomacy = require("diplomacy/util").get_stance_diplomacy
local create_diplomacy_frame = require("diplomacy/gui/frames/diplomacy").create
local destroy_diplomacy_selection_frame = require("diplomacy/gui/frames/diplomacy_selection").destroy
local create_diplomacy_selection_frame = require("diplomacy/gui/frames/diplomacy_selection").create

local function print_to_sender(message, player)
	if player then
		if player.valid then
			player.print(message)
		end
	else
		print(message) -- this message to host
	end
end

local function check_stance(cmd)
	-- Validation of data
	local player = cmd.player_index and game.players[cmd.player_index]
	if not cmd.parameter then print_to_sender({"command-help.check_stance"}, player) return end

	local params = {}
	for param in string.gmatch(cmd.parameter, "%g+") do table.insert(params, param) end
	if params[1] == nil then print_to_sender({"command-help.check_stance"}, player) return end
	if game.forces[params[1]] == nil then print_to_sender({"command-help.unknown-command", params[1]}, player) return end
	if #params ~= 1 then
		if params[2] == nil then print_to_sender({"command-help.check_stance"}, player) return end
		if game.forces[params[2]] == nil then print_to_sender({"command-help.unknown-command", params[2]}, player) return end
		local force = game.forces[params[1]]
		local other_force = game.forces[params[2]]
		print_to_sender(params[1] .. " >" .. get_stance_diplomacy(force, other_force) .. "< " .. params[2], player)
	elseif player and player.valid then
		local force = player.force
		local other_force = game.forces[params[1]]
		print_to_sender(force.name .. " >" .. get_stance_diplomacy(force, other_force) .. "< " .. params[1], player)
	end
end

local function player_force(cmd)
	-- Validation of data
	local player = cmd.player_index and game.players[cmd.player_index]
	if not cmd.parameter ~= nil then print_to_sender({"command-help.player_force"}) return end

	local player_name = cmd.parameter
	if player_name == nil or game.players[player_name] == nil then player.print({"multiplayer.unknown-username", player_name}) return end
	print_to_sender(player_name .. " - " .. game.players[player_name].force.name, player)
end

local function change_stance(cmd)
	-- Validation of data
	if not cmd.player_index then return end
	local player = cmd.player_index and game.players[cmd.player_index]
	if not (player and player.valid) then return end
	if player.force.name == "spectator" then player.print({"command-attempted-not-allowed", player.name, "change-stance"}) return end

	local diplomacy = global.diplomacy
	if diplomacy.locked_teams then player.print({"teams-is-locked"}) return end
	if diplomacy.who_decides_diplomacy == "team_leader" then
		local team_leader = player.force.connected_players[1]
		if player.name ~= team_leader.name then
			player.print({"not-team-leader", team_leader.name})
			return
		end
	end

	if cmd.parameter then
		local params = {}
		for param in string.gmatch(cmd.parameter, "%g+") do table.insert(params, param) end

		if params[1] == nil or params[2] == nil then player.print({"command-help.change_stance"}) return end
		params[2] = string.lower(params[2])
		if not(params[2] == "ally" or params[2] == "neutral" or params[2] == "enemy") then player.print({"command-help.change_stance"}) return end
		if game.forces[params[1]] == nil then player.print({"command-help.unknown-command", params[1]}) return end

		local force = player.force
		local other_force = game.forces[params[1]]
		if force == other_force then return end

		local stance = get_stance_diplomacy(force, other_force)
		if params[2] == stance then player.print({"command-output.identical_stance"}) return end

		if params[2] == "enemy" then
			set_politice[params[2]](force, other_force, cmd.player_index)
			game.print({"team-changed-diplomacy", force.name, other_force.name, {params[2]}})
			force.print({"player-changed-diplomacy", player.name, force.name})
			other_force.print({"player-changed-diplomacy", player.name, force.name})
			for _, other_player in pairs(other_force.connected_players) do
				destroy_diplomacy_selection_frame(other_player)
			end
		elseif params[2] == "ally" then
			create_diplomacy_selection_frame(other_force, force.name, "ally")
			force.print({"player-changed-diplomacy", player.name, force.name})
			other_force.print({"player-changed-diplomacy", player.name, force.name})
		else
			if stance == "ally" then
				set_politice[params[2]](force, other_force, cmd.player_index)
				game.print({"team-changed-diplomacy", force.name, other_force.name, {params[2]}})
				force.print({"player-changed-diplomacy", player.name, force.name})
				other_force.print({"player-changed-diplomacy", player.name, force.name})
				for _, other_player in pairs(other_force.connected_players) do
					destroy_diplomacy_selection_frame(other_player)
				end
			else
				create_diplomacy_selection_frame(other_force, force.name, "neutral")
				force.print({"player-changed-diplomacy", player.name, force.name})
				other_force.print({"player-changed-diplomacy", player.name, force.name})
			end
		end
	else
		local diplomacy_button = mod_gui.get_button_flow(player).diplomacy_button
		if diplomacy_button then
			diplomacy_button.destroy()
		end
		mod_gui.get_button_flow(player).add{
			type = "sprite-button",
			sprite = "virtual-signal/diplomacy",
			name = "diplomacy_button",
			style = mod_gui.button_style,
			tooltip = {"mod-name.diplomacy"}
		}
		create_diplomacy_frame(player)
	end
end

local function cancel_stance(cmd)
	-- Validation of data
	if not cmd.player_index then return end
	local player = cmd.player_index and game.players[cmd.player_index]
	if not (player and player.valid) then return end
	if player.force.name == "spectator" then player.print({"command-attempted-not-allowed", player.name, "cancel-stance"}) return end

	local diplomacy = global.diplomacy
	if diplomacy.locked_teams then
		player.print({"teams-is-locked"})
		return
	elseif diplomacy.who_decides_diplomacy == "team_leader" then
		local team_leader = player.force.connected_players[1]
		if player.name ~= team_leader.name then
			player.print({"not-team-leader", team_leader.name})
			return
		end
	end

	if cmd.parameter then
		if game.forces[cmd.parameter] == nil then player.print({"command-help.unknown-command", cmd.parameter}) return end
		local other_force = game.forces[cmd.parameter]
		if other_force ~= player.force then
			cancel_request_diplomacy_force(player.force, other_force)
		end
	else
		local teams = global.diplomacy.teams or game.forces
		for _, other_force in pairs(teams) do
			if other_force ~= player.force then
				cancel_request_diplomacy_force(player.force, other_force)
			end
		end
	end
end

commands.add_commands = function()
	commands.add_command("check-stance", {"command-help.check_stance"}, check_stance)
	commands.add_command("player-force", {"command-help.player_force"}, player_force)
	commands.add_command("change-stance", {"command-help.change_stance"}, change_stance)
	commands.add_command("cancel-stance", {"command-help.cancel_stance"}, cancel_stance)
end

return commands
