/datum/game_mode
	var/list/datum/mind/syndicates = list()
	var/obj/nuclear_uplink


/datum/game_mode/nuclear
	name = "nuclear emergency"
	config_tag = "nuclear"
	role_type = ROLE_OPERATIVE
	required_players = 15
	required_players_bundles = 25
	required_enemies = 2
	recommended_enemies = 6
	antag_hud_type = ANTAG_HUD_OPS
	antag_hud_name = "hudsyndicate"

	votable = 0

	uplink_welcome = "Corporate Backed Uplink Console:"
	uplink_uses = 20

	var/nukes_left = 1 // Call 3714-PRAY right now and order more nukes! Limited offer!
	var/nuke_off_station = 0 //Used for tracking if the syndies actually haul the nuke to the station
	var/syndies_didnt_escape = 0 //Used for tracking if the syndies got the shuttle off of the z-level


/datum/game_mode/nuclear/announce()
	to_chat(world, "<B>The current game mode is - Nuclear Emergency!</B>")
	to_chat(world, "<B>Gorlex Maradeurs are approaching [station_name()]!</B>")
	to_chat(world, "A nuclear explosive was being transported by Nanotrasen to a military base. The transport ship mysteriously lost contact with Space Traffic Control (STC). About that time a strange disk was discovered around [station_name()]. It was identified by Nanotrasen as a nuclear auth. disk and now Syndicate Operatives have arrived to retake the disk and detonate SS13! Also, most likely Syndicate star ships are in the vicinity so take care not to lose the disk!\n<B>Syndicate</B>: Reclaim the disk and detonate the nuclear bomb anywhere on SS13.\n<B>Personnel</B>: Hold the disk and <B>escape with the disk</B> on the shuttle!")

/datum/game_mode/nuclear/can_start()
	if (!..())
		return FALSE
	// Looking for map to nuclear spawn points
	var/spwn_synd = FALSE
	var/spwn_comm = FALSE
	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "Syndicate-Commander")
			spwn_comm = TRUE
		else if (A.name == "Syndicate-Spawn")
			spwn_synd = TRUE
		if (spwn_synd && spwn_comm)
			return TRUE
	return FALSE

/datum/game_mode/nuclear/assign_outsider_antag_roles()
	if(!..())
		return FALSE
	var/agent_number = 0

	//Antag number should scale to active crew.
	var/n_players = num_players()
	agent_number = clamp((n_players/5), required_enemies, recommended_enemies)

	if(antag_candidates.len < agent_number)
		agent_number = antag_candidates.len

	while(agent_number > 0)
		var/datum/mind/new_syndicate = pick(antag_candidates)
		syndicates += new_syndicate
		antag_candidates -= new_syndicate //So it doesn't pick the same guy each time.
		agent_number--

	for(var/datum/mind/synd_mind in syndicates)
		synd_mind.assigned_role = "MODE" //So they aren't chosen for other jobs.
		synd_mind.special_role = "Syndicate"//So they actually have a special role/N
	//	log_game("[synd_mind.key] with age [synd_mind.current.client.player_age] has been selected as a nuclear operative")
	//	message_admins("[synd_mind.key] with age [synd_mind.current.client.player_age] has been selected as a nuclear operative",0,1)
	return TRUE

/datum/game_mode/nuclear/pre_setup()
	return 1


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/nuclear/post_setup()

	var/list/turf/synd_spawn = list()
	var/turf/synd_comm_spawn

	for(var/obj/effect/landmark/A in landmarks_list) //Add commander spawn places first, really should only be one though.
		if(A.name == "Syndicate-Commander")
			synd_comm_spawn = get_turf(A)
			qdel(A)
			continue

	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "Syndicate-Spawn")
			synd_spawn += get_turf(A)
			qdel(A)
			continue

	var/obj/effect/landmark/uplinklocker = locate("landmark*Syndicate-Uplink")	//i will be rewriting this shortly
	var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")

	var/nuke_code = "[rand(10000, 99999)]"
	var/leader_selected = 0
	var/spawnpos = 1
