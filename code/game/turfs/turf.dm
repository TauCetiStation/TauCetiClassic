/turf
	icon = 'icons/turf/floors.dmi'
	level = 1.0
	var/turf/basetype = /turf/environment/space
	//for floors, use is_plating(), is_plasteel_floor() and is_light_floor()
	var/intact = 1
	var/can_deconstruct = FALSE

	//Properties for open tiles (/floor)
	var/airless = FALSE
	var/oxygen = 0
	var/carbon_dioxide = 0
	var/nitrogen = 0
	var/phoron = 0

	//Properties for airtight tiles (/wall)
	var/thermal_conductivity = 0.05
	var/heat_capacity = 0

	//Properties for both
	var/temperature = T20C

	var/blocks_air = 0
	var/icon_old = null
	var/pathweight = 1

	//Mining resource generation stuff.
	var/has_resources
	var/list/resources
	var/slowdown = 0

	//Footsteps
	var/footstep
	var/barefootstep
	var/clawfootstep
	var/heavyfootstep

/**
  * Turf Initialize
  *
  * Doesn't call parent, see [/atom/proc/atom_init]
  */
/turf/atom_init()
	SHOULD_CALL_PARENT(FALSE)
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	if(smooth)
		queue_smooth(src)

	for(var/atom/movable/AM in src)
		Entered(AM)

	if(light_power && light_range)
		update_light()

	if(opacity)
		has_opaque_atom = TRUE

	return INITIALIZE_HINT_NORMAL

/turf/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE // No qdelling turfs until proper method in ChangeTurf() proc as it is in other code bases.
	..()

	vis_locs = null //clears this atom out of all viscontents
	vis_contents.Cut()

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

/turf/bullet_act(obj/item/projectile/Proj, def_zone)
	. = ..()
	if(istype(Proj ,/obj/item/projectile/beam/pulse))
		ex_act(EXPLODE_HEAVY)
	else if(istype(Proj ,/obj/item/projectile/bullet/gyro))
		explosion(src, -1, 0, 2)

/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
	if(movement_disabled && usr.ckey != movement_disabled_exception)
		to_chat(usr, "<span class='warning'>Передвижение отключено администрацией.</span>")//This is to identify lag problems
		return FALSE
	if (!(mover && isturf(mover.loc)))
		return TRUE

	var/list/second_check = list()
	var/turf/mover_loc = mover.loc
	//First, check objects to block exit that are not on the border
	for(var/obj/obstacle in mover_loc)
		if(mover != obstacle && forget != obstacle)
			if(obstacle.flags & ON_BORDER)
				second_check += obstacle
			else if(!obstacle.CheckExit(mover, src))
				mover.Bump(obstacle, TRUE)
				return FALSE

	//Now, check objects to block exit that are on the border
	for(var/obj/border_obstacle as anything in second_check)
		if(!border_obstacle.CheckExit(mover, src))
			mover.Bump(border_obstacle, TRUE)
			return FALSE

	second_check.Cut()
	//Next, check objects to block entry that are on the border
	for(var/atom/movable/border_obstacle as anything in src)
		if(forget != border_obstacle)
			if(border_obstacle.flags & ON_BORDER)
				if(!border_obstacle.CanPass(mover, mover_loc, 1, 0))
					mover.Bump(border_obstacle, TRUE)
					return FALSE
			else
				second_check += border_obstacle

	//Then, check the turf itself
	if (!CanPass(mover, src))
		mover.Bump(src, TRUE)
		return FALSE

	//Finally, check objects/mobs to block entry that are not on the border
	for(var/atom/movable/obstacle as anything in second_check)
		if(!obstacle.CanPass(mover, mover_loc, 1, 0))
			mover.Bump(obstacle, TRUE)
			return FALSE
	return TRUE //Nothing found to block so return success!

