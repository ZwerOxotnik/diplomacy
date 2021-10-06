data:extend({{type = "item-subgroup", name = "virtual-signal-diplomacy", group = "signals", order = "d"}})

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
		}, {
			type = "sprite",
			name = "diplomacy_black",
			filename = "__diplomacy__/graphics/diplomacy_black.png",
			width = 32, height = 32,
			flags = {"gui-icon"}
		}
	})
end
