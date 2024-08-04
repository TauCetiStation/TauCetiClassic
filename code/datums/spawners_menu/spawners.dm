// Don't call this proc directly! Use defines create_spawner and create_spawners
/proc/_create_spawners(type, num, list/arguments)
	if(!ispath(type, /datum/spawner))
		CRASH("Attempted to create a spawner with wrong type: [type]")

	var/datum/spawner/spawner

	var/need_update = FALSE
	// check if we should just update existing spawner
	if(!length(arguments))
		for(var/datum/spawner/S in SSrole_spawners.spawners)
			if(S.type == type && !S.should_be_unique)
				spawner = S

		// arguments must have at least 1 element due to the use of arglist
		arguments += null

	if(!spawner)
		spawner = new type(arglist(arguments))
		need_update = TRUE

	if(spawner.should_be_unique && num > 1)
		stack_trace("Attempted to create unique spawner with multiple positions: [type]")
	else
		spawner.positions += num

	if(!need_update)
		return

	SSrole_spawners.add_to_list(spawner)

	for(var/mob/dead/observer/ghost in observer_list)
		if(!ghost.client)
			continue

		var/datum/hud/ghost/ghost_hud = ghost.hud_used
		var/image/I = image(ghost_hud.spawners_menu_button.icon, ghost_hud.spawners_menu_button, "spawners_update")
		flick_overlay(I, list(ghost.client), 10 SECONDS)

		to_chat(ghost, "<span class='ghostalert'>Доступны новые роли в меню возрождения!</span>")

	return spawner

/datum/spawner
	// Name of spawner, wow
	var/name

	// Priority of spawner, affects position in menu and roll order for lobby spawners
	var/priority = 100

	// In interface: "Описание: "
	var/desc
	// In interface: "Важная информация: "
	var/important_info
	// In interface: "Ссылка на вики: "
	var/wiki_ref

	// Name of landmark in landmarks_list that should be used as spawn point
	// you can left it empty and use own methonds in jump() and spawn_body()
	var/spawn_landmark_name

	// Roles and jobs that will be checked for jobban and minutes
	var/list/ranks

	// How many times can be used, number or INFINITY
	var/positions = 0
	// Flag if spawner should not be created with multile positions
	var/should_be_unique = FALSE

	// Flag if you want to temporary block spawner for use
	var/blocked = FALSE

	// Flag if it's awaylable only for applications first, and will be rolled for spawn later
	var/register_only = FALSE

	// List of clients who checked for spawner
	var/list/registered_candidates = list()

	// Automatically roll for registred clients at round start, autosets register_only
	var/lobby_spawner = FALSE // todo: maybe use -1 for time_for_registration as roll mode

	// Time for clients for registration before spawn will be automatically rolled
	// Can be zero if you want to trigger roll manually or use as lobby spawner
	var/time_for_registration

	// Time for spawner to be active, spawner will be deleted after time ends
	var/time_while_available

	// Cooldown between the opportunity become a role
	var/cooldown = 10 MINUTES
	// Set this if you want to share cooldown between several spawners, can be type or unique key
	var/cooldown_type

	// optionally you can link faction for additional field in meny "playing"
	var/datum/faction/faction // todo: print faction logo in spawn menu?

	// id of timers
	var/registration_timer_id
	var/availability_timer_id

/datum/spawner/New()
	SHOULD_CALL_PARENT(TRUE)
	. = ..()

	if(SSticker.current_state >= GAME_STATE_PLAYING)
		start_timers()
	else
		if(lobby_spawner)
			register_only = TRUE
		RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(start_timers))

/datum/spawner/proc/start_timers()
	// todo: should we start del timer, if registration timer is active?
	if(register_only && time_for_registration && !lobby_spawner)
		registration_timer_id = addtimer(CALLBACK(src, PROC_REF(roll_registrations)), time_for_registration, TIMER_STOPPABLE)
	if(time_while_available)
		availability_timer_id = QDEL_IN(src, time_while_available)


