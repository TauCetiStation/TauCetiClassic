#define MAX_OPS 6
#define MIN_OPS 2
/datum/faction/nuclear
	name = SYNDIOPS
	ID = SYNDIOPS
	logo_state = "nuke-logo"

	required_pref = ROLE_OPERATIVE

	initial_role = NUKE_OP
	late_role = NUKE_OP
	initroletype = /datum/role/syndicate/operative

	max_roles = 6

	var/nukes_left = TRUE // Call 3714-PRAY right now and order more nukes! Limited offer!
	var/nuke_off_station = 0 //Used for tracking if the syndies actually haul the nuke to the station
	var/syndies_didnt_escape = 0 //Used for tracking if the syndies got the shuttle off of the z-level

	var/leader_created = FALSE
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
		dat += "in [disk_loc.loc] at ([disk_loc.x], [disk_loc.y], [disk_loc.z])"
	return dat

/datum/faction/nuclear/get_initrole_type()
	if(!leader_created)
		leader_created = TRUE
		return /datum/role/syndicate/operative/leader
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
		if(istype(role, /datum/role/syndicate/operative/leader))
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
		if (!istype(role.antag.current,/mob/living/carbon/human))
			if(role.antag.current)
				if(role.antag.current.stat != DEAD)
					return FALSE
	return TRUE

/datum/faction/nuclear/custom_result()
	var/disk_rescued = 1
	for(var/obj/item/weapon/disk/nuclear/D in poi_list)
		var/disk_area = get_area(D)
		if(!is_type_in_typecache(disk_area, centcom_areas_typecache))
			disk_rescued = 0
			break

	var/dat = ""
	var/crew_evacuated = (SSshuttle.location==2)
	if      (!disk_rescued &&  SSticker.station_was_nuked &&          !syndies_didnt_escape)
		dat += "<span style='font-color: red; font-weight: bold;'>Syndicate Major Victory!</span>"
		dat += "<br><b>Gorlex Maradeurs operatives have destroyed [station_name()]!</b>"
		score["roleswon"]++

	else if (!disk_rescued &&  SSticker.station_was_nuked &&           syndies_didnt_escape)
		dat += "<span style='font-color: red; font-weight: bold;'>Total Annihilation</span>"
		dat += "<br><b>Gorlex Maradeurs operatives destroyed [station_name()] but did not leave the area in time and got caught in the explosion.</b> Next time, don't lose the disk!"

	else if (!disk_rescued && !SSticker.station_was_nuked &&  nuke_off_station && !syndies_didnt_escape)
		dat += "<span style='font-color: red; font-weight: bold;'>Crew Minor Victory</span>"
		dat += "<br><b>Gorlex Maradeurs operatives secured the authentication disk but blew up something that wasn't [station_name()].</b> Next time, don't lose the disk!"

	else if (!disk_rescued && !SSticker.station_was_nuked &&  nuke_off_station &&  syndies_didnt_escape)
		dat += "<span style='font-color: red; font-weight: bold;'>Gorlex Maradeurs span earned Darwin Award!</span>"
		dat += "<br><b>Gorlex Maradeurs operatives blew up something that wasn't [station_name()] and got caught in the explosion.</b> Next time, don't lose the disk!"

	else if ( disk_rescued                                         && is_operatives_are_dead())
		dat += "<span style='font-color: red; font-weight: bold;'>Crew Major Victory!</span>"
		dat += "<br><b>The Research Staff has saved the disc and killed the Gorlex Maradeurs Operatives</b>"

	else if ( disk_rescued                                        )
		dat += "<span style='font-color: red; font-weight: bold;'>Crew Major Victory</span>"
		dat += "<br><b>The Research Staff has saved the disc and stopped the Gorlex Maradeurs Operatives!</b>"

	else if (!disk_rescued                                         && is_operatives_are_dead())
		dat += "<span style='font-color: red; font-weight: bold;'>Syndicate Minor Victory!</span>"
		dat += "<br><b>The Research Staff failed to secure the authentication disk but did manage to kill most of the Gorlex Maradeurs Operatives!</b>"

	else if (!disk_rescued                                         &&  crew_evacuated)
		dat += "<span style='font-color: red; font-weight: bold;'>Syndicate Minor Victory!</span>"
		dat += "<br><b>Gorlex Maradeurs operatives recovered the abandoned authentication disk but detonation of [station_name()] was averted.</b> Next time, don't lose the disk!"

	else if (!disk_rescued                                         && !crew_evacuated)
		dat += "<span style='font-color: red; font-weight: bold;'>Neutral Victory</span>"
		dat += "<br><b>Round was mysteriously interrupted!</b>"

	return dat

/datum/faction/nuclear/GetScoreboard()
	var/dat = ..()
	if(faction_scoreboard_data)
		dat += "<BR>The operatives bought:<BR>"
		for(var/entry in faction_scoreboard_data)
			dat += "[entry]<BR>"
	return dat

#undef MAX_OPS
#undef MIN_OPS
