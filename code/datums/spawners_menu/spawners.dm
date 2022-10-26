var/global/list/datum/spawners = list()
var/global/list/datum/spawners_cooldown = list()

// Don't call this proc directly! Use defines create_spawner and create_spawners
/proc/_create_spawners(type, num, list/arguments)
	// arguments must have at least 1 element due to the use of arglist
	if(!arguments.len)
		arguments += null

	for(var/i in 1 to num)
		var/datum/spawner/spawner = new type(arglist(arguments))
		spawner.add_to_global_list()

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

/datum/spawner/proc/add_to_global_list()
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
	id = "dealer"
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
	id = "cop"
	desc = "Вы появляетесь на ЦК в полном обмундирование с целью прилететь на станцию и задержать всех бандитов."
	wiki_ref = "Families"

	ranks = list(ROLE_FAMILIES)

	var/roletype
	var/list/prefixes = list("Officer")

/datum/spawner/cop/spawn_ghost(mob/dead/observer/ghost)
	var/spawnloc = pick(copsstart)
	copsstart -= spawnloc

	var/client/C = ghost.client

	var/mob/living/carbon/human/cop = new(null)

	var/new_name = "[pick(prefixes)] [pick(last_names)]"
	C.create_human_apperance(cop, new_name)

	cop.loc = spawnloc
	cop.key = C.key

	//Give antag datum
	var/datum/faction/cops/faction = create_uniq_faction(/datum/faction/cops)

	faction.roletype = roletype
	add_faction_member(faction, cop, TRUE, TRUE)

	var/obj/item/weapon/card/id/W = cop.wear_id
	W.assign(cop.real_name)

/datum/spawner/cop/jump(mob/dead/observer/ghost)
	var/jump_to = pick(copsstart)
	ghost.forceMove(get_turf(jump_to))

/datum/spawner/cop/beatcop
	name = "Офицер ОБОП"
	id = "c_beatcop"
	roletype = /datum/role/cop/beatcop

/datum/spawner/cop/armored
	name = "Вооруженный Офицер ОБОП"
	id = "c_armored"
	roletype = /datum/role/cop/beatcop/armored

/datum/spawner/cop/swat
	name = "Боец Тактической Группы ОБОП"
	id = "c_swat"
	roletype = /datum/role/cop/beatcop/swat
	prefixes = list("Sergeant", "Captain")

/datum/spawner/cop/fbi
	name = "Инспектор ОБОП"
	id = "c_fbi"
	roletype = /datum/role/cop/beatcop/fbi
	prefixes = list("Inspector")

/datum/spawner/cop/military
	name = "Боец ВСНТ ОБОП"
	id = "c_military"
	roletype = /datum/role/cop/beatcop/military
	prefixes = list("Pvt.", "PFC", "Cpl.", "LCpl.", "SGT")


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
	id = mission
	important_info += mission

/datum/spawner/ert/jump(mob/dead/observer/ghost)
	var/jump_to = pick(landmarks_list["Commando"])
	ghost.forceMove(get_turf(jump_to))

/datum/spawner/ert/spawn_ghost(mob/dead/observer/ghost)
	var/obj/spawnloc = pick(landmarks_list["Commando"])
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
	id = "blob_event"
	desc = "Вы появляетесь в случайной точки станции в виде блоба."
	wiki_ref = "Blob"

	ranks = list(ROLE_BLOB)
	time_to_del = 3 MINUTES

/datum/spawner/blob_event/jump(mob/dead/observer/ghost)
	var/jump_to = pick(blobstart)
	ghost.forceMove(get_turf(jump_to))

/datum/spawner/blob_event/spawn_ghost(mob/dead/observer/ghost)
	var/turf/spawn_turf = pick(blobstart)
	new /obj/structure/blob/core(spawn_turf, ghost.client, 120)

/*
 * Ninja
*/
/datum/spawner/ninja_event
	name = "Космический Ниндзя"
	id = "ninja_event"
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

	var/datum/faction/ninja/N = create_uniq_faction(/datum/faction/ninja)
	add_faction_member(N, new_ninja, FALSE)

	set_ninja_objectives(new_ninja)

