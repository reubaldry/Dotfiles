local icons = require("icons")

-- State variable to track what we are displaying
local show_time_remaining = false

local battery = sbar.add("item", {
	position = "right",
	icon = {
		font = {
			style = "Regular",
			size = 19.0,
		},
	},
	-- Removed `drawing = false` so the percentage/time text is visible
	update_freq = 120,
})

local function battery_update()
	sbar.exec("pmset -g batt", function(batt_info)
		local icon = "!"
		local is_charging = string.find(batt_info, "AC Power") ~= nil

		-- Extract percentage
		local found, _, charge = batt_info:find("(%d+)%%")
		if found then
			charge = tonumber(charge)
		end

		-- Extract time remaining
		local time_remaining = batt_info:match("(%d+:%d+)")

		-- 1. Set the Icon (Keeping your exact logic)
		if is_charging then
			icon = icons.battery.charging
		else
			if found and charge > 80 then
				icon = icons.battery._100
			elseif found and charge > 60 then
				icon = icons.battery._75
			elseif found and charge > 40 then
				icon = icons.battery._50
			elseif found and charge > 20 then
				icon = icons.battery._25
			else
				icon = icons.battery._0
			end
		end

		-- 2. Determine what the text label should say
		local label_str = ""
		if show_time_remaining then
			if time_remaining then
				label_str = is_charging and (time_remaining .. " to full") or (time_remaining .. " left")
			else
				label_str = is_charging and "Charging" or "Calculating..."
			end
		else
			label_str = (charge and charge .. "%") or "100%"
		end

		-- 3. Apply updates to the widget
		battery:set({
			icon = icon,
			label = { string = label_str },
		})
	end)
end

-- Subscribe to system events
battery:subscribe({ "routine", "power_source_change", "system_woke" }, battery_update)

-- Subscribe to the click event to toggle the view
battery:subscribe("mouse.clicked", function(env)
	show_time_remaining = not show_time_remaining
	battery_update() -- Force an immediate update
end)
