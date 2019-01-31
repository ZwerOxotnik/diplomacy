function destroy_diplomacy_selection_gui(player)
  local frame = player.gui.left.diplomacy_selection_frame
  if frame then
    frame.destroy()
  end
end

function create_diplomacy_selection_gui(force, int_force_name, stance)
  local diplomacy = global.diplomacy
  local selected_players
  if diplomacy.who_decides_diplomacy == "team_leader" then
    selected_players = {force.connected_players[1]}
  else
    selected_players = force.connected_players
  end
  if selected_players == nil then return end

  for _, player in pairs(selected_players) do
    local gui = player.gui.left
    destroy_diplomacy_selection_gui(player)
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
    label.style.visible = false
    local label = holding_table.add{type = "label", name = "diplomacy_stance_label", caption = stance}
    label.style.visible = false
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

local function diplomacy_selected_gui(player)
  local gui = player.gui.left.diplomacy_selection_frame
  local force = player.force
  local other_force = game.forces[gui.holding_table_chat_label.diplomacy_other_force_label.caption]
  if not other_force then return end
  local stance = gui.holding_table_chat_label.diplomacy_stance_label.caption

  set_politice[stance](force, other_force)
  game.print({"team-changed-diplomacy", force.name, other_force.name, {stance}})
  other_force.print({"player-changed-diplomacy", player.name, force.name})
  force.print({"player-changed-diplomacy", player.name, other_force.name})
end

diplomacy_confirm = {}

diplomacy_confirm.on_gui_click = function(event)
  local gui = event.element
  local player = game.players[event.player_index]

  if gui.name == "cancel_button_dipl" then
    local force = player.force
    for _, player in pairs(force.connected_players) do
      destroy_diplomacy_selection_gui(player)
    end
  elseif gui.name == "accept_button_dipl" then
    local force = player.force
    diplomacy_selected_gui(player)
    for _, player in pairs(force.connected_players) do
      destroy_diplomacy_selection_gui(player)
    end
    update_diplomacy_frame()
  end
end

return diplomacy_confirm
