/datum/artifact_effect/gas
	log_name = "Gas"
	type_name = ARTIFACT_EFFECT_PARTICLE
	var/max_pressure
	var/target_percentage
	var/list/gas_types = list("carbon_dioxide", "nitrogen", "oxygen", "phoron", "sleeping_agent")
	var/current_gas_type

/datum/artifact_effect/gas/New()
	..()
	release_method = pick(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA)
	max_pressure = rand(115, 1000)
	current_gas_type = pick(gas_types)

/datum/artifact_effect/gas/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	var/turf/holder_loc = holder.loc
	if(isturf(holder_loc))
		holder_loc.assume_gas(current_gas_type, rand(2, 15))

/datum/artifact_effect/gas/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/turf/holder_loc = holder.loc
	if(isturf(holder_loc))
		holder_loc.assume_gas(current_gas_type, pick(0, 0, 0.1, rand()))

/datum/artifact_effect/gas/DoEffectDestroy()
	. = ..()
	var/turf/holder_loc = holder.loc
	if(isturf(holder_loc))
		holder_loc.assume_gas(current_gas_type, 150)
