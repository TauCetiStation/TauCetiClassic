/obj/item/clothing/mask/muzzle
	name = "muzzle"
	desc = "To stop that awful noise."
	icon_state = "muzzle"
	item_state = "muzzle"
	flags = MASKCOVERSMOUTH
	body_parts_covered = 0
	w_class = ITEM_SIZE_SMALL
	gas_transfer_coefficient = 0.90

//Monkeys can not take the muzzle off of themself! Call PETA!
/obj/item/clothing/mask/muzzle/attack_paw(mob/user)
	if (src == user.wear_mask)
		return
	else
		..()
	return


/obj/item/clothing/mask/surgical
	name = "sterile mask"
	desc = "A sterile mask designed to help prevent the spread of diseases."
	icon_state = "sterile"
	item_state = "sterile"
	w_class = ITEM_SIZE_SMALL
	flags = MASKCOVERSMOUTH
	body_parts_covered = 0
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 25, rad = 0)

/obj/item/clothing/mask/fakemoustache
	name = "fake moustache"
	desc = "Warning: moustache is fake."
	icon_state = "fake-moustache"
	flags_inv = HIDEFACE
	body_parts_covered = 0

/obj/item/clothing/mask/fake_face
	name = "fake face"
	desc = "Warning: this face not a fake."
	icon_state = "fake_face"
	flags_inv = HIDEFACE
	body_parts_covered = 0

/obj/item/clothing/mask/snorkel
	name = "snorkel"
	desc = "For the Swimming Savant."
	icon_state = "snorkel"
	flags_inv = HIDEFACE
	body_parts_covered = 0

//scarves (fit in in mask slot)

/obj/item/clothing/mask/scarf
	name = "scarf"
	desc = "A simple neck scarf."
	icon_state = "bluescarf"
	item_state = "bluescarf"
	flags = MASKCOVERSMOUTH
	w_class = ITEM_SIZE_SMALL
	gas_transfer_coefficient = 0.90
	action_button_name = "Adjust scarf"
	var/hanging = 0

/obj/item/clothing/mask/scarf/blue
	name = "blue neck scarf"
	desc = "A blue neck scarf."
	icon_state = "bluescarf"
	item_state = "bluescarf"

/obj/item/clothing/mask/scarf/red
	name = "red scarf"
	desc = "A red neck scarf."
	icon_state = "redscarf"
	item_state = "redscarf"

/obj/item/clothing/mask/scarf/green
	name = "green scarf"
	desc = "A green neck scarf."
	icon_state = "greenscarf"
	item_state = "greenscarf"

/obj/item/clothing/mask/scarf/yellow
	name = "yellow scarf"
	desc = "A yellow neck scarf."
	icon_state = "yellowscarf"
	item_state = "yellowscarf"

/obj/item/clothing/mask/scarf/violet
	name = "violet scarf"
	desc = "A violet neck scarf."
	icon_state = "violetscarf"
	item_state = "violetscarf"

/obj/item/clothing/mask/scarf/attack_self(mob/user)

	if(user.incapacitated())
		return


	if(!hanging)
		hanging = !hanging
		gas_transfer_coefficient = 1 //gas is now escaping to the turf and vice versa
		flags &= ~MASKCOVERSMOUTH
		icon_state = "[initial(icon_state)]down"
		to_chat(user, "Your scarf is now hanging on your neck.")
	else
		hanging = !hanging
		gas_transfer_coefficient = 0.90
		flags |= MASKCOVERSMOUTH
		icon_state = "[initial(icon_state)]"
		to_chat(user, "You pull the scarf up to cover your face.")
	user.update_inv_wear_mask()




/obj/item/clothing/mask/scarf/ninja
	name = "ninja scarf"
	desc = "A stealthy, dark scarf."
	icon_state = "ninja_scarf"
	item_state = "ninja_scarf"
	flags = MASKCOVERSMOUTH
	w_class = ITEM_SIZE_SMALL
	gas_transfer_coefficient = 0.90
	siemens_coefficient = 0

/obj/item/clothing/mask/pig
	name = "pig mask"
	desc = "A rubber pig mask."
	icon_state = "pig"
	item_state = "pig"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	w_class = ITEM_SIZE_SMALL
	siemens_coefficient = 0.9
	body_parts_covered = HEAD|FACE|EYES

/obj/item/clothing/mask/pig/speechModification(message)
	if(!canremove)
		message = pick("Oink!", "Squeeeeeeee!", "Oink Oink!")
	return message

/obj/item/clothing/mask/horsehead
	name = "horse head mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a horse."
	icon_state = "horsehead"
	item_state = "horsehead"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	body_parts_covered = HEAD|FACE|EYES
	w_class = ITEM_SIZE_SMALL
	siemens_coefficient = 0.9

