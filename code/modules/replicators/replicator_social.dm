/mob/living/simple_animal/replicator
	var/list/next_objection_time = list()
	var/objection_cooldown = 5 SECONDS

	var/next_objection_sound = 0
	var/objection_sound_cooldown = 1 SECOND

	var/objection_end_time = 0

/mob/living/simple_animal/replicator/proc/receive_objection(mob/living/simple_animal/replicator/R)
	if(objection_end_time < world.time)
		return

	var/presence_name = global.replicators_faction.get_presence_name(R.last_controller_ckey)
	if(!presence_name)
		return

	if(next_objection_time[presence_name] > world.time)
		return
	next_objection_time[presence_name] = world.time + objection_cooldown

	to_chat(src, "<span class='bold warning'>[presence_name] objects to your actions!</span>")

	if(next_objection_sound > world.time)
		return
	next_objection_sound = world.time + objection_sound_cooldown

	playsound_local(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER, 60)

/mob/living/simple_animal/replicator/proc/do_after_objections(delay, message)
	global.replicators_faction.drone_message(src, message, objection_time=delay)
	return do_after(src, delay, target=src)