/*
 * Borer
*/
/datum/spawner/borer_event
	name = "Изначальный Борер"
	id = "borer_event"
	desc = "Вы появляетесь где-то в вентиляции на станции."
	wiki_ref = "Cortical_Borer"

	ranks = list(ROLE_GHOSTLY)
	time_to_del = 3 MINUTES

/datum/spawner/borer_event/spawn_ghost(mob/dead/observer/ghost)
	var/list/vents = get_vents()
	var/obj/vent = pick_n_take(vents)
	var/mob/living/simple_animal/borer/B = new(vent.loc, FALSE, 1)
	B.transfer_personality(ghost.client)

/*
 * Aliens
*/
/datum/spawner/alien_event
	name = "Изначальный Лицехват"
	id = "alien_event"
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
 * Other
*/
/datum/spawner/gladiator
	name = "Гладиатор"
	id = "gladiator"
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
	id = "mouse"
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
	id = "space_bum"
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
	id = "drone"
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

/datum/spawner/living
	name = "Свободное тело"
	id = "living"
	desc = "Продолжи его дело!"

	ranks = list(ROLE_GHOSTLY)

	var/mob/living/mob

/datum/spawner/living/New(mob/living/_mob)
	. = ..()

	mob = _mob
	add_mob_roles()

	RegisterSignal(mob, list(COMSIG_PARENT_QDELETING, COMSIG_LOGIN, COMSIG_MOB_DIED), .proc/self_qdel)

/datum/spawner/living/Destroy()
	UnregisterSignal(mob, list(COMSIG_PARENT_QDELETING, COMSIG_LOGIN, COMSIG_MOB_DIED))
	mob = null
	return ..()

/datum/spawner/living/proc/add_mob_roles()
	ranks |= mob.job

	if(!mob.mind)
		return

	var/datum/mind/mind = mob.mind
	ranks |= mind.antag_roles

/datum/spawner/living/proc/self_qdel()
	SIGNAL_HANDLER
	qdel(src)

/datum/spawner/living/jump(mob/dead/observer/ghost)
	ghost.forceMove(get_turf(mob))

/datum/spawner/living/spawn_ghost(mob/dead/observer/ghost)
	UnregisterSignal(mob, list(COMSIG_PARENT_QDELETING, COMSIG_LOGIN, COMSIG_MOB_DIED))
	mob.key = ghost.key

/datum/spawner/living/podman
	name = "Подмена"
	id = "podman"
	desc = "Подмена умерла, да здравствует подмена."
	wiki_ref = "Podmen"

	var/replicant_memory

/datum/spawner/living/podman/New(mob/_mob, _replicant_memory)
	replicant_memory = _replicant_memory
	. = ..(_mob)

/datum/spawner/living/podman/spawn_ghost(mob/dead/observer/ghost)
	..()

	if(replicant_memory)
		mob.mind.memory = replicant_memory

	to_chat(mob, greet_message())

/datum/spawner/living/podman/proc/greet_message()
	. = "<span class='notice'><B>You awaken slowly, feeling your sap stir into sluggish motion as the warm air caresses your bark.</B></span><BR>"
	. += "<B>You are now in possession of Podmen's body. It's previous owner found it no longer appealing, by rejecting it - they brought you here. You are now, again, an empty shell full of hollow nothings, neither belonging to humans, nor them.</B><BR>"
	. += "<B>Too much darkness will send you into shock and starve you, but light will help you heal.</B>"

/datum/spawner/living/podman/podkid
	name = "Подкидыш"
	id = "podkid"
	desc = "Человечка вырастили на грядке."

/datum/spawner/living/podman/podkid/greet_message()
	. = "<span class='notice'><B>You awaken slowly, feeling your sap stir into sluggish motion as the warm air caresses your bark.</B></span><BR>"
	. += "<B>You are now one of the Podmen, a race of failures, created to never leave their trace. You are an empty shell full of hollow nothings, neither belonging to humans, nor them.</B><BR>"
	. += "<B>Too much darkness will send you into shock and starve you, but light will help you heal.</B>"

/datum/spawner/living/podman/nymph
	name = "Нимфа Дионы"
	id = "nymph_pod"
	desc = "Диону вырастили на грядке."
	wiki_ref = "Dionaea"

