/obj/item/weapon/lipstick
	gender = PLURAL
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon = 'icons/obj/items.dmi'
	icon_state = "lipstick"
	w_class = 1.0
	var/colour = "red"
	var/open = 0


/obj/item/weapon/lipstick/purple
	name = "purple lipstick"
	colour = "purple"

/obj/item/weapon/lipstick/jade
	name = "jade lipstick"
	colour = "jade"

/obj/item/weapon/lipstick/black
	name = "black lipstick"
	colour = "black"


/obj/item/weapon/lipstick/random
	name = "lipstick"

/obj/item/weapon/lipstick/random/atom_init()
	. = ..()
	colour = pick("red","purple","jade","black")
	name = "[colour] lipstick"


/obj/item/weapon/lipstick/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You twist \the [src] [open ? "closed" : "open"].</span>")
	open = !open
	if(open)
		icon_state = "[initial(icon_state)]_[colour]"
	else
		icon_state = initial(icon_state)

/obj/item/weapon/lipstick/attack(mob/M, mob/user)
	if(!open)	return

	if(!istype(M, /mob))	return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.lip_style)	//if they already have lipstick on
			to_chat(user, "<span class='notice'>You need to wipe off the old lipstick first!</span>")
			return
		if(H == user)
			user.visible_message("<span class='notice'>[user] does their lips with \the [src].</span>", \
								 "<span class='notice'>You take a moment to apply \the [src]. Perfect!</span>")
			H.lip_style = "lipstick"
			H.lip_color = colour
			H.update_body()
		else if(!user.is_busy())
			user.visible_message("<span class='warning'>[user] begins to do [H]'s lips with \the [src].</span>", \
								 "<span class='notice'>You begin to apply \the [src].</span>")
			if(do_after(user, 20, target = H))	//user needs to keep their active hand, H does not.
				user.visible_message("<span class='notice'>[user] does [H]'s lips with \the [src].</span>", \
									 "<span class='notice'>You apply \the [src].</span>")
				H.lip_style = "lipstick"
				H.lip_color = colour
				H.update_body()
	else
		to_chat(user, "<span class='notice'>Where are the lips on that?</span>")

//you can wipe off lipstick with paper!
/obj/item/weapon/paper/attack(mob/living/carbon/M, mob/living/carbon/user, def_zone)
	if(def_zone == O_MOUTH)
		if(!istype(M))
			return

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H == user)
				to_chat(user, "<span class='notice'>You wipe off the lipstick with [src].</span>")
				H.lip_style = null
				H.update_body()
			else if(!user.is_busy())
				user.visible_message("<span class='warning'>[user] begins to wipe [H]'s lipstick off with \the [src].</span>", \
								 	 "<span class='notice'>You begin to wipe off [H]'s lipstick.</span>")
				if(do_after(user, 10, target = H))	//user needs to keep their active hand, H does not.
					user.visible_message("<span class='notice'>[user] wipes [H]'s lipstick off with \the [src].</span>", \
										 "<span class='notice'>You wipe off [H]'s lipstick.</span>")
					H.lip_style = null
					H.update_body()
	else
		..()


/obj/item/weapon/razor
	name = "electric razor"
	desc = "The latest and greatest power razor born from the science of shaving."
	icon = 'icons/obj/items.dmi'
	icon_state = "razor"
	flags = CONDUCT
	w_class = 1


/obj/item/weapon/razor/proc/shave(mob/living/carbon/human/H, location = O_MOUTH, mob/living/carbon/human/AH = null)
	if(location == O_MOUTH)
		H.f_style = "Shaved"
	else
		H.h_style = "Skinhead"
	if(AH)
		H.attack_log += text("\[[time_stamp()]\] <font color='blue'>Has been shaved with [src.name] by [AH.name] ([AH.ckey])</font>")
		AH.attack_log += text("\[[time_stamp()]\] <font color='blue'>Used the [src.name] to shave [H.name] ([H.ckey])</font>")
	H.update_hair()
	playsound(loc, 'sound/items/Welder2.ogg', 20, 1)


