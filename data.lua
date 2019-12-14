data:extend(
{
	{
		type = "item-subgroup",
		name = "virtual-signal-diplomacy",
		group = "signals",
		order = "d"
	}
})

for _, name in pairs({"enemy", "neutral", "ally", "diplomacy"}) do
	data:extend(
	{
		{
			type = "virtual-signal",
			name = name,
			icon = "__diplomacy__/graphics/" .. name .. ".png",
			icon_size = 32,
			subgroup = "virtual-signal-diplomacy",
			order = "a[diplomacy]-[" .. name .. "]",
			localised_name = name
		}
	})
end