/datum/spawner/living/podman/nymph/can_spawn(mob/dead/observer/ghost)
	if(is_alien_whitelisted_banned(ghost, DIONA) || !is_alien_whitelisted(ghost, DIONA))
		to_chat(ghost, "<span class='warning'>Вы не можете играть за дион.</span>")
		return FALSE

	return ..()

/datum/spawner/living/podman/nymph/greet_message()
	. = "<span class='notice'><B>You awaken slowly, feeling your sap stir into sluggish motion as the warm air caresses your bark.</B></span><BR>"
	. += "<B>You are now one of the Dionaea, or were you always one of us? Welcome to the Gestalt, we see you now, again.</B><BR>"
	. += "<B>Too much darkness will send you into shock and starve you, but light will help you heal.</B>"

/datum/spawner/living/podman/fake_nymph
	name = "Нимфа Дионы"
	id = "fake_nymph_pod"
	desc = "Диону вырастили на грядке."

/datum/spawner/living/podman/fake_nymph/greet_message()
	. = "<span class='notice'><B>You awaken slowly, feeling your sap stir into sluggish motion as the warm air caresses your bark.</B></span><BR>"
	. += "<B>You are now one of the Dionaea, sorta, you failed at your attempt to join the Gestalt Consciousness. You are not empty, nor you are full. You are a failure good enough to fool everyone into thinking you are not. DO NOT EVOLVE.</B><BR>"
	. += "<B>Too much darkness will send you into shock and starve you, but light will help you heal.</B>"

/datum/spawner/living/borer
	name = "Борер"
	id = "borer"
	desc = "Вы становитесь очередным отпрыском бореров."
	wiki_ref = "Cortical_Borer"

/datum/spawner/living/borer/spawn_ghost(mob/dead/observer/ghost)
	UnregisterSignal(mob, list(COMSIG_PARENT_QDELETING, COMSIG_LOGIN, COMSIG_MOB_DIED))
	mob.transfer_personality(ghost.client)

/*
 * Robots
*/
/datum/spawner/living/robot
	name = "Киборг"
	id = "robot"
	desc = "Перезагрузка позитронного мозга."
	wiki_ref = "Cyborg"

/datum/spawner/living/robot/syndi
	name = "Киборг синдиката"
	id = "robot_syndi"
	ranks = list(ROLE_OPERATIVE)

/datum/spawner/living/robot/drone
	name = "Дрон"
	id = "l_drone"
	wiki_ref = "Maintenance_drone"
	ranks = list(ROLE_DRONE)

/*
 * Religion
*/
/datum/spawner/living/religion_familiar
	name = "Фамильяр Религии"
	desc = "Вы появляетесь в виде какого-то животного в подчинении определённой религии."

	var/datum/religion/religion

/datum/spawner/living/religion_familiar/New(mob/_mob, datum/religion/_religion)
	. = ..(_mob)
	religion = _religion || mob.my_religion

	id = "[mob.name]/[religion.name]"
	desc = "Вы появляетесь в виде [mob.name] в подчинении [religion.name]."

/datum/spawner/living/religion_familiar/spawn_ghost(mob/dead/observer/ghost)
	..()
	religion.add_member(mob, HOLY_ROLE_PRIEST)


/datum/spawner/living/eminence
	name = "Возвышенный культа"
	id = "eminence"
	desc = "Вы станете Возвышенным - ментором и неформальным лидером всего культа."
	ranks = list(ROLE_CULTIST, ROLE_GHOSTLY)

/datum/spawner/living/mimic
	name = "Оживлённый предмет"
	id = "mimic"
	desc = "Вы магическим образом ожили на станции"

/datum/spawner/living/evil_shade
	name = "Злой Дух"
	id = "evil_shade"
	desc = "Магическая сила призвала вас в мир, отомстите живым за причинённые обиды!"

/datum/spawner/living/rat
	name = "Крыса"
	id = "rat"
	desc = "Вы появляетесь в своём новом доме"

/datum/spawner/living/rat/spawn_ghost(mob/dead/observer/ghost)
	. = ..()
	to_chat(mob, "<B>Эта посудина теперь ваш новый дом, похозяйничайте в нём.</B>")
	to_chat(mob, "<B>(Вы можете грызть провода и лампочки).</B>")

