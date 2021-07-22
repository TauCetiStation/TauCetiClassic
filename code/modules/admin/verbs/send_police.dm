/client/proc/send_space_police()
	if (!SSticker || !SSticker.mode)
		to_chat(usr, "<span class='red'>The game hasn't started yet!</span>")
		return FALSE

	if (tgui_alert(usr, "Do you want to send in the CentCom Space Police?",,list("Yes","No")) != "Yes")
		return FALSE

	var/team_size = input(usr, "Enter a size of team of Space Police", "Team Size") as num
	if(!team_size)
		return FALSE

	var/list/equip_by_type = list(
		"Офицер" = /datum/role/cop/beatcop,
		"Вооруженный Офицер" = /datum/role/cop/beatcop/armored,
		"Боец Тактической Группы" = /datum/role/cop/beatcop/swat,
		"Инспектор" = /datum/role/cop/beatcop/fbi,
		"Боец ВСНТ" = /datum/role/cop/beatcop/military,
	)

	var/name = input(usr, "Choose a equip of Space Police", "Team Eqip") in equip_by_type
	if(!name)
		return FALSE
	var/type = equip_by_type[name]

	spawn_space_police(team_size, type)

	message_admins("<span class='notice'>[key_name_admin(usr)] has spawned a Space Police.</span>")
	log_admin("[key_name(usr)] used Spawn Space Police.")

	return TRUE

/proc/spawn_space_police(team_size, cops_to_send)
	var/list/candidates = pollGhostCandidates("Хотите помочь разобраться с преступностью на станции?", ROLE_FAMILIES,)
	if(candidates.len)
		//Pick the (un)lucky players
		var/numagents = min(team_size, candidates.len)

		var/list/spawnpoints = global.copsstart
		var/index = 0
		while(numagents && candidates.len)
			var/spawnloc = spawnpoints[index+1]
			//loop through spawnpoints one at a time
			index = (index + 1) % spawnpoints.len
			var/mob/dead/observer/chosen_candidate = pick(candidates)
			candidates -= chosen_candidate
			if(!chosen_candidate.key)
				continue

			INVOKE_ASYNC(GLOBAL_PROC, .proc/police_create_apperance, spawnloc, chosen_candidate.client, cops_to_send)

			numagents--

/proc/police_create_apperance(spawnloc, client/C, cops_to_send)
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
		faction.roletype = cops_to_send
		add_faction_member(faction, cop, TRUE, TRUE)

	var/obj/item/weapon/card/id/W = cop.wear_id
	W.name = "[cop.real_name]'s ID Card ([W.assignment])"
	W.registered_name = cop.real_name
