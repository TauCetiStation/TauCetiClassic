/datum/catastrophe_event/junkyard
	name = "Junkyard"

	one_time_event = TRUE

	weight = 100

	event_type = "harmful"
	steps = 3

	var/dirt_timer = 10
	var/dirt_timer_interval = 10

	var/list/trash_types = list(/obj/item/weapon/cigbutt/cigarbutt, /obj/item/weapon/scrap_lump, /obj/item/weapon/shard, /obj/item/stack/rods)

	var/trash_places = list(
		CYRILLIC_EVENT_JUNKYARD_SEC = /area/security,
		CYRILLIC_EVENT_JUNKYARD_MED = /area/medical,
		CYRILLIC_EVENT_JUNKYARD_ENG = /area/engine/break_room,
		CYRILLIC_EVENT_JUNKYARD_COR = /area/hallway/primary,
		CYRILLIC_EVENT_JUNKYARD_SCI = /area/rnd,
		CYRILLIC_EVENT_JUNKYARD_BRI = /area/bridge
	)
	var/will_trash

/datum/catastrophe_event/junkyard/start()
	..()

	trash_types += subtypesof(/obj/item/trash)

/datum/catastrophe_event/junkyard/on_step()
	switch(step)
		if(1)
			announce(CYRILLIC_EVENT_JUNKYARD_1)

		if(2)
			will_trash = pick(trash_places)
			announce(CYRILLIC_EVENT_JUNKYARD_2)

			addtimer(CALLBACK(src, .proc/asteroid_warning), 9 MINUTES)
			addtimer(CALLBACK(src, .proc/asteroid_last_warning), 10 MINUTES)
			addtimer(CALLBACK(src, .proc/asteroid_spawn), 10 MINUTES + 3 SECONDS)
		if(3)
			announce(CYRILLIC_EVENT_JUNKYARD_5)

/datum/catastrophe_event/junkyard/proc/asteroid_warning()
	announce(CYRILLIC_EVENT_JUNKYARD_3)

/datum/catastrophe_event/junkyard/proc/asteroid_last_warning()
	announce(CYRILLIC_EVENT_JUNKYARD_4)

/datum/catastrophe_event/junkyard/proc/asteroid_spawn()
	var/area_to_trash = trash_places[will_trash]

	for(var/e in typesof(area_to_trash))
		var/area/A = locate(e)
		totally_trash_area(A)

/datum/catastrophe_event/junkyard/process_event()
	..()

	dirt_timer -= 1
	if(dirt_timer <= 0)
		make_area_dirty(findEventArea(), 40, 20, 255, 5)

		if(prob(30))
			trash_spawn(5, 1)

		dirt_timer = dirt_timer_interval
		if(prob(10)) // to give some rest sometimes
			dirt_timer *= 10


/datum/catastrophe_event/junkyard/proc/make_area_dirty(area/A, chance, min_value, max_value, oil_chance)
	var/list/turfs = get_area_turfs(A)
	if(!turfs.len)
		return null

	for(var/turf/simulated/floor/T in turfs)
		if(prob(chance))
			var/obj/effect/decal/cleanable/dirt/dirtoverlay = locate(/obj/effect/decal/cleanable/dirt, T)
			if (!dirtoverlay)
				dirtoverlay = new/obj/effect/decal/cleanable/dirt(T)
				dirtoverlay.alpha = rand(min_value, max_value)
			else
				dirtoverlay.alpha = min(dirtoverlay.alpha + rand(min_value, max_value), 255)

		if(prob(oil_chance))
			if(!locate(/obj/effect/decal/cleanable/blood, T))
				new /obj/effect/decal/cleanable/blood/oil(T)


/datum/catastrophe_event/junkyard/proc/trash_spawn(trashbin_chance, pump_chance)
	for(var/obj/machinery/disposal/D in machines)
		if(!(D.stat & BROKEN) && D.z == ZLEVEL_STATION && D.mode)
			if(prob(trashbin_chance))
				spawn_trash_objects(D)

	for(var/obj/machinery/atmospherics/components/unary/vent_pump/v in machines)
		if(!v.welded && v.z == ZLEVEL_STATION)
			if(prob(pump_chance))
				spawn_trash_objects(v, 2)

/datum/catastrophe_event/junkyard/proc/spawn_trash_objects(obj/D, max_trash = 5)
	D.visible_message("<span class='warning'>Clogged up [D] spews out some trash</span>")

	for (var/i in 1 to rand(1, max_trash))
		var/trash_type = pick(trash_types)
		var/obj/item/trash = new trash_type(D.loc)
		trash.throw_at(locate(D.x + rand(-5, 5), D.y + rand(-5, 5), D.z), 8, 2)

/datum/catastrophe_event/junkyard/proc/totally_trash_area(area/A)
	var/list/turfs = get_area_turfs(A)
	if(!turfs.len)
		return null

	var/list/possible = list()
	for(var/turf/simulated/floor/T in turfs)
		if(prob(30))
			var/good = TRUE
			for(var/atom/At in T) // so we don't destroy something important
				if(At.density)
					good = FALSE
					break

			if(good)
				possible += T

	while(possible.len > 0)
		var/turf/T = pick(possible)
		possible -= T

		new /obj/effect/falling_effect(T, /obj/random/scrap/dense_weighted)
		sleep(3)

		if(prob(1))
			for(var/mob/M in player_list)
				if(M.z == T.z)
					M << sound('sound/effects/Explosion3.ogg')