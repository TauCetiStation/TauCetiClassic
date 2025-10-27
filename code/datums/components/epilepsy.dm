//Like sources
#define QUIRK_TYPE_EPILEPSY "quirk_type_epilepsy"
#define GENE_TYPE_EPILEPSY "gene_type_epilepsy"

/datum/component/epilepsy
	var/epilepsy_conditions = 0
	var/epilepsy_effect = 0
	var/delay_effect = 0
	var/type_epilepsy = ""
	var/epilepsy_dangerous_factors = 0

/datum/component/epilepsy/Initialize(_epilepsy_conditions, _epilepsy_effect, _type_epilepsy)
	epilepsy_conditions |= _epilepsy_conditions
	epilepsy_effect |= _epilepsy_effect
	type_epilepsy = _type_epilepsy
	RegisterSignal(parent, list(COMSIG_FLASH_EYES), PROC_REF(handle_flash_eyes))
	RegisterSignal(parent, list(COMSIG_IMPEDREZENE_DIGEST), PROC_REF(adjust_impedrezene_effect))
	RegisterSignal(parent, list(COMSIG_REMOVE_GENE_DISABILITY), PROC_REF(remove_epilepsy))
	RegisterSignal(parent, list(COMSIG_HANDLE_DISABILITIES), PROC_REF(handle_disabilities))
	RegisterSignal(parent, list(COMSIG_HUMAN_ENTERED_WATER), PROC_REF(enter_waterturf))
	RegisterSignal(parent, list(COMSIG_HUMAN_EXITED_WATER), PROC_REF(exit_waterturf))

/datum/component/epilepsy/Destroy()
	UnregisterSignal(parent, list(COMSIG_HUMAN_EXITED_WATER,
	                              COMSIG_HUMAN_ENTERED_WATER,
	                              COMSIG_HANDLE_DISABILITIES,
							      COMSIG_REMOVE_GENE_DISABILITY,
							      COMSIG_IMPEDREZENE_DIGEST,
								  COMSIG_FLASH_EYES
	                            ))
	return ..()

/datum/component/epilepsy/proc/update_fear_factor(datum/source, fear_factor)
	epilepsy_dangerous_factors |= fear_factor

	if(fear_factor & ALCOHOL_TOLERANCE_EPILEPSY)
		if(isliving(source) && !HAS_TRAIT_FROM(source, TRAIT_LIGHT_DRINKER, GENERIC_TRAIT))
			ADD_TRAIT(source, TRAIT_LIGHT_DRINKER, GENERIC_TRAIT)

/datum/component/epilepsy/proc/make_epilepsy_dangerous(datum/source, fear_factor)
	SIGNAL_HANDLER
	update_fear_factor(source, fear_factor)

/datum/component/epilepsy/proc/make_epilepsy_less_dangerous(datum/source, fear_factor)
	SIGNAL_HANDLER
	epilepsy_dangerous_factors &= ~fear_factor
	if(fear_factor & ALCOHOL_TOLERANCE_EPILEPSY)
		if(isliving(source))
			REMOVE_TRAIT(source, TRAIT_LIGHT_DRINKER, GENERIC_TRAIT)

/datum/component/epilepsy/proc/enter_waterturf(datum/source)
	SIGNAL_HANDLER
	make_epilepsy_dangerous(source, WATER_CHOKE_EPILEPSY)

/datum/component/epilepsy/proc/exit_waterturf(datum/source)
	SIGNAL_HANDLER
	make_epilepsy_less_dangerous(source, WATER_CHOKE_EPILEPSY)

/datum/component/epilepsy/proc/remove_epilepsy(datum/source, type)
	SIGNAL_HANDLER
	if(type == type_epilepsy)
		qdel(src)

/datum/component/epilepsy/proc/adjust_impedrezene_effect(datum/source)
	SIGNAL_HANDLER
	adjust_delay_effect(source, 0.5, 10)
	make_epilepsy_dangerous(source, ALCOHOL_TOLERANCE_EPILEPSY)

/datum/component/epilepsy/proc/adjust_delay_effect(datum/source, amount, max_protect_times)
	SIGNAL_HANDLER
	if(max_protect_times)
		delay_effect = min(max_protect_times, delay_effect + amount)
		return
	delay_effect += amount

/datum/component/epilepsy/proc/is_condition_fulfilled(datum/source)
	if(epilepsy_conditions & IS_EPILEPTIC_NOT_IN_PARALYSIS)
		if(!ismob(source))
			return FALSE
		var/mob/M = source
		if(M.paralysis)
			return FALSE
	return TRUE

/datum/component/epilepsy/proc/do_effect(datum/source)
	. = FALSE
	if(epilepsy_effect & EPILEPSY_PARALYSE_EFFECT)
		if(ismob(source))
			var/mob/A = source
			if(A.Paralyse(10))
				. = TRUE
	if(epilepsy_effect & EPILEPSY_JITTERY_EFFECT)
		if(ismob(source))
			var/mob/A = source
			if(A.make_jittery(1000))
				. = TRUE
	if(epilepsy_dangerous_factors & WATER_CHOKE_EPILEPSY)
		if(iscarbon(source))
			var/mob/living/carbon/C = source
			C.losebreath = max(C.losebreath, 5)
			. = TRUE

/datum/component/epilepsy/proc/is_delayed(datum/source)
	if(delay_effect < 1)
		return FALSE
	delay_effect--
	return TRUE

/datum/component/epilepsy/proc/handle_disabilities(datum/source)
	SIGNAL_HANDLER
	if(prob(99))
		return
	try_do_seizure(source)

/datum/component/epilepsy/proc/handle_flash_eyes(datum/source, intensity)
	SIGNAL_HANDLER
	if(intensity <= 0)
		return
	if(prob(intensity * 50))
		try_do_seizure(source)

/datum/component/epilepsy/proc/try_do_seizure(datum/source)
	SIGNAL_HANDLER
	if(!is_condition_fulfilled(source))
		return
	if(is_delayed(source))
		return
	if(!do_effect(source))
		return
	var/mob/M = source
	M.visible_message("<span class='danger'>[source] starts having a seizure!</span>",
						"<span class='warning'>You have a seizure!</span>")
