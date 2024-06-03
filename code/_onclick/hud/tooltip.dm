/client
	var/atom/movable/screen/tooltip/tooltip

/atom/movable/screen/tooltip
	icon = 'icons/misc/tooltip.dmi'
	icon_state = "transparent"
	screen_loc = TOOLTIP_NORTH
	plane = ABOVE_HUD_PLANE
	maptext_width = 999
	maptext_x = -385
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/looking_at
	var/state = TRUE

/atom/movable/screen/tooltip/proc/SetMapText(newValue, font, font_size, forcedFontColor = "#ffffff")
	var/style = "font-family:'[font]'; color:[forcedFontColor]; -dm-text-outline: 1px [invertHTMLcolor(forcedFontColor)]; font-weight: bold; font-size: [font_size]px;"
	maptext = "<center><span style=\"[style]\">[uppertext(newValue)]</span></center>"

/atom/movable/screen/tooltip/proc/set_state(_state)
	state = _state
	invisibility = state ? initial(invisibility) : INVISIBILITY_ABSTRACT

/client/New(TopicData)
	. = ..()
	tooltip = new /atom/movable/screen/tooltip()
	if(prefs.get_pref(/datum/pref/player/ui/tooltip))
		tooltip.set_state(TRUE)

/client/MouseEntered(atom/hoverOn, location, control, params)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	tooltip.looking_at = "\ref[hoverOn]"
	if(prefs.get_pref(/datum/pref/player/ui/tooltip) && tooltip?.state)
		var/text_in_tooltip = hoverOn.get_name()
		screen |= tooltip
		tooltip.SetMapText(text_in_tooltip, prefs.get_pref(/datum/pref/player/ui/tooltip_font), prefs.get_pref(/datum/pref/player/ui/tooltip_size))
