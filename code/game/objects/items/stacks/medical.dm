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

	var/self_delay = 25
	var/other_delay = 5

	var/repeating = FALSE

	var/heal_brute = 0
	var/heal_burn = 0

/obj/item/stack/medical/update_weight()
	if(amount < 3)
		w_class = initial(w_class)
	else
		w_class = full_w_class

/obj/item/stack/medical/attack(mob/living/L, mob/living/user, def_zone)
	try_heal(L, user)

// Everything that should be done before healing process - sounds, message.
/obj/item/stack/medical/proc/announce_heal(mob/living/L, mob/user)
	var/to_self = L == user
	user.visible_message(
		"<span class='notice'>[user] starts to apply \the [src] on [to_self ? "themself" : L].</span>",
		"<span class='notice'>You begin applying \the [src] on [to_self ? "yourself" : L].</span>")

/obj/item/stack/medical/proc/can_heal(mob/living/L, mob/user)
	if(!istype(L))
		to_chat(user, "<span class='warning'>\The [src] cannot be applied to [L]!</span>")
		return FALSE
	if(user.is_busy())
		return FALSE
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the smarts to do this!</span>")
		return FALSE
	if(!L.can_inject(user, user.get_targetzone()))
		return FALSE
	return TRUE

/obj/item/stack/medical/proc/try_heal(mob/living/L, mob/user, silent = FALSE)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/organ/external/BP = H.get_bodypart(user.get_targetzone())
		if(BP.open)
			// Checks if mob is lying down on table for surgery
			if(can_operate(H))
				do_surgery(H, user, src)
			else
				to_chat(user, "<span class='notice'>The [BP.name] is cut open, you'll need more than [src]!</span>")
			return

	if(!can_heal(L, user))
		return

	var/delay = L == user ? self_delay : other_delay
	if(delay)
		if(!silent)
			announce_heal(L, user)
		if(!do_mob(user, L, time = self_delay, check_target_zone = TRUE))
			return

	if(heal(L, user) && use(1) && repeating && !zero_amount())
		try_heal(L, user, TRUE)
		return

	L.updatehealth()

// Return TRUE if any healing was actually done.
/obj/item/stack/medical/proc/heal(mob/living/L, mob/living/user)
	L.heal_bodypart_damage(heal_brute, heal_burn)
	user.visible_message(
		"<span class='notice'>[user] has applied [src] to [L].</span>",
		"<span class='notice'>You apply \the [src] to [L].</span>")

	if(heal_brute && L.getBruteLoss() > 0)
		return TRUE
	if(heal_burn && L.getFireLoss() > 0)
		return TRUE
	return FALSE

/obj/item/stack/medical/bruise_pack
	name = "roll of gauze"
	singular_name = "gauze length"
	desc = "Some sterile gauze to wrap around bloody stumps."
	icon_state = "brutepack"
	origin_tech = "biotech=1"

	repeating = TRUE
	heal_brute = 1

/obj/item/stack/medical/bruise_pack/announce_heal(mob/living/L, mob/user)
	..()
	playsound(src, pick(SOUNDIN_BANDAGE), VOL_EFFECTS_MASTER, 15)

/obj/item/stack/medical/bruise_pack/can_heal(mob/living/L, mob/living/user)
	. = ..()
	if(!.)
		return

	if(!ishuman(L))
		return

	var/mob/living/carbon/human/H = L
	var/obj/item/organ/external/BP = H.get_bodypart(user.get_targetzone())
	if(BP.is_bandaged())
		to_chat(user, "<span class='warning'>The wounds on [H]'s [BP.name] have already been bandaged.</span>")
		return FALSE

/obj/item/stack/medical/bruise_pack/heal(mob/living/L, mob/living/user)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/organ/external/BP = H.get_bodypart(user.get_targetzone())

		for(var/datum/wound/W in BP.wounds)
			if(W.bandaged)
				continue
			if(W.current_stage <= W.max_bleeding_stage)
				user.visible_message("<span class='notice'>\The [user] bandages [W.desc] on [H]'s [BP.name].</span>", \
									"<span class='notice'>You bandage [W.desc] on [H]'s [BP.name].</span>")
				//H.add_side_effect("Itch")
			else if (istype(W,/datum/wound/bruise))
				user.visible_message("<span class='notice'>\The [user] places bruise patch over [W.desc] on [H]'s [BP.name].</span>", \
									"<span class='notice'>You place bruise patch over [W.desc] on [H]'s [BP.name].</span>" )
			else
				user.visible_message("<span class='notice'>\The [user] places bandaid over [W.desc] on [H]'s [BP.name].</span>", \
									"<span class='notice'>You place bandaid over [W.desc] on [H]'s [BP.name].</span>")
			W.bandage()
			if(crit_fail)
				W.germ_level += germ_level
			else
				W.germ_level += min(germ_level, 3)
			break

			BP.update_damages()
			H.update_bandage()
			return TRUE
	return ..()

