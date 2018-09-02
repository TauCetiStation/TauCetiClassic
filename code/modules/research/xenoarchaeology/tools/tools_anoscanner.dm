/obj/item/device/ano_scanner
	name = "Alden-Saraspova counter"
	desc = "Aids in triangulation of exotic particles."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "flashgun"
	item_state = "lampgreen"
	w_class = 2.0
	slot_flags = SLOT_BELT
	var/nearest_artifact_id = "unknown"
	var/nearest_artifact_distance = -1
	var/last_scan_time = 0
	var/scan_delay = 25

/obj/item/device/ano_scanner/atom_init()
	. = ..()
	scan() // ?why?

/obj/item/device/ano_scanner/attack_self(mob/user)
	return src.interact(user)

/obj/item/device/ano_scanner/interact(mob/user)
	var/message = "Background radiation levels detected."
	if(world.time - last_scan_time >= scan_delay)
		INVOKE_ASYNC(src, .proc/scan)
		if(nearest_artifact_distance >= 0)
			message = "Exotic energy detected on wavelength '[nearest_artifact_id]' in a radius of [nearest_artifact_distance]m"
	else
		message = "Scanning array is recharging."

	to_chat(user, "<span class='info'>[message]</span>")

/obj/item/device/ano_scanner/proc/scan()
	//set background = 1

	last_scan_time = world.time
	nearest_artifact_distance = -1
	var/turf/cur_turf = get_turf(src)
	for(var/turf/simulated/mineral/T in SSxenoarch.turfs_with_artifacts)
		if(T.artifact_find)
			if(T.z == cur_turf.z)
				var/cur_dist = get_dist(cur_turf, T) * 2
				if( (nearest_artifact_distance < 0 || cur_dist < nearest_artifact_distance) && cur_dist <= T.artifact_find.artifact_detect_range )
					nearest_artifact_distance = cur_dist + rand() * 2 - 1
					nearest_artifact_id = T.artifact_find.artifact_id
		else
			SSxenoarch.turfs_with_artifacts.Remove(T)
	cur_turf.visible_message("<span class='info'>[src] clicks.</span>")

/obj/item/device/wave_scanner_backpack
	name = "wave scanner backpack"
	desc = "Brand new NanoTrasen wave scanner, created to search and analyze exotic waves."
	slot_flags = SLOT_BACK
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "wave_scanner"
	item_state = "wave_scanner"
	flags = OPENCONTAINER
	w_class = ITEM_SIZE_LARGE
	action_button_name = "Toggle Searcher"

	var/obj/item/device/scanner/array

/obj/item/device/wave_scanner_backpack/atom_init()
	. = ..()
	array = new(src, src)

/obj/item/device/wave_scanner_backpack/ui_action_click()
	toggle_scanner()

/obj/item/device/wave_scanner_backpack/verb/toggle_scanner()
	set name = "Toggle Searcher"
	set category = "Object"

	var/mob/M = usr
	if(M.back != src)
		to_chat(usr, "<span class='warning'>The [src] must be worn properly to use!</span>")
		return

	if(usr.incapacitated())
		return

	var/mob/living/carbon/human/user = usr
	if(array.loc == src)
		//Detach an array into the user's hands
		if(!user.put_in_hands(array))
			to_chat(user, "<span class='warning'>You need a free hand to hold the [array]!</span>")
			return
	else
		//Remove from their hands and put back "into" the backpack
		remove_array()
	return

/obj/item/device/wave_scanner_backpack/equipped(mob/user, slot)
	..()
	if(slot != SLOT_BACK)
		remove_array()

/obj/item/device/wave_scanner_backpack/proc/remove_array()
	if(!array)
		return

	if(ismob(array.loc))
		var/mob/M = array.loc
		if(M.drop_from_inventory(array, src))
			to_chat(M, "<span class='notice'>\The [array] snaps back into the [src].</span>")
	else
		array.forceMove(src)
	return

/obj/item/device/wave_scanner_backpack/Destroy()
	QDEL_NULL(array)
	return ..()

/obj/item/device/wave_scanner_backpack/attack_hand(mob/user)
	if(loc == user)
		ui_action_click()
		return
	..()

/obj/item/device/wave_scanner_backpack/MouseDrop()
	if(ismob(loc))
		if(!CanMouseDrop(src))
			return
		var/mob/M = loc
		if(!M.unEquip(src))
			return
		add_fingerprint(usr)
		M.put_in_hands(src)

/obj/item/device/wave_scanner_backpack/attackby(obj/item/W, mob/user, params)
	if(W == array)
		remove_array()
	else
		..()

/obj/item/device/wave_scanner_backpack/dropped(mob/user)
	..()
	remove_array()

/obj/item/device/scanner
	name = "exotic wave searcher"
	desc = "Searches for exotic waves."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "wave_searcher"
	item_state = "wave_searcher"
	w_class = ITEM_SIZE_LARGE
	throwforce = 0 //we shall not abuse
	slot_flags = null
	var/nearest_artifact_id = "unknown"
	var/nearest_artifact_distance = -1
	var/last_scan_time = 0
	var/scan_delay = 25

	var/obj/item/device/wave_scanner_backpack/tank

/obj/item/device/scanner/atom_init(mapload, source_tank)
	. = ..()
	tank = source_tank

/obj/item/device/scanner/Destroy()
	if(tank)
		tank.array = null
	return ..()

/obj/item/device/scanner/dropped(mob/user)
	..()
	if(tank)
		tank.remove_array()
	else
		qdel(src)

/obj/item/device/scanner/afterattack(obj/target, mob/user, proximity)
	if(target.loc == loc || target == tank)
		return
	..()

/obj/item/device/scanner/atom_init()
	. = ..()
	scan() // ?why?

/obj/item/device/scanner/attack_self(mob/user)
	return src.interact(user)

/obj/item/device/scanner/interact(mob/user)
	var/message = "Background radiation levels detected."
	if(world.time - last_scan_time >= scan_delay)
		INVOKE_ASYNC(src, .proc/scan)
		if(nearest_artifact_distance >= 0)
			message = "Exotic energy detected on wavelength '[nearest_artifact_id]' in a radius of [nearest_artifact_distance]m"
	else
		message = "Scanning array is recharging."

	to_chat(user, "<span class='info'>[message]</span>")

/obj/item/device/scanner/proc/scan()
	//set background = 1

	last_scan_time = world.time
	nearest_artifact_distance = -1
	var/turf/cur_turf = get_turf(src)
	for(var/turf/simulated/mineral/T in SSxenoarch.turfs_with_artifacts)
		if(T.artifact_find)
			if(T.z == cur_turf.z)
				var/cur_dist = get_dist(cur_turf, T) * 2
				if( (nearest_artifact_distance < 0 || cur_dist < nearest_artifact_distance) && cur_dist <= T.artifact_find.artifact_detect_range )
					nearest_artifact_distance = cur_dist + rand() * 2 - 1
					nearest_artifact_id = T.artifact_find.artifact_id
		else
			SSxenoarch.turfs_with_artifacts.Remove(T)
	cur_turf.visible_message("<span class='info'>[src] clicks.</span>")
