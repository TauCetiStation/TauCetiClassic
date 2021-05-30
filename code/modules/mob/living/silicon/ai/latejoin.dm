var/global/list/empty_playable_ai_cores = list()

/proc/spawn_empty_ai()
	for(var/obj/effect/landmark/start/S in landmarks_list)
		if(S.name != "AI")
			continue
		if(locate(/mob/living) in S.loc)
			continue
		empty_playable_ai_cores += new /obj/structure/AIcore/deactivated(get_turf(S))

	return 1

/mob/living/silicon/ai/verb/wipe_core_verb()
	set name = "Wipe Core"
	set category = "OOC"
	set desc = "Wipe your core. This is functionally equivalent to cryo or robotic storage, freeing up your job slot."

	if(SSticker.mode.name == "AI malfunction")
		to_chat(usr, "<span class='danger'>You cannot use this verb in malfunction. If you need to leave, please adminhelp.</span>")
		return
	if(istype(loc,/obj/item/device/aicard))
		to_chat(usr, "<span class='danger'>Unable to establish connection with Repository. Wiping isn't possible at now.</span>")
		return
	if(stat)
		to_chat(usr, "<span class='danger'>Connection with Repository is corrupted. Wiping isn't possible at now.</span>")
		return

	// Guard against misclicks, this isn't the sort of thing we want happening accidentally
	if(alert("WARNING: This will immediately wipe your core and ghost you, removing your character from the round permanently (similar to cryo and robotic storage). Are you entirely sure you want to do this?",
					"Wipe Core", "No", "No", "Yes") != "Yes")
		return
	perform_wipe_core()


/mob/living/silicon/ai/proc/wipe_core()
	if(SSticker.mode.name == "AI malfunction" || istype(loc,/obj/item/device/aicard) || stat)
		wipe_timer_id = 0
		return
	perform_wipe_core()

/mob/living/silicon/ai/proc/perform_wipe_core()
	empty_playable_ai_cores += new /obj/structure/AIcore/deactivated(loc)
	global_announcer.autosay("[src] has been moved to intelligence storage.", "Artificial Intelligence Oversight")
	//Handle job slot/tater cleanup.
	if(mind)
		var/job = mind.assigned_role
		SSjob.FreeRole(job)
		if(mind.objectives.len)
			qdel(mind.objectives)
			mind.special_role = null

	timeofdeath = world.time
	ghostize(can_reenter_corpse = FALSE, bancheck = TRUE)
	qdel(src)
