var/global/allowed_ert_teams = list()
var/global/can_call_ert

/datum/response_team
	var/name = ""
	var/spawner = /datum/spawner/responders
	var/spawners_amount = 6
	var/faction = /datum/faction/responders
	var/probability = 0
	var/fixed_objective = null

/proc/populate_response_teams()
	if(length(allowed_ert_teams)) //It's already been set up.
		return

	var/list/erts = subtypesof(/datum/response_team)
	if(!length(erts))
		CRASH("No ERT Datums found.")

	for(var/x in erts)
		var/datum/response_team/D = new x()
		if(!D.name)
			continue //The default parent, don't add it
		allowed_ert_teams += D

/client/proc/response_team()
	set name = "Dispatch Emergency Response Team"
	set category = "Special Verbs"
	set desc = "Отправляет отряд быстрого реагирования на станцию."

	if(!holder)
		to_chat(usr, "<span class='warning'>Только администрация может использовать это.</span>")
		return
	if(!SSticker)
		to_chat(usr, "<span class='warning'>Игра еще не загрузилась!</span>")
		return
	if(SSticker.current_state == 1)
		to_chat(usr, "<span class='warning'>Раунд еще не начался!</span>")
		return
	if(SSticker.ert_call_in_progress)
		to_chat(usr, "<span class='warning'>Центральное Командование уже отправило отряд быстрого реагирования!</span>")
		return
	if(tgui_alert(usr, "Вы хотите отправить отряд быстрого реагирования?",, list("Да","Нет")) != "Да")
		return
	if(get_security_level() != "red") // Allow admins to reconsider if the alert level isn't Red

		if(tgui_alert(usr, "На станции не введён красный код. Вы всё ещё хотите отправить отряд быстрого реагирования?",, list("Да","Нет")) != "Да")
			return

	if(SSticker.ert_call_in_progress)
		to_chat(usr, "<span class='warning'>Похоже, кто-то уже опередил вас!</span>")
		return

	message_admins("[key_name_admin(usr)] is dispatching an Emergency Response Team.")
	log_admin("[key_name(usr)] used Dispatch Response Team with objective.")
	feedback_set_details("ERT", "Admin dispatch")
	trigger_armed_response_team(1)


/proc/trigger_armed_response_team(force = 0)
	if(!can_call_ert && !force)
		return 0
	if(SSticker.ert_call_in_progress)
		return 0

	var/datum/response_team/team
	var/confirm = tgui_alert(usr, "Хотите указать, какой ОБР вызвать?", "ОБР", list("Да", "Случайный", "Отмена"))
	if(confirm == "Отмена")
		return
	if(confirm == "Случайный")
		team = get_random_responders()

	if(confirm == "Да")
		var/choice = input("Какой?") as anything in allowed_ert_teams
		team = choice
	var/changing_objective = FALSE
	var/custom_objective = "Помогите экипажу станции"
	if(team.fixed_objective)
		var/objective_choice = tgui_alert(usr, "У этого ОБР есть предусмотренная задача. Хотите поменять?", "ERT", list("Нет", "Да"))
		if(objective_choice == "Да")
			changing_objective = TRUE
			custom_objective = sanitize(input(usr, "Какая задача будет у ОБР?", "Настройка цели", "Помогите экипажу станции"))
	else
		custom_objective = sanitize(input(usr, "Какая задача будет у ОБР?", "Настройка цели", "Помогите экипажу станции"))
		changing_objective = TRUE

	create_spawners(team.spawner, team.spawners_amount)
	var/datum/faction/responders/ERT = SSticker.mode.CreateFaction(team.faction)
	if(changing_objective)
		var/datum/objective/custom/C = new /datum/objective/custom
		C.explanation_text = custom_objective
		ERT.AppendObjective(C)
	else
		ERT.AppendObjective(team.fixed_objective)

	var/datum/announcement/centcomm/ert/announcement = new
	announcement.play()

