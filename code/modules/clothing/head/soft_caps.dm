/obj/item/clothing/head/soft
	name = "cargo cap"
	desc = "It's a baseball hat in a tasteless yellow color."
	icon_state = "cargosoft"
	flags = HEADCOVERSEYES
	item_state = "helmet"
	item_color = "cargo"
	var/flipped = 0
	siemens_coefficient = 0.9
	body_parts_covered = 0

	rag_color_to_give = COLOR_YELLOW

/obj/item/clothing/head/soft/dropped()
	src.icon_state = "[item_color]soft"
	src.flipped=0
	..()

/obj/item/clothing/head/soft/verb/flip()
	set category = "Object"
	set name = "Flip cap"
	set src in usr
	if(usr.canmove && !usr.stat && !usr.restrained())
		src.flipped = !src.flipped
		if(src.flipped)
			icon_state = "[item_color]soft_flipped"
			to_chat(usr, "You flip the hat backwards.")
		else
			icon_state = "[item_color]soft"
			to_chat(usr, "You flip the hat back in normal position.")
		usr.update_inv_head()	//so our mob-overlays update

/obj/item/clothing/head/soft/red
	name = "red cap"
	desc = "It's a baseball hat in a tasteless red color."
	icon_state = "redsoft"
	item_color = "red"

	rag_color_to_give = COLOR_RED

/obj/item/clothing/head/soft/blue
	name = "blue cap"
	desc = "It's a baseball hat in a tasteless blue color."
	icon_state = "bluesoft"
	item_color = "blue"

	rag_color_to_give = COLOR_BLUE

/obj/item/clothing/head/soft/green
	name = "green cap"
	desc = "It's a baseball hat in a tasteless green color."
	icon_state = "greensoft"
	item_color = "green"

	rag_color_to_give = COLOR_GREEN

/obj/item/clothing/head/soft/yellow
	name = "yellow cap"
	desc = "It's a baseball hat in a tasteless yellow color."
	icon_state = "yellowsoft"
	item_color = "yellow"

	rag_color_to_give = COLOR_YELLOW

/obj/item/clothing/head/soft/grey
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey color."
	icon_state = "greysoft"
	item_color = "grey"

	rag_color_to_give = COLOR_GREY

/obj/item/clothing/head/soft/orange
	name = "orange cap"
	desc = "It's a baseball hat in a tasteless orange color."
	icon_state = "orangesoft"
	item_color = "orange"

	rag_color_to_give = COLOR_ORANGE

/obj/item/clothing/head/soft/mime
	name = "white cap"
	desc = "It's a baseball hat in a tasteless white color."
	icon_state = "mimesoft"
	item_color = "mime"

	rag_color_to_give = COLOR_WHITE

/obj/item/clothing/head/soft/purple
	name = "purple cap"
	desc = "It's a baseball hat in a tasteless purple color."
	icon_state = "purplesoft"
	item_color = "purple"

	rag_color_to_give = COLOR_PURPLE

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

	rag_color_to_give = COLOR_RED

/obj/item/clothing/head/soft/sec/corp
	name = "corporate security cap"
	desc = "It's baseball hat in corporate colors."
	icon_state = "corpsoft"
	item_color = "corp"

	rag_color_to_give = COLOR_BLUE

/obj/item/clothing/head/soft/trash
	name = "trash cap"
	desc = "It's baseball hat."
	icon_state = "trashsoft"
	item_color = "trash"

	rag_color_to_give = COLOR_BLACK

/obj/item/clothing/head/soft/janitor
	name = "janitor cap"
	desc = "It's janitor hat."
	icon_state = "janitorsoft"
	item_color = "janitor"

	rag_color_to_give = COLOR_PURPLE