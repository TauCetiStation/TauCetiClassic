/mob/living/silicon/decoy
	name = "AI"
	icon = 'icons/mob/AI.dmi'//
	icon_state = "ai"
	anchored = TRUE // -- TLE
	canmove = 0
	hud_possible = null

/mob/living/silicon/decoy/atom_init()
	. = ..()
	silicon_list -= src //because fake ai break round end statistics

/mob/living/silicon/decoy/prepare_huds()
	return

/mob/living/silicon/decoy/diag_hud_set_status()
	return

/mob/living/silicon/decoy/diag_hud_set_health()
	return

/mob/living/silicon/decoy/nostromo
	name = "MU/TH/UR"
	icon_state = "ai"

/mob/living/silicon/decoy/nostromo/proc/announce(announce)
	switch(announce)
		if("smes")
			say("Внимание! Бортовой ИИ фиксирует резкие скачки напряжения на основной энергоячейке корабля, необходимо срочно выяснить и устранить причину неполадки!")
		if("alien_weed")
			say("Внимание! В ботанике обнаружено неопознанное растение, необходимо срочное вмешательство экипажа!")
		if("cockpit")
			say("Внимание! Прямо по курсу большое скопление заряженных частиц, необходимо срочно сменить курс корабля!")
		if("cargo")
			say("Внимание! В связи с высокой смертностью среди экипажа, на склад было возвращено электропитание.")
