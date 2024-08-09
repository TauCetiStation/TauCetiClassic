/datum/role/malf_drone
	name = MALF_DRONE
	id = MALF_DRONE

	antag_hud_type = ANTAG_HUD_MALF
	antag_hud_name = "hudmalai"

	logo_state = "malf-logo"

/datum/role/malf_drone/Greet(greeting, custom)
	. = ..()
	antag.current.playsound_local(null, 'sound/antag/malf.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	to_chat(antag.current, {"<span class='notice'><b>
Вы - сбойный дрон
------------------</b></span>"})


