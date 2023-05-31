/datum/artifact_effect/noise
	log_name = "Noise"
	var/static/list/possible_noises = list(SOUNDIN_EXPLOSION, SOUNDIN_SHATTER, SOUNDIN_SCARYSOUNDS)

/datum/artifact_effect/noise/New()
	..()
	trigger = TRIGGER_OXY
	release_method = ARTIFACT_EFFECT_PULSE
	type_name = ARTIFACT_EFFECT_PSIONIC

/datum/artifact_effect/noise/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/list/sound_type = pick(possible_noises)
	playsound(holder, pick(sound_type), VOL_EFFECTS_MASTER)
