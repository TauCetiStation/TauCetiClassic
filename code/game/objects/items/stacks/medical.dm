/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/items.dmi'
	amount = 5
	max_amount = 5
	w_class = ITEM_SIZE_TINY
	full_w_class = ITEM_SIZE_SMALL
	throw_speed = 4
	throw_range = 20
	var/heal_brute = 0
	var/heal_burn = 0

/obj/item/stack/medical/update_weight()
	if(amount < 3)
		w_class = initial(w_class)
	else
		w_class = full_w_class

/obj/item/stack/medical/attack(mob/living/carbon/M, mob/user, def_zone)
	if(!istype(M))
		to_chat(user, "<span class='warning'>\The [src] cannot be applied to [M]!</span>")
		return 1

	if(user.is_busy())
		return 1

	if(!(ishuman(user) || issilicon(user) || ismonkey(user)) )
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/BP = H.get_bodypart(def_zone)

		if(BP.body_zone == BP_HEAD)
			if(H.head && istype(H.head,/obj/item/clothing/head/helmet/space))
				to_chat(user, "<span class='warning'>You can't apply [src] through [H.head]!</span>")
				return 1
		else
			if(H.wear_suit && istype(H.wear_suit,/obj/item/clothing/suit/space))
				to_chat(user, "<span class='warning'>You can't apply [src] through [H.wear_suit]!</span>")
				return 1

		if(BP.status & ORGAN_ROBOT)
			to_chat(user, "<span class='warning'>This isn't useful at all on a robotic limb..</span>")
			return 1
	else
		M.heal_bodypart_damage(heal_brute / 2, heal_burn / 2)
		user.visible_message("<span class='notice'>[M] has been applied with [src] by [user].</span>", \
							"<span class='notice'>You apply \the [src] to [M].</span>")
		use(1)
	M.updatehealth()

/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "gauze length"
	desc = "Some sterile gauze to wrap around bloody stumps."
	icon_state = "brutepack"
	origin_tech = "biotech=1"

