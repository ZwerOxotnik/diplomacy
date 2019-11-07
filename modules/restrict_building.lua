--[[
Copyright 2018-2019 ZwerOxotnik <zweroxotnik@gmail.com>

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

local module = {}
module.events = {}

local function find_near_enemy(created_entity)
    local created_entity_force = created_entity.force
    local x, y = created_entity.position.x, created_entity.position.y
    local r = settings.global["diplomacy_restrict_building_radius"].value
    local near_entities = created_entity.surface.find_entities({{x - r, y - r}, {x + r, y + r}})

    for _, entity in pairs(near_entities) do
        local entity_force = entity.force
        if (entity and entity_force ~= created_entity_force
            and entity_force.name ~= "neutral"
            and not created_entity_force.get_cease_fire(entity_force)) then
            return true
        end
    end
    return false
end

-- TODO: return the entity to player
local function restrict_building_on_built_entity(event)
    local created_entity = event.created_entity
    if not (created_entity and created_entity.valid) then return end
    if created_entity.force.name == "neutral" then return end

    if not find_near_enemy(created_entity) then return end
    rendering.draw_text{
        text = {"diplomacy.messages.warning_restricted_building"},
        surface = created_entity.surface,
        target = created_entity.position,
        forces = {created_entity.force},
        visible = true,
        time_to_live = 60 * 3,
        color = {r = 1, g = 0, b = 0, a = 0.5}
    }
    created_entity.destroy()
end

local function on_runtime_mod_setting_changed(event)
    if event.setting == "diplomacy_restrict_building_radius" then return end

    local events = module.events
    if settings.global[event.setting].value ~= 0 then
        events[defines.events.on_built_entity] = restrict_building_on_built_entity
        events[defines.events.on_robot_built_entity] = restrict_building_on_built_entity
    else
        events[defines.events.on_built_entity] = function() end
        events[defines.events.on_robot_built_entity] = function() end
    end

    module_listener.update_event("on_built_entity")
    module_listener.update_event("on_robot_built_entity")
end

if settings.global["diplomacy_restrict_building_radius"].value == 0 then
	module.events[defines.events.on_built_entity] = function() end
	module.events[defines.events.on_robot_built_entity] = function() end
else
	module.events[defines.events.on_built_entity] = restrict_building_on_built_entity
    module.events[defines.events.on_robot_built_entity] = restrict_building_on_built_entity
end
module.events.on_runtime_mod_setting_changed = on_runtime_mod_setting_changed

return module