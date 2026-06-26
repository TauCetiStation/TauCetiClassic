//////////////////////////////////////////////////////////////////
//						Lipoplasty								//
//////////////////////////////////////////////////////////////////
/datum/surgery_status
	var/lipoplasty = 0

/datum/surgery_step/lipoplasty
	priority = 2
	can_infect = 1
	blood_level = 1

/datum/surgery_step/lipoplasty/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	return target_zone == BP_CHEST

/datum/surgery_step/lipoplasty/cut_fat
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/hatchet = 75,       \
	/obj/item/weapon/crowbar = 50
	)

	min_duration = 110
	max_duration = 150

/datum/surgery_step/lipoplasty/cut_fat/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!target.has_quirk(/datum/quirk/fatness))
		user.visible_message("[user] begins to cut away [target]'s excess fat with \the [tool].",
			"You begin to cut away [target]'s excess fat with \the [tool].")
		if (target.overeatduration > 0)
			target.custom_pain("Something hurts horribly in your chest!", 1)
	else
		user.visible_message("[user] starts inspecting [target]'s body.",
			"You begin inspecting [target]'s body.")
	..()

/datum/surgery_step/lipoplasty/cut_fat/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!target.has_quirk(/datum/quirk/fatness))
		if (target.overeatduration > 0)
			user.visible_message("<span class='notice'>[user] cuts [target]'s excess fat loose with \the [tool].</span>",
				"<span class='notice'>You have cut [target]'s excess fat loose with \the [tool].</span>")
			target.op_stage.lipoplasty = 1
		else
			user.visible_message("<span class='notice'>Unfortunately, there is nothing to cut on [target] with \the [tool].</span>",
				"<span class='notice'>Unfortunately, there is nothing to cut on [target] with \the [tool].</span>")
	else
		user.visible_message("<span class='notice'>[user] realizes, that there is no known solution to resolve [target]'s fatness problem.</span>",
			"<span class='notice'>Unfortunately, there is nothing you can do with the [target]'s excess fat.</span>")

/datum/surgery_step/lipoplasty/cut_fat/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='red'>[user]'s hand slips, cutting [target]'s chest with \the [tool]!</span>",
		"<span class='red'>Your hand slips, cutting [target]'s chest with \the [tool]!</span>")
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	BP.take_damage(30, 0, DAM_SHARP|DAM_EDGE, tool)