/*
 * Heist
*/
/datum/spawner/living/vox
	name = "Вокс-Налётчик"
	desc = "Воксы-налётчики это представители расы Воксов, птице-подобных гуманоидов, дышащих азотом. Прибыли на станцию что бы украсть что-нибудь ценное."
	wiki_ref = "Vox_Raider"

/datum/spawner/spy
	name = "Агент Прослушки"
	id = "spy"
	desc = "Вы появляетесь на аванпосте прослушки Синдиката."

	ranks = list(ROLE_GHOSTLY)

/datum/spawner/spy/can_spawn(mob/dead/observer/ghost)
	if(SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(ghost, "<span class='notice'>Please wait till round start!</span>")
		return FALSE
	return ..()

/datum/spawner/spy/spawn_ghost(mob/dead/observer/ghost)
	var/spawnloc = pick(espionageagent_start)
	espionageagent_start -= spawnloc

	var/client/C = ghost.client

	var/mob/living/carbon/human/H = new(null)
	var/new_name = sanitize_safe(input(C, "Pick a name", "Name") as null|text, MAX_LNAME_LEN)
	C.create_human_apperance(H, new_name)

	H.loc = spawnloc
	H.key = C.key
	H.equipOutfit(/datum/outfit/spy)
	H.mind.skills.add_available_skillset(/datum/skillset/max)
	H.mind.skills.maximize_active_skills()
	H.add_language(LANGUAGE_SYCODE)

	to_chat(H, "<B>Вы - <span class='boldwarning'>Агент Прослушки Синдиката</span>, в чьи задачи входит слежение за активностью на [station_name_ru()].</B>")
	if(mode_has_antags())
		to_chat(H, "<B>Согласно сводкам, именно сегодня Ваши наниматели готовятся нанести удар по корпоративным ублюдкам, и Вы можете посодействовать засланным на станцию агентам.</B>")
	else
		to_chat(H, "<B>Сегодня очередной рабочий день. Ничего из ряда вон выходящего произойти не должно, так что можно расслабиться.</B>")
	to_chat(H, "<B>Вы ни в коем случае не должны покидать свой пост! Невыполнение своих задач приведёт к увольнению.</B>")

/datum/spawner/spy/jump(mob/dead/observer/ghost)
	var/jump_to = pick(espionageagent_start)
	ghost.forceMove(get_turf(jump_to))

/datum/spawner/vox
	name = "Вокс-Налётчик"
	desc = "Воксы-налётчики это представители расы Воксов, птице-подобных гуманоидов, дышащих азотом. Прибыли на станцию что бы украсть что-нибудь ценное."
	wiki_ref = "Vox_Raider"

	ranks = list(ROLE_RAIDER, ROLE_GHOSTLY)
	time_to_del = 5 MINUTES

/datum/spawner/vox/spawn_ghost(mob/dead/observer/ghost)
	var/spawnloc = pick(global.heiststart)
	global.heiststart -= spawnloc

	var/datum/faction/heist/faction = create_uniq_faction(/datum/faction/heist)
	var/mob/living/carbon/human/vox/event/vox = new(spawnloc)

	vox.key = ghost.client.key

	var/sounds = rand(2, 8)
	var/newname = ""
	for(var/i in 1 to sounds)
		newname += pick(list("ti","hi","ki","ya","ta","ha","ka","ya","chi","cha","kah"))

	vox.real_name = capitalize(newname)
	vox.name = vox.real_name
	vox.age = rand(5, 15) // its fucking lore
	vox.add_language(LANGUAGE_VOXPIDGIN)
	if(faction.members.len % 2 == 0 || prob(33)) // first vox always gets Sol, everyone else by random.
		vox.add_language(LANGUAGE_SOLCOMMON)
	vox.h_style = "Short Vox Quills"
	vox.f_style = "Shaved"
	vox.grad_style = "none"

	//Now apply cortical stack.
	var/obj/item/weapon/implant/cortical/I = new(vox)
	I.inject(vox, BP_HEAD)

	vox.equip_vox_raider()
	vox.regenerate_icons()

	add_faction_member(faction, vox)

/datum/spawner/vox/jump(mob/dead/observer/ghost)
	var/jump_to = pick(global.heiststart)
	ghost.forceMove(jump_to)
