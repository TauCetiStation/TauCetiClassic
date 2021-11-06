/datum/event/blob
	announceWhen	= 12
	endWhen			= 120

/datum/event/blob/start()
	var/turf/T = pick(blobstart)
	if(!T)
		kill()
		return

	var/list/candidates = pollGhostCandidates("Do you want to play as a BLOB?", ROLE_BLOB, IGNORE_EVENT_BLOB, poll_time = 150)
	if(!candidates.len)
		kill()
		return

	var/mob/candidate = pick(candidates)

	var/obj/effect/blob/core/B = new /obj/effect/blob/core(T, 120, candidate.client)
	message_admins("[B] has spawned at [COORD(B)] [ADMIN_JMP(B)] [ADMIN_FLW(B)].")
