/* Clown Items
 * Contains:
 * 		Banana Peels
 *		Soap
 *		Bike Horns
 */

/*
 * Banana Peals
 */
/obj/item/weapon/bananapeel/Crossed(mob/living/carbon/C)
	if(istype(C))
		C.slip("the [src]", 4, 2)

/*
 * Soap
 */
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
	else if(ishuman(target))
		return
	else
		to_chat(user, "<span class='notice'>You clean \the [target.name].</span>")
		target.clean_blood()
	return

/obj/item/weapon/soap/attack(mob/target, mob/user, def_zone)
	var/busy
	if(target && user && ishuman(target) && ishuman(user) && !user.stat && user.zone_sel && !busy)
		busy = 1
		var/mob/living/carbon/human/H = target
		var/body_part_name
		switch(def_zone)
			if(O_MOUTH)
				body_part_name = "mouth"
			if(BP_GROIN)
				body_part_name = "groin"
			if(BP_HEAD)
				body_part_name = "head"
			if(BP_CHEST)
				body_part_name = "chest"
			if(O_EYES)
				body_part_name = "eyes"
			if(BP_L_LEG)
				body_part_name = "legs"
			if(BP_R_LEG)
				body_part_name = "legs"
			if(BP_L_ARM)
				body_part_name = "arms"
			if(BP_R_ARM)
				body_part_name = "arms"
		if(target == user)
			user.visible_message("<span class='notice'>\the [user] starts to clean \his [body_part_name] out with soap.</span>")
		else
			user.visible_message("<span class='notice'>\the [user] starts to clean \the [target]'s [body_part_name] out with soap.</span>")
		if(do_after(user, 15, target = H) && src)
			switch(body_part_name)
//				if("mouth") TO DO: some silly mouth washing effect
				if("groin")
					if(H.belt)
						if(H.belt.clean_blood())
							H.update_inv_belt()
				if("head")
					if(H.head)
						var/washmask = 1
						var/washears = 1
						var/washglasses = 1
						washmask = !(H.head.flags_inv & HIDEMASK)
						washglasses = !(H.head.flags_inv & HIDEEYES)
						washears = !(H.head.flags_inv & HIDEEARS)
						if(H.wear_mask)
							if(washmask)
								if(H.wear_mask.clean_blood())
									H.update_inv_wear_mask()
							if (washears)
								washears = !(H.wear_mask.flags_inv & HIDEEARS)
							if (washglasses)
								washglasses = !(H.wear_mask.flags_inv & HIDEEYES)
						else
							H.lip_style = null
							H.update_body()
						if(H.glasses && washglasses)
							if(H.glasses.clean_blood())
								H.update_inv_glasses()
						if(H.l_ear && washears)
							if(H.l_ear.clean_blood())
								H.update_inv_ears()
						if(H.r_ear && washears)
							if(H.r_ear.clean_blood())
								H.update_inv_ears()
						if(H.head.clean_blood())
							H.update_inv_head()
				if("chest")
					if(H.wear_suit)
						if(H.wear_suit.clean_blood())
							H.update_inv_wear_suit()
					else if(H.w_uniform)
						if(H.w_uniform.clean_blood())
							H.update_inv_w_uniform()
					if(H.belt)
						if(H.belt.clean_blood())
							H.update_inv_belt()
				if("eyes")
					var/washglasses = 1
					if(H.head)
						washglasses = !(H.head.flags_inv & HIDEEYES)
					if(washglasses)
						if(H.glasses)
							if(H.glasses.clean_blood())
								H.update_inv_glasses()
						else
							H.eye_blurry = max(H.eye_blurry, 5)
							H.eye_blind = max(H.eye_blind, 1)
							to_chat(H, "<span class='warning'>Ouch! That hurts!</span>")
				if("legs")
					var/obj/item/organ/external/l_foot = H.bodyparts_by_name[BP_L_LEG]
					var/obj/item/organ/external/r_foot = H.bodyparts_by_name[BP_R_LEG]
					if((l_foot || !(l_foot.status & ORGAN_DESTROYED)) && (r_foot || !(r_foot.status & ORGAN_DESTROYED)))
						if(H.shoes)
							if(H.shoes.clean_blood())
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
					if((l_hand || !(l_hand.status & ORGAN_DESTROYED)) && (r_hand || !(r_hand.status & ORGAN_DESTROYED)))
						if(H.gloves)
							if(H.gloves.clean_blood())
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
			busy = 0
			playsound(src.loc, 'sound/misc/slip.ogg', 50, 1)
			return
		else
			user.visible_message("<span class='red'>\the [user] fails to clean \the [target]'s [body_part_name] out with soap.</span>")
			busy = 0
			return
	..()

/*
 * Bike Horns
 */
/obj/item/weapon/bikehorn/attack_self(mob/user)
	if (spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
		src.add_fingerprint(user)
		spawn(20)
			spam_flag = 0
	return

/obj/item/weapon/bikehorn/dogtoy
	name = "dog toy"
	desc = "This adorable toy is made with super soft plush and has a squeaker inside for added entertainment."	//Woof!
	icon = 'icons/obj/items.dmi'
	icon_state = "dogtoy"
	item_state = "dogtoy"
