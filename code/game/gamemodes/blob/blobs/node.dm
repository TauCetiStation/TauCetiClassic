/obj/effect/blob/node
	name = "blob node"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_node"
	health = 100
	fire_resist = 2


/obj/effect/blob/node/atom_init(mapload, h = 100)
	blob_nodes += src
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/effect/blob/node/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/effect/blob/node/Destroy()
	blob_nodes -= src
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/blob/node/Life()
	for(var/dir in cardinal)
		Pulse(BLOB_NODE_MAX_PATH, dir)
	health = min(initial(health), health + 1)

/obj/effect/blob/node/update_icon()
	if(health <= 0)
		qdel(src)
		return
	return
