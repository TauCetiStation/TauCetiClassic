
//todo
/datum/artifact_effect/cellcharge
	effect_name = "Cell Charge"
	effect_type = ARTIFACT_EFFECT_ELECTRO

/datum/artifact_effect/cellcharge/DoEffectTouch(mob/user)
	if(!user)
		return FALSE
	if(!isrobot(user))
		return FALSE
	var/mob/living/silicon/robot/R = user
	for(var/obj/item/weapon/stock_parts/cell/D in R.contents)
		D.charge += 150
		to_chat(R, "<span class='notice'>SYSTEM ALERT: Large energy boost detected!</span>")
	return TRUE

/datum/artifact_effect/cellcharge/DoEffectAura()
	if(!holder)
		return FALSE
	recharge_everything_in_range(25, effectrange, holder)
	return TRUE

/datum/artifact_effect/cellcharge/DoEffectPulse()
	if(!holder)
		return FALSE
	recharge_everything_in_range(250, effectrange, holder)
	return TRUE

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
