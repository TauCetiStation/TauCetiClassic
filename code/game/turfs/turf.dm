/turf
	icon = 'icons/turf/floors.dmi'
	level = 1.0
	var/basetype = /turf/space
	//for floors, use is_plating(), is_plasteel_floor() and is_light_floor()
	var/intact = 1

	//Properties for open tiles (/floor)
	var/oxygen = 0
	var/carbon_dioxide = 0
	var/nitrogen = 0
	var/phoron = 0

	//Properties for airtight tiles (/wall)
	var/thermal_conductivity = 0.05
	var/heat_capacity = 1

	//Properties for both
	var/temperature = T20C

	var/blocks_air = 0
	var/icon_old = null
	var/pathweight = 1

	//Mining resource generation stuff.
	var/has_resources
	var/list/resources

/turf/atom_init()
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	for(var/atom/movable/AM in src)
		Entered(AM)

	if(light_power && light_range)
		update_light()

	if(opacity)
		has_opaque_atom = TRUE

	return INITIALIZE_HINT_NORMAL

/turf/Destroy()
	..()
	return QDEL_HINT_HARDDEL_NOW

/turf/attack_hand(mob/user)
	user.Move_Pulled(src)
	user.SetNextMove(CLICK_CD_INTERACT)

/turf/attack_animal(mob/user)
	return

/turf/attack_robot(mob/user)
	if(Adjacent(user))
		return attack_hand(user)

/turf/ex_act(severity)
	return 0

/turf/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam/pulse))
		src.ex_act(2)
	else if(istype(Proj ,/obj/item/projectile/bullet/gyro))
		explosion(src, -1, 0, 2)
	..()
	return 0

/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
	if(movement_disabled && usr.ckey != movement_disabled_exception)
		to_chat(usr, "\red Movement is admin-disabled.")//This is to identify lag problems
		return
	if (!mover || !isturf(mover.loc))
		return 1


	//First, check objects to block exit that are not on the border
	for(var/obj/obstacle in mover.loc)
		if(!(obstacle.flags & ON_BORDER) && (mover != obstacle) && (forget != obstacle))
			if(!obstacle.CheckExit(mover, src))
				mover.Bump(obstacle, 1)
				return 0

	//Now, check objects to block exit that are on the border
	for(var/obj/border_obstacle in mover.loc)
		if((border_obstacle.flags & ON_BORDER) && (mover != border_obstacle) && (forget != border_obstacle))
			if(!border_obstacle.CheckExit(mover, src))
				mover.Bump(border_obstacle, 1)
				return 0

	//Next, check objects to block entry that are on the border
	for(var/obj/border_obstacle in src)
		if(border_obstacle.flags & ON_BORDER)
			if(!border_obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != border_obstacle))
				mover.Bump(border_obstacle, 1)
				return 0

	//Then, check the turf itself
	if (!src.CanPass(mover, src))
		mover.Bump(src, 1)
		return 0

	//Finally, check objects/mobs to block entry that are not on the border
	for(var/atom/movable/obstacle in src)
		if(!(obstacle.flags & ON_BORDER))
			if(!obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != obstacle))
				mover.Bump(obstacle, 1)
				return 0
	return 1 //Nothing found to block so return success!


/turf/Entered(atom/movable/AM)
	if(!istype(AM, /atom/movable))
		return

	var/loopsanity = 100
	if(ismob(AM))
		var/mob/M = AM
		if(!M.lastarea)
			M.lastarea = get_area(M.loc)

	..()

	// If an opaque movable atom moves around we need to potentially update visibility.
	if(AM.opacity)
		has_opaque_atom = TRUE // Make sure to do this before reconsider_lights(), incase we're on instant updates. Guaranteed to be on in this case.
		reconsider_lights()

	var/objects = 0
	for(var/atom/O as mob|obj|turf|area in range(1))
		if(objects > loopsanity)	break
		objects++
		spawn( 0 )
			if ((O && AM))
				O.HasProximity(AM, 1)
			return
	return

