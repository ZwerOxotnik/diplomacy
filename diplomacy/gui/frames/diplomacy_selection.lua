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

local diplomacy_selection_frame = {}

diplomacy_selection_frame.destroy = function(player)
	local frame = player.gui.left.diplomacy_selection_frame
	if frame then
		frame.destroy()
	end
end

-- TODO: improve
diplomacy_selection_frame.create = function(force, int_force_name, stance)
	local diplomacy = global.diplomacy
	local selected_players
	if diplomacy.who_decides_diplomacy == "team_leader" then
		selected_players = {force.connected_players[1]}
	else
		selected_players = force.connected_players
	end
	if selected_players == nil then return end

	for i=1, #selected_players do
		local player = selected_players[i]
		local gui = player.gui.left
		diplomacy_selection_frame.destroy(player)
		local frame = gui.add{type = "frame", name = "diplomacy_selection_frame", caption = {stance}}
		if stance == "ally" then
			frame.style.font_color = {r = 0.5, g = 1, b = 0.5}
		end
		local holding_table = frame.add{type = "table", name = "holding_table_chat_label", column_count = 2}
		holding_table.add{type = "label", name = "force_name", caption = {"team-changed-diplomacy", player.force.name, int_force_name, ""}}
		local label = holding_table.add{type = "label", caption = {stance}}
		if stance == "ally" then
			label.style.font_color = {r = 0.5, g = 1, b = 0.5}
		end
		local label = holding_table.add{type = "label", name = "diplomacy_other_force_label", caption = int_force_name}
		label.visible = false
		local label = holding_table.add{type = "label", name = "diplomacy_stance_label", caption = stance}
		label.visible = false
		local holding_table2 = holding_table.add{type = "table", name = "holding_table_buttons", column_count = 2}
		local button = holding_table2.add{type = "button", name = "cancel_button_dipl", caption =  {"gui-mod-settings.cancel"}}
		button.style.font = "default"
		button.style.top_padding = 0
		button.style.bottom_padding = 0
		button.style.font_color = {r = 1, g = 0.1, b = 0.1}
		local button = holding_table2.add{type = "button", name = "accept_button_dipl", caption = {"gui-tag-edit.confirm"}}
		button.style.font_color = {r = 0, g = 1, b = 0}
		button.style.font = "default"
		button.style.top_padding = 0
		button.style.bottom_padding = 0
	end
end

return diplomacy_selection_frame
