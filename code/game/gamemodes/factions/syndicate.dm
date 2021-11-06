#define MAX_OPS 6
#define MIN_OPS 2
/datum/faction/nuclear
	name = F_SYNDIOPS
	ID = F_SYNDIOPS
	logo_state = "nuke-logo"
	required_pref = ROLE_OPERATIVE

	initroletype = /datum/role/operative

	min_roles = 2
	max_roles = 6

	var/nukes_left = TRUE // Call 3714-PRAY right now and order more nukes! Limited offer!
	var/nuke_off_station = 0 //Used for tracking if the syndies actually haul the nuke to the station
	var/syndies_didnt_escape = 0 //Used for tracking if the syndies got the shuttle off of the z-level

	var/nuke_code

/datum/faction/nuclear/AdminPanelEntry()
	var/dat = ..()
	var/obj/item/weapon/disk/nuclear/nukedisk
	for(var/obj/item/weapon/disk/nuclear/N in poi_list)
		if(!N)
			continue
		nukedisk = N
		break

	dat += "<br><h2>Nuclear disk</h2>"
	if(!nukedisk)
		dat += "There's no nuke disk. Panic?<br>"
	else if(isnull(nukedisk.loc))
		dat += "The nuke disk is in nullspace. Panic."
	else
		dat += "[nukedisk.name]"
		var/atom/disk_loc = nukedisk.loc
		while(!istype(disk_loc, /turf))
			if(istype(disk_loc, /mob))
				var/mob/M = disk_loc
				dat += "carried by <a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a> "
			if(istype(disk_loc, /obj))
				var/obj/O = disk_loc
				dat += "in \a [O.name] "
			disk_loc = disk_loc.loc
		dat += "in [disk_loc.loc] at [COORD(disk_loc)]"
	return dat

/datum/faction/nuclear/get_initrole_type()
	if(!leader)
		return /datum/role/operative/leader
	return ..()

/datum/faction/nuclear/can_setup(num_players)
	if (!..())
		return FALSE

	max_roles = clamp((num_players/5), MIN_OPS, MAX_OPS)

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

/datum/faction/nuclear/HandleNewMind(datum/mind/M)
	. = ..()
	if(.)
		var/datum/role/R = locate(/datum/role/operative/leader) in members
		if(R)
			leader = R

/datum/faction/nuclear/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/nuclear)
	return TRUE

/datum/faction/nuclear/OnPostSetup()
	var/list/turf/synd_spawn = list()
	var/turf/synd_comm_spawn

	for(var/obj/effect/landmark/A in landmarks_list) //Add commander spawn places first, really should only be one though.
		if(A.name == "Syndicate-Commander")
			synd_comm_spawn = get_turf(A)
			qdel(A)
			break

	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "Syndicate-Spawn")
			synd_spawn += get_turf(A)
			qdel(A)

	var/obj/effect/landmark/uplinklocker = locate("landmark*Syndicate-Uplink")	//i will be rewriting this shortly
	var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")

	nuke_code = "[rand(10000, 99999)]"
	var/spawnpos = 1

	for(var/datum/role/role in members)
		if(istype(role, /datum/role/operative/leader))
			role.antag.current.forceMove(synd_comm_spawn)
		else
			if(spawnpos > synd_spawn.len)
				spawnpos = 1
			role.antag.current.forceMove(synd_spawn[spawnpos])

		spawnpos++

	if(uplinklocker)
		new /obj/structure/closet/syndicate/nuclear(uplinklocker.loc)

	if(nuke_spawn)
		var/obj/machinery/nuclearbomb/the_bomb = new /obj/machinery/nuclearbomb(nuke_spawn.loc)
		the_bomb.r_code = nuke_code

	return ..()

/datum/faction/nuclear/check_win()
	if (!nukes_left)
		return TRUE
	return FALSE

/datum/faction/nuclear/proc/is_operatives_are_dead()
	for(var/datum/role/role in members)
		if (!ishuman(role.antag.current))
			if(role.antag.current?.stat != DEAD)
				return FALSE
	return TRUE

