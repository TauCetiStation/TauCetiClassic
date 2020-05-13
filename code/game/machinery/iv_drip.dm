/obj/machinery/iv_drip
	name = "IV drip"
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "iv_drip"
	anchored = 0
	density = 0
	interact_offline = TRUE
	var/mob/living/carbon/human/attached = null
	var/mode = 1 // 1 is injecting, 0 is taking blood.
	var/obj/item/weapon/reagent_containers/beaker = null


/obj/machinery/iv_drip/atom_init()
	. = ..()
	update_icon()

/obj/machinery/iv_drip/update_icon()
	if(attached)
		if(mode)
			icon_state = "injecting"
		else
			icon_state = "donating"
	else
		if(mode)
			icon_state = "injectidle"
		else
			icon_state = "donateidle"

	cut_overlays()

	if(beaker)
		if(attached)
			add_overlay("beakeractive")
		else
			add_overlay("beakeridle")
		if(beaker.reagents.total_volume)
			var/image/filling = image('icons/obj/iv_drip.dmi', src, "reagent")

			var/percent = round((beaker.reagents.total_volume / beaker.volume) * 100)
			switch(percent)
				if(0 to 9)		filling.icon_state = "reagent0"
				if(10 to 24) 	filling.icon_state = "reagent10"
				if(25 to 49)	filling.icon_state = "reagent25"
				if(50 to 74)	filling.icon_state = "reagent50"
				if(75 to 79)	filling.icon_state = "reagent75"
				if(80 to 90)	filling.icon_state = "reagent80"
				if(91 to INFINITY)	filling.icon_state = "reagent100"

			filling.icon += mix_color_from_reagents(beaker.reagents.reagent_list)
			add_overlay(filling)

/obj/machinery/iv_drip/MouseDrop(over_object, src_location, over_location)
	..()
	if(!iscarbon(usr) && !isrobot(usr))
		return
	if(attached)
		visible_message("[src.attached] is detached from \the [src]")
		src.attached = null
		src.update_icon()
		return

	if(in_range(src, usr) && ishuman(over_object) && get_dist(over_object, src) <= 1)
		visible_message("[usr] attaches \the [src] to \the [over_object].")
		src.attached = over_object
		src.update_icon()


/obj/machinery/iv_drip/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/reagent_containers))
		if(!isnull(src.beaker))
			to_chat(user, "There is already a reagent container loaded!")
			return

		user.drop_item()
		W.loc = src
		src.beaker = W
		to_chat(user, "You attach \the [W] to \the [src].")
		src.update_icon()
		return
	else
		return ..()


/obj/machinery/iv_drip/process()
	//set background = 1

	if(src.attached)

		if(!(get_dist(src, src.attached) <= 1 && isturf(src.attached.loc)))
			visible_message("The needle is ripped out of [src.attached], doesn't that hurt?")
			src.attached:apply_damage(3, BRUTE, pick(BP_R_ARM , BP_L_ARM))
			src.attached = null
			src.update_icon()
			return

	if(src.attached && src.beaker)
		// Give blood
		if(mode)
			if(src.beaker.volume > 0)
				var/transfer_amount = REAGENTS_METABOLISM
				if(istype(src.beaker, /obj/item/weapon/reagent_containers/blood))
					// speed up transfer on blood packs
					transfer_amount = 4
				src.beaker.reagents.trans_to(src.attached, transfer_amount)
				update_icon()

		// Take blood
		else
			var/amount = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			amount = min(amount, 4)
			// If the beaker is full, ping
			if(amount == 0)
				if(prob(5)) visible_message("\The [src] pings.")
				return

			var/mob/living/carbon/human/T = attached

			if(!istype(T)) return
			if(!T.dna)
				return
			if(NOCLONE in T.mutations)
				return

			if(T.species && T.species.flags[NO_BLOOD])
				return

			// If the human is losing too much blood, beep.
			if(T.vessel.get_reagent_amount("blood") < BLOOD_VOLUME_SAFE) if(prob(5))
				visible_message("\The [src] beeps loudly.")

			var/datum/reagent/B = T.take_blood(beaker,amount)

			if (B)
				beaker.reagents.reagent_list |= B
				beaker.reagents.update_total()
				beaker.on_reagent_change()
				beaker.reagents.handle_reactions()
				update_icon()

