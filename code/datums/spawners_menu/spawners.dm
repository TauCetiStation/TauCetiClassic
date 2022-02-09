var/global/list/datum/spawners = list()
var/global/list/datum/spawners_cooldown = list()

// Don't call this proc directly! Use defines create_spawner and create_spawners
/proc/_create_spawners(type, id, num, list/arguments)
	// arguments must have at least 1 element due to the use of arglist
	if(!arguments.len)
		arguments += null

	for(var/i in 1 to num)
		var/datum/spawner/spawner = new type(arglist(arguments))
		spawner.add_to_global_list(id)

	for(var/mob/dead/observer/ghost in observer_list)
		if(!ghost.client)
			continue

		var/datum/hud/ghost/ghost_hud = ghost.hud_used
		var/image/I = image(ghost_hud.spawners_menu_button.icon, ghost_hud.spawners_menu_button, "spawners_update")
		flick_overlay(I, list(ghost.client), 10 SECONDS)

		to_chat(ghost, "<span class='ghostalert'>Доступны новые роли в меню возрождения!</span>")

/datum/spawner
	// Name of spawner, wow
	var/name
	// Uniq category of spawner to sorting in spawner_menu
	var/id

	// In interface: "Описание: "
	var/desc
	// In interface: "Важная информация: "
	var/important_info
	// In interface: "Ссылка на вики: "
	var/wiki_ref

	// Roles and jobs that will be checked for jobban and minutes
	var/list/ranks
	// Delete spawner after use
	var/infinity = FALSE
	// Cooldown between the opportunity become a role
	var/cooldown = 10 MINUTES

	// Time to del the spawner
	var/time_to_del
	// Private, store id of timer
	var/timer_to_expiration

/datum/spawner/New()
	SHOULD_CALL_PARENT(TRUE)
	. = ..()

	if(time_to_del)
		timer_to_expiration = QDEL_IN(src, time_to_del)

/datum/spawner/Destroy()
	remove_from_global_list()

	deltimer(timer_to_expiration)

	return ..()

/datum/spawner/proc/add_to_global_list(_id)
	if(!isnull(_id))
		id = _id

	LAZYADDASSOCLIST(global.spawners, id, src)

	for(var/mob/dead/observer/ghost in observer_list)
		if(!ghost.client)
			continue

		if(ghost.spawners_menu)
			SStgui.update_uis(ghost.spawners_menu)

/datum/spawner/proc/remove_from_global_list()
	LAZYREMOVEASSOC(global.spawners, id, src)

	for(var/mob/dead/observer/ghost in observer_list)
		if(!ghost.client)
			continue

		if(ghost.spawners_menu)
			SStgui.update_uis(ghost.spawners_menu)

/datum/spawner/proc/add_client_cooldown(client/C)
	if(cooldown)
		if(!global.spawners_cooldown[C.ckey])
			global.spawners_cooldown[C.ckey] = list()
		var/list/ckey_cooldowns = global.spawners_cooldown[C.ckey]
		ckey_cooldowns[type] = world.time + cooldown

/datum/spawner/proc/check_cooldown(mob/dead/observer/ghost)
	if(global.spawners_cooldown[ghost.ckey])
		var/list/ckey_cooldowns = global.spawners_cooldown[ghost.ckey]
		if(world.time < ckey_cooldowns[type])
			var/timediff = round((ckey_cooldowns[type] - world.time) * 0.1)
			to_chat(ghost, "<span class='danger'>Вы сможете снова зайти за эту роль через [timediff] секунд!</span>")
			return FALSE
	return TRUE

/datum/spawner/proc/do_spawn(mob/dead/observer/ghost)
	if(!can_spawn(ghost))
		return

	if(!infinity)
		remove_from_global_list()

	var/client/C = ghost.client
	spawn_ghost(ghost)

	// check if the ghost really become a role
	if(ghost.client == C)
		if(!infinity)
			add_to_global_list()
		return

	message_admins("[C.ckey] as \"[name]\" has spawned at [COORD(C.mob)] [ADMIN_JMP(C.mob)] [ADMIN_FLW(C.mob)].")
	add_client_cooldown(C)

	if(!infinity)
		qdel(src)

/datum/spawner/proc/can_spawn(mob/dead/observer/ghost)
	if(!check_cooldown(ghost))
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

/*
 * Families
*/
/datum/spawner/dealer
	name = "Контрабандист"
	desc = "Вы появляетесь в космосе вблизи со станцией."
	wiki_ref = "Families"

	ranks = list(ROLE_FAMILIES)

/datum/spawner/dealer/spawn_ghost(mob/dead/observer/ghost)
	var/spawnloc = pick(dealerstart)
	dealerstart -= spawnloc

	var/client/C = ghost.client

	var/mob/living/carbon/human/H = new(null)
	var/new_name = sanitize_safe(input(C, "Pick a name", "Name") as null|text, MAX_LNAME_LEN)
	C.create_human_apperance(H, new_name)

	H.loc = spawnloc
	H.key = C.key

	create_and_setup_role(/datum/role/traitor/dealer, H, TRUE)

