//Procedures in this file: Putting items in body cavity. Implant removal. Items removal.

//////////////////////////////////////////////////////////////////
//					ITEM PLACEMENT SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/cavity
	priority = 1
	allowed_species = null

/datum/surgery_step/cavity/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	return BP && BP.open >= 2 && !(BP.status & ORGAN_BLEEDING) && (target_zone != BP_CHEST || target.op_stage.ribcage == 2)
/datum/surgery_step/cavity/proc/get_cavity(obj/item/organ/external/BP)
	switch (BP.body_zone)
		if (BP_HEAD)
			return "cranial"
		if (BP_CHEST)
			return "thoracic"
		if (BP_GROIN)
			return "abdominal"
	return ""
/datum/surgery_step/cavity/proc/get_max_wclass(obj/item/organ/external/BP)
	switch (BP.body_zone)
		if (BP_HEAD)
			return 1
		if (BP_CHEST)
			return 3
		if (BP_GROIN)
			return 2
	return 0
/datum/surgery_step/cavity/make_space
	allowed_tools = list(
	/obj/item/weapon/surgicaldrill = 100,	\
	/obj/item/weapon/pen = 75
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/cavity/make_space/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP && !BP.cavity && !BP.hidden

/datum/surgery_step/cavity/make_space/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts making some space inside [target]'s [get_cavity(BP)] cavity with \the [tool].", \
	"You start making some space inside [target]'s [get_cavity(BP)] cavity with \the [tool]." )
	target.custom_pain("The pain in your chest is living hell!",1)
	BP.cavity = 1
	..()

/datum/surgery_step/cavity/make_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] makes some space inside [target]'s [get_cavity(BP)] cavity with \the [tool].</span>", \
	"<span class='notice'>You make some space inside [target]'s [get_cavity(BP)] cavity with \the [tool].</span>" )

/datum/surgery_step/cavity/make_space/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/cavity/close_space
	priority = 2
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 50
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/cavity/close_space/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP && BP.cavity

/datum/surgery_step/cavity/close_space/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts mending [target]'s [get_cavity(BP)] cavity wall with \the [tool].", \
	"You start mending [target]'s [get_cavity(BP)] cavity wall with \the [tool]." )
	target.custom_pain("The pain in your chest is living hell!",1)
	BP.cavity = 0
	..()

/datum/surgery_step/cavity/close_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] mends [target]'s [get_cavity(BP)] cavity walls with \the [tool].</span>", \
	"<span class='notice'>You mend [target]'s [get_cavity(BP)] cavity walls with \the [tool].</span>" )

/datum/surgery_step/cavity/close_space/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(0, 20, used_weapon = tool)

/datum/surgery_step/cavity/place_item
	priority = 0
	allowed_tools = list(/obj/item = 100)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/cavity/place_item/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP && !BP.hidden && BP.cavity && tool.w_class <= get_max_wclass(BP)

/datum/surgery_step/cavity/place_item/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts putting \the [tool] inside [target]'s [get_cavity(BP)] cavity.", \
	"You start putting \the [tool] inside [target]'s [get_cavity(BP)] cavity." )
	target.custom_pain("The pain in your chest is living hell!",1)
	..()

/datum/surgery_step/cavity/place_item/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
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
			BP.cavity = 0
			return
	user.drop_from_inventory(tool, target)
	BP.hidden = tool
	BP.cavity = 0
	tool.item_actions_special = TRUE
	tool.add_item_actions(target)

/datum/surgery_step/cavity/place_item/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/chest/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)
