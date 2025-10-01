// This is really pretty crap and should be overridden for specific machines.
/obj/machinery/fluid_act(datum/reagents/fluids)
	..()
	if(!QDELETED(src) && !(stat & (NOPOWER|BROKEN)) && !waterproof && (fluids?.total_volume > FLUID_DEEP))
		ex_act(EXPLODE_LIGHT)

/obj/effect/decal/cleanable/fluid_act(datum/reagents/fluid)
	SHOULD_CALL_PARENT(FALSE)
	if(fluid?.total_liquid_volume && !QDELETED(src))
		if(reagents?.total_volume)
			reagents.trans_to(fluid, reagents.total_volume)
		qdel(src)

/obj/item/candle/fluid_act(datum/reagents/fluids)
	..()

	if(QDELETED(src) || !fluids?.total_volume || !lit)
		return

	var/turf/location = get_turf(src)
	if(location)
		location.hotspot_expose(700, 5) // Potentially set fire to fuel etc.
		if(QDELETED(src) || !fluids?.total_volume)
			return

	if(waterproof)
		return

	if(fluids.total_volume >= FLUID_PUDDLE)
		extinguish()

/obj/item/weapon/weldingtool/fluid_act(datum/reagents/fluids)
	..()
	if(!QDELETED(src) && fluids?.total_volume && isOn() && !waterproof)
		var/turf/location = get_turf(src)
		if(location)
			location.hotspot_expose(700, 50, src)
		toggle(1)

/obj/structure/fireplace/fluid_act(datum/reagents/fluids)
	. = ..()
	if(!QDELETED(src) && fluids?.total_volume && reagents)
		var/transfer = min(reagents.maximum_volume - reagents.total_volume, max(max(1, round(fluids.total_volume * 0.25))))
		if(transfer > 0)
			fluids.trans_to(src, transfer)

/obj/fluid_act(datum/reagents/fluids)
	..()
	if(!QDELETED(src) && fluids?.total_volume)
		fluids.reaction(src)

// Slightly convoluted reagent logic to avoid fluid_act() putting reagents straight back into the destroyed /obj.
/*/obj/physically_destroyed(skip_qdel)
	var/dumped_reagents = FALSE
	var/atom/last_loc = loc
	if(last_loc && reagents?.total_volume)
		reagents.trans_to(loc, reagents.total_volume, defer_update = TRUE)
		dumped_reagents = TRUE
		reagents.clear_reagents() // We are qdeling, don't bother with a more nuanced update.
	. = ..()
	if(dumped_reagents && last_loc && !QDELETED(last_loc) && last_loc.reagents?.total_volume)
		last_loc.reagents.handle_update()
		HANDLE_REACTIONS(last_loc.reagents)*/

/turf/fluid_act(datum/reagents/fluids)
	..()
	if(!QDELETED(src) && fluids?.total_volume)
		fluids.reaction(src)
		// Wet items that are not supported on a platform or such.
		if(fluids?.total_volume > FLUID_PUDDLE)
			for(var/atom/movable/AM as anything in get_contained_external_atoms())
				if(!AM.submerged())
					continue
				AM.fluid_act(fluids)

/obj/item/clothing/mask/cigarette/fluid_act(datum/reagents/fluids)
	..()
	if(!QDELETED(src) && fluids?.total_volume && !waterproof && lit)
		var/turf/location = get_turf(src)
		if(location)
			location.hotspot_expose(700, 5)
		die()

/mob/living/fluid_act(datum/reagents/fluids)
	..()
	if(QDELETED(src) || fluids?.total_volume < FLUID_PUDDLE)
		return
	fluids.reaction(src)
	if(QDELETED(src) || fluids?.total_volume < FLUID_PUDDLE)
		return
	var/on_turf = fluids.my_atom == get_turf(src)
	for(var/atom/movable/A as anything in get_equipped_items(TRUE))
		if(!A.simulated)
			continue
		// if we're being affected by reagent fluids, items check if they're submerged
		// todo: i don't like how this works, it feels hacky. maybe separate coating and submersion somehow and make this only checked for submersion
		if(on_turf && !A.submerged())
			continue
		A.fluid_act(fluids)
		if(QDELETED(src) || !fluids.total_volume)
			return
	// TODO: review saturation logic so we can end up with more than like 15 water in our contact reagents.
	var/datum/reagents/touching_reagents = reagents//get_contact_reagents()
	if(touching_reagents)
		var/saturation =  min(fluids.total_volume, round(w_class * 4 * reagent_permeability()) - touching_reagents.total_volume)
		if(saturation > 0)
			fluids.trans_to(touching_reagents, saturation)

/mob/living/carbon/human/fluid_act(datum/reagents/fluids)
	..()
	if(!QDELETED(src) && fluids?.total_volume)
		species.fluid_act(src, fluids)

/datum/species/proc/fluid_act(mob/living/human/H, datum/reagents/fluids)
	return

/datum/species/skrell/fluid_act(mob/living/carbon/human/H, datum/reagents/fluids)
	if(!fluids)
		return
	var/water = fluids.get_reagent_amount("water")
	if(water >= 40)
		if(H.getHalLoss())
			H.adjustHalLoss(-25) // Slightly more than being drunk because it fires less often (10 ticks as opposed to 4)
		if(H.getBruteLoss() || H.getFireLoss())
			H.adjustBruteLoss(-(rand(1, 3)))
			H.adjustFireLoss(-(rand(1, 3)))
		if(prob(5)) // Might be too spammy.
			to_chat(H, "<span class='notice'>The water ripples gently over your skin in a soothing balm.</span>")

/obj/machinery/artifact/fluid_act(datum/reagents/fluids)
	..()
	if(!QDELETED(src) && fluids?.total_liquid_volume && fluids?.has_reagent("water", 1))
		try_toggle_effects(TRIGGER_WATER)

/obj/fire/fluid_act(datum/reagents/fluids)
	..()
	qdel(src)

/obj/item/weapon/match/fluid_act(datum/reagents/fluids)
	..()
	if(!waterproof && lit)
		burn_out()

/mob/living/proc/reagent_permeability()
	return 1

/mob/living/human/reagent_permeability()
	var/perm = 0

	var/list/perm_by_part = list(
		"head" = THERMAL_PROTECTION_HEAD,
		"upper_torso" = THERMAL_PROTECTION_UPPER_TORSO,
		"lower_torso" = THERMAL_PROTECTION_LOWER_TORSO,
		"legs" = THERMAL_PROTECTION_LEG_LEFT + THERMAL_PROTECTION_LEG_RIGHT,
		"arms" = THERMAL_PROTECTION_ARM_LEFT + THERMAL_PROTECTION_ARM_RIGHT
		)

	for(var/obj/item/clothing/C in src.get_equipped_items())
		if(C.permeability_coefficient == 1 || !C.body_parts_covered)
			continue
		if(C.body_parts_covered & HEAD)
			perm_by_part["head"] *= C.permeability_coefficient
		if(C.body_parts_covered & UPPER_TORSO)
			perm_by_part["upper_torso"] *= C.permeability_coefficient
		if(C.body_parts_covered & LOWER_TORSO)
			perm_by_part["lower_torso"] *= C.permeability_coefficient
		if(C.body_parts_covered & LEGS)
			perm_by_part["legs"] *= C.permeability_coefficient
		if(C.body_parts_covered & ARMS)
			perm_by_part["arms"] *= C.permeability_coefficient

	for(var/part in perm_by_part)
		perm += perm_by_part[part]

	return perm
