/obj/item/clothing/head/soft
	name = "cargo cap"
	desc = "It's a baseball hat in a tasteless yellow color."
	icon_state = "cargosoft"
	flags = HEADCOVERSEYES
	inhand_state = "helmet"
	onmob_state = "cargo"
	var/flipped = 0
	siemens_coefficient = 0.9
	body_parts_covered = 0

/obj/item/clothing/head/soft/dropped()
	src.icon_state = "[onmob_state]soft"
	src.flipped=0
	..()

/obj/item/clothing/head/soft/verb/flip()
	set category = "Object"
	set name = "Flip cap"
	set src in usr
	if(usr.canmove && !usr.stat && !usr.restrained())
		src.flipped = !src.flipped
		if(src.flipped)
			icon_state = "[onmob_state]soft_flipped"
			to_chat(usr, "You flip the hat backwards.")
		else
			icon_state = "[onmob_state]soft"
			to_chat(usr, "You flip the hat back in normal position.")
		usr.update_inv_head()	//so our mob-overlays update

/obj/item/clothing/head/soft/red
	name = "red cap"
	desc = "It's a baseball hat in a tasteless red color."
	icon_state = "redsoft"
	onmob_state = "red"

/obj/item/clothing/head/soft/blue
	name = "blue cap"
	desc = "It's a baseball hat in a tasteless blue color."
	icon_state = "bluesoft"
	onmob_state = "blue"

/obj/item/clothing/head/soft/green
	name = "green cap"
	desc = "It's a baseball hat in a tasteless green color."
	icon_state = "greensoft"
	onmob_state = "green"

/obj/item/clothing/head/soft/yellow
	name = "yellow cap"
	desc = "It's a baseball hat in a tasteless yellow color."
	icon_state = "yellowsoft"
	onmob_state = "yellow"

/obj/item/clothing/head/soft/grey
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey color."
	icon_state = "greysoft"
	onmob_state = "grey"

/obj/item/clothing/head/soft/orange
	name = "orange cap"
	desc = "It's a baseball hat in a tasteless orange color."
	icon_state = "orangesoft"
	onmob_state = "orange"

/obj/item/clothing/head/soft/mime
	name = "white cap"
	desc = "It's a baseball hat in a tasteless white color."
	icon_state = "mimesoft"
	onmob_state = "mime"

/obj/item/clothing/head/soft/purple
	name = "purple cap"
	desc = "It's a baseball hat in a tasteless purple color."
	icon_state = "purplesoft"
	onmob_state = "purple"

/obj/item/clothing/head/soft/rainbow
	name = "rainbow cap"
	desc = "It's a baseball hat in a bright rainbow of colors."
	icon_state = "rainbowsoft"
	onmob_state = "rainbow"

/obj/item/clothing/head/soft/sec
	name = "security cap"
	desc = "It's baseball hat in tasteful red color."
	icon_state = "secsoft"
	onmob_state = "sec"

/obj/item/clothing/head/soft/sec/corp
	name = "corporate security cap"
	desc = "It's baseball hat in corporate colors."
	icon_state = "corpsoft"
	onmob_state = "corp"

/obj/item/clothing/head/soft/trash
	name = "trash cap"
	desc = "It's baseball hat."
	icon_state = "trashsoft"
	onmob_state = "trash"

/obj/item/clothing/head/soft/janitor
	name = "janitor cap"
	desc = "It's janitor hat."
	icon_state = "janitorsoft"
	onmob_state = "janitor"

/obj/item/clothing/head/soft/nt_pmc_cap
	name = "NT PMC Cap"
	desc = "Dark cap used by the private security corporation. This one looks good."
	icon_state = "nt_pmcsoft"
	inhand_state = "necromancer"
	onmob_state = "nt_pmc"
