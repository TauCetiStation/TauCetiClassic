var/global/list/empty_playable_ai_cores = list()

/proc/spawn_empty_ai()
	for(var/obj/effect/landmark/start/S as anything in landmarks_list["AI"])
		if(locate(/mob/living) in S.loc)
			continue
		empty_playable_ai_cores += new /obj/structure/AIcore/deactivated(get_turf(S))

	return 1

/mob/living/silicon/ai/proc/wipe_core()
	if(ismalf(src) || istype(loc,/obj/item/device/aicard) || stat != CONSCIOUS)
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
