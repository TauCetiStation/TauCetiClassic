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

/obj/effect/spawner/aspect/mech
	name = "mech spawner"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x"
	aspect = ROUND_ASPECT_MECHAS

/obj/effect/spawner/aspect/mech/gygax
	name = "security gygax spawner"
	icon_state = "gygax"
	spawn_type = /obj/mecha/combat/gygax/security

/obj/effect/spawner/aspect/mech/gygax/ultra
	name = "security gygax ultra spawner"
	icon_state = "ultra"
	spawn_type = /obj/mecha/combat/gygax/ultra/security

/obj/effect/spawner/aspect/mech/dark_gygax
	name = "dark gygax spawner"
	icon_state = "black_gygax"
	spawn_type =/obj/mecha/combat/gygax/dark

/obj/effect/spawner/aspect/mech/medical
	name = "medical mech spawner"
	icon_state = "medical"
	spawn_type = /obj/mecha/medical/odysseus/medical

/obj/effect/spawner/aspect/mech/ripley_engi
	name = "engineer's ripley spawner"
	icon_state = "ripley"
	spawn_type = /obj/mecha/working/ripley/engi

/obj/effect/spawner/aspect/mech/ff_engi
	name = "engineer's firefighter spawner"
	icon_state = "ff"
	spawn_type = /obj/mecha/working/ripley/firefighter/engi

/obj/effect/spawner/aspect/mech/ripley_mine
	name = "miner's ripley spawner"
	icon_state = "ripley"
	spawn_type = /obj/mecha/working/ripley/mine

/obj/effect/spawner/aspect/mech/honker
	name = "honker spawner" //OH SHI...
	icon_state = "honker"
	spawn_type = /obj/mecha/combat/honker/clown

/obj/effect/spawner/aspect/mech/phazon
	name = "phazon spawner"
	icon_state = "phazon"
	spawn_type = /obj/mecha/combat/phazon/captain
