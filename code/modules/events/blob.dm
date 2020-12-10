/datum/event/blob
	announceWhen	= 12
	endWhen			= 120

/datum/event/blob/announce()
	command_alert("Подтверждена вспышка биологической опасности 5-го уровня на борту [station_name()]. Весь персонал должен сдерживать вспышку. Протоколы изоляции экипажа станции теперь активны.", "Биологическая Угроза", "outbreak5")

/datum/event/blob/start()
	var/turf/T = pick(blobstart)
	if(!T)
		kill()
		return

	var/list/candidates = pollGhostCandidates("Вы хотите играть за БЛОБА?", ROLE_BLOB, poll_time = 150)
	if(!candidates.len)
		kill()
		return

	var/mob/candidate = pick(candidates)

	var/obj/effect/blob/core/B = new /obj/effect/blob/core(T, 120, candidate.client)
	message_admins("[B] появился в [B.x],[B.y],[B.z] [ADMIN_JMP(B)] [ADMIN_FLW(B)].")
