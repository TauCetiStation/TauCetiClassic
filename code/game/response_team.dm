//STRIKE TEAMS
//Thanks to Kilakk for the admin-button portion of this code.

var/list/response_team_members = list()
var/global/send_emergency_team = 0 // Used for automagic response teams
                                   // 'admin_emergency_team' for admin-spawned response teams
var/ert_base_chance = 10 // Default base chance. Will be incremented by increment ERT chance.
var/can_call_ert

/client/proc/response_team()
	set name = "Dispatch Emergency Response Team"
	set category = "Special Verbs"
	set desc = "Отправляет отряд быстрого реагирования на станцию."

	if(!holder)
		to_chat(usr, "<span class='warning'>Только администрация может использовать это.</span>")
		return
	if(!SSticker)
		to_chat(usr, "<span class='warning'>Игра еще не началась!</span>")
		return
	if(SSticker.current_state == 1)
		to_chat(usr, "<span class='warning'>Раунд еще не начался!</span>")
		return
	if(send_emergency_team)
		to_chat(usr, "<span class='warning'>Центральное командование уже отправило отряд быстрого реагирования!</span>")
		return

	if(tgui_alert(usr, "Вы хотите отправить отряд быстрого реагирования?",, list("Да","Нет")) != "Да")
		return
	if(get_security_level() != "red") // Allow admins to reconsider if the alert level isn't Red
		switch(tgui_alert(usr, "На станции не введен красный код. Вы все еще хотите отправить отряд быстрого реагирования?",, list("Да","Нет")))
			if("Нет")
				return
        
	if(send_emergency_team)
		to_chat(usr, "<span class='warning'>Похоже, кто-то уже опередил вас!</span>")
		return

	message_admins("[key_name_admin(usr)] is dispatching an Emergency Response Team.", 1)
	log_admin("[key_name(usr)] used Dispatch Response Team.")
	feedback_set_details("ERT", "Admin dispatch")
	trigger_armed_response_team(1)


/client/verb/JoinResponseTeam()
	set name = "Вступить в ОБР"
	set category = "IC"

	if(isobserver(usr) || isnewplayer(usr) || ismouse(usr) || isbrain(usr) || usr.is_dead())
		if(!send_emergency_team)
			to_chat(usr, "В данный момент нет вызванного отряда быстрого реагирования.")
			return
	/*	if(admin_emergency_team)
			to_chat(usr, "An emergency response team has already been sent.")
			return */
		if(jobban_isbanned(usr, "Syndicate") || jobban_isbanned(usr, ROLE_ERT) || jobban_isbanned(usr, "Security Officer"))
			to_chat(usr, "<span class='danger'>Администрация запретила вам вступать в отряд быстрого реагирования!</span>")
			return

		var/available_in_minutes = role_available_in_minutes(usr, ROLE_ERT)
		if(available_in_minutes)
			to_chat(usr, "<span class='notice'>Эта роль будет открыта через [pluralize_russian(available_in_minutes, "[available_in_minutes] минуту", "[available_in_minutes] минуты", "[available_in_minutes] минут")]. Продолжайте играть для получения доступа.</span>")
			return

		if(response_team_members.len > 5)
			to_chat(usr, "Отряд быстрого реагирования уже заполнен!")

		for (var/obj/effect/landmark/L in landmarks_list) if (L.name == "Commando")
			L.name = null//Reserving the place.
			var/new_name = sanitize_safe(input(usr, "Введите имя","Имя") as null|text, MAX_LNAME_LEN)
			if(!new_name)//Somebody changed his mind, place is available again.
				L.name = "Commando"
				return
			var/leader_selected = isemptylist(response_team_members)
			var/mob/living/carbon/human/new_commando = create_response_team(L.loc, leader_selected, new_name)
			qdel(L)
			new_commando.mind.key = usr.key
			new_commando.key = usr.key
			create_random_account_and_store_in_mind(new_commando)

			to_chat(new_commando, "<span class='notice'>Вы являетесь [!leader_selected?"членом":"<B>ЛИДЕРОМ</B>"] отряда быстрого реагирования, видом военного подразделения, под управлением ЦК.<BR>На станции [station_name()] (<B>[get_security_level()]</B>) код, ваша задача найти и устранить проблему.</span>")
			to_chat(new_commando, "<b>Для начала вооружитесь и обсудите план со своей командой. Другие члены могут присоединиться позже. Не выдвигайтесь, пока не будете полностью готовы.</b>")
			if(!leader_selected)
				to_chat(new_commando, "<b>Как член отряда быстрого реагирования, вы отвечаете перед лидером и представителями ЦК с более высоким приоритетом и перед капитаном с более низким.</b>")
			else
				to_chat(new_commando, "<b>Как лидер отряда быстрого реагирования, вы отвечаете только перед ЦК и перед капитаном с более низким приоритетом. Вы можете ослушаться приказа, если это поможет выполнению миссии. Рекомендуется координироваться с капитаном, если возможно.</b>")

			var/datum/faction/strike_team/ert/ERT = find_faction_by_type(/datum/faction/strike_team/ert)
			if(ERT)
				add_faction_member(ERT, new_commando, FALSE)

	else
		to_chat(usr, "Вы должны быть наблюдателем, мышкой, мозгом или новым игроком, чтобы присоединиться.")

// returns a number of dead players in %
/proc/percentage_dead()
	var/total = 0
	var/deadcount = 0
	for(var/mob/living/carbon/human/H in human_list)
		if(H.client) // Monkeys and mice don't have a client, amirite?
			if(H.stat == DEAD) deadcount++
			total++

	if(total == 0) return 0
	else return round(100 * deadcount / total)

