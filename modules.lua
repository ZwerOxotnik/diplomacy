local list = {}
list.diplomacy = require("diplomacy/control")
list.custom_events = {
  handle_events = function()
    -- Searching events "on_round_start" and "on_round_end"
    for interface_name, _ in pairs( remote.interfaces ) do
      local function_name = "get_event_name"
      if remote.interfaces[interface_name][function_name] then
        local ID_1 = remote.call(interface_name, function_name, "on_round_start")
        local ID_2 = remote.call(interface_name, function_name, "on_round_end")
        if (type(ID_1) == "number") and (type(ID_2) == "number") then
          if (script.get_event_handler(ID_1) == nil) and (script.get_event_handler(ID_2) == nil) then
            local interface_function = "get_teams"

            -- Attach "on_round_start"
            script.on_event(ID_1, function()
              local diplomacy = global.diplomacy
              if remote.interfaces[interface_name] then
                if remote.interfaces[interface_name][interface_function] then
                  diplomacy.teams = remote.call(interface_name, interface_function)
                  for _, player in pairs(game.players) do
                    list.diplomacy.create_button(player)
                    global.diplomacy.locked_teams = false
                    return
                  end
                end
              end
            end)

            -- Attach "on_round_end"
            script.on_event(ID_2, function()
              local diplomacy = global.diplomacy
              if remote.interfaces[interface_name] then
                if remote.interfaces[interface_name][interface_function] then
                  diplomacy.teams = {}
                  for _, player in pairs(game.players) do
                    list.diplomacy.destroy_gui(player)
                    global.diplomacy.locked_teams = true
                  end
                end
              end
            end)
          end
        end
      end
    end
  end
}
list.custom_events.events = {
  on_load = list.custom_events.handle_events,
  on_init = list.custom_events.handle_events
}

return list