/datum/spawner/dealer/jump(mob/dead/observer/ghost)
	var/jump_to = pick(dealerstart)
	ghost.forceMove(get_turf(jump_to))

/datum/spawner/cop
	name = "Офицер ОБОП"
	desc = "Вы появляетесь на ЦК в полном обмундирование с целью прилететь на станцию и задержать всех бандитов."
	wiki_ref = "Families"

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

/*
 * ERT
*/
/datum/spawner/ert
	name = "ЕРТ"
	desc = "Вы появляетесь на ЦК в окружение других бойцов с целью помочь станции в решении их проблем."
	wiki_ref = "Emergency_Response_Team"
	important_info = "Ваша цель: "

	ranks = list(ROLE_ERT, "Security Officer")
	time_to_del = 5 MINUTES

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

	var/is_leader = FALSE
	if(!ERT_team.leader_selected)
		is_leader = TRUE
		ERT_team.leader_selected = TRUE

	var/mob/living/carbon/human/new_commando = ghost.client.create_response_team(spawnloc.loc, is_leader, new_name)
	new_commando.mind.key = ghost.key
	new_commando.key = ghost.key
	create_random_account_and_store_in_mind(new_commando)

	to_chat(new_commando, "<span class='notice'>You are [!is_leader ? "a member" : "the <B>LEADER</B>"] of an Emergency Response Team, a type of military division, under CentComm's service. There is a code red alert on [station_name()], you are tasked to go and fix the problem.</span>")
	to_chat(new_commando, "<b>You should first gear up and discuss a plan with your team. More members may be joining, don't move out before you're ready.</b>")
	if(!is_leader)
		to_chat(new_commando, "<b>As member of the Emergency Response Team, you answer to your leader and CentCom officials with higher priority and the commander of the ship with lower.</b>")
	else
		to_chat(new_commando, "<b>As leader of the Emergency Response Team, you answer only to CentComm and the commander of the ship with lower. You can override orders when it is necessary to achieve your mission goals. It is recommended that you attempt to cooperate with the commander of the ship where possible, however.</b>")

	if(ERT_team)
		add_faction_member(ERT_team, new_commando, FALSE)

/*
 * Blob
*/
/datum/spawner/blob_event
	name = "Блоб"
	desc = "Вы появляетесь в случайной точки станции в виде блоба."
	wiki_ref = "Blob"

	ranks = list(ROLE_BLOB)
	time_to_del = 3 MINUTES

/datum/spawner/blob_event/jump(mob/dead/observer/ghost)
	var/jump_to = pick(blobstart)
	ghost.forceMove(get_turf(jump_to))

/datum/spawner/blob_event/spawn_ghost(mob/dead/observer/ghost)
	var/turf/spawn_turf = pick(blobstart)
	new /obj/effect/blob/core(spawn_turf, ghost.client, 120)

/*
 * Ninja
*/
/datum/spawner/ninja_event
	name = "Космический Ниндзя"
	desc = "Вы появляетесь в додзё. Из него вы можете телепортироваться на станцию."
	wiki_ref = "Space_Ninja"

	ranks = list(ROLE_NINJA)
	time_to_del = 3 MINUTES

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

/*
 * Borer
*/
/datum/spawner/borer_event
	name = "Изначальный Борер"
	desc = "Вы появляетесь где-то в вентиляции на станции."
	wiki_ref = "Cortical_Borer"

	ranks = list(ROLE_GHOSTLY)
	time_to_del = 3 MINUTES

/datum/spawner/borer_event/spawn_ghost(mob/dead/observer/ghost)
	var/list/vents = get_vents()
	var/obj/vent = pick_n_take(vents)
	var/mob/living/simple_animal/borer/B = new(vent.loc, FALSE, 1)
	B.transfer_personality(ghost.client)

/datum/spawner/borer
	name = "Борер"
	desc = "Вы становитесь очередным отпрыском бореров."
	wiki_ref = "Cortical_Borer"

	ranks = list(ROLE_GHOSTLY)

	var/mob/borer

/datum/spawner/borer/New(_borer)
	. = ..()
	borer = _borer

/datum/spawner/borer/jump(mob/dead/observer/ghost)
	ghost.forceMove(get_turf(borer))

/datum/spawner/borer/spawn_ghost(mob/dead/observer/ghost)
	borer.transfer_personality(ghost.client)

/*
 * Aliens
*/
/datum/spawner/alien_event
	name = "Изначальный Лицехват"
	desc = "Вы появляетесь где-то в вентиляции станции и должны развить потомство."
	wiki_ref = "Xenomorph"

	ranks = list(ROLE_ALIEN)
	time_to_del = 3 MINUTES

/datum/spawner/alien_event/spawn_ghost(mob/dead/observer/ghost)
	var/list/vents = get_vents()
	var/obj/vent = pick(vents)
	var/mob/living/carbon/xenomorph/facehugger/new_xeno = new(vent.loc)
	new_xeno.key = ghost.key

