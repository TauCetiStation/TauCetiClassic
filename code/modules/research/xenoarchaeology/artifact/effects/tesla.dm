/datum/artifact_effect/tesla
	effect_name = "Tesla"

/datum/artifact_effect/tesla/New(atom/location)
	..()
	effect_type = 8
	effect = ARTIFACT_EFFECT_PULSE
	chargelevel = 0
	chargelevelmax = 30
	activation_pulse_cost = chargelevelmax
	artifact_id = "tesla"

/datum/artifact_effect/tesla/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/radius = rand(0,4)
	radius = radius + 2
	tesla_zap(holder, radius, radius * 25000)
