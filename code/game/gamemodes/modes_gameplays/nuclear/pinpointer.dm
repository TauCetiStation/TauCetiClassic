#define SEARCH_FOR_DISK 0
#define SEARCH_FOR_OBJECT 1

/obj/item/weapon/pinpointer
	name = "pinpointer"
	icon_state = "pinoff"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	w_class = SIZE_TINY
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	var/active = FALSE
	var/atom/target = null
	var/mode = SEARCH_FOR_DISK  // Need here for GREAT OOP style, 0 - searching disk

/obj/item/weapon/pinpointer/attack_self(mob/user)
	if(!active)
		START_PROCESSING(SSobj, src)
		to_chat(user, "<span class='notice'>You activate the pinpointer</span>")
	else
		icon_state = "pinoff"
		to_chat(user, "<span class='notice'>You deactivate the pinpointer</span>")
	active = !active

/obj/item/weapon/pinpointer/process()
	if(!active)
		return
	if(!target && !mode)
		target = locate(/obj/item/weapon/disk/nuclear)
		if(!target)
			icon_state = "pinonnull"
			return
	if(target)
		set_dir(get_dir(src, target))
		var/turf/self_turf = get_turf(src)
		var/turf/target_turf = get_turf(target)
		if(target_turf.z != self_turf.z)
			icon_state = "pinonalert"
		else if(target_turf == self_turf)
			icon_state = "pinondirect"
		else
			switch(get_dist(target_turf, self_turf))
				if(1 to 8)
					icon_state = "pinonclose"
				if(9 to 16)
					icon_state = "pinonmedium"
				if(16 to INFINITY)
					icon_state = "pinonfar"

/obj/item/weapon/pinpointer/examine(mob/user)
	..()
	for(var/obj/machinery/nuclearbomb/bomb in poi_list)
		if(bomb.timing)
			to_chat(user, "Extreme danger.  Arming signal detected.   Time remaining: [bomb.timeleft]")

/obj/item/weapon/pinpointer/proc/reset_target()
	SIGNAL_HANDLER
	if(mode && target)
		UnregisterSignal(target, list(COMSIG_PARENT_QDELETING))

	active = FALSE
	STOP_PROCESSING(SSobj, src)
	icon_state = "pinoff"
	target = null

/obj/item/weapon/pinpointer/Destroy()
	reset_target()
	return ..()

/obj/item/weapon/pinpointer/advpinpointer
	name = "Advanced Pinpointer"
	desc = "A larger version of the normal pinpointer, this unit features a helpful quantum entanglement detection system to locate various objects that do not broadcast a locator signal."

/obj/item/weapon/pinpointer/advpinpointer/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Pinpointer Mode"
	set src in view(1)

	reset_target()

	switch(tgui_alert(usr, "Please select the mode you want to put the pinpointer in.", "Pinpointer Mode Select", list("Location", "Disk Recovery", "Other Signature")))

		if("Disk Recovery")
			mode = SEARCH_FOR_DISK
		if("Location")
			mode = SEARCH_FOR_OBJECT
			var/locationx = input(usr, "Please input the x coordinate to search for.", "Location?" , "") as num
			if(!locationx || !(usr in view(1, src)))
				return
			var/locationy = input(usr, "Please input the y coordinate to search for.", "Location?" , "") as num
			if(!locationy || !(usr in view(1, src)))
				return
			var/turf/Z = get_turf(src)
			var/area/A = locate(locationx, locationy, Z.z)
			if(A)
				target = A
				to_chat(usr, "You set the pinpointer to locate [locationx],[locationy]")
			else
				to_chat(usr, "No area located at [locationx],[locationy]")

		if("Other Signature")
			mode = SEARCH_FOR_OBJECT
			switch(tgui_alert(usr, "Search for AI signature or DNA fragment?" , "Signature Mode Select" , list("DNA", "AI System", "Microphone")))
				if("DNA")
					var/DNAstring = sanitize(input("Input DNA string to search for." , "Please Enter String." , ""))
					if(!DNAstring)
						return
					for(var/mob/living/carbon/M as anything in carbon_list)
						if(!M.dna)
							continue
						if(M.dna.unique_enzymes && M.dna.unique_enzymes == DNAstring)
							target = M
							break
				if("AI System")
					if(!global.ai_list.len)
						to_chat(usr, "Failed to locate active AI system!")
						return
					var/target_ai = input("Select AI to search for", "AI Select") as null|anything in global.ai_list
					if(!target_ai)
						return
					target = target_ai
					to_chat(usr, "You set the pinpointer to locate [target]")
				if("Microphone")
					if(!global.all_command_microphones.len)
						to_chat(usr, "Failed to locate any microphone!")
						return
					var/target_micro = input("Select microphone to search for", "Microphone Select") as null|anything in global.all_command_microphones
					if(!target_micro)
						return
					target = target_micro
					to_chat(usr, "You set the pinpointer to locate [target]")

	if(mode && target)
		RegisterSignal(target, list(COMSIG_PARENT_QDELETING), PROC_REF(reset_target))

	return attack_self(usr)

