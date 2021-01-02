
/proc/iscultist(mob/living/M)
	return M && global.cult_religion && (M in global.cult_religion.members)

//Possibles objections
#define SACRIFICE "sacrifice"
#define SUMMON_GOD "summon eldergod"
#define RECRUIT "recruit more people"
#define PIETY "save up piety"
#define CAPTURE "capture a station"

/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	role_type = ROLE_CULTIST
	restricted_jobs = list("Security Cadet", "Chaplain", "AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Internal Affairs Agent")
	protected_jobs = list()
	// TEST FOR DEBUGGING OF THE GAME OF CULT OF BLOOD
	required_players = 0
	required_players_bundles = 0
	// REMEMBER IT!!!!
	required_enemies = 0
	recommended_enemies = 1

	antag_hud_type = ANTAG_HUD_CULT
	antag_hud_name = "hudcultist"

	votable = 0

	uplink_welcome = "Nar-Sie Uplink Console:"
	uplink_uses = 20

	restricted_species_flags = list(NO_BLOOD)

	var/datum/religion/cult/religion

	var/datum/mind/sacrifice_target = null
	var/list/datum/mind/started_cultists = list()

	var/list/objectives = list()
	var/list/sacrificed = list()

	var/eldergod = 1 //for the summon god objective
	var/eldertry = 0

	var/acolytes_needed = 5 //for the survive objective
	var/acolytes_out = 0

	var/piety_needed = 0 // for objective

	var/need_capture = 4 // areas

	var/list/possibles_objectives = list(RECRUIT, SACRIFICE, CAPTURE, SUMMON_GOD, PIETY)

/datum/game_mode/cult/announce()
	to_chat(world, "<B>Текущий режим игры - Культ!</B>")
	to_chat(world, "<B>Некоторые члены экипажа прибыли на станцию, состоя в культе!<BR>\nКультисты - выполняют свои задачи. Заставляйте людей последовать за вами любыми способами. Перемещайте смертных в своё измерение насильно. Запомни - тебя нет, есть только культ.<BR>\nПерсонал - не знает о культе, но при обнаружении кровавых рун и фанатиков будет сопротивляться. Хороший способ борьбы с фанатиками - это промывка мозгов Библией священника в разрешенную ЦентКоммом религию.</B>")

/datum/game_mode/cult/pre_setup()
	if(!config.objectives_disabled)
		for(var/i in 1 to rand(2, 3))
			var/object = pick_n_take(possibles_objectives)
			objectives += object

			if(object == SUMMON_GOD)
				possibles_objectives -= PIETY
			else if(object == PIETY)
				possibles_objectives -= SUMMON_GOD

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

	for(var/obj in objectives)
		switch(obj)
			if(SACRIFICE)
				var/list/possible_targets = get_unconvertables()
				listclearnulls(possible_targets)

				if(!possible_targets.len)
					for(var/mob/living/carbon/human/player in player_list)
						if(player.mind && !(player.mind in started_cultists))
							possible_targets += player.mind
				listclearnulls(possible_targets)

				if(possible_targets.len)
					sacrifice_target = pick(possible_targets)

			if(RECRUIT)
				acolytes_needed = max(4, round(player_list.len * 0.1))

			if(PIETY)
				piety_needed = round(player_list.len * 10)

	for(var/datum/mind/cult_mind in started_cultists)
		religion.add_member(cult_mind.current, HOLY_ROLE_HIGHPRIEST)
		equip_cultist(cult_mind.current)
		to_chat(cult_mind.current, "<span class = 'info'><b>Вы член <font color='red'>культа</font>!</b></span>")

		if(!config.objectives_disabled)
			memoize_cult_objectives(cult_mind)
		else
			to_chat(cult_mind.current, "<span class ='blue'>Within the rules,</span> try to act as an opposing force to the crew. Further RP and try to make sure other players have fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>")

		cult_mind.special_role = "Cultist"
		add_antag_hud(antag_hud_type, antag_hud_name, cult_mind.current)

	return ..()

/datum/game_mode/cult/proc/memoize_cult_objectives(datum/mind/cult_mind)
	for(var/obj_count in 1 to objectives.len)
		var/explanation
		switch(objectives[obj_count])
			if(RECRUIT)
				explanation = "Наши знания должны жить. Убедитесь, что хотя бы [acolytes_needed] культистов улетят на шаттле, чтобы проложить исследования на других станциях."
			if(SACRIFICE)
				if(sacrifice_target)
					explanation = "Принесите в жертву [sacrifice_target.name], [sacrifice_target.assigned_role]. Для этого вам понадобится аспект Mortem."
				else
					explanation = "Свободная задача."
			if(SUMMON_GOD)
				explanation = "Призовите Нар-Си с помощью ритуала с пьедесталами на станции. Он будет работать только в том случае, если девять культистов встанут внутри структуры с 12 пьедесталами."
			if(CAPTURE)
				explanation = "Захватите не менее [need_capture] отсеков станции с помощью руны захвата зон."
			if(PIETY)
				explanation = "Накопите и сохраните [piety_needed] piety"
		to_chat(cult_mind.current, "<B>Objective #[obj_count]</B>: [explanation]")
		cult_mind.memory += "<B>Objective #[obj_count]</B>: [explanation]<BR>"

