/obj/structure/blob/node
	name = "blob node"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_node"
	max_integrity = 100
	fire_resist = 2
	var/given_name = null


/obj/structure/blob/node/atom_init(mapload, h = 100)
	blob_nodes += src
	given_name = "[get_area(loc)] ([rand(100, 999)])"
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/blob/node/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/blob/node/Destroy()
	blob_nodes -= src
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/blob/node/Life()
	for(var/dir in cardinal)
		Pulse(BLOB_NODE_MAX_PATH, dir)
	if(get_integrity() < max_integrity)
		repair_damage(1)
