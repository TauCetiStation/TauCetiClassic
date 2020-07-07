//Procedures in this file: limbs attachment
//////////////////////////////////////////////////////////////////
//						LIMB SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/limb
	can_infect = 0

/datum/surgery_step/limb/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (BP)
		return 0
	if(target_zone in list(O_EYES , O_MOUTH))
		return 0
	return target_zone != BP_CHEST


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
		return !target.op_stage.bodyparts[target_zone]

/datum/surgery_step/limb/cut/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting away flesh where [target]'s [parse_zone(target_zone)] used to be with \the [tool].", \
	"You start cutting away flesh where [target]'s [parse_zone(target_zone)] used to be with \the [tool].")
	..()

/datum/surgery_step/limb/cut/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] cuts away flesh where [target]'s [parse_zone(target_zone)] used to be with \the [tool].</span>",	\
	"<span class='notice'>You cut away flesh where [target]'s [parse_zone(target_zone)] used to be with \the [tool].</span>")
	target.op_stage.bodyparts[target_zone] = ORGAN_CUT_AWAY

/datum/surgery_step/limb/cut/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(BP_CHEST)
	if (BP)
		user.visible_message("<span class='warning'>[user]'s hand slips, cutting [target]'s [BP.name] open!</span>", \
		"<span class='warning'>Your hand slips, cutting [target]'s [BP.name] open!</span>")
		target.apply_damage(10, BRUTE, BP, damage_flags = DAM_SHARP|DAM_EDGE)


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
		return target.op_stage.bodyparts[target_zone] && target.op_stage.bodyparts[target_zone] == ORGAN_CUT_AWAY

/datum/surgery_step/limb/mend/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning to reposition flesh and nerve endings where where [target]'s [parse_zone(target_zone)] used to be with [tool].", \
	"You start repositioning flesh and nerve endings where [target]'s [parse_zone(target_zone)] used to be with [tool].")
	..()

/datum/surgery_step/limb/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has finished repositioning flesh and nerve endings where [target]'s [parse_zone(target_zone)] used to be with [tool].</span>",	\
	"<span class='notice'>You have finished repositioning flesh and nerve endings where [target]'s [parse_zone(target_zone)] used to be with [tool].</span>")
	target.op_stage.bodyparts[target_zone] = 3

/datum/surgery_step/limb/mend/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(BP_CHEST)
	if (BP)
		user.visible_message("<span class='warning'>[user]'s hand slips, tearing flesh on [target]'s [BP.name]!</span>", \
		"<span class='warning'>Your hand slips, tearing flesh on [target]'s [BP.name]!</span>")
		target.apply_damage(10, BRUTE, BP, damage_flags = DAM_SHARP|DAM_EDGE)


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
		return target.op_stage.bodyparts[target_zone] && target.op_stage.bodyparts[target_zone] == 3

/datum/surgery_step/limb/prepare/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts adjusting the area around [target]'s [parse_zone(target_zone)] with \the [tool].", \
	"You start adjusting the area around [target]'s [parse_zone(target_zone)] with \the [tool].")
	..()

/datum/surgery_step/limb/prepare/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has finished adjusting the area around [target]'s [parse_zone(target_zone)] with \the [tool].</span>",	\
	"<span class='notice'>You have finished adjusting the area around [target]'s [parse_zone(target_zone)] with \the [tool].</span>")
	target.op_stage.bodyparts[target_zone] = ORGAN_ATTACHABLE

/datum/surgery_step/limb/prepare/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(BP_CHEST)
	if (BP)
		user.visible_message("<span class='warning'>[user]'s hand slips, searing [target]'s [BP.name]!</span>", \
		"<span class='warning'>Your hand slips, searing [target]'s [BP.name]!</span>")
		target.apply_damage(10, BURN, BP)


/datum/surgery_step/limb/attach
	allowed_tools = list(
	/obj/item/organ/external = 100,
	/obj/item/robot_parts = 100,
	)
	allowed_species = null

	min_duration = 80
	max_duration = 100

/datum/surgery_step/limb/attach/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		if(istype(tool, /obj/item/robot_parts))
			var/obj/item/robot_parts/p = tool
			if (target_zone != p.part)
				to_chat(user, "<span class='userdanger'>This is inappropriate part for [parse_zone(target_zone)]!</span>")
				return FALSE
			if(!p.can_attach())
				to_chat(user, "<span class='userdanger'>You need to attach a flash to [p] first!</span>")
				return FALSE
			return target.op_stage.bodyparts[target_zone] == ORGAN_ATTACHABLE
		if(istype(tool, /obj/item/organ/external))
			var/obj/item/organ/external/p = tool
			if (target_zone != p.body_zone)
				to_chat(user, "<span class='userdanger'>This is inappropriate part for [parse_zone(target_zone)]!</span>")
				return FALSE
			if(!p.is_compatible(target))
				to_chat(user, "<span class='userdanger'>This does not fit!</span>")
				return FALSE
			return target.op_stage.bodyparts[target_zone] == ORGAN_ATTACHABLE

/datum/surgery_step/limb/attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts attaching \the [tool] where [target]'s [parse_zone(target_zone)] used to be.",
	"You start attaching \the [tool] where [target]'s [parse_zone(target_zone)] used to be.")

