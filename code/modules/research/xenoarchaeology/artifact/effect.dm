#define ARTIFACT_SMALL_POWER  1
#define ARTIFACT_MEDIUM_POWER 2
#define ARTIFACT_LARGE_POWER  3
#define ARTIFACT_ACTIVATION_MESSAGES list(\
	"momentarily glows brightly!",\
	"distorts slightly for a moment!",\
	"flickers slightly!",\
	"vibrates!",\
	"shimmers slightly for a moment!")
#define ARTIFACT_DEACTIVATION_MESSAGES list(\
	"grows dull!",\
	"fades in intensity!",\
	"suddenly becomes very still!",\
	"suddenly becomes very quiet!")

/datum/artifact_effect
	var/effect_name = "unknown" // purely used for admin checks ingame
	var/effect = ARTIFACT_EFFECT_TOUCH
	var/effectrange = 4
	var/trigger = TRIGGER_TOUCH
	var/atom/holder
	var/activated = FALSE
	var/chargelevel = 0
	var/chargelevelmax = 10
	var/recharge_speed = 1
	var/artifact_id = ""
	var/effect_type = ARTIFACT_EFFECT_UNKNOWN
	var/activation_touch_cost = 5
	var/activation_aura_cost = 0 //always zero right now
	var/activation_pulse_cost = 0

/datum/artifact_effect/New(atom/location)
	..()
	holder = location 
	effect = pick_n_take(ARTIFACT_ALL_EFECTS)
	trigger = pick_n_take(ARTIFACT_POSSIBLE_TRIGGERS)
	create_artifact_type(50, 70, 30)
	activation_pulse_cost = chargelevelmax

/datum/artifact_effect/proc/create_artifact_type(chance_small, chance_medium, chance_large)
	switch(pick(chance_small;ARTIFACT_SMALL_POWER, chance_medium;ARTIFACT_MEDIUM_POWER, chance_large;ARTIFACT_LARGE_POWER))
		if(ARTIFACT_SMALL_POWER)
			chargelevelmax = rand(3, 20)
			effectrange = rand(2, 4)
		if(ARTIFACT_MEDIUM_POWER)
			chargelevelmax = rand(15, 30)
			effectrange = rand(5, 7)
		if(ARTIFACT_LARGE_POWER)
			chargelevelmax = rand(20, 50)
			effectrange = rand(7, 10)

/datum/artifact_effect/proc/ToggleActivate(reveal_toggle = 1)
	INVOKE_ASYNC(src, .proc/toggle_artifact_effect, reveal_toggle)

/datum/artifact_effect/proc/toggle_artifact_effect(reveal_toggle)
	activated = !activated
	if(activated)
		START_PROCESSING(SSobj, src)
	if(!activated)
		STOP_PROCESSING(SSobj, src)
	if(!reveal_toggle && !holder)
		return
	if(istype(holder, /obj/machinery/artifact))
		var/obj/machinery/artifact/A = holder
		A.update_icon()
	var/display_msg = activated ? pick_n_take(ARTIFACT_ACTIVATION_MESSAGES): pick_n_take(ARTIFACT_DEACTIVATION_MESSAGES)
	var/atom/toplevelholder = holder
	while(!istype(toplevelholder.loc, /turf))
		toplevelholder = toplevelholder.loc
	if(ishuman(toplevelholder)) // When utilizer works, the holder is human and we dont display his icon (costs too much)
		toplevelholder.visible_message("<span class='warning'>[toplevelholder] [display_msg]</span>")
	else
		toplevelholder.visible_message("<span class='warning'>[bicon(toplevelholder)] [toplevelholder] [display_msg]</span>")

/datum/artifact_effect/proc/DoEffectTouch(mob/user)
	if(try_drain_charge(activation_touch_cost))
		return TRUE
	return FALSE

/datum/artifact_effect/proc/DoEffectAura(atom/holder)
	if(try_drain_charge(activation_aura_cost))
		return TRUE
	return FALSE

/datum/artifact_effect/proc/DoEffectPulse(atom/holder)
	if(try_drain_charge(activation_pulse_cost))
		return TRUE
	return FALSE

/datum/artifact_effect/proc/UpdateMove()

/datum/artifact_effect/proc/try_drain_charge(var/charges_drained)
	if((chargelevel - charges_drained) < 0)
		return FALSE
	chargelevel -= charges_drained
	return TRUE

/datum/artifact_effect/process()
	chargelevel = min(chargelevel + recharge_speed, chargelevelmax)
	if(effect == ARTIFACT_EFFECT_AURA)
		DoEffectAura()
	else if(effect == ARTIFACT_EFFECT_PULSE)
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
		else
			. += " Unable to determine any data about activation trigger."

// returns 0..1, with 1 being no protection and 0 being fully protected
/proc/GetAnomalySusceptibility(mob/living/carbon/human/H) 
	if(!H || !istype(H)) //damn im blind, i should cut all of the not needed parts bcos of this like when i return the thing if its non human and later check it fo human
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

#undef ARTIFACT_SMALL_POWER
#undef ARTIFACT_MEDIUM_POWER
#undef ARTIFACT_LARGE_POWER
#undef ARTIFACT_ACTIVATION_MESSAGES
#undef ARTIFACT_DEACTIVATION_MESSAGES
