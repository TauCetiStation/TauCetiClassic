/obj/machinery/life_assist
	anchored = FALSE
	density = FALSE
	interact_offline = TRUE
	var/mob/living/carbon/human/attached = null

	var/my_trait

	var/icon_state_attached
	var/icon_state_detached

/obj/machinery/life_assist/atom_init()
	. = ..()
	update_icon()

/obj/machinery/life_assist/Destroy()
	if(attached)
		detach()
	return ..()

/obj/machinery/life_assist/update_icon()
	if(attached)
		icon_state = icon_state_attached
	else
		icon_state = icon_state_detached

/obj/machinery/life_assist/proc/attach(mob/living/carbon/human/H)
	attached = H
	AddComponent(/datum/component/bounded, H, 0, 1, CALLBACK(src, .proc/resolve_stranded))
	visible_message("<span class='notice'>[usr] attaches \the [src] to \the [H].</span>")
	assist(H)
	update_icon()

/obj/machinery/life_assist/proc/detach(rip = FALSE)
	if(!rip)
		visible_message("<span class='notice'>[attached] is detached from \the [src]</span>")
	else
		visible_message("<span class='warning'>The tubes are ripped out of [attached], doesn't that hurt?</span>")
		attached.apply_damage(15, BRUTE, BP_CHEST)

	qdel(GetComponent(/datum/component/bounded))
	deassist(attached)
	attached = null
	update_icon()

// Add the LIFE_ASSIST trait, etc.
/obj/machinery/life_assist/proc/assist(mob/living/carbon/human/H)
	ADD_TRAIT(H, my_trait, LIFE_ASSIST_MACHINES_TRAIT)

// Remove the LIFE_ASSIST trait, etc.
/obj/machinery/life_assist/proc/deassist(mob/living/carbon/human/H)
	REMOVE_TRAIT(H, my_trait, LIFE_ASSIST_MACHINES_TRAIT)

/obj/machinery/life_assist/MouseDrop(over_object, src_location, over_location)
	..()
	if(!iscarbon(usr) && !isrobot(usr))
		return
	if(!(Adjacent(usr) && Adjacent(over_object) && usr.Adjacent(over_object)))
		return

	if(attached)
		detach()
	else if(ishuman(over_object))
		attach(over_object)

/obj/machinery/life_assist/proc/resolve_stranded(datum/component/bounded/bounds)
	if(get_dist(bounds.bound_to, src) == 2 && !anchored)
		step_towards(src, bounds.bound_to)
		var/dist = get_dist(src, get_turf(bounds.bound_to))
		if(dist >= bounds.min_dist && dist <= bounds.max_dist)
			return TRUE

	detach(rip = TRUE)
	return TRUE



/obj/machinery/life_assist/artificial_ventilation
	name = "artificial ventilation machine"
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "av_idle"
	desc = "This is an Artificial Ventillation machine that supports breathing while lungs is broken."

	icon_state_attached = "av_ventilating"
	icon_state_detached = "av_idle"

	var/obj/item/weapon/tank/holding

	my_trait = TRAIT_AV

/obj/machinery/life_assist/artificial_ventilation/update_icon()
	..()
	if(holding)
		add_overlay(holding.icon_state)
	else
		cut_overlays()

/obj/machinery/life_assist/artificial_ventilation/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/tank) && !istype(W, /obj/item/weapon/tank/jetpack))
		if(!(stat & BROKEN))
			if (holding || !user.drop_from_inventory(W, src))
				return
			var/obj/item/weapon/tank/T = W
			holding = T
			user.drop_from_inventory(holding, src)
			visible_message("<span class='notice'>[holding] is attached to \the [src]</span>")
			update_icon()

/obj/machinery/life_assist/artificial_ventilation/attack_hand(mob/user)
	if(holding)
		user.put_in_hands(holding)
		visible_message("<span class='notice'>[holding] is detached from \the [src]</span>")
		holding = null
		if(attached)
			var/attached_holder = attached
			detach(FALSE)
			attach(attached_holder)
			attached_holder = null
	update_icon()

/obj/machinery/life_assist/artificial_ventilation/attach(mob/living/carbon/human/H)
	..()
	if(holding)
		H.internal = holding
		if(H.internals)
			H.internals.icon_state = "internal1"
	update_icon()

/obj/machinery/life_assist/artificial_ventilation/detach(rip = FALSE)
	if(attached.internals)
		attached.internals.icon_state = "internal0"
	attached.internal = null
	..()

/obj/machinery/life_assist/cardiopulmonary_bypass
	name = "cardiopulmonary bypass machine"
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "cpb_idle"
	desc = "This is an Cardiopulmonary Bypass machine that temporarily takes over the function of the heart"

	density = TRUE

	icon_state_attached = "cpb_pumping"
	icon_state_detached = "cpb_idle"

	my_trait = TRAIT_CPB

/obj/machinery/life_assist/external_cooling_device
	name = "External Cooling Device"
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "cooler_idle"
	desc = "External Cooling Device rapidly cools down any connected machine. There are IPC-compatible jacks."

	density = TRUE

	icon_state_attached = "cooler_pumping"
	icon_state_detached = "cooler_idle"

	my_trait = TRAIT_COOLED
