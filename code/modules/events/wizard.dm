/datum/event/wizard
	announceWhen	= 12
	endWhen			= 120

/datum/event/wizard/start()
	if(!length(landmarks_list["Wizard"]))
		kill()
		return

	create_spawner(/datum/spawner/wizard_event)

	var/obj/effect/landmark/L = pick(landmarks_list["Wizard"])
	var/mutable_appearance/wizard_overlay = mutable_appearance('icons/obj/cardboard_cutout.dmi', "cutout_wizard")
	notify_ghosts("Wizard event! Доступна роль в спавнер-меню, чтобы стать магом.", source = L, alert_overlay = wizard_overlay, action = NOTIFY_JUMP, header = "Wizard")
