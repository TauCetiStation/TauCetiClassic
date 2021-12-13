var/global/list/datum/spawners = list()

/proc/_create_spawners(type, id, num, list/arguments)
	// arguments must have at least 1 element due to the use of arglist
	if(!arguments.len)
		arguments += null

	for(var/i in 1 to num)
		var/datum/spawner/spawner = new type(arglist(arguments))

		spawner.id = id
		LAZYADD(global.spawners[id], spawner)

	for(var/mob/dead/observer/ghost in observer_list)
		if(ghost.spawners_menu)
			SStgui.update_uis(ghost.spawners_menu)

		var/datum/hud/ghost/ghost_hud = ghost.hud_used
		var/image/I = image(ghost_hud.spawners_menu_button.icon, ghost_hud.spawners_menu_button, "spawners_update")
		flick_overlay(I, list(ghost.client), 10 SECONDS)

		to_chat(ghost, "<span class='ghostalert'>В спавнер меню появились новые роли!</span>")

/datum/spawner
	var/name
	var/id

	var/desc
	var/flavor_text
	var/important_info

	var/list/ranks
	var/del_after_spawn = TRUE
	var/cooldown
	var/timer_to_expiration

/datum/spawner/New()
	SHOULD_CALL_PARENT(TRUE)
	. = ..()

	if(time_to_expiration)
		timer_to_expiration = QDEL_IN(src, time_to_expiration)

/datum/spawner/Destroy()
	var/list/spawn_list = global.spawners[id]
	LAZYREMOVE(spawn_list, src)
	if(!length(spawn_list))
		global.spawners -= id

	for(var/mob/dead/observer/ghost in observer_list)
		if(ghost.spawners_menu)
			SStgui.update_uis(ghost.spawners_menu)

	return ..()

/datum/spawner/proc/do_spawn(mob/dead/observer/ghost)
	if(!can_spawn(ghost))
		return

	var/client/C = ghost.client
	spawn_ghost(ghost)

	message_admins("[C.ckey] as \"[name]\" has spawned at [COORD(C.mob)] [ADMIN_JMP(C.mob)] [ADMIN_FLW(C.mob)].")

	if(del_after_spawn)
		qdel(src)

/datum/spawner/proc/can_spawn(mob/dead/observer/ghost)
	if(!ghost.client)
		return FALSE
	if(!ranks)
		return TRUE
	if(jobban_isbanned(ghost, "Syndicate"))
		to_chat(ghost, "<span class='danger'>Роль - \"[name]\" для Вас заблокирована!</span>")
		return FALSE
	for(var/rank in ranks)
		if(jobban_isbanned(ghost, rank))
			to_chat(ghost, "<span class='danger'>Роль - \"[name]\" для Вас заблокирована!</span>")
			return FALSE
		if(role_available_in_minutes(ghost, rank))
			to_chat(ghost, "<span class='danger'>У Вас не хватает минут, чтобы зайди за роль \"[name]\". Чтобы её разблокировать вам нужно просто играть!</span>")
			return FALSE
	return TRUE

/datum/spawner/proc/spawn_ghost(mob/dead/observer/ghost)
	return

/datum/spawner/proc/jump(mob/dead/observer/ghost)
	return

/datum/spawner/dealer
	name = "Контрабандист"
	desc = "Вы появляетесь в космосе вблизи со станцией."
	flavor_text = "https://wiki.taucetistation.org/Families"

	ranks = list(ROLE_FAMILIES)

/datum/spawner/dealer/spawn_ghost(mob/dead/observer/ghost)
	var/spawnloc = pick(copsstart) // TODO: dealerstart
	copsstart -= spawnloc // TODO: dealerstart

	var/client/C = ghost.client

	var/mob/living/carbon/human/H = new(null)
	var/new_name = sanitize_safe(input(C, "Pick a name", "Name") as null|text, MAX_LNAME_LEN)
	C.create_human_apperance(H, new_name)

	H.loc = spawnloc
	H.key = C.key

	create_and_setup_role(/datum/role/traitor/dealer, H, TRUE)

