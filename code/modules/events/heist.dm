/datum/event/heist
	announceWhen = 12
	endWhen      = 120

/datum/event/heist/start()
	if(!length(landmarks_list["Heist"]))
		kill()
		return

	create_uniq_faction(/datum/faction/heist)

	var/obj/effect/landmark/L = pick(landmarks_list["Heist"])
	var/mutable_appearance/raider_overlay = mutable_appearance('icons/obj/cardboard_cutout.dmi', "cutout_voxraider")
	notify_ghosts("Heist event! Доступна роль в спавнер-меню, чтобы стать вокс-налётчиком.", source = L, alert_overlay = raider_overlay, action = NOTIFY_JUMP, header = "Heist")
