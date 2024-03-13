/turf/environment/space
	icon = 'icons/turf/space.dmi'
	name = "space"
	icon_state = "0"

	oxygen = 0
	carbon_dioxide = 0
	nitrogen = 0
	phoron = 0

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	plane = PLANE_SPACE
	heat_capacity = HEAT_CAPACITY_VACUUM

	flags = NOBLOODY | NOSTEPSOUND

	level_light_source = TRUE

/**
  * Space Initialize
  *
  * Doesn't call parent, see [/atom/proc/atom_init]
  * With any changes here keep in mind HOW MANY space turfs we have
  */
/turf/environment/space/atom_init()
	SHOULD_CALL_PARENT(FALSE)
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE
	icon_state = SPACE_ICON_STATE

	if(level_light_source)
		ENABLE_LEVEL_LIGHTING(src)

	if(light_power && light_range)
		update_light()

	if(opacity)
		has_opaque_atom = TRUE

	return INITIALIZE_HINT_NORMAL

/turf/environment/space/Destroy()
	SHOULD_CALL_PARENT(FALSE)
	return QDEL_HINT_LETMELIVE

/turf/environment/space/attack_paw(mob/user)
	return attack_hand(user)

/turf/proc/build_floor_support(obj/item/C, mob/user, volume = 50)
	if (istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		user.SetNextMove(CLICK_CD_RAPID)
		if(L)
			if(R.get_amount() < 2)
				to_chat(user, "<span class='warning'>Недостаточно стержней.</span>")
				return
			if(user.is_busy()) return
			to_chat(user, "<span class='notice'>Вы начинаете собирать помост.</span>")
			if(R.use_tool(src, user, 30, amount = 2, volume = volume))
				to_chat(user, "<span class='notice'>Вы собрали помост!</span>")
				ChangeTurf(/turf/simulated/floor/plating/airless/catwalk)
				qdel(L)
				return

		if(!R.use(1))
			return
		to_chat(user, "<span class='notice'>Создание поддерживающей решетки...</span>")
		playsound(src, 'sound/weapons/Genhit.ogg', VOL_EFFECTS_MASTER)
		ReplaceWithLattice()

	else if (istype(C, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			if(!S.use(1))
				return
			qdel(L)
			user.SetNextMove(CLICK_CD_RAPID)
			playsound(src, 'sound/weapons/Genhit.ogg', VOL_EFFECTS_MASTER)
			S.build(src)
			return
		else
			to_chat(user, "<span class='warning'>Для покрытия нужна опора.</span>")

/turf/environment/space/attackby(obj/item/C, mob/user)
	build_floor_support(C, user)

// Ported from unstable r355

/turf/environment/space/Entered(atom/movable/A as mob|obj)
	if(movement_disabled)
		to_chat(usr, "<span class='warning'>Передвижение отключено администрацией.</span>")//This is to identify lag problems
		return
	..()
	if ((!(A) || src != A.loc))	return

	if(SSticker && SSticker.mode)

		// Okay, so let's make it so that people can travel z levels but not nuke disks!
		if(!SSmapping.has_level(A.z))
			return
		if (A.x <= TRANSITIONEDGE || A.x >= (world.maxx - TRANSITIONEDGE - 1) || A.y <= TRANSITIONEDGE || A.y >= (world.maxy - TRANSITIONEDGE - 1))
			if(istype(A, /obj/effect/meteor))
				qdel(A)
				return

			if(istype(A, /obj/item/weapon/disk/nuclear)) // Don't let nuke disks travel Z levels  ... And moving this shit down here so it only fires when they're actually trying to change z-level.
				qdel(A) //The disk's Destroy() proc ensures a new one is created
				return

			var/list/disk_search = A.search_contents_for(/obj/item/weapon/disk/nuclear)
			if(!isemptylist(disk_search))
				if(isliving(A))
					var/mob/living/MM = A
					if(MM.client && MM.stat == CONSCIOUS)
						to_chat(MM, "<span class='warning'>Вы имеете что-то, что мешает улететь. Не прикидывайтесь: вы знаете, что это.</span>")
						if(MM.x <= TRANSITIONEDGE)
							MM.inertia_dir = 4
						else if(MM.x >= world.maxx -TRANSITIONEDGE)
							MM.inertia_dir = 8
						else if(MM.y <= TRANSITIONEDGE)
							MM.inertia_dir = 1
						else if(MM.y >= world.maxy -TRANSITIONEDGE)
							MM.inertia_dir = 2
					else
						for(var/obj/item/weapon/disk/nuclear/N in disk_search)
							qdel(N)//Make the disk respawn it is on a clientless mob or corpse
				else
					for(var/obj/item/weapon/disk/nuclear/N in disk_search)
						qdel(N)//Make the disk respawn if it is floating on its own
				return

			var/datum/space_level/L = SSmapping.get_level(z)
			if(!L)
				return

			var/move_to_z = L.get_next_z()

			if(!move_to_z)
				return

			A.z = move_to_z

			if(src.x <= TRANSITIONEDGE)
				A.x = world.maxx - TRANSITIONEDGE - 2
				A.y = rand(TRANSITIONEDGE + 2, world.maxy - TRANSITIONEDGE - 2)

			else if (A.x >= (world.maxx - TRANSITIONEDGE - 1))
				A.x = TRANSITIONEDGE + 1
				A.y = rand(TRANSITIONEDGE + 2, world.maxy - TRANSITIONEDGE - 2)

			else if (src.y <= TRANSITIONEDGE)
				A.y = world.maxy - TRANSITIONEDGE -2
				A.x = rand(TRANSITIONEDGE + 2, world.maxx - TRANSITIONEDGE - 2)

			else if (A.y >= (world.maxy - TRANSITIONEDGE - 1))
				A.y = TRANSITIONEDGE + 1
				A.x = rand(TRANSITIONEDGE + 2, world.maxx - TRANSITIONEDGE - 2)

			if(ismob(A))
				var/mob/M = A
				if(M.pulling)
					M.pulling.forceMove(get_turf(M), TRUE)


			stoplag()//Let a diagonal move finish, if necessary
			A.newtonian_move(A.inertia_dir)

/turf/environment/space/proc/Sandbox_Spacemove(atom/movable/A)
	var/cur_x
	var/cur_y
	var/next_x
	var/next_y
	var/target_z
	var/list/y_arr

	if(src.x <= 1)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			return

		var/list/cur_pos = get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		next_x = (--cur_x||global_map.len)
		y_arr = global_map[next_x]
		target_z = y_arr[cur_y]
/*
		//debug
		to_chat(world, "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		to_chat(world, "Target Z = [target_z]")
		to_chat(world, "Next X = [next_x]")
		//debug
*/
		if(target_z)
			A.z = target_z
			A.x = world.maxx - 2
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
	else if (src.x >= world.maxx)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			return

		var/list/cur_pos = get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		next_x = (++cur_x > global_map.len ? 1 : cur_x)
		y_arr = global_map[next_x]
		target_z = y_arr[cur_y]
/*
		//debug
		to_chat(world, "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		to_chat(world, "Target Z = [target_z]")
		to_chat(world, "Next X = [next_x]")
		//debug
*/
		if(target_z)
			A.z = target_z
			A.x = 3
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
	else if (src.y <= 1)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			return
		var/list/cur_pos = get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		y_arr = global_map[cur_x]
		next_y = (--cur_y||y_arr.len)
		target_z = y_arr[next_y]
/*
		//debug
		to_chat(world, "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		to_chat(world, "Next Y = [next_y]")
		to_chat(world, "Target Z = [target_z]")
		//debug
*/
		if(target_z)
			A.z = target_z
			A.y = world.maxy - 2
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)

	else if (src.y >= world.maxy)
		if(istype(A, /obj/effect/meteor))
			qdel(A)
			return
		var/list/cur_pos = get_global_map_pos()
		if(!cur_pos) return
		cur_x = cur_pos["x"]
		cur_y = cur_pos["y"]
		y_arr = global_map[cur_x]
		next_y = (++cur_y > y_arr.len ? 1 : cur_y)
		target_z = y_arr[next_y]
/*
		//debug
		to_chat(world, "Src.z = [src.z] in global map X = [cur_x], Y = [cur_y]")
		to_chat(world, "Next Y = [next_y]")
		to_chat(world, "Target Z = [target_z]")
		//debug
*/
		if(target_z)
			A.z = target_z
			A.y = 3
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
	return

/turf/environment/space/singularity_act()
	return