/obj/item/weapon/razor/attack(mob/M, mob/user, def_zone)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		if(def_zone == O_MOUTH)
			if(!H.species.flags[HAS_HAIR])
				to_chat(user, "<span class='warning'>There is no hair!</span>")
				return
			if((H.head && (H.head.flags & HEADCOVERSMOUTH)) || (H.wear_mask && (H.wear_mask.flags & MASKCOVERSMOUTH)))
				to_chat(user, "<span class='warning'>The mask is in the way!</span>")
				return
			if(H.f_style == "Shaved")
				to_chat(user, "<span class='warning'>Already clean-shaven!</span>")
				return

			if(H == user) //shaving yourself
				if(user.is_busy()) return
				user.visible_message("[user] starts to shave their facial hair with [src].", \
									 "<span class='notice'>You take a moment to shave your facial hair with [src]...</span>")
				if(do_after(user, 50, target = H))
					user.visible_message("[user] shaves his facial hair clean with [src].", \
										 "<span class='notice'>You finish shaving with [src]. Fast and clean!</span>")
					shave(H, def_zone)
			else if(!user.is_busy())
				var/turf/H_loc = H.loc
				user.visible_message("<span class='warning'>[user] tries to shave [H]'s facial hair with [src].</span>", \
									 "<span class='notice'>You start shaving [H]'s facial hair...</span>")
				if(do_after(user, 50, target = H))
					if(H_loc == H.loc)
						user.visible_message("<span class='warning'>[user] shaves off [H]'s facial hair with [src].</span>", \
											 "<span class='notice'>You shave [H]'s facial hair clean off.</span>")
						shave(H, def_zone, user)

		else if(def_zone == BP_HEAD)
			if(!H.species.flags[HAS_HAIR])
				to_chat(user, "<span class='warning'>There is no hair!</span>")
				return
			if((H.head && (H.head.flags & BLOCKHAIR)) || (H.head && (H.head.flags & HIDEEARS)))
				to_chat(user, "<span class='warning'>The headgear is in the way!</span>")
				return
			if(H.h_style == "Bald" || H.h_style == "Balding Hair" || H.h_style == "Skinhead")
				to_chat(user, "<span class='warning'>There is not enough hair left to shave!</span>")
				return

			if(H == user) //shaving yourself
				if(user.is_busy()) return
				user.visible_message("[user] starts to shave their head with [src].", \
									 "<span class='notice'>You start to shave your head with [src]...</span>")
				if(do_after(user, 50, target = H))
					user.visible_message("[user] shaves his head with [src].", \
										 "<span class='notice'>You finish shaving with [src].</span>")
					shave(H, def_zone)
			else if(!user.is_busy())
				var/turf/H_loc = H.loc
				user.visible_message("<span class='warning'>[user] tries to shave [H]'s head with [src]!</span>", \
									 "<span class='notice'>You start shaving [H]'s head...</span>")
				if(do_after(user, 50, target = H))
					if(H_loc == H.loc)
						user.visible_message("<span class='warning'>[user] shaves [H]'s head bald with [src]!</span>", \
											 "<span class='notice'>You shave [H]'s head bald.</span>")
						shave(H, def_zone, user)
		else
			..()
	else
		..()

/obj/item/weapon/haircomb //sparklysheep's comb
	name = "purple comb"
	desc = "A pristine purple comb made from flexible plastic."
	w_class = 1.0
	icon = 'icons/obj/items.dmi'
	icon_state = "purplecomb"
	item_state = "purplecomb"

/obj/item/weapon/haircomb/attack_self(mob/user)
	if(user.r_hand == src || user.l_hand == src)
		user.visible_message(text("\red [] uses [] to comb their hair with incredible style and sophistication. What a [].", user, src, user.gender == FEMALE ? "lady" : "guy"))
	return

/obj/item/weapon/scissors
	name = "scissors"
	desc = "These can cut hair."
	icon = 'icons/obj/items.dmi'
	icon_state = "cutters_yellow"
	item_state = "cutters_yellow"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 6.0
	throw_speed = 2
	throw_range = 9
	w_class = 2.0
	m_amt = 80
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("cut", "stabbed", "chipped")
	sharp = 1
	edge = 1
	var/list/bald_hair_styles_list = list("Bald", "Balding Hair", "Skinhead", "Unathi Horns", "Tajaran Ears")
	var/list/shaved_facial_hair_styles_list = list("Shaved")
	var/list/allowed_races = list(HUMAN, UNATHI, TAJARAN)

