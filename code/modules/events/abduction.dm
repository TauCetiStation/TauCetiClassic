/datum/event/abduction
	announceWhen = 12
	endWhen      = 120

/datum/event/abduction/start()
	create_uniq_faction(/datum/faction/abductors)

	var/obj/effect/landmark/L = scientist_landmarks[1]
	if(L)
		var/mutable_appearance/abductor_overlay = mutable_appearance('icons/effects/landmarks_static.dmi', "abductor_agent")
		notify_ghosts("Abduction event! Доступна роль в спавнер-меню, чтобы стать похитителем.", source = L, alert_overlay = abductor_overlay, action = NOTIFY_JUMP, header = "Abductors")
