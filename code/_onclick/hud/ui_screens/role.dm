// changeling
/atom/movable/screen/current_sting
	icon = 'icons/hud/screen_gen.dmi'
	name = "current sting"
	screen_loc = ui_lingstingdisplay
	plane = ABOVE_HUD_PLANE
	invisibility = INVISIBILITY_ABSTRACT

	copy_flags = NONE

/atom/movable/screen/current_sting/action()
	if(iscarbon(usr))
		var/mob/living/carbon/U = usr
		U.unset_sting()

/atom/movable/screen/chemical_display
	name = "chemical storage"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "power_display"
	screen_loc = ui_lingchemdisplay
	plane = ABOVE_HUD_PLANE

	copy_flags = NONE

// families
/atom/movable/screen/wanted
	name = "NanoTrasen Alertness"
	desc = "Shows the current level of hostility NanoTrasen is planning to rain down on you. Better be careful."
	icon = 'icons/obj/gang/wanted_160x32.dmi'
	icon_state = "wanted_0"
	screen_loc = ui_wanted_lvl

	copy_flags = NONE
	/// Wanted level, affects the hud icon. Level 0 is default, and the level 0 icon is blank, so in case of no families gamemode (and thus no wanted level), this HUD element will never appear.
	var/wanted_level = 0
	/// Boolean, have the cops arrived? If so, the icon stops changing and remains the same.
	var/cops_arrived = 0
	var/base_icon_state = "wanted"

/atom/movable/screen/wanted/MouseEntered(location,control,params)
	. = ..()
	openToolTip(usr, src, params, title = name, content = desc, theme = "alerttooltipstyle")

/atom/movable/screen/wanted/MouseExited()
	closeToolTip(usr)

/atom/movable/screen/wanted/proc/update_icon_state()
	icon_state = "[base_icon_state]_[wanted_level][cops_arrived ? "_active" : null]"
