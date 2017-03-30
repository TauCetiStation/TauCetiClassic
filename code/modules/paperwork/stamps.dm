/obj/item/weapon/stamp
	name = "rubber stamp"
	desc = "A rubber stamp for stamping important documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-qm"
	item_state = "stamp"
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	m_amt = 60
	item_color = "cargo"
	pressure_resistance = 2
	attack_verb = list("stamped")
	var/stamp_by_message = ""
	var/big_stamp = FALSE

/obj/item/weapon/stamp/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"
	item_color = "captain"
	big_stamp = TRUE

/obj/item/weapon/stamp/hop
	name = "head of personnel's rubber stamp"
	icon_state = "stamp-hop"
	item_color = "hop"

/obj/item/weapon/stamp/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"
	item_color = "hosred"

/obj/item/weapon/stamp/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"
	item_color = "chief"

/obj/item/weapon/stamp/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"
	item_color = "director"

/obj/item/weapon/stamp/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"
	item_color = "cmo"

/obj/item/weapon/stamp/denied
	name = "\improper DENIED rubber stamp"
	icon_state = "stamp-deny"
	item_color = "redcoat"

/obj/item/weapon/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"
	item_color = "clown"
	stamp_by_message = "strange pink stamp"

/obj/item/weapon/stamp/internalaffairs
	name = "internal affairs rubber stamp"
	icon_state = "stamp-intaff"
	item_color = "intaff"

/obj/item/weapon/stamp/centcomm
	name = "centcomm rubber stamp"
	icon_state = "stamp-cent"
	item_color = "centcomm"
	stamp_by_message = "Central Command Quantum Relay"
	big_stamp = TRUE

/obj/item/weapon/stamp/fakecentcomm
	name = "cantcom rubber stamp"
	icon_state = "stamp-fakecentcom"
	item_color = "fakecentcom"
	stamp_by_message = "Central Compound Quantum Relay"
	big_stamp = TRUE

/obj/item/weapon/stamp/syndicate
	name = "syndicate rubber stamp"
	icon_state = "stamp-syndicate"
	item_color = "syndicate"
	stamp_by_message = "Syndicate Command Interception Relay"
	big_stamp = TRUE

/obj/item/weapon/stamp/proc/stamp_paper(obj/item/weapon/paper/P, stamp_text, use_stamp_by_message = FALSE)
	P.stamp_text += (P.stamp_text == "" ? "<hr>" : "<br>")

	if(use_stamp_by_message)
		P.stamp_text += "<i>This paper has been stamped by the [stamp_by_message].</i>"
	else
		P.stamp_text += stamp_text ? "<i>[stamp_text]</i>" : "<i>This paper has been stamped with the [name].</i>"

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
	P.overlays += stampoverlay

/obj/item/weapon/stamp/attack_paw(mob/user)
	return attack_hand(user)
