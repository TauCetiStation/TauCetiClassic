/obj/effect/temp_visual/dust_animation
	icon = 'icons/mob/mob.dmi'
	duration = 15

/obj/effect/temp_visual/dust_animation/atom_init(mapload, dust_icon)
	icon_state = dust_icon // Before ..() so the correct icon is flick()'d
	. = ..()

/obj/effect/temp_visual/pulse
	icon_state = "emppulse"
	duration = 10

/obj/effect/temp_visual/sparkles
	icon_state = "shieldsparkles"
	duration = 8

/obj/effect/constructing_effect
	icon = 'icons/effects/effects_rcd.dmi'
	icon_state = ""
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/status = 0
	var/delay = 0

/obj/effect/constructing_effect/atom_init(mapload, rcd_delay, rcd_status)
	. = ..()
	status = rcd_status
	delay = rcd_delay
	if(status == 5)
		delay -= 11
		icon_state = "rcd_reverse_end"

/obj/effect/constructing_effect/proc/update_icon_state()
	icon_state = "rcd"
	if(status == 5)
		icon_state += "_reverse"
	if(delay < 10)
		icon_state += "_shortest"
		return ..()
	if (delay < 20)
		icon_state += "_shorter"
		return ..()
	if (delay < 37)
		icon_state += "_short"
		return ..()
	return ..()

/obj/effect/constructing_effect/proc/end_animation()
	if (status == 5)
		qdel(src)
	else
		icon_state = "rcd_end"
		addtimer(CALLBACK(src, .proc/end), 15)

/obj/effect/constructing_effect/proc/end()
	qdel(src)
