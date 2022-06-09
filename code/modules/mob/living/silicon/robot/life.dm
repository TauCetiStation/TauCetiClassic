/mob/living/silicon/robot/Life()
	set invisibility = 0
	//set background = 1

	if (notransform)
		return

	blinded = null

	//Status updates, death etc.
	clamp_values()
	handle_fire()
	handle_regular_status_updates()
	handle_actions()

	if(client)
		handle_regular_hud_updates()
		update_items()
	if(stat != DEAD) //still using power
		add_ingame_age()
		use_power()
		process_killswitch()
		process_locks()
	update_canmove()

/mob/living/silicon/robot/proc/clamp_values()

//	SetStunned(min(stunned, 30))
	SetParalysis(min(paralysis, 30))
//	SetWeakened(min(weakened, 20))
	SetSleeping(0)
	adjustBruteLoss(0)
	adjustToxLoss(0)
	adjustOxyLoss(0)
	adjustFireLoss(0)

/mob/living/silicon/robot/proc/use_power()
	// Debug only
	used_power_this_tick = 0
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		C.update_power_state()

	if (cell && is_component_functioning("power cell") && cell.charge > 0)
		if(module_state_1)
			cell_use_power(50) // 50W load for every enabled tool TODO: tool-specific loads
		if(module_state_2)
			cell_use_power(50)
		if(module_state_3)
			cell_use_power(50)

		if(lights_on)
			cell_use_power(30) 	// 30W light. Normal lights would use ~15W, but increased for balance reasons.

		has_power = TRUE
	else
		if(has_power)
			to_chat(src, "<span class='warning'>You are now running on emergency backup power.</span>")
		has_power = FALSE
		if(lights_on) // Light is on but there is no power!
			lights_on = FALSE
			set_light(0)
	diag_hud_set_borgcell()

/mob/living/silicon/robot/proc/handle_regular_status_updates()

	if(camera && !scrambledcodes)
		if(stat == DEAD || wires.is_index_cut(BORG_WIRE_CAMERA))
			camera.status = FALSE
		else
			camera.status = TRUE

	updatehealth()

	if(IsSleeping())
		Paralyse(3)

	if(crawling)
		Weaken(5)

	if(health < config.health_threshold_dead && stat != DEAD) //die only once
		death()

	if(stat != DEAD) //Alive.
		if (paralysis || stunned || weakened || has_power) //Stunned etc.
			stat = UNCONSCIOUS
			if(stunned > 0)
				AdjustStunned(-1)
			if(weakened > 0)
				AdjustWeakened(-1)
			if(paralysis > 0)
				AdjustParalysis(-1)
				blinded = TRUE
			else
				blinded = FALSE

		else	//Not stunned.
			stat = CONSCIOUS

	else //Dead.
		blinded = TRUE
		stat = DEAD

	if(stuttering > 0)
		AdjustStuttering(-1)

	if(eye_blind)
		eye_blind--
		blinded = TRUE

	if(ear_deaf > 0)
		ear_deaf--
	if(ear_damage < 25)
		ear_damage -= 0.05
		ear_damage = max(ear_damage, 0)

	density = !lying

	if((sdisabilities & BLIND))
		blinded = TRUE
	if((sdisabilities & DEAF))
		ear_deaf = TRUE

	if(eye_blurry > 0)
		adjustBlurriness(-1)

	if(druggy > 0)
		druggy--
		druggy = max(0, druggy)

	AdjustConfused(-1)
	AdjustDrunkenness(-1)

	//update the state of modules and components here
	if(stat != CONSCIOUS)
		uneq_all()

	if(!is_component_functioning("radio"))
		radio.on = FALSE
	else
		radio.on = TRUE

	if(is_component_functioning("camera"))
		if(!eye_blind)
			blinded = FALSE
	else
		blinded = TRUE

	if(!is_component_functioning("actuator"))
		Paralyse(3)


	return TRUE

