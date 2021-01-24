/obj/structure/cult/statue
	name = "statue"
	icon_state = "shell" // can be shell_glow

/obj/structure/cult/statue/Destroy()
	playsound(src, 'sound/effects/ghost2.ogg', VOL_EFFECTS_MASTER)

	var/datum/effect/effect/system/smoke_spread/chem/S = new
	create_reagents(10)
	reagents.add_reagent("blood", 10)
	S.set_up(reagents, 20, 0, get_turf(src))
	S.attach(get_turf(src))
	S.color = "#5f0344"
	S.start()

	return ..()

/obj/structure/cult/statue/capture
	name = "statue of gargoyle"
	icon_state = "gargoyle_glow"

	health = 100
	var/obj/effect/rune/capture_rune

/obj/structure/cult/statue/capture/atom_init(mapload, obj/effect/rune/R)
	. = ..()
	capture_rune = R

/obj/structure/cult/statue/capture/Destroy()
	if(!QDELETED(capture_rune))
		qdel(capture_rune)
	return ..()

/obj/structure/cult/statue/jew
	name = "statue of jew"
	icon_state = "jew" // cant be jew_glow

/obj/structure/cult/statue/gargoyle
	name = "statue of gargoyle"
	icon_state = "gargoyle" // can be gargoyle_glow
