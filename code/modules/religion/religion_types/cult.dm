/datum/religion/cult
	name = "Cult of Blood"
	deity_names_by_name = list(
		"Cult of Blood" = list("Nar-Sie", "The Geometer of Blood", "The One Who Sees", )
	)

	bible_info_by_name = list(
		"Cult of Blood" = /datum/bible_info/cult/blood
	)

	pews_info_by_name = list(
		"Cult of Blood" = "dead"
	)

	altar_info_by_name = list(
		"Cult of Blood" = "satanaltar"
	)

	carpet_type_by_name = list(
		"Cult of Blood" = /turf/simulated/floor/carpet/black
	)

	carpet_dir_by_name = list(
		"Cult of Blood" = 9
	)

	bible_type = /obj/item/weapon/storage/bible/tome
	area_type = /area/custom/cult
	build_agent_type = /datum/building_agent/structure/cult
	rune_agent_type = /datum/building_agent/rune/cult
	tech_agent_type = /datum/building_agent/tech/cult
	wall_types = list(/turf/simulated/wall/cult)
	floor_types = list(/turf/simulated/floor/engine/cult, /turf/simulated/floor/engine/cult/lava)
	door_types = list(/obj/structure/mineral_door/cult)

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

	// Are they dead or not yet? Maybe separate it somehow and put it in /datum/religion
	var/list/humans_in_heaven = list()
	// When's the next time you scare people in heaven
	var/next_spook
	// Just cd
	var/spook_cd = 20 SECONDS
	// Motivation to work!
	var/list/possible_god_phrases = list("ОТДАЙ НАМ СВОЮ СИЛУ", "СКЛОНИСЬ ПЕРЕД НАМИ", "БОЙСЯ НАС", "ОСОЗНАЙ НАШУ МОЩЬ", "УМРИ ИЛИ СКЛОНИСЬ", "ТЫ ПОЖАЛЕЕШЬ О СВОЕМ ВЫБОРЕ", "УБИРАЙСЯ ОТСЮДА", "УМРИ", "БОЛЬШЕ КРОВИ БОГУ КРОВИ", "Я ИСПЕПЕЛЮ ТЕБЯ", "ТЫ НИКТО", "ТЫ ЖАЛОК", "СМЕРТЬ ТВОЕ СПАСЕНИЕ", "ТЫ НЕ ВЫБЕРЕШЬСЯ ОТСЮДА", "ПАДИ НИЦ", "ПОДЧИНЯЙСЯ НАШЕЙ ВОЛЕ", "УМРИ, СМЕРД", "ПОХВАЛЬНАЯ ПОКОРНОСТЬ", "АХ-ХА-ХА-ХА-ХА-ХА", "БОЛЬШЕ ВЛАСТИ", "БОГ ДАЛ - БОГ ВЗЯЛ",
							"НУЖНО БОЛЬШЕ ДУШ", "ВО'ХЕДОК-ГЛУТ", " ВО'ХАДОК ГРИШ. СОЛ ИЧА ОЖ")
	// Motivation to kill!
	var/list/possible_human_phrases = list("Я убью тебя!", "Ты чё?", "Я вырву твой имплант сердца и сожгу его!", "Я выпью твою кровь!", "Я уничтожу тебя!", "Молись, сука!", "Я вырву и съем твои кишки!", "Моргало выколю!", "Эй ты!", "Я измельчу тебя на мелкие кусочки и выброшу их в чёрную дыру!", "Пошёл нахуй!", "Ты умрешь в ужасных судорогах!", "Ильс'м уль чах!", "Твое призвание - это чистить канализацию на Марсе!", "Тупое животное!", "АХ-ХА-ХА-ХА-ХА-ХА!", "Что б ты бобов объелся!", "Ёбаный в рот этого ада!", "Эй обезьяна свинорылая!", "Обабок бля!", "Ну ты и маслёнок!",\
	 						"Пиздакряк ты тупой!", "Твои потраха съедят кибер-свиньи вместе с помоями, а мозг будут разрывать на куски бездомные космо-кошки!", "Твою плоть разорвут космо-карпы, а кишки съедят мыши!", "Тупоголовый дегенерат!", "Ты никому не нужный биомусор!", "Ты тупое ничтожество!", "Лучшеб ты у папы на синих трусах засох!", "ААА-Р-Р-Р-Р-Р-Г-Г-Г-Х-Х-Х!")

