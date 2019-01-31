--[[
Diplomacy
Copyright (c) 2018-2019 ZwerOxotnik <zweroxotnik@gmail.com>
License: MIT
Version: 2.0.0 (2019.01.31)
Source: https://gitlab.com/ZwerOxotnik/diplomacy
Mod portal: https://mods.factorio.com/mod/diplomacy
Homepage: https://forums.factorio.com/viewtopic.php?f=190&t=64630
Description: Adds modified version diplomacy, scenario from PvP and are added diplomatic request,
             commands needful, auto-diplomacy customizable protection from theft of electricity,
             customized settings balance.
             Compatible with custom PvP scenario (not default). UPS friendly.
]]--

local color_map = require("diplomacy/color_map")
require("diplomacy/util")
require("diplomacy/commands")
local select_diplomacy = require("diplomacy/select_diplomacy")
local confirm_diplomacy = require("diplomacy/confirm_diplomacy")
local mod_gui = require("mod-gui")

local mod = {}
mod.self_events = require("diplomacy/self_events")
mod.version = "2.0.0"

local function destroy_button(player)
  local button_flow = mod_gui.get_button_flow(player)
  if button_flow.diplomacy__button then
    button_flow.diplomacy__button.destroy()
  end
end

mod.create_button = function(player)
  destroy_button(player)
  if player.force.name == "spectator" then return end
  mod_gui.get_button_flow(player).add{type = "button", caption = {"mod-name.diplomacy"}, name = "diplomacy__button", style = mod_gui.button_style}
end

local function destroy_diplomacy_gui(player)
  local center_gui = player.gui.center
  if center_gui.diplomacy_frame then
    center_gui.diplomacy_frame.destroy()
  end
end

mod.destroy_gui = function(player)
  destroy_button(player)
  destroy_diplomacy_gui(player)
  destroy_diplomacy_selection_gui(player)
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

local function forbidden_entity_mine(event)
  -- Validation of data
  local player = game.players[event.player_index]
  if player.selected == nil then return end
  local entity = player.selected
  if not (entity and entity.valid) then return end
  local force = player.force
  local mining_force = entity.force
  if not force.get_friend(mining_force) then return end

  local max_health = game.entity_prototypes[entity.name].max_health
  if max_health >= ((global.diplomacy_HP_forbidden_entity_on_mined ~= nil and global.diplomacy_HP_forbidden_entity_on_mined) or 300) or is_forbidden_entity_diplomacy(entity) then
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
  if not force.get_friend(mining_force) then return end

  local max_health = game.entity_prototypes[entity.name].max_health
  if max_health >= ((global.diplomacy_HP_forbidden_entity_on_mined ~= nil and global.diplomacy_HP_forbidden_entity_on_mined) or 300) or is_forbidden_entity_diplomacy(entity) then
    set_politice["neutral"](force, mining_force)
    game.print({"team-changed-diplomacy", mining_force.name, force.name, {"neutral"}})
    mining_force.print({"player-changed-diplomacy", player.name, force.name})
    force.print({"player-changed-diplomacy", player.name, mining_force.name})
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
  mod.create_button(player)
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

  if parent.name == 'mod_gui_button_flow' or parent.name == 'diplomacy_frame' then
    select_diplomacy.on_gui_click(event)
  elseif parent.name == 'diplomacy_selection_frame' or parent.name == "holding_table_buttons" then
    confirm_diplomacy.on_gui_click(event)
  end
end

local function on_player_changed_force(event)
  -- Validation of data
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end

  destroy_diplomacy_selection_gui(player)

  update_diplomacy_frame()
end

local function on_forces_merging(event)
  for _, player in pairs(event.source.players) do
    destroy_diplomacy_selection_gui(player)
  end

  update_diplomacy_frame()
end

local function on_entity_damaged(event)
  if math.random(100) <= 3 then
    check_stance_on_entity_damaged(event)
  end
end

local function on_runtime_mod_setting_changed(event)
  if event.setting_type ~= "runtime-global" then return end

  local events = mod.events
  if event.setting == "diplomacy_protection_from_theft_of_electricity" then
    if settings.global[event.setting].value then
      events.on_built_entity = protect_from_theft_of_electricity
      events.on_robot_built_entity = protect_from_theft_of_electricity
    else
      events.on_built_entity = function() end
      events.on_robot_built_entity = function() end
    end
  elseif event.setting == "diplomacy_on_entity_damaged_state" then
    if settings.global[event.setting].value then
      events.on_entity_damaged = on_entity_damaged
    else
      events.on_entity_damaged = function() end
    end
  elseif event.setting == "diplomacy_allow_mine_entity" then
    if settings.global[event.setting].value then
      events.on_selected_entity_changed = function() end
      events.on_player_mined_entity = forbidden_entity_mined
    else
      events.on_player_mined_entity = function() end
      events.on_selected_entity_changed = forbidden_entity_mine
    end
  elseif event.setting == "who_decides_diplomacy" then
    global.diplomacy.who_decides_diplomacy = settings.global[event.setting].value
  elseif event.setting == "diplomacy_visible_all_teams" then
    update_diplomacy_frame()
  end
end

local function on_player_left_game(event)
  -- Validation of data
  local gui = event.element
  local player = game.players[event.player_index]
  if not (player and player.valid and gui and gui.valid) then return end

  select_diplomacy.on_player_left_game(player)
end

local function init()
  global.diplomacy = global.diplomacy or {}
  local diplomacy = global.diplomacy
  diplomacy.teams = diplomacy.teams or nil
  diplomacy.locked_teams = diplomacy.locked_teams or false
  diplomacy.who_decides_diplomacy = diplomacy.who_decides_diplomacy or settings.global["who_decides_diplomacy"].value
  diplomacy.color_map = diplomacy.color_map or color_map.get()
end

local function on_load()
  if not game then
    if global.soft_evolution == nil then
      init()
    end
  end
end

remote.remove_interface("diplomacy")
remote.add_interface("diplomacy",
{
  get_event_name = function(name)
    return mod.self_events[name]
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

mod.events = {
  on_init = init,
  on_load = on_load,
  on_entity_damaged = on_entity_damaged,
  on_built_entity = protect_from_theft_of_electricity,
  on_robot_built_entity = protect_from_theft_of_electricity,
  on_entity_died = on_entity_died,
  on_selected_entity_changed = forbidden_entity_mine,
  on_player_mined_entity = forbidden_entity_mined,
  on_forces_merging = on_forces_merging,
  on_player_changed_force = on_player_changed_force,
  on_player_created = on_player_created,
  on_player_left_game = on_player_left_game,
  on_player_removed = update_diplomacy_frame,
  on_player_joined_game = update_diplomacy_frame,
  on_gui_click = on_gui_click,
  on_gui_checked_state_changed = on_gui_checked_state_changed,
  on_runtime_mod_setting_changed = on_runtime_mod_setting_changed
}
if not settings.global["diplomacy_protection_from_theft_of_electricity"].value then
  mod.events.on_built_entity = function() end
  mod.events.on_robot_built_entity = function() end
end
if not settings.global["diplomacy_on_entity_damaged_state"].value then
  mod.events.on_entity_damaged = function() end
end
if settings.global["diplomacy_allow_mine_entity"].value then
  mod.events.on_selected_entity_changed = function() end
end
if not settings.global["diplomacy_allow_mine_entity"].value then
  mod.events.on_player_mined_entity = function() end
end

return mod
