/datum/event/lone_op
	announceWhen	= 12
	endWhen			= 120

/datum/event/lone_op/start()
	if(!length(landmarks_list["Solo operative"]))
		kill()
		return

	create_spawner(/datum/spawner/lone_op_event)

	var/obj/effect/landmark/L = pick(landmarks_list["Solo operative"])
	var/mutable_appearance/op_overlay = mutable_appearance('icons/obj/cardboard_cutout.dmi', "cutout_flukecombat")
	notify_ghosts("Lone operative event! Доступна роль в спавнер-меню, чтобы стать одиночным агентом Синдиката.", source = L, alert_overlay = op_overlay, action = NOTIFY_JUMP, header = "Lone Operative")
