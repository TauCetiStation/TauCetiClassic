/datum/action/item_action/hands_free/connect_tank
	name = "Adjust mask"
	button_icon_state = "internal"
	toggleable = TRUE
	action_type = AB_INNATE

/datum/action/item_action/hands_free/connect_tank/Activate()
	if(!owner.wear_mask && !owner.incapacitated())
		return
	var/obj/item/clothing/mask/breath/breath_mask = owner.wear_mask
	breath_mask.toggle_breath(owner)
	if(breath_mask.attached_tank) // check, we just hangling mask or activate it
		active = TRUE

	UpdateButtonIcon()

/datum/action/item_action/hands_free/connect_tank/Deactivate()
	if(!owner.wear_mask && !owner.incapacitated())
		return
	var/obj/item/clothing/mask/breath/breath_mask = owner.wear_mask
	breath_mask.toggle_breath(owner)
	if(!breath_mask.attached_tank)
		active = FALSE
	UpdateButtonIcon()

/obj/item/clothing/mask/breath
	desc = "A close-fitting mask that can be connected to an air supply."
	name = "breath mask"
	icon_state = "breath"
	item_state = "b_mask"
	flags = MASKCOVERSMOUTH | MASKINTERNALS
	body_parts_covered = 0
	w_class = SIZE_TINY
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50
	var/obj/item/weapon/tank/attached_tank = null
	var/active = FALSE
	var/adjustible = TRUE
	item_action_types = list(/datum/action/item_action/hands_free/connect_tank)

/obj/item/clothing/mask/breath/Destroy()
	. = ..()
	detach_tank()

/obj/item/clothing/mask/breath/equipped(mob/user, slot)
	. = ..()
	if(src == user.wear_mask)
		toggle_breath(user)

/obj/item/clothing/mask/breath/dropped(mob/user)
	. = ..()
	if(active)
		toggle_breath(user)
		update_action_icons(user, FALSE)

/obj/item/clothing/mask/breath/proc/toggle_breath(mob/user = usr)
	active = !active
	if(active)
		connect_tank(user)
	else
		detach_tank()
	if(adjustible)
		update_hanging()
	update_item_actions()

/obj/item/clothing/mask/breath/proc/update_hanging()
	if(!adjustible) // if mask on face but pushed down
		return

	if(active)
		gas_transfer_coefficient = 0.10
		flags |= MASKCOVERSMOUTH | MASKINTERNALS
		icon_state = "[initial(icon_state)]_UP"
		to_chat(usr, "You pull the mask up to cover your face.")
	else
		gas_transfer_coefficient = 1 //gas is now escaping to the turf and vice versa
		flags &= ~(MASKCOVERSMOUTH | MASKINTERNALS)
		icon_state = initial(icon_state)
		to_chat(usr, "Your mask is now hanging on your neck.")

	update_inv_mob()

/obj/item/clothing/mask/breath/proc/connect_tank(mob/user)
	var/list/tanks = list()
	for(var/obj/item/I in user.contents)
		if(istank(I))
			tanks[I] += I.appearance

	if(!length(tanks))
		to_chat(user, "You didn`t have some tank.")
		return FALSE

	var/choose

	if(tanks.len == 1)
		choose = tanks[1]
	else
		choose = show_radial_menu(user, user, tanks)

	if(!choose)
		to_chat(user, "You didn`t choose some tank.")
		return FALSE

	attached_tank = choose
	open_internals()
	RegisterSignals(attached_tank, list(COMSIG_PARENT_QDELETING, COMSIG_ITEM_DROPPED), PROC_REF(drop_detach_tank), override = TRUE) //override = true, to prevert stuck trace error
	return TRUE

/obj/item/clothing/mask/breath/proc/drop_detach_tank(obj/source)
	if(!iscarbon(loc))
		return
	var/mob/living/carbon/user = loc // mask loc
	if(source.loc == user)
		return
	if(attached_tank && active)
		toggle_breath(user)

/obj/item/clothing/mask/breath/proc/detach_tank()
	if(attached_tank)
		close_internals()
		return TRUE
	return FALSE

/obj/item/clothing/mask/breath/proc/close_internals()
	if(!iscarbon(loc))
		return
	var/mob/living/carbon/C = loc
	C.internal = null	// refactor this and delete
	to_chat(usr, "<span class='notice'>[bicon(attached_tank)]You close the tank release valve.</span>")
	var/internalsound = 'sound/misc/internaloff.ogg'
	UnregisterSignal(attached_tank, list(COMSIG_PARENT_QDELETING, COMSIG_ITEM_DROPPED)) //crash stuck trace we didn`t  off signal trigger
	update_action_icons(C, FALSE)
	attached_tank = null
	if(ishuman(C)) // Because only human can wear a spacesuit
		var/mob/living/carbon/human/H = C
		if(istype(H.head, /obj/item/clothing/head/helmet/space) && istype(H.wear_suit, /obj/item/clothing/suit/space))
			internalsound = 'sound/misc/riginternaloff.ogg'
	playsound(src, internalsound, VOL_EFFECTS_MASTER, null, FALSE, null, -5)

/obj/item/clothing/mask/breath/proc/open_internals()
	if(!iscarbon(loc))
		return
	var/mob/living/carbon/C = loc
	if(!(flags & MASKINTERNALS))
		update_hanging()
	C.internal = attached_tank	// refactor this and delete
	update_action_icons(C, TRUE)
	to_chat(usr, "<span class='notice'>[bicon(attached_tank)]You open \the [attached_tank] valve.</span>")
	var/internalsound = 'sound/misc/internalon.ogg'
	if(ishuman(C)) // Because only human can wear a spacesuit
		var/mob/living/carbon/human/H = C
		if(istype(H.head, /obj/item/clothing/head/helmet/space) && istype(H.wear_suit, /obj/item/clothing/suit/space))
			internalsound = 'sound/misc/riginternalon.ogg'
	playsound(src, internalsound, VOL_EFFECTS_MASTER, null, FALSE, null, -5)

/obj/item/clothing/mask/breath/proc/update_action_icons(mob/user, status)
	for(var/datum/action/item_action/hands_free/connect_tank/CT in user.actions)
		CT.active = status
		CT.UpdateButtonIcon()
	user.update_action_buttons()

/obj/item/clothing/mask/breath/medical
	desc = "A close-fitting sterile mask that can be connected to an air supply."
	name = "medical mask"
	icon_state = "medical"
	item_state = "m_mask"
	permeability_coefficient = 0.01
