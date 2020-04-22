//CONTAINS: Evidence bags and fingerprint cards

/obj/item/weapon/evidencebag
	name = "evidence bag"
	desc = "An empty evidence bag."
	icon = 'icons/obj/storage.dmi'
	icon_state = "evidenceobj"
	item_state = ""
	w_class = ITEM_SIZE_SMALL

/obj/item/weapon/evidencebag/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(!in_range(target, user))
		return

	if(!istype(target, /obj/item))
		return ..()

	var/obj/item/I = target
	if(I.anchored)
		return ..()

	if(istype(I, /obj/item/weapon/evidencebag))
		to_chat(user, "<span class='notice'>You find putting an evidence bag in another evidence bag to be slightly absurd.</span>")
		return

	if(istype(I, /obj/item/weapon/storage/box/evidence))
		return

	if(istype(I, /obj/item/device/core_sampler)) //core sampler interacts with evidence bags in another way
		return

	if(I.w_class > ITEM_SIZE_NORMAL)
		to_chat(user, "<span class='notice'>[I] won't fit in [src].</span>")
		return

	if(contents.len)
		to_chat(user, "<span class='notice'>[src] already has something inside it.</span>")
		return ..()

	if(!isturf(I.loc)) //If it isn't on the floor. Do some checks to see if it's in our hands or a box. Otherwise give up.
		if(istype(I.loc,/obj/item/weapon/storage))	//in a container.
			var/obj/item/weapon/storage/U = I.loc
			user.client.screen -= I
			U.contents.Remove(I)
		else if(user.l_hand == I)					//in a hand
			user.drop_l_hand()
		else if(user.r_hand == I)					//in a hand
			user.drop_r_hand()
		else
			return

	user.visible_message(
		"[user] puts [I] into [src]",
		"You put [I] inside [src].",
		"You hear a rustle as someone puts something into a plastic bag."
	)

	put_item_in(I)

/obj/item/weapon/evidencebag/proc/put_item_in(obj/item/I)
	icon_state = "evidence"
	w_class = I.w_class
	desc = "\An [name] containing [I]. [I.desc]"

	var/temp_x = I.pixel_x
	var/temp_y = I.pixel_y
	I.pixel_x = 0
	I.pixel_y = 0

	var/image/img = image("icon" = I)
	img.layer = FLOAT_LAYER
	img.plane = FLOAT_PLANE

	underlays += img

	I.pixel_x = temp_x
	I.pixel_y = temp_y
	I.loc = src

/obj/item/weapon/evidencebag/attack_self(mob/user)
	if(contents.len)
		var/obj/item/I = contents[1]
		user.visible_message(
			"[user] takes [I] out of [src]",
			"You take [I] out of [src].",
			"You hear someone rustle around in a plastic bag, and remove something."
		)
		underlays.Cut()
		user.put_in_hands(I)
		w_class = initial(w_class)
		icon_state = "evidenceobj"
		desc = "An empty [name]."

	else
		to_chat(user, "[src] is empty.")
		icon_state = "evidenceobj"
	return

/obj/item/weapon/f_card
	name = "finger print card"
	desc = "Used to take fingerprints."
	icon = 'icons/obj/card.dmi'
	icon_state = "fingerprint0"
	var/amount = 10.0
	item_state = "paper"
	throwforce = 1
	w_class = ITEM_SIZE_TINY
	throw_speed = 3
	throw_range = 5


/obj/item/weapon/fcardholder
	name = "fingerprint card case"
	desc = "Apply finger print card."
	icon = 'icons/obj/items.dmi'
	icon_state = "fcardholder0"
	item_state = "clipboard"
