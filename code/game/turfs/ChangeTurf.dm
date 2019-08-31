// This is a list of turf types we dont want to assign to baseturfs unless through initialization or explicitly
var/list/blacklisted_automated_baseturfs = typecacheof(list(
	/turf/space,
	/turf/baseturf_bottom,
	))

/turf/proc/empty(turf_type=/turf/space, baseturf_type, list/ignore_typecache, flags)
	// Remove all atoms except observers, landmarks, docking ports
	var/static/list/ignored_atoms = typecacheof(list(/mob/dead, /obj/effect/landmark, /atom/movable/lighting_object))
	var/list/allowed_contents = typecache_filter_list_reverse(GetAllContentsIgnoring(ignore_typecache), ignored_atoms)
	allowed_contents -= src
	for(var/i in 1 to allowed_contents.len)
		var/thing = allowed_contents[i]
		qdel(thing, force=TRUE)

	if(turf_type)
		ChangeTurf(turf_type, baseturf_type, flags)

/turf/proc/copyTurf(turf/T)
	if(T.type != type)
		var/obj/O
		if(underlays.len)	//we have underlays, which implies some sort of transparency, so we want to a snapshot of the previous turf as an underlay
			O = new()
			O.underlays.Add(T)
		T = T.ChangeTurf(type)
		if(!T)
			return T
		if(underlays.len)
			T.underlays = O.underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(color)
		T.color = color
	if(T.dir != dir)
		T.dir = dir
	return T

//wrapper for ChangeTurf()s that you want to prevent/affect without overriding ChangeTurf() itself
/turf/proc/TerraformTurf(path, new_baseturf, flags)
	return ChangeTurf(path, new_baseturf, flags)

// Creates a new turf
// new_baseturfs can be either a single type or list of types, formated the same as baseturfs. see turf.dm
/turf/proc/ChangeTurf(path, list/new_baseturfs, flags, list/arguments = list())
	switch(path)
		if(null)
			return
		if(/turf/baseturf_bottom)
			path = SSmapping.level_trait(z, ZTRAIT_BASETURF) || /turf/space
			if (!ispath(path))
				path = text2path(path)
				if (!ispath(path))
					warning("Z-level [z] has invalid baseturf '[SSmapping.level_trait(z, ZTRAIT_BASETURF)]'")
					path = /turf/space

	if(!use_preloader && path == type && !(flags & CHANGETURF_FORCEOP)) // Don't no-op if the map loader requires it to be reconstructed
		return src
	if(flags & CHANGETURF_SKIP)
		return new path(src)

	// Back all this data up, so we can set it after the turf replace.
	// If you're wondering how this proc'll keep running since the turf should be "deleted":
	// BYOND never deletes turfs, when you "delete" a turf, it actually morphs the turf into a new one.
	// Running procs do NOT get stopped due to this.
	var/old_opacity = opacity
	var/old_dynamic_lighting = dynamic_lighting
	var/old_affecting_lights = affecting_lights
	var/old_lighting_object = lighting_object
	var/old_corners = corners

	var/list/old_baseturfs = baseturfs
	var/old_flooded = flooded
	var/obj/effect/fluid/F = locate() in src

	var/list/temp_res = resources

	if(connections)
		connections.erase_all()

	if(istype(src, /turf/simulated))
		//Yeah, we're just going to rebuild the whole thing.
		//Despite this being called a bunch during explosions,
		//the zone will only really do heavy lifting once.
		var/turf/simulated/S = src
		if(S.zone)
			S.zone.rebuild()

	//BEGIN: ECS SHIT (UNTIL SOMEONE MAKES POSSIBLE TO USE QDEL IN THIS PROC FOR TURFS)
	signal_enabled = FALSE

	var/list/dc = datum_components
	if(dc)
		var/all_components = dc[/datum/component]
		if(length(all_components))
			for(var/I in all_components)
				var/datum/component/C = I
				qdel(C, FALSE, TRUE)
		else
			var/datum/component/C = all_components
			qdel(C, FALSE, TRUE)
		dc.Cut()

	var/list/lookup = comp_lookup
	if(lookup)
		for(var/sig in lookup)
			var/list/comps = lookup[sig]
			if(length(comps))
				for(var/i in comps)
					var/datum/component/comp = i
					comp.UnregisterSignal(src, sig)
			else
				var/datum/component/comp = comps
				comp.UnregisterSignal(src, sig)
		comp_lookup = lookup = null

	for(var/target in signal_procs)
		UnregisterSignal(target, signal_procs[target])
	//END: ECS SHIT

	qdel(src)	//Just get the side effects and call Destroy
	arguments.Insert(1, src)
	var/turf/W = new path(arglist(arguments))

	W.has_resources = has_resources
	W.resources = temp_res

	if(new_baseturfs)
		W.baseturfs = new_baseturfs
	else
		W.baseturfs = old_baseturfs

	if(ispath(path, /turf/simulated/floor))
		if (istype(W, /turf/simulated/floor))
			W.RemoveLattice()

	if(SSair)
		SSair.mark_for_update(W)

	if(!(flags & CHANGETURF_DEFER_CHANGE))
		W.AfterChange(flags)

	if(SSlighting.initialized)
		recalc_atom_opacity()
		lighting_object = old_lighting_object
		affecting_lights = old_affecting_lights
		corners = old_corners
		if (old_opacity != opacity || dynamic_lighting != old_dynamic_lighting)
			reconsider_lights()

		if (dynamic_lighting != old_dynamic_lighting)
			if (IS_DYNAMIC_LIGHTING(src))
				lighting_build_overlay()
			else
				lighting_clear_overlay()

		for(var/turf/space/S in RANGE_TURFS(1, src)) //RANGE_TURFS is in code\__HELPERS\game.dm
			S.update_starlight()

	if(F)
		F.forceMove(src)
		F.start_loc = src
		fluid_update()

	if(old_flooded)
		flooded = 1
		update_icon()

	return W

