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
		"Офицер" = /datum/spawner/cop/beatcop,
		"Вооруженный Офицер" = /datum/spawner/cop/armored,
		"Боец Тактической Группы" = /datum/spawner/cop/swat,
		"Инспектор" = /datum/spawner/cop/fbi,
		"Боец ВСНТ" = /datum/spawner/cop/military,
	)

	var/name = input(usr, "Choose a equip of Space Police", "Team Eqip") in equip_by_type
	if(!name)
		return FALSE
	var/type = equip_by_type[name]

	spawn_space_police(team_size, type)

	message_admins("<span class='notice'>[key_name_admin(usr)] has spawned a Space Police.</span>")
	log_admin("[key_name(usr)] used Spawn Space Police.")

	return TRUE

/proc/spawn_space_police(team_size, cops_type)
	create_spawners(cops_type, team_size)
