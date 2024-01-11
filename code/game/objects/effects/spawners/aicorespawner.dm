/obj/effect/spawner/newai //only for trioai aspect
	name = "ai core spawner"
	icon = 'icons/hud/screen1.dmi'
	icon_state = "x"

/obj/effect/spawner/newai/atom_init()
	. = ..()
	if(HAS_ROUND_ASPECT(ROUND_ASPECT_AI_TRIO))
		new /obj/structure/AIcore/deactivated (loc)
	return INITIALIZE_HINT_QDEL
