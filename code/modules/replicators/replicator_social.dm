/mob/living/simple_animal/replicator
	var/list/next_objection_time = list()
	var/objection_cooldown = 5 SECONDS

	var/next_objection_sound = 0
	var/objection_sound_cooldown = 1 SECOND

	var/objection_end_time = 0

/mob/living/simple_animal/replicator/proc/receive_objection(mob/living/simple_animal/replicator/R)
	if(objection_end_time < world.time)
		return

	if(!R.mind)
		return

	var/datum/role/replicator/R_role = R.mind.GetRole(REPLICATOR)
	if(!R_role)
		return

	if(next_objection_time[R_role.presence_name] > world.time)
		return
	next_objection_time[R_role.presence_name] = world.time + objection_cooldown

	to_chat(src, "<span class='bold warning'>[R_role.presence_name] objects to your actions!</span>")

	if(next_objection_sound > world.time)
		return
	next_objection_sound = world.time + objection_sound_cooldown

	playsound_local(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)

/mob/living/simple_animal/replicator/proc/do_after_objections(delay, message)
	global.replicators_faction.drone_message(src, message, objection_time=delay)
	return do_after(src, delay, target=src)
