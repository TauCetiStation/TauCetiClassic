//Procedures in this file: Putting items in body cavity. Implant removal. Items removal.

//////////////////////////////////////////////////////////////////
//					ITEM PLACEMENT SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/drill_open
	priority = 1
	allowed_species = null

/datum/surgery_step/drill_open/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(BP.open == BP_RIBCAGE_OS || (BP.open == BP_RETRACT_OS  && target_zone != BP_CHEST))
		return TRUE
	return FALSE

/datum/surgery_step/drill_open/proc/get_cavity(obj/item/organ/external/BP)
	switch (BP.body_zone)
		if (BP_HEAD)
			return "cranial"
		if (BP_CHEST)
			return "thoracic"
		if (BP_GROIN)
			return "abdominal"
	return ""

/datum/surgery_step/drill_open/proc/get_max_wclass(obj/item/organ/external/BP)
	switch (BP.body_zone)
		if (BP_HEAD)
			return 1
		if (BP_CHEST)
			return 3
		if (BP_GROIN)
			return 2
	return 0

/datum/surgery_step/drill_open/make_space
	allowed_qualities = list(
		QUALITY_DRILL_OPEN
	)

	min_duration = 6 SECONDS
	max_duration = 8 SECONDS

/datum/surgery_step/drill_open/make_space/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE

	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(!BP.cavity && !BP.hidden)
		return TRUE
	return FALSE

/datum/surgery_step/drill_open/make_space/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts making some space inside [target]'s [get_cavity(BP)] cavity with \the [tool].", \
	"You start making some space inside [target]'s [get_cavity(BP)] cavity with \the [tool]." )
	target.custom_pain("The pain in your chest is living hell!",1)
	BP.cavity = TRUE
	..()

/datum/surgery_step/drill_open/make_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] makes some space inside [target]'s [get_cavity(BP)] cavity with \the [tool].</span>", \
	"<span class='notice'>You make some space inside [target]'s [get_cavity(BP)] cavity with \the [tool].</span>" )

/datum/surgery_step/drill_open/make_space/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/drill_open/place_item
	priority = 3
	allowed_tools = list(
		/obj/item = 100
		)

	min_duration = 8 SECONDS
	max_duration = 10 SECONDS

/datum/surgery_step/drill_open/place_item/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE

	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(!BP.hidden && BP.cavity && tool.w_class <= get_max_wclass(BP))
		return TRUE

	return FALSE

/datum/surgery_step/drill_open/place_item/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts putting \the [tool] inside [target]'s [get_cavity(BP)] cavity.", \
	"You start putting \the [tool] inside [target]'s [get_cavity(BP)] cavity." )
	target.custom_pain("The pain in your chest is living hell!",1)
	..()

/datum/surgery_step/drill_open/place_item/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)

	user.visible_message("<span class='notice'>[user] puts \the [tool] inside [target]'s [get_cavity(BP)] cavity.</span>", \
	"<span class='notice'>You put \the [tool] inside [target]'s [get_cavity(BP)] cavity.</span>" )
	if (tool.w_class > get_max_wclass(BP)/2 && prob(50) && BP.sever_artery())
		to_chat(user, "<span class='warning'>You tear some blood vessels trying to fit such a big object in this cavity.</span>")
		BP.owner.custom_pain("You feel something rip in your [BP.name]!", 1)
	if(istype(tool, /obj/item/gland))	//Abductor surgery integration
		if(target_zone != BP_CHEST)
			return
		else
			var/obj/item/gland/gland = tool
			user.drop_from_inventory(gland, target)
			gland.Inject(target)
			BP.cavity = FALSE
			return
	user.drop_from_inventory(tool, target)
	BP.hidden = tool
	BP.cavity = FALSE
	tool.item_actions_special = TRUE
	tool.add_item_actions(target)

/datum/surgery_step/drill_open/place_item/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)