/datum/spawner/Destroy()
	SSrole_spawners.remove_from_list(src)

	spawn_landmark_name = null

	deltimer(registration_timer_id)
	deltimer(availability_timer_id)

	if(length(registered_candidates))
		for(var/mob/dead/M in registered_candidates)
			M.registred_spawner = null
		registered_candidates = null

	return ..()

/datum/spawner/proc/add_client_cooldown(client/C)
	if(cooldown)
		if(!SSrole_spawners.spawners_cooldown[C.ckey])
			SSrole_spawners.spawners_cooldown[C.ckey] = list()
		var/list/ckey_cooldowns = SSrole_spawners.spawners_cooldown[C.ckey]
		var/cooldown_key = cooldown_type ? cooldown_type : type
		ckey_cooldowns[cooldown_key] = world.time + cooldown

/datum/spawner/proc/check_cooldown(mob/dead/spectator)
	if(SSrole_spawners.spawners_cooldown[spectator.ckey])
		var/list/ckey_cooldowns = SSrole_spawners.spawners_cooldown[spectator.ckey]
		var/cooldown_key = cooldown_type ? cooldown_type : type
		if(world.time < ckey_cooldowns[cooldown_key])
			var/timediff = round((ckey_cooldowns[cooldown_key] - world.time) * 0.1)
			to_chat(spectator, "<span class='danger'>Вы сможете снова зайти за эту роль через [timediff] секунд!</span>")
			return FALSE
	return TRUE

/datum/spawner/proc/registration(mob/dead/spectator)
	if(blocked)
		return

	if(!spectator.client || spectator.client.is_in_spawner)
		return

	if(!register_only)
		if(positions < 1)
			to_chat(spectator, "<span class='notice'>Нет свободных позиций для роли.</span>")
		else
			positions--
			do_spawn(spectator)
		return

	// todo: registration for multiple spawners?
	if(spectator in registered_candidates)
		cancel_registration(spectator)
		to_chat(spectator, "<span class='notice'>Вы отменили заявку на роль \"[name]\".</span>")
		return

	else if(spectator.registred_spawner)
		to_chat(spectator, "<span class='notice'>Вы уже ждете роль \"[spectator.registred_spawner.name]\". Сначала отмените заявку.</span>")
		return

	if(!can_spawn(spectator))
		return

	registered_candidates += spectator
	spectator.registred_spawner = src

	to_chat(spectator, "<span class='notice'>Вы изъявили желание на роль \"[name]\". Доступные позиции будет случайно разыграны между всеми желающими по истечении таймера.</span>")

/datum/spawner/proc/cancel_registration(mob/dead/spectator)
	registered_candidates -= spectator
	spectator.registred_spawner = null

/datum/spawner/proc/roll_registrations()
	register_only = FALSE

	if(!length(registered_candidates))
		return

	var/list/filtered_candidates = list()

	// possible some candidates already spawned
	// todo: control of this should be part of subsystem
	for(var/mob/dead/M in registered_candidates)
		if(M.client)
			filtered_candidates += M

	registered_candidates.Cut()

	if(!length(filtered_candidates))
		return

	shuffle(filtered_candidates)

	for(var/mob/dead/M in filtered_candidates)
		if(positions > 0)
			positions--
			to_chat(M, "<span class='notice'>Вы получили роль \"[name]\"!</span>")
			INVOKE_ASYNC(src, PROC_REF(do_spawn), M)
		else
			to_chat(M, "<span class='warning'>К сожалению, вам не выпала роль \"[name]\".</span>")


