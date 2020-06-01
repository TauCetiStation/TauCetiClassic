//This file deals with distress beacons. It randomizes between a number of different types when activated.
//There's also an admin commmand which lets you set one to your liking.


//The distress call parent.
/datum/emergency_call
	var/name = ""
	var/mob_max = 10
	var/mob_min = 1
	var/dispatch_message = "An encrypted signal has been received from a nearby vessel. Stand by." //Message displayed to marines once the signal is finalized.
	var/objectives = "" //Objectives to display to the members.
	var/probability = 0 //So we can give different ERTs a different probability.
	var/list/mob/dead/observer/members = list() //Currently-joined members.
	var/list/mob/dead/observer/candidates = list() //Potential candidates for enlisting.
	var/mob/living/carbon/leader = null
	var/shuttle_id = "distress"
	var/medics = 0
	var/max_medics = 1
	var/candidate_timer
	var/cooldown_timer

/datum/game_mode/proc/initialize_emergency_calls()
	if(length(all_calls)) //It's already been set up.
		return

	var/list/total_calls = subtypesof(/datum/emergency_call)
	if(!length(total_calls))
		CRASH("No distress Datums found.")

	for(var/x in total_calls)
		var/datum/emergency_call/D = new x()
		if(!D?.name)
			continue //The default parent, don't add it
		all_calls += D


//Randomizes and chooses a call datum.
/datum/game_mode/proc/get_random_call()
	var/datum/emergency_call/chosen_call
	var/list/valid_calls = list()

	for(var/datum/emergency_call/E in all_calls) //Loop through all potential candidates
		if(E.probability < 1) //Those that are meant to be admin-only
			continue

		valid_calls.Add(E)

		if(prob(E.probability))
			chosen_call = E
			break

	if(!istype(chosen_call))
		chosen_call = pick(valid_calls)

	return chosen_call

/datum/emergency_call/proc/show_join_message()
	if(!mob_max || !ticker?.mode) //Not a joinable distress call.
		return

	for(var/i in observer_list)
		var/mob/dead/observer/M = i
		to_chat(M, "<br><font size='3'><span class='attack'>An emergency beacon has been activated. Use the Join Response Team To Join")
		to_chat(M, "<span class='attack'>You cannot join if you have Ghosted before this message.</span><br>")


/datum/game_mode/proc/activate_distress(datum/emergency_call/chosen_call)
	picked_call = chosen_call || get_random_call()

	if(ticker?.mode?.waiting_for_candidates) //It's already been activated
		return FALSE

	picked_call.mob_max = rand(5, 15)

	picked_call.activate()


/mob/dead/observer/verb/JoinResponseTeam()
	set name = "Join Response Team"
	set category = "Ghost"
	set desc = "Join an ongoing distress call response. You must be ghosted to do this."

	var/datum/emergency_call/distress = ticker?.mode?.picked_call //Just to simplify things a bit

	if(jobban_isbanned(usr, "Syndicate") || jobban_isbanned(usr, ROLE_ERT) || jobban_isbanned(usr, "Security Officer"))
		to_chat(usr, "<span class='danger'>You are jobbanned from the emergency reponse team!</span>")
		return

	if(!istype(distress) || !ticker.mode.waiting_for_candidates || distress.mob_max < 1)
		to_chat(usr, "<span class='warning'>No distress beacons that need candidates are active. You will be notified if that changes.</span>")
		return
/*
	var/deathtime = world.time - usr.timeofdeath

	if(deathtime < 600) //They have ghosted after the announcement.
		to_chat(usr, "<span class='warning'>You ghosted too recently. Try again later.</span>")
		return
*/
	if(usr in distress.candidates)
		to_chat(usr, "<span class='warning'>You are already a candidate for this emergency response team.</span>")
		return

	if(distress.add_candidate(usr))
		to_chat(usr, "<span class='boldnotice'>You are now a candidate in the emergency response team! If there are enough candidates, you may be picked to be part of the team.</span>")
	else
		to_chat(usr, "<span class='warning'>Something went wrong while adding you into the candidate list!</span>")

/datum/emergency_call/proc/reset()
	if(candidate_timer)
		deltimer(candidate_timer)
		candidate_timer = null
	if(cooldown_timer)
		deltimer(cooldown_timer)
		cooldown_timer = null
	members = list()
	candidates = list()
	ticker.mode.waiting_for_candidates = FALSE
	ticker.mode.on_distress_cooldown = FALSE
	message_admins("Distress beacon: [name] has been reset.")

