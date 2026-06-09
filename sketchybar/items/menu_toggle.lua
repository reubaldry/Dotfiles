local apple = sbar.add("item", "menu_toggle", {
	position = "left",
	icon = { string = "", font = { size = 18.0 } },
	label = { drawing = false },
	padding_left = 10,
	padding_right = 10,
})

-- Broadcast the swap event when clicked
apple:subscribe("mouse.clicked", function()
	sbar.trigger("swap_menus_and_spaces")
end)