/datum/spawner/proc/do_spawn(mob/dead/spectator)
	if(!can_spawn(spectator))
		positions++
		return

	var/client/C = spectator.client

	// temporary flag to fight some races because of pre-spawn dialogs in spawn_body of some spawners
	// we should fight it and first spawn user, so he can't access spawn menu anymore,
	// and only then allow costumization in separated thread
	C.is_in_spawner = TRUE

	if(isnewplayer(spectator))
		var/mob/dead/new_player/NP = spectator
		spectator = NP.spawn_as_observer() // need to check if we can skip this step

	spawn_body(spectator)

	C.is_in_spawner = FALSE
	// check if the spectator really moved to a new body
	if(spectator.client == C)
		positions++
		return

	message_admins("[C.ckey] as \"[name]\" has spawned at [COORD(C.mob)] [ADMIN_JMP(C.mob)] [ADMIN_FLW(C.mob)].")
	add_client_cooldown(C)

	if(positions < 1)
		qdel(src)

/datum/spawner/proc/can_spawn(mob/dead/spectator)
	if(!check_cooldown(spectator))
		return FALSE
	if(!ranks)
		return TRUE
	for(var/rank in ranks)
		if(jobban_isbanned(spectator, rank))
			to_chat(spectator, "<span class='danger'>Роль - \"[name]\" для Вас заблокирована!</span>")
			return FALSE
		if(role_available_in_minutes(spectator, rank))
			to_chat(spectator, "<span class='danger'>У Вас не хватает минут, чтобы зайди за роль \"[name]\". Чтобы её разблокировать вам нужно просто играть!</span>")
			return FALSE
	return TRUE

/datum/spawner/proc/pick_spawn_location()
	if(!length(landmarks_list[spawn_landmark_name]))
		CRASH("[src.type] attempts to pick spawn location \"[spawn_landmark_name]\", but can't find one!")

	return pick_landmarked_location(spawn_landmark_name)

/datum/spawner/proc/spawn_body(mob/dead/spectator)
	return

/datum/spawner/proc/jump(mob/dead/spectator)
	if(!length(landmarks_list[spawn_landmark_name]))
		to_chat(spectator, "<span class='notice'>У этой роли нет предустановленных локаций для спавна.</span>")
		return
	var/jump_to = pick(landmarks_list[spawn_landmark_name])
	spectator.forceMove(get_turf(jump_to))

/*
 * Families
*/
/datum/spawner/dealer
	name = "Контрабандист"
	desc = "Вы появляетесь в космосе вблизи со станцией."
	wiki_ref = "Families"

	ranks = list(ROLE_FAMILIES)

	spawn_landmark_name = "Dealer" // /obj/effect/landmark/dealer_spawn

/datum/spawner/dealer/spawn_body(mob/dead/spectator)
	var/spawnloc = pick_spawn_location()

	var/client/C = spectator.client

	var/mob/living/carbon/human/H = new(null)
	var/new_name = sanitize_safe(input(C, "Pick a name", "Name") as null|text, MAX_LNAME_LEN)
	C.create_human_apperance(H, new_name)

	H.loc = spawnloc
	H.key = C.key

	create_and_setup_role(/datum/role/traitor/dealer, H, TRUE)

/datum/spawner/cop
	name = "Офицер ОБОП"
	desc = "Вы появляетесь на ЦК в полном обмундировании с целью прилететь на станцию и задержать всех бандитов."
	wiki_ref = "Families"

	ranks = list(ROLE_FAMILIES)

	register_only = TRUE
	time_for_registration = 0.5 MINUTES

	var/roletype
	var/list/prefixes = list("Officer")

	spawn_landmark_name = "Space Cops" // /obj/effect/landmark/cops_spawn

/datum/spawner/cop/spawn_body(mob/dead/spectator)
	var/spawnloc = pick_spawn_location()

	var/client/C = spectator.client

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

/datum/spawner/cop/beatcop
	name = "Офицер ОБОП"
	roletype = /datum/role/cop/beatcop

/datum/spawner/cop/armored
	name = "Вооруженный Офицер ОБОП"
	roletype = /datum/role/cop/beatcop/armored

/datum/spawner/cop/swat
	name = "Боец Тактической Группы ОБОП"
	roletype = /datum/role/cop/beatcop/swat
	prefixes = list("Sergeant", "Captain")

/datum/spawner/cop/fbi
	name = "Инспектор ОБОП"
	roletype = /datum/role/cop/beatcop/fbi
	prefixes = list("Inspector")

