/datum/role/malf_drone
	name = MALF_DRONE
	id = MALF_DRONE

	antag_hud_type = ANTAG_HUD_MALF
	antag_hud_name = "hudmalai"

	logo_state = "malf-logo"

/datum/role/malf_drone/Greet(greeting, custom)
	. = ..()
	antag.current.playsound_local(null, 'sound/antag/malf.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	to_chat(antag.current, {"<span class='notice'><b>Вы - сбойный дрон.
У вас есть общая великая цель по преображению станции. Вы должны выполнить её во чтобы то ни стало.
Действуйте сообща с другими дронами. Ремонтируйте друг-друга в случае необходимости.
Вы можете нападать на людей, но только если они мешают вам выполнить вашу цель.
Не жертвуйте собой, если видите у человека оружие, лучше отступите и уйдите в другое место.
ПО ПЕРВОМУ ЗАКОНУ ВЫ НЕ МОЖЕТЕ ВРЕДИТЬ СТАНЦИИ И НАРУШАТЬ ЕЁ ГЕРМЕТИЧНОСТЬ. НИКАКИХ ДЫР В КОСМОС.
------------------</b></span>"})
