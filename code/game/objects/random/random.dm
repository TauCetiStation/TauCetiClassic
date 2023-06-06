// little wrapper to get path from obj/random item ~~without creating dummy object~~ (not true atm), so we can use and work with random items in code
/proc/random2path(path)
	if(!ispath(path, /obj/random))
		CRASH("Expected /obj/random path, got [path]")

	// todo:
	// text2path can't compile subtype proc for us, so we still need to make a dummy object. Maybe 515 nameof() can help here
	/*
	var/obj/random/R = path

	if(prob(initial(R.spawn_nothing_percentage)))
		return

	return call(text2path("[path].proc/item_to_spawn"))()
	*/

	while(ispath(path, /obj/random))
		var/obj/random/R = new path(null, TRUE)

		if(prob(initial(R.spawn_nothing_percentage)))
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
	var/spawn_nothing_percentage = 0 // this variable determines the likelyhood that this random object will not spawn anything

// creates a new object and deletes itself
/obj/random/atom_init(mapload, no_init = FALSE)
	if(no_init)
		return
	..()
	if (!prob(spawn_nothing_percentage))
		spawn_item()
	return INITIALIZE_HINT_QDEL

// this function should return a specific item to spawn
/obj/random/proc/item_to_spawn()
	return 0

// creates the random item
/obj/random/proc/spawn_item()
	var/build_path = item_to_spawn()
	return build_path ? (new build_path(loc)) : null

/obj/randomcatcher
	name = "Random Catcher Object"
	desc = "You should not see this."
	icon = 'icons/misc/mark.dmi'
	icon_state = "rup"
	flags = ABSTRACT

/obj/randomcatcher/proc/get_item(type)
	new type(src)
	if(length(contents))
		return pick(contents)
