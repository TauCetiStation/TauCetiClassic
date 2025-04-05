/mob/autosay //copied camera mob
	name = "autosay mob"
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	see_in_dark = 7
	invisibility = 101 // No one can see us

/mob/autosay/say_quote(text)
	return "says, \"[text]\""
