local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local wifi_up = sbar.add("item", "widgets.wifi1", {
	position = "right",
	padding_left = 0,
	width = 0,
	icon = {
		padding_right = 0,
		font = {
			style = settings.font.style_map["Bold"],
			size = 10.0,
		},
		string = icons.wifi.upload,
	},
	label = {
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 10.0,
		},
		color = colors.red,
		string = "??? Bps",
	},
	y_offset = 5,
})

local wifi_down = sbar.add("item", "widgets.wifi2", {
	position = "right",
	padding_left = 0,
	icon = {
		padding_right = 0,
		font = {
			style = settings.font.style_map["Bold"],
			size = 10.0,
		},
		string = icons.wifi.download,
	},
	label = {
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 10.0,
		},
		color = colors.green,
		string = "??? Bps",
	},
	y_offset = -5,
})

local wifi = sbar.add("item", {
	position = "right",
	label = {
		drawing = false,
	},
	padding_left = 0,
	padding_right = 5,
})

wifi:subscribe({ "wifi_change", "system_woke" }, function(_)
	sbar.exec("ipconfig getifaddr en0", function(ip)
		local connected = not (ip == "")
		wifi:set({
			icon = {
				string = connected and icons.wifi.connected or icons.wifi.disconnected,
				color = connected and colors.white or colors.red,
			},
		})
	end)
end)

wifi:subscribe({ "mouse.clicked" }, function(_)
	local menu_helper = os.getenv("HOME") .. "/.config/sketchybar/helpers/menus/bin/menus"

	-- Pass the specific Control Center alias string
	os.execute(menu_helper .. ' -s "Control Center,WiFi" > /dev/null 2>&1 &')
end)

wifi_up:subscribe("network_update", function(env)
	local up_color = (env.upload == "000 Bps") and colors.white or colors.red
	local down_color = (env.download == "000 Bps") and colors.white or colors.green
	wifi_up:set({
		icon = { color = up_color },
		label = {
			string = env.upload,
			color = up_color,
		},
	})
	wifi_down:set({
		icon = { color = down_color },
		label = {
			string = env.download,
			color = down_color,
		},
	})
end)