/datum/spawner/cop/military
	name = "Боец ВСНТ ОБОП"
	roletype = /datum/role/cop/beatcop/military
	prefixes = list("Pvt.", "PFC", "Cpl.", "LCpl.", "SGT")

/*
 * Blob
*/
/datum/spawner/blob_event
	name = "Блоб"
	desc = "Вы появляетесь в случайной точки станции в виде блоба."
	wiki_ref = "Blob"

	ranks = list(ROLE_BLOB)

	register_only = TRUE
	time_for_registration = 0.5 MINUTES

	time_while_available = 3 MINUTES

	spawn_landmark_name = "blobstart"

/datum/spawner/blob_event/spawn_body(mob/dead/spectator)
	var/turf/spawn_turf = pick_spawn_location()
	new /obj/structure/blob/core(spawn_turf, spectator.client, 120)

/*
 * Ninja
*/
/datum/spawner/ninja_event
	name = "Космический Ниндзя"
	desc = "Вы появляетесь в додзё. Из него вы можете телепортироваться на станцию."
	wiki_ref = "Space_Ninja"

	ranks = list(ROLE_NINJA)

	register_only = TRUE
	time_for_registration = 0.5 MINUTES

	time_while_available = 3 MINUTES

	spawn_landmark_name = "ninja"

/datum/spawner/ninja_event/spawn_body(mob/dead/spectator)
	var/spawnloc = pick_spawn_location()
	if(!spawnloc)
		spawnloc = latejoin
	var/mob/living/carbon/human/new_ninja = create_space_ninja(spawnloc)
	new_ninja.key = spectator.key

	var/datum/faction/ninja/N = create_uniq_faction(/datum/faction/ninja)
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

	register_only = TRUE
	time_for_registration = 0.5 MINUTES

	time_while_available = 3 MINUTES

/datum/spawner/borer_event/spawn_body(mob/dead/spectator)
	var/list/vents = get_vents()
	var/obj/vent = pick_n_take(vents)
	var/mob/living/simple_animal/borer/B = new(vent.loc, FALSE, 1)
	B.transfer_personality(spectator.client)

/*
 * Aliens
*/
/datum/spawner/alien_event
	name = "Изначальный Лицехват"
	desc = "Вы появляетесь где-то в вентиляции станции и должны развить потомство."
	wiki_ref = "Xenomorph"

	ranks = list(ROLE_ALIEN)

	register_only = TRUE
	time_for_registration = 0.5 MINUTES

	time_while_available = 3 MINUTES

/datum/spawner/alien_event/spawn_body(mob/dead/spectator)
	var/list/vents = get_vents()
	var/obj/vent = pick(vents)
	var/mob/living/carbon/xenomorph/facehugger/new_xeno = new(vent.loc)
	new_xeno.key = spectator.key

/*
 * Other
*/
/datum/spawner/gladiator
	name = "Гладиатор"
	desc = "Вы появляетесь на арене и должны выжить."
	wiki_ref = "Starter_Guide#Арена"

	ranks = list(ROLE_GHOSTLY)
	cooldown = 0
	positions = INFINITY

	spawn_landmark_name = "eorgwarp"

/datum/spawner/gladiator/spawn_body(mob/dead/spectator)
	var/spawnloc = pick_spawn_location()
	SSticker.spawn_gladiator(spectator, FALSE, spawnloc)

/datum/spawner/mouse
	name = "Мышь"
	desc = "Вы появляетесь в суровом мире людей и должны выжить."
	wiki_ref = "Mouse"

	priority = 1000

	ranks = list("Mouse")
	positions = INFINITY

/datum/spawner/mouse/can_spawn(mob/dead/spectator)
	if(config.disable_player_mice)
		to_chat(spectator, "<span class='warning'>Spawning as a mouse is currently disabled.</span>")
		return FALSE
	return ..()

/datum/spawner/mouse/spawn_body(mob/dead/spectator)
	spectator.mousize()

