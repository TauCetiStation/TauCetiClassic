/mob/living/carbon/xenomorph
	name = "alien"
	voice_name = "alien"
	icon = 'icons/mob/xenomorph.dmi'
	gender = NEUTER
	dna = null
	faction = "alien"

	alien_talk_understand = 1
	speak_emote = list("hisses")
	typing_indicator_type = "alien"

	see_in_dark = 8
	sight = SEE_MOBS

	var/nightvision = 1
	var/storedPlasma = 250
	var/max_plasma = 500
	var/last_sound_emote = 0 // prevents sounds spam

	var/obj/item/weapon/card/id/wear_id = null // Fix for station bounced radios -- Skie
	var/move_delay_add = 0 // movement delay to add

	status_flags = CANPARALYSE|CANPUSH
	var/heal_rate = 1
	var/plasma_rate = 5
	var/acid_type = /obj/effect/alien/acid

	var/heat_protection = 0.5
	var/leaping = 0
	ventcrawler = 2

	attack_push_vis_effect = ATTACK_EFFECT_CLAW
	attack_disarm_vis_effect = ATTACK_EFFECT_CLAW

	var/list/alien_spells = list()

	show_examine_log = FALSE

/mob/living/carbon/xenomorph/atom_init()
	. = ..()
	add_language(LANGUAGE_XENOMORPH)
	var/datum/atom_hud/hud = global.huds[DATA_HUD_EMBRYO]
	hud.add_hud_to(src)	//add xenomorph to the hudusers list to see who is infected
	for(var/spell in alien_spells)
		AddSpell(new spell(src))

/mob/living/carbon/xenomorph/Destroy()
	var/datum/atom_hud/hud = global.huds[DATA_HUD_EMBRYO]
	hud.remove_hud_from(src)
	return ..()

/mob/living/carbon/xenomorph/movement_delay()
	return (move_delay_add + config.alien_delay + speed)

/mob/living/carbon/xenomorph/adjustToxLoss(amount)
	storedPlasma = min(max(storedPlasma + amount,0),max_plasma) //upper limit of max_plasma, lower limit of 0
	updatePlasmaDisplay()
	return

/mob/living/carbon/xenomorph/proc/getPlasma()
	return storedPlasma

/mob/living/carbon/xenomorph/eyecheck()
	return 2

/mob/living/carbon/xenomorph/getToxLoss()
	return 0

/mob/living/carbon/xenomorph/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
	else
		//oxyloss is only used for suicide
		//toxloss isn't used for aliens, its actually used as alien powers!!
		health = maxHealth - getOxyLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()
		med_hud_set_health()
		med_hud_set_status()

/mob/living/carbon/xenomorph/get_heat_protection()
	return heat_protection

/mob/living/carbon/xenomorph/handle_environment(datum/gas_mixture/environment)

	//If there are alien weeds on the ground then heal if needed or give some plasma
	if(locate(/obj/structure/alien/weeds) in loc)
		if(health >= maxHealth)
			adjustToxLoss(plasma_rate)
		else if(crawling)
			adjustBruteLoss(-heal_rate*2)
			adjustFireLoss(-heal_rate*2)
			adjustOxyLoss(-heal_rate*2)
			adjustCloneLoss(-heal_rate*2)
			adjustToxLoss(plasma_rate)
		else
			adjustBruteLoss(-heal_rate)
			adjustFireLoss(-heal_rate)
			adjustOxyLoss(-heal_rate)
			adjustCloneLoss(-heal_rate)
			adjustToxLoss(plasma_rate/2)

	if(!environment)
		return

	if(istype(loc, /obj/machinery/atmospherics/pipe) || istype(loc, /obj/item/alien_embryo))
		return

	var/loc_temp = get_temperature(environment)
	var/pressure = environment.return_pressure()

	// Aliens are now weak to fire.

	//After then, it reacts to the surrounding atmosphere based on your thermal protection
	if(!on_fire) // If you're on fire, ignore local air temperature
		var/affecting_temp = (loc_temp - bodytemperature) * environment.return_relative_density()
		adjust_bodytemperature(affecting_temp, use_insulation = TRUE, use_steps = TRUE)

	// +/- 50 degrees from 310.15K is the 'safe' zone, where no damage is dealt.
	if(bodytemperature > 360)
		//Body temperature is too hot.
		throw_alert("alien_fire", /atom/movable/screen/alert/alien_fire)
		switch(bodytemperature)
			if(400 to 600)
				apply_damage(HEAT_DAMAGE_LEVEL_1, BURN)
			if(600 to 800)
				apply_damage(HEAT_DAMAGE_LEVEL_2, BURN)
			if(800 to INFINITY)
				apply_damage(HEAT_DAMAGE_LEVEL_3, BURN)
	else
		clear_alert("alien_fire")

//xenomorphs will take damage from high and low pressure
	var/pressure_damage = heal_rate		//aliens won't take damage from pressure if stay on weeds
	if(pressure >= WARNING_HIGH_PRESSURE)
		apply_damage(pressure_damage, BRUTE)
		throw_alert("pressure", /atom/movable/screen/alert/highpressure, 2)
	else if(pressure >= WARNING_LOW_PRESSURE)
		clear_alert("pressure")
	else
		throw_alert("pressure", /atom/movable/screen/alert/lowpressure, 2)
		apply_damage(pressure_damage, BRUTE)

