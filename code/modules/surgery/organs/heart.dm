/obj/item/organ/internal/heart
	name = "heart"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "heart-on"
	item_state_world = "heart-on_world"
	cases = list("сердце", "сердца", "сердцу", "сердце", "сердцем", "сердце")
	organ_tag = O_HEART
	parent_bodypart = BP_CHEST
	max_damage = 45
	min_bruised_damage = 15
	min_broken_damage = 35
	cybernetic_version = /obj/item/organ/internal/heart/cybernetic
	var/heart_beat
	var/pulse = PULSE_NORM
	var/base_icon_state = "heart"
	var/heart_status = HEART_NORMAL
	var/fibrillation_timer_id = null
	var/failing_interval = 1 MINUTE
	var/beating = 0
	var/bloodlose_multiplier = 1

	var/list/external_pump

	var/datum/modval/heart_metabolism_mod

	compability = list(HUMAN, PLUVIAN, UNATHI, TAJARAN, SKRELL)

/obj/item/organ/internal/heart/Destroy()
	owner?.mob_metabolism_mod.RemoveMods(src) // where is remove_organ()
	QDEL_NULL(heart_metabolism_mod)
	return ..()

/obj/item/organ/internal/heart/update_icon()
	if(beating)
		item_state_world = "[base_icon_state]-on_world"
		icon_state = "[base_icon_state]-on"
	else
		item_state_world = "[base_icon_state]-off_world"
		icon_state = "[base_icon_state]-off"

/obj/item/organ/internal/heart/process()
	if(owner)
		handle_pulse()
		pulse = handle_pulse()
		if(pulse)
			handle_heart_beat()
			if(pulse == PULSE_2FAST && prob(1))
				take_damage(0.5)
			if(pulse == PULSE_THREADY && prob(5))
				take_damage(0.5)
		handle_blood()
	..()