//	var/max_age = 0
/*	for(var/datum/mind/synd_mind in syndicates)
		if(isnum(synd_mind.current.client.player_age))
			if(max_age<synd_mind.current.client.player_age)
				max_age = synd_mind.current.client.player_age */

	for(var/datum/mind/synd_mind in syndicates)
		log_debug("Starting cycle - Ckey:[synd_mind.key] - [synd_mind]")
		synd_mind.current.faction = "syndicate"
		synd_mind.current.real_name = "Gorlex Maradeurs Operative" // placeholder while we get their actual name
		log_debug("Leader status [leader_selected]")
		if(!leader_selected)
			log_debug("Leader - [synd_mind]")
			synd_mind.current.loc = synd_comm_spawn
			equip_syndicate(synd_mind.current, 1)
			prepare_syndicate_leader(synd_mind, nuke_code)
			leader_selected = 1
			greet_syndicate(synd_mind, 0, 1)
		else
			log_debug("[synd_mind] - not a leader")
			greet_syndicate(synd_mind)
			equip_syndicate(synd_mind.current)
			if(spawnpos > synd_spawn.len)
				spawnpos = 1
			log_debug("[synd_mind] telepoting to [synd_spawn[spawnpos]]")
			synd_mind.current.loc = synd_spawn[spawnpos]

		spawn(0)
			NukeNameAssign(synd_mind)

		if(!config.objectives_disabled)
			forge_syndicate_objectives(synd_mind)

		spawnpos++

	if(uplinklocker)
		var/obj/structure/closet/C = new /obj/structure/closet/syndicate/nuclear(uplinklocker.loc)
		spawn(10) //gives time for the contents to spawn properly
			for(var/obj/item/thing in C)
				if(thing.hidden_uplink)
					nuclear_uplink = thing
					break
	if(nuke_spawn)
		var/obj/machinery/nuclearbomb/the_bomb = new /obj/machinery/nuclearbomb(nuke_spawn.loc)
		the_bomb.r_code = nuke_code

	return ..()

/datum/game_mode/proc/prepare_syndicate_leader(datum/mind/synd_mind, nuke_code)
	if (nuke_code)
		synd_mind.store_memory("<B>Syndicate Nuclear Bomb Code</B>: [nuke_code]", 0)
		to_chat(synd_mind.current, "The nuclear authorization code is: <B>[nuke_code]</B>")
		var/obj/item/weapon/paper/P = new
		P.info = "The nuclear authorization code is: <b>[nuke_code]</b>"
		P.name = "nuclear bomb code"
		P.update_icon()
		if (SSticker.mode.config_tag=="nuclear")
			P.loc = synd_mind.current.loc
		else
			var/mob/living/carbon/human/H = synd_mind.current
			P.loc = H.loc
			H.equip_to_slot_or_del(P, SLOT_R_STORE, 0)
			H.update_icons()

	else
		nuke_code = "code will be provided later"
	return


/datum/game_mode/proc/forge_syndicate_objectives(datum/mind/syndicate)
	if (config.objectives_disabled)
		return
	var/datum/objective/nuclear/syndobj = new
	syndobj.owner = syndicate
	syndicate.objectives += syndobj


