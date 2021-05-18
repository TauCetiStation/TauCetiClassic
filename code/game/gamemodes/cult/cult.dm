
/proc/iscultist(mob/M)
	return M && global.cult_religion && global.cult_religion.is_member(M)

/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	role_type = ROLE_CULTIST
	restricted_jobs = list("Security Cadet", "Chaplain", "AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Internal Affairs Agent")
	protected_jobs = list()

	required_players = 5
	required_players_bundles = 20

	required_enemies = 3
	recommended_enemies = 3

	antag_hud_type = ANTAG_HUD_CULT
	antag_hud_name = "hudcultist"
	var/leader_hud_name = "hudheadcultist"

	votable = 0

	uplink_welcome = "Nar-Sie Uplink Console:"
	uplink_uses = 20

	restricted_species_flags = list(NO_BLOOD)

	var/datum/religion/cult/religion
	var/list/datum/mind/started_cultists = list()

	// For objectives
	var/datum/mind/sacrifice_target = null
	var/list/sacrificed = list()

	var/list/datum/objective/objectives = list()

	var/eldergod = FALSE //for the summon god objective
	var/check_leader_time

/datum/game_mode/cult/announce()
	to_chat(world, "<B>Текущий режим игры - Культ!</B>")
	to_chat(world, "<B>Некоторые члены экипажа прибыли на станцию, состоя в культе!</B>")
	to_chat(world, "<B>Культисты - сеют хаос. Заставляйте людей последовать за вами любыми способами. Перемещайте смертных в своё измерение насильно. Запомни - тебя нет, есть только культ.</B>")
	to_chat(world, "<B>Персонал - не знает о культе, но при обнаружении кровавых рун и фанатиков будет сопротивляться. Хороший способ борьбы с фанатиками - это промывка мозгов Библией священника в разрешенную ЦентКоммом религию.</B>")

/datum/game_mode/cult/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	for(var/datum/mind/player in antag_candidates)
		if(player.assigned_role in restricted_jobs)	//Removing heads and such from the list
			antag_candidates -= player

	for(var/cultists_number = 1 to recommended_enemies)
		if(!antag_candidates.len)
			break
		var/datum/mind/cultist = pick(antag_candidates)
		antag_candidates -= cultist
		started_cultists += cultist

	return (started_cultists.len >= required_enemies)

/datum/game_mode/cult/post_setup()
	religion = create_religion(/datum/religion/cult)
	modePlayer += started_cultists
	if(!config.objectives_disabled)
		generate_objectives()

	var/datum/mind/leader = pick(started_cultists)
	started_cultists -= leader
	leader_setup(leader)

	for(var/datum/mind/cult_mind in started_cultists)
		cultist_setup(cult_mind)

	return ..()

/datum/game_mode/cult/proc/cultist_setup(datum/mind/cult_mind)
	religion.add_member(cult_mind.current, CULT_ROLE_HIGHPRIEST)
	add_antag_hud(antag_hud_type, antag_hud_name, cult_mind.current)

	equip_cultist(cult_mind.current)
	to_chat(cult_mind.current, "<span class = 'info'><b>Вы член <font color='red'>культа</font>!</b></span>")

	if(!config.objectives_disabled)
		memoize_cult_objectives(cult_mind)
	else
		to_chat(cult_mind.current, "<span class ='blue'>Не нарушайте правила и по любому вопросу пишите в adminhelp.</span>")

/datum/game_mode/cult/proc/leader_setup(datum/mind/leader)
	religion.add_member(leader.current, CULT_ROLE_MASTER)
	add_antag_hud(antag_hud_type, leader_hud_name, leader.current)

	equip_cultist_leader(leader.current)
	to_chat(leader.current, "<span class = 'info'><b>Вы <span class='cult'>лидер</span> <font color='red'>культа</font>!</b></span>")

	if(!config.objectives_disabled)
		memoize_cult_objectives(leader)
	else
		to_chat(leader.current, "<span class ='blue'>Не нарушайте правила и по любому вопросу пишите в adminhelp.</span>")

/datum/game_mode/cult/proc/generate_objectives()
	var/list/possibles_objectives = subtypesof(/datum/objective/cult)
	for(var/i in 1 to rand(2, 3))
		var/type = pick_n_take(possibles_objectives)
		var/datum/objective/cult/objective = new type(null, src)
		objectives += objective