/datum/game_mode/proc/equip_cultist(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.mind)
		if(H.mind.assigned_role == "Clown")
			to_chat(H, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			H.mutations.Remove(CLUMSY)

	global.cult_religion.give_tome(H)

/datum/game_mode/proc/add_cultist(datum/mind/cult_mind) //BASE
	if(!istype(cult_mind))
		return FALSE

	if(!global.cult_religion)
		create_religion(/datum/religion/cult)

	if(global.cult_religion.mode.is_convertable_to_cult(cult_mind))
		if(global.cult_religion.add_member(cult_mind.current, HOLY_ROLE_HIGHPRIEST))
			cult_mind.current.Paralyse(5)
			add_antag_hud(ANTAG_HUD_CULT, "hudcultist", cult_mind.current)
			return TRUE

/datum/game_mode/cult/add_cultist(datum/mind/cult_mind) //INHERIT
	if (!..(cult_mind))
		return
	if (!config.objectives_disabled)
		memoize_cult_objectives(cult_mind)

/datum/game_mode/proc/remove_cultist(datum/mind/cult_mind, show_message = 1)
	if(global.cult_religion.remove_member(cult_mind.current))
		remove_antag_hud(ANTAG_HUD_CULT, cult_mind.current)
		cult_mind.current.Paralyse(5)
		to_chat(cult_mind.current, "<span class='danger'><FONT size = 3>An unfamiliar white light flashes through your mind, cleansing the taint of the dark-one and the memories of your time as his servant with it.</span></FONT>")
		cult_mind.memory = ""
		if(show_message)
			cult_mind.current.visible_message("<span class='danger'><FONT size = 3>[cult_mind.current] looks like they just reverted to their old faith!</span></FONT>")

/datum/game_mode/cult/proc/is_convertable_to_cult(datum/mind/mind)
	if(!istype(mind))
		return FALSE
	if(ishuman(mind.current))
		if(mind.assigned_role == "Captain")
			return FALSE
		if(istype(mind.current.my_religion, /datum/religion/chaplain))
			return FALSE
		if(mind.current.get_species() == GOLEM)
			return FALSE
	if(ismindshielded(mind.current) || isloyal(mind.current))
		return FALSE
	return TRUE

/datum/game_mode/cult/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in human_list)
		if(!is_convertable_to_cult(player.mind))
			ucs += player.mind
	return ucs

/datum/game_mode/cult/proc/check_cult_victory()
	var/cult_fail = 0
	for(var/obj in objectives)
		switch(obj)
			if(RECRUIT)
				cult_fail += check_survive() //the proc returns 1 if there are not enough cultists on the shuttle, 0 otherwise
			if(SUMMON_GOD)
				cult_fail += eldergod //1 by default, 0 if the elder god has been summoned at least once
			if(SACRIFICE)
				if(sacrifice_target && !sacrificed.Find(sacrifice_target)) //if the target has been sacrificed, ignore this step. otherwise, add 1 to cult_fail
					cult_fail++
			if(CAPTURE)
				if(!check_capture())
					cult_fail++
			if(PIETY)
				if(religion.piety < piety_needed)
					cult_fail++

	return cult_fail //if any objectives aren't met, failure

/datum/game_mode/cult/proc/check_survive()
	for(var/mob/cultist in religion.members)
		if(cultist?.stat != DEAD)
			var/area/A = get_area(cultist)
			if(is_type_in_typecache(A, centcom_areas_typecache))
				acolytes_out++
	if(acolytes_out >= acolytes_needed)
		return FALSE
	return TRUE

/datum/game_mode/cult/proc/check_capture()
	var/list/areas = get_areas(/area/station/)
	var/captured_areas = 0
	for(var/area/A in areas)
		if(istype(A.religion, /datum/religion/cult))
			captured_areas++
	if(captured_areas >= need_capture)
		return TRUE
	return FALSE

