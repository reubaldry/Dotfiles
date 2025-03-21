local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local weather = sbar.add("item", "widgets.weather", {
	position = "right",
	icon = {
		font = {
			style = settings.font.style_map["Regular"],
			size = 19.0,
		},
		string = icons.weather,
	},
	label = {
		font = { family = settings.font.numbers },
		string = "??°C", -- Placeholder until data loads
		color = colors.fg,
	},
	update_freq = 600, -- Update every 10 minutes
	popup = { align = "center" },
})

-- 2) Define a popup item for detailed weather info
local weather_detail = sbar.add("item", {
	position = "popup." .. weather.name,
	icon = {
		string = "Weather Details:",
		width = 150,
		align = "left",
	},
	label = {
		-- We'll display multiline data here
		string = "Loading...",
		width = 200,
		align = "left",
	},
})

-- 3) Routine update for the main weather display
weather:subscribe("routine", function()
	-- We’ll fetch a concise weather string, e.g. condition icon + temperature
	-- See https://github.com/chubin/wttr.in#one-line-output
	local cmd = "curl -s 'wttr.in/?format=%c+%t'"
	sbar.exec(cmd, function(weather_info)
		-- Example output might look like: "☀ +20°C"
		local info = weather_info:gsub("\n", ""):gsub("^%s*(.-)%s*$", "%1") -- trim
		if info == "" then
			info = "N/A"
		end

		-- Split out the icon/temperature if you like:
		-- For instance, if info is "☀ +20°C", we can parse the temperature:
		local icon_str, temp_str = info:match("([^%s]+)%s+([^%s]+)")
		icon_str = icon_str or ""
		temp_str = temp_str or "??°C"

		-- Update the item’s icon and label
		weather:set({
			icon = { string = icon_str },
			label = { string = temp_str },
		})
	end)
end)

--local detail_cmd = "curl -s 'wttr.in/?format=j1'"
local function update_weather_detail()
	-- Using wttr.in custom formatting:
	-- %%0A is the URL-encoded newline character.
	local detail_cmd =
		"curl -s 'wttr.in/London?format=Location:%l%0ACondition:%C%0ATemperature:%t%0AFeels%20Like:%f%0AHumidity:%h'"

	sbar.exec(detail_cmd, function(result, exit_code)
		if exit_code ~= 0 or not result or result == "" then
			weather_detail:set({ label = { string = "Error fetching data" } })
			return
		end

		result = result:gsub("%%0A", "\n")

		-- Since the result is a simple multi-line string, no JSON parsing is needed.
		weather_detail:set({ label = { string = result } })
	end)
end

-- 7) On click, toggle popup and fetch the detailed info
weather:subscribe("mouse.clicked", function(env)
	local drawing = weather:query().popup.drawing
	weather:set({ popup = { drawing = "toggle" } })

	if drawing == "off" then
		update_weather_detail()
	end
end)

-- 5) Optional: visually group the widget with a bracket and some padding
sbar.add("bracket", "widgets.weather.bracket", { weather.name }, {
	background = { color = colors.bg1 },
})

sbar.add("item", "widgets.weather.padding", {
	position = "right",
	width = settings.group_paddings,
})

local function update_weather()
	local cmd = "curl -s 'wttr.in/?format=%c+%t'"
	sbar.exec(cmd, function(weather_info)
		local info = weather_info:gsub("\n", ""):gsub("^%s*(.-)%s*$", "%1") -- trim
		if info == "" then
			info = "N/A"
		end

		-- Simple splitting: icon + temperature
		local icon_str, temp_str = info:match("([^%s]+)%s+([^%s]+)")
		icon_str = icon_str or ""
		temp_str = temp_str or "??°C"

		weather:set({
			icon = { string = icon_str },
			label = { string = temp_str },
		})
	end)
end

update_weather()

weather:subscribe("routine", function()
	update_weather()
end)
