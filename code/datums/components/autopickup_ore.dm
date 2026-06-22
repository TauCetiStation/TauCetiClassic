/datum/component/autopickup_ore

/datum/component/autopickup_ore/proc/pickup_all_on_tile(turf/T, mob/user, obj/item/weapon/storage/bag/B)
	if (B.max_storage_space < B.storage_space_used() + SIZE_TINY)
		return
	if(B.collection_mode)
		for(var/obj/item/weapon/ore/O in T.contents)
			O.attackby(B,user)