/obj/item/organ/internal/heart/proc/handle_pulse()

	if(is_robotic(src))
		return PULSE_NONE

	if(owner.life_tick % 5)
		return pulse	//update pulse every 5 life ticks (~1 tick/sec, depending on server load)

	if(owner.species && HAS_TRAIT(owner, TRAIT_NO_BLOOD))
		return PULSE_NONE //No blood, no pulse.

	if(HAS_TRAIT(owner, TRAIT_EXTERNAL_HEART))
		return PULSE_NORM

	if(owner.stat == DEAD)
		return PULSE_NONE	//that's it, you're dead, nothing can influence your pulse

	if(owner.life_tick % 10)
		switch(heart_status)
			if(HEART_FAILURE)
				to_chat(src, "<span class='userdanger'>Your feel a prick in your heart!</span>")
				owner.apply_effect(5,AGONY,0)
				return PULSE_NONE
			if(HEART_FIBR)
				to_chat(src, "<span class='danger'>Your heart hurts a little.</span>")
				owner.playsound_local(null, 'sound/machines/cardio/pulse_fibrillation.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
				owner.apply_effect(1,AGONY,0)
				return PULSE_SLOW

	var/temp = PULSE_NORM

	if(owner.blood_amount() <= BLOOD_VOLUME_BAD)	//how much blood do we have
		temp = PULSE_THREADY	//not enough :(

	if(owner.status_flags & FAKEDEATH)
		temp = PULSE_NONE		//pretend that we're dead. unlike actual death, can be inflienced by meds

	//handles different chems' influence on pulse
	for(var/datum/reagent/R in owner.reagents.reagent_list)
		if(R.id in bradycardics)
			if(temp <= PULSE_THREADY && temp >= PULSE_NORM)
				temp--
		if(R.id in tachycardics)
			if(temp <= PULSE_FAST && temp >= PULSE_NONE)
				temp++
		if(R.id in heartstopper) //To avoid using fakedeath
			temp = PULSE_NONE
		if(R.id in cheartstopper) //Conditional heart-stoppage
			if(R.volume >= R.overdose)
				temp = PULSE_NONE

	return temp

// Takes care blood loss and regeneration:
/obj/item/organ/internal/heart/var/tmp/next_blood_squirt = 0 // until this moved to heart or not...

/obj/item/organ/internal/heart/proc/handle_blood()

	if(!owner)
		return

	if(HAS_TRAIT(owner, TRAIT_NO_BLOOD) || owner.bodytemperature < 170 || owner.stat == DEAD || !owner)
		return

	if(owner.reagents.has_reagent("metatrombine"))
		return

	// Bleeding out:
	var/blood_max = 0
	var/list/do_spray = list()
	for(var/obj/item/organ/external/BP in owner.bodyparts)
		if(BP.is_robotic_part())
			continue

		var/open_wound
		if(BP.status & ORGAN_BLEEDING)
			if(BP.open)
				blood_max += 2 // Yer stomach is cut open
			if(HAS_TRAIT(src, TRAIT_HEMOPHILIAC))
				blood_max += 4

			for(var/datum/wound/W in BP.wounds)
				if(!open_wound && (W.damage_type == CUT || W.damage_type == PIERCE) && W.damage && !W.is_treated())
					open_wound = TRUE

				if(W.bleeding())
					if(BP.applied_pressure)
						if(ishuman(BP.applied_pressure))
							var/mob/living/carbon/human/H = BP.applied_pressure
							H.bloody_hands(src, 0)
						// somehow you can apply pressure to every wound on the organ at the same time
						// you're basically forced to do nothing at all, so let's make it pretty effective
						var/min_eff_damage = max(0, W.damage - 10) / 6 // still want a little bit to drip out, for effect
						blood_max += max(min_eff_damage, W.damage - 30) / 40
					else
						blood_max += W.damage / 40

		if(BP.status & ORGAN_ARTERY_CUT)
			var/bleed_amount = owner.blood_amount() / (BP.applied_pressure ? 500 : 250) * BP.arterial_bleed_severity
			if(bleed_amount)
				if(open_wound)
					blood_max += bleed_amount
					do_spray += "the [BP.artery_name] in \the [src]'s [BP.name]"
				else
					owner.blood_remove(bleed_amount)
				playsound(src, 'sound/effects/ArterialBleed.ogg', VOL_EFFECTS_MASTER)

	if(blood_max == 0) // so... there is no blood loss, lets stop right here.
		return

	switch(pulse)
		if(PULSE_NONE)
			blood_max *= 0.2 // simulates passive blood loss.
		if(PULSE_SLOW)
			blood_max *= 0.8
		if(PULSE_FAST)
			blood_max *= 1.25
		if(PULSE_2FAST)
			blood_max *= 1.5
		if(PULSE_THREADY)
			blood_max *= 1.8

	if(owner.reagents.has_reagent("inaprovaline"))
		blood_max *= 0.8

	blood_max *= bloodlose_multiplier

	if(!isturf(owner.loc)) // No floor to drip on
		owner.blood_remove(blood_max)
		return

	if(world.time >= next_blood_squirt && do_spray.len) // It becomes very spammy otherwise. Arterial bleeding will still happen outside of this block, just not the squirt effect.
		if(prob(50)) // added 50 prob for message and halved delay between squit effects (difference between us and Bay12), lets see how this will be on live server.
			visible_message("<span class='danger'>Blood squirts from [pick(do_spray)]!</span>")
		next_blood_squirt = world.time + 50
		var/turf/sprayloc = get_turf(owner)
		var/third = CEIL(blood_max / 3)
		owner.drip(third, sprayloc)
		blood_max -= third
		if(blood_max > 0)
			owner.blood_squirt(blood_max, sprayloc)
	else
		owner.drip(blood_max) // No fancy shooting of blood, just bleeding

/obj/item/organ/internal/heart/insert_organ(mob/living/carbon/M)
	..()
	// attach heart modval to our owner modval as multiplicative
	// we should not add any heart-related mods directly to the owner, mod our heart modval
	heart_metabolism_mod = new(base_value = 1, clamp_min = 0, clamp_max = 1)
	owner.mob_metabolism_mod.ModMultiplicative(heart_metabolism_mod, src)


/obj/item/organ/internal/heart/proc/heart_stop()
	if(!owner.reagents.has_reagent("inaprovaline") || owner.stat == DEAD)
		heart_status = HEART_FAILURE
		deltimer(fibrillation_timer_id)
		fibrillation_timer_id = null
		// modval it multiplicative for mob metabolism,
		// so making it 0 disables mob metabolism
		// can be balanced by life assist machinery
		heart_metabolism_mod.ModAdditive(-1, "Bad Heart")
	else
		take_damage(1, 0)
		fibrillation_timer_id = addtimer(CALLBACK(src, PROC_REF(heart_stop)), 10 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)

/obj/item/organ/internal/heart/remove(mob/living/carbon/M)
	..()
	heart_status = HEART_FAILURE
	VARSET_IN(src, beating, 0, 100 SECONDS)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 2 MINUTES)


