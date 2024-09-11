/**
 * Shuttle window
 */

/obj/structure/window/shuttle
	name = "shuttle window"
	cases = list("окно шаттла", "окна шаттла", "окну шаттлу", "окно шаттла", "окном шаттла", "окне шаттла")
	desc = "Оно выглядит довольно прочным. Потребуется несколько сильных ударов, чтобы разбить его."
	icon = 'icons/obj/podwindows.dmi'
	icon_state = "window"

	max_integrity = 150

	var/damage_threshold = 30

/obj/structure/window/shuttle/run_atom_armor(damage_amount, damage_type, damage_flag, attack_dir)
	if(damage_threshold)
		switch(damage_type)
			if(BRUTE)
				return max(0, damage_amount - damage_threshold)
			if(BURN)
				return damage_amount * 0.3
	return ..()

/obj/structure/window/shuttle/bullet_act(obj/item/projectile/Proj, def_zone)
	if(Proj.checkpass(PASSGLASS))
		return PROJECTILE_FORCE_MISS

	return ..()

/**
 * Shuttle reinforced(?)
 */

/obj/structure/window/shuttle/reinforced
	icon = 'icons/locations/shuttles/shuttle.dmi'
	dir = SOUTHWEST
	flags = NODECONSTRUCT | ON_BORDER

/obj/structure/window/shuttle/reinforced/mining
	name = "shuttle window"
	icon = 'icons/locations/shuttles/shuttle_mining.dmi'
	dir = SOUTHWEST
	icon_state = "1"

/obj/structure/window/shuttle/reinforced/evac
	name = "shuttle window"
	icon = 'icons/locations/shuttles/evac_shuttle.dmi'
	dir = SOUTHWEST

/obj/structure/window/shuttle/reinforced/default
	name = "shuttle window"
	icon = 'icons/obj/podwindows.dmi'
	icon_state = "window"
	dir = SOUTHWEST

/obj/structure/window/shuttle/reinforced/vox
	name = "shuttle window"
	icon = 'icons/locations/shuttles/vox_shuttle_inner.dmi'
	icon_state = "7,10"
	dir = SOUTHWEST
