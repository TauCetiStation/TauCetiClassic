/datum/event/blob
	announceWhen	= 12
	endWhen			= 120

/datum/event/blob/announce()
	command_alert("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak. The station crew isolation protocols are now active.", "Biohazard Alert", "outbreak5")

/datum/event/blob/start()
	var/turf/T = pick(blobstart)
	if(!T)
		kill()
		return

	var/list/candidates = pollGhostCandidates("Do you want to play as a BLOB?", ROLE_BLOB, 15)
	if(!candidates.len)
		kill()
		return

	var/mob/candidate = pick(candidates)

	var/obj/effect/blob/core/B = new /obj/effect/blob/core(T, 120, candidate.client)
	message_admins("[B] has spawned at [B.x],[B.y],[B.z] [ADMIN_JMP(B)] [ADMIN_FLW(B)].")