/obj/machinery/iv_drip/attack_ai(mob/user)
	if(IsAdminGhost(user))
		return ..()

/obj/machinery/iv_drip/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(beaker)
		beaker.loc = get_turf(src)
		beaker = null
		update_icon()

/obj/machinery/iv_drip/verb/toggle_mode()
	set name = "Toggle Mode"
	set category = "Object"
	set src in oview(1)

	if(isliving(usr) && usr.stat != DEAD)
		mode = !mode
		to_chat(usr, "The IV drip is now [mode ? "injecting" : "taking blood"].")

/obj/machinery/iv_drip/examine(mob/user)
	..()
	if(src in oview(2, user))
		to_chat(user, "The IV drip is [mode ? "injecting" : "taking blood"].")

		if(beaker)
			if(beaker.reagents && beaker.reagents.reagent_list.len)
				to_chat(user, "<span class='notice'>Attached is \a [beaker] with [beaker.reagents.total_volume] units of liquid.</span>")
			else
				to_chat(user, "<span class='notice'>Attached is an empty [beaker].</span>")
		else
			to_chat(user, "<span class='notice'>No chemicals are attached.</span>")

		to_chat(user, "<span class='notice'>[attached ? attached : "No one"] is attached.</span>")


/obj/machinery/artifical_ventilation
	name = "artificial ventilation machine"
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "av_idle"
	desc = "This is an Artificial Ventillation machine that supports breathing while lungs is broken."
	anchored = FALSE
	density = FALSE
	interact_offline = TRUE
	var/mob/living/carbon/human/attached = null

/obj/machinery/artifical_ventilation/atom_init()
	. = ..()
	update_icon()

/obj/machinery/artifical_ventilation/Destroy()
	if(attached)
		REMOVE_TRAIT(attached, TRAIT_AV, LIFE_ASSIST_MACHINES_TRAIT)
		attached = null
	return ..()

/obj/machinery/artifical_ventilation/update_icon()
	if(attached)
		icon_state = "av_ventilating"
	else
		icon_state = "av_idle"

/obj/machinery/artifical_ventilation/MouseDrop(over_object, src_location, over_location)
	..()
	if(!iscarbon(usr) && !isrobot(usr))
		return
	if(!in_range(src, usr) || !in_range(over_object, src))
		return
	src.AddComponent(/datum/component/bounded, over_object, 0, 1, CALLBACK(src, .proc/av_resolve_stranded))
	if(attached)
		visible_message("[attached] is detached from \the [src]")
		REMOVE_TRAIT(attached, TRAIT_AV, LIFE_ASSIST_MACHINES_TRAIT)
		attached = null
		update_icon()
	else if(ishuman(over_object))
		visible_message("[usr] attaches \the [src] to \the [over_object].")
		attached = over_object
		ADD_TRAIT(attached, TRAIT_AV, LIFE_ASSIST_MACHINES_TRAIT)
		update_icon()

/obj/machinery/artifical_ventilation/proc/detach(mob/living/carbon/human/attached)
	visible_message("The tube is ripped out of [attached]'s lungs, doesn't that hurt?")
	attached.apply_damage(10, BRUTE, BP_CHEST)
	REMOVE_TRAIT(attached, TRAIT_AV, LIFE_ASSIST_MACHINES_TRAIT)
	attached = null
	update_icon()
	qdel(GetComponent(/datum/component/bounded))


/obj/machinery/artifical_ventilation/proc/av_resolve_stranded(datum/component/bounded/bounds)
	if(get_dist(bounds.bound_to, src) == 2 && !anchored)
		step_towards(src, bounds.bound_to)
		var/dist = get_dist(src, get_turf(bounds.bound_to))
		if(dist >= bounds.min_dist || dist <= bounds.max_dist)
			return TRUE
	var/obj/machinery/artifical_ventilation/AV = src
	AV.detach(bounds.bound_to)
	return TRUE


