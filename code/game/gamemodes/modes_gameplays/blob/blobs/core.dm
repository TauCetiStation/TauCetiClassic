//Few global vars to track the blob
var/global/blob_tiles_grown_total = 0
var/global/list/blobs = list()
var/global/list/blob_cores = list()
var/global/list/blob_nodes = list()

/obj/structure/blob/core
	name = "blob core"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_core"
	max_integrity = 200
	fire_resist = 2
	var/overmind_get_delay = 0 // we don't want to constantly try to find an overmind, do it every 30 seconds
	var/resource_delay = 0
	var/point_rate = 2
	var/last_resource_collection

/obj/structure/blob/core/atom_init(mapload, client/new_overmind, h = 200, new_rate = 2)
	blob_cores += src
	START_PROCESSING(SSobj, src)
	if(!OV)
		INVOKE_ASYNC(src, PROC_REF(create_overmind), new_overmind)
	point_rate = new_rate
	last_resource_collection = world.time
	update_integrity(h)
	. = ..()


/obj/structure/blob/core/Destroy()
	blob_cores -= src
	QDEL_NULL(OV)
	STOP_PROCESSING(SSobj, src)

	var/datum/faction/blob_conglomerate/F = find_faction_by_type(/datum/faction/blob_conglomerate)
	if(!F.detect_overminds())
		F.stage(FS_DEFEATED)

	return ..()
//	return

/obj/structure/blob/core/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/blob/core/RegenHealth()
	return // Don't regen, we handle it in Life()

/obj/structure/blob/core/Life()
	if(!OV)
		create_overmind()
	else
		var/points_to_collect = point_rate*round((world.time-last_resource_collection)/10)
		OV.add_points(points_to_collect)
		last_resource_collection = world.time

	if(get_integrity() < max_integrity)
		repair_damage(1)
	if(OV)
		OV.update_health_hud()
	for(var/dir in cardinal)
		Pulse(BLOB_CORE_MAX_PATH, dir)
	for(var/b_dir in alldirs)
		if(!prob(5))
			continue
		var/obj/structure/blob/normal/B = locate() in get_step(src, b_dir)
		if(B)
			B.change_to(/obj/structure/blob/shield)
	..()


/obj/structure/blob/core/proc/create_overmind(client/new_overmind, override_delay)

	if(overmind_get_delay > world.time && !override_delay)
		return

	overmind_get_delay = world.time + 300 // 30 seconds

	if(OV)
		qdel(OV)

	var/client/C = null
	var/list/candidates = list()

	if(!new_overmind)
		candidates = pollGhostCandidates("Would you like to be a BLOB?!", ROLE_BLOB, IGNORE_EVENT_BLOB)
		if(candidates.len)
			var/mob/M = pick(candidates)
			C = M.client
	else
		C = new_overmind

	if(!C)
		return
	var/mob/camera/blob/B = new(src.loc)
	B.key = C.key
	B.blob_core = src
	src.OV = B

	var/datum/faction/blob_conglomerate/conglomerate = create_uniq_faction(/datum/faction/blob_conglomerate)
	if(!conglomerate.get_member_by_mind(B.mind)) //We are not a member yet
		var/ded = TRUE
		if(conglomerate.members.len)
			for(var/datum/role/R in conglomerate.members)
				if (R.antag.current && !(R.antag.current.is_dead()))
					ded = FALSE
					break
		add_faction_member(conglomerate, B, !ded)

	B.b_congl = conglomerate
	notify_ghosts("[B] in [get_area(B)]!", source=B, action=NOTIFY_ORBIT, header="Blob")

	if(icon_state == "cerebrate")
		icon_state = "core"
		flick("morph_cerebrate",src)

		return TRUE
	return FALSE
