/mob/proc/flash_pain()
	flick("pain",pain)

/mob/var/last_pain_message = ""
/mob/var/next_pain_time = 0

// message is the custom message to be displayed
// flash_strength is 0 for weak pain flash, 1 for strong pain flash
/mob/living/carbon/proc/custom_pain(message, power, force, obj/item/bodypart/BP)
	if(!message || stat || !can_feel_pain())//|| chem_effects[CE_PAINKILLER] > power)
		return 0

	if(reagents.has_reagent("paracetamol"))
		return 0
	if(reagents.has_reagent("tramadol"))
		return 0
	if(reagents.has_reagent("oxycodone"))
		return 0
	if(analgesic)
		return 0

	// Excessive halloss is horrible, just give them enough to make it visible.
	if(power)
		if(BP)
			BP.add_pain(ceil(power/2))
		else
			adjustHalLoss(ceil(power/2))

	// Anti message spam checks
	if(force || (message != last_pain_message) || (world.time >= next_pain_time))
		last_pain_message = message
		if(power >= 50)
			to_chat(src, "<span class='danger'><font size=3>[message]</font></span>")
		else
			to_chat(src, "<span class='danger'>[message]</span>")
	next_pain_time = world.time + (100-power)

/mob/living/carbon/proc/handle_pain()
	if(stat)
		return
	if(!can_feel_pain())
		return
	if(world.time < next_pain_time)
		return

	if(reagents.has_reagent("tramadol"))
		return
	if(reagents.has_reagent("oxycodone"))
		return
	if(analgesic)
		return

	var/maxdam = 0
	var/obj/item/bodypart/BP = null
	for(var/obj/item/bodypart/E in bodyparts)
		// amputated limbs don't cause pain
		if(!E.can_feel_pain())
			continue
		var/dam = E.get_damage()
		// make the choice of the organ depend on damage,
		// but also sometimes use one of the less damaged ones
		if(dam > maxdam && (maxdam == 0 || prob(70)) )
			BP = E
			maxdam = dam
	if(BP)
		if(maxdam > 10 && paralysis)
			paralysis = max(0, paralysis - round(maxdam/10))
		if(maxdam > 50 && prob(maxdam / 5))
			drop_item()
		var/burning = BP.burn_dam > BP.brute_dam
		var/msg
		switch(maxdam)
			if(1 to 10)
				msg =  "Your [BP.name] [burning ? "burns" : "hurts"]."
			if(11 to 90)
				flash_weak_pain()
				msg = "<font size=2>Your [BP.name] [burning ? "burns" : "hurts"] badly!</font>"
			if(91 to 10000)
				flash_pain()
				msg = "<font size=3>OH GOD! Your [BP.name] is [burning ? "on fire" : "hurting terribly"]!</font>"
		custom_pain(msg, 0, prob(10), BP = BP)

	// Damage to internal organs hurts a lot.
	for(var/obj/item/organ/IO in organs)
		if((IO.status & ORGAN_DEAD) || IO.robotic >= ORGAN_ROBOT) continue
		if(IO.damage > 2) if(prob(2))
			var/obj/item/bodypart/parent = get_bodypart(IO.parent_bodypart)
			src.custom_pain("You feel a sharp pain in your [parent.name]", 50, BP = parent)

	if(prob(2))
		switch(getToxLoss())
			if(1 to 10)
				custom_pain("Your body stings slightly.", getToxLoss())
			if(11 to 60)
				custom_pain("Your whole body hurts badly.", getToxLoss())
			if(61 to INFINITY)
				custom_pain("Your body aches all over, it's driving you mad.", getToxLoss())
