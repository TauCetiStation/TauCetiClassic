// little wrapper to get path from obj/random item, so we can use and work with final type in code
/proc/random2path(path, prob_nothing = FALSE)
	if(!ispath(path, /obj/random))
		CRASH("Expected /obj/random path, got [path]")

	while(ispath(path, /obj/random))
		var/obj/random/R = new path(null, TRUE)

		if(prob_nothing && prob(R.spawn_nothing_chance))
			return

		path = R.item_to_spawn()
		qdel(R)

	return path

/obj/random
	name = "Random Object"
	desc = "This item type is used to spawn random objects at round-start."
	icon = 'icons/misc/mark.dmi'
	icon_state = "rup"
	flags = ABSTRACT
	var/spawn_nothing_chance = 0 // this variable determines the likelyhood that this random object will not spawn anything

// creates a new object and deletes itself
/obj/random/atom_init(mapload, no_spawn = FALSE)
	. = ..()
	if(no_spawn)
		return
	if (!prob(spawn_nothing_chance))
		var/new_path = item_to_spawn()
		if(!new_path)
			CRASH("Random item [type] was unable to spawn new item via item_to_spawn(), should be impossible")
		new new_path(loc)

	return INITIALIZE_HINT_QDEL

// this function should return a specific item to spawn
/obj/random/proc/item_to_spawn()
	return 0
