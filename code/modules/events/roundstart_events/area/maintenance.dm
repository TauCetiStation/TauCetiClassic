/datum/event/roundstart/area/maintenance_spawn
	special_area_types = list(/area/station/maintenance)
	var/list/possible_types = list()
	var/nums = 3

/datum/event/roundstart/area/maintenance_spawn/proc/spawn_atom(type, turf/T)
	if(T)
		message_admins("RoundStart Event: \"[event_meta.name]\" spawn '[type]' in [COORD(T)] - [ADMIN_JMP(T)]")
		log_game("RoundStart Event: \"[event_meta.name]\" spawn '[type]' in [COORD(T)]")
		new type(T)

/datum/event/roundstart/area/maintenance_spawn/start()
	for(var/i in 1 to nums)
		var/area/area = get_area_by_type(pick_n_take(targeted_areas))
		var/list/all_turfs = get_area_turfs(area, FALSE, black_list=list(/turf/simulated/wall, /turf/simulated/wall/r_wall))
		// to prevent spawn in glass or grinds
		for(var/turf/T in all_turfs)
			if(T.contents.len == 1) // any turfs has a single instance of lighting_object, for at some optimization, i need to skip such turfs
				continue
			if(!T.CanPass(null, T))
				all_turfs -= T

		spawn_atom(pick(possible_types), pick(all_turfs))

/datum/event/roundstart/area/maintenance_spawn/invasion
	possible_types = list(
		/mob/living/simple_animal/hostile/giant_spider,
		/mob/living/simple_animal/hostile/pylon,
		/mob/living/simple_animal/hostile/xenomorph/drone,
		/mob/living/simple_animal/hostile/xenomorph,
		/mob/living/simple_animal/hostile/hivebot,
		/mob/living/carbon/slime,
	)

/datum/event/roundstart/area/maintenance_spawn/invasion/setup()
	nums = rand(1, 3)
	. = ..()

/datum/event/roundstart/area/maintenance_spawn/antag_meta
	possible_types = list(
		/obj/effect/rune,
		/obj/item/weapon/kitchenknife/ritual,
		/obj/item/clothing/head/wizard,
		/obj/structure/alien/resin/wall/shadowling,
		/obj/structure/alien/resin/wall,
		/obj/structure/alien/weeds/node,
		/obj/item/weapon/card/emag_broken,
	)

/datum/event/roundstart/area/maintenance_spawn/antag_meta/setup()
	nums = rand(1, 3)
	possible_types += subtypesof(/obj/item/weapon/storage/box/syndie_kit)
	. = ..()

/datum/event/roundstart/area/maintenance_spawn/antag_meta/spawn_atom(type, turf/T)
	if(ispath(type, /obj/effect/rune))
		new /obj/effect/rune(T, null, null, TRUE)
	else if(ispath(type, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = new type(T)
		S.make_empty(TRUE)
	else
		new type(T)

	message_admins("RoundStart Event: \"[event_meta.name]\" spawn '[type]' in [COORD(T)] - [ADMIN_JMP(T)]")
	log_game("RoundStart Event: \"[event_meta.name]\" spawn '[type]' in [COORD(T)]")
