local function check_stance(cmd)
  -- Validation of data
  local player = game.player
  if not (player and player.valid) then return end
  if not cmd.parameter then player.print({"command-help.check_stance"}) return end

  local params = {}
  for param in string.gmatch(cmd.parameter, "%g+") do table.insert(params, param) end
  if params[1] == nil then player.print({"command-help.check_stance"}) return end
  if game.forces[params[1]] == nil then player.print({"command-help.unknown-command", params[1]}) return end
  if #params ~= 1 then
    if params[2] == nil then player.print({"command-help.check_stance"}) return end
    if game.forces[params[2]] == nil then player.print({"command-help.unknown-command", params[2]}) return end
    local force = game.forces[params[1]]
    local other_force = game.forces[params[2]]
    player.print(params[1].." >"..get_stance_diplomacy(force, other_force).."< "..params[2])
  else
    local force = player.force
    local other_force = game.forces[params[1]]
    player.print(force.name.." >"..get_stance_diplomacy(force, other_force).."< "..params[1])
  end
end
commands.add_command("check-stance", {"command-help.check_stance"}, check_stance)

local function player_force(cmd)
  -- Validation of data
  local player = game.player
  if not (player and player.valid) then return end
  if not cmd.parameter ~= nil then player.print({"command-help.player_force"}) return end

  local player_name = cmd.parameter
  if player_name == nil or game.players[player_name] == nil then player.print({"multiplayer.unknown-username", player_name}) return end
  player.print(player_name .. " - " .. game.players[player_name].force.name)
end
commands.add_command("player-force", {"command-help.player_force"}, player_force)

local function change_stance(cmd)
  -- Validation of data
  local player = game.player
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
      set_politice[params[2]](force, other_force)
      game.print({"team-changed-diplomacy", force.name, other_force.name, {params[2]}})
      force.print({"player-changed-diplomacy", player.name, force.name})
      other_force.print({"player-changed-diplomacy", player.name, force.name})
      for _, other_player in pairs(other_force.connected_players) do
        destroy_diplomacy_selection_gui(other_player)
      end
    elseif params[2] == "ally" then
      create_diplomacy_selection_gui(other_force, force.name, "ally")
      force.print({"player-changed-diplomacy", player.name, force.name})
      other_force.print({"player-changed-diplomacy", player.name, force.name})
    else
      if stance == "ally" then
        set_politice[params[2]](force, other_force)
        game.print({"team-changed-diplomacy", force.name, other_force.name, {params[2]}})
        force.print({"player-changed-diplomacy", player.name, force.name})
        other_force.print({"player-changed-diplomacy", player.name, force.name})
        for _, other_player in pairs(other_force.connected_players) do
          destroy_diplomacy_selection_gui(other_player)
        end
      else
        create_diplomacy_selection_gui(other_force, force.name, "neutral")
        force.print({"player-changed-diplomacy", player.name, force.name})
        other_force.print({"player-changed-diplomacy", player.name, force.name})
      end
    end
  else
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
end
commands.add_command("change-stance", {"command-help.change_stance"}, change_stance)

local function cancel_stance(cmd)
  -- Validation of data
  local player = game.player
  if not (player and player.valid) then return end
  if player.force.name == "spectator" then player.print({"command-attempted-not-allowed", player.name, "cancel-stance"}) return end

  local diplomacy = global.diplomacy
  if diplomacy.locked_teams then
    player.print({"teams-is-locked"})
    return
  elseif diplomacy.who_decides_diplomacy == "team_leader" then
    local team_leader =  player.force.connected_players[1]
    if player.name ~= team_leader.name then
      player.print({"not-team-leader", team_leader.name})
      return
    end
  end

  if cmd.parameter then
    if game.forces[cmd.parameter] == nil then player.print({"command-help.unknown-command", params[1]}) return end
    local other_force = game.forces[cmd.parameter]
    if other_force ~= player.force then
      cancel_request_diplomacy_force(player.force, other_force)
    end
  else
    local teams = global.diplomacy.teams or game.forces
    for _, other_force in pairs(target) do
      if other_force ~= player.force then
        cancel_request_diplomacy_force(player.force, other_force)
      end
    end
  end
end
commands.add_command("cancel-stance", {"command-help.cancel_stance"}, cancel_stance)