/obj/item/weapon/scissors/attack(mob/M, mob/user, def_zone)
	if(user.a_intent == "hurt")
		..()
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		if(user.is_busy()) return

		if(def_zone == O_MOUTH)
			if(H == user)
				to_chat(user, "<span class='notice'>You can't cut your facial hair</span>")
				return

			if(H.species.name in allowed_races)
				if((H.head && (H.head.flags & HEADCOVERSMOUTH)) || (H.wear_mask && (H.wear_mask.flags & MASKCOVERSMOUTH)))
					to_chat(user, "<span class='warning'>The mask is in the way!</span>")
					return

				if(H.f_style in shaved_facial_hair_styles_list)
					to_chat(user, "<span class='notice'>There are not enough hair to change facial hair style</span>")
					return

				var/list/species_facial_hair = list()
				if(H.species)
					for(var/i in facial_hair_styles_list)
						var/datum/sprite_accessory/hair/tmp_hair = facial_hair_styles_list[i]
						if(H.species.name in tmp_hair.species_allowed)
							species_facial_hair += i
				else
					species_facial_hair = facial_hair_styles_list

				if(species_facial_hair.len == 0)
					to_chat(user, "<span class='notice'>You don't know any facial hair styles for this race!</span>")
					return
				var/new_fstyle = input(usr, "Select a facial hair style", "Grooming") as null|anything in species_facial_hair
				if(new_fstyle)
					user.visible_message("<span class='notice'>[user] starts cutting [H]'s facial hair with [src]!</span>", \
									 	 "<span class='notice'>You start cutting [H]'s facial hair with [src], this might take a minute...</span>")
					if(do_after(user, 100, target = H))
						H.f_style = new_fstyle
						H.update_hair()
						user.visible_message("<span class='notice'>[user] finished cutting [H]'s facial hair</span>", \
									 	 	 "<span class='notice'>You finished cutting [src]'s facial hair</span>")
				return
			else
				to_chat(user, "<span class='notice'>You don't know how to cut the hair of this race!</span>")
				return

		else if(def_zone == BP_HEAD)
			if(H == user)
				to_chat(user, "<span class='notice'>You can't cut your hair</span>")
				return

			if(H.species.name in allowed_races)
				if(H.head && ((H.head.flags & BLOCKHAIR) || (H.head.flags & HIDEEARS)))
					to_chat(user, "<span class='warning'>The headgear is in the way!</span>")
					return

				if(H.h_style in bald_hair_styles_list)
					to_chat(user, "<span class='notice'>There are not enough hair to make a haircut</span>")
					return

				var/list/species_hair = list()
				if(H.species)
					for(var/i in hair_styles_list)
						var/datum/sprite_accessory/hair/tmp_hair = hair_styles_list[i]
						if(H.species.name in tmp_hair.species_allowed)
							species_hair += i
				else
					species_hair = hair_styles_list

				if(species_hair.len == 0)
					to_chat(user, "<span class='notice'>You don't know any hair styles for this race!</span>")
					return
				var/new_hstyle = input(usr, "Select a hair style", "Grooming") as null|anything in species_hair
				if(new_hstyle)
					user.visible_message("<span class='notice'>[user] starts cutting [H]'s hair with [src]!</span>", \
									 	 "<span class='notice'>You start cutting [H]'s hair with [src], this might take a minute...</span>")
					if(do_after(user, 100, target = H))
						H.h_style = new_hstyle
						H.update_hair()
						user.visible_message("<span class='notice'>[user] finished cutting [H]'s hair</span>", \
									 	 	 "<span class='notice'>You finished cutting [src]'s hair</span>")
				return
			else
				to_chat(user, "<span class='notice'>You don't know how to cut the hair of this race!</span>")
				return
		else
			..()
	else
		..()

/obj/item/weapon/hair_growth_accelerator
	name = "hair growth accelerator"
	desc = "Revive your hair."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cleaner"
	item_state = "cleaner"
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	var/list/bald_hair_styles_list = list("Bald", "Balding Hair", "Skinhead", "Unathi Horns", "Tajaran Ears")
	var/list/shaved_facial_hair_styles_list = list("Shaved")
	var/list/allowed_races = list(HUMAN, UNATHI, TAJARAN)