/turf/proc/is_mob_placeable(mob/M) // todo: maybe rewrite as COMSIG_ATOM_INTERCEPT_TELEPORT
	if(density)
		return FALSE
	var/static/list/allowed_types = list(/obj/structure/window, /obj/machinery/door,
										 /obj/structure/table,  /obj/structure/grille,
										 /obj/structure/cult,   /obj/structure/mineral_door,
										 /obj/item/tape,        /obj/structure/rack,
										 /obj/structure/closet,)
	for(var/atom/movable/on_turf in contents)
		if(on_turf == M)
			continue
		if(ismob(on_turf) && !on_turf.anchored)
			continue
		if(on_turf.density && !is_type_in_list(on_turf, allowed_types))
			return FALSE
	return TRUE

/turf/Entered(atom/movable/AM)
	if(!istype(AM, /atom/movable))
		return

	if(ismob(AM))
		var/mob/M = AM
		if(!M.lastarea)
			M.lastarea = get_area(M.loc)

	..()

	// If an opaque movable atom moves around we need to potentially update visibility.
	if (AM && AM.opacity)
		recalc_atom_opacity() // Make sure to do this before reconsider_lights(), incase we're on instant updates.
		reconsider_lights()

/turf/Exited(atom/movable/Obj, atom/newloc)
	. = ..()

	if (Obj && Obj.opacity)
		recalc_atom_opacity() // Make sure to do this before reconsider_lights(), incase we're on instant updates.
		reconsider_lights()

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

// override for environment turfs, since they should never hide anything
/turf/environment/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(0)

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L)
		qdel(L)

/turf/proc/empty(turf_type=/turf/environment/space, list/ignore_typecache)
	// Remove all atoms except observers, landmarks, docking ports
	var/static/list/ignored_atoms = typecacheof(list(/mob/dead, /obj/effect/landmark))
	var/list/allowed_contents = typecache_filter_list_reverse(GetAllContentsIgnoring(ignore_typecache), ignored_atoms)
	allowed_contents -= src
	for(var/i in 1 to allowed_contents.len)
		var/thing = allowed_contents[i]
		qdel(thing, force=TRUE)

	if(turf_type)
		ChangeTurf(turf_type)

//Creates a new turf
/turf/proc/ChangeTurf(path, list/arguments = list())
	if (!path)
		return

	/*if(istype(src, path))
		stack_trace("Warning: [src]([type]) changeTurf called for same turf!")
		return*/

	if(ispath(path, /turf/environment))
		var/env_turf_type = SSenvironment.turf_type[z]
		if(!ispath(path, env_turf_type))
			path = env_turf_type

	if (path == type)
		return src

	// Back all this data up, so we can set it after the turf replace.
	// If you're wondering how this proc'll keep running since the turf should be "deleted":
	// BYOND never deletes turfs, when you "delete" a turf, it actually morphs the turf into a new one.
	// Running procs do NOT get stopped due to this.
	var/old_opacity = opacity
	var/old_dynamic_lighting = dynamic_lighting
	var/old_force_lighting_update = force_lighting_update
	var/old_affecting_lights = affecting_lights
	var/old_lighting_object = lighting_object
	var/old_corners = corners

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

	var/turf/W = new path(arglist(arguments))

	W.has_resources = has_resources
	W.resources = temp_res

	if(ispath(path, /turf/simulated/floor))
		if (isfloorturf(W))
			W.RemoveLattice()

	if(SSair)
		SSair.mark_for_update(W)

	W.levelupdate()

	basetype = old_basetype

	queue_smooth_neighbors(W)

	if(SSlighting.initialized)
		recalc_atom_opacity()
		lighting_object = old_lighting_object
		affecting_lights = old_affecting_lights
		corners = old_corners
		if (force_lighting_update || old_force_lighting_update || old_opacity != opacity || dynamic_lighting != old_dynamic_lighting)
			reconsider_lights()

		if (dynamic_lighting != old_dynamic_lighting)
			if (IS_DYNAMIC_LIGHTING(src))
				lighting_build_overlay()
			else
				lighting_clear_overlay()

		for(var/turf/environment/space/S in RANGE_TURFS(1, src)) //RANGE_TURFS is in code\__HELPERS\game.dm
			S.update_starlight()

	if(F)
		F.forceMove(src)
		F.start_loc = src
		fluid_update()

	if(old_flooded)
		flooded = 1
		update_icon()
	SSdemo.mark_turf(W)

	return W

