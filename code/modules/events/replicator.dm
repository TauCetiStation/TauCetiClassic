/datum/event/replicator
	announceWhen	= 12
	endWhen			= 120

/datum/event/replicator/start()
	if(!length(landmarks_list["replicator"]))
		kill()
		return

	create_spawner(/datum/spawner/replicator_event)

	var/obj/effect/landmark/L = pick(landmarks_list["replicator"])
	var/mutable_appearance/rep_overlay = mutable_appearance('icons/mob/replicator.dmi', "replicator")
	notify_ghosts("Replicator event! Доступна роль в спавнер-меню.", source = L, alert_overlay = rep_overlay, action = NOTIFY_JUMP, header = "Replicator")
