-- Define the helper path to your newly compiled C binary
local menu_helper = os.getenv("HOME") .. "/.config/sketchybar/helpers/menus/bin/menus"

-- Register the event FIRST so spaces.lua doesn't crash when it looks for it
sbar.add("event", "swap_menus_and_spaces")

local menu_watcher = sbar.add("item", {
	drawing = false,
	updates = false,
})

local space_menu_swap = sbar.add("item", {
	drawing = false,
	updates = true,
})

-- Re-add your padding so it aligns properly with the spaces indicator
local menu_padding = sbar.add("item", "menu.padding", {
	position = "left",
	drawing = false,
	width = 5,
})

local max_items = 15
local menu_items = {}

for i = 1, max_items, 1 do
	local menu = sbar.add("item", "menu." .. i, {
		position = "left",
		drawing = false,
		icon = { drawing = false },
		label = {
			font = {
				family = "Hack Nerd Font",
				style = (i == 1) and "Heavy" or "Semibold",
				size = 14.0,
			},
			padding_left = 6,
			padding_right = 6,
		},
		click_script = menu_helper .. " -s " .. i,
	})
	menu_items[i] = menu
end

local function update_menus(env)
	sbar.exec(menu_helper .. " -l", function(menus)
		sbar.set("/menu\\..*/", { drawing = false })
		menu_padding:set({ drawing = true })

		local id = 1
		for menu in string.gmatch(menus, "[^\r\n]+") do
			if id < max_items then
				menu_items[id]:set({ label = menu, drawing = true })
			else
				break
			end
			id = id + 1
		end
	end)
end

menu_watcher:subscribe("front_app_switched", update_menus)

-- The Swap Logic
space_menu_swap:subscribe("swap_menus_and_spaces", function(env)
	local is_drawing = menu_items[1]:query().geometry.drawing == "on"

	if is_drawing then
		-- Hide Menus, Show Spaces
		menu_watcher:set({ updates = false })
		sbar.set("/menu\\..*/", { drawing = false })
		menu_padding:set({ drawing = false })
		sbar.set("/space\\..*/", { drawing = true })
		sbar.set("front_app", { drawing = true })
	else
		-- Hide Spaces, Show Menus
		menu_watcher:set({ updates = true })
		sbar.set("/space\\..*/", { drawing = false })
		sbar.set("front_app", { drawing = false })
		update_menus()
	end
end)
