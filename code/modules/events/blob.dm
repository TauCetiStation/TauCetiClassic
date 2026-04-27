/datum/event/blob
	announceWhen	= 12
	endWhen			= 120

/datum/event/blob/start()
	if(!length(landmarks_list["blobstart"])) // add return codes for create_spawner
		kill()
		return

	create_spawner(/datum/spawner/blob_event)

	var/obj/effect/landmark/L = pick(landmarks_list["blobstart"])
	var/mutable_appearance/blob_overlay = mutable_appearance('icons/mob/blob.dmi', "blob_core")
	notify_ghosts("Blob event! Доступна роль в спавнер-меню, чтобы стать блобом.", source = L, alert_overlay = blob_overlay, action = NOTIFY_JUMP, header = "Blob")
