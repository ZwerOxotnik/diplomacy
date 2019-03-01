local color_map = {}

color_map.get = function()
	return {
		orange = {r = 0.869, g = 0.5  , b = 0.130, a = 0.5},
		purple = {r = 0.485, g = 0.111, b = 0.659, a = 0.5},
		red    = {r = 0.815, g = 0.024, b = 0.0,   a = 0.5},
		green  = {r = 0.093, g = 0.768, b = 0.172, a = 0.5},
		blue   = {r = 0.155, g = 0.540, b = 0.898, a = 0.5},
		yellow = {r = 0.835, g = 0.666, b = 0.077, a = 0.5},
		pink   = {r = 0.929, g = 0.386, b = 0.514, a = 0.5},
		white  = {r = 0.8  , g = 0.8  , b = 0.8,   a = 0.5},
		black  = {r = 0.1  , g = 0.1  , b = 0.1,   a = 0.5},
		gray   = {r = 0.4  , g = 0.4  , b = 0.4,   a = 0.5},
		brown  = {r = 0.300, g = 0.117, b = 0.0,   a = 0.5},
		cyan   = {r = 0.275, g = 0.755, b = 0.712, a = 0.5},
		acid   = {r = 0.559, g = 0.761, b = 0.157, a = 0.5}
	}
end

return color_map
