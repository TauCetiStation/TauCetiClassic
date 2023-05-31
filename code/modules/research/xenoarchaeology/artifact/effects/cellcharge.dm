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

/datum/artifact_effect/cellcharge/proc/try_give_charge(atom/reciever_atmon, power)
	if(istype(reciever_atmon, /obj/item/weapon/stock_parts/cell))
		var/obj/item/weapon/stock_parts/cell/C = reciever_atmon
		C.give(power)
	if(istype(reciever_atmon, /obj/machinery/power/apc))
		for(var/obj/item/weapon/stock_parts/cell/C in reciever_atmon.contents)
			C.give(power)
	if(istype(reciever_atmon, /obj/machinery/power/smes))
		for(var/obj/item/weapon/stock_parts/cell/C in reciever_atmon.contents)
			C.give(power)
	if(isrobot(reciever_atmon))
		for(var/obj/item/weapon/stock_parts/cell/D in reciever_atmon.contents)
			D.give(power)
		to_chat(reciever_atmon, "<span class='notice'>SYSTEM ALERT: Energy boost detected!</span>")

/datum/artifact_effect/cellcharge/proc/recharge_everything_in_range(power, range)
	var/turf/curr_turf = get_turf(holder)
	var/list/captured_atoms = range(range, curr_turf)
	for(var/atom/A in captured_atoms)
		try_give_charge(A, power)
