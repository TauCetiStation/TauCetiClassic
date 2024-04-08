/obj/structure/storage_box/rocket
	name = "Rockets Crate"
	desc = "A heavy box storing rockets."
	var/spawn_type = /obj/item/rocket
	var/number = 9

/obj/structure/storage_box/rocket/atom_init(mapload)
	for(var/i in 1 to number)
		new spawn_type(src)

	return ..()

/obj/structure/storage_box/rocket/cheap
	name = "Cheap Explosive Rockets Crate"
	desc = "A heavy box storing rockets."
	spawn_type = /obj/item/rocket/cheap

/obj/structure/storage_box/rocket/explosive
	name = "Explosive Rockets Crate"
	desc = "A heavy box storing rockets."
	spawn_type = /obj/item/rocket/explosive

/obj/structure/storage_box/rocket/emp
	name = "EMP Rockets Crate"
	desc = "A heavy box storing rockets."
	spawn_type = /obj/item/rocket/emp

/obj/structure/storage_box/rocket/piercing
	name = "Armor-piercing Rockets Crate"
	desc = "A heavy box storing rockets."
	spawn_type = /obj/item/rocket/piercing

// todo: we need merge mechanics for simultaneous explosions on the same turf
// here i do it manyally because this box can contain only rockets
/obj/structure/storage_box/rocket/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
		if(EXPLODE_LIGHT)
			if(prob(95))
				return

	var/new_explosion_severity

	for(var/obj/item/rocket/R as anything in contents)
		new_explosion_severity += 0.5
		R.exploded = TRUE
		qdel(R)

	var/turf/T = get_turf(src)

	qdel(src) // mark as destroying first so explosions don't go into recursion

	if(new_explosion_severity)
		new_explosion_severity = clamp(new_explosion_severity, 1, 3)
		explosion(T, new_explosion_severity, new_explosion_severity*2, new_explosion_severity*3)
