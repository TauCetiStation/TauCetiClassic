/*
 * Basically your stat from RPG with set of dynamic mods (buffs or debuffs) like +20% or *20%.
 * Can be easily used as cumulative coefficient for calculations.
 * 
 * You can combine multiple static, multiplicative and additive mods from different sources
 * and even add another modval as a modificator (disclaimer: there is no built-in protection from loop dependencies)
 *
 * In the end it will be calculated like this:
 * value = (base_value + SUM(statics)) * PRODUCT(multiplicatives) * (1 + SUM(additives))
 */

/datum/modval
	VAR_PRIVATE/value = 0
	VAR_PRIVATE/base_value = 0
	VAR_PRIVATE/clamp_min
	VAR_PRIVATE/clamp_max
	VAR_PRIVATE/round_base
	VAR_PRIVATE/list/statics
	VAR_PRIVATE/list/multiplicatives
	VAR_PRIVATE/list/additives

/datum/modval/New(base_value, clamp_min, clamp_max, round_base)
	src.base_value = base_value
	src.clamp_min = clamp_min
	src.clamp_max = clamp_max
	src.round_base = round_base
	Recalculate()

/datum/modval/Destroy()
	statics = null
	multiplicatives = null
	additives = null
	return ..()

/datum/modval/proc/SetBaseValue(new_value)
	base_value = new_value
	Recalculate()

/datum/modval/proc/Get()
	return value

// constant non-relative mod, like +5 or -5
// other mods will mod on top of it
/datum/modval/proc/ModStatic(new_static, source)
	if(!source || isnull(new_static))
		return

	if(!statics)
		statics = list()
	else if(statics[source] == new_static)
		return

	if(istype(statics[source], /datum/modval))
		UnregisterSignal(statics[source], COMSIG_MODVAL_UPDATE)

	statics[source] = new_static
	if(istype(statics[source], /datum/modval))
		RegisterSignal(statics[source], COMSIG_MODVAL_UPDATE, PROC_REF(Recalculate))

	Recalculate()

// multiplicative mod, like *2 or *0.5
// multiplicative mods multiply each other so two mods 2 and 0.5 will give you 1
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

// relative mod, +0.5 means to add 50%
// relative mods stacks with each other, two +50% mods will give you +100%
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

/datum/modval/proc/RemoveMods(source)
	var/need_to_recalculate = FALSE

	if(length(statics) && (source in statics))
		statics -= source
		need_to_recalculate = TRUE
		if(!length(statics))
			statics = null

	if(length(multiplicatives) && (source in multiplicatives))
		multiplicatives -= source
		need_to_recalculate = TRUE
		if(!length(multiplicatives))
			multiplicatives = null

	if(length(additives) && (source in additives))
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

	if(length(statics))
		var/stat = 0
		for(var/source in statics)
			if(istype(statics[source], /datum/modval))
				var/datum/modval/V = statics[source]
				stat += V.Get()
			else
				stat += statics[source]

		new_value += stat

	if(new_value && length(multiplicatives)) // new_value could be 0 so we can skip future calculations
		var/multiplicative = 1
		for(var/source in multiplicatives)
			if(istype(multiplicatives[source], /datum/modval))
				var/datum/modval/V = multiplicatives[source]
				multiplicative *= V.Get()
			else
				multiplicative *= multiplicatives[source]

		new_value *= multiplicative

	if(new_value && length(additives))
		var/additive = 0
		for(var/source in additives)
			if(istype(additives[source], /datum/modval))
				var/datum/modval/V = additives[source] 
				additive += V.Get()
			else
				additive += additives[source]

		new_value *= (1 + additive)

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
	var/stat = 0
	var/multi = 1
	var/addi = 0

	. += "<b>Statics</b>:<br>"
	for(var/source in statics)
		if(istype(statics[source], /datum/modval))
			var/datum/modval/V = statics[source] 
			mod = V.Get()
		else
			mod = multiplicatives[source]
		stat += mod
		. += "[ENTITY_TAB][SIGNED_NUM(mod)] (source: <b>[source]</b>)<br>"

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

	. += "<b>Final value</b>: [value] = ([base_value] [SIGNED_NUM(stat)]) * [multi] * (1 [SIGNED_NUM(addi)])"

	return . // linter problems, https://github.com/SpaceManiac/SpacemanDMM/issues/423

#undef SIGNED_NUM
#undef PRINT_SIGN
