/datum/artifact_effect/cellcharge
	log_name = "Cell Charge"
	type_name = ARTIFACT_EFFECT_ELECTRO

/datum/artifact_effect/cellcharge/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	for(var/obj/item/weapon/stock_parts/cell/D in user.contents)
		D.charge += 150
		if(isrobot(user))
			to_chat(user, "<span class='notice'>SYSTEM ALERT: Energy boost detected!</span>")

/datum/artifact_effect/cellcharge/DoEffectAura()
	. = ..()
	if(!.)
		return
	var/turf/curr_turf = get_turf(holder)
	recharge_everything_in_range(25, range, curr_turf)

/datum/artifact_effect/cellcharge/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/used_power
	used_power = .
	var/turf/curr_turf = get_turf(holder)
	recharge_everything_in_range(200 * used_power, range, curr_turf)

/datum/artifact_effect/cellcharge/DoEffectDestroy()
	var/turf/curr_turf = get_turf(holder)
	recharge_everything_in_range(10000, 7, curr_turf)

/datum/artifact_effect/cellcharge/proc/recharge_everything_in_range(power, range, center)
	for(var/obj/item/weapon/stock_parts/cell/C in range(range, center))
		C.charge += power
	for(var/obj/machinery/power/apc/A in range(range, center))
		for(var/obj/item/weapon/stock_parts/cell/B in A.contents)
			B.charge += power
	for(var/obj/machinery/power/smes/S in range(range, center))
		S.charge += power
	for(var/mob/living/silicon/robot/M in range(range, center))
		for(var/obj/item/weapon/stock_parts/cell/D in M.contents)
			D.charge += power
			to_chat(M, "<span class='notice'>SYSTEM ALERT: Energy boost detected!</span>")
