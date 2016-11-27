/*

Infestation:

*/



/*
	GAMEMODE
*/
/datum/game_mode/var/list/datum/mind/xenomorphs = list()

/datum/game_mode/infestation
	name = "infestation"
	config_tag = "infestation"
	role_type = ROLE_ALIEN
	required_players = 20
	required_players_secret = 15
	required_enemies = 2
	recommended_enemies = 4

	votable = 0

/datum/game_mode/infestation/announce()
	to_chat(world, "<b>The current game mode is - Infestation!</b>")
	to_chat(world, "<b>There are <span class='userdanger'>xenomorphs</span> on the station. Crew: Kill the xenomorphs before they infest the station. Xenomorphs: Go catch some living hamburgers.</b>")

/datum/game_mode/infestation/can_start()
	if(!..())
		return 0

	var/xenomorphs_num = 0

	//Check that we have enough vox.
	if(antag_candidates.len < required_enemies)
		return 0
	else if(antag_candidates.len < recommended_enemies)
		xenomorphs_num = antag_candidates.len
	else
		xenomorphs_num = recommended_enemies

	while(xenomorphs_num > 0)
		var/datum/mind/new_xeno = pick(antag_candidates)
		xenomorphs += new_xeno
		antag_candidates -= new_xeno
		xenomorphs_num--

	for(var/datum/mind/xeno in xenomorphs)
		xeno.assigned_role = "MODE"
		xeno.special_role = "Xenomorph"

	//Build a list of spawn points.

	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "xeno_spawn")
			xeno_spawn.Add(L)

	if(xeno_spawn.len == 0)
		return 0

	return 1

/datum/game_mode/infestation/pre_setup()
	return 1

/datum/game_mode/infestation/post_setup()
	for(var/check_spawn in xeno_spawn)
		var/turf/T = get_turf(check_spawn)
		if(T.loc.name == "Construction Area")
			xeno_spawn -= check_spawn
		if(T.loc.name == "Technical Storage")
			xeno_spawn -= check_spawn

	for(var/datum/mind/xeno in xenomorphs)
		var/start_point = pick(xeno_spawn)
		xeno_spawn -= start_point
		var/area/A = get_area(start_point)

		for(var/obj/machinery/power/apc/apc in A.apc)
			apc.overload_lighting()

		var/mob/living/carbon/alien/facehugger/FH = new /mob/living/carbon/alien/facehugger(get_turf(start_point))
		var/mob/original = xeno.current

		xeno.transfer_to(FH)

		greet_xeno(xeno)
		qdel(original)
	return ..()

/datum/game_mode/infestation/proc/greet_xeno(datum/mind/xeno)
	to_chat(xeno.current, "\green <B>You are a Xenomorph.</b>")
	to_chat(xeno.current, "\green <B>Your current alien form is a facehugger.</b>")
	to_chat(xeno.current, "\green <B>Go find some monkeys, corgi or a sleeping human.</b>")
	to_chat(xeno.current, "\green <B>To leap at someones face, you simply start with left mouse button click.</b>")
	to_chat(xeno.current, "\green <B>Then check your tail action button, there will be leap available.</b>")
	to_chat(xeno.current, "\green <B>Leap isnt instant, keep that in mind. There is 1-2 seconds delay, before you can actually leap.</b>")
	to_chat(xeno.current, "\green <B>You target also must be near, after you prepares to leap.</b>")
	to_chat(xeno.current, "\blue Use :A to hivetalk.")
	to_chat(xeno.current, "\green ------------------")
	//xeno.current << "\red IF YOU HAVE NOT PLAYED A XENOMORPH, REVIEW THIS THREAD: http://tauceti.ru"


/*
	GAME FINISH CHECKS
*/

/datum/game_mode/proc/check_xeno_queen()
	var/state = 0 // 0 = no queen
	for(var/mob/living/carbon/alien/humanoid/queen/alive in living_mob_list)
		if(alive)
			state = 1
	if(!state)
		for(var/mob/living/carbon/alien/humanoid/queen/dead in dead_mob_list)
			if(dead)
				state = 2
	return state

/datum/game_mode/proc/count_hive_power()
	var/count = 0
	for(var/mob/living/carbon/alien/alive in living_mob_list)
		if(alive)
			count++
	return count

/datum/game_mode/proc/count_hive_looses()
	var/count = 0
	for(var/mob/living/carbon/alien/dead in dead_mob_list)
		if(dead)
			count++
	return count

/datum/game_mode/proc/auto_declare_completion_infestation()
	var/text =""
	if(xenomorphs.len)
		if(check_xeno_queen())
			if(check_xeno_queen() == 1)
				text += "<font size=3 color=green><b>The Queen is alive!</FONT></b></span>"
			if(check_xeno_queen() == 2)
				text += "<span class='danger'><font size=3><b>The Queen has been killed!</b></FONT></span>"
		else
			text += "<font size=3 color=blue><b>The Queen was never born.</FONT></b></span>"
		if(count_hive_power())
			text += "<font size=3 color=green><b>There is [count_hive_power()] xenomorphs alive!</FONT></b></span>"
		else
			text += "<span class='danger'><font size=3><b>All xenomorphs were eradicated.</b></FONT></span>"
		if(count_hive_looses())
			text += "<span class='danger'><font size=3><b>[count_hive_looses()] xenomorphs are dead.</b></FONT></span>"
	return text
