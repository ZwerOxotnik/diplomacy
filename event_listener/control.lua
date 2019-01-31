--[[
Event listener
Copyright (c) 2018-2019 ZwerOxotnik <zweroxotnik@gmail.com>
License: MIT
Version: 0.2.0 (2019.01.29)
Source: https://gitlab.com/ZwerOxotnik/event-listener
Mod portal: https://mods.factorio.com/mod/event-listener
Homepage: https://forums.factorio.com/viewtopic.php?f=190&t=64621
Description: The script combine events of other scripts.
             Designed for mod developers.
]]--

local mod = {}
mod.version = "0.2.0"

local function debug(message)
  log(message)
  if game then
    game.write_file("event_listener", message, true)
  end
end

local function create_container(list, name_event)
  local container = {}
  for name_mod, _ in pairs( list ) do
    if type(list[name_mod]) == 'table' and type(list[name_mod].events) == 'table' and list[name_mod].events[name_event] then
      table.insert(container, list[name_mod].events[name_event])
      if list[name_mod].version then
        debug("For '" .. name_mod .. "' version='" .. list[name_mod].version .. "' processed event '" .. name_event .. "'")
      else
        debug("For '" .. name_mod .. "' version='unknown' processed event '" .. name_event .. "'")
      end
    end
  end
  return container
end

local function handle_events(list)
  local is_used = {}
  for name_mod, _ in pairs( list ) do
    if list[name_mod].version then
      debug("Checking '" .. name_mod .. "' version='" .. list[name_mod].version .. "'")
    else
      debug("Checking '" .. name_mod .. "' version='unknown'")
    end
    if type(list[name_mod]) == 'table' and type(list[name_mod].events) == 'table' then
      for name_event, _ in pairs( list[name_mod].events ) do
        local target_event_id = defines.events[name_event]
        if target_event_id and not is_used[name_event] then
          is_used[name_event] = true
          if script.get_event_handler(target_event_id) == nil then
            local container = create_container(list, name_event)
            script.on_event(target_event_id, function(event)
              for _, _event in pairs( container ) do
                _event(event)
              end
            end)
          else
            if list[name_mod].version then
              debug("For '" .. name_mod .. "' version='" .. list[name_mod].version .. "' can't handle event '" .. name_event .. "'")
            else
              debug("For '" .. name_mod .. "' version='unknown' can't handle event '" .. name_event .. "'")
            end
          end
        end
      end
    end
  end

  is_used = {}
  for _, name_event in pairs( {'on_init', 'on_configuration_changed', 'on_load'} ) do
    local add_func = script[name_event]
    if add_func then
      for name_mod, _ in pairs( list ) do
        if type(list[name_mod]) == 'table' and type(list[name_mod].events) == 'table' then
          for name, _ in pairs( list[name_mod].events ) do
            if not is_used[name_event] and name == name_event then
              is_used[name_event] = true
              local container = create_container(list, name_event)
              add_func(function()
                for _, _event in pairs( container ) do
                  _event()
                end
              end)
            end
          end
        else
          if list[name_mod].version then
            debug("For '" .. name_mod .. "' version='" .. list[name_mod].version .. "' can't handle event '" .. name_event .. "'")
          else
            debug("For '" .. name_mod .. "' version='unknown' can't handle event '" .. name_event .. "'")
          end
        end
      end
    else
      debug("Event '" .. name_event .. "' can't be handle!!!")
    end
  end
end

-- Handle all possible events from list for the game
mod.add_events = function(list)
  debug('Event listener ' .. mod.version .. ' adding events. Working inside ' .. script.mod_name)

  if type(list) == 'table' then
    handle_events(list)
  else
    debug('Type of list is not table!')
  end

  if game then
    debug('Event listener ' .. mod.version .. ' finished adding of events during the game. Game tick = ' .. game.tick)
  else
    debug('Event listener ' .. mod.version .. ' finished adding of events before during the game')
  end
end

return mod
