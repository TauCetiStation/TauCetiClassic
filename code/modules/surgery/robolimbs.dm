//Procedures in this file: Robotic limbs attachment
//////////////////////////////////////////////////////////////////
//						LIMB SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/limb
	can_infect = 0

/datum/surgery_step/limb/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
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
	return BP.body_zone != BP_CHEST


/datum/surgery_step/limb/cut
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/limb/cut/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return !(BP.status & ORGAN_CUT_AWAY)

/datum/surgery_step/limb/cut/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts cutting away flesh where [target]'s [BP.name] used to be with \the [tool].", \
	"You start cutting away flesh where [target]'s [BP.name] used to be with \the [tool].")
	..()

/datum/surgery_step/limb/cut/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] cuts away flesh where [target]'s [BP.name] used to be with \the [tool].",	\
	"\blue You cut away flesh where [target]'s [BP.name] used to be with \the [tool].")
	BP.status |= ORGAN_CUT_AWAY

/datum/surgery_step/limb/cut/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
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
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return (BP.status & ORGAN_CUT_AWAY) && BP.open < 3 && !(BP.status & ORGAN_ATTACHABLE)

/datum/surgery_step/limb/mend/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] is beginning to reposition flesh and nerve endings where where [target]'s [BP.name] used to be with [tool].", \
	"You start repositioning flesh and nerve endings where [target]'s [BP.name] used to be with [tool].")
	..()

/datum/surgery_step/limb/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] has finished repositioning flesh and nerve endings where [target]'s [BP.name] used to be with [tool].",	\
	"\blue You have finished repositioning flesh and nerve endings where [target]'s [BP.name] used to be with [tool].")
	BP.open = 3

/datum/surgery_step/limb/mend/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (BP.parent)
		BP = BP.parent
		user.visible_message("\red [user]'s hand slips, tearing flesh on [target]'s [BP.name]!", \
		"\red Your hand slips, tearing flesh on [target]'s [BP.name]!")
		target.apply_damage(10, BRUTE, BP, null, DAM_SHARP)


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
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP.open == 3

/datum/surgery_step/limb/prepare/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts adjusting the area around [target]'s [BP.name] with \the [tool].", \
	"You start adjusting the area around [target]'s [BP.name] with \the [tool].")
	..()

/datum/surgery_step/limb/prepare/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] has finished adjusting the area around [target]'s [BP.name] with \the [tool].",	\
	"\blue You have finished adjusting the area around [target]'s [BP.name] with \the [tool].")
	BP.status |= ORGAN_ATTACHABLE
	BP.amputated = 1
	BP.setAmputatedTree()
	BP.open = 0

/datum/surgery_step/limb/prepare/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (BP.parent)
		BP = BP.parent
		user.visible_message("\red [user]'s hand slips, searing [target]'s [BP.name]!", \
		"\red Your hand slips, searing [target]'s [BP.name]!")
		target.apply_damage(10, BURN, BP)


/datum/surgery_step/limb/attach
	allowed_tools = list(
	/obj/item/robot_parts = 100,
	/obj/item/weapon/organ/head/posi = 100)
	allowed_species = list(IPC)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/limb/attach/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		if(istype(tool, /obj/item/weapon/organ/head/posi) && target.get_species() == IPC)
			var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
			return (BP.status & ORGAN_ATTACHABLE)

		var/obj/item/robot_parts/p = tool
		if (target_zone != p.part)
			to_chat(user, "<span class='userdanger'>This is inappropriate part for [parse_zone(target_zone)]!</span>")
			return FALSE
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return (BP.status & ORGAN_ATTACHABLE)

/datum/surgery_step/limb/attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts attaching \the [tool] where [target]'s [BP.name] used to be.",
	"You start attaching \the [tool] where [target]'s [BP.name] used to be.")

/datum/surgery_step/limb/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/robot_parts/L = tool
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("\blue [user] has attached \the [tool] where [target]'s [BP.name] used to be.",
	"\blue You have attached \the [tool] where [target]'s [BP.name] used to be.")
	BP.germ_level = 0
	BP.robotize()
	if(L.sabotaged)
		BP.sabotaged = TRUE
	else
		BP.sabotaged = FALSE
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon(BP)
	qdel(tool)

/datum/surgery_step/limb/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("\red [user]'s hand slips, damaging connectors on [target]'s [BP.name]!",
	"\red Your hand slips, damaging connectors on [target]'s [BP.name]!")
	target.apply_damage(10, BRUTE, BP, null, DAM_SHARP)

//////////////////////////////////////////////////////////////////
//						ROBO LIMB SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/ipc_limb
	can_infect = FALSE
	allowed_species = list(IPC)

/datum/surgery_step/ipc_limb/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return FALSE
	if(!(target.species && target.species.flags[IS_SYNTHETIC]))
		return FALSE
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (!BP)
		return FALSE
	if (!(BP.status & ORGAN_DESTROYED))
		return FALSE
	if (BP.parent)
		if (BP.parent.status & ORGAN_DESTROYED)
			return FALSE
	return BP.body_zone != BP_CHEST

/datum/surgery_step/ipc_limb/cut_wires
	allowed_tools = list(
	/obj/item/weapon/wirecutters = 100,
	/obj/item/weapon/kitchenknife = 75,
	/obj/item/weapon/shard = 50
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/ipc_limb/cut_wires/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return !(BP.status & ORGAN_CUT_AWAY)

/datum/surgery_step/ipc_limb/cut_wires/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] begins to reposition wires where [target]'s [BP.name] used to be with \the [tool].",
	"You begin to reposition wires where [target]'s [BP.name] used to be with \the [tool].")
	..()

/datum/surgery_step/ipc_limb/cut_wires/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] finished repositioning wires where [target]'s [BP.name] used to be with \the [tool].</span>",
	"<span class='notice'>You finished repositioning wires where [target]'s [BP.name] used to be with \the [tool].</span>")
	BP.status |= ORGAN_CUT_AWAY
	BP.open = 3

/datum/surgery_step/ipc_limb/cut_wires/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (BP.parent)
		BP = BP.parent
		user.visible_message("<span class='warning'>[user]'s hand slips, cutting [target]'s [BP.name] open!</span>",
		"<span class='warning'>Your hand slips, cutting [target]'s [BP.name] open!</span>")
		BP.createwound(CUT, 10)

/datum/surgery_step/ipc_limb/ipc_prepare
	allowed_tools = list(
	/obj/item/weapon/wrench = 100,
	/obj/item/weapon/bonesetter = 75
	)

	min_duration = 60
	max_duration = 70

/datum/surgery_step/ipc_limb/ipc_prepare/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
		return BP.open == 3

/datum/surgery_step/ipc_limb/ipc_prepare/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("[user] starts adjusting the area around [target]'s [BP.name] with \the [tool].",
	"You start adjusting the area around [target]'s [BP.name] with \the [tool].")
	..()

/datum/surgery_step/ipc_limb/ipc_prepare/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] has finished adjusting the area around [target]'s [BP.name] with \the [tool].</span>",
	"<span class='notice'>You have finished adjusting the area around [target]'s [BP.name] with \the [tool].</span>")
	BP.status |= ORGAN_ATTACHABLE
	BP.amputated = TRUE
	BP.setAmputatedTree()
	BP.open = 0

/datum/surgery_step/ipc_limb/ipc_prepare/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (BP.parent)
		BP = BP.parent
		user.visible_message("<span class='warning'>[user]'s hand slips, denting [target]'s [BP.name]!</span>",
		"<span class='warning'>Your hand slips, searing [target]'s [BP.name]!</span>")
		target.apply_damage(10, BRUTE, BP)