/mob/living/carbon/xenomorph/proc/handle_mutations_and_radiation()

	// Aliens love radiation nom nom nom
	if (radiation)
		if (radiation > 100)
			radiation = 100

		if (radiation < 0)
			radiation = 0

		switch(radiation)
			if(1 to 49)
				radiation--
				if(prob(25))
					adjustToxLoss(1)

			if(50 to 74)
				radiation -= 2
				adjustToxLoss(1)
				if(prob(5))
					radiation -= 5

			if(75 to 100)
				radiation -= 3
				adjustToxLoss(3)

/mob/living/carbon/xenomorph/Stat()
	..()
	if(statpanel("Status"))
		if(!isxenoqueen(src))
			var/mob/living/carbon/xenomorph/queen = null
			for(var/mob/living/carbon/xenomorph/humanoid/queen/Q as anything in alien_list[ALIEN_QUEEN])
				if(Q.stat == DEAD || !Q.key)
					continue
				queen = Q
			if(!queen)
				stat("Королева: Нет")
			else
				stat("Здоровье Королевы: [queen.health]/[queen.maxHealth]")
				stat("Локация Королевы: [queen.loc.loc.name]")
				stat("Королева в сознании: [queen.stat ? "Нет" : "Да"]")
				stat(null) //for readability

		stat("Статус Улья:")
		for(var/key in alien_list)
			var/count = 0
			if(key == ALIEN_QUEEN)
				continue
			for(var/mob/living/carbon/xenomorph/A as anything in alien_list[key])
				if(A.stat == DEAD || !A.key)
					continue
				count++
			if(count)
				stat("[key]: [count]")

/mob/living/carbon/xenomorph/Stun(amount, ignore_canstun = 0)
	if(status_flags & CANSTUN || ignore_canstun)
		..()
	else
		// add some movement delay
		move_delay_add = min(move_delay_add + round(amount / 2), 10) // a maximum delay of 10

/mob/living/carbon/xenomorph/getDNA()
	return null

/mob/living/carbon/xenomorph/setDNA()
	return

/*----------------------------------------
Hit Procs
-----------------------------------------*/
/mob/living/carbon/xenomorph/ex_act(severity)
	if(!blinded)
		flash_eyes()

	var/shielded = 0

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if(EXPLODE_DEVASTATE)
			b_loss += 500
			gib()
			return

		if(EXPLODE_HEAVY)
			if (!shielded)
				b_loss += 60

			f_loss += 60

			ear_damage += 30
			ear_deaf += 120

		if(EXPLODE_LIGHT)
			b_loss += 30
			if (prob(50) && !shielded)
				Paralyse(1)
			ear_damage += 15
			ear_deaf += 60

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)

	updatehealth()

/mob/living/carbon/xenomorph/blob_act()
	if (stat == DEAD)
		return
	var/shielded = 0
	var/damage = null
	if (stat != DEAD)
		damage = rand(30,40)

	if(shielded)
		damage /= 4


	to_chat(src, "<span class='warning'>The blob attacks!</span>")

	adjustFireLoss(damage)

	updatehealth()
	return

/mob/living/carbon/xenomorph/airlock_crush_act()
	..()
	emote("roar")

/mob/living/carbon/xenomorph/emp_act(severity)
	return

/mob/living/carbon/xenomorph/attack_ui(slot_id)
	return

/mob/living/carbon/xenomorph/restrained()
	return 0

/mob/living/carbon/xenomorph/show_inv(mob/user)
	return

/mob/living/carbon/xenomorph/getTrail()
	return "xltrails"

/mob/living/carbon/xenomorph/update_canmove()
	..()

	if(lying)
		canmove = FALSE
	if(density)
		density = initial(density)

/mob/living/carbon/xenomorph/swap_hand()
	var/obj/item/item_in_hand = get_active_hand()
	if(SEND_SIGNAL(src, COMSIG_MOB_SWAP_HANDS, item_in_hand) & COMPONENT_BLOCK_SWAP)
		to_chat(src, "<span class='warning'>Your other hand is too busy holding [item_in_hand].</span>")
		return
	src.hand = !( src.hand )
	if(hud_used && l_hand_hud_object && r_hand_hud_object)
		l_hand_hud_object.update_icon(src)
		r_hand_hud_object.update_icon(src)

/mob/living/carbon/xenomorph/get_pixel_y_offset(lying = 0)
	return initial(pixel_y)

/mob/living/carbon/xenomorph/proc/toggle_nvg(message = 1)
	if(stat != CONSCIOUS)
		return

	src.nightvision = !src.nightvision

	if(!src.nightvision)
		src.nightvisionicon.icon_state = "nightvision0"
	else if(src.nightvision == 1)
		src.nightvisionicon.icon_state = "nightvision1"

	update_sight()
	if(message)
		to_chat(src, "<span class='noticealien'>You adapt your eyes for [nightvision ? "dark":"light"] !</span>")
	else
		return
