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
	var/active = FALSE
	var/adjustible = TRUE
	item_action_types = list(/datum/action/item_action/hands_free/connect_tank)

/obj/item/clothing/mask/breath/atom_init()
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, PROC_REF(toggle_breath))

/obj/item/clothing/mask/breath/Destroy()
	. = ..()
	UnregisterSignal(src, COMSIG_ITEM_EQUIPPED)

/datum/action/item_action/hands_free/connect_tank
	name = "Adjust mask"
	button_icon_state = "internal"
	toggleable = TRUE
	action_type = AB_INNATE

/datum/action/item_action/hands_free/connect_tank/Activate()
	if(!owner.wear_mask)
		return
	var/obj/item/clothing/mask/breath/breath_mask = owner.wear_mask
	breath_mask.toggle_breath(src, owner)
	if(owner.internal)
		active = TRUE
	UpdateButtonIcon()

/datum/action/item_action/hands_free/connect_tank/Deactivate()
	if(!owner.wear_mask)
		return
	var/obj/item/clothing/mask/breath/breath_mask = owner.wear_mask
	breath_mask.toggle_breath(src, owner)
	if(!owner.internal)
		active = FALSE
	UpdateButtonIcon()

/obj/item/clothing/mask/breath/proc/toggle_breath(source, mob/user = usr)
	if(!user.incapacitated())
		if(src == user.wear_mask)
			if(adjustible) // if mask on face but pushed down
				update_hanging()
			if(!active)
				connect_tank(user)
			else
				detach_tank(user)

			update_item_actions()
			active = !active

/obj/item/clothing/mask/breath/proc/update_hanging()
	if(!active)
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

	var/obj/item/weapon/tank/tank = choose
	tank.toggle_internals()
	return TRUE

/obj/item/clothing/mask/breath/proc/detach_tank(mob/user)
	if(user.internal)
		user.internal.close_internals(user)
		return TRUE
	return FALSE

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
