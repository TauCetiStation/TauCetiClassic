
//override procs in children as necessary
/datum/artifact_effect
	var/effect_name = "unknown" // purely used for admin checks ingame
	var/effect = ARTIFACT_EFFECT_TOUCH
	var/effectrange = 4
	var/trigger = TRIGGER_TOUCH
	var/atom/holder
	var/activated = 0
	var/chargelevel = 0
	var/chargelevelmax = 10
	var/artifact_id = ""
	var/effect_type = ARTIFACT_EFFECT_UNKNOWN

/datum/artifact_effect/New(var/atom/location)
	..()
	holder = location
	effect = rand(0,ARTIFACT_MAX_EFFECT)
	trigger = rand(0,MAX_TRIGGER)

	// this will be replaced by the excavation code later, but it's here just in case
	artifact_id = "[pick("kappa", "sigma", "antaeres", "beta", "omicron", "iota", "epsilon", "omega", "gamma", "delta", "tau", "alpha")]-[rand(100, 999)]"

	// random charge time and distance
	switch(pick(50;1, 70;2, 30;3))
		if(1)
			// short range, short charge time
			chargelevelmax = rand(3, 20)
			effectrange = rand(2, 4)
		if(2)
			// medium range, medium charge time
			chargelevelmax = rand(15, 30)
			effectrange = rand(5, 7)
		if(3)
			// large range, long charge time
			chargelevelmax = rand(20, 50)
			effectrange = rand(7, 10)

/datum/artifact_effect/proc/ToggleActivate(reveal_toggle = 1)
	//so that other stuff happens first
	spawn(0)
		if(activated)
			activated = FALSE
		else
			activated = TRUE
		if(reveal_toggle && holder)
			if(istype(holder, /obj/machinery/artifact))
				var/obj/machinery/artifact/A = holder
				A.update_icon()
			var/display_msg
			if(activated)
				display_msg = pick("momentarily glows brightly!", "distorts slightly for a moment!", "flickers slightly!", "vibrates!", "shimmers slightly for a moment!")
			else
				display_msg = pick("grows dull!", "fades in intensity!", "suddenly becomes very still!", "suddenly becomes very quiet!")
			var/atom/toplevelholder = holder
			while(!istype(toplevelholder.loc, /turf))
				toplevelholder = toplevelholder.loc
			if(ishuman(toplevelholder)) // When utilizer works, the holder is human and we dont display his icon (costs too much)
				toplevelholder.visible_message("<span class='warning'>[toplevelholder] [display_msg]</span>")
			else
				toplevelholder.visible_message("<span class='warning'>[bicon(toplevelholder)] [toplevelholder] [display_msg]</span>")

/datum/artifact_effect/proc/DoEffectTouch(mob/user)
/datum/artifact_effect/proc/DoEffectAura(atom/holder)
/datum/artifact_effect/proc/DoEffectPulse(atom/holder)
/datum/artifact_effect/proc/UpdateMove()

/datum/artifact_effect/process()
	if(chargelevel < chargelevelmax)
		chargelevel++

	if(activated)
		if(effect == ARTIFACT_EFFECT_AURA)
			DoEffectAura()
		else if(effect == ARTIFACT_EFFECT_PULSE && chargelevel >= chargelevelmax)
			chargelevel = 0
			DoEffectPulse()

/datum/artifact_effect/proc/getDescription()
	. = "<b>"
	switch(effect_type)
		if(ARTIFACT_EFFECT_ENERGY)
			. += "Concentrated energy emissions"
		if(ARTIFACT_EFFECT_PSIONIC)
			. += "Intermittent psionic wavefront"
		if(ARTIFACT_EFFECT_ELECTRO)
			. += "Electromagnetic energy"
		if(ARTIFACT_EFFECT_PARTICLE)
			. += "High frequency particles"
		if(ARTIFACT_EFFECT_ORGANIC)
			. += "Organically reactive exotic particles"
		if(ARTIFACT_EFFECT_BLUESPACE)
			. += "Interdimensional/bluespace? phasing"
		if(ARTIFACT_EFFECT_SYNTH)
			. += "Atomic synthesis"
		else
			. += "Low level energy emissions"

	. += "</b> have been detected <b>"

	switch(effect)
		if(ARTIFACT_EFFECT_TOUCH)
			. += "interspersed throughout substructure and shell."
		if(ARTIFACT_EFFECT_AURA)
			. += "emitting in an ambient energy field."
		if(ARTIFACT_EFFECT_PULSE)
			. += "emitting in periodic bursts."
		else
			. += "emitting in an unknown way."

	. += "</b>"

	switch(trigger)
		if(TRIGGER_TOUCH, TRIGGER_WATER, TRIGGER_ACID, TRIGGER_VOLATILE, TRIGGER_TOXIN)
			. += " Activation index involves <b>physical interaction</b> with artifact surface."
		if(TRIGGER_FORCE, TRIGGER_ENERGY, TRIGGER_HEAT, TRIGGER_COLD)
			. += " Activation index involves <b>energetic interaction</b> with artifact surface."
		if(TRIGGER_PHORON, TRIGGER_OXY, TRIGGER_CO2, TRIGGER_NITRO)
			. += " Activation index involves <b>precise local atmospheric conditions</b>."
		else
			. += " Unable to determine any data about activation trigger."

// returns 0..1, with 1 being no protection and 0 being fully protected
/proc/GetAnomalySusceptibility(mob/living/carbon/human/H)
	if(!H || !istype(H))
		return 1

	var/protected = 0

	// particle protection suits give best protection, but science space suits are almost as good
	if(istype(H.wear_suit, /obj/item/clothing/suit/bio_suit/particle_protection))
		protected += 0.6
	else if(istype(H.wear_suit, /obj/item/clothing/suit/space/globose/science))
		protected += 0.5

	if(istype(H.head, /obj/item/clothing/head/bio_hood/particle_protection))
		protected += 0.3
	else if(istype(H.head, /obj/item/clothing/head/helmet/space/globose/science))
		protected += 0.2

	// latex gloves and science goggles also give a bit of bonus protection
	if(istype(H.gloves,/obj/item/clothing/gloves/latex))
		protected += 0.1

	if(istype(H.glasses,/obj/item/clothing/glasses/science))
		protected += 0.1

	return 1 - protected