/datum/game_mode/cult/declare_completion()
	if(config.objectives_disabled)
		return TRUE
	completion_text += "<h3>Результаты Культа:</h3>"
	if(!check_cult_victory())
		mode_result = "победа - культ выйграл"
		feedback_set_details("round_end_result", mode_result)
		feedback_set("round_end_result", acolytes_out)
		completion_text += "<span class='color: red; font-weight: bold;'>Культ <span style='color: green'>выйгал</span>! Рабы преуспели в служении своим темным хозяевам!</span><br>"
		score["roleswon"]++
	else
		mode_result = "поражение - персонал остановил культ"
		feedback_set_details("round_end_result", mode_result)
		feedback_set("round_end_result", acolytes_out)
		completion_text += "<span class='color: red; font-weight: bold;'>Персонал смог остановить культ!</span><br>"

	var/text = "<b>Культистов улетело:</b> [acolytes_out]"
	if(!config.objectives_disabled)
		if(objectives.len)
			text += "<br><b>Целями культистов было:</b>"
			for(var/obj_count in 1 to objectives.len)
				var/explanation
				switch(objectives[obj_count])
					if(RECRUIT)
						if(!check_survive())
							explanation = "Убедитесь, что хотя бы [acolytes_needed] улетят на шаттле. <span style='color: green; font-weight: bold;'>Успех!</span>"
							feedback_add_details("cult_objective","cult_survive|SUCCESS|[acolytes_needed]")
						else
							explanation = "Убедитесь, что хотя бы [acolytes_needed] улетят на шаттле. <span style='color: red; font-weight: bold;'>Провал.</span>"
							feedback_add_details("cult_objective","cult_survive|FAIL|[acolytes_needed]")
					if(SACRIFICE)
						if(sacrifice_target)
							if(sacrifice_target in sacrificed)
								explanation = "Принесите в жертву [sacrifice_target.name], [sacrifice_target.assigned_role]. <span style='color: green; font-weight: bold;'>Успех!</span>"
								feedback_add_details("cult_objective","cult_sacrifice|SUCCESS")
							else if(sacrifice_target && sacrifice_target.current)
								explanation = "Принесите в жертву [sacrifice_target.name], [sacrifice_target.assigned_role]. <span style='color: red; font-weight: bold;'>Провал.</span>"
								feedback_add_details("cult_objective","cult_sacrifice|FAIL")
							else
								explanation = "Принесите в жертву [sacrifice_target.name], [sacrifice_target.assigned_role]. <span style='color: red; font-weight: bold;'>Провал (Тело уничтожено).</span>"
								feedback_add_details("cult_objective","cult_sacrifice|FAIL|GIBBED")
						else
							explanation = "Свободная цель. <span style='color: green; font-weight: bold;'>Успех!</span>"
							feedback_add_details("cult_objective","cult_free_objective|SUCCESS")
					if(SUMMON_GOD)
						if(!eldergod)
							explanation = "Призовите Нар-Си. <span style='color: green; font-weight: bold;'>Успех!</span>"
							feedback_add_details("cult_objective","cult_narsie|SUCCESS")
						else
							explanation = "Призовите Нар-Си. <span style='color: red; font-weight: bold;'>Провал.</span>"
							feedback_add_details("cult_objective","cult_narsie|FAIL")
					if(CAPTURE)
						if(check_capture())
							explanation = "Захватите не менее [need_capture]% станции. <span style='color: green; font-weight: bold;'>Успех!</span>"
							feedback_add_details("cult_objective","cult_capture|SUCCESS")
						else
							explanation = "Захватите не менее [need_capture]% станции. <span style='color: red; font-weight: bold;'>Провал.</span>"
							feedback_add_details("cult_objective","cult_capture|FAIL")
					if(PIETY)
						if(religion.piety >= piety_needed)
							explanation = "Накопите и сохраните [piety_needed] piety. <span style='color: green; font-weight: bold;'>Успех!</span>"
							feedback_add_details("cult_objective","cult_piety|SUCCESS")
						else
							explanation = "Накопите и сохраните [piety_needed] piety. <span style='color: red; font-weight: bold;'>Провал.</span>"
							feedback_add_details("cult_objective","cult_piety|FAIL")
				text += "<br><b>Задача #[obj_count]</b>: [explanation]"

	completion_text += text
	..()
	return TRUE

/datum/game_mode/proc/auto_declare_completion_cult()
	var/text = ""
	if(global.cult_religion.members.len)
		text += printlogo("cult", "cultists")
		for(var/mob/cultist in global.cult_religion.members)
			if(cultist.mind)
				text += printplayerwithicon(cultist.mind)

	if(text)
		antagonists_completion += list(list("mode" = "cult", "html" = text))
		text = "<div class='Section'>[text]</div>"

	return text

#undef SACRIFICE
#undef SUMMON_GOD
#undef RECRUIT
#undef PIETY
#undef CAPTURE
