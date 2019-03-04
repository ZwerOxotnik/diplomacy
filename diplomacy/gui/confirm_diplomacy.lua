-- Copyright (c) 2018-2019 ZwerOxotnik <zweroxotnik@gmail.com>
-- Licensed under the MIT licence;

local destroy_diplomacy_selection_frame = require("diplomacy/gui/frames/diplomacy_selection").destroy
local update_diplomacy_frame = require("diplomacy/gui/frames/diplomacy").update
local set_politice = require("diplomacy/util").set_politice

local function diplomacy_selected_frame(player)
	local frame = player.gui.left.diplomacy_selection_frame
	local force = player.force
	local other_force = game.forces[frame.holding_table_chat_label.diplomacy_other_force_label.caption]
	if not other_force then return end
	local stance = frame.holding_table_chat_label.diplomacy_stance_label.caption

	set_politice[stance](force, other_force)
	game.print({"team-changed-diplomacy", force.name, other_force.name, {stance}})
	other_force.print({"player-changed-diplomacy", player.name, force.name})
	force.print({"player-changed-diplomacy", player.name, other_force.name})
end

local confirm_diplomacy = {}

confirm_diplomacy.on_gui_click = function(event)
	local gui = event.element
	local player = game.players[event.player_index]

	if gui.name == "cancel_button_dipl" then
		local force = player.force
		for _, target in pairs(force.connected_players) do
			destroy_diplomacy_selection_frame(target)
		end
	elseif gui.name == "accept_button_dipl" then
		local force = player.force
		diplomacy_selected_frame(player)
		for _, target in pairs(force.connected_players) do
			destroy_diplomacy_selection_frame(target)
		end
		update_diplomacy_frame()
	end
end

return confirm_diplomacy