/obj/item/weapon/hair_growth_accelerator/attack(mob/M, mob/user, def_zone)
	if(user.a_intent == "hurt")
		..()
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		if(user.is_busy()) return

		if(def_zone == O_MOUTH)
			if(H.species.name in allowed_races)
				if((H.head && (H.head.flags & HEADCOVERSMOUTH)) || (H.wear_mask && (H.wear_mask.flags & MASKCOVERSMOUTH)))
					to_chat(user, "<span class='warning'>The mask is in the way!</span>")
					return

				var/list/species_facial_hair = list()
				if(H.species)
					for(var/i in facial_hair_styles_list)
						var/datum/sprite_accessory/hair/tmp_hair = facial_hair_styles_list[i]
						if(i in shaved_facial_hair_styles_list)
							continue
						if(H.species.name in tmp_hair.species_allowed)
							species_facial_hair += i
				else
					species_facial_hair = facial_hair_styles_list

				if(species_facial_hair.len == 0)
					to_chat(user, "<span class='notice'>You can't apply [src] to the face of this race!</span>")
					return
				var/random_facial_hair = pick(species_facial_hair)

				if(random_facial_hair)
					user.visible_message("<span class='notice'>[user] starts applying [src] to [H]'s face</span>", \
									 	 "<span class='notice'>You start applying [src] to [H]'s face</span>")
					if(do_after(user, 50, target = H))
						H.f_style = random_facial_hair
						H.update_hair()
						user.visible_message("<span class='notice'>[user] applied [src] to [H]'s face</span>", \
									 	 	 "<span class='notice'>You applied [src] to [H]'s face</span>")
				return
			else
				to_chat(user, "<span class='notice'>You can't use [src] on this race!</span>")
				return

		else if(def_zone == BP_HEAD)
			if(H.species.name in allowed_races)
				if(H.head && ((H.head.flags & BLOCKHAIR) || (H.head.flags & HIDEEARS)))
					to_chat(user, "<span class='warning'>The headgear is in the way!</span>")
					return

				var/list/species_hair = list()
				if(H.species)
					for(var/i in hair_styles_list)
						var/datum/sprite_accessory/hair/tmp_hair = hair_styles_list[i]
						if(i in bald_hair_styles_list)
							continue
						if(H.species.name in tmp_hair.species_allowed)
							species_hair += i
				else
					species_hair = hair_styles_list

				if(species_hair.len == 0)
					to_chat(user, "<span class='notice'>You can't apply [src] to the head of this race!</span>")
					return
				var/random_hair = pick(species_hair)

				if(random_hair)
					user.visible_message("<span class='notice'>[user] starts applying [src] to [H]'s head</span>", \
									 	 "<span class='notice'>You start applying [src] to [H]'s head</span>")
					if(do_after(user, 50, target = H))
						H.h_style = random_hair
						H.update_hair()
						user.visible_message("<span class='notice'>[user] applied [src] to [H]'s head</span>", \
									 	 	 "<span class='notice'>You applied [src] to [H]'s head</span>")
				return
			else
				to_chat(user, "<span class='notice'>You can't use [src] on this race!</span>")
				return
		else
			..()
	else
		..()

/obj/item/weapon/hair_color_spray
	name = "white hair color spray"
	desc = "Changes hair color."
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "weedspray"
	item_state = "spray"
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	var/list/bald_hair_styles_list = list("Bald", "Balding Hair", "Skinhead", "Unathi Horns", "Tajaran Ears")
	var/list/shaved_facial_hair_styles_list = list("Shaved")
	var/list/allowed_races = list(HUMAN, UNATHI, TAJARAN)
	var/spraycolor_r = 255
	var/spraycolor_g = 255
	var/spraycolor_b = 255
	var/spraymode = 0

/obj/item/weapon/hair_color_spray/attack_self(mob/user)
	spraymode = 1 - spraymode
	if(spraymode==0)
		to_chat(user, "<span class='notice'>You will fully paint</span>")
	else if(spraymode==1)
		to_chat(user, "<span class='notice'>You will add an accent color</span>")
	return

