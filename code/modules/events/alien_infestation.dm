/datum/event/alien_infestation
	announceWhen	= 400

	var/spawncount = 1
	var/successSpawn = FALSE  //So we don't make a command report if nothing gets spawned.

	announcement = new /datum/announcement/centcomm/aliens


/datum/event/alien_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(3, 4)

/datum/event/alien_infestation/announce()
	if(successSpawn)
		announcement.play()

/datum/event/alien_infestation/start()
	if(!aliens_allowed)
		message_admins("An event attempted to spawn an alien but aliens are locked down. Shutting down.")
		kill()
		return
	var/list/vents = get_vents()

	if(!vents.len)
		message_admins("An event attempted to spawn an alien but no suitable vents were found. Shutting down.")
		return

	var/list/candidates = pollGhostCandidates("Would you like to be \a facehugger?", ROLE_ALIEN, IGNORE_FACEHUGGER)

	while(spawncount > 0 && candidates.len)
		var/obj/vent = pick(vents)
		var/mob/candidate = pick(candidates)

		var/mob/living/carbon/xenomorph/facehugger/new_xeno = new(vent.loc)
		new_xeno.key = candidate.key
		message_admins("[new_xeno] has spawned at [COORD(new_xeno)] [ADMIN_JMP(new_xeno)] [ADMIN_FLW(new_xeno)].")

		candidates -= candidate
		vents -= vent
		spawncount--
		successSpawn = TRUE
