/obj/item/clothing/head/soft
	name = "cargo cap"
	desc = "It's a baseball hat in a tasteless yellow color."
	icon_state = "cargosoft"
	flags = HEADCOVERSEYES
	colored_name = "colored cap"
	item_state = "helmet"
	item_color = "cargo"
	var/flipped = 0
	can_be_colored = TRUE
	siemens_coefficient = 0.9
	body_parts_covered = 0

/obj/item/clothing/head/soft/dropped()
	src.icon_state = "[item_color]"
	src.flipped=0
	..()

/obj/item/clothing/head/soft/verb/flip()
	set category = "Object"
	set name = "Flip cap"
	set src in usr
	if(!usr.incapacitated())
		src.flipped = !src.flipped
		if(src.flipped)
			icon_state = "[item_color]_flipped"
			to_chat(usr, "You flip the hat backwards.")
		else
			icon_state = "[item_color]"
			to_chat(usr, "You flip the hat back in normal position.")
		usr.update_inv_head()	//so our mob-overlays update

/obj/item/clothing/head/soft/color
	name = "white cap"
	desc = "It's a baseball hat in a tasteless white color."
	icon_state = "white"
	item_color = "white"

/obj/item/clothing/head/soft/color/red
	name = "red cap"
	desc = "It's a baseball hat in a tasteless red color."
	color = "#f63c45"

/obj/item/clothing/head/soft/color/blue
	name = "blue cap"
	desc = "It's a baseball hat in a tasteless blue color."
	color = "#4ca7fb"

/obj/item/clothing/head/soft/color/green
	name = "green cap"
	desc = "It's a baseball hat in a tasteless green color."
	color = "#59e663"

/obj/item/clothing/head/soft/color/yellow
	name = "yellow cap"
	desc = "It's a baseball hat in a tasteless yellow color."
	color = "#ffdb06"

/obj/item/clothing/head/soft/color/grey
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey color."
	color = "#d4d4d2"

/obj/item/clothing/head/soft/color/orange
	name = "orange cap"
	desc = "It's a baseball hat in a tasteless orange color."
	color = "#ff7314"

/obj/item/clothing/head/soft/color/purple
	name = "purple cap"
	desc = "It's a baseball hat in a tasteless purple color."
	color = "#b26bef"

/obj/item/clothing/head/soft/rainbow
	name = "rainbow cap"
	desc = "It's a baseball hat in a bright rainbow of colors."
	icon_state = "rainbowsoft"
	item_color = "rainbow"

/obj/item/clothing/head/soft/sec
	name = "security cap"
	desc = "It's baseball hat in tasteful red color."
	icon_state = "secsoft"
	item_color = "sec"

/obj/item/clothing/head/soft/sec/corp
	name = "corporate security cap"
	desc = "It's baseball hat in corporate colors."
	icon_state = "corpsoft"
	item_color = "corp"

/obj/item/clothing/head/soft/trash
	name = "trash cap"
	desc = "It's baseball hat."
	icon_state = "trashsoft"
	item_color = "trash"

/obj/item/clothing/head/soft/janitor
	name = "janitor cap"
	desc = "It's janitor hat."
	icon_state = "janitorsoft"
	item_color = "janitor"

/obj/item/clothing/head/soft/nt_pmc_cap
	name = "NT PMC Cap"
	desc = "Dark cap used by the private security corporation. This one looks good."
	icon_state = "nt_pmcsoft"
	item_state = "necromancer"
	item_color = "nt_pmc"

/obj/item/clothing/head/soft/paramed
	name = "first responder cap"
	desc = "It's first responder hat. Shows who's saving lives here."
	icon_state = "frsoft"
	item_color = "fr"
