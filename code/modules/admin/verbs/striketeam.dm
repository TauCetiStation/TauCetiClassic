// STRIKE TEAMS

#define COMMANDOS_POSSIBLE 6

var/global/sent_strike_team = FALSE

/client/proc/call_strike_team()
	if (!SSticker)
		to_chat(usr, "<span class='red'>The game hasn't started yet!</span>")
		return FALSE

	if (sent_strike_team)
		to_chat(usr, "<span class='red'>CentCom is already sending a team.</span>")
		return FALSE

	if (tgui_alert(usr, "Do you want to send in the CentCom death squad? Once enabled, this is irreversible.",,"Yes","No") != "Yes")
		return FALSE

	tgui_alert(usr, "This 'mode' will go on until everyone is dead or the station is destroyed. You may also admin-call the evac shuttle when appropriate. Spawned commandos have internals cameras which are viewable through a monitor inside the Spec. Ops. Office. Assigning the team's detailed task is recommended from there. While you will be able to manually pick the candidates from active ghosts, their assignment in the squad will be random.")

	var/input = null
	while (!input)
		input = sanitize(input(src, "Please specify which mission the death commando squad shall undertake.", "Specify Mission", ""))
		if (!input)
			if (tgui_alert(usr, "Error, no mission set. Do you want to exit the setup process?",, list("Yes","No")) == "Yes")
				return FALSE

	// Generates a list of commandos from active client.
	var/list/candidates = list()
	var/list/commandos = list()

	for (var/client/C in clients)
		if (!C.is_afk())
			candidates += C.ckey

	for (var/i in 1 to COMMANDOS_POSSIBLE)
		var/candidate = input("Pick characters to spawn as the commandos. This will go on until there either no more clients to pick from or the slots are full.", "Active Clients") as null|anything in candidates
		if (candidate)
			candidates -= candidate
			commandos += candidate

	if (!commandos.len)
		to_chat(usr, "<span class='red'>No commandos selected.</span>")
		return FALSE

	if (sent_strike_team)
		to_chat(usr, "<span class='red'>Looks like someone beat you to it.</span>")
		return FALSE

	sent_strike_team = TRUE

	if (SSshuttle.direction == 1 && SSshuttle.online)
		SSshuttle.recall()

	// Code for spawning a nuke auth code.
	var/nuke_code = null

	for (var/obj/machinery/nuclearbomb/N in poi_list)
		if (N.nuketype == "NT")
			var/temp_code = text2num(N.r_code)
			if (temp_code)
				nuke_code = N.r_code
				break

	var/is_leader_seleceted = FALSE

	var/datum/faction/strike_team/deathsquad/S = SSticker.mode.CreateFaction(/datum/faction/strike_team/deathsquad)
	S.forgeObjectives(input)
	// Spawns commandos and equips them.
	for (var/obj/effect/landmark/L in landmarks_list)
		if (!commandos.len)
			break

		if (L.name != "Commando")
			continue

		var/is_leader = FALSE

		if (!is_leader_seleceted)
			is_leader_seleceted = TRUE
			is_leader = TRUE

		var/mob/living/carbon/human/new_commando = create_death_commando(get_turf(L), is_leader)

		new_commando.ckey = pick_n_take(commandos)

		// So they don't forget their code or mission.
		create_random_account_and_store_in_mind(new_commando)

		if (nuke_code)
			new_commando.mind.store_memory("<B>Nuke Code:</B> <span class='warning'>[nuke_code]</span>.")
		else
			new_commando.mind.store_memory("<B>Nuke Code:</B> <span class='warning'>NT bomb not found???</span>.")
		new_commando.mind.store_memory("<B>Mission:</B> <span class='warning'>[input]</span>.")

		to_chat(new_commando, "<span class='notice'>You are a Special Ops. [is_leader ? "<B>LEADER</B>" : "commando"] in the service of Central Command. Check the table ahead for detailed instructions.\nYour current mission is: <span class='warning'><B>[input]</B></span></span>")

	message_admins("<span class='notice'>[key_name_admin(usr)] has spawned a CentCom strike squad.</span>")
	log_admin("[key_name(usr)] used Spawn Death Squad.")

	return TRUE

