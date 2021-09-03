/datum/artifact_effect/celldrain
	effect_name = "Cell Drain"
	effect_type = ARTIFACT_EFFECT_ELECTRO

/datum/artifact_effect/celldrain/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	if(istype(user, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = user
		for(var/obj/item/weapon/stock_parts/cell/D in R.contents)
			D.charge = max(D.charge - 100, 0)
			to_chat(R, "<span class='notice'>SYSTEM ALERT: Energy drain detected!</span>")

/datum/artifact_effect/celldrain/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	discharge_everything_in_range(150, effectrange, curr_turf)

/datum/artifact_effect/celldrain/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	discharge_everything_in_range(250, effectrange, curr_turf)

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

