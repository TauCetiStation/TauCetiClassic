/obj/item/device/radio/headset/chameleon
//Just normal headset
	name = "radio headset"
	icon_state = "headset"
	item_state = "headset"
	desc = "An updated, modular intercom that fits over the head. Takes encryption keys. There's a small dial on it, with a holographic projector."
	origin_tech = "syndicate=3"
	var/list/headset_choices = list()

/obj/item/device/radio/headset/radio_dummy
	icon = 'icons/obj/radio.dmi'
	name = "station bounced radio"
	suffix = "\[3\]"
	icon_state = "walkietalkie"
	item_state = "walkietalkie"

/obj/item/device/radio/headset/chameleon/atom_init()
	. = ..()
	var/blocked = list(/obj/item/device/radio/headset/chameleon)	//Prevent infinite loops and bad headsets.
	for(var/U in typesof(/obj/item/device/radio/headset, /obj/item/device/radio/intercom,)-blocked)
		var/obj/item/device/radio/headset/V = U
		headset_choices[initial(V.name)] = U

/obj/item/device/radio/headset/chameleon/emp_act(severity) 
	if(!grid)
		on = 0
		name = "radio headset"
		icon_state = "headset"
		item_state = "headset"
		desc = "Standart headset. Looks burned"
		update_icon()
		update_inv_mob()
		..()

/obj/item/device/radio/headset/chameleon/verb/change()
	set name = "Change Headset Appearance"
	set category = "Headset"
	set src in usr
	
	if(usr.incapacitated())
		return

	var/picked = input("Select headset to change it to", "Chameleon Headset")as null|anything in headset_choices
	if(!picked || !headset_choices[picked])
		return
	if(picked && !on)
		to_chat(usr, "Holographic system doesn't respond!")
		return
	var/newtype = headset_choices[picked]
	var/obj/item/device/radio/A = new newtype

	desc = null

	if(A.icon_custom)
		icon = A.icon_custom
		icon_custom = A.icon_custom
	else
		icon = A.icon
		icon_custom = null
	desc = A.desc
	name = A.name
	icon_state = A.icon_state
	item_state = A.item_state
	update_inv_mob()

