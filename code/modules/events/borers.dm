//Cortical borer spawn event - care of RobRichards1997 with minor editing by Zuhayr.

/datum/event/borer_infestation
	announceWhen = 400
	announcement = new /datum/announcement/centcomm/aliens

	var/spawncount = 1
	var/successSpawn = FALSE //So we don't make a command report if nothing gets spawned.

/datum/event/borer_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(1, 3)

/datum/event/borer_infestation/announce()
	if(successSpawn)
		announcement.play()

/datum/event/borer_infestation/start()
	var/list/vents = get_vents()

	if(!vents.len)
		message_admins("An event attempted to spawn a borers, but no suitable vents were found. Shutting down.")
		kill()
		return

	var/list/candidates = pollGhostCandidates("Borer Infestation! Do you want to play as a Cortical Borer?", ROLE_GHOSTLY, IGNORE_BORER)

	create_uniq_faction(/datum/faction/borers)

	for(var/mob/M in candidates)
		if(spawncount <= 0 || !vents.len)
			break
		var/obj/vent = pick_n_take(vents)
		var/mob/living/simple_animal/borer/B = new(vent.loc, FALSE, 1)
		B.transfer_personality(M.client)
		message_admins("[B] has spawned at [COORD(B)] [ADMIN_JMP(B)] [ADMIN_FLW(B)].")
		successSpawn = TRUE
		spawncount--

	if(!successSpawn)
		message_admins("An event attempted to spawn a borers, but no candidates found. Shutting down.")
		kill()
		return
