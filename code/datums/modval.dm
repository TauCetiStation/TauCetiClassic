/*
 * Basically your stat from RPG with set of dynamic mods (buffs or debuffs) like +20% or *20%.
 *
 * Below is some examples of how it will be calculated.
 *
 * You can add a multiplicative mod of 0.20: 
 * value * 0.20
 * the final value becomes 20% of the original value.
 *
 * Or an additive mod of 0.20:
 * value + value * 0.20
 * the final value increases by 20% of the original value.
 *
 * You can stack them, for example it's how will be calculated two multiplicative mods of 0.20: 
 * value * 0.20 * 0.20 = value * 0.04 
 * so the value becomes 4% of the original, multiplicative mods are powerful!
 *
 * Or two additive:
 * value + value * (0.20 + 0.20) = value + value * 0.40 = value * (1 + 0.40) 
 * the final value becomes 140% of the original value.
 * 
 * You can combine multiple multiplicative and additive mods from different sources
 * and even add another modval as a modificator (disclaimer: there is no built-in protection from loop dependencies)
 * and you can add multiplicative with "0" value to overwrite all others.
 *
 * In the end it will be calculated like this:
 * value = base_value * PRODUCT(multiplicatives) * (1 + SUM(additives))
 */

/datum/modval
	VAR_PRIVATE/value = 0
	VAR_PRIVATE/base_value = 0
	VAR_PRIVATE/clamp_min
	VAR_PRIVATE/clamp_max
	VAR_PRIVATE/round_base
	VAR_PRIVATE/list/multiplicatives
	VAR_PRIVATE/list/additives

/datum/modval/New(base_value, clamp_min, clamp_max, round_base)
	src.base_value = base_value
	src.clamp_min = clamp_min
	src.clamp_max = clamp_max
	src.round_base = round_base
	Recalculate()

/datum/modval/Destroy()
	multiplicatives = null
	additives = null
	return ..()

/datum/modval/proc/SetBaseValue(new_value)
	base_value = new_value
	Recalculate()

/datum/modval/proc/Get()
	return value

/datum/modval/proc/ModMultiplicative(new_multiplicative, source)
	if(!source || isnull(new_multiplicative))
		return

	if(!multiplicatives)
		multiplicatives = list()
	else if(multiplicatives[source] == new_multiplicative)
		return

	if(istype(multiplicatives[source], /datum/modval))
		UnregisterSignal(multiplicatives[source], COMSIG_MODVAL_UPDATE)

	multiplicatives[source] = new_multiplicative
	if(istype(multiplicatives[source], /datum/modval))
		RegisterSignal(multiplicatives[source], COMSIG_MODVAL_UPDATE, PROC_REF(Recalculate))

	Recalculate()

/datum/modval/proc/ModAdditive(new_additive, source)
	if(!source || isnull(new_additive))
		return

	if(!additives)
		additives = list()
	else if(additives[source] == new_additive)
		return

	if(istype(additives[source], /datum/modval))
		UnregisterSignal(additives[source], COMSIG_MODVAL_UPDATE)

	additives[source] = new_additive
	if(istype(additives[source], /datum/modval))
		RegisterSignal(additives[source], COMSIG_MODVAL_UPDATE, PROC_REF(Recalculate))

	Recalculate()

/datum/modval/proc/RemoveModifiers(source)
	var/need_to_recalculate = FALSE

	if(source in multiplicatives)
		multiplicatives -= source
		need_to_recalculate = TRUE
		if(!length(multiplicatives))
			multiplicatives = null

	if(source in additives)
		additives -= source
		need_to_recalculate = TRUE
		if(!length(additives))
			additives = null

	if(need_to_recalculate)
		Recalculate()

/datum/modval/proc/Recalculate()
	PRIVATE_PROC(TRUE)
	SIGNAL_HANDLER

	var/new_value = base_value

	if(base_value) // don't need to calculate all mods if our base value is zero
		var/multiplicative = 1
		var/mod
		if(length(multiplicatives))
			for(var/source in multiplicatives)
				if(istype(multiplicatives[source], /datum/modval))
					var/datum/modval/V = multiplicatives[source]
					mod = V.Get()
				else
					mod = multiplicatives[source]
				multiplicative *= mod

		var/additive = 0
		if(length(additives))
			for(var/source in additives)
				if(istype(additives[source], /datum/modval))
					var/datum/modval/V = additives[source] 
					mod = V.Get()
				else
					mod = additives[source]
				additive += mod

		new_value = base_value * multiplicative * (1 + additive)

	if(isnum(round_base))
		new_value = round(new_value, round_base)

	if(isnum(clamp_min) && new_value < clamp_min)
		new_value = clamp_min

	if(isnum(clamp_max) && new_value > clamp_max)
		new_value = clamp_max

	if(new_value != value)
		var/old_value = value
		value = new_value
		SEND_SIGNAL(src, COMSIG_MODVAL_UPDATE, old_value)

#define PRINT_SIGN(num) (num < 0 ? "&minus;" : "&plus;")
#define SIGNED_NUM(num) ("[PRINT_SIGN(num)] [abs(num)]")

/datum/modval/proc/DebugPrint()
	. = "<b>Base value</b>: [base_value]<br>"
	var/mod
	var/multi = 1
	var/addi = 0

	. += "<b>Multiplicatives</b>:<br>"
	for(var/source in multiplicatives)
		if(istype(multiplicatives[source], /datum/modval))
			var/datum/modval/V = multiplicatives[source] 
			mod = V.Get()
		else
			mod = multiplicatives[source]
		multi *= mod
		. += "[ENTITY_TAB]* [mod] (source: <b>[source]</b>)<br>"

	. += "<b>Additives</b>:<br>"
	for(var/source in additives)
		if(istype(additives[source], /datum/modval))
			var/datum/modval/V = additives[source] 
			mod = V.Get()
		else
			mod = additives[source]
		addi += mod
		. += "[ENTITY_TAB][SIGNED_NUM(mod)] (source: <b>[source]</b>)<br>"

	. += "<b>Final value</b>: [value] = [base_value] * [multi] * (1 [SIGNED_NUM(addi)])"

#undef SIGNED_NUM
#undef PRINT_SIGN