/turf/proc/adjacent_fire_act(turf/simulated/floor/source, temperature, volume)
	return

/turf/proc/is_plating()
	return 0
/turf/proc/is_asteroid_floor()
	return 0
/turf/proc/is_plasteel_floor()
	return 0
/turf/proc/is_light_floor()
	return 0
/turf/proc/is_grass_floor()
	return 0
/turf/proc/is_wood_floor()
	return 0
/turf/proc/is_carpet_floor()
	return 0
/turf/proc/is_catwalk()
	return 0
/turf/proc/return_siding_icon_state()		//used for grass floors, which have siding.
	return 0

/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(src.intact)

// override for space turfs, since they should never hide anything
/turf/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(0)

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L)
		qdel(L)

//Creates a new turf
/turf/proc/ChangeTurf(path, force_lighting_update, list/arguments = list())
	if (!path)
		return
	/*if(istype(src, path))
		stack_trace("Warning: [src]([type]) changeTurf called for same turf!")
		return*/

	// Back all this data up, so we can set it after the turf replace.
	// If you're wondering how this proc'll keep running since the turf should be "deleted":
	// BYOND never deletes turfs, when you "delete" a turf, it actually morphs the turf into a new one.
	// Running procs do NOT get stopped due to this.
	var/old_opacity = opacity
	var/old_dynamic_lighting = dynamic_lighting
	var/list/old_affecting_lights = affecting_lights
	var/old_lighting_overlay = lighting_overlay // Not even a need to cast this, honestly.
	var/list/old_lighting_corners = corners

	var/old_basetype = basetype
	var/old_flooded = flooded
	var/obj/effect/fluid/F = locate() in src

	var/list/temp_res = resources

	//world << "Replacing [src.type] with [N]"

	if(connections)
		connections.erase_all()

	if(istype(src, /turf/simulated))
		//Yeah, we're just going to rebuild the whole thing.
		//Despite this being called a bunch during explosions,
		//the zone will only really do heavy lifting once.
		var/turf/simulated/S = src
		if(S.zone)
			S.zone.rebuild()

	arguments.Insert(0, src)
	var/turf/W = new path(arglist(arguments))

	W.has_resources = has_resources
	W.resources = temp_res

	if(ispath(path, /turf/simulated/floor))
		if (istype(W, /turf/simulated/floor))
			W.RemoveLattice()

	if(SSair)
		SSair.mark_for_update(W)

	W.levelupdate()

	if(SSlighting.initialized)
		lighting_overlay = old_lighting_overlay
		affecting_lights = old_affecting_lights
		corners = old_lighting_corners
		basetype = old_basetype

		for(var/atom/A in contents)
			if(A.light)
				A.light.force_update = 1

		for(var/i = 1 to 4)//Generate more light corners when needed. If removed - pitch black shuttles will come for your soul!
			if(corners[i]) // Already have a corner on this direction.
				continue
			corners[i] = new/datum/lighting_corner(src, LIGHTING_CORNER_DIAGONAL[i])

		if((old_opacity != opacity) || (dynamic_lighting != old_dynamic_lighting) || force_lighting_update)
			reconsider_lights()
		if(dynamic_lighting != old_dynamic_lighting)
			if(dynamic_lighting)
				lighting_build_overlay()
			else
				lighting_clear_overlay()

		for(var/turf/space/S in RANGE_TURFS(1, src))
			S.update_starlight()

	if(F)
		F.forceMove(src)
		F.start_loc = src
		fluid_update()

	if(old_flooded)
		flooded = 1
		update_icon()

	return W

/turf/proc/MoveTurf(turf/target, move_unmovable = 0)
	if(type != basetype || move_unmovable)
		. = target.ChangeTurf(src.type)
		ChangeTurf(basetype)
	else
		return target

/turf/proc/BreakToBase()
	ChangeTurf(basetype)

