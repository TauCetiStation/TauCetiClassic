/datum/combo_saved
	var/fullness = 0
	var/image/combo_icon
	var/list/combo_elements_icons = list()

	var/datum/progressbar/progbar
	var/list/combo_elements = list()
	var/mob/living/carbon/human/attacker
	var/mob/living/carbon/human/victim
	var/datum/combat_combo/next_combo

	var/last_hand_hit = 0 // Switching hands doubles fullness gained.

/datum/combo_saved/New(mob/living/victim, mob/living/attacker, combo_element, combo_value)
	src.attacker = attacker
	src.victim = victim
	progbar = new(attacker, 100, victim)

/datum/combo_saved/proc/set_combo_icon(image/new_icon)
	if(combo_icon && attacker.client)
		attacker.client.images -= combo_icon

	if(new_icon)
		combo_icon = new_icon
		combo_icon.loc = victim
		attacker.client.images += combo_icon
		var/matrix/M = matrix()
		M.Scale(0.1)
		combo_icon.transform = M
		var/matrix/N = matrix()
		animate(combo_icon, transform=N, time=2)

		INVOKE_ASYNC(src, .proc/shake_combo_icon)

/datum/combo_saved/proc/shake_combo_icon()
	sleep(2) // This is here for set_combo_icon to properly animate the icon.

	var/matrix/M = matrix()
	for(var/i in 1 to 3)
		if(!combo_icon)
			break
		M.Turn(pick(-30, 30))
		animate(combo_icon, transform=M, time=2)
		sleep(2)
		M = matrix()
		animate(combo_icon, transform=M, time=1)
		sleep(1)

/datum/combo_saved/proc/animate_attack(combo_element, combo_value)
	switch(combo_element)
		if(I_DISARM, I_HURT)
			var/matrix/saved_transform = attacker.transform
			var/matrix/M = matrix()
			if(attacker.hand)
				M.Turn(-combo_value)
			else
				M.Turn(combo_value)
			animate(attacker, transform=M, time=2)
			sleep(2)
			animate(attacker, transform=saved_transform, time=1)

/datum/combo_saved/proc/register_attack(combo_element, combo_value)
	var/target_zone
	if(attacker.zone_sel)
		target_zone = attacker.zone_sel.selecting
	else
		target_zone = ran_zone(BP_CHEST)

	if(combo_elements.len == 4)
		combo_elements.Cut(1, 2)
	if(attacker.hand != last_hand_hit)
		combo_value *= 2
		last_hand_hit = attacker.hand

	if(attacker.incapacitated())
		combo_value *= 0.5
	if(victim.incapacitated())
		combo_value *= 0.5

	combo_elements += combo_element

	if(attacker.client)
		for(var/combo_element_icon in combo_elements_icons)
			attacker.client.images -= combo_element_icon

		var/i = 1
		for(var/c_el in combo_elements)
			var/CC_icon_state = "combo_element_combo"
			switch(c_el)
				if(I_DISARM)
					CC_icon_state = "combo_element_disarm"
				if(I_GRAB)
					CC_icon_state = "combo_element_grab"
				if(I_HURT)
					CC_icon_state = "combo_element_hurt"
			var/image/C_EL_I = image(icon='icons/mob/unarmed_combat_combos.dmi', icon_state="[CC_icon_state]_[i]")
			C_EL_I.loc = victim
			C_EL_I.layer = ABOVE_HUD_LAYER
			C_EL_I.plane = ABOVE_HUD_PLANE
			C_EL_I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
			C_EL_I.pixel_y = -2
			C_EL_I.pixel_x = 3
			combo_elements_icons += C_EL_I
			attacker.client.images += C_EL_I
			i++

	fullness = min(100, fullness + combo_value)

	if(next_combo)
		var/datum/combat_combo/CC = next_combo
		if(CC.can_execute(src))
			next_combo = null
			INVOKE_ASYNC(CC, /datum/combat_combo.proc/animate_combo, victim, attacker)
			CC.pre_execute(victim, attacker)
			CC.execute(victim, attacker)
			fullness -= CC.fullness_lose_on_execute
			set_combo_icon(null)
			combo_elements = list()
			register_attack(CC.name, 0)
			return TRUE
		else
			set_combo_icon(null)
			next_combo = null
	else
		var/combo_hash = "[target_zone]|"
		for(var/CE in combo_elements)
			combo_hash += "[CE]#"

		var/datum/combat_combo/CC = combat_combos[combo_hash]
		if(CC.can_execute(src))
			next_combo = combat_combos[combo_hash]
			set_combo_icon(next_combo.get_combo_icon())
			next_combo.on_ready(victim, attacker)

	return FALSE

/datum/combo_saved/proc/update()
	if(combo_icon && (SSmob.times_fired % 3) == 0)
		INVOKE_ASYNC(src, .proc/shake_combo_icon)

	if(progbar)
		progbar.update(fullness)
	fullness--
	if(fullness < 0)
		attacker.combos_performed -= src
		victim.combos_saved -= src

		qdel(src)

/datum/combo_saved/Destroy()
	if(attacker.client)
		if(combo_icon)
			attacker.client.images -= combo_icon
		for(var/c_el_i in combo_elements_icons)
			attacker.client.images -= c_el_i
	combo_icon = null
	combo_elements_icons.Cut()
	QDEL_NULL(progbar)
	victim = null
	attacker = null
	next_combo = null
	return ..()
