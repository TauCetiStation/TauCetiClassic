/obj/item/clothing/head/soft
	name = "cargo cap"
	desc = "It's a baseball hat in a tasteless yellow color."
	icon_state = "cargosoft"
	flags = HEADCOVERSEYES
	siemens_coefficient = 0.9
	body_parts_covered = 0
	dyed_type = DYED_SOFTCAP
	item_action_types = list(/datum/action/item_action/hands_free/flip_cap)

	var/flipped = FALSE
	var/cap_color = "cargo"

/datum/action/item_action/hands_free/flip_cap
	name = "Flip Cap"

/obj/item/clothing/head/soft/atom_init()
	. = ..()
	icon_state = "[cap_color]soft"

/obj/item/clothing/head/soft/wash_act(w_color)
	. = ..()
	var/obj/item/clothing/dye_type = get_dye_type(w_color)
	if(!dye_type)
		return

	var/obj/item/clothing/head/soft/S = dye_type

	cap_color = initial(S.cap_color)
	icon_state = "[cap_color][flipped ? "soft_flipped" : "soft"]"

/obj/item/clothing/head/soft/attack_self(mob/living/carbon/human/user)
	flipped = !flipped
	if(flipped)
		icon_state = "[cap_color]soft_flipped"
		to_chat(user, "You flip the hat backwards.")
	else
		icon_state = "[cap_color]soft"
		to_chat(user, "You flip the hat back in normal position.")

	update_inv_mob()
	update_item_actions()

/obj/item/clothing/head/soft/red
	name = "red cap"
	desc = "It's a baseball hat in a tasteless red color."
	icon_state = "redsoft"
	cap_color = "red"

/obj/item/clothing/head/soft/blue
	name = "blue cap"
	desc = "It's a baseball hat in a tasteless blue color."
	icon_state = "bluesoft"
	cap_color = "blue"

/obj/item/clothing/head/soft/green
	name = "green cap"
	desc = "It's a baseball hat in a tasteless green color."
	icon_state = "greensoft"
	cap_color = "green"

/obj/item/clothing/head/soft/yellow
	name = "yellow cap"
	desc = "It's a baseball hat in a tasteless yellow color."
	icon_state = "yellowsoft"
	cap_color = "yellow"

/obj/item/clothing/head/soft/grey
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey color."
	icon_state = "greysoft"
	cap_color = "grey"

/obj/item/clothing/head/soft/orange
	name = "orange cap"
	desc = "It's a baseball hat in a tasteless orange color."
	icon_state = "orangesoft"
	cap_color = "orange"

/obj/item/clothing/head/soft/mime
	name = "white cap"
	desc = "It's a baseball hat in a tasteless white color."
	icon_state = "mimesoft"
	cap_color = "mime"

/obj/item/clothing/head/soft/purple
	name = "purple cap"
	desc = "It's a baseball hat in a tasteless purple color."
	icon_state = "purplesoft"
	cap_color = "purple"

/obj/item/clothing/head/soft/rainbow
	name = "rainbow cap"
	desc = "It's a baseball hat in a bright rainbow of colors."
	icon_state = "rainbowsoft"
	cap_color = "rainbow"

/obj/item/clothing/head/soft/sec
	name = "security cap"
	desc = "It's baseball hat in tasteful red color."
	icon_state = "secsoft"
	cap_color = "sec"

/obj/item/clothing/head/soft/sec/corp
	name = "corporate security cap"
	desc = "It's baseball hat in corporate colors."
	icon_state = "corpsoft"
	cap_color = "corp"

/obj/item/clothing/head/soft/trash
	name = "trash cap"
	desc = "It's baseball hat."
	icon_state = "trashsoft"
	cap_color = "trash"

/obj/item/clothing/head/soft/janitor
	name = "janitor cap"
	desc = "It's janitor hat."
	icon_state = "janitorsoft"
	cap_color = "janitor"
	can_get_wet = FALSE

/obj/item/clothing/head/soft/nt_pmc_cap
	name = "NT PMC Cap"
	desc = "Dark cap used by the private security corporation. This one looks good."
	icon_state = "nt_pmcsoft"
	item_state = "necromancer"
	cap_color = "nt_pmc"

/obj/item/clothing/head/soft/paramed
	name = "first responder cap"
	desc = "It's first responder hat. Shows who's saving lives here."
	icon_state = "frsoft"
	cap_color = "fr"

/obj/item/clothing/head/soft/blueshield
	name = "blueshield cap"
	desc = "It's baseball hat in tasteful black color with blueshield insignia."
	icon_state = "blueshieldsoft"
	cap_color = "blueshield"
