/mob/living/simple_animal/hostile/replicator
	var/list/next_objection_time = list()
	var/objection_cooldown = 5 SECONDS

	var/next_objection_sound = 0
	var/objection_sound_cooldown = 1 SECOND

	var/objection_end_time = 0

/mob/living/simple_animal/hostile/replicator/proc/receive_objection(mob/living/simple_animal/hostile/replicator/R)
	if(objection_end_time < world.time)
		return

	if(!R.ckey)
		return

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	var/datum/replicator_array_info/RAI = FR.ckey2info[R.ckey]
	if(!RAI)
		return

	if(next_objection_time[R.ckey] > world.time)
		return
	next_objection_time[R.ckey] = world.time + objection_cooldown

	to_chat(src, "<span class='bold warning'>[RAI.presence_name] objects to your actions!</span>")
	// to_chat(R, "<span class='notice'>You have objected to [R]'s actions.</span>")

	if(next_objection_sound > world.time)
		return
	next_objection_sound = world.time + objection_sound_cooldown

	playsound_local(src, 'sound/machines/buzz-sigh.ogg', VOL_EFFECTS_MASTER)

/mob/living/simple_animal/hostile/replicator/proc/do_after_objections(delay, message, datum/callback/extra_checks=null)
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()

	var/indicator = say_test(message)
	var/ending = ""
	if(indicator == 1)
		ending = "?"
	else if(indicator == 2)
		ending = "!"

	emote("beep[ending]")
	FR.drone_message(src, message, objection_time=delay)
	return do_after(src, delay, target=src, extra_checks=extra_checks)
