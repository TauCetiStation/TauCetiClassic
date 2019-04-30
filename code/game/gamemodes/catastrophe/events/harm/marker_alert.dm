/datum/catastrophe_event/marker_alert
	name = "Marker alert"

	one_time_event = TRUE

	weight = 100

	event_type = "harmful"
	steps = 5

	var/obj/structure/obelisk/marker = null
	var/should_spawn_monster = FALSE

	var/monster_wave_timer = 10
	var/monster_wave_min = 1
	var/monster_wave_max = 1

	var/spook_wave_timer = 10
	var/spook_active_timer = 0
	var/monster_chance = 10 // chance that a spook might become real
	var/list/spooked = list() // a list of players that got spooked this wave so we dont spooke them again
	var/list/spooky_sounds = list('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/wail.ogg')

	var/list/monster_types = list(/mob/living/simple_animal/hostile/cellular/necro)

/datum/catastrophe_event/marker_alert/on_step()
	switch(step)
		if(1)
			var/turf/T = find_spot()
			var/datum/map_template/marker_template/temp = new /datum/map_template/marker_template()
			temp.load(T, centered = TRUE)

			marker = new /obj/structure/obelisk(T)

			announce(CYRILLIC_EVENT_MARKER_ALERT_1)

			message_admins("Marker was created in [T.x],[T.y],[T.z] [ADMIN_JMP(T)]")
		if(2)
			announce(CYRILLIC_EVENT_MARKER_ALERT_2)
		if(3)
			// stuff happens first, then you get the report
			if(marker)
				marker.visible_message("<span class='warning'><b>[marker]</b> begins to glow bright <b>RED</b></span>")

				addtimer(CALLBACK(src, .proc/spawn_monsters_marker), 10 SECONDS)
			addtimer(CALLBACK(src, .proc/marker_report), 30 SECONDS)

			for(var/obj/machinery/power/apc/apc in apc_list)
				if(prob(80))
					apc.overload_lighting()
		if(4)
			announce(CYRILLIC_EVENT_MARKER_ALERT_4)

			monster_wave_min = 1
			monster_wave_max = 3
		if(5)
			var/turf/T = find_random_floor(findEventArea())
			if(!T)
				return
			var/area/A = get_area(T)

			announce(CYRILLIC_EVENT_MARKER_ALERT_5)
			message_admins("Necroblob was created in [T.x],[T.y],[T.z] [ADMIN_JMP(T)]")

			new /obj/effect/cellular_biomass_controller/necro(T)

/datum/catastrophe_event/marker_alert/proc/spawn_monsters_marker()
	if(marker)
		var/turf/MyTurf = get_turf(marker)
		for (var/newdir in alldirs)
			var/turf/A = get_step(MyTurf, newdir)
			var/monster_type = pick(monster_types)
			new monster_type(A)

/datum/catastrophe_event/marker_alert/proc/marker_report()
	announce(CYRILLIC_EVENT_MARKER_ALERT_3)

	should_spawn_monster = TRUE

/datum/catastrophe_event/marker_alert/process_event()
	..()

	if(!should_spawn_monster)
		return

	// this spawns monsters at random air pumps
	monster_wave_timer -= 1
	if(monster_wave_timer <= 0)
		monster_wave_timer = rand(30, 40)
		if(prob(20))
			monster_wave_timer = rand(90, 120)

		var/list/found_vents = list()
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/v in machines)
			if(!v.welded && v.z == ZLEVEL_STATION)
				found_vents.Add(v)

		if(found_vents.len)
			for (var/i in 1 to rand(monster_wave_min, monster_wave_max))
				var/obj/machinery/atmospherics/components/unary/vent_pump/vent_found = pick(found_vents)
				spawn_monster(vent_found)


	spook_wave_timer -= 1
	if(spook_wave_timer <= 0)
		spook_wave_timer = 30
		spook_active_timer = 10
		spooked = list()

	if(spook_active_timer > 0)
		spook_active_timer -= 1

		if(player_list.len > 0) // picks a random player each second and tries to scary them
			var/mob/P = pick(player_list)
			if(ishuman(P))
				var/mob/living/carbon/human/H = P

				if(!(H in spooked))
					spooked += H
					var/scary_object = spook(H)

					if(scary_object && prob(monster_chance))
						addtimer(CALLBACK(src, .proc/spawn_monster, scary_object), rand(3, 10) SECONDS)

