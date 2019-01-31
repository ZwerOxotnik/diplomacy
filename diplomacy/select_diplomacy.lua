-- This is file taken from game "Factorio" version 0.16.12 scenario "PvP" and modified by ZwerOxotnik <zweroxotnik@gmail.com>
-- Read terms of service: https://www.factorio.com/terms-of-service

local mod_gui = require("mod-gui")

function add_player_list_gui(force, gui)
  if not (force and force.valid) then return end

  if #force.players == 0 then
    gui.add{type = "label", caption = {"size.none"}}
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
    for _, player in pairs(force.connected_players) do
      if not first then
        online_names = online_names..", "
      end
      first = false
      online_names = online_names..player.name
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
        offline_names = offline_names..", "
      end
      first = false
      offline_names = offline_names..player.name
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

function create_diplomacy_frame(player)
  local flow = player.gui.center.diplomacy_frame
  if not flow then return end
  local gui = flow.diplomacy_inner_frame
  if not gui then return end

  local diplomacy_scrollpane = gui.diplomacy_scrollpane
  local diplomacy_table
  local is_changed = false
  local temp_diplomacy_table = {}
  if not diplomacy_scrollpane then
    local scroll = gui.add{name = "diplomacy_scrollpane", type = "scroll-pane"}
    scroll.style.maximal_height = 320
    diplomacy_table = scroll.add{type = "table", name = "diplomacy_table", column_count = 6}
    diplomacy_table.style.horizontal_spacing = 16
    diplomacy_table.style.vertical_spacing = 8
    diplomacy_table.draw_horizontal_lines = true
    diplomacy_table.draw_vertical_lines = true
  else
    diplomacy_table = gui.diplomacy_scrollpane.diplomacy_table
    is_changed = true
    for _, child in pairs(diplomacy_table.children) do
      if child.type == "checkbox" then
        temp_diplomacy_table[child.name] = {state = child.state}
      end
    end
    diplomacy_table.clear()
  end

  for _, name in pairs({"team-name", "gui-browse-games.players", "stance", "enemy", "neutral", "ally"}) do
    local label = diplomacy_table.add{type = "label", name = name, caption = {name}}
    label.style.font = "default-bold"
  end

  local teams
  local is_show_all_teams = false
  if settings.global["diplomacy_visible_all_teams"].value then
    teams = game.forces
    is_show_all_teams = true
  else
    teams = global.diplomacy.teams or game.forces
  end
  for _, team in pairs(teams) do
    local force = game.forces[team.name]
    if force then
      if is_show_all_teams or global.diplomacy.teams ~= nil or #force.players ~= 0 then
        local label = diplomacy_table.add{type = "label", name = team.name .. "_name", caption = team.name}
        label.style.single_line = false
        label.style.maximal_width = 150
        label.style.font = "default-semibold"
        label.style.font_color = get_color_team(team, true)
        add_player_list_gui(force, diplomacy_table)
        if force.name == player.force.name then
          diplomacy_table.add{type = "label"}
          diplomacy_table.add{type = "label"}
          diplomacy_table.add{type = "label"}
          diplomacy_table.add{type = "label"}
        else
          local stance = get_stance_diplomacy(player.force, force)
          local stance_label = diplomacy_table.add{type = "label", name = team.name .. "_stance", caption = {stance}}
          if stance == "ally" then
            stance_label.style.font_color = {r = 0.5, g = 1, b = 0.5}
          elseif stance == "enemy" then
            stance_label.style.font_color = {r = 1, g = 0.5, b = 0.5}
          end

          if is_changed then
            if temp_diplomacy_table[team.name .. "_enemy"] ~= nil then
              local state
              state = temp_diplomacy_table[team.name .. "_enemy"].state
              diplomacy_table.add{type = "checkbox", name = team.name .. "_enemy", state = state}
              state = temp_diplomacy_table[team.name .. "_neutral"].state
              diplomacy_table.add{type = "checkbox", name = team.name .. "_neutral", state = state}
              state = temp_diplomacy_table[team.name .. "_ally"].state
              diplomacy_table.add{type = "checkbox", name = team.name .. "_ally", state = state}
            else
              diplomacy_table.add{type = "checkbox", name = team.name .. "_enemy", state = (stance == "enemy")}
              diplomacy_table.add{type = "checkbox", name = team.name .. "_neutral", state = (stance == "neutral")}
              diplomacy_table.add{type = "checkbox", name = team.name .. "_ally", state = (stance == "ally")}
            end
          else
            diplomacy_table.add{type = "checkbox", name = team.name .. "_enemy", state = (stance == "enemy"), enabled = not global.diplomacy.locked_teams}
            diplomacy_table.add{type = "checkbox", name = team.name .. "_neutral", state = (stance == "neutral"), enabled = not global.diplomacy.locked_teams}
            diplomacy_table.add{type = "checkbox", name = team.name .. "_ally", state = (stance == "ally"), enabled = not global.diplomacy.locked_teams}
          end
        end
      end
    else
      log("!Game tick = " .. game.tick .. ": team '" .. team.name .. "' is not a force!")
    end
  end

  if not flow.confirm_diplomacy then
    local button = flow.add{type = "button", name = "confirm_diplomacy", caption = {"gui-tag-edit.confirm"}}
    -- if global.is_blacklist_diplomacy[player.force.name] ~= nil then
    --   button.enabled = false
    -- end
  end
