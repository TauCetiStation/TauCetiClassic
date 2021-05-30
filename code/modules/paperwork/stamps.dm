/obj/item/weapon/stamp
	name = "rubber stamp"
	desc = "A rubber stamp for stamping important documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-qm"
	item_state = "stamp"
	throwforce = 0
	w_class = ITEM_SIZE_TINY
	throw_speed = 7
	throw_range = 15
	m_amt = 60
	hitsound = list('sound/effects/stamp.ogg') //taken from Baystation build
	item_color = "cargo"
	attack_verb = list("stamped")
	var/stamp_message = "Stamp"
	var/stamp_color = "#a23e3e"
	var/stamp_border = "#660000"
	var/big_stamp = FALSE

/obj/item/weapon/stamp/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"
	item_color = "captain"
	stamp_message = "Captain"
	stamp_color = "#3681bb"
	stamp_border = "#1f66a0"
	big_stamp = TRUE

/obj/item/weapon/stamp/captain/atom_init()
	. = ..()
	stamp_message = "[station_name()]"

/obj/item/weapon/stamp/hop
	name = "head of personnel's rubber stamp"
	icon_state = "stamp-hop"
	item_color = "hop"
	stamp_message = "Head of Personnel"
	stamp_color = "#6ec0ea"
	stamp_border = "#1f66a0"

/obj/item/weapon/stamp/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"
	item_color = "hosred"
	stamp_message = "Head of Security"
	stamp_color = "#cc0000"
	stamp_border = "#990000"

/obj/item/weapon/stamp/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"
	item_color = "chief"
	stamp_message = "Chief Engineer"
	stamp_color = "#ffcc00"
	stamp_border = "#cc9900"

/obj/item/weapon/stamp/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"
	item_color = "director"
	stamp_message = "Research Director"
	stamp_color = "#9361b5"
	stamp_border = "#7f4ba2"

/obj/item/weapon/stamp/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"
	item_color = "cmo"
	stamp_message = "Chief Medical Officer"
	stamp_color = "#00cccc"
	stamp_border = "#3399ff"

/obj/item/weapon/stamp/qm
	name = "quartermaster's rubber stamp"
	item_color = "qm"
	stamp_message = "Quartermaster"

/obj/item/weapon/stamp/approve
	name = "APPROVED rubber stamp"
	icon_state = "stamp-approve"
	item_color = "greencoat"
	stamp_message = "APPROVED"
	stamp_color = "#007b00"
	stamp_border = "#1d5215"
	big_stamp = TRUE

/obj/item/weapon/stamp/denied
	name = "DENIED rubber stamp"
	icon_state = "stamp-deny"
	item_color = "redcoat"
	stamp_message = "DENIED"
	stamp_color = "#a23e3e"
	stamp_border = "#660000"
	big_stamp = TRUE

/obj/item/weapon/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"
	item_color = "clown"
	stamp_message = "HONK!"
	stamp_color = "#ff99cc"
	stamp_border = "#ff66cc"
	big_stamp = TRUE

/obj/item/weapon/stamp/internalaffairs
	name = "internal affairs rubber stamp"
	icon_state = "stamp-intaff"
	item_color = "intaff"
	stamp_message = "Internal Affairs"
	stamp_color = "black"
	stamp_border = "black"
	big_stamp = TRUE

/obj/item/weapon/stamp/centcomm
	name = "centcomm rubber stamp"
	icon_state = "stamp-cent"
	item_color = "centcomm"
	stamp_message = "Central Command"
	stamp_color = "#006600"
	stamp_border = "#174111"
	big_stamp = TRUE

/obj/item/weapon/stamp/fakecentcomm
	name = "cantcom rubber stamp"
	icon_state = "stamp-fakecentcom"
	item_color = "fakecentcom"
	stamp_message = "Central Compound"
	stamp_color = "#006600"
	stamp_border = "#006600"
	big_stamp = TRUE

/obj/item/weapon/stamp/syndicate
	name = "syndicate rubber stamp"
	icon_state = "stamp-syndicate"
	item_color = "syndicate"
	stamp_message = "Syndicate Command"
	stamp_color = "#990000"
	stamp_border = "#ff3300"
	big_stamp = TRUE

/obj/item/weapon/stamp/cargo_industries
	name = "cargo industries rubber stamp"
	icon_state = "stamp-cargo-industries"
	stamp_message = "Cargo Industries"
	stamp_color = "#a23e3e"
	stamp_border = "#660000"
	big_stamp = TRUE

/obj/item/weapon/stamp/velocity
	name = "velocity rubber stamp"
	icon_state = "stamp-velocity"
	stamp_message = "NTS Velocity"
	stamp_color = "#999999"
	stamp_border = "#257cc3"
	big_stamp = TRUE

// Syndicate stamp to forge documents.
/obj/item/weapon/stamp/chameleon/attack_self(mob/user)

	var/list/stamp_types = typesof(/obj/item/weapon/stamp) - src.type // Get all stamp types except our own
	var/list/stamps = list()

	// Generate them into a list
	for(var/stamp_type in stamp_types)
		var/obj/item/weapon/stamp/S = new stamp_type
		stamps[capitalize(S.name)] = S

	var/list/show_stamps = sortList(stamps) // the list that will be shown to the user to pick from

	var/input_stamp = input(user, "Choose a stamp to disguise as.", "Choose a stamp.") as null|anything in show_stamps

	if(user && (src in user.contents))

		var/obj/item/weapon/stamp/chosen_stamp = stamps[capitalize(input_stamp)]

		if(chosen_stamp)
			name = chosen_stamp.name
			icon_state = chosen_stamp.icon_state
			stamp_message = chosen_stamp.stamp_message
			stamp_color = chosen_stamp.stamp_color
			stamp_border = chosen_stamp.stamp_border
			big_stamp = chosen_stamp.big_stamp

/obj/item/weapon/stamp/proc/stamp_paper(obj/item/weapon/paper/P, stamp_text)
	if (P.stamp_text && P.stamp_text != "")
		P.stamp_text += "<br>"

	var/message = stamp_text ? stamp_text : stamp_message
	if (big_stamp)
		P.stamp_text += "<div style=\"margin-top:20px;\"><font size=\"5\"><div style=\"border-color:[stamp_border];color:[stamp_color];display:inline;border-width:5px;border-style:double;padding:3px\">[message]</div></font></div>"
	else
		P.stamp_text += "<div style=\"margin-top:20px;margin-left:3px\"><font size=\"5\"><div style=\"border-color:[stamp_border];color:[stamp_color];display:inline;border-width:2px;border-style:solid;padding:3px\">[message]</div></font></div>"

	var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
	var/x
	var/y

	if(big_stamp)
		x = rand(-2, 0)
		y = rand(-1, 2)
	else
		x = rand(-2, 2)
		y = rand(-3, 2)

	LAZYADD(P.offset_x, x)
	LAZYADD(P.offset_y, y)

	stampoverlay.pixel_x = x
	stampoverlay.pixel_y = y

	LAZYADD(P.ico, "paper_[icon_state]")
	stampoverlay.icon_state = "paper_[icon_state]"

	LAZYADD(P.stamped, type)
	P.add_overlay(stampoverlay)

/obj/item/weapon/stamp/attack_paw(mob/user)
	return attack_hand(user)
