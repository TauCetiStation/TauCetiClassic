/datum/religion/cult
	name = "Cult of Blood"
	deity_names_by_name = list(
		"Cult of Blood" = list("Nar-Sie", "The Geometer of Blood", "The One Who Sees", "Dark One")
	)

	bible_info_by_name = list(
		"Cult of Blood" = /datum/bible_info/cult/blood
	)

	emblem_info_by_name = list(
		"Cult of Blood" = "dead"
	)

	altar_info_by_name = list(
		"Cult of Blood" = "cultaltar"
	)

	carpet_type_by_name = list(
		"Cult of Blood" = /turf/simulated/floor/carpet/black
	)

	decal_by_name = list(
		"Cult of Blood",
	)

	binding_rites = list(
		/datum/religion_rites/pedestals/cult/narsie,
		/datum/religion_rites/instant/cult/sacrifice,
		/datum/religion_rites/instant/cult/convert, // maybe not binding,
	)

	bible_type = /obj/item/weapon/storage/bible/tome
	religious_tool_type = /obj/item/weapon/storage/bible/tome
	area_type = /area/custom/cult
	build_agent_type = /datum/building_agent/structure/cult
	rune_agent_type = /datum/building_agent/rune/cult
	tech_agent_type = /datum/building_agent/tech/cult
	wall_types = list(/turf/simulated/wall/cult, /turf/simulated/wall/cult/runed, /turf/simulated/wall/cult/runed/anim)
	floor_types = list(/turf/simulated/floor/engine/cult, /turf/simulated/floor/engine/cult/lava)
	door_types = list(/obj/structure/mineral_door/cult)

	favor = 1000
	max_favor = 10000

	max_runes_on_mob = 5
	style_text = "cult"
	symbol_icon_state = null

	/*
		Only cult
	*/
	var/datum/faction/cult/mode
	// Is the area captured by /datum/rune/cult/capture_area
	var/capturing_area = FALSE

	// Time to creation next anomalies
	var/next_anomaly
	// Just cd
	var/spawn_anomaly_cd = 10 MINUTES
	// Created anomalies at the beginning and the number of possible anomalies after
	var/max_spawned_anomalies = 12
	// Types
	var/list/strange_anomalies
	// Instead of storing links to turfs
	var/list/coord_started_anomalies = list()

	// Used for ritеs
	var/list/obj/machinery/optable/torture_table/torture_tables = list()

	// Are they dead or not yet? Maybe separate it somehow and put it in /datum/religion
	var/list/humans_in_heaven = list()
	// When's the next time you scare people in heaven
	var/next_spook
	// Just cd
	var/spook_cd = 20 SECONDS
	// Motivation to work!
	var/list/possible_god_phrases = list("О̒̀̾Т̔̒́Д̈́̈́͝А̾̓̾Й͌͠ Н͊̈́͊А̿̓͠М̔̀͝ С̈́͌͆В͐͌̿О͊͑͝Ю͋̓͘ С̔͛͠И͊͐͠Л͊͆͝У̐͒", "С̀̐͝К̾͌͠Л̈́̿͋О͐̈́̕Н͛̓̔И̕͠͠С͌̓̀Ь̔̀ П̽͋͆Е͒͑͝Р̐̒̔Е͑͐́Д̐͋ Н͋͒̈́А͋͛М͑͠͝И̿̽͝", "Б͑̿О̐̈́͠Й̀̽͌С͝͠͝Я͒̐͠ Н̽̚͝А͌̈́͠С́̐͐", "О̽̓͌С͐̔̕О̿̔Ӟ́̒͘Н͐̐̕А̔̐͝Й̈́͌̓ Н̐̈́͑А̓͊̓Ш͋͝У͛̐̕ М̚͝О͌͝͝Щ̓̾͐Ь̈́̽͝", "Ӱ́̔͝М͆͛̈́Р̒̿͝И̓͒͠ И̓̈́̚Л͊̚͝Ӥ́͒͝ С̐̽К͐̚͝Л͌͝О̒͐̚Н͒͌̽И̐͑С̀̈́̕Ь͊͒͝", "Т͆̐͘Ы͐͆̕ П͑̒͘О̐͒͝Ж̕̕А͑͛͝Л̀̓͘Е͛̔͘Е̐̿͠Ш͐̿Ь́͐͝ О͌͌ С̀̈́͋В̾̓̕О̒͊͒Е̾͠͝М̓͐͆ В͒͘̕Ы͑̓Б̿̓̒О̓̔͠Р͝͝Е͐͊͊", "У̐̈́̿Б͊͆̓Ӥ́̈́͝Р̓͊͋А̀̕̚Й͛͒С͋́͋Я̈́̽͠ О͛͌̓Т̿͋̒С̓̈́̚Ю͊̓Д͌͌͑А͛͆̕", "У͆̔͒М̽̿̕Р͛͋͝И͊͆͝", "Б̒̐̕О͌̓Л̓͊͠Ь̈́̕͝Ш̈́̚Ё́͐ К̓̓Р͒̈́͛О̒͠В̐͘͠И͋̓͌ Б͐͘͝О͆͐̓Г̽͑У̿̐̓ К͆͋̔Р͋̓͒О͛͊͘В̒͑͠И͒͋͆", "Я̈́̐ И̓͘͠С̾͠͝П̿͝͝Е͑̚П̽̓Ё́̀̽Л͆̚Ю͒͠͝ Т͋̿͘Е̓̈́̈́Б̓̓̔Я͛͌̕", "Т̀͆͛Ы̐̾̚ Н̓͊͊И͐̈́͝К̓͋̒Т̐̚͝О͋͋͑", "Т̀̐͐Ы̒̓͘ Ж͊̾͒А͆͠Л͒͆О͋̾К̐̐̕", "С͋͆̓М̓̕̕Е͒́͝Р̒͌͝Т̓̿͝Ь͋̿ Т̾͑͝В̒͊͠О͑͐̒Е͛̈́̕ С̾͐͒П͒̓А͌͑̈́С͐͐͛Е͛̚͝Н͊̾͝Ӥ́͑͘Е͐̚͝", "Т͊͋̚Ы͑͋ Н͛͛͝Ѐ̓͠ В͋͌̔Ы̐͊͠Б͋̔͘Е̐̓͝Р̈́̽͘Ё́̒͠Ш̽̀̚Ь͛̀͘С̾͠Я̈́͊͝ О̾̈́̐Т͌́̚С́͌͘Ю̔́̀Д̾̐А͊̓̓", "П́̔͒Ӓ́͒͠Д͑̓͌И͛̀͊ Н̔͊͠И͛͐͠Ц̓̔", "П̓̕О͌̓̀Д̈́̕͝Ч͑̈́̓И͐́̽Н̐͒͘Я̓̒̓Й̈́͐͠С͑͝Я͛̔͝ Н̒̐͐А̐̿͒Ш̈́̐̚Ѐ̿̚Й̾̓̚ В̀̕О͊̕͝Л̓̕͝Е͊͊̕", "У̓̕͝М̽̈́̐Р̚͠͝И͐̽͠,͒̾̕ С̽́̀М̈́͋͊Е͊̿͝Р͌̚Д͛̔͛", "П͒̐͝Ӧ́͝Х̀͊͝В̀̓͒А͋̚Л͋̐̚Ь̒̿͛Н̾̈́͋А̔͛Я͑͒͠ П̽͒͊О̐̽͝К͛͑̔О͑͊̓Р̿͑͆Н̐̀̈́О͌̔͝С̀̽͝Т́̽Ь̀͝͝", "А̓͝Х̈́͒͠-̈́̔̕Х̾͊͝А͋̾͝-̀̓Х͐͒̾А͊̕̚-͒̓͆Х͒͋͋А͒̀͝-̈́̚̚Х̈́̓͝Ӓ́̽͛-̽͒͘Х̾̚͝А̓̒̕", "Б͒̓͋О̓͛́Л̀̒͒Ь̒͛̒Ш͑́͘Е͌̚͠ В͑͐̈́Л͑̾͑А͑͒́С͑̓Т́̔͝И͋̚͠", "Б̓̀̈́О̐͊̈́Г͒̿͝ Д̓̐А̐̓͝Л̀͊͋ -͒́͠ Б̀͛̀О͐̿͘Г̀̓͆ В̈́͆͘Ӟ́͛́Я̿͐͘Л̓̚͝",
							"Н͆̈́͠У̔͊͝Ж̾͘͝Н͌̾́О̽͑̕ Б͒̔̿О͆̈́Л̈́̾̕Ь͒̒̈́Ш͐̔͝Е͋̓ Д́̚̚У͋͊́Ш̾̈́", "В͆̿̓О̐̿'̓͠͝Х͛̚Ѐ͠͝Д͒̓͒О͛͑К͋͊͛-͛̾̕Г̿̿̿Л̒̿͘У͑̒̓Т̓͐", "В̐͋̕О́͊͛'̐̀͘Х́̀͘А͊͘͘Д͒̓͆О͋̓К̓͊͝ Г̓͌͝Р́̓͘Ѝ͌̾Ш̈́̓.͊̐ С̽́О͊͛̽Л͘̕͝ И͑̔͝Ч̓̔А͋̾̚ О́̒́Ж͌͒͝")
	// Motivation to kill!
	var/list/possible_human_phrases = list("Я убью тебя!", "Ты чё?", "Я вырву твой имплант сердца и сожгу его!", "Я выпью твою кровь!", "Я уничтожу тебя!", "Молись, сука!", "Я вырву и съем твои кишки!", "Моргало выколю!", "Эй ты!", "Я измельчу тебя на мелкие кусочки и выброшу их в чёрную дыру!", "Пошёл нахуй!", "Ты умрешь в ужасных судорогах!", "Ильс'м уль чах!", "Твое призвание - это чистить канализацию на Марсе!", "Тупое животное!", "АХ-ХА-ХА-ХА-ХА-ХА!", "Что б ты бобов объелся!", "Ёбаный в рот этого ада!", "Эй обезьяна свинорылая!", "Обабок бля!", "Ну ты и маслёнок!",\
	 						"Пиздакряк ты тупой!", "Твои потроха съедят кибер-свиньи вместе с помоями, а мозг будут разрывать на куски бездомные космо-кошки!", "Твою плоть разорвут космо-карпы, а кишки съедят мыши!", "Тупоголовый дегенерат!", "Ты никому не нужный биомусор!", "Ты тупое ничтожество!", "Лучше б ты у папы на синих трусах засох!", "ААА-Р-Р-Р-Р-Р-Г-Г-Г-Х-Х-Х!")

	// Has our being already shown its nature? Red eyes
	var/risen = FALSE
	// We have something that no one can overlook anymore. Halo
	var/ascendent = FALSE

	var/mob/camera/eminence/eminence
	var/research_forbidden = FALSE //If Eminence forbade research for fellow cultist