end

function update_diplomacy_frame()
  for _, player in pairs(game.connected_players) do
    create_diplomacy_frame(player)
  end
end

local function diplomacy_button_press(event)
  local player = game.players[event.player_index]
  local flow = player.gui.center

  local frame = flow.diplomacy_frame
  if frame then
    frame.destroy()
    return
  end

  frame = flow.add{type = "frame", name = "diplomacy_frame", caption = {"mod-name.diplomacy"}, direction = "vertical"}
  frame.style.visible = true
  frame.style.title_bottom_padding = 8
  local inner_frame = frame.add{type = "frame", style = "image_frame", name = "diplomacy_inner_frame", direction = "vertical"}
  inner_frame.style.left_padding = 8
  inner_frame.style.top_padding = 8
  inner_frame.style.right_padding = 8
  inner_frame.style.bottom_padding = 8
  create_diplomacy_frame(player)
end

local function confirm_diplomacy(event)
  local gui = event.element
  local player = game.players[event.player_index]
  local diplomacy_table = gui.parent.diplomacy_inner_frame.diplomacy_scrollpane.diplomacy_table
  local some_change = false
  local player_force = player.force
  for _, child in pairs(diplomacy_table.children) do
    if child.type == "checkbox" and child.state then
      if child.name:find("_ally") then
        local name = child.name:gsub("_ally", "")
        local force = game.forces[name]
        local stance = get_stance_diplomacy(player_force, force)
        if stance ~= "ally" then
          create_diplomacy_selection_gui(force, player_force.name, "ally")
          force.print({"player-changed-diplomacy", player.name, player_force.name})
          player_force.print({"player-changed-diplomacy", player.name, force.name})
          some_change = true
        end
      elseif child.name:find("_neutral") then
        local name = child.name:gsub("_neutral", "")
        local force = game.forces[name]
        local stance = get_stance_diplomacy(player_force, force)
        if stance ~= "neutral" then
          if stance == "ally" then
            set_politice["neutral"](force, player_force)
            game.print({"team-changed-diplomacy", player_force.name, force.name, {"neutral"}})
            force.print({"player-changed-diplomacy", player.name, player_force.name})
            player_force.print({"player-changed-diplomacy", player.name, force.name})
            cancel_request_diplomacy_force(player_force, force)
          else
            create_diplomacy_selection_gui(force, player_force.name, "neutral")
          end
          some_change = true
        end
      elseif child.name:find("_enemy") then
        local name = child.name:gsub("_enemy", "")
        local force = game.forces[name]
        local stance = get_stance_diplomacy(player_force, force)
        if stance ~= "enemy" then
          set_politice["enemy"](force, player_force)
          game.print({"team-changed-diplomacy", player_force.name, force.name, {"enemy"}})
          force.print({"player-changed-diplomacy", player.name, player_force.name})
          player_force.print({"player-changed-diplomacy", player.name, force.name})
          cancel_request_diplomacy_force(player_force, force)
          some_change = true
        end
      end
    end
  end

  if some_change then
    update_diplomacy_frame()
  end
  if player.gui.center.diplomacy_frame then
    player.gui.center.diplomacy_frame.destroy()
  end
end


local select_diplomacy = {}

select_diplomacy.diplomacy_check_press = function(event)
  local gui = event.element
  if not gui.valid then return end

  if not (gui.name:find("_enemy")
    or gui.name:find("_neutral")
    or gui.name:find("_ally")) then
    return
  end

  if not gui.state then
    gui.state = true
    return
  end

  local index = 1
  for k, child in pairs(gui.parent.children) do
    if child.name == gui.name then
      index = k
      break
    end
  end

  if gui.name:find("_neutral") then
    gui.parent.children[index+1].state = false
    gui.parent.children[index-1].state = false
  elseif gui.name:find("_ally") then
    gui.parent.children[index-2].state = false
    gui.parent.children[index-1].state = false
  else
    gui.parent.children[index+1].state = false
    gui.parent.children[index+2].state = false
  end
end

function get_stance_diplomacy(force, other_force)
  if force.get_friend(other_force) then
    return "ally"
  elseif force.get_cease_fire(other_force) then
    return "neutral"
  else
    return "enemy"
  end
end

select_diplomacy.on_player_left_game = function(player)
  destroy_diplomacy_selection_gui(player)
  update_diplomacy_frame()
end

local button_press_functions = {
  ["diplomacy__button"] = diplomacy_button_press,
  ["diplomacy_cancel"] = function(event) game.players[event.player_index].diplomacy_frame.destroy() end,
  ["confirm_diplomacy"] = confirm_diplomacy,
}

select_diplomacy.on_gui_click = function(event)
  local gui = event.element
  local button_function = button_press_functions[gui.name]
  if button_function then
    button_function(event)
  end
end

return select_diplomacy