/obj/item/weapon/hair_color_spray/attack(mob/M, mob/user, def_zone)
	if(user.a_intent == "hurt")
		..()
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		if(user.is_busy()) return

		if(def_zone == O_MOUTH)
			if(H.species.name in allowed_races)
				if((H.head && (H.head.flags & HEADCOVERSMOUTH)) || (H.wear_mask && (H.wear_mask.flags & MASKCOVERSMOUTH)))
					to_chat(user, "<span class='warning'>The mask is in the way!</span>")
					return

				if(H.f_style in shaved_facial_hair_styles_list)
					to_chat(user, "<span class='notice'>You can't paint a shaved face</span>")
					return

				user.visible_message("<span class='notice'>[user] starts to paint [H]'s face hair with a [src]</span>", \
									 "<span class='notice'>You start painting [H]'s face hair with a [src]</span>")
				if(do_after(user, (100 - spraymode*80), target = H))
					if(spraymode == 0)
						H.r_facial = spraycolor_r
						H.g_facial = spraycolor_g
						H.b_facial = spraycolor_b
					else if(spraymode == 1)
						H.r_facial = round(H.r_facial*0.9 + spraycolor_r*0.1)
						H.g_facial = round(H.g_facial*0.9 + spraycolor_g*0.1)
						H.b_facial = round(H.b_facial*0.9 + spraycolor_b*0.1)
					H.update_hair()
					user.visible_message("<span class='notice'>[user] finished painting [H]'s face hair with a [src]</span>", \
									 	 "<span class='notice'>You finished painting [H]'s face hair with a [src]</span>")
				return
			else
				to_chat(user, "<span class='notice'>You can't paint this race!</span>")
				return
		else if(def_zone == BP_HEAD)
			if(H.species.name in allowed_races)
				if(H.head && ((H.head.flags & BLOCKHAIR) || (H.head.flags & HIDEEARS)))
					to_chat(user, "<span class='warning'>The headgear is in the way!</span>")
					return

				if(H.h_style in bald_hair_styles_list)
					to_chat(user, "<span class='notice'>You can't paint a bald head</span>")
					return

				user.visible_message("<span class='notice'>[user] starts to paint [H]'s head with a [src]</span>", \
									 "<span class='notice'>You start painting [H]'s head with a [src]</span>")
				if(do_after(user, (100 - spraymode*80), target = H))
					if(spraymode == 0)
						H.r_hair = spraycolor_r
						H.g_hair = spraycolor_g
						H.b_hair = spraycolor_b
					else if(spraymode == 1)
						H.r_hair = round(H.r_hair*0.9 + spraycolor_r*0.1)
						H.g_hair = round(H.g_hair*0.9 + spraycolor_g*0.1)
						H.b_hair = round(H.b_hair*0.9 + spraycolor_b*0.1)
					H.update_hair()
					user.visible_message("<span class='notice'>[user] finished painting [H]'s head with a [src]</span>", \
									 	 "<span class='notice'>You finished painting [H]'s head with a [src]</span>")
				return
			else
				to_chat(user, "<span class='notice'>You can't paint this race!</span>")
				return
		else
			..()
	else
		..()

/obj/item/weapon/hair_color_spray/red
	name = "red hair color spray"
	spraycolor_r = 255
	spraycolor_g = 0
	spraycolor_b = 0

/obj/item/weapon/hair_color_spray/blue
	name = "blue hair color spray"
	spraycolor_r = 0
	spraycolor_g = 0
	spraycolor_b = 255

/obj/item/weapon/hair_color_spray/green
	name = "green hair color spray"
	spraycolor_r = 0
	spraycolor_g = 255
	spraycolor_b = 0

/obj/item/weapon/hair_color_spray/black
	name = "black hair color spray"
	spraycolor_r = 0
	spraycolor_g = 0
	spraycolor_b = 0

/obj/item/weapon/hair_color_spray/brown
	name = "brown hair color spray"
	spraycolor_r = 50
	spraycolor_g = 0
	spraycolor_b = 0

/obj/item/weapon/hair_color_spray/blond
	name = "blond hair color spray"
	spraycolor_r = 255
	spraycolor_g = 225
	spraycolor_b = 135