/obj/item/stack/medical/bruise_pack/update_icon()
	var/icon_amount = min(amount, max_amount)
	icon_state = "[initial(icon_state)][icon_amount]"

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burns."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	origin_tech = "biotech=1"

	repeating = TRUE
	heal_burn = 1

/obj/item/stack/medical/ointment/can_heal(mob/living/L, mob/living/user)
	. = ..()
	if(!.)
		return

	if(!ishuman(L))
		return

	var/mob/living/carbon/human/H = L
	var/obj/item/organ/external/BP = H.get_bodypart(user.get_targetzone())
	if(BP.is_salved())
		to_chat(user, "<span class='warning'>The wounds on [H]'s [BP.name] have already been salved.</span>")
		return FALSE

/obj/item/stack/medical/ointment/heal(mob/living/L, mob/living/user)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/organ/external/BP = H.get_bodypart(user.get_targetzone())

		user.visible_message("<span class='notice'>\The [user] salves wounds on [H]'s [BP.name].</span>",
							"<span class='notice'>You salve wounds on [H]'s [BP.name].</span>")
		BP.salve()
		return TRUE
	return ..()

/obj/item/stack/medical/ointment/update_icon()
	var/icon_amount = min(amount, max_amount)
	icon_state = "[initial(icon_state)][icon_amount]"

/obj/item/stack/medical/bruise_pack/tajaran
	name = "S'rendarr's Hand leaf"
	singular_name = "S'rendarr's Hand leaf"
	desc = "A poultice made of soft leaves that is rubbed on bruises."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "shandp"
	heal_brute = 7

/obj/item/stack/medical/bruise_pack/tajaran/update_icon()
	return

/obj/item/stack/medical/ointment/tajaran
	name = "Messa's Tear petals"
	singular_name = "Messa's Tear petals"
	desc = "A poultice made of cold, blue petals that is rubbed on burns."
	icon = 'icons/obj/hydroponics/harvest.dmi'
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

	other_delay = 10

	repeating = TRUE

/obj/item/stack/medical/advanced/bruise_pack/update_icon()
	icon_state = "[initial(icon_state)][amount]"

/obj/item/stack/medical/advanced/bruise_pack/announce_heal(mob/living/L, mob/user)
	..()
	playsound(src, pick(SOUNDIN_BANDAGE), VOL_EFFECTS_MASTER, 15)

/obj/item/stack/medical/advanced/bruise_pack/can_heal(mob/living/L, mob/living/user)
	. = ..()
	if(!.)
		return

	if(!ishuman(L))
		return

	var/mob/living/carbon/human/H = L
	var/obj/item/organ/external/BP = H.get_bodypart(user.get_targetzone())
	if(BP.is_bandaged() && BP.is_disinfected())
		to_chat(user, "<span class='warning'>The wounds on [L]'s [BP.name] have already been treated.</span>")
		return FALSE

/obj/item/stack/medical/advanced/bruise_pack/heal(mob/living/L, mob/living/user)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/organ/external/BP = H.get_bodypart(user.get_targetzone())

		for(var/datum/wound/W in BP.wounds)
			if(W.bandaged && W.disinfected)
				continue
			if(W.current_stage <= W.max_bleeding_stage)
				user.visible_message("<span class='notice'>\The [user] cleans [W.desc] on [H]'s [BP.name] and seals edges with bioglue.</span>", \
									"<span class='notice'>You clean and seal [W.desc] on [H]'s [BP.name].</span>")
			else if (istype(W,/datum/wound/bruise))
				user.visible_message("<span class='notice'>\The [user] places medicine patch over [W.desc] on [H]'s [BP.name].</span>", \
									"<span class='notice'>You place medicine patch over [W.desc] on [H]'s [BP.name].</span>")
			else
				user.visible_message("<span class='notice'>\The [user] smears some bioglue over [W.desc] on [H]'s [BP.name].</span>", \
									"<span class='notice'>You smear some bioglue over [W.desc] on [H]'s [BP.name].</span>")
			W.bandage()
			W.disinfect()
			W.heal_damage(heal_brute)
			break

		BP.update_damages()
		H.update_bandage()
		return TRUE
	return ..()

