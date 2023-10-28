/obj/item/clothing/accessory/holster
	name = "shoulder holster"
	desc = "A handgun holster."
	icon_state = "holster"
	slot = "utility"
	var/obj/item/weapon/gun/holstered = null

/obj/item/clothing/accessory/holster/atom_init()
	. = ..()
	if(holstered)
		holstered = new holstered(src)
		update_icon()

/obj/item/clothing/accessory/holster/proc/holster(obj/item/I, mob/user)
	if(holstered)
		to_chat(user, "<span class='warning'>There is already a [holstered] holstered here!</span>")
		return FALSE

	if (!istype(I, /obj/item/weapon/gun) && !I.can_be_holstered)
		to_chat(user, "<span class='warning'>Only guns can be holstered!</span>")
		return FALSE

	if (!I.can_be_holstered)
		to_chat(user, "<span class='warning'>This [I] won't fit in the [src]!</span>")
		return FALSE

	holstered = I
	user.drop_from_inventory(holstered, src)
	holstered.add_fingerprint(user)
	user.visible_message("<span class='notice'>[user] holsters the [holstered].</span>", "<span class='notice'>You holster the [holstered].</span>")
	update_icon()
	return TRUE

/obj/item/clothing/accessory/holster/proc/unholster(mob/user)
	if(!holstered)
		return

	if(istype(user.get_active_hand(), /obj) && istype(user.get_inactive_hand(), /obj))
		to_chat(user, "<span class='warning'>You need an empty hand to draw the [holstered]!</span>")
	else
		if(user.a_intent == INTENT_HARM)
			user.visible_message(
				"<span class='warning'>[user] draws the [holstered], ready to shoot!</span>",
				"<span class='warning'>You draw the [holstered], ready to shoot!</span>")
		else
			user.visible_message(
				"<span class='notice'>[user] draws the [holstered], pointing it at the ground.</span>",
				"<span class='notice'>You draw the [holstered], pointing it at the ground.</span>")
		user.put_in_hands(holstered)
		holstered.add_fingerprint(user)
		holstered = null
		update_icon()


/obj/item/clothing/accessory/holster/attack_hand(mob/user)
	if (has_suit)	//if we are part of a suit
		if (holstered)
			unholster(user)
		return

	..(user)

/obj/item/clothing/accessory/holster/attack_accessory(obj/item/I, mob/user, params)
	return holster(I, user)

/obj/item/clothing/accessory/holster/emp_act(severity)
	if (holstered)
		holstered.emplode(severity)
	..()

/obj/item/clothing/accessory/holster/examine(mob/user)
	..()
	if (holstered)
		to_chat(user, "A [holstered] is holstered here.")
	else
		to_chat(user, "It is empty.")

/obj/item/clothing/accessory/holster/on_attached(obj/item/clothing/under/S, mob/user)
	..()
	has_suit.verbs += /obj/item/clothing/accessory/holster/verb/holster_verb

/obj/item/clothing/accessory/holster/on_removed(mob/user)
	has_suit.verbs -= /obj/item/clothing/accessory/holster/verb/holster_verb
	..()

/mob/living/carbon/human/proc/get_holster()
	var/obj/item/clothing/accessory/holster/H = locate() in src
	if(!H && isunder(w_uniform))
		var/obj/item/clothing/under/S = w_uniform
		if(S.accessories)
			H = locate() in S.accessories
	return H

/mob/living/carbon/human/proc/holster_weapon()
	var/obj/item/clothing/accessory/holster/my_holster = get_holster()
	if(!my_holster)
		return

	if(!my_holster.holstered)
		var/obj/item/weapon/gun/W = get_active_hand()
		if(!istype(W, /obj/item/weapon/gun))
			to_chat(src, "<span class='notice'>You need your gun equiped to holster it.</span>")
			return
		my_holster.holster(W, src)
	else
		my_holster.unholster(src)

//For the holster hotkey
/obj/item/clothing/accessory/holster/verb/holster_verb()
	set name = "Holster"
	set category = "Object"
	set src in usr

	if(!ishuman(usr))
		return
	if(usr.incapacitated())
		return

	var/mob/living/carbon/human/human = usr
	human.holster_weapon()

/obj/item/clothing/accessory/holster/armpit
	name = "shoulder holster"
	desc = "A worn-out handgun holster. Perfect for concealed carry."
	icon_state = "holster"

/obj/item/clothing/accessory/holster/armpit/update_icon()
	..()
	icon_state = "[initial(icon_state)][holstered ? "_loaded" : ""]"

/obj/item/clothing/accessory/holster/armpit/

/obj/item/clothing/accessory/holster/mafia
	name = "gun holster"
	desc = "When you just HAVE to show off your guns."
	icon_state = "mafia_holster"
