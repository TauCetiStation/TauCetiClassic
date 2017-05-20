//This is an uguu head restoration surgery TOTALLY not yoinked from chinsky's limb reattacher


/datum/surgery_step/head/
	clothless = 0
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
		return BP.body_zone == BP_HEAD


/datum/surgery_step/head/peel
	allowed_tools = list(
	/obj/item/weapon/retractor = 100,           \
	/obj/item/weapon/kitchen/utensil/fork = 75, \
	/obj/item/weapon/screwdriver = 50
	)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/BP = target.get_bodypart(target_zone)
			return !(BP.status & ORGAN_CUT_AWAY)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts peeling back tattered flesh where [target]'s head used to be with \the [tool].", \
		"You start peeling back tattered flesh where [target]'s head used to be with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class='notice'>[user] peels back tattered flesh where [target]'s head used to be with \the [tool].</span>",	\
		"<span class='notice'>You peel back tattered flesh where [target]'s head used to be with \the [tool].</span>")
		BP.status |= ORGAN_CUT_AWAY

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		if (BP.parent)
			BP = BP.parent
			user.visible_message("<span class=warning'>[user]'s hand slips, ripping [target]'s [BP.name] open!</span>", \
			"<span class=warning'>Your hand slips,  ripping [target]'s [BP.name] open!</span>")
			BP.createwound(CUT, 10)


/datum/surgery_step/head/shape
	allowed_tools = list(
	/obj/item/weapon/FixOVein = 100, 	\
	/obj/item/weapon/cable_coil = 75
	)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/BP = target.get_bodypart(target_zone)
			return (BP.status & ORGAN_CUT_AWAY) && BP.open < 3 && !(BP.status & ORGAN_ATTACHABLE)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("[user] is beginning to reshape [target]'s esophagal and vocal region with \the [tool].", \
		"You start to reshape [target]'s [BP.name] esophagal and vocal region with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class='notice'>[user] has finished repositioning flesh and tissue to something anatomically recognizable where [target]'s head used to be with \the [tool].</span>",	\
		"<span class='notice'>You have finished repositioning flesh and tissue to something anatomically recognizable where [target]'s head used to be with \the [tool].</span>")
		BP.open = 3

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		if (BP.parent)
			BP = BP.parent
			user.visible_message("<span class=warning'>[user]'s hand slips, further rending flesh on [target]'s neck!</span>", \
			"<span class=warning'>Your hand slips, further rending flesh on [target]'s neck!</span>")
			target.apply_damage(10, BRUTE, BP)

/datum/surgery_step/head/suture
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100, 	\
	/obj/item/weapon/cable_coil = 75,	\
	/obj/item/weapon/wirecutters = 75,           \
	/obj/item/weapon/kitchen/utensil/fork = 50,  \
	/obj/item/weapon/FixOVein = 80)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/BP = target.get_bodypart(target_zone)
			return BP.open == 3

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] is stapling and suturing flesh into place in [target]'s esophagal and vocal region with \the [tool].", \
		"You start to staple and suture flesh into place in [target]'s esophagal and vocal region with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class='notice'>[user] has finished stapling [target]'s neck into place with \the [tool].</span>",	\
		"<span class='notice'>You have finished stapling [target]'s neck into place with \the [tool].</span>")
		BP.open = 4

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		if (BP.parent)
			BP = BP.parent
			user.visible_message("<span class=warning'>[user]'s hand slips, ripping apart flesh on [target]'s neck!</span>", \
			"<span class=warning'>Your hand slips, ripping apart flesh on [target]'s neck!</span>")
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

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/BP = target.get_bodypart(target_zone)
			return BP.open == 4

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts adjusting area around [target]'s neck with \the [tool].", \
		"You start adjusting area around [target]'s neck with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class='notice'>[user] has finished adjusting the area around [target]'s neck with \the [tool].</span>",	\
		"<span class='notice'>You have finished adjusting the area around [target]'s neck with \the [tool].</span>")
		BP.status |= ORGAN_ATTACHABLE
		BP.amputated = 1
		BP.setAmputatedTree()
		BP.open = 0

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		if (BP.parent)
			BP = BP.parent
			user.visible_message("<span class=warning'>[user]'s hand slips, searing [target]'s neck!</span>", \
			"<span class=warning'>Your hand slips, searing [target]'s [BP.name]!</span>")
			target.apply_damage(10, BURN, BP)


/datum/surgery_step/head/attach
	allowed_tools = list(/obj/item/weapon/organ/head = 100)
	can_infect = 0

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/datum/organ/external/head = target.get_bodypart(target_zone)
			return head.status & ORGAN_ATTACHABLE

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts attaching [tool] to [target]'s reshaped neck.", \
		"You start attaching [tool] to [target]'s reshaped neck.")

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class='notice'>[user] has attached [target]'s head to the body.</span>",	\
		"<span class='notice'>You have attached [target]'s head to the body.</span>")
		BP.status = 0
		BP.amputated = 0
		BP.destspawn = 0
		target.update_body()
		target.updatehealth()
		target.UpdateDamageIcon(BP)
		var/obj/item/weapon/organ/head/B = tool
		if (B.brainmob.mind)
			B.brainmob.mind.transfer_to(target)
		qdel(B)


	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/BP = target.get_bodypart(target_zone)
		user.visible_message("<span class=warning'>[user]'s hand slips, damaging connectors on [target]'s neck!</span>", \
		"<span class=warning'>Your hand slips, damaging connectors on [target]'s neck!</span>")
		target.apply_damage(10, BRUTE, BP, sharp = 1)