/client/proc/create_death_commando(turf/spawn_location, is_leader)
	var/mob/living/carbon/human/new_commando = new(spawn_location)
	var/commando_leader_rank = pick("Lieutenant", "Captain", "Major")
	var/commando_rank = pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
	var/commando_name = pick(last_names)

	new_commando.gender = pick(MALE, FEMALE)

	// Randomize appearance for the commando
	var/datum/preferences/A = new
	A.randomize_appearance_for(new_commando)

	new_commando.real_name = "[is_leader ? commando_leader_rank : commando_rank] [commando_name]"
	new_commando.age = is_leader ? rand(new_commando.species.min_age * 1.25, new_commando.species.min_age * 1.75) :  rand(new_commando.species.min_age, new_commando.species.min_age * 1.5)

	new_commando.dna.ready_dna(new_commando)

	// Creates mind stuff
	new_commando.mind_initialize()
	new_commando.equip_death_commando(is_leader)
	var/datum/faction/strike_team/deathsquad/D = find_faction_by_type(/datum/faction/strike_team/deathsquad)
	if(D)
		add_faction_member(D, new_commando, FALSE)
	return new_commando

/mob/living/carbon/human/proc/equip_death_commando(is_leader)
	equip_to_slot_or_del(new /obj/item/device/radio/headset/deathsquad(src), SLOT_L_EAR)

	if (is_leader)
		equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom_officer(src), SLOT_W_UNIFORM)
	else
		equip_to_slot_or_del(new /obj/item/clothing/under/color/green(src), SLOT_W_UNIFORM)

	equip_to_slot_or_del(new /obj/item/clothing/shoes/boots/swat(src), SLOT_SHOES)
	equip_to_slot_or_del(new /obj/item/clothing/suit/armor/swat(src), SLOT_WEAR_SUIT)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(src), SLOT_GLOVES)
	equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/deathsquad(src), SLOT_HEAD)
	equip_to_slot_or_del(new /obj/item/clothing/mask/gas/swat(src), SLOT_WEAR_MASK)
	equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal(src), SLOT_GLASSES)

	equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/security(src), SLOT_BACK)
	equip_to_slot_or_del(new /obj/item/weapon/storage/box(src), SLOT_IN_BACKPACK)

	equip_to_slot_or_del(new /obj/item/ammo_box/a357(src), SLOT_IN_BACKPACK)
	equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/regular(src), SLOT_IN_BACKPACK)
	equip_to_slot_or_del(new /obj/item/weapon/storage/box/flashbangs(src), SLOT_IN_BACKPACK)
	equip_to_slot_or_del(new /obj/item/device/flashlight(src), SLOT_IN_BACKPACK)

	if (is_leader)
		equip_to_slot_or_del(new /obj/item/weapon/pinpointer(src), SLOT_IN_BACKPACK)
		equip_to_slot_or_del(new /obj/item/weapon/disk/nuclear(src), SLOT_IN_BACKPACK)
	else
		equip_to_slot_or_del(new /obj/item/weapon/plastique(src), SLOT_IN_BACKPACK)

	equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword(src), SLOT_L_STORE)
	equip_to_slot_or_del(new /obj/item/weapon/grenade/flashbang(src), SLOT_R_STORE)
	equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen(src), SLOT_S_STORE)
	equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/revolver/mateba(src), SLOT_BELT)

	equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse_rifle(src), SLOT_R_HAND)

	var/obj/item/weapon/implant/mindshield/loyalty/L = new(src)
	L.inject(src)

	var/obj/item/weapon/card/id/centcom/C = new(src)
	C.name = "[real_name]'s ID Card"
	C.registered_name = real_name
	equip_to_slot_or_del(C, SLOT_WEAR_ID)

#undef COMMANDOS_POSSIBLE
