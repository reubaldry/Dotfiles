local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- 1. THE SPACES
local function mouse_click(env)
	if env.BUTTON == "right" then
		sbar.exec("yabai -m space --destroy " .. env.SID)
	else
		sbar.exec("yabai -m space --focus " .. env.SID)
	end
end

local function space_selection(env)
	local color = env.SELECTED == "true" and colors.white or colors.bg2

	sbar.set(env.NAME, {
		icon = { highlight = env.SELECTED },
		label = { highlight = env.SELECTED },
		background = { border_color = color },
	})
end

local spaces = {}
for i = 1, 10, 1 do
	local space = sbar.add("space", "space." .. i, {
		associated_space = i,
		icon = {
			string = i,
			padding_left = 10,
			padding_right = 10,
			color = colors.white,
			highlight_color = colors.red,
		},
		padding_left = 2,
		padding_right = 2,
		label = {
			padding_right = 20,
			color = colors.grey,
			highlight_color = colors.white,
			font = "sketchybar-app-font:Regular:16.0",
			y_offset = -1,
			drawing = false,
		},
	})

	spaces[i] = space.name
	space:subscribe("space_change", space_selection)
	space:subscribe("mouse.clicked", mouse_click)
end

-- 2. THE BRACKET
sbar.add("bracket", "space.bracket", spaces, {
	background = { color = colors.bg1, border_color = colors.bg2 },
})

-- 3. THE SPACE CREATOR
local space_creator = sbar.add("item", "space.creator", {
	padding_left = 10,
	padding_right = 8,
	icon = {
		string = "􀆊",
		font = {
			style = "Heavy",
			size = 16.0,
		},
	},
	label = { drawing = false },
	associated_display = "active",
})

space_creator:subscribe("mouse.clicked", function(_)
	sbar.exec("yabai -m space --create")
end)

-- 4. THE TOGGLE BUTTON (Moved to the right)
local apple_logo = sbar.add("item", "apple_logo", {
	position = "left",
	icon = {
		string = icons.switch.on,
		font = { size = 18.0 },
	},
	label = { drawing = false },
	padding_left = 10,
	padding_right = 10,
})

apple_logo:subscribe("mouse.clicked", function()
	sbar.trigger("swap_menus_and_spaces")
end)

local function hide_scratchpad()
	-- Asynchronously query Yabai for the scratchpad index
	sbar.exec("yabai -m query --spaces | jq -r '.[] | select(.label == \"scratchpad\") | .index'", function(result)
		-- Safely extract the number from the jq output
		local index = result:match("%d+")

		if index then
			-- Force the corresponding SketchyBar space item to hide
			sbar.set("space." .. index, { drawing = false })
		end
	end)
end

-- Run it immediately on boot
hide_scratchpad()

-- Hook it into the space_creator's global space_change event.
-- If macOS shifts space indices (e.g., you create or delete a normal space),
-- this ensures the phantom space is instantly re-hidden.
space_creator:subscribe("space_change", function(_)
	hide_scratchpad()
end)