/datum/surgery_step/limb/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP

	if(istype(tool, /obj/item/robot_parts))
		var/obj/item/robot_parts/L = tool
		if(!L.can_attach())
			return
		BP = new L.bodypart_type()
		target.remove_from_mob(tool)
		qdel(tool)

	if(istype(tool, /obj/item/organ/external))
		BP = tool

	if(!BP)
		return

	user.visible_message("<span class='notice'>[user] has attached \the [tool] where [target]'s [parse_zone(target_zone)] used to be.</span>",
	"<span class='notice'>You have attached \the [tool] where [target]'s [parse_zone(target_zone)] used to be.</span>")

	user.remove_from_mob(tool)
	BP.insert_organ(target, surgically = TRUE)
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon(BP)
	target.op_stage.bodyparts -= target_zone

	if(istype(BP, /obj/item/organ/external/head))
		var/obj/item/organ/external/head/B = BP
		if (B.brainmob && B.brainmob.mind)
			B.brainmob.mind.transfer_to(target)
			target.dna = B.brainmob.dna
			QDEL_NULL(B.brainmob)
		target.f_style = B.f_style
		target.h_style = B.h_style
		target.grad_style = B.grad_style
		target.r_facial = B.r_facial
		target.g_facial = B.g_facial
		target.b_facial = B.b_facial
		target.dyed_r_facial = B.dyed_r_facial
		target.dyed_g_facial = B.dyed_g_facial
		target.dyed_b_facial = B.dyed_b_facial
		target.facial_painted = B.facial_painted
		target.r_hair = B.r_hair
		target.g_hair = B.g_hair
		target.b_hair = B.b_hair
		target.dyed_r_hair = B.dyed_r_hair
		target.dyed_g_hair = B.dyed_g_hair
		target.dyed_b_hair = B.dyed_b_hair
		target.r_grad = B.r_grad
		target.g_grad = B.g_grad
		target.b_grad = B.b_grad
		target.hair_painted = B.hair_painted
		target.update_hair()

/datum/surgery_step/limb/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(BP_CHEST)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging connectors on [target]'s [BP.name]!</span>",
	"<span class='warning'>Your hand slips, damaging connectors on [target]'s [BP.name]!</span>")
	target.apply_damage(10, BRUTE, BP, damage_flags = DAM_SHARP)

//////////////////////////////////////////////////////////////////
//						ROBO LIMB SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/ipc_limb
	can_infect = FALSE
	allowed_species = list(IPC)

/datum/surgery_step/ipc_limb/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (BP)
		return 0
	if(target_zone in list(O_EYES , O_MOUTH))
		return 0
	return target_zone != BP_CHEST


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
		return !target.op_stage.bodyparts[target_zone]

/datum/surgery_step/ipc_limb/cut_wires/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to reposition wires where [target]'s [parse_zone(target_zone)] used to be with \the [tool].",
	"You begin to reposition wires where [target]'s [parse_zone(target_zone)] used to be with \the [tool].")
	..()

/datum/surgery_step/ipc_limb/cut_wires/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] finished repositioning wires where [target]'s [parse_zone(target_zone)] used to be with \the [tool].</span>",
	"<span class='notice'>You finished repositioning wires where [target]'s [parse_zone(target_zone)] used to be with \the [tool].</span>")
	target.op_stage.bodyparts[target_zone] = ORGAN_CUT_AWAY

/datum/surgery_step/ipc_limb/cut_wires/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(BP_CHEST)
	if (BP)
		user.visible_message("<span class='warning'>[user]'s hand slips, cutting [target]'s [BP.name] open!</span>",
		"<span class='warning'>Your hand slips, cutting [target]'s [BP.name] open!</span>")
		target.apply_damage(10, BRUTE, BP, damage_flags = DAM_SHARP|DAM_EDGE)

/datum/surgery_step/ipc_limb/ipc_prepare
	allowed_tools = list(
	/obj/item/weapon/wrench = 100,
	/obj/item/weapon/bonesetter = 75
	)

	min_duration = 60
	max_duration = 70

/datum/surgery_step/ipc_limb/ipc_prepare/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		return target.op_stage.bodyparts[target_zone] && target.op_stage.bodyparts[target_zone] == ORGAN_CUT_AWAY

/datum/surgery_step/ipc_limb/ipc_prepare/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts adjusting the area around [target]'s [parse_zone(target_zone)] with \the [tool].",
	"You start adjusting the area around [target]'s [parse_zone(target_zone)] with \the [tool].")
	..()

/datum/surgery_step/ipc_limb/ipc_prepare/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has finished adjusting the area around [target]'s [parse_zone(target_zone)] with \the [tool].</span>",
	"<span class='notice'>You have finished adjusting the area around [target]'s [parse_zone(target_zone)] with \the [tool].</span>")
	target.op_stage.bodyparts[target_zone] = ORGAN_ATTACHABLE

/datum/surgery_step/ipc_limb/ipc_prepare/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(BP_CHEST)
	if (BP)
		user.visible_message("<span class='warning'>[user]'s hand slips, denting [target]'s [BP.name]!</span>",
		"<span class='warning'>Your hand slips, searing [target]'s [BP.name]!</span>")
		target.apply_damage(10, BRUTE, BP)