// Take off the top layer turf and replace it with the next baseturf down
/turf/proc/ScrapeAway(amount=1, flags)
	if(!amount)
		return
	if(length(baseturfs))
		var/list/new_baseturfs = baseturfs.Copy()
		var/turf_type = new_baseturfs[max(1, new_baseturfs.len - amount + 1)]
		while(ispath(turf_type, /turf/baseturf_skipover))
			amount++
			if(amount > new_baseturfs.len)
				CRASH("The bottomost baseturf of a turf is a skipover [src]([type])")
			turf_type = new_baseturfs[max(1, new_baseturfs.len - amount + 1)]
		new_baseturfs.len -= min(amount, new_baseturfs.len - 1) // No removing the very bottom
		if(new_baseturfs.len == 1)
			new_baseturfs = new_baseturfs[1]
		return ChangeTurf(turf_type, new_baseturfs, flags)

	if(baseturfs == type)
		return src

	return ChangeTurf(baseturfs, baseturfs, flags) // The bottom baseturf will never go away

// Take the input as baseturfs and put it underneath the current baseturfs
// If fake_turf_type is provided and new_baseturfs is not the baseturfs list will be created identical to the turf type's
// If both or just new_baseturfs is provided they will be inserted below the existing baseturfs
/turf/proc/PlaceOnBottom(list/new_baseturfs, turf/fake_turf_type)
	if(fake_turf_type)
		if(!new_baseturfs)
			if(!length(baseturfs))
				baseturfs = list(baseturfs)
			var/list/old_baseturfs = baseturfs.Copy()
			assemble_baseturfs(fake_turf_type)
			if(!length(baseturfs))
				baseturfs = list(baseturfs)
			baseturfs -= baseturfs & blacklisted_automated_baseturfs
			baseturfs += old_baseturfs
			return
		else if(!length(new_baseturfs))
			new_baseturfs = list(new_baseturfs, fake_turf_type)
		else
			new_baseturfs += fake_turf_type
	if(!length(baseturfs))
		baseturfs = list(baseturfs)
	baseturfs.Insert(1, new_baseturfs)

