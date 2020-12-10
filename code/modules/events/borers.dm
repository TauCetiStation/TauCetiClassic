//Cortical borer spawn event - care of RobRichards1997 with minor editing by Zuhayr.

/datum/event/borer_infestation
	announceWhen = 400

	var/spawncount = 1
	var/successSpawn = FALSE //So we don't make a command report if nothing gets spawned.

/datum/event/borer_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(1, 3)

/datum/event/borer_infestation/announce()
	if(successSpawn)
		command_alert("Обнаружены неопознанные признаки жизни на борту [station_name()]. Обезопасьте любой доступ снаружи, включая воздуховоды и вентиляцию.", "Неизвестные Формы Жизни", "lfesigns")

/datum/event/borer_infestation/start()
	var/list/vents = get_vents()

	if(!vents.len)
		message_admins("Произошла попытка создать мозговых червей, но подходящих вентиляционных отверстий не найдено. Выключение.")
		kill()
		return

	var/list/candidates = pollGhostCandidates("Заражение! Вы хотите играть за мозгового червя?", ROLE_ALIEN, IGNORE_BORER)

	for(var/mob/M in candidates)
		if(spawncount <= 0 || !vents.len)
			break
		var/obj/vent = pick_n_take(vents)
		var/mob/living/simple_animal/borer/B = new(vent.loc)
		B.transfer_personality(M.client)
		message_admins("[B] появился в [B.x],[B.y],[B.z] [ADMIN_JMP(B)] [ADMIN_FLW(B)].")
		successSpawn = TRUE
		spawncount--

	if(!successSpawn)
		message_admins("Произошла попытка создать мозговых червей, но кандидатов не найдено. Выключение.")
		kill()
		return
