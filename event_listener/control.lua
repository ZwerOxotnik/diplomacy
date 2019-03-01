--[[
Event listener
Copyright (c) 2019 ZwerOxotnik <zweroxotnik@gmail.com>
License: The MIT License (MIT)
Author: ZwerOxotnik
Version: 0.3.0 (2019-02-28)
Source: https://gitlab.com/ZwerOxotnik/event-listener
Mod portal: https://mods.factorio.com/mod/event-listener
Homepage: https://forums.factorio.com/viewtopic.php?f=190&t=64621
Description: The script combine events of other scripts.
             Designed for mod developers.
]]--

local module = {}
local SCRIPT_EVENTS_FOR_CHECKING = {
	on_init = true,
	on_configuration_changed = true,
	on_load = true
}
local registered_modules
local standart_events
local script_events
-- TODO: custom events in 0.4.0
module.version = "0.3.0"

local function debug(message)
	log(message)
	if game then
		game.write_file("event_listener", message, true)
	end
end

-- Check and get events from modules for handling
local function handle_events(modules)
	standart_events = {}
	script_events = {}
	-- Find events from modules
	for name_mod, data in pairs( modules ) do
		if data.version then
			debug("Checking events of '" .. name_mod .. "' version='" .. data.version .. "'")
		else
			debug("Checking events of '" .. name_mod .. "' version='unknown'")
		end
		for event_name, func in pairs( data.events ) do
			if type(func) == "function"  then
				debug("Adding of event '" .. event_name .. "'")
				if defines.events[event_name] then
					if standart_events[event_name] == nil then standart_events[event_name] = {} end
					table.insert(standart_events[event_name], func)
				elseif SCRIPT_EVENTS_FOR_CHECKING[event_name] then -- something is not done
					if script_events[event_name] == nil then script_events[event_name] = {} end
					table.insert(script_events[event_name], func)
				else
					debug("Can't to identify event '" .. event_name .. "'")
				end
			end
		end
	end

	-- Attach events of standart_events
	for event_name, _ in pairs( standart_events ) do
		if script.get_event_handler(defines.events[event_name]) == nil then
      debug("Handled event '" .. event_name .. "'")
			script.on_event(defines.events[event_name], function(event)
				for _, _event in pairs( standart_events[event_name] ) do
					_event(event)
				end
			end)
		end
	end

	-- Attach events of script_events
	for event_name, _ in pairs( script_events ) do
    debug("Handled event '" .. event_name .. "'")
		script[event_name](function(event)
			for _, _event in pairs( script_events[event_name] ) do
				_event(event)
			end
		end)
	end
end

-- Handle all possible events from modules for the game
module.add_events = function(modules)
	debug('Event listener ' .. module.version .. ' adding events, working inside ' .. script.mod_name)

	if type(modules) == 'table' then
		registered_modules = modules
		handle_events(modules)
	else
		debug('Type of modules is not table!')
	end

	if game then
		debug('Event listener ' .. module.version .. ' finished adding of events during the game. Game tick = ' .. game.tick)
	else
		debug('Event listener ' .. module.version .. ' finished adding of events before during the game')
	end
end

local function update_standart_event(event_name)
	standart_events[event_name] = {}
	for name_mod, data in pairs( registered_modules ) do
		if data.version then
			debug("Updating events of '" .. name_mod .. "' version='" .. data.version .. "'")
		else
			debug("Updating events of '" .. name_mod .. "' version='unknown'")
		end
    if data.events[event_name] and type(data.events[event_name]) == "function" then
			if standart_events[event_name] == nil then standart_events[event_name] = {} end
			table.insert(standart_events[event_name], data.events[event_name])
		end
	end

  if script.get_event_handler(defines.events[event_name]) == nil then
    debug("Handled event '" .. event_name .. "'")
		script.on_event(defines.events[event_name], function(event)
			for _, _event in pairs( standart_events[event_name] ) do
				_event(event)
			end
		end)
	end
end

-- Not tested!
local function update_script_event(event_name)
	script_events[event_name] = {}
	for name_mod, data in pairs( registered_modules ) do
		if data.version then
			debug("Updating events of '" .. name_mod .. "' version='" .. data.version .. "'")
		else
			debug("Updating events of '" .. name_mod .. "' version='unknown'")
		end
		if data.events[event_name] and type(data.events[event_name]) == "function" then
			if script_events[event_name] == nil then script_events[event_name] = {} end
			table.insert(script_events[event_name], data.events[event_name])
		end
	end

  -- debug("Handled event '" .. event_name .. "'")
  -- script[event_name](function(e)
	-- 	for _, _event in pairs( script_events[event_name] ) do
	-- 		_event(e)
	-- 	end
	-- end)
end

module.update_event = function(event)
  debug("Event listener " .. module.version .. " updating event '" .. event .. "'")
	if type(event) == "string" then
    if defines.events[event] then
			update_standart_event(event)
		elseif SCRIPT_EVENTS_FOR_CHECKING[event] then
      update_script_event(event)
		end
	--elseif type(event) == "number" then
	end
end

module.update_events = function()
	if type(registered_modules) == 'table' then
		handle_events(registered_modules)
	else
		debug("Type of registered_modules is not table! Type of registered_modules='" .. type(registered_modules) .. "'")
	end

	if game then
		debug('Event listener ' .. module.version .. ' finished updating of events during the game. Game tick = ' .. game.tick)
	else
		debug('Event listener ' .. module.version .. ' finished updating of events before during the game')
	end
end

return module
