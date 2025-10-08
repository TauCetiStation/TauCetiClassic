/mob/living/proc/handle_environment(datum/gas_mixture/environment)
	return
/*	if(loc && loc.check_fluid_depth(30))
		var/total_depth = loc.get_fluid_depth()
		water_act(total_depth)
		for(var/obj/item/I in contents)
			I.water_act(total_depth)*/

/mob/proc/can_drown()
	return 0

/obj/item/clothing/mask/proc/filters_water()
	return FALSE

// This doesn't 'filter' water so much as allow us to breathe from the air above it.
/obj/item/clothing/mask/snorkel/filters_water()
	var/turf/source_turf = get_turf(src)
	// Is our turf completely full of water?
	// If the turf is raised, it needs less water to be full; if the turf is lowered it needs more.
	if (source_turf.check_fluid_depth(FLUID_DEEP))
		// Can't breathe if there's nothing but water!
		return FALSE
	return TRUE

/obj/item/clothing/mask/gas/examine(mob/user, distance)
	. = ..()
	if(clogged)
		to_chat(user, "<span class='warning'>The intakes are clogged with [clogged]!</span>")

/obj/item/clothing/mask/gas/attack_self(mob/user)
	if(clogged)
		user.visible_message("<span class='notice'>\The [user] begins unclogging the intakes of \the [src].</span>")
		if(do_after(user, 10 SECONDS, target = src) && clogged)
			user.visible_message("<span class='notice'>\The [user] has unclogged \the [src].</span>")
			clogged = FALSE
		return
	. = ..()

/obj/item/clothing/mask/gas/filters_water()
	return (filter_water && !clogged)

/obj/item/clothing/mask/gas/aquabreather
	name = "aquabreather"
	desc = "A compact CO2 scrubber and breathing apparatus that draws oxygen from water."
	//icon = 'icons/clothing/mask/gas_mask_half.dmi'
	icon_state = "gas_mask_half"
	filter_water = TRUE
	flags = MASKCOVERSMOUTH | MASKINTERNALS
	w_class = SIZE_SMALL

	var/hanging = 0
	item_action_types = list(/datum/action/item_action/hands_free/adjust_aquabreather)

/datum/action/item_action/hands_free/adjust_aquabreather
	name = "Adjust mask"

/obj/item/clothing/mask/gas/aquabreather/attack_self()
	if(!usr.incapacitated())
		if(!hanging)
			hanging = !hanging
			gas_transfer_coefficient = 1 //gas is now escaping to the turf and vice versa
			flags &= ~(MASKCOVERSMOUTH | MASKINTERNALS)
			icon_state = "[initial(icon_state)]down"
			to_chat(usr, "Your mask is now hanging on your neck.")

		else
			hanging = !hanging
			gas_transfer_coefficient = 0.10
			flags |= MASKCOVERSMOUTH | MASKINTERNALS
			icon_state = initial(icon_state)
			to_chat(usr, "You pull the mask up to cover your face.")
		update_inv_mob()
		update_item_actions()

/mob/living/can_drown()
	if(internal)
		return FALSE
	var/obj/item/clothing/mask/mask = get_equipped_item(SLOT_WEAR_MASK)
	if(istype(mask) && mask.filters_water())
		return FALSE
	return TRUE

/mob/living/carbon/human/can_drown()
	if(!..())
		return FALSE
	var/obj/item/organ/internal/lungs/L = organs_by_name[O_LUNGS]
	return (!L || L.can_drown())

mob/proc/can_overcome_gravity()
	return FALSE

//Swimming and floating
/atom/movable/proc/can_float()
	return FALSE

/mob/living/can_float()
	return !is_physically_disabled()

/mob/living/simple_animal/can_float()
	return is_aquatic

/mob/living/carbon/human/can_float()
	return species.can_float(src)

/mob/living/silicon/can_float()
	return FALSE //If they can fly otherwise it will be checked first

/mob/proc/is_physically_disabled()
	return IsWeaken() || IsStun()

//Used for swimming
/datum/species/proc/can_float(mob/living/human/H)
	if(!H.is_physically_disabled())
		return TRUE //We could tie it to stamina
	return FALSE

/mob/living/carbon/human/can_overcome_gravity()
	//First do species check
	if(species && species.can_overcome_gravity(src))
		return 1

	var/turf/T = loc
	var/depth = T.get_fluid_depth()

	if(depth >= FLUID_MAX_DEPTH)
		if(can_float()) // aquatic check basicly
			return 1

	else if(depth < FLUID_OVER_MOB_HEAD) // 300
		for(var/obj/structure/S in loc)
			if(S.climbable)
				return 1

	return 0

/datum/species/proc/can_overcome_gravity(mob/living/human/H)
	return FALSE

/mob/proc/handle_drowning()
	return FALSE

/mob/living/handle_drowning()
	if(!can_drown() || !loc?.is_flooded(lying || crawling))
		return FALSE
	var/turf/T = get_turf(src)
	if(!(lying || crawling) && can_overcome_gravity())
		return FALSE
	if(prob(5))
		var/datum/reagents/inhaled = get_inhaled_reagents()
		var/datum/reagents/ingested = get_ingested_reagents()
		to_chat(src, "<span class='danger'>You choke and splutter as you inhale [T.get_fluid_name()]!</span>")
		var/inhale_amount = 0
		if(inhaled)
			inhale_amount = rand(2,5)
			T.reagents?.trans_to(inhaled, min(T.reagents.total_volume, inhale_amount))
		if(ingested)
			var/ingest_amount = 5 - inhale_amount
			reagents?.trans_to(ingested, min(T.reagents.total_volume, ingest_amount))

	T.show_bubbles()
	return TRUE // Presumably chemical smoke can't be breathed while you're underwater.

/obj/item/organ/internal/lungs/proc/can_drown()
	return !has_gills || is_bruised()

/mob/living/proc/get_ingested_reagents()
	RETURN_TYPE(/datum/reagents)
	return reagents

/mob/living/proc/get_inhaled_reagents()
	RETURN_TYPE(/datum/reagents)
	return reagents

/mob/living/carbon/human/get_ingested_reagents()
	if(!should_have_organ(O_LIVER) || !should_have_organ(O_KIDNEYS)) // there is no stomach organ
		return
	return reagents

/mob/living/carbon/human/get_inhaled_reagents()
	if(!should_have_organ(O_LUNGS))
		return
	return reagents