/datum/religion/cult/New()
	..()
	// Init anomalys
	strange_anomalies = subtypesof(/obj/structure/cult/anomaly)
	var/area/area = get_area_by_type(/area/custom/cult)
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

	RegisterSignal(area, list(COMSIG_AREA_ENTERED), PROC_REF(area_entered))
	RegisterSignal(area, list(COMSIG_AREA_EXITED), PROC_REF(area_exited))

	START_PROCESSING(SSreligion, src)

/datum/religion/cult/setup_religions()
	global.cult_religion = src

/datum/religion/cult/process()
	adjust_favor(passive_favor_gain)
	if(next_anomaly < world.time)
		create_anomalys()

	if(next_spook < world.time)
		if(!humans_in_heaven.len)
			next_spook = world.time + spook_cd
			return
		var/mob/living/carbon/human/H = pick(humans_in_heaven)
		if(!H || !H.mind)
			return
		if(H.mind.holy_role && prob(80))
			if(prob(15) && iscultist(H)) // Heal
				H.apply_damages(rand(-clamp(world.time**(1/3), 1, 30), 0), rand(-clamp(world.time**(1/3), 1, 30), 0), rand(-clamp(world.time**(1/3), 1, 30), 0))
				log_game("[H] healed by Cult Heaven")
			return

		if(prob(20)) // sound
			var/list/sounds = pick(SOUNDIN_EXPLOSION, SOUNDIN_SPARKS, SOUNDIN_FEMALE_HEAVY_PAIN, SOUNDIN_MALE_HEAVY_PAIN, SOUNDIN_SHATTER, SOUNDIN_HORROR)
			playsound(H, pick(sounds), VOL_EFFECTS_INSTRUMENT)

		else if(prob(20)) // chat_message
			to_chat(H, "<font size='15' color='red'><b>[pick(possible_god_phrases)]!</b></font>")

		else if(prob(20)) // receive damage
			H.take_overall_damage(rand(-3, clamp(world.time**(1/3), 1, 30)), rand(-3, clamp(world.time**(1/3), 1, 30)), used_weapon = "Plasma ions") // Its science, baby
			log_game("[H] attacked by Cult Heaven")

		else if(prob(15)) // Heal
			H.apply_damages(rand(-clamp(world.time**(1/3), 1, 30), 3), rand(-clamp(world.time**(1/3), 1, 30), 3), rand(-clamp(world.time**(1/3), 1, 30), 3))
			log_game("[H] healed by Cult Heaven")

		else if(prob(5)) // temp alt_apperance of humans or item
			if(prob(50))
				var/mob/living/carbon/human/target = pick(humans_in_heaven)
				var/image/I = image(icon = 'icons/mob/human.dmi', icon_state = pick("husk_s", "electrocuted_generic", "ghost", "zombie", "skeleton", "abductor_s", "electrocuted_base"), layer = INFRONT_MOB_LAYER, loc = target)
				I.override = TRUE
				target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, "nar-sie_hall", I, H)
				addtimer(CALLBACK(src, PROC_REF(remove_spook_effect), target), 3 MINUTES)
			else
				if(!H.contents.len)
					return
				var/obj/item/I = pick(H.contents)
				I.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, "nar-sie_hall", null, H, /obj/effect/decal/remains/human, I)
				addtimer(CALLBACK(src, PROC_REF(remove_spook_effect), I), 3 MINUTES)


		else if(prob(1)) // temp alt_apperance of nar-sie
			if(!altars.len)
				return
			var/obj/structure/altar_of_gods/altar = pick(altars)
			altar.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, "nar-sie_hall", null, H, /atom/movable/narsie, altar)
			addtimer(CALLBACK(src, PROC_REF(remove_spook_effect), altar), 10 MINUTES)

		else if(prob(1)) // 6/100000000 chance, or 0,000006% wow
			H.say(pick(possible_human_phrases))

		removeNullsFromList(humans_in_heaven)
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
		if(isenvironmentturf(T))
			continue
		var/anom = pick(strange_anomalies)
		var/rand_time = force ? 0 : rand(1 SECOND, 1 MINUTE)
		time += rand_time
		addtimer(CALLBACK(src, PROC_REF(create_anomaly), anom, T, C), rand_time)

	if(!force)
		next_anomaly = world.time + spawn_anomaly_cd + time

