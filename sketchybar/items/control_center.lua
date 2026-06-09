local control_center = sbar.add("item", {
	position = "right",
	icon = {
		string = "􀜊",
		font = { size = 16.0 },
	},
	label = { drawing = false },
	padding_right = 10,
	padding_left = 10,
})

control_center:subscribe("mouse.clicked", function(env)
	-- Point to your compiled C binary
	local menu_helper = os.getenv("HOME") .. "/.config/sketchybar/helpers/menus/bin/menus"

	-- Pass the specific Control Center alias string
	os.execute(menu_helper .. ' -s "Control Center,BentoBox-0" > /dev/null 2>&1 &')
end)
