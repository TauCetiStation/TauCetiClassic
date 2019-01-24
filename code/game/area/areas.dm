// Areas.dm



// ===
/area
	level = null
	name = "Space"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = 10
	mouse_opacity = 0

	var/global/global_uid = 0
	var/uid

	var/parallax_movedir = 0

	var/fire = null
	var/atmos = 1
	var/atmosalm = 0
	var/poweralm = 1
	var/party = null
	var/lightswitch = 1
	var/valid_territory = 1 //If it's a valid territory for gangs to claim

	var/eject = null

	var/debug = 0
	var/powerupdate = 10	//We give everything 10 ticks to settle out it's power usage.
	var/requires_power = 1
	var/always_unpowered = 0	//this gets overriden to 1 for space in area/New()

	var/power_equip = 1
	var/power_light = 1
	var/power_environ = 1
	var/music = null
	var/used_equip = 0
	var/used_light = 0
	var/used_environ = 0
	var/static_equip
	var/static_light = 0
	var/static_environ

	var/has_gravity = 1
	var/obj/machinery/power/apc/apc = null
	var/no_air = null
	var/area/master				// master area used for power calcluations
								// (original area before splitting due to sd_DAL)
	var/list/related			// the other areas of the same type as this
	var/list/all_doors = list()		//Added by Strumpetplaya - Alarm Change - Contains a list of doors adjacent to this area
	var/air_doors_activated = 0


/*Adding a wizard area teleport list because motherfucking lag -- Urist*/
/*I am far too lazy to make it a proper list of areas so I'll just make it run the usual telepot routine at the start of the game*/
var/list/teleportlocs = list()

/proc/process_teleport_locs()
	for(var/area/AR in all_areas)
		if(istype(AR, /area/shuttle) || istype(AR, /area/syndicate_station) || istype(AR, /area/wizard_station) || istype(AR, /area/engine/singularity))
			continue
		if(teleportlocs.Find(AR.name))
			continue
		var/turf/picked = pick(get_area_turfs(AR.type))
		if (picked.z == ZLEVEL_STATION)
			teleportlocs += AR.name
			teleportlocs[AR.name] = AR
	teleportlocs = sortAssoc(teleportlocs)
	return 1


var/list/ghostteleportlocs = list()

/proc/process_ghost_teleport_locs()
	for(var/area/AR in all_areas)
		if(ghostteleportlocs.Find(AR.name))
			continue
		if(istype(AR, /area/turret_protected/aisat) || istype(AR, /area/derelict) || istype(AR, /area/tdome))
			ghostteleportlocs += AR.name
			ghostteleportlocs[AR.name] = AR
		var/turf/picked = pick(get_area_turfs(AR.type))
		if (picked.z == ZLEVEL_STATION || picked.z == ZLEVEL_ASTEROID || picked.z == ZLEVEL_TELECOMMS)
			ghostteleportlocs += AR.name
			ghostteleportlocs[AR.name] = AR
	ghostteleportlocs = sortAssoc(ghostteleportlocs)
	return 1

/area/New() // not ready for transfer, problems with alarms raises if this part moved into init (requires more time)
	icon_state = ""
	layer = 10
	master = src
	uid = ++global_uid
	related = list(src)
	all_areas += src

	if(!requires_power)
		power_light = 0
		power_equip = 0
		power_environ = 0

	..()

/area/atom_init()

	. = ..()

	if(dynamic_lighting)
		luminosity = FALSE

	power_change() // all machines set to current power level, also updates lighting icon


/area/proc/poweralert(state, obj/source)
	if (state != poweralm)
		poweralm = state
		if(istype(source))	//Only report power alarms on the z-level where the source is located.
			var/list/cameras = list()
			for (var/area/RA in related)
				for (var/obj/machinery/camera/C in RA)
					cameras += C
					if(state == 1)
						C.network.Remove("Power Alarms")
					else
						C.network.Add("Power Alarms")
			for (var/mob/living/silicon/aiPlayer in silicon_list)
				if(!aiPlayer.client)
					continue
				if(aiPlayer.z == source.z)
					if (state == 1)
						aiPlayer.cancelAlarm("Power", src, source)
					else
						aiPlayer.triggerAlarm("Power", src, cameras, source)
			for(var/obj/machinery/computer/station_alert/a in station_alert_list)
				if(a.z == source.z)
					if(state == 1)
						a.cancelAlarm("Power", src, source)
					else
						a.triggerAlarm("Power", src, cameras, source)
	return