/datum/spawner/space_bum
	name = "Космо-бомж"
	desc = "Вы появляетесь где-то на свалке."
	wiki_ref = "Junkyard"

	positions = INFINITY

	spawn_landmark_name = "Junkyard Bum" // /obj/effect/landmark/junkyard_bum

/datum/spawner/space_bum/spawn_body(mob/dead/spectator)
	spectator.make_bum()

/datum/spawner/drone
	name = "Дрон"
	desc = "Вы появляетесь на дронстанции и обязаны ремонтировать станцию."
	wiki_ref = "Drone"

	priority = 1000

	ranks = list(ROLE_DRONE)

	positions = INFINITY

/datum/spawner/drone/can_spawn(mob/dead/spectator)
	if(!config.allow_drone_spawn)
		to_chat(spectator, "<span class='warning'>That verb is not currently permitted.</span>")
		return FALSE
	return ..()

/datum/spawner/drone/jump(mob/dead/spectator)
	var/obj/machinery/drone_fabricator/DF = locate() in global.machines
	spectator.forceMove(get_turf(DF))

/datum/spawner/drone/spawn_body(mob/dead/spectator)
	spectator.dronize()

/datum/spawner/spy
	name = "Агент Прослушки"
	desc = "Вы появляетесь на аванпосте прослушки Синдиката."

	ranks = list(ROLE_GHOSTLY)

	register_only = TRUE
	time_for_registration = 1 MINUTES

	spawn_landmark_name = "Espionage Agent Start" // /obj/effect/landmark/espionage_start