// Make a new turf and put it on top
// The args behave identical to PlaceOnBottom except they go on top
// Things placed on top of closed turfs will ignore the topmost closed turf
// Returns the new turf
/turf/proc/PlaceOnTop(list/new_baseturfs, turf/fake_turf_type, flags)
	var/area/turf_area = loc
	if(new_baseturfs && !length(new_baseturfs))
		new_baseturfs = list(new_baseturfs)
	flags = turf_area.PlaceOnTopReact(new_baseturfs, fake_turf_type, flags) // A hook so areas can modify the incoming args

	var/turf/newT
	if(flags & CHANGETURF_SKIP) // We haven't been initialized
		if(initialized)
			stack_trace("CHANGETURF_SKIP was used in a PlaceOnTop call for a turf that's initialized. This is a mistake. [src]([type])")
		assemble_baseturfs()
	if(fake_turf_type)
		if(!new_baseturfs) // If no baseturfs list then we want to create one from the turf type
			if(!length(baseturfs))
				baseturfs = list(baseturfs)
			var/list/old_baseturfs = baseturfs.Copy()
			if(!istype(src, /turf/simulated/wall) && !istype(src, /turf/unsimulated/wall)) // !istype(src, /turf/closed)
				old_baseturfs += type
			newT = ChangeTurf(fake_turf_type, null, flags)
			newT.assemble_baseturfs(initial(fake_turf_type.baseturfs)) // The baseturfs list is created like roundstart
			if(!length(newT.baseturfs))
				newT.baseturfs = list(baseturfs)
			newT.baseturfs -= blacklisted_automated_baseturfs
			newT.baseturfs.Insert(1, old_baseturfs) // The old baseturfs are put underneath
			return newT
		if(!length(baseturfs))
			baseturfs = list(baseturfs)
		if(!istype(src, /turf/simulated/wall) && !istype(src, /turf/unsimulated/wall))
			baseturfs += type
		baseturfs += new_baseturfs
		return ChangeTurf(fake_turf_type, null, flags)
	if(!length(baseturfs))
		baseturfs = list(baseturfs)
	if(!istype(src, /turf/simulated/wall) && !istype(src, /turf/unsimulated/wall))
		baseturfs += type
	var/turf/change_type
	if(length(new_baseturfs))
		change_type = new_baseturfs[new_baseturfs.len]
		new_baseturfs.len--
		if(new_baseturfs.len)
			baseturfs += new_baseturfs
	else
		change_type = new_baseturfs
	return ChangeTurf(change_type, null, flags)

// Copy an existing turf and put it on top
// Returns the new turf
/turf/proc/CopyOnTop(turf/copytarget, ignore_bottom=1, depth=INFINITY)
	var/list/new_baseturfs = list()
	new_baseturfs += baseturfs
	new_baseturfs += type

	if(depth)
		var/list/target_baseturfs
		if(length(copytarget.baseturfs))
			// with default inputs this would be Copy(CLAMP(2, -INFINITY, baseturfs.len))
			// Don't forget a lower index is lower in the baseturfs stack, the bottom is baseturfs[1]
			target_baseturfs = copytarget.baseturfs.Copy(CLAMP(1 + ignore_bottom, 1 + copytarget.baseturfs.len - depth, copytarget.baseturfs.len))
		else if(!ignore_bottom)
			target_baseturfs = list(copytarget.baseturfs)
		if(target_baseturfs)
			target_baseturfs -= new_baseturfs & blacklisted_automated_baseturfs
			new_baseturfs += target_baseturfs

	var/turf/newT = copytarget.copyTurf(src)
	newT.baseturfs = new_baseturfs
	return newT

//If you modify this function, ensure it works correctly with lateloaded map templates.
/turf/proc/AfterChange(flags) //called after a turf has been replaced in ChangeTurf()
	levelupdate()

	queue_smooth_neighbors(src)

/turf/proc/ReplaceWithLattice()
	ScrapeAway()
	new /obj/structure/lattice(locate(x, y, z))