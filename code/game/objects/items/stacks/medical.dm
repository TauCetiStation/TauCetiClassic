/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/items.dmi'
	amount = 5
	max_amount = 5
	w_class = 2
	throw_speed = 4
	throw_range = 20
	var/heal_brute = 0
	var/heal_burn = 0

/obj/item/stack/medical/attack(mob/living/carbon/M, mob/user)
	if(!istype(M))
		to_chat(user, "<span class='warning'>\The [src] cannot be applied to [M]!</span>")
		return 1

	if(!(istype(user, /mob/living/carbon/human) || \
			istype(user, /mob/living/silicon) || \
			istype(user, /mob/living/carbon/monkey)) )
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.display_name == "head")
			if(H.head && istype(H.head,/obj/item/clothing/head/helmet/space))
				to_chat(user, "<span class='warning'>You can't apply [src] through [H.head]!</span>")
				return 1
		else
			if(H.wear_suit && istype(H.wear_suit,/obj/item/clothing/suit/space))
				to_chat(user, "<span class='warning'>You can't apply [src] through [H.wear_suit]!</span>")
				return 1

		if(affecting.status & ORGAN_ROBOT)
			to_chat(user, "<span class='warning'>This isn't useful at all on a robotic limb..</span>")
			return 1
	else
		M.heal_organ_damage((heal_brute/2), (heal_burn/2))
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