/datum/religion/cult/New()
	..()
	area_types = typesof(area_type)
	religify_area()

	// Init anomalys
	var/area/area = locate(/area/custom/cult)
	for(var/i in 1 to max_spawned_anomalies)
		var/turf/T = get_turf(pick(area.contents))
		var/anom = pick(strange_anomalies)
		new anom(T)
		var/datum/coords/C = new
		C.x_pos = T.x
		C.y_pos = T.y
		C.z_pos = T.z
		coord_started_anomalies += C
	next_anomaly = world.time + spawn_anomaly_cd

	var/area/A = locate(/area/custom/cult)
	RegisterSignal(A, list(COMSIG_AREA_ENTERED), .proc/area_entered)
	RegisterSignal(A, list(COMSIG_AREA_EXITED), .proc/area_exited)

	START_PROCESSING(SSreligion, src)

/datum/religion/cult/setup_religions()
	global.cult_religion = src
	mode = SSticker.mode

/datum/religion/cult/process()
	if(next_anomaly < world.time)
		create_anomalys()

	if(next_spook < world.time)
		if(!humans_in_heaven.len)
			next_spook = world.time + 5 MINUTES
			return
		var/mob/living/carbon/human/H = pick(humans_in_heaven)
		if(H.mind?.holy_role && prob(20))
			return

		if(prob(20)) // sound
			var/list/sounds = pick(SOUNDIN_EXPLOSION, SOUNDIN_SPARKS, SOUNDIN_FEMALE_HEAVY_PAIN, SOUNDIN_MALE_HEAVY_PAIN)
			playsound(H, pick(sounds), VOL_EFFECTS_INSTRUMENT)
		else if(prob(20)) // chat_message
			to_chat(H, "<font size='15' color='red'><b>[pick(possible_god_phrases)]!</b></font>")
		else if(prob(20)) // receive damage
			H.take_overall_damage(rand(-3, clamp(world.time**(1/3), 1, 30)), rand(-3, clamp(world.time**(1/3), 1, 30)), used_weapon = "Plasma ions") // Its science, baby
		else if(prob(15)) // Heal
			H.apply_damages(rand(-clamp(world.time**(1/3), 1, 30), 3), rand(-clamp(world.time**(1/3), 1, 30), 3), rand(-clamp(world.time**(1/3), 1, 30), 3))
		else if(prob(5)) // temp alt_apperance of humans or item
			if(prob(50))
				var/mob/living/carbon/human/target = pick(humans_in_heaven)
				var/image/I = image(icon = 'icons/mob/human.dmi', icon_state = pick("husk_s", "electrocuted_generic", "ghost", "zombie", "skeleton", "abductor_s", "electrocuted_base"), layer = INFRONT_MOB_LAYER, loc = target)
				I.override = TRUE
				target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, "nar-sie_hall", I, H)
			else
				var/obj/item/I = pick(H.contents)
				I.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, "nar-sie_hall", null, H, /obj/effect/decal/remains/human, I)

			addtimer(CALLBACK(src, .proc/remove_spook_effect, H), 3 MINUTES)
		else if(prob(1)) // temp alt_apperance of nar-sie
			if(!altar)
				return
			altar.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, "nar-sie_hall", null, H, /obj/singularity/narsie, altar)
			addtimer(CALLBACK(src, .proc/remove_spook_effect, H), 10 MINUTES)

		else if(prob(1))
			H.say(pick(possible_human_phrases))

		next_spook = world.time + spook_cd

/datum/religion/cult/proc/give_tome(mob/living/carbon/human/cultist)
	var/obj/item/weapon/storage/bible/tome/B = spawn_bible(cultist)
	cultist.equip_to_slot_or_del(B, SLOT_IN_BACKPACK)

/datum/religion/cult/proc/area_entered(area/A, atom/movable/AM)
	if(ishuman(AM))
		humans_in_heaven += AM

/datum/religion/cult/proc/area_exited(area/A, atom/movable/AM)
	humans_in_heaven -= AM

/datum/religion/cult/proc/create_anomalys(force = FALSE)
	var/time
	for(var/datum/coords/C in coord_started_anomalies)
		var/list/L = locate(C.x_pos, C.y_pos, C.z_pos)
		var/turf/T = get_step(pick(L), pick(alldirs))
		if(istype(T, /turf/space))
			continue
		var/anom = pick(strange_anomalies)
		var/rand_time = force ? 0 : rand(1 SECOND, 1 MINUTE)
		time += rand_time
		addtimer(CALLBACK(src, .proc/create_anomaly, anom, T, C), rand_time)

	if(!force)
		next_anomaly = world.time + spawn_anomaly_cd + time

/datum/religion/cult/proc/create_anomaly(type, turf/T, datum/coords/C)
	new type(T)
	C.x_pos = T.x
	C.y_pos = T.y
	C.z_pos = T.z

/datum/religion/cult/proc/remove_spook_effect(mob/living/carbon/C)
	C.remove_alt_appearance("nar-sie_hall")
