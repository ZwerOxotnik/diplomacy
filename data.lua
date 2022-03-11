local deepcopy = util.table.deepcopy


data:extend({
	{type = "item-subgroup", name = "virtual-signal-diplomacy", group = "signals", order = "d"},
	{
		type = "sprite",
		name = "diplomacy_black",
		filename = "__diplomacy__/graphics/diplomacy_black.png",
		width = 32, height = 32,
		flags = {"gui-icon"}
	}
})


for _, name in pairs({"enemy", "neutral", "ally", "diplomacy"}) do
	data:extend({
		{
			type = "virtual-signal",
			name = name,
			localised_name = name,
			icon = "__diplomacy__/graphics/" .. name .. ".png",
			icon_size = 32,
			subgroup = "virtual-signal-diplomacy",
			order = "a[diplomacy]-[" .. name .. "]"
		}
	})
end


local styles = data.raw["gui-style"].default
local slot_button = styles.slot_button

styles.ZD_diplomacy_button = {
  type = "button_style",
	parent = "slot_button",
	tooltip = "mod-name.diplomacy",
	default_graphical_set = deepcopy(slot_button.default_graphical_set),
	hovered_graphical_set = deepcopy(slot_button.hovered_graphical_set),
	clicked_graphical_set = deepcopy(slot_button.clicked_graphical_set)
}
local ZD_diplomacy_button = styles.ZD_diplomacy_button
ZD_diplomacy_button.default_graphical_set.glow = {
	top_outer_border_shift = 4,
	bottom_outer_border_shift = -4,
	left_outer_border_shift = 4,
	right_outer_border_shift = -4,
	draw_type = "outer",
	filename = "__diplomacy__/graphics/diplomacy.png",
	flags = {"gui-icon"},
	size = 32,
	scale = 1
}
ZD_diplomacy_button.hovered_graphical_set.glow.center = {
	filename = "__diplomacy__/graphics/diplomacy_black.png",
	flags = {"gui-icon"},
	size = 32,
	scale = 1
}
ZD_diplomacy_button.clicked_graphical_set.glow = {
	top_outer_border_shift = 2,
	bottom_outer_border_shift = -2,
	left_outer_border_shift = 2,
	right_outer_border_shift = -2,
	draw_type = "outer",
	filename = "__diplomacy__/graphics/diplomacy_black.png",
	flags = {"gui-icon"},
	size = 32,
	scale = 1
}
