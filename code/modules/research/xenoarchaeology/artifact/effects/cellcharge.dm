/datum/artifact_effect/cellcharge
	log_name = "Cell Charge"
	type_name = ARTIFACT_EFFECT_ELECTRO

/datum/artifact_effect/cellcharge/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	for(var/obj/item/weapon/stock_parts/cell/D in user.contents)
		D.give(150)
		if(isrobot(user))
			to_chat(user, "<span class='notice'>SYSTEM ALERT: Energy boost detected!</span>")

/datum/artifact_effect/cellcharge/DoEffectAura()
	. = ..()
	if(!.)
		return
	recharge_everything_in_range(25, range, holder)

/datum/artifact_effect/cellcharge/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/used_power = .
	recharge_everything_in_range(200 * used_power, range, holder)

/datum/artifact_effect/cellcharge/DoEffectDestroy()
	recharge_everything_in_range(10000, 7, holder)

/datum/artifact_effect/cellcharge/proc/recharge_everything_in_range(power, range)
	var/turf/curr_turf = get_turf(holder)
	var/list/captured_atoms = range(range, curr_turf)
	for(var/obj/item/weapon/stock_parts/cell/C in captured_atoms)
		C.give(power)
	for(var/obj/machinery/power/apc/A in captured_atoms)
		for(var/obj/item/weapon/stock_parts/cell/B in A.contents)
			B.give(power)
	for(var/obj/machinery/power/smes/S in captured_atoms)
		for(var/obj/item/weapon/stock_parts/cell/C in S.contents)
			C.give(power)
	for(var/mob/living/silicon/robot/M in captured_atoms)
		for(var/obj/item/weapon/stock_parts/cell/D in M.contents)
			D.give(power)
			to_chat(M, "<span class='notice'>SYSTEM ALERT: Energy boost detected!</span>")
