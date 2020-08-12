////////////////////////////////
//Old Alden-Saraspova counter///
////////////////////////////////
// the old one that is used by borgs
/obj/item/device/ano_scanner
	name = "Alden-Saraspova counter"
	desc = "Aids in triangulation of exotic particles."
	icon = 'icons/obj/xenoarchaeology/tools.dmi'
	icon_state = "anoscanner_borg"
	item_state = "lampgreen"
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_FLAGS_BELT
	var/nearest_artifact_id = "unknown"
	var/nearest_artifact_distance = -1
	var/last_scan_time = 0
	var/scan_delay = 25

/obj/item/device/ano_scanner/atom_init()
	. = ..()
	scan()

/obj/item/device/ano_scanner/attack_self(mob/user)
	return interact(user)

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
	// set background = 1

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

/////////////////////////////////////////////////
//Brand new version of Alden-Saraspova counter///
/////////////////////////////////////////////////

/obj/item/device/wave_scanner_backpack
	name = "wave scanner backpack"
	desc = "Brand new NanoTrasen wave scanner, designed to search and analyze exotic waves."
	slot_flags = SLOT_FLAGS_BACK
	icon = 'icons/obj/xenoarchaeology/tools.dmi'
	icon_state = "wave_scanner"
	item_state = "wave_scanner"
	w_class = ITEM_SIZE_LARGE
	action_button_name = "Toggle Searcher"

	var/obj/item/device/searcher/processor

/obj/item/device/wave_scanner_backpack/atom_init()
	. = ..()
	processor = new(src, src)

/obj/item/device/wave_scanner_backpack/ui_action_click()
	toggle_searcher()

/obj/item/device/wave_scanner_backpack/verb/toggle_searcher()
	set name = "Toggle Searcher"
	set category = "Object"

	if(usr.incapacitated())
		return

	var/mob/M = usr
	if(M.back != src)
		to_chat(usr, "<span class='warning'>The [src] must be worn properly to use!</span>")
		return

	if(processor.loc == src)
		// Detach the searcher into the user's hands
		if(!M.put_in_hands(processor))
			to_chat(M, "<span class='warning'>You need a free hand to hold the [processor]!</span>")
			return
		playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER)
	else
		// Remove from their hands and put back "into" the backpack
		remove_processor()

/obj/item/device/wave_scanner_backpack/equipped(mob/user, slot)
	..()
	if(slot != SLOT_BACK)
		remove_processor()

/obj/item/device/wave_scanner_backpack/proc/remove_processor()
	if(!processor)
		return

	if(ismob(processor.loc))
		var/mob/M = processor.loc
		if(M.drop_from_inventory(processor, src))
			to_chat(M, "<span class='notice'>\The [processor] snaps back into the [src].</span>")
			playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER)
	else
		processor.forceMove(src)

/obj/item/device/wave_scanner_backpack/Destroy()
	QDEL_NULL(processor)
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

/obj/item/device/wave_scanner_backpack/attackby(obj/item/I, mob/user, params)
	if(I == processor)
		remove_processor()
	else
		return ..()

/obj/item/device/wave_scanner_backpack/dropped(mob/user)
	..()
	remove_processor()

/obj/item/device/searcher
	name = "exotic wave searcher"
	desc = "Searches for exotic waves."
	icon = 'icons/obj/xenoarchaeology/tools.dmi'
	icon_state = "wave_searcher"
	item_state = "wave_searcher"
	w_class = ITEM_SIZE_LARGE
	throwforce = 0 // we shall not abuse
	throw_range = 0
	slot_flags = null
	var/nearest_artifact_id = "unknown"
	var/nearest_artifact_distance = -1
	var/last_scan_time = 0
	var/scan_delay = 25

	var/obj/item/device/wave_scanner_backpack/wavescanner

/obj/item/device/searcher/atom_init(mapload, source_wavescanner)
	. = ..()
	scan()
	wavescanner = source_wavescanner

/obj/item/device/searcher/Destroy()
	if(wavescanner)
		wavescanner.processor = null
	return ..()

/obj/item/device/searcher/dropped(mob/user)
	..()
	if(wavescanner)
		wavescanner.remove_processor()
		playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER)
	else
		playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER)
		qdel(src)

/obj/item/device/searcher/afterattack(atom/target, mob/user, proximity, params)
	if(target.loc == loc || target == wavescanner)
		return
	..()

/obj/item/device/searcher/after_throw(datum/callback/callback)
	..()
	if(wavescanner)
		wavescanner.remove_processor()
		playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER)
	else
		playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER)
		qdel(src)
	return

/obj/item/device/searcher/attack_self(mob/user)
	return interact(user)

/obj/item/device/searcher/interact(mob/user)
	var/message = "Background radiation levels detected."
	if(world.time - last_scan_time >= scan_delay)
		playsound(src, 'sound/weapons/guns/gunpulse_wave.ogg', VOL_EFFECTS_MASTER, 10)
		INVOKE_ASYNC(src, .proc/scan)
		if(nearest_artifact_distance >= 0)
			message = "Exotic energy detected on wavelength '[nearest_artifact_id]' in a radius of [nearest_artifact_distance]m"
	else
		message = "Scanning array is recharging."

	to_chat(user, "<span class='info'>[message]</span>")

/obj/item/device/searcher/proc/scan()
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
