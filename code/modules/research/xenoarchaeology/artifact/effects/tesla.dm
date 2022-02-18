/datum/artifact_effect/tesla
	log_name = "Tesla"
	type_name = ARTIFACT_EFFECT_ELECTRO

/datum/artifact_effect/tesla/New(atom/location)
	..()
	release_method = ARTIFACT_EFFECT_PULSE
	current_charge = 0
	maximum_charges = 30
	activation_pulse_cost = maximum_charges
	artifact_id = "tesla"

/datum/artifact_effect/tesla/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/radius = rand(0,4)
	radius = radius + 2
	tesla_zap(holder, radius, radius * 25000)

/datum/artifact_effect/tesla/DoEffectDestroy()
	tesla_zap(holder, 7, 2500000)