// attempts to scare some one, also may return object that we can use to spawn some monsters inside
/datum/catastrophe_event/marker_alert/proc/spook(mob/living/carbon/human/H)
	var/list/spook_types = list("vent", "closet", "pump", "sound")
	var/spook_type = pick(spook_types)

	// just some generic thing
	if(spook_type == "sound")
		var/turf/T = locate(H.x+rand(-7, 7), H.y+rand(-7, 7), H.z)
		if(!T)
			return null

		playsound(T, pick(spooky_sounds), rand(10, 50), 1)
		return null

	var/obj/scary_object = null

	switch(spook_type)
		if("vent")
			for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/U in orange(7, H))
				if(!U.welded)
					scary_object = U
					break
		if("closet")
			for(var/obj/structure/closet/C in orange(7, H))
				if(istype(C, /obj/structure/closet/body_bag))
					continue

				if(!C.opened)
					scary_object = C
					break
		if("pump")
			for(var/obj/machinery/atmospherics/components/unary/vent_pump/U in orange(7, H))
				if(!U.welded)
					scary_object = U
					break

	if(!scary_object)
		return null

	switch(spook_type)
		if("vent", "pump")
			scary_object.audible_message("<span class='warning'>[pick("You hear something squeezing through the ducts", "You hear a metal screeching sound.", "You hear something squeezing through the pipes", "You hear twisting metal")]</span>")
		if("closet")
			scary_object.audible_message("<span class='warning'>[pick("You hear something inside <b>[scary_object]</b>...", "You hear a noise coming from <b>[scary_object]</b>", "<b>[scary_object]</b> is shaking")]</span>")
	return scary_object

/datum/catastrophe_event/marker_alert/proc/spawn_monster(obj/scary_object)
	if(!scary_object || scary_object.z != ZLEVEL_STATION)
		return

	if(istype(scary_object, /obj/structure/closet))
		var/obj/structure/closet/C = scary_object
		if(C.opened)
			return
		if(C.locked || C.welded)
			if(prob(50)) // Saved
				C.audible_message("<span class='danger'>[bicon(C)] *BAM*</span>")
				playsound(C.loc, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), 20, 1)
				return
		C.locked = FALSE
		C.welded = FALSE
		C.open()
		var/monster_type = pick(monster_types)
		new monster_type(C.loc)
		playsound(C.loc, pick(spooky_sounds), 50, 1)
		C.visible_message("<span class='danger'>A monster comes out from [C]!</span>")

	if(istype(scary_object, /obj/machinery/atmospherics/components/unary/vent_scrubber))
		var/obj/machinery/atmospherics/components/unary/vent_scrubber/S = scary_object
		if(S.welded)
			return

		var/monster_type = pick(monster_types)
		new monster_type(S.loc)
		playsound(S.loc, pick(spooky_sounds), 50, 1)
		S.visible_message("<span class='danger'>A monster climbs out from [S]!</span>")

	if(istype(scary_object, /obj/machinery/atmospherics/components/unary/vent_pump))
		var/obj/machinery/atmospherics/components/unary/vent_pump/S = scary_object
		if(S.welded)
			return

		var/monster_type = pick(monster_types)
		new monster_type(S.loc)
		playsound(S.loc, pick(spooky_sounds), 50, 1)
		S.visible_message("<span class='danger'>A monster climbs out from [S]!</span>")

// where do we spawn marker thing
/datum/catastrophe_event/marker_alert/proc/find_spot()
	var/try_count = 0
	while(try_count < 30)
		try_count += 1

		var/turf/space/T = locate(rand(20, world.maxx - 20), rand(20, world.maxy - 20), ZLEVEL_STATION)
		if(!istype(T))
			continue

		var/good = TRUE
		for(var/turf/simulated/G in orange(5, T))
			good = FALSE
			break
		if(good)
			return T
	return locate(rand(20, world.maxx - 20), rand(20, world.maxy - 20), ZLEVEL_STATION) // need to spawn it somewhere anyway

/obj/structure/obelisk
	name = "Pylon"
	desc = "A floating crystal that hums with an unearthly energy."
	density = TRUE
	anchored = FALSE
	icon = 'icons/obj/structures/marker.dmi'
	icon_state = "marker"
	layer = INFRONT_MOB_LAYER
	light_color = "#ff0000"
	light_power = 2
	light_range = 6

/obj/structure/obelisk/attack_hand(mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)

	to_chat(user, "<span class='warning'>[pick("You feel... <i>different</i>", "EVOLVE", "You feel a lot of energy")]</span>")

	if(ishuman(user) && prob(10))
		var/mob/living/carbon/human/H = user
		H.hallucination = max(H.hallucination, 50)

// Just some asteroid-looking thing, the actual marker is spawned through code in the center
/datum/map_template/marker_template
	name = "The Marker"
	mappath = "maps/templates/catastrophe/marker.dmm"
