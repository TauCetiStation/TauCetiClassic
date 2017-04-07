//Procedures in this file: Robotic limbs attachment
//////////////////////////////////////////////////////////////////
//						LIMB SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/limb
	can_infect = 0

/datum/surgery_step/limb/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return 0
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if(!BP)
		return 0
	if(!BP.is_stump())
		return 0
	return BP.body_zone != BP_HEAD


/datum/surgery_step/limb/cut
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/limb/cut/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return 0
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	return !(BP.status & ORGAN_CUT_AWAY)

/datum/surgery_step/limb/cut/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts cutting away flesh where [target]'s [BP.name] used to be with \the [tool].", \
	"You start cutting away flesh where [target]'s [BP.name] used to be with \the [tool].")
	..()

/datum/surgery_step/limb/cut/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] cuts away flesh where [target]'s [BP.name] used to be with \the [tool].",	\
	"\blue You cut away flesh where [target]'s [BP.name] used to be with \the [tool].")
	BP.status |= ORGAN_CUT_AWAY
	target.update_bodypart(BP.body_zone)

/datum/surgery_step/limb/cut/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if (BP.parent)
		BP = BP.parent
		user.visible_message("\red [user]'s hand slips, cutting [target]'s [BP.name] open!", \
		"\red Your hand slips, cutting [target]'s [BP.name] open!")
		BP.createwound(CUT, 10)


/datum/surgery_step/limb/mend
	allowed_tools = list(
	/obj/item/weapon/retractor = 100,           \
	/obj/item/weapon/kitchen/utensil/fork = 75,	\
	/obj/item/weapon/screwdriver = 50
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/limb/mend/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return 0
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	return (BP.status & ORGAN_CUT_AWAY) && (BP.open < 3) && !(BP.status & ORGAN_ATTACHABLE)

/datum/surgery_step/limb/mend/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] is beginning to reposition flesh and nerve endings where where [target]'s [BP.name] used to be with [tool].", \
	"You start repositioning flesh and nerve endings where [target]'s [BP.name] used to be with [tool].")
	..()

/datum/surgery_step/limb/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] has finished repositioning flesh and nerve endings where [target]'s [BP.name] used to be with [tool].",	\
	"\blue You have finished repositioning flesh and nerve endings where [target]'s [BP.name] used to be with [tool].")
	BP.open = 3

/datum/surgery_step/limb/mend/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if (BP.parent)
		BP = BP.parent
		user.visible_message("\red [user]'s hand slips, tearing flesh on [target]'s [BP.name]!", \
		"\red Your hand slips, tearing flesh on [target]'s [BP.name]!")
		target.apply_damage(10, BRUTE, BP, 0, DAM_SHARP)


/datum/surgery_step/limb/prepare
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 50
	)

	min_duration = 60
	max_duration = 70

/datum/surgery_step/limb/prepare/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return 0
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	return BP.open == 3

/datum/surgery_step/limb/prepare/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts adjusting the area around [target]'s [BP.name] with \the [tool].", \
	"You start adjusting the area around [target]'s [BP.name] with \the [tool].")
	..()

/datum/surgery_step/limb/prepare/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] has finished adjusting the area around [target]'s [BP.name] with \the [tool].",	\
	"\blue You have finished adjusting the area around [target]'s [BP.name] with \the [tool].")
	BP.status |= ORGAN_ATTACHABLE
	BP.open = 0

/datum/surgery_step/limb/prepare/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if (BP.parent)
		BP = BP.parent
		user.visible_message("\red [user]'s hand slips, searing [target]'s [BP.name]!", \
		"\red Your hand slips, searing [target]'s [BP.name]!")
		target.apply_damage(10, BURN, BP)

//////////////////////////////////////////////////////////////////
//	 robotic limb attachment surgery step
//////////////////////////////////////////////////////////////////
/datum/surgery_step/limb/mechanize
	allowed_tools = list(/obj/item/robot_parts = 100)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/limb/mechanize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!..())
		return 0
	var/obj/item/robot_parts/p = tool
	if (p.part)
		if (target_zone != p.part)
			return 0
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	return BP.status & ORGAN_ATTACHABLE

/datum/surgery_step/limb/mechanize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts attaching \the [tool] where [target]'s [BP.name] used to be.", \
	"You start attaching \the [tool] where [target]'s [BP.name] used to be.")

/datum/surgery_step/limb/mechanize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/bodypart/tool)
	user.drop_from_inventory(tool)
	if(tool.replace_stump(target)) // TODO implement robot bodyparts or this won't work
		var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
		user.visible_message("\blue [user] has attached \the [tool] where [target]'s [BP.name] used to be.",	\
		"\blue You have attached \the [tool] where [target]'s [BP.name] used to be.")

/datum/surgery_step/limb/mechanize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	user.visible_message("\red [user]'s hand slips, damaging connectors on [target]'s [BP.name]!", \
	"\red Your hand slips, damaging connectors on [target]'s [BP.name]!")
	target.apply_damage(10, BRUTE, BP, 0, DAM_SHARP)