/obj/item/organ/internal/heart/proc/heart_fibrillate()
	heart_status = HEART_FIBR
	if(HAS_TRAIT(owner, TRAIT_FAT))
		failing_interval = 30 SECONDS
	fibrillation_timer_id = addtimer(CALLBACK(src, PROC_REF(heart_stop)), failing_interval, TIMER_UNIQUE|TIMER_STOPPABLE)
	heart_metabolism_mod.ModAdditive(-0.5, "Bad Heart") // slows down metabolism, can be balanced by life assist machinery

/obj/item/organ/internal/heart/proc/heart_normalize()
	heart_status = HEART_NORMAL
	deltimer(fibrillation_timer_id)
	fibrillation_timer_id = null
	heart_metabolism_mod.RemoveMods("Bad Heart")

/obj/item/organ/internal/heart/proc/handle_heart_beat()

	if(pulse == PULSE_NONE)
		return

	if(pulse == PULSE_2FAST)

		var/temp = (5 - pulse)/2

		if(heart_beat >= temp)
			heart_beat = 0
			owner.playsound_local(null, 'sound/effects/singlebeat.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		else if(temp != 0)
			heart_beat++

/obj/item/organ/internal/heart/cybernetic
	name = "cybernetic heart"
	desc = "An electronic device designed to mimic the functions of an organic human heart. It has a built-in coagulator that slows bleeding."
	icon_state = "heart-prosthetic"
	item_state_world = "heart-prosthetic_world"
	base_icon_state = "heart-prosthetic"
	status = ORGAN_ROBOT
	durability = 0.8
	compability = list(HUMAN, PLUVIAN, UNATHI, TAJARAN, SKRELL)
	can_relocate = TRUE
	bloodlose_multiplier = 0.75

/obj/item/organ/internal/heart/cybernetic/voxc
	parent_bodypart = BP_GROIN
	compability = list(VOX)

/obj/item/organ/internal/heart/ipc
	name = "cooling pump"
	cases = list("помпа системы охлаждения", "помпы системы охлаждения", "помпе системы охлаждения", "помпу системы охлаждения", "помпой системы охлаждения", "помпой системы охлаждения")

	var/pumping_rate = 5
	var/bruised_loss = 3
	requires_robotic_bodypart = TRUE
	status = ORGAN_ROBOT
	durability = 0.8
	icon = 'icons/obj/device.dmi'
	icon_state = "miniaturesuitcooler0"


/obj/item/organ/internal/heart/ipc/update_icon()
	if(beating)
		icon_state = "miniaturesuitcooler0"
		item_state_world = "miniaturesuitcooler0"
	else
		icon_state = "miniaturesuitcooler0"
		item_state_world = "miniaturesuitcooler0"

/obj/item/organ/internal/heart/ipc/process()
	if(!owner)
		return
	if(owner.nutrition < 1)
		return
	if(is_broken())
		return

	var/obj/item/organ/internal/lungs/ipc/lungs = owner.organs_by_name[O_LUNGS]
	if(!istype(lungs))
		return

	var/pumping_volume = pumping_rate
	if(is_bruised())
		pumping_volume -= bruised_loss

	if(pumping_volume > 0)
		lungs.add_refrigerant(pumping_volume)

/obj/item/organ/internal/heart/vox
	name = "vox heart"
	icon = 'icons/obj/special_organs/vox.dmi'
	parent_bodypart = BP_GROIN
	compability = list(VOX)
	sterile = TRUE
	cybernetic_version = /obj/item/organ/internal/heart/cybernetic/voxc

/obj/item/organ/internal/heart/tajaran
	name = "tajaran heart"
	icon = 'icons/obj/special_organs/tajaran.dmi'

/obj/item/organ/internal/heart/unathi
	name = "unathi heart"
	icon = 'icons/obj/special_organs/unathi.dmi'
	desc = "A large looking heart."

/obj/item/organ/internal/heart/skrell
	name = "skrell heart"
	icon = 'icons/obj/special_organs/skrell.dmi'
	desc = "A stream lined heart."

/obj/item/organ/internal/heart/diona
	name = "circulatory siphonostele"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	item_state_world = "nymph"
	compability = list(DIONA)
	tough = TRUE
