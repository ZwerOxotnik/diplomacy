set_politice = {
  ally = function(force, other_force)
    force.set_friend(other_force, true)
    force.set_cease_fire(other_force, true)
    other_force.set_friend(force, true)
    other_force.set_cease_fire(force, true)
  end,
  neutral = function(force, other_force)
    force.set_friend(other_force, false)
    force.set_cease_fire(other_force, true)
    other_force.set_friend(force, false)
    other_force.set_cease_fire(force, true)
  end,
  enemy = function(force, other_force)
    force.set_friend(other_force, false)
    force.set_cease_fire(other_force, false)
    other_force.set_friend(force, false)
    other_force.set_cease_fire(force, false)
  end
}

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

function check_stance_when_killed(event)
  local entity = event.entity
  local force = entity.force
  local killing_force = event.force
  if killing_force == force then return end

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

  local cause = event.cause
  if cause and cause.valid then
    if force.get_friend(killing_force) then
      if game.entity_prototypes[entity.name].max_health >= settings.global["diplomacy_HP_forbidden_entity_on_killed"].value or is_forbidden_entity_diplomacy(entity) or
         entity.type == "player" then
        set_politice["enemy"](force, killing_force)
        game.print({"team-changed-diplomacy", killing_force.name, force.name, {"enemy"}})
        if cause.type == "player" then
          killing_force.print({"player-changed-diplomacy", cause.player.name, force.name})
          force.print({"player-changed-diplomacy", cause.player.name, killing_force.name})
        elseif cause.type == "car" then
          passenger = cause.get_passenger()
          driver = cause.get_driver()
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
        if cause.type == "player" then
          killing_force.print({"player-changed-diplomacy", cause.player.name, force.name})
          force.print({"player-changed-diplomacy", cause.player.name, killing_force.name})
        elseif cause.type == "car" then
          passenger = cause.get_passenger()
          driver = cause.get_driver()
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
         entity.type == "player" then
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

function check_stance_on_entity_damaged(event)
  -- Validation of data
  local entity = event.entity
  if not (entity and entity.valid) then return end
  local force = entity.force
  if not (force and force.valid) then return end
  local killing_force = event.force
  if not (killing_force and killing_force.valid) then return end
  if killing_force == force then return end
  if event.final_damage_amount < 1 then return end

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

  -- Change policy between teams
  local cause = event.cause
  if cause and cause.valid then
    if game.entity_prototypes[entity.name].max_health >= settings.global["diplomacy_HP_forbidden_entity_on_damaged"].value then --entity.type == "rocket-silo"
      if force.get_cease_fire(killing_force) then
        set_politice["enemy"](force, killing_force)
        game.print({"team-changed-diplomacy", killing_force.name, force.name, {"enemy"}})
        if cause.type == "player" then
          killing_force.print({"player-changed-diplomacy", cause.player.name, force.name})
          force.print({"player-changed-diplomacy", cause.player.name, killing_force.name})
        elseif cause.type == "car" then
          passenger = cause.get_passenger()
          driver = cause.get_driver()
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

function cancel_request_diplomacy_force(player_force, force)
  for _, other_player in pairs(force.connected_players) do
    local diplomacy_selection_frame = other_player.gui.left.diplomacy_selection_frame
    if diplomacy_selection_frame ~= nil then
      if player_force == game.forces[diplomacy_selection_frame.holding_table_chat_label.diplomacy_other_force_label.caption] then
        destroy_diplomacy_selection_gui(other_player)
      end
    end
  end
end
