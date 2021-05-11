/datum/event/roundstart/area/maintenance_spawn
	special_area_types = list(/area/station/maintenance)
	var/list/possible_types = list()
	var/nums = 3

/datum/event/roundstart/area/maintenance_spawn/proc/spawn_atom(type, turf/T)
	message_admins("RoundStart Event: \"[event_meta.name]\" replace [A] on [B_type ? "[B_type]" : "OTHER"] in ([A.x] [A.y] [A.z]) - [ADMIN_JMP(A.loc)]")
	log_game("RoundStart Event: \"[event_meta.name]\" replace [A] on [B_type ? "[B_type]" : "OTHER"] in ([A.x] [A.y] [A.z])")
	new type(T)

/datum/event/roundstart/area/maintenance_spawn/start()
	for(var/i in 1 to nums)
		var/area/area = get_area_by_type(pick(targeted_areas))
		var/turf/T = pick(get_area_turfs(area, FALSE, black_list=list(/turf/simulated/wall)))
		var/type = pick(possible_types)
		spawn_atom(type, T)

/datum/event/roundstart/area/maintenance_spawn/invasion
	possible_types = list(
		/mob/living/simple_animal/hostile/giant_spider,
		/mob/living/simple_animal/hostile/pylon,
		/mob/living/simple_animal/hostile/xenomorph/drone,
		/mob/living/simple_animal/hostile/xenomorph/sentinel,
		/mob/living/simple_animal/hostile/xenomorph,
		/mob/living/simple_animal/hostile/hivebot,
		/mob/living/carbon/slime,
	)

/datum/event/roundstart/area/maintenance_spawn/invasion/setup()
	. = ..()
	nums = rand(1, 3)

/datum/event/roundstart/area/maintenance_spawn/antag_meta
	possible_types = list(
		/obj/effect/rune,
		/obj/item/weapon/kitchenknife/ritual,
		/obj/item/clothing/head/wizard,
		/obj/structure/alien/resin/wall/shadowling,
		/obj/structure/alien/resin/wall,
		/obj/structure/alien/weeds/node,
	)

/datum/event/roundstart/area/maintenance_spawn/antag_meta/setup()
	. = ..()
	nums = rand(1, 3)

/datum/event/roundstart/area/maintenance_spawn/antag_meta/spawn_atom(type, turf/T)
	switch(type)
		if(/obj/effect/rune)
			var/obj/effect/rune/R = new(T, rand_icon = TRUE)
		else
			new type(T)
