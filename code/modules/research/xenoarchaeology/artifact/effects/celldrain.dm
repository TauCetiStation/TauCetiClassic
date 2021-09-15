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

/datum/artifact_effect/celldrain/proc/try_use_charge(atom/reciever_atmon, power)
	if(istype(reciever_atmon, /obj/item/weapon/stock_parts/cell))
		var/obj/item/weapon/stock_parts/cell/C = reciever_atmon
		C.use(power)
	if(istype(reciever_atmon, /obj/machinery/power/apc))
		for(var/obj/item/weapon/stock_parts/cell/C in reciever_atmon.contents)
			C.use(power)
	if(istype(reciever_atmon, /obj/machinery/power/smes))
		for(var/obj/item/weapon/stock_parts/cell/C in reciever_atmon.contents)
			C.use(power)
	if(isrobot(reciever_atmon))
		for(var/obj/item/weapon/stock_parts/cell/D in reciever_atmon.contents)
			D.use(power)
		to_chat(reciever_atmon, "<span class='warning'>SYSTEM ALERT: Energy drain detected!</span>")

/datum/artifact_effect/celldrain/proc/discharge_everything_in_range(power, range, center)
	var/turf/curr_turf = get_turf(holder)
	var/list/captured_atoms = range(range, curr_turf)
	for(var/atom/A in captured_atoms)
		try_use_charge(A, power)
