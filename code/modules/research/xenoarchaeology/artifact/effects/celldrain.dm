/datum/artifact_effect/celldrain
	log_name = "Cell Drain"
	type_name = ARTIFACT_EFFECT_ELECTRO

/datum/artifact_effect/celldrain/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	for(var/obj/item/weapon/stock_parts/cell/D in user.contents)
		D.charge = max(D.charge - 100, 0)
		if(isrobot(user))
			to_chat(user, "<span class='notice'>SYSTEM ALERT: Energy drain detected!</span>")

/datum/artifact_effect/celldrain/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	discharge_everything_in_range(150, range, curr_turf)

/datum/artifact_effect/celldrain/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/used_power = .
	var/turf/curr_turf = get_turf(holder)
	discharge_everything_in_range(200 * used_power, range, curr_turf)

/datum/artifact_effect/celldrain/DoEffectDestroy()
	var/turf/curr_turf = get_turf(holder)
	discharge_everything_in_range(10000, 7, curr_turf)

/datum/artifact_effect/celldrain/proc/discharge_everything_in_range(power, range, center)
	for(var/obj/item/weapon/stock_parts/cell/C in range(range, center))
		C.charge = max(C.charge - power, 0)
	for(var/obj/machinery/power/apc/C in range(range, center))
		for(var/obj/item/weapon/stock_parts/cell/B in C.contents)
			B.charge = max(B.charge - power, 0)
	for(var/obj/machinery/power/smes/S in range(range, center))
		S.charge = max(S.charge - power, 0)
	for(var/mob/living/silicon/robot/M in range(range, center))
		for(var/obj/item/weapon/stock_parts/cell/D in M.contents)
			D.charge = max(D.charge - power, 0)
			to_chat(M, "<span class='warning'>SYSTEM ALERT: Energy drain detected!</span>")
