data:extend({
	{
		type = "bool-setting",
		name = "diplomacy_visible_all_teams",
		setting_type = "runtime-global",
		default_value = false
	},
	{
		type = "bool-setting",
		name = "diplomacy_entity_not_on_map",
		setting_type = "startup",
		default_value = false
	},
	{
		type = "bool-setting",
		name = "diplomacy_allow_mine_entity",
		setting_type = "runtime-global",
		default_value = false
	},
	{
		type = "bool-setting",
		name = "diplomacy_on_entity_damaged_state",
		setting_type = "runtime-global",
		default_value = true
	},
	{
		type = "bool-setting",
		name = "disable_diplomacy_on_entity_died",
		setting_type = "runtime-global",
		default_value = false
	},
	{
		type = "bool-setting",
		name = "diplomacy_hp_rocket_silo_switcher",
		setting_type = "startup",
		default_value = true
	},
	{
		type = "int-setting",
		name = "diplomacy_hp_rocket_silo",
		setting_type = "startup",
		default_value = 50000,
		minimum_value = 1,
		maximum_value = 10000000000,
	},
	{
		type = "bool-setting",
		name = "diplomacy_tech_tanks_count_switcher",
		setting_type = "startup",
		default_value = true
	},
	{
		type = "int-setting",
		name = "diplomacy_tech_tanks_count",
		setting_type = "startup",
		default_value = 1000,
		minimum_value = 1,
		maximum_value = 10000000000,
	},
	{
		type = "bool-setting",
		name = "diplomacy_tech_power_armor_2_count_switcher",
		setting_type = "startup",
		default_value = true
	},
	{
		type = "int-setting",
		name = "diplomacy_tech_power_armor_2_count",
		setting_type = "startup",
		default_value = 1000,
		minimum_value = 1,
		maximum_value = 10000000000,
	},
	{
		type = "bool-setting",
		name = "diplomacy_tech_uranium_ammo_count_switcher",
		setting_type = "startup",
		default_value = true
	},
	{
		type = "int-setting",
		name = "diplomacy_tech_uranium_ammo_count",
		setting_type = "startup",
		default_value = 1800,
		minimum_value = 1,
		maximum_value = 10000000000,
	},
	{
		type = "int-setting",
		name = "diplomacy_HP_forbidden_entity_on_killed",
		setting_type = "runtime-global",
		default_value = 300,
		minimum_value = 1,
		maximum_value = 100000000000,
	},
	{
		type = "int-setting",
		name = "diplomacy_HP_forbidden_entity_on_mined",
		setting_type = "runtime-global",
		default_value = 300,
		minimum_value = 0,
		maximum_value = 100000000000,
	},
	{
		type = "int-setting",
		name = "diplomacy_HP_forbidden_entity_on_damaged",
		setting_type = "runtime-global",
		default_value = 300,
		minimum_value = 1,
		maximum_value = 100000000000,
	},
	{
		type = "string-setting",
		name = "who_decides_diplomacy",
		setting_type = "runtime-global",
		default_value = "all_players",
		allowed_values = {"all_players", "team_leader"}
	},
})
