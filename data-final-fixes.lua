local function check_not_on_map(flags)
	for _, flag in pairs(flags) do
		if flag == "not-on-map" then
			return false
		end
	end

	return true
end

if settings.startup["diplomacy_entity_not_on_map"].value then
	for _, prototypes in pairs(data.raw) do
		for _, prototype in pairs(prototypes) do
			if prototype.max_health then
				if check_not_on_map(prototype.flags) then
					table.insert(prototype.flags, "not-on-map")
				end
			end
		end
	end
end

if settings.startup["diplomacy_tech_tanks_count_switcher"].value then
	if data.raw["technology"]["tanks"] then
		data.raw["technology"]["tanks"].unit.count = settings.startup["diplomacy_tech_tanks_count"].value
	end
end

if settings.startup["diplomacy_tech_power_armor_2_count_switcher"].value then
	if data.raw["technology"]["power-armor-2"] then
		data.raw["technology"]["power-armor-2"].unit.count = settings.startup["diplomacy_tech_power_armor_2_count"].value
	end
end

if settings.startup["diplomacy_tech_uranium_ammo_count_switcher"].value then
	if data.raw["technology"]["uranium-ammo"] then
		data.raw["technology"]["uranium-ammo"].unit.count = settings.startup["diplomacy_tech_uranium_ammo_count"].value
	end
end

if settings.startup["diplomacy_hp_rocket_silo_switcher"].value then
	if data.raw["rocket-silo"]["rocket-silo"] then
		data.raw["rocket-silo"]["rocket-silo"].max_health = settings.startup["diplomacy_hp_rocket_silo"].value
	end
end