/datum/game_mode/cult/proc/memoize_cult_objectives(datum/mind/cult_mind)
	var/obj_count = 1
	for(var/datum/objective/O in objectives)
		to_chat(cult_mind.current, "<B>Задача #[obj_count]</B>: [O.explanation_text]")
		cult_mind.memory += "<B>Задача #[obj_count]</B>: [O.explanation_text]<BR>"
		obj_count++

	cult_mind.special_role = "Cultist"

/datum/game_mode/cult/proc/equip_cultist_leader(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.mind)
		if(H.mind.assigned_role == "Clown")
			to_chat(H, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			H.mutations.Remove(CLUMSY)

	H.equip_to_slot_or_del(new /obj/item/device/cult_camera(H), SLOT_IN_BACKPACK)

	global.cult_religion.give_tome(H)

/datum/game_mode/proc/equip_cultist(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.mind)
		if(H.mind.assigned_role == "Clown")
			to_chat(H, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			H.mutations.Remove(CLUMSY)

	H.equip_to_slot_or_del(new /obj/item/device/cult_camera(H), SLOT_IN_BACKPACK)

	global.cult_religion.give_tome(H)

/datum/game_mode/proc/add_cultist(datum/mind/cult_mind) //BASE
	if(!istype(cult_mind))
		return FALSE

	if(!global.cult_religion)
		create_religion(/datum/religion/cult)

	if(global.cult_religion.add_member(cult_mind.current, CULT_ROLE_HIGHPRIEST))
		cult_mind.current.Paralyse(5)
		add_antag_hud(ANTAG_HUD_CULT, "hudcultist", cult_mind.current)
		return TRUE

/datum/game_mode/cult/add_cultist(datum/mind/cult_mind) //INHERIT
	if (!..(cult_mind))
		return
	if (!config.objectives_disabled)
		memoize_cult_objectives(cult_mind)

/datum/game_mode/proc/remove_cultist(datum/mind/cult_mind, show_message = TRUE)
	if(global.cult_religion?.remove_member(cult_mind.current))
		remove_antag_hud(ANTAG_HUD_CULT, cult_mind.current)
		cult_mind.current.Paralyse(5)
		to_chat(cult_mind.current, "<span class='danger'><FONT size = 3>Незнакомый белый свет очищает твой разум от порчи и воспоминаний, когда ты был Его слугой.</span></FONT>")
		cult_mind.memory = ""
		if(show_message)
			cult_mind.current.visible_message("<span class='danger'><FONT size = 3>[cult_mind.current] выглядит так, будто вернулся к своей старой вере!</span></FONT>")

/datum/game_mode/cult/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in player_list)
		if(!global.cult_religion?.can_convert(player))
			ucs += player.mind
	return ucs

/datum/game_mode/cult/proc/check_cult_victory()
	for(var/datum/objective/O in objectives)
		if(!O.check_completion())
			return FALSE

	return TRUE

/datum/game_mode/cult/proc/find_sacrifice_target()
	var/list/possible_targets = get_unconvertables()

	if(possible_targets.len)
		for(var/datum/mind/M in possible_targets)
			if(M in started_cultists)
				possible_targets -= M

	if(possible_targets.len)
		sacrifice_target = pick(possible_targets)

/datum/game_mode/cult/declare_completion()
	if(config.objectives_disabled)
		return TRUE
	completion_text += "<h3>Результаты Культа:</h3>"
	if(check_cult_victory())
		mode_result = "win - cult win"
		feedback_set_details("round_end_result", mode_result)
		completion_text += "<span class='color: red; font-weight: bold;'>Культ <span style='color: green'>выиграл</span>! Рабы преуспели в служении своим темным хозяевам!</span><br>"
		score["roleswon"]++
	else
		mode_result = "loss - staff can stop cult"
		feedback_set_details("round_end_result", mode_result)
		completion_text += "<span class='color: red; font-weight: bold;'>Персонал смог остановить культ!</span><br>"

	var/acolytes_out = get_cultists_out()
	var/text = "<b>Культистов улетело:</b> [acolytes_out]"
	feedback_set("round_end_result", acolytes_out)
	if(!config.objectives_disabled)
		text += "<br><b>Целями культистов было:</b>"
		var/obj_count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				text += "<br><b>Задача #[obj_count]</b>: [objective.explanation_text] <span style='color: green; font-weight: bold;'>Успех!</span>"
				feedback_add_details("cult_objective","[objective.type]|SUCCESS")
			else
				text += "<br><b>Задача #[obj_count]</b>: [objective.explanation_text] <span style='color: red; font-weight: bold;'>Провал.</span>"
				feedback_add_details("cult_objective","[objective.type]|FAIL")
			obj_count++

	text += "<br><b>Аспекты([global.cult_religion.aspects.len]):</b>"
	if(!global.cult_religion.aspects.len)
		text += "<br>Ниодного аспекта не было выбрано"
	else
		for(var/name in global.cult_religion.aspects)
			var/datum/aspect/A = global.cult_religion.aspects[name]
			text += "<br><font color='[A.color]'>[name]</font> - с силой [A.power]"

	text += "<br><br><b>Ритуалы:</b>"
	if(!global.cult_religion.ritename_by_count.len)
		text += "<br>Ниодного ритуала не было выбрано"
	else
		for(var/name in global.cult_religion.ritename_by_count)
			var/count = global.cult_religion.ritename_by_count[name]
			text += "<br><i>[name]</i> - использован [count] [russian_plural(count, "раз", "раза", "раз")]"

	completion_text += text
	..()
	return TRUE

/datum/game_mode/cult/modestat()
	var/dat = ""

	dat += {"<B><U>MODE STATS</U></B><BR>
	<B>Всего членов Культа:</B> [religion.members.len]<BR>
	<B>Захвачено зон:</B> [religion.captured_areas.len - religion.area_types.len]<BR>
	<B>Накоплено Favor/Piety:</B> [religion.favor]/[religion.piety]<BR>
	<B>Рун на станции:</B> [religion.runes.len]<BR>
	<B>Аномалий уничтожено:</B> [score["destranomaly"]]<BR>
	<HR>"}

	return dat

#define CHECK_LEADER_CD 50
/datum/game_mode/cult/process()
	if(check_leader_time < world.time)
		check_leader_time = world.time + CHECK_LEADER_CD
		var/leader = FALSE
		for(var/mob/living/carbon/human/M in religion.members)
			if(M && M.client && M.client.inactivity <= 20 MINUTES && M.mind?.holy_role == CULT_ROLE_MASTER) // 20 minutes inactivity are OK
				leader = TRUE
				break

		if(!leader)
			log_debug("There are zero active leaders of cult, trying to add some..")
			var/added_lead = FALSE
			for(var/mob/living/carbon/human/H in religion.members)
				if(H.stat != DEAD && H.client?.inactivity <= 20 MINUTES && H.mind?.holy_role != CULT_ROLE_MASTER)
					H.mind.holy_role = CULT_ROLE_MASTER
					add_antag_hud(antag_hud_type, leader_hud_name, H)

					to_chat(H, "<span class='warning'>Вы теперь новый лидер культа.</span>")
					added_lead = TRUE
					break

			if(added_lead)
				log_admin("Managed to add new leaders of cult.")
				message_admins("Managed to add new leaders of cult.")
			else
				log_admin("Unable to add new leaders of cult.")
				message_admins("Unable to add new leaders of cult.")
				check_leader_time = world.time + 10 MINUTE

/datum/game_mode/proc/auto_declare_completion_cult()
	var/text = ""
	if(global.cult_religion?.members.len)
		text += printlogo("cult", "cultists")
		for(var/datum/mind/cult_mind in global.cult_religion.members_minds)
			if(cult_mind)
				text += printplayerwithicon(cult_mind)

	if(text)
		antagonists_completion += list(list("mode" = "cult", "html" = text))
		text = "<div class='Section'>[text]</div>"

	return text

/datum/game_mode/cult/proc/get_cultists_out()
	var/acolytes_out = 0
	for(var/mob/cultist in religion.members)
		if(cultist?.stat != DEAD)
			var/area/A = get_area(cultist)
			if(is_type_in_typecache(A, centcom_areas_typecache))
				acolytes_out++

	return acolytes_out