/datum/spawner/dealer/jump(mob/dead/observer/ghost)
	var/jump_to = pick(copsstart) // TODO: dealerstart
	ghost.forceMove(get_turf(jump_to))

/datum/spawner/cop
	name = "Офицер ОБОП"
	desc = "Вы появляетесь на ЦК в полном обмундирование с целью прилететь на станцию и задержать всех бандитов."
	flavor_text = "https://wiki.taucetistation.org/Families"

	ranks = list(ROLE_FAMILIES)

	var/roletype

/datum/spawner/cop/spawn_ghost(mob/dead/observer/ghost)
	var/spawnloc = pick(copsstart)
	copsstart -= spawnloc

	var/client/C = ghost.client

	var/mob/living/carbon/human/cop = new(null)

	var/new_name = sanitize_safe(input(C, "Pick a name", "Name") as null|text, MAX_LNAME_LEN)
	C.create_human_apperance(cop, new_name)

	cop.loc = spawnloc
	cop.key = C.key

	//Give antag datum
	var/datum/faction/cops/faction = find_faction_by_type(/datum/faction/cops)
	if(!faction)
		faction = SSticker.mode.CreateFaction(/datum/faction/cops)
	if(faction)
		faction.roletype = roletype
		add_faction_member(faction, cop, TRUE, TRUE)

	var/obj/item/weapon/card/id/W = cop.wear_id
	W.name = "[cop.real_name]'s ID Card ([W.assignment])"
	W.registered_name = cop.real_name


/datum/spawner/cop/jump(mob/dead/observer/ghost)
	var/jump_to = pick(copsstart)
	ghost.forceMove(get_turf(jump_to))

/datum/spawner/cop/beatcop
	name = "Офицер ОБОП"
	roletype = /datum/role/cop/beatcop

/datum/spawner/cop/armored
	name = "Вооруженный Офицер ОБОП"
	roletype = /datum/role/cop/beatcop/armored

/datum/spawner/cop/swat
	name = "Боец Тактической Группы ОБОП"
	roletype = /datum/role/cop/beatcop/swat

/datum/spawner/cop/fbi
	name = "Инспектор ОБОП"
	roletype = /datum/role/cop/beatcop/fbi

/datum/spawner/cop/military
	name = "Боец ВСНТ ОБОП"
	roletype = /datum/role/cop/beatcop/military

/datum/spawner/ert
	name = "ЕРТ"
	desc = "Вы появляетесь на ЦК в окружение других бойцов с целью помочь станции в решении их проблем."
	flavor_text = "https://wiki.taucetistation.org/Emergency_Response_Team"
	important_info = "Ваша цель: "

	ranks = list(ROLE_ERT, "Security Officer")
	timer_to_expiration = 5 MINUTES

/datum/spawner/ert/New(mission)
	..()
	important_info += mission

/datum/spawner/ert/jump(mob/dead/observer/ghost)
	var/list/correct_landmarks = list()
	for (var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "Commando")
			correct_landmarks += L

	var/jump_to = pick(correct_landmarks)
	ghost.forceMove(get_turf(jump_to))

/datum/spawner/ert/spawn_ghost(mob/dead/observer/ghost)
	var/list/correct_landmarks = list()
	for (var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "Commando")
			correct_landmarks += L

	var/obj/spawnloc = pick(correct_landmarks)
	var/new_name = sanitize_safe(input(ghost, "Pick a name","Name") as null|text, MAX_LNAME_LEN)

	var/datum/faction/strike_team/ert/ERT_team = find_faction_by_type(/datum/faction/strike_team/ert)
	var/leader_selected = isemptylist(ERT_team.members)

	var/mob/living/carbon/human/new_commando = ghost.client.create_response_team(spawnloc.loc, leader_selected, new_name)
	new_commando.mind.key = ghost.key
	new_commando.key = ghost.key
	create_random_account_and_store_in_mind(new_commando)
	qdel(spawnloc)

	to_chat(new_commando, "<span class='notice'>You are [!leader_selected ? "a member" : "the <B>LEADER</B>"] of an Emergency Response Team, a type of military division, under CentComm's service. There is a code red alert on [station_name()], you are tasked to go and fix the problem.</span>")
	to_chat(new_commando, "<b>You should first gear up and discuss a plan with your team. More members may be joining, don't move out before you're ready.</b>")
	if(!leader_selected)
		to_chat(new_commando, "<b>As member of the Emergency Response Team, you answer to your leader and CentCom officials with higher priority and the commander of the ship with lower.</b>")
	else
		to_chat(new_commando, "<b>As leader of the Emergency Response Team, you answer only to CentComm and the commander of the ship with lower. You can override orders when it is necessary to achieve your mission goals. It is recommended that you attempt to cooperate with the commander of the ship where possible, however.</b>")

	if(ERT_team)
		add_faction_member(ERT_team, new_commando, FALSE)

