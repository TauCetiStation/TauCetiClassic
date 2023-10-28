/mob/living/simple_animal/hostile/replicator
	var/list/next_objection_time = list()
	var/objection_cooldown = 5 SECONDS

	var/next_objection_sound = 0
	var/objection_sound_cooldown = 1 SECOND

	var/objection_end_time = 0

/mob/living/simple_animal/hostile/replicator/proc/receive_objection(mob/living/simple_animal/hostile/replicator/R)
	if(objection_end_time < world.time)
		return

	if(!R.is_controlled())
		return

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	var/datum/replicator_array_info/RAI = FR.ckey2info[R.ckey]
	if(!RAI)
		return

	if(next_objection_time[R.ckey] > world.time)
		return
	next_objection_time[R.ckey] = world.time + objection_cooldown

	var/datum/role/replicator/repl_role = FR.get_member_by_ckey(last_controller_ckey)
	if(!repl_role)
		return

	var/datum/mind/repl_mind = repl_role.antag
	if(!repl_mind)
		return

	if(!repl_mind.current)
		return

	to_chat(repl_mind.current, "<span class='bold warning'>[RAI.presence_name] objects to your actions!</span>")
	// to_chat(R, "<span class='notice'>You have objected to [R]'s actions.</span>")

	if(next_objection_sound > world.time)
		return
	next_objection_sound = world.time + objection_sound_cooldown

	var/datum/replicator_array_info/my_RAI = FR.ckey2info[last_controller_ckey]

	playsound_local(repl_mind.current, 'sound/machines/buzz-sigh.ogg', VOL_EFFECTS_MASTER)
	my_RAI.objections_received += 1

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