// counts the number of antagonists in %
/proc/percentage_antagonists()
	var/total = 0
	var/antagonists = 0
	for(var/mob/living/carbon/human/H in human_list)
		if(is_special_character(H) >= 1)
			antagonists++
		total++

	if(total == 0) return 0
	else return round(100 * antagonists / total)

// Increments the ERT chance automatically, so that the later it is in the round,
// the more likely an ERT is to be able to be called.
/proc/increment_ert_chance()
	while(send_emergency_team == 0) // There is no ERT at the time.
		if(get_security_level() == "green")
			ert_base_chance += 1
		if(get_security_level() == "blue")
			ert_base_chance += 2
		if(get_security_level() == "red")
			ert_base_chance += 3
		if(get_security_level() == "delta")
			ert_base_chance += 10           // Need those big guns
		sleep(600 * 3) // Minute * Number of Minutes


/proc/trigger_armed_response_team(force = 0)
	if(!can_call_ert && !force)
		return
	if(send_emergency_team)
		return

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
		return

	var/datum/announcement/centcomm/yesert/announcement = new
	announcement.play()
	can_call_ert = 0 // Only one call per round, gentleman.
	send_emergency_team = 1
	var/datum/faction/strike_team/ert/ERT = SSticker.mode.CreateFaction(/datum/faction/strike_team/ert)
	ERT.forgeObjectives("Help the station crew")

	sleep(600 * 5)
	send_emergency_team = 0 // Can no longer join the ERT.

/client/proc/create_response_team(obj/spawn_location, leader_selected = 0, commando_name)


	var/mob/living/carbon/human/M = new(null)
	response_team_members |= M

	//todo: god damn this.
	//make it a panel, like in character creation
	var/new_facial = input("Выберите цвет растительности на лице.", "Создание персонажа") as color
	if(new_facial)
		M.r_facial = hex2num(copytext(new_facial, 2, 4))
		M.g_facial = hex2num(copytext(new_facial, 4, 6))
		M.b_facial = hex2num(copytext(new_facial, 6, 8))

	var/new_hair = input("Выберите цвет прически.", "Создание персонажа") as color
	if(new_facial)
		M.r_hair = hex2num(copytext(new_hair, 2, 4))
		M.g_hair = hex2num(copytext(new_hair, 4, 6))
		M.b_hair = hex2num(copytext(new_hair, 6, 8))

	var/new_eyes = input("Выберите цвет глаз.", "Создание персонажа") as color
	if(new_eyes)
		M.r_eyes = hex2num(copytext(new_eyes, 2, 4))
		M.g_eyes = hex2num(copytext(new_eyes, 4, 6))
		M.b_eyes = hex2num(copytext(new_eyes, 6, 8))

	var/new_tone = input("Выберите тон кожи: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Создание персонажа")  as text

	if (!new_tone)
		new_tone = 35
	M.s_tone = max(min(round(text2num(new_tone)), 220), 1)
	M.s_tone =  -M.s_tone + 35

	// hair
	var/list/all_hairs = subtypesof(/datum/sprite_accessory/hair)
	var/list/hairs = list()

	// loop through potential hairs
	for(var/x in all_hairs)
		var/datum/sprite_accessory/hair/H = new x // create new hair datum based on type x
		hairs.Add(H.name) // add hair name to hairs
		qdel(H) // delete the hair after it's all done

	var/new_gender = tgui_alert(usr, "Выберите пол.", "Создание персонажа", list("Мужской", "Женский"))

	if (new_gender)
		if(new_gender == "Мужской")
			M.gender = MALE
		else
			M.gender = FEMALE

	//hair
	var/new_hstyle = input(usr, "Выберите прическу", "Отличительные признаки")  as null|anything in get_valid_styles_from_cache(hairs_cache, M.get_species(), M.gender)
	if(new_hstyle)
		M.h_style = new_hstyle

	// facial hair
	var/new_fstyle = input(usr, "Выберите стиль лицевой растительности", "Отличительные признаки")  as null|anything in get_valid_styles_from_cache(facial_hairs_cache, M.get_species(), M.gender)
	if(new_fstyle)
		M.f_style = new_fstyle


	//M.rebuild_appearance()
	M.apply_recolor()
	M.update_hair()
	M.update_body()
	M.check_dna(M)

	M.real_name = commando_name
	M.name = commando_name
	M.age = !leader_selected ? rand(M.species.min_age, M.species.min_age * 1.5) : rand(M.species.min_age * 1.25, M.species.min_age * 1.75)

	M.dna.ready_dna(M)//Creates DNA.

	//Creates mind stuff.
	M.mind = new
	M.mind.current = M
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
	equip_to_slot_or_del(new /obj/item/clothing/gloves/swat(src), SLOT_GLOVES)
	equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(src), SLOT_GLASSES)

	if(leader_selected)
		var/obj/item/weapon/card/id/centcom/ert/W = new(src)
		W.assignment = "Emergency Response Team Leader"
		W.rank = "Emergency Response Team Leader"
		W.registered_name = real_name
		W.name = "[real_name]'s ID Card ([W.assignment])"
		W.icon_state = "ert-leader"
		equip_to_slot_or_del(W, SLOT_WEAR_ID)
	else
		var/obj/item/weapon/card/id/centcom/ert/W = new(src)
		W.registered_name = real_name
		W.name = "[real_name]'s ID Card ([W.assignment])"
		equip_to_slot_or_del(W, SLOT_WEAR_ID)

	var/obj/item/weapon/implant/mind_protect/loyalty/L = new(src)
	L.inject(src)
	return 1
