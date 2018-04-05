//This is an uguu head restoration surgery TOTALLY not yoinked from chinsky's limb reattacher


/datum/surgery_step/head
	clothless = 0
	can_infect = 0

/datum/surgery_step/head/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (!BP)
		return 0
	if (!(BP.status & ORGAN_DESTROYED))
		return 0
	if (BP.parent)
		if (BP.parent.status & ORGAN_DESTROYED)
			return 0
	return BP.body_zone == BP_HEAD


/datum/surgery_step/head/peel
	allowed_tools = list(
	/obj/item/weapon/retractor = 100,           \
	/obj/item/weapon/kitchen/utensil/fork = 75, \
	/obj/item/weapon/screwdriver = 50
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/head/peel/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return !(BP.status & ORGAN_CUT_AWAY)

/datum/surgery_step/head/peel/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts peeling back tattered flesh where [target]'s head used to be with \the [tool].", \
	"You start peeling back tattered flesh where [target]'s head used to be with \the [tool].")
	..()

/datum/surgery_step/head/peel/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] peels back tattered flesh where [target]'s head used to be with \the [tool].",	\
	"\blue You peel back tattered flesh where [target]'s head used to be with \the [tool].")
	BP.status |= ORGAN_CUT_AWAY

/datum/surgery_step/head/peel/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (BP.parent)
		BP = BP.parent
		user.visible_message("\red [user]'s hand slips, ripping [target]'s [BP.name] open!", \
		"\red Your hand slips,  ripping [target]'s [BP.name] open!")
		BP.createwound(CUT, 10)


/datum/surgery_step/head/shape
	allowed_tools = list(
	/obj/item/weapon/FixOVein = 100, 	\
	/obj/item/stack/cable_coil = 75
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/head/shape/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return (BP.status & ORGAN_CUT_AWAY) && BP.open < 3 && !(BP.status & ORGAN_ATTACHABLE)

/datum/surgery_step/head/shape/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] is beginning to reshape [target]'s esophagal and vocal region with \the [tool].", \
	"You start to reshape [target]'s [BP.name] esophagal and vocal region with \the [tool].")
	..()

/datum/surgery_step/head/shape/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] has finished repositioning flesh and tissue to something anatomically recognizable where [target]'s head used to be with \the [tool].",	\
	"\blue You have finished repositioning flesh and tissue to something anatomically recognizable where [target]'s head used to be with \the [tool].")
	BP.open = 3

/datum/surgery_step/head/shape/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (BP.parent)
		BP = BP.parent
		user.visible_message("\red [user]'s hand slips, further rending flesh on [target]'s neck!", \
		"\red Your hand slips, further rending flesh on [target]'s neck!")
		target.apply_damage(10, BRUTE, BP)

/datum/surgery_step/head/suture
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100, 	\
	/obj/item/stack/cable_coil = 75,	\
	/obj/item/weapon/wirecutters = 75,           \
	/obj/item/weapon/kitchen/utensil/fork = 50,  \
	/obj/item/weapon/FixOVein = 80)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/head/suture/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP.open == 3

/datum/surgery_step/head/suture/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is stapling and suturing flesh into place in [target]'s esophagal and vocal region with \the [tool].", \
	"You start to staple and suture flesh into place in [target]'s esophagal and vocal region with \the [tool].")
	..()

/datum/surgery_step/head/suture/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] has finished stapling [target]'s neck into place with \the [tool].",	\
	"\blue You have finished stapling [target]'s neck into place with \the [tool].")
	BP.open = 4

/datum/surgery_step/head/suture/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (BP.parent)
		BP = BP.parent
		user.visible_message("\red [user]'s hand slips, ripping apart flesh on [target]'s neck!", \
		"\red Your hand slips, ripping apart flesh on [target]'s neck!")
		target.apply_damage(10, BRUTE, BP)

/datum/surgery_step/head/prepare
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 50
	)

	min_duration = 60
	max_duration = 70

/datum/surgery_step/head/prepare/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP.open == 4

/datum/surgery_step/head/prepare/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts adjusting area around [target]'s neck with \the [tool].", \
	"You start adjusting area around [target]'s neck with \the [tool].")
	..()

/datum/surgery_step/head/prepare/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] has finished adjusting the area around [target]'s neck with \the [tool].",	\
	"\blue You have finished adjusting the area around [target]'s neck with \the [tool].")
	BP.status |= ORGAN_ATTACHABLE
	BP.amputated = 1
	BP.setAmputatedTree()
	BP.open = 0

/datum/surgery_step/head/prepare/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (BP.parent)
		BP = BP.parent
		user.visible_message("\red [user]'s hand slips, searing [target]'s neck!", \
		"\red Your hand slips, searing [target]'s [BP.name]!")
		target.apply_damage(10, BURN, BP)


/datum/surgery_step/head/attach
	allowed_tools = list(/obj/item/weapon/organ/head = 100)
	can_infect = 0

	min_duration = 80
	max_duration = 100

/datum/surgery_step/head/attach/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/head = target.get_bodypart(target_zone)
		return head.status & ORGAN_ATTACHABLE

/datum/surgery_step/head/attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts attaching [tool] to [target]'s reshaped neck.", \
	"You start attaching [tool] to [target]'s reshaped neck.")

/datum/surgery_step/head/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] has attached [target]'s head to the body.",	\
	"\blue You have attached [target]'s head to the body.")
	BP.status = 0
	BP.amputated = 0
	BP.destspawn = 0
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon(BP)
	var/obj/item/weapon/organ/head/B = tool
	if (B.brainmob.mind)
		B.brainmob.mind.transfer_to(target)
		target.dna = B.brainmob.dna
	qdel(B)


/datum/surgery_step/head/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("\red [user]'s hand slips, damaging connectors on [target]'s neck!", \
	"\red Your hand slips, damaging connectors on [target]'s neck!")
	target.apply_damage(10, BRUTE, BP, null, DAM_SHARP)
