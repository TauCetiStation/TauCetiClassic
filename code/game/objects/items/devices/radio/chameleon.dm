/obj/item/device/radio/headset/chameleon
//Just normal headset
	name = "radio headset"
	icon_state = "headset"
	item_state = "headset"
	desc = "An updated, modular intercom that fits over the head. Takes encryption keys. There's a small dial on it."
	origin_tech = "syndicate=3"
	var/list/headset_choices = list()

/obj/item/device/radio/headset/chameleon/atom_init()
	. = ..()
	var/blocked = list(obj/item/device/radio/headset/chameleon)//Prevent infinite loops and bad jumpsuits.
    var/unblocked = list(/obj/item/device/radio/intercom)
	for(var/U in typesof((/obj/item/device/radio/headset) && (/obj/item/device/radio/intercom))-blocked)
		var/obj/item/device/radio/headset/D = new H
		headset_choices[D.name] = H

/obj/item/device/radio/headset/chameleon/verb/change()
	set name = "Change Headset Appearance"
	set category = "Object"
	set src in usr

	var/picked = input("Select headset to change it to", "Chameleon Headset")as null|anything in headset_choices
	if(!picked || !headset_choices[picked])
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