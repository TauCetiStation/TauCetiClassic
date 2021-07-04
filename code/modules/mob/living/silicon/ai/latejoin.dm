var/global/list/empty_playable_ai_cores = list()

/proc/spawn_empty_ai()
	for(var/obj/effect/landmark/start/S in landmarks_list)
		if(S.name != "AI")
			continue
		if(locate(/mob/living) in S.loc)
			continue
		empty_playable_ai_cores += new /obj/structure/AIcore/deactivated(get_turf(S))

	return 1

// Wipe your core. This is functionally equivalent to cryo or robotic storage, freeing up your job slot.
/mob/living/silicon/ai/proc/wipe_core_verb()
	if(ismalf(usr))
		to_chat(usr, "<span class='danger'>You cannot use this verb in malfunction. If you need to leave, please adminhelp.</span>")
		return
	if(istype(loc,/obj/item/device/aicard))
		to_chat(usr, "<span class='danger'>Unable to establish connection with Repository. Wiping isn't possible at now.</span>")
		return
	if(stat)
		to_chat(usr, "<span class='danger'>Connection with Repository is corrupted. Wiping isn't possible at now.</span>")
		return

	// Guard against misclicks, this isn't the sort of thing we want happening accidentally
	if(tgui_alert(usr, "WARNING: This will immediately wipe your core and ghost you, removing your character from the round permanently (similar to cryo and robotic storage). Are you entirely sure you want to do this?",
					"Wipe Core", list("No", "Yes")) != "Yes")
		return
	perform_wipe_core()


/mob/living/silicon/ai/proc/wipe_core()
	if(ismalf(src) || istype(loc,/obj/item/device/aicard) || stat)
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
		if(isanyantag(src))
			mind.special_role = null

	timeofdeath = world.time
	ghostize(can_reenter_corpse = FALSE, bancheck = TRUE)
	qdel(src)
