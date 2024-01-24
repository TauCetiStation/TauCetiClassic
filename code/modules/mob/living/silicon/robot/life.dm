/mob/living/silicon/robot/Life()
	set invisibility = 0
	//set background = 1

	if (notransform)
		return

	src.blinded = null

	//Status updates, death etc.
	clamp_values()
	handle_fire()
	handle_regular_status_updates()

	if(client)
		handle_regular_hud_updates()
		update_items()
	if (src.stat != DEAD) //still using power
		add_ingame_age()
		use_power()
		process_killswitch()
		process_locks()
	update_canmove()

/mob/living/silicon/robot/proc/clamp_values()

	SetParalysis(min(AmountParalyzed(), 30))
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

	if ( cell && is_component_functioning("power cell") && src.cell.charge > 0 )
		if(src.module_state_1)
			cell_use_power(50) // 50W load for every enabled tool TODO: tool-specific loads
		if(src.module_state_2)
			cell_use_power(50)
		if(src.module_state_3)
			cell_use_power(50)

		if(lights_on)
			cell_use_power(30) 	// 30W light. Normal lights would use ~15W, but increased for balance reasons.

		src.has_power = 1
	else
		if (src.has_power)
			to_chat(src, "<span class='warning'>You are now running on emergency backup power.</span>")
		src.has_power = 0
		if(lights_on) // Light is on but there is no power!
			lights_on = 0
			set_light(0)
	diag_hud_set_borgcell()

/mob/living/silicon/robot/proc/handle_regular_status_updates()

	if(src.camera && !scrambledcodes)
		if(src.stat == DEAD || wires.is_index_cut(BORG_WIRE_CAMERA))
			src.camera.status = 0
		else
			src.camera.status = 1

	updatehealth()

	if(IsSleeping())
		Paralyse(3)

	if(crawling)
		Weaken(5)

	if(health < config.health_threshold_dead && src.stat != DEAD) //die only once
		death()

	if (src.stat != DEAD) //Alive.
		if (src.paralysis || src.stunned || src.weakened || !src.has_power) //Stunned etc.
			src.stat = UNCONSCIOUS
			blinded = paralysis
		else	//Not stunned.
			src.stat = CONSCIOUS

	else //Dead.
		src.blinded = 1
		src.stat = DEAD

	if (src.stuttering > 0)
		AdjustStuttering(-1)

	if (src.eye_blind)
		src.eye_blind--
		src.blinded = 1

	if (src.ear_deaf > 0) src.ear_deaf--
	if (src.ear_damage < 25)
		src.ear_damage -= 0.05
		src.ear_damage = max(src.ear_damage, 0)

	src.density = !( src.lying )

	if ((src.sdisabilities & BLIND))
		src.blinded = 1
	if ((src.sdisabilities & DEAF))
		src.ear_deaf = 1

	if (src.eye_blurry > 0)
		adjustBlurriness(-1)

	if (src.druggy > 0)
		src.druggy--
		src.druggy = max(0, src.druggy)

	AdjustConfused(-1)
	AdjustDrunkenness(-1)

	//update the state of modules and components here
	if (src.stat != CONSCIOUS)
		uneq_all()

	if(!is_component_functioning("radio"))
		radio.on = 0
	else
		radio.on = 1

	if(is_component_functioning("camera"))
		if(!src.eye_blind)
			src.blinded = 0
	else
		src.blinded = 1

	if(!is_component_functioning("actuator"))
		Paralyse(3)


	return 1

/mob/living/silicon/robot/update_sight()
	if(!..())
		return FALSE

	if(HAS_TRAIT(src, TRAIT_BLUESPACE_MOVING))
		return TRUE

	sight = initial(sight)
	lighting_alpha = initial(lighting_alpha)
	see_in_dark = 8
	var/sight_modifier = null
	if (sight_mode & BORGXRAY)
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		see_invisible = SEE_INVISIBLE_OBSERVER
	else if (sight_mode & BORGMESON)
		sight_modifier = "meson"
		sight |= SEE_TURFS
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	else if (sight_mode & BORGNIGHT)
		sight_modifier = "nvg"
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	else if (sight_mode & BORGTHERM)
		sight_modifier = "thermal"
		sight |= SEE_MOBS
	sight_modifier = sight_mode & BORGIGNORESIGHT ? null : sight_modifier
	set_EyesVision(sight_modifier)
	return TRUE

/mob/living/silicon/robot/handle_regular_hud_updates()
	if(!client)
		return

	regular_hud_updates()
	update_sight()

	if (src.cell)
		var/cellcharge = src.cell.charge/src.cell.maxcharge
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

/mob/living/silicon/robot/proc/update_items()
	if (src.client)
		src.client.screen -= src.contents
		for(var/obj/I in src.contents)
			if(I && !(istype(I,/obj/item/weapon/stock_parts/cell) || istype(I,/obj/item/device/radio)  || istype(I,/obj/machinery/camera) || isMMI(I)))
				src.client.screen += I
	if(src.module_state_1)
		src.module_state_1:screen_loc = ui_inv1
	if(src.module_state_2)
		src.module_state_2:screen_loc = ui_inv2
	if(src.module_state_3)
		src.module_state_3:screen_loc = ui_inv3
	updateicon()

/mob/living/silicon/robot/proc/process_killswitch()
	if(killswitch)
		killswitch_time --
		if(killswitch_time <= 0)
			if(src.client)
				to_chat(src, "<span class='danger'>Killswitch Activated</span>")
			killswitch = 0
			spawn(5)
				gib()

/mob/living/silicon/robot/proc/process_locks()
	if(weapon_lock)
		uneq_all()
		weaponlock_time --
		if(weaponlock_time <= 0)
			if(src.client)
				to_chat(src, "<span class='danger'>Weapon Lock Timed Out!</span>")
			weapon_lock = 0
			weaponlock_time = 120

/mob/living/silicon/robot/update_canmove()
	anchored = HAS_TRAIT(src, TRAIT_ANCHORED)
	canmove = !(buckled || anchored || weakened || HAS_TRAIT(src, TRAIT_IMMOBILIZED))

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
		underlays += image("icon"='icons/mob/OnFire.dmi', "icon_state"="generic_underlay")
		var/image/over = image("icon"='icons/mob/OnFire.dmi', "icon_state"="generic_overlay")
		over.plane = LIGHTING_LAMPS_PLANE
		add_overlay(over)
	else
		underlays -= image("icon"='icons/mob/OnFire.dmi', "icon_state"="generic_underlay")
		cut_overlay(image("icon"='icons/mob/OnFire.dmi', "icon_state"="generic_overlay"))
