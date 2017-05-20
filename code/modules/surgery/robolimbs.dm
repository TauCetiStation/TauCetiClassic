//Procedures in this file: Robotic limbs attachment
//////////////////////////////////////////////////////////////////
//						LIMB SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/limb/
	can_infect = 0
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(!ishuman(target))
			return 0
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		if (!BP)
			return 0
		if (!(BP.status & ORGAN_DESTROYED))
			return 0
		if (BP.parent)
			if (BP.parent.status & ORGAN_DESTROYED)
				return 0
		return BP.body_zone != BP_CHEST


/datum/surgery_step/limb/cut
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/BP = target.get_bodypart(target_zone)
			return !(BP.status & ORGAN_CUT_AWAY)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("[user] starts cutting away flesh where [target]'s [BP.name] used to be with \the [tool].", \
		"You start cutting away flesh where [target]'s [BP.name] used to be with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class='notice'>[user] cuts away flesh where [target]'s [BP.name] used to be with \the [tool].</span>",	\
		"<span class='notice'>You cut away flesh where [target]'s [BP.name] used to be with \the [tool].</span>")
		BP.status |= ORGAN_CUT_AWAY

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		if (BP.parent)
			BP = BP.parent
			user.visible_message("<span class='warning'>[user]'s hand slips, cutting [target]'s [BP.name] open!</span>", \
			"<span class='warning'>Your hand slips, cutting [target]'s [BP.name] open!</span>")
			BP.createwound(CUT, 10)


/datum/surgery_step/limb/mend
	allowed_tools = list(
	/obj/item/weapon/retractor = 100,           \
	/obj/item/weapon/kitchen/utensil/fork = 75,	\
	/obj/item/weapon/screwdriver = 50
	)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/BP = target.get_bodypart(target_zone)
			return (BP.status & ORGAN_CUT_AWAY) && BP.open < 3 && !(BP.status & ORGAN_ATTACHABLE)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("[user] is beginning to reposition flesh and nerve endings where where [target]'s [BP.name] used to be with [tool].", \
		"You start repositioning flesh and nerve endings where [target]'s [BP.name] used to be with [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class='notice'>[user] has finished repositioning flesh and nerve endings where [target]'s [BP.name] used to be with [tool].</span>",	\
		"<span class='notice'>You have finished repositioning flesh and nerve endings where [target]'s [BP.name] used to be with [tool].</span>")
		BP.open = 3

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		if (BP.parent)
			BP = BP.parent
			user.visible_message("<span class='warning'>[user]'s hand slips, tearing flesh on [target]'s [BP.name]!</span>", \
			"<span class='warning'>Your hand slips, tearing flesh on [target]'s [BP.name]!</span>")
			target.apply_damage(10, BRUTE, BP, sharp = 1)


/datum/surgery_step/limb/prepare
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 50
	)

	min_duration = 60
	max_duration = 70

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/BP = target.get_bodypart(target_zone)
			return BP.open == 3

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("[user] starts adjusting the area around [target]'s [BP.name] with \the [tool].", \
		"You start adjusting the area around [target]'s [BP.name] with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class='notice'>[user] has finished adjusting the area around [target]'s [BP.name] with \the [tool].</span>",	\
		"<span class='notice'>You have finished adjusting the area around [target]'s [BP.name] with \the [tool].</span>")
		BP.status |= ORGAN_ATTACHABLE
		BP.amputated = 1
		BP.setAmputatedTree()
		BP.open = 0

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		if (BP.parent)
			BP = BP.parent
			user.visible_message("<span class='warning'>[user]'s hand slips, searing [target]'s [BP.name]!</span>", \
			"<span class='warning'>Your hand slips, searing [target]'s [BP.name]!</span>")
			target.apply_damage(10, BURN, BP)


/datum/surgery_step/limb/attach
	allowed_tools = list(/obj/item/robot_parts = 100)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/obj/item/robot_parts/p = tool
			if (p.part)
				if (!(target_zone in p.part))
					return 0
			var/datum/organ/external/BP = target.get_bodypart(target_zone)
			return (BP.status & ORGAN_ATTACHABLE)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("[user] starts attaching \the [tool] where [target]'s [BP.name] used to be.", \
		"You start attaching \the [tool] where [target]'s [BP.name] used to be.")

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/robot_parts/L = tool
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class='notice'>[user] has attached \the [tool] where [target]'s [BP.name] used to be.</span>",	\
		"<span class='notice'>You have attached \the [tool] where [target]'s [BP.name] used to be.</span>")
		BP.germ_level = 0
		BP.robotize()
		if(L.sabotaged)
			BP.sabotaged = 1
		else
			BP.sabotaged = 0
		target.update_body()
		target.updatehealth()
		target.UpdateDamageIcon(BP)
		qdel(tool)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class='warning'>[user]'s hand slips, damaging connectors on [target]'s [BP.name]!</span>", \
		"<span class='warning'>Your hand slips, damaging connectors on [target]'s [BP.name]!</span>")
		target.apply_damage(10, BRUTE, BP, sharp = 1)
