/datum/event/feature/area/maintenance_spawn
	special_area_types = list(/area/station/maintenance)
	var/list/possible_types = list()
	var/nums = 3

/datum/event/feature/area/maintenance_spawn/proc/spawn_atom(type, turf/T)
	if(T && type)
		message_admins("RoundStart Event: \"[event_meta.name]\" spawn '[type]' in [COORD(T)] - [ADMIN_JMP(T)]")
		log_game("RoundStart Event: \"[event_meta.name]\" spawn '[type]' in [COORD(T)]")
		new type(T)

/datum/event/feature/area/maintenance_spawn/start()
	if(!length(targeted_areas))
		return

	for(var/i in 1 to nums)
		var/area/A = get_area_by_type(pick_n_take(targeted_areas))
		if(!A)
			continue

		var/list/turfs = list()
		for(var/turf/T in A)
			turfs += T

		if(length(turfs) && length(possible_types))
			spawn_atom(pick(possible_types), pick(turfs))

/datum/event/feature/area/maintenance_spawn/invasion
	possible_types = list(
		/mob/living/simple_animal/hostile/giant_spider,
		/mob/living/simple_animal/hostile/shade,
		/mob/living/simple_animal/hostile/octopus,
		/mob/living/simple_animal/hostile/cyber_horror,
	)

/datum/event/feature/area/maintenance_spawn/invasion/setup()
	nums = rand(8, 12)
	. = ..()

/datum/event/feature/area/maintenance_spawn/antag_meta
	possible_types = list(
		/obj/effect/rune,
		/obj/item/weapon/kitchenknife/ritual,
		/obj/item/clothing/head/wizard,
		/obj/structure/alien/resin/wall/shadowling,
		/obj/structure/alien/resin/wall,
		/obj/structure/alien/weeds/node,
		/obj/item/weapon/card/emag_broken,
	)

/datum/event/feature/area/maintenance_spawn/antag_meta/setup()
	nums = rand(1, 3)
	possible_types += subtypesof(/obj/item/weapon/storage/box/syndie_kit)
	. = ..()

/datum/event/feature/area/maintenance_spawn/antag_meta/spawn_atom(type, turf/T)
	if(!T || !type)
		return

	if(ispath(type, /obj/effect/rune))
		new /obj/effect/rune(T, null, null, TRUE)
	else if(ispath(type, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = new type(T)
		S.make_empty(TRUE)
	else
		new type(T)

	message_admins("RoundStart Event: \"[event_meta.name]\" spawn '[type]' in [COORD(T)] - [ADMIN_JMP(T)]")
	log_game("RoundStart Event: \"[event_meta.name]\" spawn '[type]' in [COORD(T)]")

/datum/event/feature/area/maintenance_spawn/corpse
	possible_types = list(/mob/living/carbon/human)

	var/static/list/role_outfit_map = list(
		"Assistant" = /datum/outfit/job/assistant,
		"Engineer" = /datum/outfit/job/engineer,
		"Scientist" = /datum/outfit/job/scientist,
		"Security Officer" = /datum/outfit/job/officer,
		"Medical Doctor" = /datum/outfit/job/doctor,
		"Cargo Technician" = /datum/outfit/job/cargo_tech,
		"Janitor" = /datum/outfit/job/janitor,
		"Chef" = /datum/outfit/job/chef,
		"Bartender" = /datum/outfit/job/bartender,
		"Chaplain" = /datum/outfit/job/chaplain,
		"Librarian" = /datum/outfit/job/librarian,
	)

/datum/event/feature/area/maintenance_spawn/corpse/setup()
	nums = rand(2, 5)
	. = ..()

/datum/event/feature/area/maintenance_spawn/corpse/spawn_atom(type, turf/T)
	if(!istype(T, /turf))
		return

	var/mob/living/carbon/human/H = new(T)
	var/used_real_player = FALSE

	if(prob(30))
		var/list/candidates = list()

		for(var/mob/living/carbon/human/player in world)
			if(player.client && player.stat == CONSCIOUS && player.z == 2)
				candidates += player

		if(length(candidates))
			var/mob/living/carbon/human/donor = pick(candidates)

			if(donor.dna)
				H.dna = donor.dna

			H.real_name = donor.real_name
			H.name = H.real_name

			used_real_player = TRUE

	if(!used_real_player)
		H.randomize_appearance()
		H.real_name = random_name(H.gender)
		H.name = H.real_name

	H.death()

	var/role = pick(role_outfit_map)
	var/outfit = role_outfit_map[role]

	var/list/zones = list("chest","head","l_arm","r_arm","l_leg","r_leg")

	for(var/i in 1 to rand(3,6))
		H.apply_damage(rand(15,40), BRUTE, pick(zones))

	if(prob(80))
		new /obj/effect/decal/cleanable/blood(T)

	if(prob(50))
		var/turf/N = get_step(T, pick(NORTH,SOUTH,EAST,WEST))
		if(N)
			new /obj/effect/decal/cleanable/blood(N)

	if(outfit)
		H.equipOutfit(outfit)

	var/list/misc = list(
		/obj/item/trash/cheesie,
		/obj/item/trash/candy,
		/obj/item/weapon/paper/crumpled,
		/obj/item/weapon/storage/wallet
	)

	if(prob(30))
		var/path1 = pick(misc)
		new path1(T)

	if(prob(10))
		var/path2 = pick(misc)
		new path2(T)

	H.update_body()
	H.update_icons()

	message_admins("Corpse spawned ([role]) at [T.x],[T.y],[T.z] - [ADMIN_JMP(T)]")
	log_game("Corpse spawned ([role]) at [T.x],[T.y],[T.z]")