/datum/religion/cult/proc/create_anomaly(type, turf/T, datum/coords/C)
	new type(T)
	C.x_pos = T.x
	C.y_pos = T.y
	C.z_pos = T.z

/datum/religion/cult/proc/remove_spook_effect(atom/A)
	A.remove_alt_appearance("nar-sie_hall")

/datum/religion/cult/on_entry(mob/M)
	var/obj/effect/proc_holder/spell/targeted/communicate/spell = locate(/obj/effect/proc_holder/spell/targeted/communicate) in M.spell_list
	if(spell)
		M.RemoveSpell(spell)

	var/type
	if(ishuman(M))
		type = /obj/effect/proc_holder/spell/targeted/communicate/fastener
	else
		type = /obj/effect/proc_holder/spell/targeted/communicate

	M.AddSpell(new type(src))

/datum/religion/cult/can_convert(mob/M)
	if(M.my_religion)
		return FALSE
	if(M.stat == DEAD)
		return FALSE
	if(jobban_isbanned(M, ROLE_CULTIST) || jobban_isbanned(M, "Syndicate")) // Nar-sie will punish people with a jobban, it's funny (used for objective)
		return FALSE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.flags[NO_BLOOD])
			return FALSE
	if(M.ismindprotect())
		return FALSE
	return TRUE