/turf/proc/MoveTurf(turf/target, move_unmovable = 0)
	if(type != basetype || move_unmovable)
		. = target.ChangeTurf(src.type)
		ChangeTurf(basetype)
	else
		return target

/turf/proc/BreakToBase()
	ChangeTurf(basetype)

/turf/proc/ReplaceWithLattice()
	ChangeTurf(basetype)
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
			M.take_damage(100, BRUTE)

////////////////
//Distance procs
////////////////

/**
 * Distance associates with all directions movement
 */
/turf/proc/Distance(turf/T)
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
	ChangeTurf(/turf/environment/space)
	return(2)

/turf/hitby(atom/movable/AM, datum/thrownthing/throwingdatum)
	if(isliving(AM))
		var/mob/living/L = AM
		L.turf_collision(src)

/turf/update_icon()
	if(is_flooded(absolute = 1))
		if(!(locate(/obj/effect/flood) in contents))
			new /obj/effect/flood(src)
	else
		if(locate(/obj/effect/flood) in contents)
			for(var/obj/effect/flood/F in contents)
				qdel(F)

/////////////////////
// Tracks, cleanables
/////////////////////

/turf/proc/AddTracks(mob/M, bloodDNA, comingdir, goingdir, blooddatum = null)
	if(flags & NOBLOODY)
		return

	var/typepath
	if(ishuman(M))
		typepath = /obj/effect/decal/cleanable/blood/tracks/footprints
	else if(isxeno(M))
		typepath = /obj/effect/decal/cleanable/blood/tracks/footprints/claws
	else // can shomeone make shlime footprint shprites later pwetty pwease?
		typepath = /obj/effect/decal/cleanable/blood/tracks/footprints/paws

	var/obj/effect/decal/cleanable/blood/tracks/tracks = locate(typepath) in src
	if(!tracks)
		tracks = new typepath(src)
	if(!blooddatum)
		blooddatum = new /datum/dirt_cover/red_blood
	tracks.AddTracks(bloodDNA, comingdir, goingdir, blooddatum)

//returns 1 if made bloody, returns 0 otherwise
/turf/add_blood(mob/living/carbon/human/M)
	if (!..())
		return 0

	var/obj/effect/decal/cleanable/blood/this = new /obj/effect/decal/cleanable/blood(src)

	//Species-specific blood.
	if(M.species)
		this.basedatum = new(M.species.blood_datum)
	else
		this.basedatum = new/datum/dirt_cover/red_blood()
	this.update_icon()

	this.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	this.virus2 = virus_copylist(M.virus2)

	return 1 //we bloodied the floor


// Only adds blood on the floor -- Skie
/turf/proc/add_blood_floor(mob/living/carbon/M)
	if(flags & NOBLOODY)
		return

	if(ismonkey(M))
		var/mob/living/carbon/monkey/Monkey = M
		var/obj/effect/decal/cleanable/blood/this = new /obj/effect/decal/cleanable/blood(src)
		this.blood_DNA[Monkey.dna.unique_enzymes] = Monkey.dna.b_type
		this.basedatum = new Monkey.blood_datum
		this.update_icon()

	else if(ishuman(M))
		add_blood(M)

	else if(isxeno(M))
		var/obj/effect/decal/cleanable/blood/xeno/this = new /obj/effect/decal/cleanable/blood/xeno(src)
		this.blood_DNA["UNKNOWN BLOOD"] = "X*"

	else if(isrobot(M))
		new /obj/effect/decal/cleanable/blood/oil(src)

/turf/proc/add_vomit_floor(mob/living/carbon/C, toxvomit = 0)
	if(flags & NOBLOODY)
		return

	var/obj/effect/decal/cleanable/vomit/V = new /obj/effect/decal/cleanable/vomit(src)
	// Make toxins vomit look different
	if(toxvomit)
		var/datum/reagent/new_color = locate(/datum/reagent/luminophore) in C.reagents.reagent_list
		if(!new_color)
			V.icon_state = "vomittox_[pick(1,4)]"
		else
			V.icon_state = "vomittox_nc_[pick(1,4)]"
			V.alpha = 127
			V.color = new_color.color
			V.light_color = V.color
			V.set_light(3)
			V.stop_light()
