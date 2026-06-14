local icons = require("icons")

local bonky = sbar.add("item", {
	position = "right",
	icon = {
		font = {
			style = "Regular",
			size = 19.00,
		},
		string = "♡",
	},
})

bonky:subscribe("mouse.clicked", function(_)
	sbar.exec('osascript -e \'tell application "Shortcuts Events" to run the shortcut named "SketchyBonky"\'')
	os.execute("open ~/.config/sketchybar/attachments/bonky.JPG")
end)
