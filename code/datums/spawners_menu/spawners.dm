var/global/list/datum/spawners = list()

/datum/spawner
	var/name
	var/desc
	var/flavor_text
	var/important_info

	var/required_pref

	var/datum/callback/spawn_ghost

/datum/spawner/New()
	SHOULD_CALL_PARENT(TRUE)
	LAZYADD(global.spawners[type], src)

/datum/spawner/Destroy()
	var/list/spawn_list = global.spawners[type]
	LAZYREMOVE(spawn_list, src)
	if(!length(spawn_list))
		global.spawners -= type
	return ..()

/datum/spawner/proc/do_spawn(mob/dead/observer/ghost)
	if(!can_spawn(ghost))
		return
	spawn_ghost(ghost)

/datum/spawner/proc/can_spawn(mob/dead/observer/ghost)
	if(!ghost.client)
		return FALSE
	if(!required_pref)
		return TRUE
	if(jobban_isbanned(ghost, required_pref) || jobban_isbanned(ghost, "Syndicate") || role_available_in_minutes(ghost, required_pref))
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

	required_pref = ROLE_FAMILIES

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

	required_pref = ROLE_FAMILIES

	var/roletype

/datum/spawner/cop/spawn_ghost(mob/dead/observer/ghost)
	var/spawnloc = pick(copsstart)
	copsstart -= spawnloc

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