/datum/faction/nuclear/custom_result()
	var/disk_rescued = TRUE
	for(var/obj/item/weapon/disk/nuclear/D in poi_list)
		var/disk_area = get_area(D)
		if(!is_type_in_typecache(disk_area, centcom_areas_typecache))
			disk_rescued = FALSE
			break

	var/dat = ""
	var/crew_evacuated = (SSshuttle.location == SHUTTLE_AT_CENTCOM)
	if      (!disk_rescued &&  SSticker.station_was_nuked &&          !syndies_didnt_escape)
		dat += "<span class='red'>Syndicate Major Victory!</span>"
		dat += "<br><b>Gorlex Maradeurs operatives have destroyed [station_name()]!</b>"
		score["roleswon"]++
		feedback_add_details("[ID]_success","SUCCESS")

	else if (!disk_rescued &&  SSticker.station_was_nuked &&           syndies_didnt_escape)
		dat += "<span class='red'>Total Annihilation</span>"
		dat += "<br><b>Gorlex Maradeurs operatives destroyed [station_name()] but did not leave the area in time and got caught in the explosion.</b> Next time, don't lose the disk!"
		feedback_add_details("[ID]_success","HALF")

	else if (!disk_rescued && !SSticker.station_was_nuked &&  nuke_off_station && !syndies_didnt_escape)
		dat += "<span class='red'>Crew Minor Victory</span>"
		dat += "<br><b>Gorlex Maradeurs operatives secured the authentication disk but blew up something that wasn't [station_name()].</b> Next time, don't lose the disk!"
		feedback_add_details("[ID]_success","HALF")

	else if (!disk_rescued && !SSticker.station_was_nuked &&  nuke_off_station &&  syndies_didnt_escape)
		dat += "<span class='red'>Gorlex Maradeurs span earned Darwin Award!</span>"
		dat += "<br><b>Gorlex Maradeurs operatives blew up something that wasn't [station_name()] and got caught in the explosion.</b> Next time, don't lose the disk!"
		feedback_add_details("[ID]_success","HALF")

	else if ( disk_rescued                                         && is_operatives_are_dead())
		dat += "<span class='red'>Crew Major Victory!</span>"
		dat += "<br><b>The Research Staff has saved the disc and killed the Gorlex Maradeurs Operatives</b>"
		feedback_add_details("[ID]_success","FAIL")

	else if ( disk_rescued                                        )
		dat += "<span class='red'>Crew Major Victory</span>"
		dat += "<br><b>The Research Staff has saved the disc and stopped the Gorlex Maradeurs Operatives!</b>"
		feedback_add_details("[ID]_success","FAIL")

	else if (!disk_rescued                                         && is_operatives_are_dead())
		dat += "<span class='red'>Syndicate Minor Victory!</span>"
		dat += "<br><b>The Research Staff failed to secure the authentication disk but did manage to kill most of the Gorlex Maradeurs Operatives!</b>"
		feedback_add_details("[ID]_success","HALF")

	else if (!disk_rescued                                         &&  crew_evacuated)
		dat += "<span class='red'>Syndicate Minor Victory!</span>"
		dat += "<br><b>Gorlex Maradeurs operatives recovered the abandoned authentication disk but detonation of [station_name()] was averted.</b> Next time, don't lose the disk!"
		feedback_add_details("[ID]_success","HALF")

	else if (!disk_rescued                                         && !crew_evacuated)
		dat += "<span class='red'>Neutral Victory</span>"
		dat += "<br><b>Round was mysteriously interrupted!</b>"
		feedback_add_details("[ID]_success","HALF")

	return dat

/datum/faction/nuclear/GetScoreboard()
	var/dat = ..()
	if(faction_scoreboard_data)
		dat += "The operatives bought:"
		for(var/entry in faction_scoreboard_data)
			dat += "<br>[entry]"
		dat += "<br>"
	return dat

/datum/faction/nuclear/proc/get_nukedpenalty()
	var/nukedpenalty = 1000
	for (var/obj/machinery/nuclearbomb/NUKE in poi_list)
		if (NUKE.detonated == 0)
			continue
		var/turf/T = NUKE.loc
		if (istype(T,/area/shuttle/syndicate) || istype(T,/area/custom/wizard_station) || istype(T,/area/station/solar))
			nukedpenalty = 1000
		else if (istype(T,/area/station/security/main) || istype(T,/area/station/security/brig) || istype(T,/area/station/security/armoury) || istype(T,/area/station/security/checkpoint))
			nukedpenalty = 50000
		else if (istype(T,/area/station/engineering))
			nukedpenalty = 100000
		else
			nukedpenalty = 10000

		return nukedpenalty
	return 0

/datum/faction/nuclear/build_scorestat()
	var/foecount = 0
	var/nukedpenalty = 1000
	for(var/datum/role/role in members)
		foecount++
		if (!role.antag || !role.antag.current)
			score["opkilled"]++
			continue
		var/turf/T = role.antag.current.loc
		if (T && istype(T.loc, /area/station/security/brig))
			score["arrested"] += 1
		else if (role.antag.current.stat == DEAD)
			score["opkilled"]++
	if(foecount == score["arrested"])
		score["allarrested"] = 1

	if (score["nuked"])
		nukedpenalty = get_nukedpenalty()
		if(score["disc"])
			score["crewscore"] += 500

	var/killpoints = score["opkilled"] * 250
	var/arrestpoints = score["arrested"] * 1000
	score["crewscore"] += killpoints
	score["crewscore"] += arrestpoints
	if (score["nuked"])
		score["crewscore"] -= nukedpenalty

/datum/faction/nuclear/get_scorestat()
	var/dat = ""

	var/foecount = members.len
	var/crewcount = 0
	var/diskdat = ""
	var/bombdat = "Unknown"
	for(var/mob/living/C in alive_mob_list)
		if (!C.client || C.stat != DEAD)
			continue
		if(!ishuman(C) || !issilicon(C))
			continue
		crewcount++

	for (var/obj/machinery/nuclearbomb/NUKE in poi_list)
		if (NUKE.detonated == 0)
			continue
		bombdat = NUKE.loc
		break

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
		break

	var/nukedpenalty = get_nukedpenalty()
	if (!diskdat)
		diskdat = "Uh oh. Something has fucked up! Report this."

	dat += {"<B><U>NUKE STATS</U></B><BR>
	<B>Number of Operatives:</B> [foecount]<BR>
	<B>Number of Surviving Crew:</B> [crewcount]<BR>
	<B>Final Location of Nuke:</B> [bombdat]<BR>
	<B>Final Location of Disk:</B> [diskdat]<BR><BR>
	<B>Operatives Arrested:</B> [score["arrested"]] ([score["arrested"] * 1000] Points)<BR>
	<B>Operatives Killed:</B> [score["opkilled"]] ([score["opkilled"] * 250] Points)<BR>
	<B>Station Destroyed:</B> [score["nuked"] ? "Yes" : "No"] (-[nukedpenalty] Points)<BR>
	<B>All Operatives Arrested:</B> [score["allarrested"] ? "Yes" : "No"] (Score tripled)<BR>"}

	return dat

#undef MAX_OPS
#undef MIN_OPS