/datum/religion/cult/add_member(mob/M, holy_role)
	if(!..())
		return FALSE
	if(!M.mind?.GetRole(CULTIST))
		add_faction_member(mode, M, TRUE)
	handle_appearence(M)
	ADD_TRAIT(M, TRAIT_HEALS_FROM_PYLONS, RELIGION_TRAIT)
	M.update_alt_apperance_by(/datum/atom_hud/alternate_appearance/basic/my_religion)
	return TRUE

/datum/religion/cult/proc/handle_appearence(mob/M)
	if(risen)
		rise(M) //No return here

	if(ascendent) //To avoid useless counts through all players in Nar-Nar stage
		ascend(M)
		return

	var/alive = 0
	var/cultplayers = 0
	for(var/mob/living/P in player_list)
		if(P.stat != DEAD)
			if(iscultist(P))
				++cultplayers
			else
				++alive

	if(cultplayers == 0 || alive == 0) //Just in case to avoid 0
		return
	var/ratio = cultplayers / alive
	if(ratio > 0.25 && !risen) //Red eye check
		first_rise()
	if(ratio > 0.4 && !ascendent) //Halo check
		first_ascend()

	return TRUE

/datum/religion/cult/proc/first_rise()
	for(var/mob/living/L in members)
		playsound(L, 'sound/hallucinations/i_see_you_2.ogg', VOL_EFFECTS_MASTER)
		to_chat(L, "<span class='cult'>Культ набирает силы, вуаль реальности всё слабее, ваши глаза начинают светиться...</span>")
		rise(L)
	risen = TRUE
	log_game("The blood cult has risen with [length(members)] players.")

