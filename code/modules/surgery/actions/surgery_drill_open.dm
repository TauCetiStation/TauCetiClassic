/datum/surgery_step/surgery_drill
	name = "Check cavity in target"
	name = "Drill"
	priority = 1
	allowed_species = null

/datum/surgery_step/surgery_drill/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/I)
	if(!..())
		return FALSE
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(BP.open == BP_RIBCAGE_OS || (BP.open == BP_RETRACT_OS  && target_zone != BP_CHEST))
		return TRUE
	return FALSE

/datum/surgery_step/surgery_drill/proc/get_cavity(obj/item/organ/external/BP)
	switch (BP.body_zone)
		if (BP_HEAD)
			return "cranial"
		if (BP_CHEST)
			return "thoracic"
		if (BP_GROIN)
			return "abdominal"
	return ""

/datum/surgery_step/surgery_drill/proc/get_max_wclass(obj/item/organ/external/BP)
	switch (BP.body_zone)
		if (BP_HEAD)
			return 1
		if (BP_CHEST)
			return 3
		if (BP_GROIN)
			return 2
	return 0

/datum/surgery_step/surgery_drill/make_space
	name = "Make cavity in victim"
	allowed_qualities = list(
		QUALITY_SURGERY_DRILL
	)

	min_duration = 6 SECONDS
	max_duration = 8 SECONDS

/datum/surgery_step/surgery_drill/make_space/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/I)
	if(!..())
		return FALSE

	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(!BP.cavity && !BP.hidden)
		return TRUE
	return FALSE

/datum/surgery_step/surgery_drill/make_space/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/I)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	msg = "<span class='notice'>[user] starts making some space inside [target]'s [get_cavity(BP)] cavity with \the [I].</span>"
	self_msg = "<span class='notice'>You start making some space inside [target]'s [get_cavity(BP)] cavity with \the [I].</span>"
	user.visible_message(msg, self_msg)

	target.custom_pain("The pain in your chest is living hell!",1)
	BP.cavity = TRUE
	..()

/datum/surgery_step/surgery_drill/make_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/I)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	msg = "<span class='notice'>[user] makes some space inside [target]'s [get_cavity(BP)] cavity with \the [I].</span>"
	self_msg = "<span class='notice'>You make some space inside [target]'s [get_cavity(BP)] cavity with \the [I].</span>"
	user.visible_message(msg, self_msg)

/datum/surgery_step/surgery_drill/make_space/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/I)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	msg = "<span class='notice'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [I]!</span>"
	self_msg = "<span class='notice'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [I]!</span>"
	user.visible_message(msg, self_msg)
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, I)

/datum/surgery_step/surgery_drill/place_item
	name = "Place item into cavern"
	priority = 3
	allowed_tools = list(
		/obj/item = 100
		)

	min_duration = 8 SECONDS
	max_duration = 10 SECONDS

/datum/surgery_step/surgery_drill/place_item/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/I)
	if(!..())
		return FALSE

	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(!BP.hidden && BP.cavity && I.w_class <= get_max_wclass(BP))
		return TRUE

	return FALSE

/datum/surgery_step/surgery_drill/place_item/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/I)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	msg = "<span class='notice'>[user] starts putting \the [I] inside [target]'s [get_cavity(BP)] cavity.</span>"
	self_msg = "<span class='notice'>You start putting \the [I] inside [target]'s [get_cavity(BP)] cavity.</span>"
	user.visible_message(msg, self_msg)
	target.custom_pain("The pain in your chest is living hell!",1)
	..()

/datum/surgery_step/surgery_drill/place_item/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/I)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	msg = "<span class='notice'>[user] puts \the [I] inside [target]'s [get_cavity(BP)] cavity.</span>"
	self_msg = "<span class='notice'>You put \the [I] inside [target]'s [get_cavity(BP)] cavity.</span>"
	user.visible_message(msg, self_msg)
	if (I.w_class > get_max_wclass(BP)/2 && prob(50) && BP.sever_artery())
		to_chat(user, "<span class='warning'>You tear some blood vessels trying to fit such a big object in this cavity.</span>")
		BP.owner.custom_pain("You feel something rip in your [BP.name]!", 1)
	if(istype(I, /obj/item/gland))	//Abductor surgery integration
		if(target_zone != BP_CHEST)
			return
		else
			var/obj/item/gland/gland = I
			user.drop_from_inventory(gland, target)
			gland.Inject(target)
			BP.cavity = FALSE
			return
	user.drop_from_inventory(I, target)
	BP.hidden = I
	BP.cavity = FALSE
	I.item_actions_special = TRUE
	I.add_item_actions(target)

/datum/surgery_step/surgery_drill/place_item/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/I)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	msg = "<span class='notice'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [I]!</span>"
	self_msg = "<span class='notice'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [I]!</span>"
	user.visible_message(msg, self_msg)
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, I)