/obj/machinery/artifical_ventilation/process()
	if(attached)
		var/datum/gas_mixture/env = loc.return_air()
		if(env.return_pressure() > (ONE_ATMOSPHERE - 20))
			if((env.gas["oxygen"] / env.total_moles) > 0.10)
				if(!HAS_TRAIT(attached, TRAIT_AV))
					ADD_TRAIT(attached, TRAIT_AV, LIFE_ASSIST_MACHINES_TRAIT)
			else
				if(HAS_TRAIT(attached, TRAIT_AV))
					REMOVE_TRAIT(attached, TRAIT_AV, LIFE_ASSIST_MACHINES_TRAIT)
		else
			if(HAS_TRAIT(attached, TRAIT_AV))
				REMOVE_TRAIT(attached, TRAIT_AV, LIFE_ASSIST_MACHINES_TRAIT)
	return


/obj/machinery/artifical_ventilation/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>[attached ? attached : "No one"] is attached.</span>")


/obj/machinery/cardiopulmonary_bypass
	name = "cardiopulmonary bypass machine"
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "cpb_idle"
	desc = "This is an Cardiopulmonary Bypass machine that temporarily takes over the function of the heart"
	anchored = FALSE
	density = TRUE
	interact_offline = TRUE
	var/mob/living/carbon/human/attached = null

/obj/machinery/cardiopulmonary_bypass/atom_init()
	. = ..()
	update_icon()

/obj/machinery/cardiopulmonary_bypass/Destroy()
	if(attached)
		REMOVE_TRAIT(attached, TRAIT_CPB, LIFE_ASSIST_MACHINES_TRAIT)
		attached = null
	return ..()

/obj/machinery/cardiopulmonary_bypass/update_icon()
	if(attached)
		icon_state = "cpb_pumping"
	else
		icon_state = "cpb_idle"

/obj/machinery/cardiopulmonary_bypass/MouseDrop(over_object, src_location, over_location)
	..()
	if(!iscarbon(usr) && !isrobot(usr))
		return
	if(!in_range(src, usr) || !in_range(over_object, src))
		return
	src.AddComponent(/datum/component/bounded, over_object, 0, 1, CALLBACK(src, .proc/cpb_resolve_stranded))
	if(attached)
		visible_message("[attached] is detached from \the [src]")
		REMOVE_TRAIT(attached, TRAIT_CPB, LIFE_ASSIST_MACHINES_TRAIT)
		attached = null
		update_icon()
	else if(ishuman(over_object))
		visible_message("[usr] attaches \the [src] to \the [over_object].")
		attached = over_object
		update_icon()
		ADD_TRAIT(attached, TRAIT_CPB, LIFE_ASSIST_MACHINES_TRAIT)

/obj/machinery/cardiopulmonary_bypass/proc/detach(mob/living/carbon/human/attached)
	visible_message("The tubes is ripped out of [attached]'s heart, doesn't that hurt?")
	attached.apply_damage(15, BRUTE, BP_CHEST)
	REMOVE_TRAIT(attached, TRAIT_CPB, LIFE_ASSIST_MACHINES_TRAIT)
	attached = null
	update_icon()
	qdel(GetComponent(/datum/component/bounded))


/obj/machinery/cardiopulmonary_bypass/proc/cpb_resolve_stranded(datum/component/bounded/bounds)
	if(get_dist(bounds.bound_to, src) == 2 && !anchored)
		step_towards(src, bounds.bound_to)
		var/dist = get_dist(src, get_turf(bounds.bound_to))
		if(dist >= bounds.min_dist || dist <= bounds.max_dist)
			return TRUE
	var/obj/machinery/artifical_ventilation/CPB = src
	CPB.detach(bounds.bound_to)
	return TRUE

/obj/machinery/cardiopulmonary_bypass/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>[attached ? attached : "No one"] is attached.</span>")