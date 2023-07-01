//STRIKE TEAMS
//Thanks to Kilakk for the admin-button portion of this code.

var/global/ert_base_chance = 10 // Default base chance. Will be incremented by increment ERT chance.
var/global/can_call_ert

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

	var/objective = sanitize(input(usr, "Custom ERT objective", "Setup objective", "Help the station crew"))

	if(SSticker.ert_call_in_progress)
		to_chat(usr, "<span class='warning'>Похоже, кто-то уже опередил вас!</span>")
		return

	message_admins("[key_name_admin(usr)] is dispatching an Emergency Response Team with objective: [objective].")
	log_admin("[key_name(usr)] used Dispatch Response Team with objective: [objective].")
	feedback_set_details("ERT", "Admin dispatch")
	trigger_armed_response_team(1, objective)

// returns a number of dead players in %
/proc/percentage_dead()
	var/total = 0
	var/deadcount = 0
	for(var/mob/living/carbon/human/H as anything in human_list)
		if(H.client) // Monkeys and mice don't have a client, amirite?
			if(H.stat == DEAD) deadcount++
			total++

	if(total == 0) return 0
	else return round(100 * deadcount / total)

// counts the number of antagonists in %
/proc/percentage_antagonists()
	var/total = 0
	var/antagonists = 0
	for(var/mob/living/carbon/human/H as anything in human_list)
		if(is_special_character(H) >= 1)
			antagonists++
		total++

	if(total == 0) return 0
	else return round(100 * antagonists / total)

// Increments the ERT chance automatically, so that the later it is in the round,
// the more likely an ERT is to be able to be called.
/proc/increment_ert_chance()
	while(SSticker.ert_call_in_progress == FALSE) // There is no ERT at the time.
		if(get_security_level() == "green")
			ert_base_chance += 1
		if(get_security_level() == "blue")
			ert_base_chance += 2
		if(get_security_level() == "red")
			ert_base_chance += 3
		if(get_security_level() == "delta")
			ert_base_chance += 10           // Need those big guns
		sleep(600 * 3) // Minute * Number of Minutes


/proc/trigger_armed_response_team(force = 0, objective_text)
	if(!can_call_ert && !force)
		return 0
	if(SSticker.ert_call_in_progress)
		return 0

	if(!objective_text)
		objective_text = "Help the station crew"

	var/send_team_chance = ert_base_chance // Is incremented by increment_ert_chance.
	send_team_chance += 2*percentage_dead() // the more people are dead, the higher the chance
	send_team_chance += percentage_antagonists() // the more antagonists, the higher the chance
	send_team_chance = min(send_team_chance, 100)

	if(force) send_team_chance = 100

	// there's only a certain chance a team will be sent
	if(!prob(send_team_chance))
		var/datum/announcement/centcomm/noert/announcement = new
		announcement.play()
		can_call_ert = 0 // Only one call per round, ladies.
		return 0

	var/datum/announcement/centcomm/yesert/announcement = new
	announcement.play()
	can_call_ert = 0 // Only one call per round, gentleman.
	SSticker.ert_call_in_progress = TRUE
	var/datum/faction/strike_team/ert/ERT = SSticker.mode.CreateFaction(/datum/faction/strike_team/ert)
	ERT.forgeObjectives(objective_text)

	create_spawners(/datum/spawner/ert, 5, objective_text)

	VARSET_IN(SSticker, ert_call_in_progress, FALSE, 5 MINUTES) // Can no longer join the ERT.
	return 1

/client/proc/create_human_apperance(mob/living/carbon/human/H, _name)
	//todo: god damn this.
	//make it a panel, like in character creation
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

/client/proc/create_response_team(obj/spawn_location, leader_selected = 0, commando_name)

	var/mob/living/carbon/human/M = new(null)

	create_human_apperance(M, commando_name)
	M.age = !leader_selected ? rand(M.species.min_age, M.species.min_age * 1.5) : rand(M.species.min_age * 1.25, M.species.min_age * 1.75)

	//Creates mind stuff.
	M.mind = new
	M.mind.set_current(M)
	M.mind.original = M
	M.mind.assigned_role = "MODE"
	M.mind.special_role = "Response Team"
	if(!(M.mind in SSticker.minds))
		SSticker.minds += M.mind//Adds them to regular mind list.
	M.loc = spawn_location
	M.equip_strike_team(leader_selected)
	return M

/mob/living/carbon/human/proc/equip_strike_team(leader_selected = 0)

	//Special radio setup
	equip_to_slot_or_del(new /obj/item/device/radio/headset/ert(src), SLOT_L_EAR)

	//Replaced with new ERT uniform
	equip_to_slot_or_del(new /obj/item/clothing/under/ert(src), SLOT_W_UNIFORM)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/boots/swat(src), SLOT_SHOES)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(src), SLOT_GLOVES)
	equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(src), SLOT_GLASSES)

	if(leader_selected)
		var/obj/item/weapon/card/id/centcom/ert/W = new(src)
		W.assignment = "Emergency Response Team Leader"
		W.rank = "Emergency Response Team Leader"
		W.assign(real_name)
		W.icon_state = "ert-leader"
		mind.skills.add_available_skillset(/datum/skillset/ERT_leader)
		mind.skills.maximize_active_skills()
		equip_to_slot_or_del(W, SLOT_WEAR_ID)
	else
		var/obj/item/weapon/card/id/centcom/ert/W = new(src)
		W.assign(real_name)
		equip_to_slot_or_del(W, SLOT_WEAR_ID)

	var/obj/item/weapon/implant/mind_protect/loyalty/L = new(src)
	L.inject(src)
	return 1
