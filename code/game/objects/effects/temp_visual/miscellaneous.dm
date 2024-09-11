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

/obj/effect/temp_visual/heart
	name = "heart"
	icon = 'icons/mob/animal.dmi'
	icon_state = "heart"
	duration = 25

/obj/effect/temp_visual/heart/atom_init()
	. = ..()
	pixel_x = rand(-4,4)
	pixel_y = rand(-4,4)
	animate(src, pixel_y = pixel_y + 32, alpha = 0, time = 25)
