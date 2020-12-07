/datum/religion/cult
	name = "Cult of Blood"
	deity_names_by_name = list(
		"Cult of Blood" = list("Nar-Sie", "The Geometer of Blood", "The One Who Sees", )
	)

	bible_info_by_name = list(
		"Cult of Blood" = /datum/bible_info/cult/blood
	)

	pews_info_by_name = list(
		"Satanism" = "dead"
	)

	altar_info_by_name = list(
		"Satanism" = "satanaltar"
	)

	carpet_dir_by_name = list(
		"Islam" = 4
	)

	favor = 10000
	piety = 10000
	max_favor = 10000
	// Just gamemode of cult
	var/datum/game_mode/cult/mode
	// Time to creation next anomalies
	var/next_anomaly
	// Just cd
	var/spawn_anomaly_cd = 10 MINUTES
	// Created anomalies at the beginning and the number of possible anomalies after
	var/max_spawned_anomalies = 12
	// Types
	var/static/list/strange_anomalies = list(/obj/effect/spacewhole, /obj/effect/timewhole, /obj/effect/orb, /obj/structure/cult/shell)
	// Instead of storing links to turfs, I store coordinates for optimization
	var/list/coord_started_anomalies = list()

	agent_type = /datum/building_agent/cult/structure
	bible_type = /obj/item/weapon/storage/bible/tome

/datum/religion/cult/New()
	..()
	area_types = typesof(/area/custom/cult)
	religify()
	for(var/i in 1 to max_spawned_anomalies)
		var/area/A = locate(/area/custom/cult)
		var/turf/T = get_turf(pick(A.contents))
		var/anom = pick(strange_anomalies)
		new anom(T)
		var/datum/coords/C = new
		C.x_pos = T.x
		C.y_pos = T.y
		C.z_pos = T.z
		coord_started_anomalies += C

	next_anomaly = world.time + spawn_anomaly_cd
	START_PROCESSING(SSreligion, src)

/datum/religion/cult/process()
	if(next_anomaly < world.time)
		var/time
		for(var/datum/coords/C in coord_started_anomalies)
			var/list/L = locate(C.x_pos, C.y_pos, C.z_pos)
			var/turf/T = get_step(pick(L), pick(alldirs))
			if(istype(T, /turf/space))
				continue
			var/anom = pick(strange_anomalies)
			var/rand_time = rand(1 SECOND, 1 MINUTE)
			time += rand_time
			addtimer(CALLBACK(src, .proc/create_anomaly, anom, T, C), rand_time)
		next_anomaly = world.time + spawn_anomaly_cd + time

/datum/religion/cult/proc/create_anomaly(type, turf/T, datum/coords/C)
	new type(T)
	C.x_pos = T.x
	C.y_pos = T.y
	C.z_pos = T.z

/datum/religion/cult/reset_religion()
	deity_names = deity_names_by_name[name]
	if(!deity_names)
		warning("ERROR IN SETTING UP RELIGION: [name] HAS NO DEITIES WHATSOVER. HAVE YOU SET UP RELIGIONS CORRECTLY?")
		deity_names = list("Error")

	gen_bible_info()
	gen_altar_variants()
	gen_pews_variants()
	gen_carpet_variants()
	gen_building_list()

/datum/religion/cult/setup_religions()
	global.cult_religion = src
	mode = SSticker.mode

/datum/religion/cult/proc/give_tome(mob/living/carbon/human/cultist)
	var/obj/item/weapon/storage/bible/tome/B = spawn_bible(cultist, /obj/item/weapon/storage/bible/tome)
	cultist.equip_to_slot_or_del(B, SLOT_IN_BACKPACK)
