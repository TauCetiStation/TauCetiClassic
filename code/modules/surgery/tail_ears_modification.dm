//Procedures in this file: detachment and attachment of tails and ears.
//////////////////////////////////////////////////////////////////
//						TAIL DETACHMENT							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/tail
	can_infect = 1

/datum/surgery_step/tail/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasbodyparts(target))
		return 0

	var/obj/item/bodypart/groin/BP = target.get_bodypart(target_zone)
	if (!istype(BP) || (BP.status & ORGAN_ROBOT))
		return 0

	return TRUE

/datum/surgery_step/tail/sever_tail
	allowed_tools = list(
		 /obj/item/weapon/scalpel = 100
		,/obj/item/weapon/circular_saw = 100
		,/obj/item/weapon/hatchet = 75
		,/obj/item/weapon/shard = 50
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/tail/sever_tail/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/groin/BP = target.get_bodypart(target_zone)
	return ..() && BP.tail

/datum/surgery_step/tail/sever_tail/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to sever [target]'s tail!",
		"<span class='notice'>You begin to sever [target]'s tail...</span>")
	..()

/datum/surgery_step/tail/sever_tail/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] severs [target]'s tail!",
		"<span class='notice'>You sever [target]'s tail.</span>")
	BP.detach_misc_part(type = null)

/datum/surgery_step/tail/sever_tail/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if (BP.parent)
		BP = BP.parent
		user.visible_message("\red [user]'s hand slips, cutting [target]'s [BP.name] open!",
			                     "\red Your hand slips, cutting [target]'s [BP.name] open!")
		BP.createwound(CUT, 10)

//////////////////////////////////////////////////////////////////
//						TAIL ATTACHMENT							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/tail/attach_tail
	allowed_tools = list(
		/obj/item/tail = 100
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/tail/attach_tail/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/groin/BP = target.get_bodypart(target_zone)
	return ..() && !BP.tail && BP.open == 2

/datum/surgery_step/tail/attach_tail/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to attach a tail to [target]!",
		"<span class='notice'>You begin to attach the tail to [target]...</span>")
	..()

/datum/surgery_step/tail/attach_tail/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] gives [target] a tail!",
		"<span class='notice'>You give [target] a tail. It adjusts to [target]'s melanin.</span>")
	BP.attach_misc_part(tool, user)

/datum/surgery_step/tail/attach_tail/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if (BP.parent)
		BP = BP.parent
		user.visible_message("\red [user]'s hand slips, cutting [target]'s [BP.name] open!",
			                     "\red Your hand slips, cutting [target]'s [BP.name] open!")
		BP.createwound(CUT, 10)

//////////////////////////////////////////////////////////////////
//						EARS DETACHMENT							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/ears
	can_infect = 1

/datum/surgery_step/ears/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasbodyparts(target))
		return 0

	var/obj/item/bodypart/head/BP = target.get_bodypart(target_zone)
	if (!istype(BP) || (BP.status & ORGAN_ROBOT))
		return 0

	return TRUE

/datum/surgery_step/ears/sever_ears
	allowed_tools = list(
		 /obj/item/weapon/scalpel = 100
		,/obj/item/weapon/circular_saw = 100
		,/obj/item/weapon/hatchet = 75
		,/obj/item/weapon/shard = 50
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/ears/sever_ears/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/head/BP = target.get_bodypart(target_zone)
	return ..() && BP.ears

/datum/surgery_step/ears/sever_ears/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to sever [target]'s ears!",
		"<span class='notice'>You begin to sever [target]'s ears...</span>")
	..()

/datum/surgery_step/ears/sever_ears/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] severs [target]'s ears!",
		"<span class='notice'>You sever [target]'s ears.</span>")
	BP.detach_misc_part(type = null)

/datum/surgery_step/ears/sever_ears/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if (BP.parent)
		BP = BP.parent
		user.visible_message("\red [user]'s hand slips, cutting [target]'s [BP.name] open!",
			                     "\red Your hand slips, cutting [target]'s [BP.name] open!")
		BP.createwound(CUT, 10)

//////////////////////////////////////////////////////////////////
//						EARS ATTACHMENT							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/ears/attach_ears
	allowed_tools = list(
		/obj/item/ears = 100
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/ears/attach_ears/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/head/BP = target.get_bodypart(target_zone)
	return ..() && !BP.ears && BP.open == 2

/datum/surgery_step/ears/attach_ears/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to attach a ears to [target]!",
		"<span class='notice'>You begin to attach the ears to [target]...</span>")
	..()

/datum/surgery_step/ears/attach_ears/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] gives [target] a ears!",
		"<span class='notice'>You give [target] a ears. It adjusts to [target]'s melanin.</span>")
	BP.attach_misc_part(tool, user)

/datum/surgery_step/ears/attach_ears/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if (BP.parent)
		BP = BP.parent
		user.visible_message("\red [user]'s hand slips, cutting [target]'s [BP.name] open!",
			                     "\red Your hand slips, cutting [target]'s [BP.name] open!")
		BP.createwound(CUT, 10)