/area/proc/atmosalert(danger_level)
	//Check all the alarms before lowering atmosalm. Raising is perfectly fine.
	for (var/area/RA in related)
		for (var/obj/machinery/alarm/AA in RA)
			if ( !(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted)
				danger_level = max(danger_level, AA.danger_level)

	if(danger_level != atmosalm)
		if (danger_level < 1 && atmosalm >= 1)
			//closing the doors on red and opening on green provides a bit of hysteresis that will hopefully prevent fire doors from opening and closing repeatedly due to noise
			air_doors_open()

		if (danger_level < 2 && atmosalm >= 2)
			for(var/area/RA in related)
				for(var/obj/machinery/camera/C in RA)
					C.network.Remove("Atmosphere Alarms")
			for(var/mob/living/silicon/aiPlayer in silicon_list)
				if(!aiPlayer.client)
					continue
				aiPlayer.cancelAlarm("Atmosphere", src, src)
			for(var/obj/machinery/computer/station_alert/a in station_alert_list)
				a.cancelAlarm("Atmosphere", src, src)

		if (danger_level >= 2 && atmosalm < 2)
			var/list/cameras = list()
			for(var/area/RA in related)
				for(var/obj/machinery/camera/C in RA)
					cameras += C
					C.network.Add("Atmosphere Alarms")
			for(var/mob/living/silicon/aiPlayer in silicon_list)
				if(!aiPlayer.client)
					continue
				aiPlayer.triggerAlarm("Atmosphere", src, cameras, src)
			for(var/obj/machinery/computer/station_alert/a in station_alert_list)
				a.triggerAlarm("Atmosphere", src, cameras, src)
			air_doors_close()

		atmosalm = danger_level
		for(var/area/RA in related)
			for (var/obj/machinery/alarm/AA in RA)
				AA.update_icon()

		return 1
	return 0

/area/proc/air_doors_close()
	if(!src.master.air_doors_activated)
		src.master.air_doors_activated = 1
		for(var/obj/machinery/door/firedoor/E in src.master.all_doors)
			if(!E.blocked)
				if(E.operating)
					E.nextstate = CLOSED
				else if(!E.density)
					INVOKE_ASYNC(E, /obj/machinery/door/firedoor.proc/close)

/area/proc/air_doors_open()
	if(src.master.air_doors_activated)
		src.master.air_doors_activated = 0
		for(var/obj/machinery/door/firedoor/E in src.master.all_doors)
			if(!E.blocked)
				if(E.operating)
					E.nextstate = OPEN
				else if(E.density)
					INVOKE_ASYNC(E, /obj/machinery/door/firedoor.proc/open)


/area/proc/firealert()
	if(name == "Space") //no fire alarms in space
		return
	if( !fire )
		fire = 1
		master.fire = 1		//used for firedoor checks
		mouse_opacity = 0
		for(var/obj/machinery/door/firedoor/D in all_doors)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = CLOSED
				else if(!D.density)
					INVOKE_ASYNC(D, /obj/machinery/door/firedoor.proc/close)
		var/list/cameras = list()
		for(var/area/RA in related)
			for (var/obj/machinery/camera/C in RA)
				cameras.Add(C)
				C.network.Add("Fire Alarms")
		for (var/mob/living/silicon/ai/aiPlayer in ai_list)
			if(!aiPlayer.client)
				continue
			aiPlayer.triggerAlarm("Fire", src, cameras, src)
		for (var/obj/machinery/computer/station_alert/a in station_alert_list)
			a.triggerAlarm("Fire", src, cameras, src)

/area/proc/firereset()
	if(fire)
		fire = 0
		master.fire = 0		//used for firedoor checks
		mouse_opacity = 0
		for(var/obj/machinery/door/firedoor/D in all_doors)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = OPEN
				else if(D.density)
					INVOKE_ASYNC(D, /obj/machinery/door/firedoor.proc/open)
		for(var/area/RA in related)
			for (var/obj/machinery/camera/C in RA)
				C.network.Remove("Fire Alarms")
		for (var/mob/living/silicon/ai/aiPlayer in ai_list)
			if(!aiPlayer.client)
				continue
			aiPlayer.cancelAlarm("Fire", src, src)
		for (var/obj/machinery/computer/station_alert/a in station_alert_list)
			a.cancelAlarm("Fire", src, src)

/area/proc/partyalert()
	if(name == "Space") //no parties in space!!!
		return
	if(!party)
		party = 1
		updateicon()
		mouse_opacity = 0
	return

/area/proc/partyreset()
	if(party)
		party = 0
		mouse_opacity = 0
		updateicon()
		for(var/obj/machinery/door/firedoor/D in src)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = OPEN
				else if(D.density)
					INVOKE_ASYNC(D, /obj/machinery/door/firedoor.proc/open)
	return

/area/proc/updateicon()
	icon_state = null


/area/proc/powered(chan)		// return true if the area has power to given channel
	if(!master.requires_power)
		return 1
	if(master.always_unpowered)
		return 0
	switch(chan)
		if(EQUIP)
			return master.power_equip
		if(LIGHT)
			return master.power_light
		if(ENVIRON)
			return master.power_environ

	return 0

// called when power status changes
/area/proc/power_change()
	master.powerupdate = 2
	for(var/area/RA in related)
		for(var/obj/machinery/M in RA)	// for each machine in the area
			M.power_change()				// reverify power status (to update icons etc.)
		if (fire || eject || party)
			RA.updateicon()

/area/proc/usage(chan)
	var/used = 0
	switch(chan)
		if(LIGHT)
			used += master.used_light
		if(EQUIP)
			used += master.used_equip
		if(ENVIRON)
			used += master.used_environ
		if(TOTAL)
			used += master.used_light + master.used_equip + master.used_environ
		if(STATIC_EQUIP)
			used += master.static_equip
		if(STATIC_LIGHT)
			used += master.static_light
		if(STATIC_ENVIRON)
			used += master.static_environ
	return used

/area/proc/addStaticPower(value, powerchannel)
	switch(powerchannel)
		if(STATIC_EQUIP)
			static_equip += value
		if(STATIC_LIGHT)
			static_light += value
		if(STATIC_ENVIRON)
			static_environ += value

/area/proc/clear_usage()
	master.used_equip = 0
	master.used_light = 0
	master.used_environ = 0

/area/proc/use_power(var/amount, var/chan)

	switch(chan)
		if(EQUIP)
			master.used_equip += amount
		if(LIGHT)
			master.used_light += amount
		if(ENVIRON)
			master.used_environ += amount


/area/Entered(A)
	if(!istype(A,/mob/living))
		return

	var/mob/living/L = A
	if(!L.ckey)
		return

	//Jukebox
	if(!L.lastarea)
		L.lastarea = get_area(L.loc)
	var/area/newarea = get_area(L.loc)
	var/area/oldarea = L.lastarea
	if(newarea != oldarea)
		if(L.client)
			L.update_music()
	L.lastarea = newarea

	if((oldarea.has_gravity == 0) && (newarea.has_gravity == 1) && (L.m_intent == "run")) // Being ready when you change areas gives you a chance to avoid falling all together.
		thunk(L)

	// Ambience goes down here -- make sure to list each area seperately for ease of adding things in later, thanks! Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
	if(!(L && L.client && (L.client.prefs.toggles & SOUND_AMBIENCE)))
		return

	if(!L.client.ambience_playing)
		L.client.ambience_playing = 1
		L << sound('sound/ambience/shipambience.ogg', repeat = 1, wait = 0, volume = 35, channel = 2)

	if(prob(35))
		var/sound = 'sound/ambience/ambigen1.ogg'

		if(istype(src, /area/chapel))
			sound = pick('sound/ambience/ambicha1.ogg','sound/ambience/ambicha2.ogg','sound/ambience/ambicha3.ogg','sound/ambience/ambicha4.ogg','sound/music/traitor.ogg')
		else if(istype(src, /area/medical/morgue))
			sound = pick('sound/ambience/ambimo1.ogg','sound/ambience/ambimo2.ogg','sound/music/main.ogg')
		else if(type == /area)
			sound = pick('sound/ambience/ambispace.ogg','sound/music/title2.ogg','sound/music/space.ogg','sound/music/main.ogg','sound/music/traitor.ogg','sound/ambience/voidambi.ogg','sound/ambience/timeship_amb1.ogg')
		else if(istype(src, /area/engine))
			sound = pick('sound/ambience/ambisin1.ogg','sound/ambience/ambisin2.ogg','sound/ambience/ambisin3.ogg','sound/ambience/ambisin4.ogg')
		else if(istype(src, /area/AIsattele) || istype(src, /area/turret_protected/ai) || istype(src, /area/turret_protected/ai_upload))
			sound = pick('sound/ambience/ambimalf.ogg')
		else if(istype(src, /area/mine/explored) || istype(src, /area/mine/unexplored))
			sound = pick('sound/ambience/ambimine.ogg', 'sound/ambience/song_game.ogg','sound/ambience/mars.ogg')
		else if(istype(src, /area/tcommsat))
			sound = pick('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')
		else if (istype(src, /area/syndicate_station) || istype(src, /area/syndicate_station/start) || istype(src,/area/syndicate_station/transit))
			sound = pick('sound/ambience/omega.ogg')
		else
			sound = pick('sound/ambience/ambigen1.ogg','sound/ambience/ambigen3.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambigen5.ogg','sound/ambience/ambigen6.ogg','sound/ambience/ambigen7.ogg','sound/ambience/ambigen8.ogg','sound/ambience/ambigen9.ogg','sound/ambience/ambigen10.ogg','sound/ambience/ambigen11.ogg','sound/ambience/ambigen12.ogg','sound/ambience/ambigen14.ogg')

		if(!L.client.played)
			L << sound(sound, repeat = 0, wait = 0, volume = 25, channel = 1)
			L.client.played = TRUE
			addtimer(CALLBACK(src, .proc/set_played_false, L), 600)

/area/proc/set_played_false(mob/living/L)
	if(L && L.client)
		L.client.played = FALSE

/area/proc/gravitychange(gravitystate = 0, area/A)

	A.has_gravity = gravitystate

	for(var/area/SubA in A.related)
		SubA.has_gravity = gravitystate

		if(gravitystate)
			for(var/mob/living/carbon/human/M in SubA)
				thunk(M)

/area/proc/thunk(mob)
	if(istype(get_turf(mob), /turf/space)) // Can't fall onto nothing.
		return

	if(istype(mob,/mob/living/carbon/human/))  // Only humans can wear magboots, so we give them a chance to.
		var/mob/living/carbon/human/H = mob
		if((istype(H.shoes, /obj/item/clothing/shoes/magboots) && (H.shoes.flags & NOSLIP)))
			return
		if((istype(H.wear_suit, /obj/item/clothing/suit/space/rig) && (H.wear_suit.flags & NOSLIP))) //Humans in rig with turn on magboots
			return

		if(H.m_intent == "run")
			H.AdjustStunned(2)
			H.AdjustWeakened(2)
		else
			H.AdjustStunned(1)
			H.AdjustWeakened(1)
		to_chat(mob, "<span class='notice'>The sudden appearance of gravity makes you fall to the floor!</span>")

/proc/has_gravity(atom/AT, turf/T)
	if(!T)
		T = get_turf(AT)
	var/area/A = get_area(T)
	if(istype(T, /turf/space)) // Turf never has gravity
		return 0
	else if(A && A.has_gravity) // Areas which always has gravity
		return 1
	return 0
