//////////////////////////////////////////////////////////////////
//						Plastic Surgery							//
//////////////////////////////////////////////////////////////////
/datum/surgery_status/
	var/plasticsur = 0

/datum/surgery_step/plastic_surgery/
	clothless = 0
	priority = 3
	can_infect = 0
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(!ishuman(target))
			return 0
		if (!hasorgans(target))
			return 0
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (!affected)
			return 0
		return target_zone == "mouth"

/datum/surgery_step/plastic_surgery/retract_face
	allowed_tools = list(
	/obj/item/weapon/retractor = 100,           \
	/obj/item/weapon/kitchen/utensil/fork = 75, \
	/obj/item/weapon/screwdriver = 50
	)

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.op_stage.plasticsur == 0 && target.op_stage.face == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts adjusting the skin on [target]'s face with \the [tool].", \
		"You start adjusting the skin on [target]'s face with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] pulls the skin on [target]'s face with \the [tool].",	\
		"\blue You pull the skin on [target]'s face with \the [tool].")
		target.op_stage.plasticsur = 1

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, tearing skin on [target]'s face with \the [tool]!", \
		"\red Your hand slips, tearing skin on [target]'s face with \the [tool]!")
		target.apply_damage(10, BRUTE, affected, sharp=1, sharp=1)

/datum/surgery_step/plastic_surgery/adjust_vocal
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100, 	\
	/obj/item/weapon/cable_coil = 75, 	\
	/obj/item/weapon/wirecutters = 75,           \
	/obj/item/weapon/kitchen/utensil/fork = 50,  \
	/obj/item/device/assembly/mousetrap = 10
	)

	min_duration = 70
	max_duration = 90

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.op_stage.plasticsur == 1 && target.op_stage.face == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		var/datum/organ/external/head/h = affected
		if (h.disfigured == 1)
			user.visible_message("[user] starts mending [target]'s vocal cords with \the [tool].", \
			"You start mending [target]'s vocal cords with \the [tool].")
		else
			user.visible_message("[user] starts adjusting [target]'s vocal cords with \the [tool].", \
			"You start adjusting [target]'s vocal cords with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		var/datum/organ/external/head/h = affected
		if (h.disfigured == 1)
			user.visible_message("\blue [user] mends [target]'s vocal cords with \the [tool].", \
			"\blue You mend [target]'s vocal cords with \the [tool].")
			h.disfigured = 0
		else
			user.visible_message("\blue [user] adjusts [target]'s vocal cords with \the [tool].", \
			"\blue You adjust [target]'s vocal cords with \the [tool].")
		target.op_stage.plasticsur = 2

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, clamping [target]'s trachea shut for a moment with \the [tool]!", \
		"\red Your hand slips, clamping [user]'s trachea shut for a moment with \the [tool]!")
		target.losebreath += 10

//reshape_face
/datum/surgery_step/plastic_surgery/reshape_face
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 110
	max_duration = 150

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.op_stage.plasticsur == 2 && target.op_stage.face == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] begins to alter [target]'s appearance with \the [tool].", \
		"You begin to alter [target]'s appearance with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] alters [target]'s appearance with \the [tool].",		\
		"\blue You alter [target]'s appearance with \the [tool].")
		var/i
		while (!i)
			var/randomname
			if (target.gender == MALE)
				randomname = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
			else
				randomname = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))
			if (findname(randomname))
				continue
			else
				target.real_name = randomname
				i++

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, tearing skin on [target]'s face with \the [tool]!", \
		"\red Your hand slips, tearing skin on [target]'s face with \the [tool]!")
		target.apply_damage(20, BRUTE, "head", 1, sharp=1)

/datum/surgery_step/plastic_surgery/cauterize
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 50
	)

	min_duration = 70
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.op_stage.face > 0 && target.op_stage.plasticsur > 0

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] is beginning to cauterize the incision on [target]'s face and neck with \the [tool]." , \
		"You are beginning to cauterize the incision on [target]'s face and neck with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] cauterizes the incision on [target]'s face and neck with \the [tool].", \
		"\blue You cauterize theon [target]'s face and neck with \the [tool].")
		affected.open = 0
		affected.status &= ~ORGAN_BLEEDING
		if (target.op_stage.plasticsur == 2)
			var/datum/organ/external/head/h = affected
			h.disfigured = 0
		target.op_stage.plasticsur = 0
		target.op_stage.face = 0

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, leaving a small burn on [target]'s face with \the [tool]!", \
		"\red Your hand slips, leaving a small burn on [target]'s face with \the [tool]!")
		target.apply_damage(4, BURN, affected)
