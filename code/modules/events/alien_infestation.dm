/datum/event/alien_infestation
	announceWhen	= 400

	var/spawncount = 1
	var/successSpawn = FALSE  //So we don't make a command report if nothing gets spawned.


/datum/event/alien_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(1, 2)

/datum/event/alien_infestation/announce()
	if(successSpawn)
		command_alert("Обнаружены неопознанные признаки жизни на борту [station_name()]. Обезопасьте любой доступ снаружи, включая воздуховоды и вентиляцию.", "Неизвестные Формы Жизни", "lfesigns")

/datum/event/alien_infestation/start()
	if(!aliens_allowed)
		message_admins("Событие попыталось породить чужих, но они заблокированы. Выключение.")
		kill()
		return
	var/list/vents = get_vents()

	if(!vents.len)
		message_admins("Событие попыталось создать чужого, но нет подходящих вентиляционных отверстий. Выключение.")
		return

	var/list/candidates = pollGhostCandidates("Вы хотите быть личинкой чужого?", ROLE_ALIEN)

	while(spawncount > 0 && candidates.len)
		var/obj/vent = pick(vents)
		var/mob/candidate = pick(candidates)

		var/mob/living/carbon/xenomorph/larva/new_xeno = new(vent.loc)
		new_xeno.key = candidate.key
		message_admins("[new_xeno] появился в [new_xeno.x],[new_xeno.y],[new_xeno.z] [ADMIN_JMP(new_xeno)] [ADMIN_FLW(new_xeno)].")

		candidates -= candidate
		vents -= vent
		spawncount--
		successSpawn = TRUE
