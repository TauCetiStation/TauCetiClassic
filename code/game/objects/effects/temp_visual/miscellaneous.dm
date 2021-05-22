/obj/effect/temp_visual/dust_animation
	icon = 'icons/mob/mob.dmi'
	duration = 15

/obj/effect/temp_visual/dust_animation/atom_init(mapload, dust_icon)
	icon_state = dust_icon // Before ..() so the correct icon is flick()'d
	. = ..()