/datum/religion/cult/proc/first_ascend()
	for(var/mob/living/L in members)
		playsound(L, 'sound/hallucinations/im_here1.ogg', VOL_EFFECTS_MASTER)
		to_chat(L, "<span class='cult'>Культ всё сильнее, и приближается жатва - вы не можете больше скрывать свою истинную природу!</span>")
		ascend(L)
	ascendent = TRUE
	log_game("The blood cult has ascended with [length(members)] players.")

/datum/religion/cult/proc/rise(cultist)
	if(isliving(cultist))
		var/mob/living/L = cultist
		L.AddElement(/datum/element/cult_eyes)

/datum/religion/cult/proc/ascend(cultist)
	if(isliving(cultist))
		var/mob/living/L = cultist
		L.AddElement(/datum/element/cult_halo)

/datum/religion/cult/add_deity(mob/M)
	..()
	if(!M.mind?.GetRole(CULTIST))
		add_faction_member(mode, M, TRUE)

/datum/religion/cult/on_exit(mob/M)
	for(var/obj/effect/proc_holder/spell/targeted/communicate/C in M.spell_list)
		M.RemoveSpell(C)

	if(!isliving(M))
		return
	var/mob/living/L = M
	if(HAS_TRAIT(L, TRAIT_CULT_EYES))
		L.RemoveElement(/datum/element/cult_eyes)
	if(HAS_TRAIT(L, TRAIT_CULT_HALO))
		L.RemoveElement(/datum/element/cult_halo)
	M.update_alt_apperance_by(/datum/atom_hud/alternate_appearance/basic/my_religion)
