var/global/list/camera_statues_list = list()
var/global/list/capture_statues_list = list()

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
	icon_state = "gargoyle"

	max_integrity = 81
	can_unwrench = FALSE
	var/obj/effect/rune/capture_rune

/obj/structure/cult/statue/capture/atom_init(mapload, obj/effect/rune/R)
	. = ..()
	capture_rune = R
	capture_statues_list += src

/obj/structure/cult/statue/capture/Destroy()
	if(!QDELETED(capture_rune))
		qdel(capture_rune)
	capture_statues_list -= src
	return ..()

/obj/structure/cult/statue/camera
	name = "statue of sighted"
	icon_state = "shell"

/obj/structure/cult/statue/camera/atom_init()
	. = ..()
	camera_statues_list += src

/obj/structure/cult/statue/camera/Destroy()
	camera_statues_list -= src
	return ..()

/obj/structure/cult/statue/camera/jew
	name = "statue of jew"
	icon_state = "jew"

/obj/structure/cult/statue/camera/gargoyle
	name = "statue of gargoyle"
	icon_state = "gargoyle"
