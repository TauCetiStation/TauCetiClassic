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
	var/hanging = 0
	var/adjustible = TRUE
	item_action_types = list(/datum/action/item_action/hands_free/connect_tank)

/datum/action/item_action/hands_free/connect_tank
	name = "Adjust mask"
	button_icon_state = "internal"
	toggleable = TRUE
	action_type = AB_INNATE

/datum/action/item_action/hands_free/connect_tank/Activate()
	if(!owner.wear_mask)
		return

	var/obj/item/clothing/mask/breath/bmask = owner.wear_mask
	if(bmask.adjustible)
		bmask.update_hanging()
		bmask.update_inv_mob()

	var/list/tanks = list()
	for(var/obj/item/I in owner.contents)
		if(istank(I))
			tanks[I] += I.appearance

	if(!length(tanks))
		to_chat(owner, "You didn`t have some tank.")
		return

	var/choose

	if(tanks.len == 1)
		choose = tanks[1]
	else
		choose = show_radial_menu(owner, owner, tanks)

	if(!choose)
		to_chat(owner, "You didn`t choose some tank.")
		return

	var/obj/item/weapon/tank/tank = choose
	tank.toggle_internals()
	active = TRUE
	UpdateButtonIcon()

/datum/action/item_action/hands_free/connect_tank/Deactivate()
	var/obj/item/clothing/mask/breath/bmask = owner.wear_mask
	if(bmask?.adjustible)
		bmask.update_hanging()
		bmask.update_inv_mob()

	if(owner.internal)
		owner.internal.close_internals(owner)

	active = FALSE
	UpdateButtonIcon()

/obj/item/clothing/mask/breath/attack_self()
	var/mob/living/carbon/human/user = usr
	if(!user.incapacitated())
		if(adjustible)
			update_hanging()
			update_inv_mob()

		update_item_actions()

/obj/item/clothing/mask/breath/proc/update_hanging()
	if(!hanging)
		gas_transfer_coefficient = 1 //gas is now escaping to the turf and vice versa
		flags &= ~(MASKCOVERSMOUTH | MASKINTERNALS)
		icon_state = "[initial(icon_state)]down"
		to_chat(usr, "Your mask is now hanging on your neck.")

	else
		gas_transfer_coefficient = 0.10
		flags |= MASKCOVERSMOUTH | MASKINTERNALS
		icon_state = initial(icon_state)
		to_chat(usr, "You pull the mask up to cover your face.")

	hanging = !hanging

/obj/item/clothing/mask/breath/proc/detach_tank(mob/user)
	if(user.internal)
		user.internal.close_internals(user)
		update_action_icons(user)

/obj/item/clothing/mask/proc/update_action_icons(mob/user)
	for(var/datum/action/item_action/hands_free/connect_tank/CT in user.actions)
		if(CT.active)
			CT.active = FALSE
			CT.UpdateButtonIcon()
	user.update_action_buttons()

/obj/item/clothing/mask/breath/medical
	desc = "A close-fitting sterile mask that can be connected to an air supply."
	name = "medical mask"
	icon_state = "medical"
	item_state = "m_mask"
	permeability_coefficient = 0.01