/obj/item/stack/medical/advanced/ointment
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	icon_state = "burnkit"
	amount = 6
	max_amount = 6
	heal_burn = 12
	origin_tech = "biotech=1"

	other_delay = 10

	repeating = TRUE

/obj/item/stack/medical/advanced/ointment/update_icon()
	icon_state = "[initial(icon_state)][amount]"

/obj/item/stack/medical/advanced/ointment/can_heal(mob/living/L, mob/living/user)
	. = ..()
	if(!.)
		return

	if(!ishuman(L))
		return

	var/mob/living/carbon/human/H = L
	var/obj/item/organ/external/BP = H.get_bodypart(user.get_targetzone())
	if(BP.is_salved())
		to_chat(user, "<span class='warning'>The wounds on [H]'s [BP.name] have already been salved.</span>")
		return FALSE

/obj/item/stack/medical/advanced/ointment/heal(mob/living/L, mob/living/user)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/organ/external/BP = H.get_bodypart(user.get_targetzone())

		user.visible_message("<span class='notice'>\The [user] covers wounds on [H]'s [BP.name] with regenerative membrane.</span>", \
							"<span class='notice'>You cover wounds on [H]'s [BP.name] with regenerative membrane.</span>")
		BP.heal_damage(0, heal_burn)
		BP.salve()
		return TRUE
	return ..()

/obj/item/stack/medical/splint
	name = "medical splints"
	singular_name = "medical splint"
	icon_state = "splint"
	amount = 5
	max_amount = 5
	w_class = ITEM_SIZE_SMALL
	full_w_class = ITEM_SIZE_SMALL

	self_delay = 50
	other_delay = 25

	repeating = FALSE

/obj/item/stack/medical/splint/can_heal(mob/living/L, mob/living/user)
	. = ..()
	if(!.)
		return

	if(!ishuman(L))
		return

	var/mob/living/carbon/human/H = L
	var/obj/item/organ/external/BP = H.get_bodypart(user.get_targetzone())

	if(BP.body_zone == BP_HEAD || BP.body_zone == BP_CHEST || BP.body_zone == BP_GROIN)
		to_chat(user, "<span class='danger'>You can't apply a splint there!</span>")
		return FALSE
	if(BP.status & ORGAN_SPLINTED)
		to_chat(user, "<span class='danger'>[H]'s [BP.name] is already splinted!</span>")
		return FALSE
	if(H == user && ((user.hand && BP.body_zone != BP_R_ARM) || (user.hand && BP.body_zone != BP_L_ARM)))
		to_chat(user, "<span class='danger'>You can't apply a splint to the arm you're using!</span>")
		return FALSE

/obj/item/stack/medical/splint/heal(mob/living/L, mob/user)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/organ/external/BP = H.get_bodypart(user.get_targetzone())

		if(H != user)
			user.visible_message("<span class='danger'>[user] finishes applying \the [src] to [H]'s [BP.name].</span>", \
								"<span class='danger'>You finish applying \the [src] to [H]'s [BP.name].</span>", \
								"<span class='danger'>You hear something being wrapped.</span>")
		else
			user.visible_message("<span class='danger'>[user] successfully applies \the [src] to their [BP.name].</span>", \
								"<span class='danger'>You successfully apply \the [src] to your [BP.name].</span>", \
								"<span class='danger'>You hear something being wrapped.</span>")
		BP.status |= ORGAN_SPLINTED
		return TRUE
	return FALSE

/obj/item/stack/medical/suture
	name = "suture kit"
	singular_name = "suture kit"
	desc = "A little nanobot-controlled needle that fixes anything bleeding related, including internal bleedings!"
	icon_state = "suture"
	amount = 3
	max_amount = 3
	origin_tech = "biotech=2"

	self_delay = 20
	other_delay = 5

	repeating = FALSE

/obj/item/stack/medical/suture/update_icon()
	icon_state = "[initial(icon_state)][amount]"

/obj/item/stack/medical/suture/heal(mob/living/L, mob/living/user)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/organ/external/BP = H.get_bodypart(user.get_targetzone())

		// Suturing yourself brings much more pain.
		var/pain_factor = H == user ? 40 : 20
		if(H.stat == CONSCIOUS)
			H.shock_stage += pain_factor
		BP.status &= ~ORGAN_ARTERY_CUT
		BP.strap()
		user.visible_message(
			"<span class='notice'>[user] has stitched [L]'s [BP.name] with [src].</span>",
			"<span class='notice'>You have stitched [L]'s [BP.name] with [src].</span>")
		return TRUE
	return ..()
