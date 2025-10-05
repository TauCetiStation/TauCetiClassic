// Nebula-dev\code\game\atoms.dm

/atom
	/// (FLOAT) world.time of last on_reagent_update call, used to prevent recursion due to reagents updating reagents
	VAR_PRIVATE/_reagent_update_started = 0

/// Handle reagents being modified
/atom/proc/try_on_reagent_change()
	SHOULD_NOT_OVERRIDE(TRUE)
	set waitfor = FALSE
	if(QDELETED(src) || _reagent_update_started >= world.time)
		return FALSE
	_reagent_update_started = world.time
	sleep(0) // Defer to end of tick so we don't drop subsequent reagent updates.
	if(QDELETED(src))
		return
	return on_reagent_change()

/atom/proc/is_watertight()
	return !is_open_container()


// Nebula-dev\code\game\objects\items\__item.dm

/obj/item/is_watertight()
	return watertight || ..()

/obj/item
	/// Can this object leak into water sources?
	var/watertight = FALSE

// Nebula-dev\code\modules\reagents\reagent_containers\drinks.dm
/obj/item/weapon/reagent_containers/food/drinks
	watertight = FALSE // /drinks uses the open container flag for this

// Nebula-dev\code\modules\reagents\reagent_containers\_glass.dm
/obj/item/weapon/reagent_containers/glass
	watertight = FALSE // /glass uses the open container flag for this

// Nebula-dev\code\modules\reagents\reagent_containers.dm
/obj/item/weapon/reagent_containers
	watertight = TRUE
