/obj/effect/spawner/aspect
	var/spawn_type
	var/aspect
	icon = 'icons/effects/landmarks_static.dmi'

/obj/effect/spawner/aspect/atom_init()
	. = ..()
	if(HAS_ROUND_ASPECT(aspect))
		new spawn_type(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/aspect/newai
	name = "ai core spawner"
	icon_state = "x"
	spawn_type = /obj/structure/AIcore/deactivated
	aspect = ROUND_ASPECT_AI_TRIO