/obj/item/stack/medical/bruise_pack/attack(mob/living/carbon/M, mob/user, def_zone)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/BP = H.get_bodypart(def_zone)

		if(BP.open == 0)
			if(BP.is_bandaged())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [BP.name] have already been bandaged.</span>")
				return 1
			else
				playsound(src, "bandg", 15, 1)
				user.visible_message("<span class='notice'>\The [user] starts treating [M]'s [BP.name].</span>", \
									"<span class='notice'>You start treating [M]'s [BP.name].</span>")

				for(var/datum/wound/W in BP.wounds)
					if(W.bandaged)
						continue
					if(!use(1))
						break
					if(!do_mob(user, M, W.damage))
						to_chat(user, "<span class='notice'>You must stand still to bandage wounds.</span>")
						break
					if(W.current_stage <= W.max_bleeding_stage)
						user.visible_message("<span class='notice'>\The [user] bandages [W.desc] on [M]'s [BP.name].</span>", \
											"<span class='notice'>You bandage [W.desc] on [M]'s [BP.name].</span>")
						//H.add_side_effect("Itch")
					else if (istype(W,/datum/wound/bruise))
						user.visible_message("<span class='notice'>\The [user] places bruise patch over [W.desc] on [M]'s [BP.name].</span>", \
											"<span class='notice'>You place bruise patch over [W.desc] on [M]'s [BP.name].</span>" )
					else
						user.visible_message("<span class='notice'>\The [user] places bandaid over [W.desc] on [M]'s [BP.name].</span>", \
											"<span class='notice'>You place bandaid over [W.desc] on [M]'s [BP.name].</span>")
					W.bandage()
					if(crit_fail)
						W.germ_level += germ_level
					else
						W.germ_level += min(germ_level, 3)

				BP.update_damages()
				H.update_bandage()

				if(BP.is_bandaged())
					to_chat(user, "<span class='warning'>\The [src] is used up.</span>")
				else
					to_chat(user, "<span class='warning'>\The [src] is used up, but there are more wounds to treat on \the [BP.name].</span>")

		else
			if(can_operate(H))        //Checks if mob is lying down on table for surgery
				if(do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>The [BP.name] is cut open, you'll need more than a bandage!</span>")

/obj/item/stack/medical/bruise_pack/update_icon()
	icon_state = "[initial(icon_state)][amount]"

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	heal_burn = 1
	origin_tech = "biotech=1"

/obj/item/stack/medical/ointment/attack(mob/living/carbon/M, mob/user, def_zone)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/BP = H.get_bodypart(def_zone)

		if(BP.open == 0)
			if(BP.is_salved())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [BP.name] have already been salved.</span>")
				return 1
			else
				user.visible_message("<span class='notice'>\The [user] starts salving wounds on [M]'s [BP.name].</span>", \
									"<span class='notice'>You start salving the wounds on [M]'s [BP.name].</span>")
				if(!do_mob(user, M, 25))
					to_chat(user, "<span class='notice'>You must stand still to salve wounds.</span>")
					return 1

				if(!use(1))
					to_chat(user, "<span class='danger'>You need more ointment to do this.</span>")
					return

				user.visible_message("<span class='notice'>\The [user] salves wounds on [M]'s [BP.name].</span>", \
									"<span class='notice'>You salve wounds on [M]'s [BP.name].</span>")
				BP.salve()
		else
			if(can_operate(H))        //Checks if mob is lying down on table for surgery
				if(do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>The [BP.name] is cut open, you'll need more than a bandage!</span>")

/obj/item/stack/medical/ointment/update_icon()
	icon_state = "[initial(icon_state)][amount]"

/obj/item/stack/medical/bruise_pack/tajaran
	name = "\improper S'rendarr's Hand leaf"
	singular_name = "S'rendarr's Hand leaf"
	desc = "A poultice made of soft leaves that is rubbed on bruises."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "shandp"
	heal_brute = 7

/obj/item/stack/medical/bruise_pack/tajaran/update_icon()
	return

/obj/item/stack/medical/ointment/tajaran
	name = "\improper Messa's Tear petals"
	singular_name = "Messa's Tear petals"
	desc = "A poultice made of cold, blue petals that is rubbed on burns."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "mtearp"
	heal_burn = 7

/obj/item/stack/medical/ointment/tajaran/update_icon()
	return

/obj/item/stack/medical/advanced/bruise_pack
	name = "advanced trauma kit"
	singular_name = "advanced trauma kit"
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "traumakit"
	heal_brute = 12
	amount = 6
	max_amount = 6
	origin_tech = "biotech=1"

/obj/item/stack/medical/advanced/bruise_pack/update_icon()
	icon_state = "[initial(icon_state)][amount]"

/obj/item/stack/medical/advanced/bruise_pack/attack(mob/living/carbon/M, mob/user, def_zone)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/BP = H.get_bodypart(def_zone)

		if(BP.open == 0)
			if(BP.is_bandaged() && BP.is_disinfected())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [BP.name] have already been treated.</span>")
				return 1
			else
				playsound(src, "bandg", 15, 1)
				user.visible_message("<span class='notice'>\The [user] starts treating [M]'s [BP.name].</span>", \
									"<span class='notice'>You start treating [M]'s [BP.name].</span>")

				for(var/datum/wound/W in BP.wounds)
					if(W.bandaged && W.disinfected)
						continue
					if(!use(1))
						break
					update_icon()
					if(!do_mob(user, M, W.damage))
						to_chat(user, "<span class='notice'>You must stand still to bandage wounds.</span>")
						break
					if(W.current_stage <= W.max_bleeding_stage)
						user.visible_message("<span class='notice'>\The [user] cleans [W.desc] on [M]'s [BP.name] and seals edges with bioglue.</span>", \
											"<span class='notice'>You clean and seal [W.desc] on [M]'s [BP.name].</span>")
					else if (istype(W,/datum/wound/bruise))
						user.visible_message("<span class='notice'>\The [user] places medicine patch over [W.desc] on [M]'s [BP.name].</span>", \
											"<span class='notice'>You place medicine patch over [W.desc] on [M]'s [BP.name].</span>")
					else
						user.visible_message("<span class='notice'>\The [user] smears some bioglue over [W.desc] on [M]'s [BP.name].</span>", \
											"<span class='notice'>You smear some bioglue over [W.desc] on [M]'s [BP.name].</span>")
					W.bandage()
					W.disinfect()
					W.heal_damage(heal_brute)

				BP.update_damages()
				H.update_bandage()

				if(BP.is_bandaged())
					to_chat(user, "<span class='warning'>\The [src] is used up.</span>")
				else
					to_chat(user, "<span class='warning'>\The [src] is used up, but there are more wounds to treat on \the [BP.name].</span>")

		else
			if(can_operate(H))        //Checks if mob is lying down on table for surgery
				if(do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>The [BP.name] is cut open, you'll need more than a bandage!</span>")

/obj/item/stack/medical/advanced/ointment
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	icon_state = "burnkit"
	amount = 6
	max_amount = 6
	heal_burn = 12
	origin_tech = "biotech=1"

/obj/item/stack/medical/advanced/ointment/update_icon()
	icon_state = "[initial(icon_state)][amount]"

/obj/item/stack/medical/advanced/ointment/attack(mob/living/carbon/M, mob/user, def_zone)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/BP = H.get_bodypart(def_zone)

		if(BP.open == 0)
			if(BP.is_salved())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [BP.name] have already been salved.</span>")
				return 1
			else
				user.visible_message("<span class='notice'>\The [user] starts salving wounds on [M]'s [BP.name].</span>", \
									"<span class='notice'>You start salving the wounds on [M]'s [BP.name].</span>")

				if(!do_mob(user, M, 25))
					to_chat(user, "<span class='notice'>You must stand still to salve wounds.</span>")
					return 1

				if(!use(1))
					to_chat(user, "<span class='danger'>You need more advanced burn kit's to do this.</span>")
					return
				update_icon()
				user.visible_message("<span class='notice'>\The [user] covers wounds on [M]'s [BP.name] with regenerative membrane.</span>", \
									"<span class='notice'>You cover wounds on [M]'s [BP.name] with regenerative membrane.</span>")
				BP.heal_damage(0, heal_burn)
				BP.salve()

		else
			if(can_operate(H))        //Checks if mob is lying down on table for surgery
				if (do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>The [BP.name] is cut open, you'll need more than a bandage!</span>")

/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	icon_state = "splint"
	amount = 5
	max_amount = 5
	w_class = ITEM_SIZE_SMALL
	full_w_class = ITEM_SIZE_SMALL

/obj/item/stack/medical/splint/attack(mob/living/carbon/M, mob/user, def_zone)
	if(..())
		return 1

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/BP = H.get_bodypart(def_zone)
		var/limb = BP.name
		if(!((BP.body_zone == BP_L_ARM) || (BP.body_zone == BP_R_ARM) || (BP.body_zone == BP_L_LEG) || (BP.body_zone == BP_R_LEG)))
			to_chat(user, "<span class='danger'>You can't apply a splint there!</span>")
			return
		if(BP.status & ORGAN_SPLINTED)
			to_chat(user, "<span class='danger'>[M]'s [limb] is already splinted!</span>")
			return

		if(M != user)
			user.visible_message("<span class='danger'>[user] starts to apply \the [src] to [M]'s [limb]</span>.", \
								"<span class='danger'>You start to apply \the [src] to [M]'s [limb].</span>", \
								"<span class='danger'>You hear something being wrapped.</span>")
		else
			if((!user.hand && BP.body_zone == BP_R_ARM) || (user.hand && BP.body_zone == BP_L_ARM))
				to_chat(user, "<span class='danger'>You can't apply a splint to the arm you're using!</span>")
				return
			user.visible_message("<span class='danger'>[user] starts to apply \the [src] to their [limb].</span>", \
								"<span class='danger'>You start to apply \the [src] to your [limb].</span>", \
								"<span class='danger'>You hear something being wrapped.</span>")
		if(!user.is_busy() && do_after(user, 50, target = M))
			if(!use(1))
				to_chat(user, "<span class='danger'>You need more splints's to do this.</span>")
				return

			if(M != user)
				user.visible_message("<span class='danger'>[user] finishes applying \the [src] to [M]'s [limb].</span>", \
									"<span class='danger'>You finish applying \the [src] to [M]'s [limb].</span>", \
									"<span class='danger'>You hear something being wrapped.</span>")
			else
				if(prob(25))
					user.visible_message("<span class='danger'>[user] successfully applies \the [src] to their [limb].</span>", \
										"<span class='danger'>You successfully apply \the [src] to your [limb].</span>", \
										"<span class='danger'>You hear something being wrapped.</span>")
				else
					user.visible_message("<span class='danger'>[user] fumbles \the [src].", \
										"<span class='danger'>You fumble \the [src].</span>", \
										"<span class='danger'>You hear something being wrapped.</span>")
					return
			BP.status |= ORGAN_SPLINTED

		return
