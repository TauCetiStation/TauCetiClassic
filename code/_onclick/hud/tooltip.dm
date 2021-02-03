/client
	var/obj/screen/tooltip/tooltip

/obj/screen/tooltip
	icon = 'icons/misc/tooltip.dmi'
	icon_state = "transparent"
	screen_loc = TOOLTIP_NORTH
	plane = HUD_PLANE
	layer = ABOVE_HUD_LAYER
	maptext_width = 999
	maptext_x = -385
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/state = TRUE
	var/size = 5
	var/maptext_style = "font-size: 10pt;"

/obj/screen/tooltip/proc/SetMapText(newValue, font, forcedFontColor = "#ffffff")
	var/style = "font-family:'[font]';color:[forcedFontColor];text-shadow: 0 2px 2px [invertHTML(forcedFontColor)];[maptext_style];"
	maptext = "<center><span style=\"[style]\">[newValue]</span></center>"

/obj/screen/tooltip/proc/set_state(_state)
	state = _state
	invisibility = state ? initial(invisibility) : INVISIBILITY_ABSTRACT

/client/New(TopicData)
	. = ..()
	tooltip = new /obj/screen/tooltip()
	if(prefs.tooltip)
		tooltip.set_state(TRUE)

/client/MouseEntered(atom/hoverOn, location, control, params)
	if(!prefs.tooltip)
		return

	if(tooltip?.state)
		var/text_in_tooltip = hoverOn.get_name()
		screen |= tooltip
		tooltip.SetMapText(text_in_tooltip, prefs.tooltip_font, color)
