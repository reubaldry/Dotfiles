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
	-- sbar.exec runs safely in the background
	sbar.exec(
		[[osascript -e 'tell application "System Events" to tell process "ControlCenter" to click menu bar item 4 of menu bar 1']]
	)
end)
