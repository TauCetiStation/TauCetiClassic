#define IS_EPILEPTIC_MOB (1<<0)
#define IS_EPILEPTIC_NOT_IN_PARALYSIS (1<<1)

#define EPILEPSY_PARALYSE_EFFECT (1<<0)
#define EPILEPSY_JITTERY_EFFECT (1<<1)

#define COMSIG_TRIGGER_EPILEPSY "trigger_epilepsy"
#define COMSIG_ADJUST_DELAY_EPILEPSY "adjust_delay_epilepsy"
#define COMSIG_REMOVE_EPILEPSY "remove_epilepsy"
#define COMSIG_MAKE_EPILEPSY_DANGEROUS "make_epilepsy_dangerous"
#define COMSIG_MAKE_EPILEPSY_LESS_DANGEROUS "make_epilepsy_less_dangerous"

//Like sources
#define QUIRK_TYPE_EPILEPSY "quirk_type_epilepsy"
#define GENE_TYPE_EPILEPSY "gene_type_epilepsy"

#define ALCOHOL_TOLERANCE_EPILEPSY (1<<0)
#define WATER_CHOKE_EPILEPSY (1<<1)

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
	RegisterSignal(parent, list(COMSIG_TRIGGER_EPILEPSY), PROC_REF(try_do_seizure))
	RegisterSignal(parent, list(COMSIG_ADJUST_DELAY_EPILEPSY), PROC_REF(adjust_delay_effect))
	RegisterSignal(parent, list(COMSIG_REMOVE_EPILEPSY), PROC_REF(remove_epilepsy))
	RegisterSignal(parent, list(COMSIG_MAKE_EPILEPSY_DANGEROUS), PROC_REF(make_epilepsy_dangerous))
	RegisterSignal(parent, list(COMSIG_MAKE_EPILEPSY_LESS_DANGEROUS), PROC_REF(make_epilepsy_less_dangerous))

/datum/component/epilepsy/Destroy()
	UnregisterSignal(parent, list(COMSIG_TRIGGER_EPILEPSY,
	                              COMSIG_ADJUST_DELAY_EPILEPSY,
	                              COMSIG_REMOVE_EPILEPSY,
							      COMSIG_MAKE_EPILEPSY_DANGEROUS,
							      COMSIG_MAKE_EPILEPSY_LESS_DANGEROUS
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

/datum/component/epilepsy/proc/remove_epilepsy(datum/source, type)
	SIGNAL_HANDLER
	if(type == type_epilepsy)
		qdel(src)

/datum/component/epilepsy/proc/adjust_delay_effect(datum/source, amount, max_protect_times)
	SIGNAL_HANDLER
	if(max_protect_times)
		delay_effect = min(max_protect_times, delay_effect + amount)
		return
	delay_effect += amount

/datum/component/epilepsy/proc/is_condition_fulfilled(datum/source)
	if(epilepsy_conditions & IS_EPILEPTIC_MOB)
		if(!ismob(source))
			return FALSE
	if(epilepsy_conditions & IS_EPILEPTIC_NOT_IN_PARALYSIS)
		if((epilepsy_conditions & IS_EPILEPTIC_MOB))
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

/datum/component/epilepsy/proc/try_do_seizure(datum/source)
	SIGNAL_HANDLER
	world.log << "triggered [world.time]"
	if(!is_condition_fulfilled(source))
		return
	if(is_delayed(source))
		return
	if(!do_effect(source))
		return
	if(epilepsy_conditions & IS_EPILEPTIC_MOB)
		var/mob/M = source
		M.visible_message("<span class='danger'>[source] starts having a seizure!</span>",
		                  "<span class='warning'>You have a seizure!</span>")