/obj/item/clothing/mask/horsehead/speechModification(message)
	if(!canremove)
		message = pick("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!")
	return message

/obj/item/clothing/mask/cowmask
	name = "cowface"
	desc = "It looks like a mask, but closer inspection reveals it's melded onto this persons face!"
	icon_state = "cowmask"
	item_state = "cowmask"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	body_parts_covered = HEAD|FACE|EYES
	w_class = ITEM_SIZE_SMALL

/obj/item/clothing/mask/cowmask/speechModification(message)
	if(!canremove)
		message = pick("Moooooooo!", "Moo!", "Moooo!")
	return message

/obj/item/clothing/mask/bandana
	name = "botany bandana"
	desc = "A fine bandana with nanotech lining and a hydroponics pattern."
	w_class = ITEM_SIZE_TINY
	flags = MASKCOVERSMOUTH
	action_button_name = "Adjust Bandana"
	icon_state = "bandbotany"
	body_parts_covered = 0

/obj/item/clothing/mask/chicken
	name = "chicken suit head"
	desc = "Bkaw!"
	icon_state = "chickenmask"
	flags = BLOCKHAIR
	body_parts_covered = HEAD|FACE|EYES

/obj/item/clothing/mask/chicken/speechModification(message)
	if(!canremove)
		message = pick("BKAW!", "BUK BUK!", "Ba-Gawk!")
	return message

/obj/item/clothing/mask/bandana/verb/adjustmask()
	set category = "Object"
	set name = "Adjust bandana"
	set src in usr
	if(!usr.incapacitated())
		flags ^= MASKCOVERSMOUTH
		if(flags & MASKCOVERSMOUTH)
			src.icon_state = initial(icon_state)
			to_chat(usr, "Your bandana is now covering your face.")
		else
			src.icon_state += "_up"
			to_chat(usr, "You tie the bandana around your head.")
		usr.update_inv_wear_mask()

/obj/item/clothing/mask/bandana/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/bandana/red
	name = "red bandana"
	desc = "A fine red bandana with nanotech lining."
	icon_state = "bandred"

/obj/item/clothing/mask/bandana/blue
	name = "blue bandana"
	desc = "A fine blue bandana with nanotech lining."
	icon_state = "bandblue"

/obj/item/clothing/mask/bandana/green
	name = "green bandana"
	desc = "A fine green bandana with nanotech lining."
	icon_state = "bandgreen"

/obj/item/clothing/mask/bandana/gold
	name = "gold bandana"
	desc = "A fine gold bandana with nanotech lining."
	icon_state = "bandgold"

/obj/item/clothing/mask/bandana/black
	name = "black bandana"
	desc = "A fine black bandana with nanotech lining."
	icon_state = "bandblack"

/obj/item/clothing/mask/bandana/skull
	name = "skull bandana"
	desc = "A fine black bandana with nanotech lining and a skull emblem."
	icon_state = "bandskull"

/obj/item/clothing/mask/tie
	body_parts_covered = 0
	w_class = ITEM_SIZE_TINY

/obj/item/clothing/mask/tie/collar
	name = "silver collar"
	desc = "A common collar with silver covering"
	icon_state = "collar"

/obj/item/clothing/mask/tie/collar2
	name = "gold collar"
	desc = "A common collar with gold covering"
	icon_state = "collar2"

/obj/item/clothing/mask/tie/silver_cross
	name = "pectoral silver cross"
	desc = "That's a big pectoral silver cross for big religion figures."
	icon_state = "pectoral_silver_cross"
	item_state = "pectoral_silver_cross"

/obj/item/clothing/mask/tie/golden_cross
	name = "pectoral golden cross"
	desc = "That's a big pectoral golden cross for the biggest religion figure."
	icon_state = "pectoral_golden_cross"
	item_state = "pectoral_golden_cross"

/obj/item/clothing/mask/ecig
	name = "electronic cigarette"
	desc = "An electronic cigarette. Most of the relief of a real cigarette with none of the side effects. Often used by smokers who are trying to quit the habit."
	icon_state = "ecig"
	item_state = "ecig"
	throw_speed = 0.5
	w_class = ITEM_SIZE_TINY
	body_parts_covered = null
	var/last_time_used = 0

/obj/item/clothing/mask/ecig/attack_self(mob/user)
	if(world.time > last_time_used + 20)
		if(icon_state == "ecig")
			icon_state = "ecig_on"
			item_state = "ecig_on"
			to_chat(user, "<span class='notice'>You turn the [src] on</span>")
		else
			icon_state = "ecig"
			item_state = "ecig"
			to_chat(user, "<span class='notice'>You turn the [src] off</span>")
		last_time_used = world.time
	return