/obj/item/stack/medical/bruise_pack/attack(mob/living/carbon/M, mob/user)
	if(..())
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(affecting.is_bandaged())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been bandaged.</span>")
				return 1
			else
				user.visible_message("<span class='notice'>\The [user] starts treating [M]'s [affecting.display_name].</span>", \
									"<span class='notice'>You start treating [M]'s [affecting.display_name].</span>")
				var/used = 0
				for(var/datum/wound/W in affecting.wounds)
					if(W.internal)
						continue
					if(W.bandaged)
						continue
					if(used == amount)
						break
					if(!do_mob(user, M, W.damage))
						to_chat(user, "<span class='notice'>You must stand still to bandage wounds.</span>")
						break
					if(W.current_stage <= W.max_bleeding_stage)
						user.visible_message("<span class='notice'>\The [user] bandages [W.desc] on [M]'s [affecting.display_name].</span>", \
											"<span class='notice'>You bandage [W.desc] on [M]'s [affecting.display_name].</span>")
						//H.add_side_effect("Itch")
					else if (istype(W,/datum/wound/bruise))
						user.visible_message("<span class='notice'>\The [user] places bruise patch over [W.desc] on [M]'s [affecting.display_name].</span>", \
											"<span class='notice'>You place bruise patch over [W.desc] on [M]'s [affecting.display_name].</span>" )
					else
						user.visible_message("<span class='notice'>\The [user] places bandaid over [W.desc] on [M]'s [affecting.display_name].</span>", \
											"<span class='notice'>You place bandaid over [W.desc] on [M]'s [affecting.display_name].</span>")
					W.bandage()
					used++
				affecting.update_damages()
				if(used == amount)
					if(affecting.is_bandaged())
						to_chat(user, "<span class='warning'>\The [src] is used up.</span>")
					else
						to_chat(user, "<span class='warning'>\The [src] is used up, but there are more wounds to treat on \the [affecting.display_name].</span>")
				H.update_bandage()
				use(used)
		else
			if(can_operate(H))        //Checks if mob is lying down on table for surgery
				if(do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>The [affecting.display_name] is cut open, you'll need more than a bandage!</span>")

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	heal_burn = 1
	origin_tech = "biotech=1"

/obj/item/stack/medical/ointment/attack(mob/living/carbon/M, mob/user)
	if(..())
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(affecting.is_salved())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been salved.</span>")
				return 1
			else
				user.visible_message("<span class='notice'>\The [user] starts salving wounds on [M]'s [affecting.display_name].</span>", \
									"<span class='notice'>You start salving the wounds on [M]'s [affecting.display_name].</span>")
				if(!do_mob(user, M, 25))
					to_chat(user, "<span class='notice'>You must stand still to salve wounds.</span>")
					return 1
				user.visible_message("<span class='notice'>\The [user] salves wounds on [M]'s [affecting.display_name].</span>", \
									"<span class='notice'>You salve wounds on [M]'s [affecting.display_name].</span>")
				affecting.salve()
				use(1)
		else
			if(can_operate(H))        //Checks if mob is lying down on table for surgery
				if(do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>The [affecting.display_name] is cut open, you'll need more than a bandage!</span>")

/obj/item/stack/medical/bruise_pack/tajaran
	name = "\improper S'rendarr's Hand leaf"
	singular_name = "S'rendarr's Hand leaf"
	desc = "A poultice made of soft leaves that is rubbed on bruises."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "shandp"
	heal_brute = 7

/obj/item/stack/medical/ointment/tajaran
	name = "\improper Messa's Tear petals"
	singular_name = "Messa's Tear petals"
	desc = "A poultice made of cold, blue petals that is rubbed on burns."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "mtearp"
	heal_burn = 7

/obj/item/stack/medical/advanced/bruise_pack
	name = "advanced trauma kit"
	singular_name = "advanced trauma kit"
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "traumakit"
	heal_brute = 12
	origin_tech = "biotech=1"

/obj/item/stack/medical/advanced/bruise_pack/attack(mob/living/carbon/M, mob/user)
	if(..())
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(affecting.is_bandaged() && affecting.is_disinfected())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been treated.</span>")
				return 1
			else
				user.visible_message("<span class='notice'>\The [user] starts treating [M]'s [affecting.display_name].</span>", \
									"<span class='notice'>You start treating [M]'s [affecting.display_name].</span>")
				var/used = 0
				for(var/datum/wound/W in affecting.wounds)
					if(W.internal)
						continue
					if(W.bandaged && W.disinfected)
						continue
					if(used == amount)
						break
					if(!do_mob(user, M, W.damage))
						to_chat(user, "<span class='notice'>You must stand still to bandage wounds.</span>")
						break
					if(W.current_stage <= W.max_bleeding_stage)
						user.visible_message("<span class='notice'>\The [user] cleans [W.desc] on [M]'s [affecting.display_name] and seals edges with bioglue.</span>", \
											"<span class='notice'>You clean and seal [W.desc] on [M]'s [affecting.display_name].</span>")
					else if (istype(W,/datum/wound/bruise))
						user.visible_message("<span class='notice'>\The [user] places medicine patch over [W.desc] on [M]'s [affecting.display_name].</span>", \
											"<span class='notice'>You place medicine patch over [W.desc] on [M]'s [affecting.display_name].</span>")
					else
						user.visible_message("<span class='notice'>\The [user] smears some bioglue over [W.desc] on [M]'s [affecting.display_name].</span>", \
											"<span class='notice'>You smear some bioglue over [W.desc] on [M]'s [affecting.display_name].</span>")
					W.bandage()
					W.disinfect()
					W.heal_damage(heal_brute)
					used++
				affecting.update_damages()
				if(used == amount)
					if(affecting.is_bandaged())
						to_chat(user, "<span class='warning'>\The [src] is used up.</span>")
					else
						to_chat(user, "<span class='warning'>\The [src] is used up, but there are more wounds to treat on \the [affecting.display_name].</span>")
				H.update_bandage()
				use(used)
		else
			if(can_operate(H))        //Checks if mob is lying down on table for surgery
				if(do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>The [affecting.display_name] is cut open, you'll need more than a bandage!</span>")

/obj/item/stack/medical/advanced/ointment
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	icon_state = "burnkit"
	heal_burn = 12
	origin_tech = "biotech=1"

/obj/item/stack/medical/advanced/ointment/attack(mob/living/carbon/M, mob/user)
	if(..())
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 0)
			if(affecting.is_salved())
				to_chat(user, "<span class='warning'>The wounds on [M]'s [affecting.display_name] have already been salved.</span>")
				return 1
			else
				user.visible_message("<span class='notice'>\The [user] starts salving wounds on [M]'s [affecting.display_name].</span>", \
									"<span class='notice'>You start salving the wounds on [M]'s [affecting.display_name].</span>")
				if(!do_mob(user, M, 25))
					to_chat(user, "<span class='notice'>You must stand still to salve wounds.</span>")
					return 1
				user.visible_message("<span class='notice'>\The [user] covers wounds on [M]'s [affecting.display_name] with regenerative membrane.</span>", \
									"<span class='notice'>You cover wounds on [M]'s [affecting.display_name] with regenerative membrane.</span>")
				affecting.heal_damage(0,heal_burn)
				affecting.salve()
				use(1)
		else
			if(can_operate(H))        //Checks if mob is lying down on table for surgery
				if (do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>The [affecting.display_name] is cut open, you'll need more than a bandage!</span>")

/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	icon_state = "splint"
	amount = 5
	max_amount = 5

/obj/item/stack/medical/splint/attack(mob/living/carbon/M, mob/user)
	if(..())
		return 1

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)
		var/limb = affecting.display_name
		if(!((affecting.name == "l_arm") || (affecting.name == "r_arm") || (affecting.name == "l_leg") || (affecting.name == "r_leg")))
			to_chat(user, "<span class='danger'>You can't apply a splint there!</span>")
			return
		if(affecting.status & ORGAN_SPLINTED)
			to_chat(user, "<span class='danger'>[M]'s [limb] is already splinted!</span>")
			return
		if(M != user)
			user.visible_message("<span class='danger'>[user] starts to apply \the [src] to [M]'s [limb]</span>.", \
								"<span class='danger'>You start to apply \the [src] to [M]'s [limb].</span>", \
								"<span class='danger'>You hear something being wrapped.</span>")
		else
			if((!user.hand && affecting.name == "r_arm") || (user.hand && affecting.name == "l_arm"))
				to_chat(user, "<span class='danger'>You can't apply a splint to the arm you're using!</span>")
				return
			user.visible_message("<span class='danger'>[user] starts to apply \the [src] to their [limb].</span>", \
								"<span class='danger'>You start to apply \the [src] to your [limb].</span>", \
								"<span class='danger'>You hear something being wrapped.</span>")
		if(do_after(user, 50, target = M))
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
			affecting.status |= ORGAN_SPLINTED
			use(1)
		return
