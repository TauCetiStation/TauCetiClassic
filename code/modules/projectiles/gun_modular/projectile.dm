/obj/item/gun_modular/projectile

/obj/item/gun_modular/projectile/proc/Fire(datum/process_fire/process)

	var/loc_start = process.GetData(START_FIRE_LOC)

	if(!loc_start)
		src.loc = get_turf(src.loc)
	else
		src.loc = get_turf(locate(loc_start[1], loc_start[2], loc_start[3]))

	START_PROCESSING(SSfastprocess, src)

/obj/item/gun_modular/projectile/process()
	
	
	