/*
 * Religion
*/
/datum/spawner/religion_familiar
	name = "Фамильяр Религии"
	desc = "Вы появляетесь в виде какого-то животного в подчинении определённой религии."

	ranks = list(ROLE_GHOSTLY)

	var/mob/animal
	var/datum/religion/religion

/datum/spawner/religion_familiar/New(mob/_animal, datum/religion/_religion)
	. = ..()
	animal = _animal
	religion = _religion

	desc = "Вы появляетесь в виде [animal.name] в подчинении [religion.name]."

/datum/spawner/religion_familiar/jump(mob/dead/observer/ghost)
	ghost.forceMove(get_turf(animal))

/datum/spawner/religion_familiar/spawn_ghost(mob/dead/observer/ghost)
	animal.ckey = ghost.ckey
	religion.add_member(animal, HOLY_ROLE_PRIEST)

/*
 * Other
*/
/datum/spawner/gladiator
	name = "Гладиатор"
	desc = "Вы появляетесь на арене и должны выжить."
	wiki_ref = "Starter_Guide#Арена"

	ranks = list(ROLE_GHOSTLY)
	cooldown = 0
	infinity = TRUE

/datum/spawner/gladiator/jump(mob/dead/observer/ghost)
	var/jump_to = pick(eorgwarp)
	ghost.forceMove(get_turf(jump_to))

/datum/spawner/gladiator/spawn_ghost(mob/dead/observer/ghost)
	SSticker.spawn_gladiator(ghost, FALSE)

/datum/spawner/mouse
	name = "Мышь"
	desc = "Вы появляетесь в суровом мире людей и должны выжить."
	wiki_ref = "Mouse"

	ranks = list("Mouse")
	infinity = TRUE

/datum/spawner/mouse/can_spawn(mob/dead/observer/ghost)
	if(config.disable_player_mice)
		to_chat(ghost, "<span class='warning'>Spawning as a mouse is currently disabled.</span>")
		return FALSE
	return ..()

/datum/spawner/mouse/spawn_ghost(mob/dead/observer/ghost)
	ghost.mousize()

/datum/spawner/space_bum
	name = "Космо-бомж"
	desc = "Вы появляетесь где-то на свалке."
	wiki_ref = "Junkyard"

	infinity = TRUE

/datum/spawner/space_bum/jump(mob/dead/observer/ghost)
	var/jump_to = pick(junkyard_bum_list)
	ghost.forceMove(get_turf(jump_to))

/datum/spawner/space_bum/spawn_ghost(mob/dead/observer/ghost)
	ghost.make_bum()

/datum/spawner/drone
	name = "Дрон"
	desc = "Вы появляетесь на дронстанции и обязаны ремонтировать станцию."
	wiki_ref = "Drone"

	ranks = list(ROLE_DRONE)

	infinity = TRUE

/datum/spawner/drone/can_spawn(mob/dead/observer/ghost)
	if(!config.allow_drone_spawn)
		to_chat(ghost, "<span class='warning'>That verb is not currently permitted.</span>")
		return FALSE
	return ..()

/datum/spawner/drone/jump(mob/dead/observer/ghost)
	var/obj/machinery/drone_fabricator/DF = locate() in global.machines
	ghost.forceMove(get_turf(DF))

/datum/spawner/drone/spawn_ghost(mob/dead/observer/ghost)
	ghost.dronize()

/datum/spawner/plant
	name = "Нимфа Дионы"
	desc = "Нимфу вырастили на грядке."
	wiki_ref = "Dionaea"

	ranks = list(ROLE_GHOSTLY)

	var/mob/diona
	var/realName

/datum/spawner/plant/New(mob/_diona, _realName)
	. = ..()
	diona = _diona
	realName = _realName

/datum/spawner/plant/can_spawn(mob/dead/observer/ghost)
	if(is_alien_whitelisted_banned(ghost, DIONA) || !is_alien_whitelisted(ghost, DIONA))
		to_chat(ghost, "<span class='warning'>Вы не можете играть за дион.</span>")
		return FALSE
	return ..()

/datum/spawner/plant/jump(mob/dead/observer/ghost)
	ghost.forceMove(get_turf(diona))

/datum/spawner/plant/spawn_ghost(mob/dead/observer/ghost)
	diona.key = ghost.key

	if(realName)
		diona.real_name = realName
	diona.dna.real_name = diona.real_name

	to_chat(diona, "<span class='notice'><B>You awaken slowly, feeling your sap stir into sluggish motion as the warm air caresses your bark.</B></span>")
	to_chat(diona, "<B>You are now one of the Dionaea, a race of drifting interstellar plantlike creatures that sometimes share their seeds with human traders.</B>")
	to_chat(diona, "<B>Too much darkness will send you into shock and starve you, but light will help you heal.</B>")

	if(!realName)
		var/newname = sanitize_safe(input(diona,"Enter a name, or leave blank for the default name.", "Name change","") as text, MAX_NAME_LEN)
		if (newname != "")
			diona.real_name = newname
