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

local set_politice = require("diplomacy/util").set_politice
local cancel_request_diplomacy_force = require("diplomacy/util").cancel_request_diplomacy_force
local get_stance_diplomacy = require("diplomacy/util").get_stance_diplomacy
local create_diplomacy_frame = require("diplomacy/gui/frames/diplomacy").create
local destroy_diplomacy_selection_frame = require("diplomacy/gui/frames/diplomacy_selection").destroy
local create_diplomacy_selection_frame = require("diplomacy/gui/frames/diplomacy_selection").create
local mod_gui = require("mod-gui")

local module = {}

local function trim(s)
	return s:match'^%s*(.*%S)' or ''
end

-- Sends message to a player or server
local function print_to_caller(message, caller)
	if caller then
		if caller.valid then
			caller.print(message)
		end
	else
		print(message) -- this message for server
	end
end

local function check_stance(cmd)
	-- Validation of data
	local caller = game.get_player(cmd.player_index)
	if cmd.parameter == nil then
		print_to_caller({"command-help.check_stance"}, caller)
		return
	elseif #cmd.parameter > 100 then
		print_to_caller({"too-big-input-data"}, caller)
		return
	end

	cmd.parameter = trim(cmd.parameter)
	local args = {}
	for arg in string.gmatch(cmd.parameter, "%g+") do args[#args + 1] = arg end
	if args[1] == nil then print_to_caller({"command-help.check_stance"}, caller) return end
	if game.forces[args[1]] == nil then print_to_caller({"command-help.unknown-command", args[1]}, caller) return end

	if #args > 1 then
		if args[2] == nil then print_to_caller({"command-help.check_stance"}, caller) return end
		if game.forces[args[2]] == nil then print_to_caller({"command-help.unknown-command", args[2]}, caller) return end
		local force = game.forces[args[1]]
		local other_force = game.forces[args[2]]
		print_to_caller(args[1] .. " >" .. get_stance_diplomacy(force, other_force) .. "< " .. args[2], caller)
	elseif caller and caller.valid then
		local force = caller.force
		local other_force = game.forces[args[1]]
		print_to_caller(force.name .. " >" .. get_stance_diplomacy(force, other_force) .. "< " .. args[1], caller)
	end
end

local function player_force(cmd)
	-- Validation of data
	local caller = game.get_player(cmd.player_index)
	if cmd.parameter == nil then print_to_caller({"command-help.player_force"}, caller) return end
	if #cmd.parameter > 32 then
		print_to_caller({"gui-auth-server.username-too-long"}, caller)
		return
	end
	cmd.parameter = trim(cmd.parameter)

	local player = game.get_player(cmd.parameter)
	if cmd.parameter == nil or player == nil then print_to_caller({"multiplayer.unknown-username", cmd.parameter}, caller) return end
	print_to_caller(cmd.parameter .. " - " .. player.force.name, caller)
end

local function change_stance(cmd)
	-- Validation of data
	if cmd.player_index == 0 then print({"prohibited-server-command"}) return end
	local caller = game.get_player(cmd.player_index)
	if not (caller and caller.valid) then return end
	if caller.force.name == "spectator" then caller.print({"command-attempted-not-allowed", caller.name, "change-stance"}) return end

	local diplomacy = global.diplomacy
	if diplomacy.locked_teams then caller.print({"teams-is-locked"}) return end
	if diplomacy.who_decides_diplomacy == "team_leader" then
		local team_leader = caller.force.players[1]
		if caller.name ~= team_leader.name then
			caller.print({"not-team-leader", team_leader.name})
			return
		end
	end

	if cmd.parameter == nil then
		local diplomacy_button = mod_gui.get_button_flow(caller).diplomacy_button
		if diplomacy_button then
			diplomacy_button.destroy()
		end
		mod_gui.get_button_flow(caller).add{
			type = "sprite-button",
			sprite = "virtual-signal/diplomacy",
			name = "diplomacy_button",
			style = mod_gui.button_style,
			tooltip = {"mod-name.diplomacy"}
		}
		create_diplomacy_frame(caller)
	elseif #cmd.parameter < 70 then
		local args = {}
		for arg in string.gmatch(cmd.parameter, "%g+") do args[#args + 1] = arg end

		if args[1] == nil or args[2] == nil then caller.print({"command-help.change_stance"}) return end
		args[2] = string.lower(args[2])
		if not(args[2] == "ally" or args[2] == "neutral" or args[2] == "enemy") then caller.print({"command-help.change_stance"}) return end
		if game.forces[args[1]] == nil then caller.print({"command-help.unknown-command", args[1]}) return end

		local force = caller.force
		local other_force = game.forces[args[1]]
		if force == other_force then return end

		local stance = get_stance_diplomacy(force, other_force)
		if args[2] == stance then caller.print({"command-output.identical_stance"}) return end

		if args[2] == "enemy" then
			set_politice[args[2]](force, other_force, cmd.player_index)
			game.print({"team-changed-diplomacy", force.name, other_force.name, {args[2]}})
			force.print({"player-changed-diplomacy", caller.name, force.name})
			other_force.print({"player-changed-diplomacy", caller.name, force.name})
			for _, other_player in pairs(other_force.connected_players) do
				destroy_diplomacy_selection_frame(other_player)
			end
		elseif args[2] == "ally" then
			create_diplomacy_selection_frame(other_force, force.name, "ally")
			force.print({"player-changed-diplomacy", caller.name, force.name})
			other_force.print({"player-changed-diplomacy", caller.name, force.name})
		else
			if stance == "ally" then
				set_politice[args[2]](force, other_force, cmd.player_index)
				game.print({"team-changed-diplomacy", force.name, other_force.name, {args[2]}})
				force.print({"player-changed-diplomacy", caller.name, force.name})
				other_force.print({"player-changed-diplomacy", caller.name, force.name})
				for _, other_player in pairs(other_force.connected_players) do
					destroy_diplomacy_selection_frame(other_player)
				end
			else
				create_diplomacy_selection_frame(other_force, force.name, "neutral")
				force.print({"player-changed-diplomacy", caller.name, force.name})
				other_force.print({"player-changed-diplomacy", caller.name, force.name})
			end
		end
	else
		caller.print({"too-big-input-data"})
	end
end

local function cancel_stance(cmd)
	-- Validation of data
	if cmd.player_index == 0 then print({"prohibited-server-command"}) return end
	local caller = game.get_player(cmd.player_index)
	if not (caller and caller.valid) then return end
	if caller.force.name == "spectator" then caller.print({"command-attempted-not-allowed", caller.name, "cancel-stance"}) return end

	local diplomacy = global.diplomacy
	if diplomacy.locked_teams then
		caller.print({"teams-is-locked"})
		return
	elseif diplomacy.who_decides_diplomacy == "team_leader" then
		local team_leader = caller.force.players[1]
		if caller.name ~= team_leader.name then
			caller.print({"not-team-leader", team_leader.name})
			return
		end
	end

	if cmd.parameter then
		if #cmd.parameter > 52 then
			caller.print({"too-long-team-name"})
			return
		else
			cmd.parameter = trim(cmd.parameter)
		end

		if game.forces[cmd.parameter] == nil then caller.print({"command-help.unknown-command", cmd.parameter}) return end
		local other_force = game.forces[cmd.parameter]
		if other_force ~= caller.force then
			cancel_request_diplomacy_force(caller.force, other_force)
		end
	else
		local teams = global.diplomacy.teams or game.forces
		for _, other_force in pairs(teams) do
			if other_force ~= caller.force then
				cancel_request_diplomacy_force(caller.force, other_force)
			end
		end
	end
end

module.add_commands = function()
	commands.add_command("check-stance", {"command-help.check_stance"}, check_stance)
	commands.add_command("player-force", {"command-help.player_force"}, player_force)
	commands.add_command("change-stance", {"command-help.change_stance"}, change_stance)
	commands.add_command("cancel-stance", {"command-help.cancel_stance"}, cancel_stance)
end

return module