/datum/spawner/spy/can_spawn(mob/dead/spectator)
	if(SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(spectator, "<span class='notice'>Please wait till round start!</span>")
		return FALSE
	return ..()

/datum/spawner/spy/spawn_body(mob/dead/spectator)
	var/spawnloc = pick_spawn_location()

	var/client/C = spectator.client

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

/datum/spawner/vox
	name = "Вокс-Налётчик"
	desc = "Воксы-налётчики это представители расы Воксов, птице-подобных гуманоидов, дышащих азотом. Прибыли на станцию что бы украсть что-нибудь ценное."
	wiki_ref = "Vox_Raider"

	ranks = list(ROLE_RAIDER, ROLE_GHOSTLY)

	register_only = TRUE
	time_for_registration = 0.5 MINUTES

	time_while_available = 5 MINUTES

	spawn_landmark_name = "Heist"

/datum/spawner/vox/spawn_body(mob/dead/spectator)
	var/spawnloc = pick_spawn_location()

	var/datum/faction/heist/faction = create_uniq_faction(/datum/faction/heist)
	var/mob/living/carbon/human/vox/event/vox = new(spawnloc)

	vox.key = spectator.client.key

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

/datum/spawner/abductor
	name = "Похититель"
	desc = "Технологически развитое сообщество пришельцев, которые занимаются каталогизированием других существ в Галактике. К сожалению для этих существ, методы похитителей, мягко выражаясь, агрессивны."
	wiki_ref = "Abductor"

	ranks = list(ROLE_ABDUCTOR, ROLE_GHOSTLY)

	register_only = TRUE
	time_for_registration = 0.5 MINUTES

	time_while_available = 5 MINUTES

/datum/spawner/abductor/spawn_body(mob/dead/spectator)
	// One team. Working together
	var/datum/faction/abductors/team_fac = create_uniq_faction(/datum/faction/abductors)
	//Nullspace for spawning and assigned key causes image freeze, so move body to non-playing area
	var/mob/living/carbon/human/abductor/event/body_abductor = new(pick(newplayer_start))
	body_abductor.key = spectator.client.key
	add_faction_member(team_fac, body_abductor, team_fac.get_needed_teamrole())

/datum/spawner/abductor/jump(mob/dead/spectator)
	var/obj/effect/landmark/L = scientist_landmarks[1]
	spectator.forceMove(L.loc)

/datum/spawner/abductor/check_cooldown(mob/dead/spectator)
	return TRUE

/datum/spawner/survival
	name = "Выживший (Инженер)"
	desc = "Вы просыпаетесь на заброшенной станции. Адаптируйтесь, выживайте и всё такое."
	var/outfit = /datum/outfit/survival/engineer
	var/skillset = /datum/skillset/survivalist_engi

	ranks = list(ROLE_GHOSTLY)

	register_only = TRUE
	time_for_registration = 0.5 MINUTES

	spawn_landmark_name = "Survivalist Start"

/datum/spawner/survival/can_spawn(mob/dead/spectator)
	if(SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(spectator, "<span class='notice'>Please wait till round start!</span>")
		return FALSE
	return ..()

/datum/spawner/survival/spawn_body(mob/dead/spectator)
	var/spawnloc = pick_spawn_location()

	var/client/C = spectator.client

	var/mob/living/carbon/human/H = new(null)
	C.create_human_apperance(H)

	H.loc = spawnloc
	H.key = C.key
	H.equipOutfit(outfit)
	H.mind.skills.add_available_skillset(skillset)
	H.mind.skills.maximize_active_skills()

	to_chat(H, "<B>Ваша голова раскалывается...Вы просыпаетесь в старом криоподе.</B>")
	to_chat(H, "<B>Вы - <span class='boldwarning'>были работником передовой Космической Научной Станции Нанотрасен LCR</span>, что уже как год считается уничтоженной.</B>")
	to_chat(H, "<B>Станция заброшена, никто, кроме вас и вашего товарища в соседней криокамере, не выжил. Вы вольны делать здесь что угодно. Можете попытаться всё починить, а можете просто улететь в поисках лучшей жизни. Выбор за вами.</B>")

/datum/spawner/survival/med
	name = "Выживший (Медик)"

	outfit = /datum/outfit/survival/medic
	skillset = /datum/skillset/survivalist_medic

/*
 * Lone operative
*/
/datum/spawner/lone_op_event
	name = "Оперативник Синдиката"
	desc = "Вы появляетесь на малой базе Синдиката с невероятно сложным заданием."
	wiki_ref = "Syndicate_Guide"

	ranks = list(ROLE_GHOSTLY)

	register_only = TRUE
	time_for_registration = 0.5 MINUTES

	spawn_landmark_name = "Solo operative"

/datum/spawner/lone_op_event/spawn_body(mob/dead/spectator)
	var/spawnloc = pick_spawn_location()

	var/client/C = spectator.client

	var/mob/living/carbon/human/H = new(null)
	var/new_name = "Gorlex Maradeurs Operative"
	C.create_human_apperance(H, new_name)

	H.loc = spawnloc
	H.key = C.key

	create_and_setup_role(/datum/role/operative/lone, H, TRUE, TRUE)

/*
 * Midround wizard
*/
/datum/spawner/wizard_event
	name = "Маг"
	desc = "Вы просыпаетесь в Логове Волшебника, с неотложным заданием от Федерации магов."

	ranks = list(ROLE_GHOSTLY)

	register_only = TRUE
	time_for_registration = 0.5 MINUTES

	spawn_landmark_name = "Wizard"

/datum/spawner/wizard_event/New()
	. = ..()
	desc = "Вы просыпаетесь в [pick("Логове Волшебника", "Убежище мага", "Винтерхолде", "Башне мага")] с неотложным заданием от Федерации магов."

/datum/spawner/wizard_event/spawn_body(mob/dead/spectator)
	var/spawnloc = pick_spawn_location()
	var/mob/living/carbon/human/H = new(null)
	var/new_name = "Wizard The Unbenannt"
	INVOKE_ASYNC(spectator.client, TYPE_PROC_REF(/client, create_human_apperance), H, new_name, TRUE)

	H.loc = spawnloc
	H.key = spectator.client.key

	var/datum/role/wizard/R = SSticker.mode.CreateRole(/datum/role/wizard, H)
	R.rename = FALSE
	setup_role(R, TRUE)