/mob/living/silicon/robot/update_sight()
	if(!..())
		return FALSE

	sight = initial(sight)
	lighting_alpha = initial(lighting_alpha)
	see_in_dark = 8
	var/sight_modifier = null
	if(sight_mode & BORGXRAY)
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		see_invisible = SEE_INVISIBLE_OBSERVER
	else if(sight_mode & BORGMESON)
		sight_modifier = "meson"
		sight |= SEE_TURFS
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	else if(sight_mode & BORGNIGHT)
		sight_modifier = "nvg"
	else if(sight_mode & BORGTHERM)
		sight_modifier = "thermal"
		sight |= SEE_MOBS
	sight_modifier = sight_mode & BORGIGNORESIGHT ? null : sight_modifier
	set_EyesVision(sight_modifier)
	return TRUE

/mob/living/silicon/robot/handle_regular_hud_updates()
	if(!client)
		return FALSE

	regular_hud_updates()
	update_sight()

	if(healths)
		if(stat != DEAD)
			if(health >= maxHealth)
				healths.icon_state = "health0"
			else if(health >= maxHealth * 0.75)
				healths.icon_state = "health1"
			else if(health >= maxHealth * 0.5)
				healths.icon_state = "health2"
			else if(health >= maxHealth * 0.25)
				healths.icon_state = "health3"
			else if(health >= 0)
				healths.icon_state = "health4"
			else if(health >= config.health_threshold_dead)
				healths.icon_state = "health5"
			else
				healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

	if(cell)
		var/cellcharge = cell.charge/cell.maxcharge
		switch(cellcharge)
			if(0.75 to INFINITY)
				clear_alert("charge")
			if(0.5 to 0.75)
				throw_alert("charge", /atom/movable/screen/alert/lowcell, 60)
			if(0.25 to 0.5)
				throw_alert("charge", /atom/movable/screen/alert/lowcell, 40)
			if(0.01 to 0.25)
				throw_alert("charge", /atom/movable/screen/alert/lowcell, 20)
			else
				throw_alert("charge", /atom/movable/screen/alert/emptycell)
	else
		throw_alert("charge", /atom/movable/screen/alert/nocell)

	..()

	return TRUE

/mob/living/silicon/robot/proc/update_items()
	if(client)
		client.screen -= contents
		for(var/obj/I in contents)
			if(I && !(istype(I,/obj/item/weapon/stock_parts/cell) || istype(I,/obj/item/device/radio)  || istype(I,/obj/machinery/camera) || isMMI(I)))
				client.screen += I
	if(module_state_1)
		module_state_1:screen_loc = ui_inv1
	if(module_state_2)
		module_state_2:screen_loc = ui_inv2
	if(module_state_3)
		module_state_3:screen_loc = ui_inv3
	updateicon()

/mob/living/silicon/robot/proc/process_killswitch()
	if(killswitch)
		killswitch_time --
		if(killswitch_time <= 0)
			if(client)
				to_chat(src, "<span class='danger'>Killswitch Activated</span>")
			killswitch = FALSE
			spawn(5)
				gib()

/mob/living/silicon/robot/proc/process_locks()
	if(weapon_lock)
		uneq_all()
		weaponlock_time --
		if(weaponlock_time <= 0)
			if(client)
				to_chat(src, "<span class='danger'>Weapon Lock Timed Out!</span>")
			weapon_lock = FALSE
			weaponlock_time = 120

/mob/living/silicon/robot/update_canmove()
	if(paralysis || stunned || weakened || buckled || lockcharge || pinned.len)
		canmove = FALSE
	else
		canmove = TRUE
	return canmove

//Robots on fire
/mob/living/silicon/robot/handle_fire()
	if(..())
		return
	if(fire_stacks > 0)
		adjustFireLoss(4)
		fire_stacks--
		fire_stacks = max(0, fire_stacks)
	else
		ExtinguishMob()
		return TRUE

/mob/living/silicon/robot/update_fire()
	if(on_fire)
		add_overlay(image("icon"='icons/mob/OnFire.dmi', "icon_state"="Generic_mob_burning"))
	else
		cut_overlay(image("icon"='icons/mob/OnFire.dmi', "icon_state"="Generic_mob_burning"))
