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
	w_class = ITEM_SIZE_SMALL
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/bananapeel/atom_init()
	. = ..()
	AddComponent(/datum/component/slippery, 4)

/obj/item/weapon/bananapeel/honk
	name = "Clowny banana peel"
	desc = "A peel from a banana for Clown."
	icon = 'icons/obj/items.dmi'
	icon_state = "h-banana_peel"
	item_state = "h-banana_peel"
	w_class = ITEM_SIZE_SMALL
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/bananapeel/honk/atom_init()
	. = ..()
	AddComponent(/datum/component/slippery, 5, SLIDE | GALOSHES_DONT_HELP)

/*
 * Soap
 */
/obj/item/weapon/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "soap"
	w_class = ITEM_SIZE_SMALL
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/soap/atom_init()
	. = ..()
	AddComponent(/datum/component/slippery, 4)

/obj/item/weapon/soap/nanotrasen
	desc = "A Nanotrasen brand bar of soap. Smells of phoron."
	icon_state = "soapnt"

/obj/item/weapon/soap/deluxe
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of condoms."
	icon_state = "soapdeluxe"

/obj/item/weapon/soap/syndie
	desc = "An untrustworthy bar of soap. Smells of fear."
	icon_state = "soapsyndie"

/obj/item/weapon/soap/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	// I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	// So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
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
	if(target && user && ishuman(target) && ishuman(user) && !user.stat && user.zone_sel && !user.is_busy())
		var/mob/living/carbon/human/H = target
		var/body_part_name
		switch(def_zone)
			if(BP_L_LEG, BP_R_LEG)
				body_part_name = "legs"
			if(BP_L_ARM, BP_R_ARM)
				body_part_name = "arms"
			else
				body_part_name = def_zone
		if(target == user)
			user.visible_message("<span class='notice'>\the [user] starts to clean \his [body_part_name] out with soap.</span>")
		else
			user.visible_message("<span class='notice'>\the [user] starts to clean \the [target]'s [body_part_name] out with soap.</span>")
		if(do_after(user, 15, target = H) && src)
			switch(body_part_name)
				if("mouth")
					H.lip_style = null
					H.update_body()
				if("groin")
					if(H.belt)
						if(H.belt.clean_blood())
							H.update_inv_belt()
				if("head")
					if(H.head)
						var/washmask = !(H.head.flags_inv & HIDEMASK)
						var/washears = !((H.head.flags_inv & HIDEEARS) || (H.wear_mask && H.wear_mask.flags_inv & HIDEEARS))
						var/washglasses = !((H.head.flags_inv & HIDEEYES) || (H.wear_mask && H.wear_mask.flags_inv & HIDEEYES))
						if(washmask && H.wear_mask && H.wear_mask.clean_blood())
							H.update_inv_wear_mask()
						else
							H.lip_style = null
							H.update_body()
						if(H.glasses && washglasses && H.glasses.clean_blood())
							H.update_inv_glasses()
						if(H.l_ear && washears && H.l_ear.clean_blood())
							H.update_inv_ears()
						if(H.r_ear && washears && H.r_ear.clean_blood())
							H.update_inv_ears()
						if(H.head.clean_blood())
							H.update_inv_head()
				if("chest")
					if(H.wear_suit && H.wear_suit.clean_blood())
						H.update_inv_wear_suit()
					else if(H.w_uniform && H.w_uniform.clean_blood())
						H.update_inv_w_uniform()
					if(H.belt && H.belt.clean_blood())
						H.update_inv_belt()
				if("eyes")
					if(!(H.head && (H.head.flags_inv & HIDEEYES)))
						if(H.glasses)
							H.glasses.clean_blood()
							H.update_inv_glasses()
						else
							H.eye_blurry = max(H.eye_blurry, 5)
							H.eye_blind = max(H.eye_blind, 1)
							to_chat(H, "<span class='warning'>Ouch! That hurts!</span>")
				if("legs")
					var/obj/item/organ/external/l_foot = H.bodyparts_by_name[BP_L_LEG]
					var/obj/item/organ/external/r_foot = H.bodyparts_by_name[BP_R_LEG]
					var/no_legs = FALSE
					if((!l_foot || (l_foot && (l_foot.is_stump))) && (!r_foot || (r_foot && (r_foot.is_stump))))
						no_legs = TRUE
					if(!no_legs)
						if(H.shoes && H.shoes.clean_blood())
							H.update_inv_shoes()
						else
							H.feet_blood_DNA = null
							H.feet_dirt_color = null
							H.update_inv_shoes()
					else
						to_chat(user, "<span class='red'>There is nothing to clean!</span>")
						return
				if("arms")
					var/obj/item/organ/external/r_hand = H.bodyparts_by_name[BP_L_ARM]
					var/obj/item/organ/external/l_hand = H.bodyparts_by_name[BP_R_ARM]
					if((l_hand && !(l_hand.is_stump)) && (r_hand && !(r_hand.is_stump)))
						if(H.gloves && H.gloves.clean_blood())
							H.update_inv_gloves()
							H.gloves.germ_level = 0
						else
							if(H.bloody_hands)
								H.bloody_hands = 0
								H.update_inv_gloves()
							H.germ_level = 0
			H.clean_blood()
			if(target == user)
				user.visible_message("<span class='notice'>\the [user] cleans \his [body_part_name] out with soap.</span>")
			else
				user.visible_message("<span class='notice'>\the [user] cleans \the [target]'s [body_part_name] out with soap.</span>")
			playsound(src, 'sound/misc/slip.ogg', VOL_EFFECTS_MASTER)
			return
		else
			user.visible_message("<span class='red'>\the [user] fails to clean \the [target]'s [body_part_name] out with soap.</span>")
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
	w_class = ITEM_SIZE_TINY
	throw_speed = 3
	throw_range = 15
	attack_verb = list("HONKED")
	var/cooldown = FALSE

/obj/item/weapon/bikehorn/proc/honk(mob/user)
	playsound(src, 'sound/items/bikehorn.ogg', VOL_EFFECTS_MISC)
	if(user.can_waddle())
		user.waddle(pick(-14, 0, 14), 4)

/obj/item/weapon/bikehorn/attack(mob/target, mob/user, def_zone)
	. = ..()
	honk(user)

/obj/item/weapon/bikehorn/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = world.time + 8
		honk(user)
		src.add_fingerprint(user)

/obj/item/weapon/bikehorn/Crossed(atom/movable/AM)
	. = ..()
	if(isliving(AM) && cooldown <= world.time)
		cooldown = world.time + 8
		honk(AM)

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
	w_class = ITEM_SIZE_TINY

/obj/item/toy/laugh_button/attack_self(mob/user)
	if(!cooldown)
		user.visible_message("<span class='notice'>[bicon(src)] \the [user] presses \the [src]</span>")
		playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER)
		var/laugh = pick(
			'sound/voice/fake_laugh/laugh1.ogg',
			'sound/voice/fake_laugh/laugh2.ogg',
			'sound/voice/fake_laugh/laugh3.ogg',
			)
		playsound(src, laugh, VOL_EFFECTS_MISC)
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
	playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER)
	return
