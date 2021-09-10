/datum/artifact_effect/celldrain
	log_name = "Cell Drain"
	type_name = ARTIFACT_EFFECT_ELECTRO

/datum/artifact_effect/celldrain/DoEffectTouch(mob/user)
	. = ..()
	if(!.)
		return
	for(var/obj/item/weapon/stock_parts/cell/D in user.contents)
		D.use(150)
		if(isrobot(user))
			to_chat(user, "<span class='notice'>SYSTEM ALERT: Energy drain detected!</span>")

/datum/artifact_effect/celldrain/DoEffectAura()
	. = ..()
	if(!.)
		return
	discharge_everything_in_range(150, range, holder)

/datum/artifact_effect/celldrain/DoEffectPulse()
	. = ..()
	if(!.)
		return
	var/used_power = .
	discharge_everything_in_range(200 * used_power, range, holder)

/datum/artifact_effect/celldrain/DoEffectDestroy()
	discharge_everything_in_range(10000, 7, holder)

/datum/artifact_effect/celldrain/proc/discharge_everything_in_range(power, range, center)
	var/turf/curr_turf = get_turf(holder)
	var/list/captured_atoms = range(range, curr_turf)
	for(var/obj/item/weapon/stock_parts/cell/C in captured_atoms)
		C.use(power)
	for(var/obj/machinery/power/apc/C in captured_atoms)
		for(var/obj/item/weapon/stock_parts/cell/B in C.contents)
			B.use(power)
	for(var/obj/machinery/power/smes/S in captured_atoms)
		for(var/obj/item/weapon/stock_parts/cell/C in S.contents)
			C.use(power)
	for(var/mob/living/silicon/robot/M in captured_atoms)
		for(var/obj/item/weapon/stock_parts/cell/D in M.contents)
			D.use(power)
			to_chat(M, "<span class='warning'>SYSTEM ALERT: Energy drain detected!</span>")