/datum/spawner/blob_event
	name = "Блоб"
	desc = "Вы появляетесь в случайной точки станции в виде блоба."
	flavor_text = "https://wiki.taucetistation.org/Blob"

	ranks = list(ROLE_BLOB)
	timer_to_expiration = 3 MINUTES

/datum/spawner/blob_event/jump(mob/dead/observer/ghost)
	var/jump_to = pick(copsstart) //TODO: blobstart
	ghost.forceMove(get_turf(jump_to))

/datum/spawner/blob_event/spawn_ghost(mob/dead/observer/ghost)
	var/turf/spawn_turf = pick(copsstart) //TODO: blobstart
	new /obj/effect/blob/core(spawn_turf, ghost.client, 120)

/datum/spawner/ninja_event
	name = "Космический Ниндзя"
	desc = "Вы появляетесь в додзё. Из него вы можете телепортироваться на станцию."
	flavor_text = "https://wiki.taucetistation.org/Space_Ninja"

	ranks = list(ROLE_NINJA)
	timer_to_expiration = 3 MINUTES

/datum/spawner/ninja_event/jump(mob/dead/observer/ghost)
	var/jump_to = pick(ninjastart)
	ghost.forceMove(get_turf(jump_to))

/datum/spawner/ninja_event/spawn_ghost(mob/dead/observer/ghost)
	var/mob/living/carbon/human/new_ninja = create_space_ninja(pick(ninjastart.len ? ninjastart : latejoin))
	new_ninja.key = ghost.key

	var/datum/faction/ninja/N = find_faction_by_type(/datum/faction/ninja)
	if(!N)
		N = SSticker.mode.CreateFaction(/datum/faction/ninja)
	add_faction_member(N, new_ninja, FALSE)

	set_ninja_objectives(new_ninja)

/datum/spawner/religion_familiar
	name = "Фамильяр Религии"
	desc = "Вы появляетесь в виде какого-то животного в подчинении определённой религии."

	ranks = list(ROLE_GHOSTLY)

	var/mob/animal
	var/datum/religion/religion

/datum/spawner/religion_familiar/New(time_to_expiration, mob/_animal, datum/religion/_religion)
	. = ..()
	animal = _animal
	religion = _religion

	desc = "Вы появляетесь в виде [animal.name] в подчинении [religion.name]."

/datum/spawner/religion_familiar/jump(mob/dead/observer/ghost)
	ghost.forceMove(get_turf(animal))

/datum/spawner/religion_familiar/spawn_ghost(mob/dead/observer/ghost)
	animal.ckey = ghost.ckey
	religion.add_member(animal, HOLY_ROLE_PRIEST)

/datum/spawner/gladiator
	name = "Гладиатор"
	desc = "Вы появляетесь на арене и должны выжить."

	ranks = list(ROLE_GHOSTLY)
	del_after_spawn = FALSE

/datum/spawner/gladiator/jump(mob/dead/observer/ghost)
	var/jump_to = pick(eorgwarp)
	ghost.forceMove(get_turf(jump_to))

/datum/spawner/gladiator/spawn_ghost(mob/dead/observer/ghost)
	SSticker.spawn_gladiator(ghost, FALSE)

/datum/spawner/mouse
	name = "Мышь"
	desc = "Вы появляетесь где-то в вентиляции."
	flavor_text = "https://wiki.taucetistation.org/Mouse"

	ranks = list("Mouse")
	del_after_spawn = FALSE