/client/proc/create_human_apperance(mob/living/carbon/human/H, _name, allow_name_choice = FALSE)
	//todo: god damn this.
	//make it a panel, like in character creation
	//upd: please (also as option we can take current character from client preferences)
	if(allow_name_choice)
		_name = sanitize_name(input(src, "Выберите имя.", "Создание персонажа", _name))

	var/new_facial = input(src, "Выберите цвет растительности на лице.", "Создание персонажа") as color
	if(new_facial)
		H.r_facial = hex2num(copytext(new_facial, 2, 4))
		H.g_facial = hex2num(copytext(new_facial, 4, 6))
		H.b_facial = hex2num(copytext(new_facial, 6, 8))

	var/new_hair = input(src, "Выберите цвет прически.", "Создание персонажа") as color
	if(new_facial)
		H.r_hair = hex2num(copytext(new_hair, 2, 4))
		H.g_hair = hex2num(copytext(new_hair, 4, 6))
		H.b_hair = hex2num(copytext(new_hair, 6, 8))

	var/new_eyes = input(src, "Выберите цвет глаз.", "Создание персонажа") as color
	if(new_eyes)
		H.r_eyes = hex2num(copytext(new_eyes, 2, 4))
		H.g_eyes = hex2num(copytext(new_eyes, 4, 6))
		H.b_eyes = hex2num(copytext(new_eyes, 6, 8))

	var/new_tone = input(src, "Выберите тон кожи: 1-220 (1=альбинос, 35=белый, 150=чёрный, 220='очень' чёрный)", "Создание персонажа")  as text

	if (!new_tone)
		new_tone = 35
	H.s_tone = max(min(round(text2num(new_tone)), 220), 1)
	H.s_tone = -H.s_tone + 35

	// hair
	var/list/all_hairs = subtypesof(/datum/sprite_accessory/hair)
	var/list/hairs = list()

	// loop through potential hairs
	for(var/x in all_hairs)
		var/datum/sprite_accessory/hair/hair = new x // create new hair datum based on type x
		hairs.Add(hair.name) // add hair name to hairs
		qdel(hair) // delete the hair after it's all done

	var/new_gender = tgui_alert(src, "Выберите пол.", "Создание персонажа", list("Мужской", "Женский"))
	if (new_gender)
		if(new_gender == "Мужской")
			H.gender = MALE
		else
			H.gender = FEMALE

	//hair
	var/new_hstyle = input(src, "Выберите прическу", "Внешность")  as null|anything in get_valid_styles_from_cache(hairs_cache, H.get_species(), H.gender)
	if(new_hstyle)
		H.h_style = new_hstyle

	// facial hair
	var/new_fstyle = input(src, "Выберите стиль растительности на лице", "Внешность")  as null|anything in get_valid_styles_from_cache(facial_hairs_cache, H.get_species(), H.gender)
	if(new_fstyle)
		H.f_style = new_fstyle

	H.apply_recolor()
	H.update_hair()
	H.update_body()
	H.check_dna(H)

	if(!_name)
		var/first_name = H.gender == FEMALE ? pick(global.first_names_female) : pick(global.first_names_male)
		_name = "[first_name] [pick(global.last_names)]"

	H.real_name = _name
	H.name = _name
	if(H.mind)
		H.mind.name = _name
	H.age = rand(H.species.min_age, H.species.min_age * 1.25)

	H.dna.ready_dna(H)//Creates DNA.


/proc/get_random_responders()
	var/datum/response_team/chosen_team
	var/list/valid_teams = list()

	for(var/datum/response_team/T in allowed_ert_teams) //Loop through all potential candidates
		if(T.probability < 1) //Those that are meant to be admin-only
			continue

		valid_teams.Add(T)

		if(prob(T.probability))
			chosen_team = T
			break

	if(!istype(chosen_team))
		chosen_team = pick(valid_teams)

	return chosen_team
