//Procedures in this file: Fracture repair surgery
//////////////////////////////////////////////////////////////////
//						BONE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/glue_bone
	allowed_tools = list(
	/obj/item/weapon/bonegel = 100,	\
	/obj/item/stack/rods = 50
	)
	can_infect = 1
	blood_level = 1

	min_duration = 50
	max_duration = 60

/datum/surgery_step/glue_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	return BP && BP.open >= 2 && BP.stage == 0

/datum/surgery_step/glue_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (BP.stage == 0)
		user.visible_message("[user] starts applying medication to the damaged bones in [target]'s [BP.name] with \the [tool]." , \
		"You start applying medication to the damaged bones in [target]'s [BP.name] with \the [tool].")
	target.custom_pain("Something in your [BP.name] is causing you a lot of pain!",1)
	..()

/datum/surgery_step/glue_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] applies some [tool] to [target]'s bone in [BP.name]</span>", \
		"<span class='notice'>You apply some [tool] to [target]'s bone in [BP.name] with \the [tool].</span>")
	BP.stage = 1

/datum/surgery_step/glue_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>" , \
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>")

/datum/surgery_step/set_bone
	allowed_tools = list(
	/obj/item/weapon/bonesetter = 100,	\
	/obj/item/weapon/wrench = 75		\
	)

	min_duration = 60
	max_duration = 70

/datum/surgery_step/set_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	return BP && BP.body_zone != BP_HEAD && BP.open >= 2 && BP.stage == 1

/datum/surgery_step/set_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] is beginning to set the bone in [target]'s [BP.name] in place with \the [tool]." , \
		"You are beginning to set the bone in [target]'s [BP.name] in place with \the [tool].")
	target.custom_pain("The pain in your [BP.name] is going to make you pass out!",1)
	..()

/datum/surgery_step/set_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (BP.status & ORGAN_BROKEN)
		user.visible_message("<span class='notice'>[user] sets the bone in [target]'s [BP.name] in place with \the [tool].</span>", \
			"<span class='notice'>You set the bone in [target]'s [BP.name] in place with \the [tool].</span>")
		BP.stage = 2
	else
		user.visible_message("<span class='notice'>[user] sets the bone in [target]'s [BP.name]<span class='warning'> in the WRONG place with \the [tool].</span></span>", \
			"<span class='notice'>You set the bone in [target]'s [BP.name]<span class='warning'> in the WRONG place with \the [tool].</span></span>")
		BP.fracture()

/datum/surgery_step/set_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging the bone in [target]'s [BP.name] with \the [tool]!</span>" , \
		"<span class='warning'>Your hand slips, damaging the bone in [target]'s [BP.name] with \the [tool]!</span>")
	BP.take_damage(5, 0, used_weapon = tool)

/datum/surgery_step/mend_skull
	allowed_tools = list(
	/obj/item/weapon/bonesetter = 100,	\
	/obj/item/weapon/wrench = 75		\
	)

	min_duration = 60
	max_duration = 70

/datum/surgery_step/mend_skull/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	return BP && BP.body_zone == BP_HEAD && BP.open >= 2 && BP.stage == 1

/datum/surgery_step/mend_skull/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning to piece together [target]'s skull with \the [tool]."  , \
		"You are beginning to piece together [target]'s skull with \the [tool].")
	..()

/datum/surgery_step/mend_skull/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] sets [target]'s skull with \the [tool].</span>" , \
		"<span class='notice'>You set [target]'s skull with \the [tool].</span>")
	BP.stage = 2

/datum/surgery_step/mend_skull/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s face with \the [tool]!</span>"  , \
		"<span class='warning'>Your hand slips, damaging [target]'s face with \the [tool]!</span>")
	var/obj/item/organ/external/head/H = BP
	H.take_damage(10, 0, used_weapon = tool)
	H.disfigured = 1

/datum/surgery_step/finish_bone
	allowed_tools = list(
	/obj/item/weapon/bonegel = 100,	\
	/obj/item/stack/rods = 50
	)
	can_infect = 1
	blood_level = 1

	min_duration = 50
	max_duration = 60

/datum/surgery_step/finish_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))	return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	return BP && BP.open >= 2 && BP.stage == 2

/datum/surgery_step/finish_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts to finish mending the damaged bones in [target]'s [BP.name] with \the [tool].", \
	"You start to finish mending the damaged bones in [target]'s [BP.name] with \the [tool].")
	..()

/datum/surgery_step/finish_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] has mended the damaged bones in [target]'s [BP.name] with \the [tool].</span>"  , \
		"<span class='notice'>You have mended the damaged bones in [target]'s [BP.name] with \the [tool].</span>" )
	BP.status &= ~(ORGAN_BROKEN | ORGAN_SPLINTED)
	BP.stage = 0
	BP.perma_injury = 0

/datum/surgery_step/finish_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>" , \
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [BP.name]!</span>")
