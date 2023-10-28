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
	item_action_types = list(/datum/action/item_action/hands_free/adjust_mask)

/datum/action/item_action/hands_free/adjust_mask
	name = "Adjust mask"

/obj/item/clothing/mask/breath/attack_self()

	if(!usr.incapacitated())
		if(!src.hanging)
			src.hanging = !src.hanging
			gas_transfer_coefficient = 1 //gas is now escaping to the turf and vice versa
			flags &= ~(MASKCOVERSMOUTH | MASKINTERNALS)
			icon_state = "breathdown"
			to_chat(usr, "Your mask is now hanging on your neck.")

		else
			src.hanging = !src.hanging
			gas_transfer_coefficient = 0.10
			flags |= MASKCOVERSMOUTH | MASKINTERNALS
			icon_state = "breath"
			to_chat(usr, "You pull the mask up to cover your face.")
		update_inv_mob()
		update_item_actions()

/obj/item/clothing/mask/breath/medical
	desc = "A close-fitting sterile mask that can be connected to an air supply."
	name = "medical mask"
	icon_state = "m_mask"
	item_state = "m_mask"
	permeability_coefficient = 0.01
