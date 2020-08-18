/obj/effect/blob/core
	name = "blob core"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_core"
	health = 200
	fire_resist = 2
	var/mob/camera/blob/overmind = null // the blob core's overmind
	var/overmind_get_delay = 0 // we don't want to constantly try to find an overmind, do it every 30 seconds
	var/resource_delay = 0
	var/point_rate = 2
	var/last_resource_collection

/obj/effect/blob/core/atom_init(mapload, h = 200, client/new_overmind, new_rate = 2)
	blob_cores += src
	START_PROCESSING(SSobj, src)
	if(!overmind)
		create_overmind(new_overmind)
	point_rate = new_rate
	last_resource_collection = world.time
	. = ..()


/obj/effect/blob/core/Destroy()
	blob_cores -= src
	if(overmind)
		qdel(overmind)
	STOP_PROCESSING(SSobj, src)
	return ..()
//	return

/obj/effect/blob/core/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/effect/blob/core/update_icon()
	if(health <= 0)
		qdel(src)
		return
	// update_icon is called when health changes so... call update_health in the overmind
	return

/obj/effect/blob/core/RegenHealth()
	return // Don't regen, we handle it in Life()

/obj/effect/blob/core/Life()
	if(!overmind)
		create_overmind()
	else
		var/points_to_collect = point_rate*round((world.time-last_resource_collection)/10)
		overmind.add_points(points_to_collect)
		last_resource_collection = world.time

	health = min(initial(health), health + 1)
	if(overmind)
		overmind.update_health_hud()
	for(var/dir in cardinal)
		Pulse(BLOB_CORE_MAX_PATH, dir)
	for(var/b_dir in alldirs)
		if(!prob(5))
			continue
		var/obj/effect/blob/normal/B = locate() in get_step(src, b_dir)
		if(B)
			B.change_to(/obj/effect/blob/shield)
	..()


/obj/effect/blob/core/proc/create_overmind(client/new_overmind, override_delay)

	if(overmind_get_delay > world.time && !override_delay)
		return

	overmind_get_delay = world.time + 300 // 30 seconds

	if(overmind)
		qdel(overmind)

	var/client/C = null
	var/list/candidates = list()

	if(!new_overmind)
		candidates = pollGhostCandidates("Would you like to be a BLOB?!", ROLE_BLOB)
		if(candidates.len)
			var/mob/M = pick(candidates)
			C = M.client
	else
		C = new_overmind

	if(C)
		var/mob/camera/blob/B = new(src.loc)
		B.key = C.key
		B.blob_core = src
		src.overmind = B
		return 1
	return 0
