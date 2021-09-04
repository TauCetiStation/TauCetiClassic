/datum/artifact_effect/cellcharge
	effect_name = "Cell Charge"
	effect_type = ARTIFACT_EFFECT_ELECTRO

/datum/artifact_effect/cellcharge/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	if(!isrobot(user))
		return
	var/mob/living/silicon/robot/R = user
	for(var/obj/item/weapon/stock_parts/cell/D in R.contents)
		D.charge += 150
		to_chat(R, "<span class='notice'>SYSTEM ALERT: Large energy boost detected!</span>")

/datum/artifact_effect/cellcharge/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	recharge_everything_in_range(25, effectrange, curr_turf)

/datum/artifact_effect/cellcharge/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	recharge_everything_in_range(250, effectrange, curr_turf)

/datum/artifact_effect/cellcharge/DoEffectDestroy()
	var/turf/curr_turf = get_turf(holder)
	recharge_everything_in_range(10000, 7, curr_turf)

/datum/artifact_effect/cellcharge/proc/recharge_everything_in_range(power, range, center)	
	for(var/obj/machinery/power/apc/C in range(range, center))
		for(var/obj/item/weapon/stock_parts/cell/B in C.contents)
			B.charge += power
	for(var/obj/machinery/power/smes/S in range(range, center))
		S.charge += power
	for(var/mob/living/silicon/robot/M in range(range, center))
		for(var/obj/item/weapon/stock_parts/cell/D in M.contents)
			D.charge += power
			to_chat(M, "<span class='notice'>SYSTEM ALERT: Energy boost detected!</span>")
