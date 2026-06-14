local icons = require("icons")
local colors = require("colors")

local popup_toggle = "sketchybar --set $NAME popup.drawing=toggle"

local apple_logo = sbar.add("item", {
	padding_right = 15,
	-- click_script = popup_toggle,
	icon = {
		string = icons.apple,
		font = {
			style = "Black",
			size = 16.0,
		},
	},
	label = {
		drawing = false,
	},
	popup = {
		height = 35,
	},
})

local apple_prefs = sbar.add("item", {
	position = "popup." .. apple_logo.name,
	icon = icons.preferences,
	label = "Preferences",
})

apple_logo:subscribe("mouse.clicked", function(env)
	local menu_helper = os.getenv("HOME") .. "/.config/sketchybar/helpers/menus/bin/menus"

	-- Pass the specific Control Center alias string
	os.execute(menu_helper .. " -s 0")
end)