//Commented out by SkyMarshal 5/10/13 - If you are patching up space, it should be vacuum.
//  If you are replacing a wall, you have increased the volume of the room without increasing the amount of gas in it.
//  As such, this will no longer be used.

//////Assimilate Air//////
/*
/turf/simulated/proc/Assimilate_Air()
	var/aoxy = 0//Holders to assimilate air from nearby turfs
	var/anitro = 0
	var/aco = 0
	var/atox = 0
	var/atemp = 0
	var/turf_count = 0

	for(var/direction in cardinal)//Only use cardinals to cut down on lag
		var/turf/T = get_step(src,direction)
		if(istype(T,/turf/space))//Counted as no air
			turf_count++//Considered a valid turf for air calcs
			continue
		else if(istype(T,/turf/simulated/floor))
			var/turf/simulated/S = T
			if(S.air)//Add the air's contents to the holders
				aoxy += S.air.oxygen
				anitro += S.air.nitrogen
				aco += S.air.carbon_dioxide
				atox += S.air.toxins
				atemp += S.air.temperature
			turf_count ++
	air.oxygen = (aoxy/max(turf_count,1))//Averages contents of the turfs, ignoring walls and the like
	air.nitrogen = (anitro/max(turf_count,1))
	air.carbon_dioxide = (aco/max(turf_count,1))
	air.toxins = (atox/max(turf_count,1))
	air.temperature = (atemp/max(turf_count,1))//Trace gases can get bant
	air.update_values()

	//cael - duplicate the averaged values across adjacent turfs to enforce a seamless atmos change
	for(var/direction in cardinal)//Only use cardinals to cut down on lag
		var/turf/T = get_step(src,direction)
		if(istype(T,/turf/space))//Counted as no air
			continue
		else if(istype(T,/turf/simulated/floor))
			var/turf/simulated/S = T
			if(S.air)//Add the air's contents to the holders
				S.air.oxygen = air.oxygen
				S.air.nitrogen = air.nitrogen
				S.air.carbon_dioxide = air.carbon_dioxide
				S.air.toxins = air.toxins
				S.air.temperature = air.temperature
				S.air.update_values()
*/


/turf/proc/ReplaceWithLattice()
	src.ChangeTurf(basetype)
	spawn()
		new /obj/structure/lattice( locate(src.x, src.y, src.z) )

/turf/proc/kill_creatures(mob/U = null)//Will kill people/creatures and damage mechs./N
//Useful to batch-add creatures to the list.
	for(var/mob/living/M in src)
		if(M==U)	continue//Will not harm U. Since null != M, can be excluded to kill everyone.
		spawn(0)
			M.gib()
	for(var/obj/mecha/M in src)//Mecha are not gibbed but are damaged.
		spawn(0)
			M.take_damage(100, "brute")

/turf/proc/Bless()
	flags |= NOJAUNT


////////////////
//Distance procs
////////////////

/**
 * Distance associates with all directions movement
 */
/turf/proc/Distance(var/turf/T)
	return get_dist(src,T)

/**
 * This Distance proc assumes that only cardinal movement is possible.
 * It results in more efficient (CPU-wise) pathing
 * for bots and anything else that only moves in cardinal dirs.
 */
/turf/proc/Distance_cardinal(turf/T)
	if(!src || !T) return 0
	return abs(src.x - T.x) + abs(src.y - T.y)

////////////////

/turf/singularity_act()
	if(intact)
		for(var/obj/O in contents) //this is for deleting things like wires contained in the turf
			if(O.level != 1)
				continue
			if(O.invisibility == 101)
				O.singularity_act()
	ChangeTurf(/turf/space)
	return(2)

/turf/hitby(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/L = AM
		L.turf_collision(src)

/turf/proc/update_icon()
	if(is_flooded(absolute = 1))
		if(!(locate(/obj/effect/flood) in contents))
			new /obj/effect/flood(src)
	else
		if(locate(/obj/effect/flood) in contents)
			for(var/obj/effect/flood/F in contents)
				qdel(F)