/datum/emergency_call/proc/activate(announce = TRUE)
	if(!ticker?.mode) //Something horribly wrong with the gamemode ticker
		message_admins("Distress beacon: [name] attempted to activate but no gamemode exists")
		return FALSE

	if(ticker.mode.on_distress_cooldown) //It's already been called.
		message_admins("Distress beacon: [name] attempted to activate but distress is on cooldown")
		return FALSE

	if(mob_max > 0)
		ticker.mode.waiting_for_candidates = TRUE

	show_join_message() //Show our potential candidates the message to let them join.
	message_admins("Distress beacon: '[name]' activated. Looking for candidates.")
/*
	if(announce)
		priority_announce("A distress beacon has been launched from the [Station.", "Priority Alert", sound = 'sound/AI/distressbeacon.ogg')
*/
	ticker.mode.on_distress_cooldown = TRUE

	candidate_timer = addtimer(CALLBACK(src, .proc/do_activate, announce), 1 MINUTES, TIMER_STOPPABLE)

/datum/emergency_call/proc/do_activate(announce = TRUE)
	candidate_timer = null
	ticker.mode.waiting_for_candidates = FALSE

	var/list/valid_candidates = list()

	for(var/i in candidates)
		var/mob/dead/observer/M = i
		if(!istype(M)) // invalid
			return
		valid_candidates += M

	message_admins("Distress beacon: [name] got [length(candidates)] candidates, [length(valid_candidates)] of them were valid.")

	if(length(valid_candidates) < mob_min)
		message_admins("Aborting distress beacon [name], not enough candidates. Found: [length(valid_candidates)]. Minimum required: [mob_min].")
		ticker.mode.waiting_for_candidates = FALSE
		members = list() //Empty the members list.
		candidates = list()

		if(announce)
			captain_announce("The distress signal has not received a response, the launch tubes are now recalibrating.", "Distress Beacon")

		ticker.mode.picked_call = null
		ticker.mode.on_distress_cooldown = TRUE

		return

	var/mob/dead/observer/picked_candidates = list()
	if(length(valid_candidates) > mob_max)
		for(var/i in 1 to mob_max)
			if(!length(valid_candidates)) //We ran out of candidates.
				break
			picked_candidates += pick_n_take(valid_candidates) //Get a random candidate, then remove it from the candidates list.

		for(var/mob/dead/observer/M in valid_candidates)
			if(!M)
				to_chat(M, "<span class='warning'>You didn't get selected to join the distress team. Better luck next time!</span>")
		message_admins("Distress beacon: [length(valid_candidates)] valid candidates were not selected.")
	else
		picked_candidates = valid_candidates // save some time
		message_admins("Distress beacon: All valid candidates were selected.")
/*
	if(announce)
		priority_announce(dispatch_message, "Distress Beacon", sound = 'sound/AI/distressreceived.ogg')
*/
	message_admins("Distress beacon: [name] finalized, starting spawns.")



	if(length(picked_candidates) && mob_min > 0)
		max_medics = max(round(length(picked_candidates) * 0.25), 1)
		for(var/i in picked_candidates)
			var/mob/dead/observer/M = i
			members += M
			create_member(M)
	else
		message_admins("ERROR: No picked candidates, aborting.")
		return


	message_admins("Distress beacon: [name] finished spawning.")

	candidates = list() //Blank out the candidates list for next time.


/datum/emergency_call/proc/add_candidate(mob/M)
	if(!M.client)
		return FALSE  //Not connected

	if(M in candidates)
		return FALSE  //Already there.

	if(M.stat != DEAD)
		return FALSE  //Alive, could have been drafted into xenos or something else.

	if(!M.mind) //They don't have a mind
		return FALSE

	candidates += M
	return TRUE

/obj/effect/landmark/ertspawn

/datum/emergency_call/proc/get_spawn_point(is_for_items)
	var/obj/effect/landmark/ertspawn/O = locate() in landmarks_list
	if(O)
		return get_turf(O)


/datum/emergency_call/proc/create_member(mob/dead/observer/M) //Overriden in each distress call file.
	return

/datum/emergency_call/proc/print_backstory(mob/living/carbon/human/M)
	return
