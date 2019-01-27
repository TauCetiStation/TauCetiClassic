/* Clown Items
 * Contains:
 * 		Banana Peels
 *		Soap
 *		Bike Horns
 */

/*
 * Banana Peals
 */

/obj/item/weapon/bananapeel
	name = "banana peel"
	desc = "A peel from a banana."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = 2.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/bananapeel/Crossed(mob/living/carbon/C)
	if(istype(C))
		C.slip("the [src]", 4, 2)

/*
 * Soap
 */
/obj/item/weapon/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "soap"
	w_class = 2.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/soap/nanotrasen
	desc = "A Nanotrasen brand bar of soap. Smells of phoron."
	icon_state = "soapnt"

/obj/item/weapon/soap/deluxe
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of condoms."
	icon_state = "soapdeluxe"

/obj/item/weapon/soap/syndie
	desc = "An untrustworthy bar of soap. Smells of fear."
	icon_state = "soapsyndie"

/obj/item/weapon/soap/Crossed(mob/living/carbon/C) //EXACTLY the same as bananapeel for now, so it makes sense to put it in the same dm -- Urist
	if(istype(C))
		C.slip("the [src]", 4, 2)

/obj/item/weapon/soap/afterattack(atom/target, mob/user, proximity)
	if(!proximity) return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		to_chat(user, "<span class='notice'>You need to take that [target.name] off before cleaning it.</span>")
	else if(istype(target,/obj/effect/decal/cleanable))
		to_chat(user, "<span class='notice'>You scrub \the [target.name] out.</span>")
		qdel(target)
	else
		to_chat(user, "<span class='notice'>You clean \the [target.name].</span>")
		target.clean_blood()
	return

/obj/item/weapon/soap/attack(mob/target, mob/user, def_zone)
	if(target && user && ishuman(target) && ishuman(user) && !target.stat && !user.stat && user.zone_sel && def_zone == O_MOUTH)
		user.visible_message("<span class='red'>\the [user] washes \the [target]'s mouth out with soap!</span>")
		return
	..()

/*
 * Bike Horns
 */

/obj/item/weapon/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon = 'icons/obj/items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"
	throwforce = 3
	w_class = 1.0
	throw_speed = 3
	throw_range = 15
	attack_verb = list("HONKED")
	var/cooldown = FALSE

/obj/item/weapon/bikehorn/attack(mob/target, mob/user, def_zone)
	. = ..()
	playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)

/obj/item/weapon/bikehorn/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = world.time + 8
		playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
		src.add_fingerprint(user)
	return

/obj/item/weapon/bikehorn/dogtoy
	name = "dog toy"
	desc = "This adorable toy is made with super soft plush and has a squeaker inside for added entertainment."	//Woof!
	icon = 'icons/obj/items.dmi'
	icon_state = "dogtoy"
	item_state = "dogtoy"

//////////////////////////////////////////////////////
//			       Fake Laugh Button   			    //
//////////////////////////////////////////////////////

/obj/item/toy/laugh_button
	name = "laugh button"
	desc = "It's a perfect adding to the bad joke."
	icon = 'icons/obj/toy.dmi'
	icon_state = "laugh_button_on"
	var/cooldown = FALSE
	w_class = 1

/obj/item/toy/laugh_button/attack_self(mob/user)
	if(!cooldown)
		user.visible_message("<span class='notice'>[bicon(src)] \the [user] presses \the [src]</span>")
		playsound(src.loc, 'sound/items/buttonclick.ogg', 50, 1)
		var/laugh = pick(
			'sound/voice/fake_laugh/laugh1.ogg',
			'sound/voice/fake_laugh/laugh2.ogg',
			'sound/voice/fake_laugh/laugh3.ogg',
			)
		playsound(src.loc, laugh, 50, 1)
		flick("laugh_button_down",src)
		icon_state = "laugh_button_off"
		cooldown = TRUE
		addtimer(CALLBACK(src, .proc/release_cooldown), 50)
		return
	..()

/obj/item/toy/laugh_button/proc/release_cooldown()
	flick("laugh_button_up",src)
	icon_state = "laugh_button_on"
	cooldown = FALSE
	playsound(src.loc, 'sound/items/buttonclick.ogg', 50, 1)
	return
