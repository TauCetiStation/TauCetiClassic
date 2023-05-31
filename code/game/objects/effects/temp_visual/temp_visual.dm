//temporary visual effects
/obj/effect/temp_visual
	icon_state = "nothing"
	icon = 'icons/effects/effects.dmi'
	anchored = TRUE
	layer = INFRONT_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/duration = 10 //in deciseconds
	var/randomdir = TRUE
	var/timerid

/obj/effect/temp_visual/atom_init()
	. = ..()
	if(randomdir)
		set_dir(pick(global.cardinal))

	timerid = QDEL_IN(src, duration)

/obj/effect/temp_visual/Destroy()
	. = ..()
	deltimer(timerid)

/obj/effect/temp_visual/singularity_act()
	return

/obj/effect/temp_visual/singularity_pull()
	return

/obj/effect/temp_visual/ex_act()
	return

/obj/effect/temp_visual/dir_setting
	randomdir = FALSE

/obj/effect/temp_visual/dir_setting/atom_init(mapload, set_dir)
	if(set_dir)
		set_dir(set_dir)
	. = ..()

/obj/effect/temp_visual/dir_setting/ninja
	name = "ninja shadow"
	icon = 'icons/mob/mob.dmi'
	icon_state = "uncloak"
	duration = 9