/datum/game_mode/proc/greet_syndicate(datum/mind/syndicate, you_are=1, boss=0)
	add_antag_hud(ANTAG_HUD_OPS, "hudsyndicate", syndicate.current)
	if (you_are)
		to_chat(syndicate.current, "<span class = 'info'>You are a <font color='red'>Gorlex Maradeurs agent</font>!</span>")
	if(boss)
		to_chat(syndicate.current, "<span class = 'info'>You are a <font color='red'>Gorlex Maradeurs Commander</font>!</span>")
	var/obj_count = 1
	syndicate.current.playsound_local(null, 'sound/antag/ops.ogg', VOL_EFFECTS_MASTER, null, FALSE)

	if(!config.objectives_disabled)
		for(var/datum/objective/objective in syndicate.objectives)
			to_chat(syndicate.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++
	else
		to_chat(syndicate.current, "<font color=blue>Within the rules,</font> try to act as an opposing force to the crew. Further RP and try to make sure other players have fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>")
	return

/datum/game_mode/proc/remove_nuclear(mob/M)
	syndicates -= M
	M.mind.special_role = null
	remove_antag_hud(ANTAG_HUD_OPS, M)
	M.mind.remove_objectives()
	M.mind.current.faction = "neutral"

/datum/game_mode/proc/random_radio_frequency()
	return 1337 // WHY??? -- Doohl


/datum/game_mode/proc/equip_syndicate(mob/living/carbon/human/synd_mob, boss)
	var/nuclear_outfit = /datum/outfit/nuclear
	if(boss)
		nuclear_outfit = /datum/outfit/nuclear/leader
	synd_mob.equipOutfit(nuclear_outfit)

	synd_mob.add_language("Sy-Code")
	return 1


/datum/game_mode/nuclear/check_win()
	if (nukes_left == 0)
		return 1
	return ..()


/datum/game_mode/proc/is_operatives_are_dead()
	for(var/datum/mind/operative_mind in syndicates)
		if (!istype(operative_mind.current,/mob/living/carbon/human))
			if(operative_mind.current)
				if(operative_mind.current.stat!=2)
					return 0
	return 1

/datum/game_mode/nuclear/declare_completion()
	if(config.objectives_disabled)
		return
	var/disk_rescued = 1
	for(var/obj/item/weapon/disk/nuclear/D in poi_list)
		var/disk_area = get_area(D)
		if(!is_type_in_typecache(disk_area, centcom_areas_typecache))
			disk_rescued = 0
			break
	var/crew_evacuated = (SSshuttle.location==2)
	//var/operatives_are_dead = is_operatives_are_dead()


	//nukes_left
	//station_was_nuked
	//derp //Used for tracking if the syndies actually haul the nuke to the station	//no
	//herp //Used for tracking if the syndies got the shuttle off of the z-level	//NO, DON'T FUCKING NAME VARS LIKE THIS

	if      (!disk_rescued &&  station_was_nuked &&          !syndies_didnt_escape)
		mode_result = "win - syndicate nuke"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: red; font-weight: bold;'>Syndicate Major Victory!</span>"
		completion_text += "<br><b>Gorlex Maradeurs operatives have destroyed [station_name()]!</b>"
		score["roleswon"]++

	else if (!disk_rescued &&  station_was_nuked &&           syndies_didnt_escape)
		mode_result = "halfwin - syndicate nuke - did not evacuate in time"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: red; font-weight: bold;'>Total Annihilation</span>"
		completion_text += "<br><b>Gorlex Maradeurs operatives destroyed [station_name()] but did not leave the area in time and got caught in the explosion.</b> Next time, don't lose the disk!"

	else if (!disk_rescued && !station_was_nuked &&  nuke_off_station && !syndies_didnt_escape)
		mode_result = "halfwin - blew wrong station"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: red; font-weight: bold;'>Crew Minor Victory</span>"
		completion_text += "<br><b>Gorlex Maradeurs operatives secured the authentication disk but blew up something that wasn't [station_name()].</b> Next time, don't lose the disk!"

	else if (!disk_rescued && !station_was_nuked &&  nuke_off_station &&  syndies_didnt_escape)
		mode_result = "halfwin - blew wrong station - did not evacuate in time"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: red; font-weight: bold;'>Gorlex Maradeurs span earned Darwin Award!</span>"
		completion_text += "<br><b>Gorlex Maradeurs operatives blew up something that wasn't [station_name()] and got caught in the explosion.</b> Next time, don't lose the disk!"

	else if ( disk_rescued                                         && is_operatives_are_dead())
		mode_result = "loss - evacuation - disk secured - syndi team dead"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: red; font-weight: bold;'>Crew Major Victory!</span>"
		completion_text += "<br><b>The Research Staff has saved the disc and killed the Gorlex Maradeurs Operatives</b>"

	else if ( disk_rescued                                        )
		mode_result = "loss - evacuation - disk secured"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: red; font-weight: bold;'>Crew Major Victory</span>"
		completion_text += "<br><b>The Research Staff has saved the disc and stopped the Gorlex Maradeurs Operatives!</b>"

	else if (!disk_rescued                                         && is_operatives_are_dead())
		mode_result = "loss - evacuation - disk not secured"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: red; font-weight: bold;'>Syndicate Minor Victory!</span>"
		completion_text += "<br><b>The Research Staff failed to secure the authentication disk but did manage to kill most of the Gorlex Maradeurs Operatives!</b>"

	else if (!disk_rescued                                         &&  crew_evacuated)
		mode_result = "halfwin - detonation averted"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: red; font-weight: bold;'>Syndicate Minor Victory!</span>"
		completion_text += "<br><b>Gorlex Maradeurs operatives recovered the abandoned authentication disk but detonation of [station_name()] was averted.</b> Next time, don't lose the disk!"

	else if (!disk_rescued                                         && !crew_evacuated)
		mode_result = "halfwin - interrupted"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='font-color: red; font-weight: bold;'>Neutral Victory</span>"
		completion_text += "<br><b>Round was mysteriously interrupted!</b>"

	..()
	return 1

/datum/game_mode/nuclear/modestat()
	var/dat = ""
	var/foecount = 0
	var/crewcount = 0
	var/diskdat = ""
	var/bombdat = null
	var/datum/game_mode/nuclear/GM = SSticker.mode
	for(var/datum/mind/M in GM.syndicates)
		foecount++
	for(var/mob/living/C in alive_mob_list)
		if (!istype(C,/mob/living/carbon/human) || !istype(C,/mob/living/silicon/robot) || !istype(C,/mob/living/silicon/ai))
			continue
		if (!C.client)
			continue
		crewcount++

	for(var/obj/item/weapon/disk/nuclear/N in poi_list)
		if(!N)
			continue
		var/atom/disk_loc = N.loc
		while(!istype(disk_loc, /turf))
			if(istype(disk_loc, /mob))
				var/mob/M = disk_loc
				diskdat += "Carried by [M.real_name] "
			if(istype(disk_loc, /obj))
				var/obj/O = disk_loc
				diskdat += "in \a [O.name] "
			disk_loc = disk_loc.loc
		diskdat += "in [disk_loc.loc]"
		break // Should only need one go-round, probably
	var/nukedpenalty = 0
	for(var/obj/machinery/nuclearbomb/NUKE in poi_list)
		//if (NUKE.r_code == "Nope") continue
		if (NUKE.detonated == 0)
			continue
		var/turf/T = NUKE.loc
		bombdat = T.loc
		if (istype(T,/area/shuttle/syndicate) || istype(T,/area/custom/wizard_station) || istype(T,/area/station/solar))
			nukedpenalty = 1000
		else if (istype(T,/area/station/security/main) || istype(T,/area/station/security/brig) || istype(T,/area/station/security/armoury) || istype(T,/area/station/security/checkpoint))
			nukedpenalty = 50000
		else if (istype(T,/area/station/engineering))
			nukedpenalty = 100000
		else
			nukedpenalty = 10000
		break
	if (!diskdat)
		diskdat = "Uh oh. Something has fucked up! Report this."
	dat += {"<B><U>MODE STATS</U></B><BR>
	<B>Number of Operatives:</B> [foecount]<BR>
	<B>Number of Surviving Crew:</B> [crewcount]<BR>
	<B>Final Location of Nuke:</B> [bombdat]<BR>
	<B>Final Location of Disk:</B> [diskdat]<BR><BR>
	<B>Operatives Arrested:</B> [score["arrested"]] ([score["arrested"] * 1000] Points)<BR>
	<B>Operatives Killed:</B> [score["opkilled"]] ([score["opkilled"] * 250] Points)<BR>
	<B>Station Destroyed:</B> [score["nuked"] ? "Yes" : "No"] (-[nukedpenalty] Points)<BR>
	<B>All Operatives Arrested:</B> [score["allarrested"] ? "Yes" : "No"] (Score tripled)<BR>
	<HR>"}
	return dat

/datum/game_mode/proc/auto_declare_completion_nuclear()
	var/text = ""
	if( syndicates.len || (SSticker && istype(SSticker.mode,/datum/game_mode/nuclear)) )
		text += printlogo("nuke", "syndicate operatives")
		for(var/datum/mind/syndicate in syndicates)
			text += printplayerwithicon(syndicate)

		var/obj/item/nuclear_uplink = src:nuclear_uplink
		if(nuclear_uplink && nuclear_uplink.hidden_uplink)
			if(nuclear_uplink.hidden_uplink.purchase_log.len)
				text += "<br><b>The tools used by the syndicate operatives were:</b> "
				for(var/entry in nuclear_uplink.hidden_uplink.purchase_log)
					text += "<br>[entry]TC(s)"
			else
				text += "<br>The nukeops were smooth operators this round (did not purchase any uplink items)."

	if(text)
		antagonists_completion += list(list("mode" = "nuclear", "html" = text))
		text = "<div class='Section'>[text]</div>"

	return text

/proc/NukeNameAssign(datum/mind/synd_mind)
	var/choose_name = sanitize_safe(input(synd_mind.current, "You are a Gorlex Maradeurs agent! What is your name?", "Choose a name") as text, MAX_NAME_LEN)

	if(!choose_name)
		return

	else
		synd_mind.current.name = choose_name
		synd_mind.current.real_name = choose_name
		return