/obj/item/weapon/pinpointer/nukeop

/obj/item/weapon/pinpointer/nukeop/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Pinpointer Mode"
	set src in view(1)

	reset_target()

	switch(tgui_alert(usr, "Please select the mode you want to put the pinpointer in.", "Pinpointer Mode Select", list("Shuttle Location", "Disk", "Nuclear Warhead")))

		if("Disk")
			mode = SEARCH_FOR_DISK
			to_chat(usr, "<span class='notice'>Authentication Disk Locator active.</span>")
		if("Shuttle Location")
			mode = SEARCH_FOR_OBJECT
			target = locate(/obj/machinery/computer/syndicate_station)
			to_chat(usr, "<span class='notice'>Shuttle Locator active.</span>")

		if("Nuclear Warhead")
			mode = SEARCH_FOR_OBJECT
			for (var/obj/machinery/nuclearbomb/N in poi_list)
				if(N.nuketype == "Syndi")
					target = locate(N)
					to_chat(usr, "<span class='notice'>Nuclear Warhead Locator active.</span>")

	playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)

	if(mode && target)
		RegisterSignal(target, list(COMSIG_PARENT_QDELETING), PROC_REF(reset_target))

	return attack_self(usr)

/proc/get_jobs_dna(list/required_positions)
	var/list/players = list()
	for (var/datum/data/record/R in data_core.general)
		if (R.fields["rank"] in required_positions)
			players[R.fields["id"]] = R.fields["name"]

	var/list/dnas = list()
	for (var/datum/data/record/R in data_core.medical)
		if (R.fields["id"] in players) // There will be fun thing, if ID's are overlapping
			dnas[players[R.fields["id"]]] = R.fields["b_dna"] // If Head is IPC there will be ""
	return dnas

/proc/get_humans_by_dna(dna)
	var/list/result = list()
	for(var/mob/living/carbon/human/player in human_list)
		if (!player.dna)
			continue
		if (!player.dna.unique_enzymes)
			continue // IPC will produce "?" on pinpointer, because there is no DNA
		if (player.dna.unique_enzymes == dna)
			result += player
	return result

/obj/item/weapon/pinpointer/heads
	name = "heads of staff pinpointer"
	desc = "A larger version of the normal pinpointer. Includes quantuum connection to the database of the Station Heads of Staff to point to."

	var/target_dna = null

/obj/item/weapon/pinpointer/heads/process()
	if (!active)
		STOP_PROCESSING(SSobj, src) // Just to be sure
		return

	if (!target_dna)
		icon_state = "pinonnull"
		return

	var/list/_target = null
	if (target_dna)
		_target = get_humans_by_dna(target_dna)

	if (active && !_target.len)
		icon_state = "pinonnull"
		return

	if (_target.len > 1)
		target = get_closest_atom(/mob/living/carbon/human, _target, src)
	else
		target = pick(_target)

	return ..()

/obj/item/weapon/pinpointer/heads/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Pinpointer Target"
	set src in view(1)

	active = FALSE
	STOP_PROCESSING(SSobj, src)
	icon_state = "pinoff"

	var/list/heads_dna = get_jobs_dna(heads_positions + "Internal Affairs Agent")
	if (!heads_dna.len)
		to_chat(usr, "There is no command staff on the station!")
		return
	var/target_head = tgui_input_list(usr, "Head to point to", "Target selection", heads_dna)

	if (!target_head)
		return
	target_dna = heads_dna[target_head]
	to_chat(usr, "You set the pinpointer to locate [target_head]")

	return attack_self(usr)

#undef SEARCH_FOR_DISK
#undef SEARCH_FOR_OBJECT
