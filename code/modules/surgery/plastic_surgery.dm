//////////////////////////////////////////////////////////////////
//						Plastic Surgery							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/plastic_surgery
	clothless = 0
	priority = 3
	can_infect = 0

/datum/surgery_step/plastic_surgery/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return 0
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (!BP)
		return 0
	return target_zone == O_MOUTH

/datum/surgery_step/plastic_surgery/retract_face
	allowed_tools = list(
	/obj/item/weapon/retractor = 100,           \
	/obj/item/weapon/kitchen/utensil/fork = 75, \
	/obj/item/weapon/screwdriver = 50
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/plastic_surgery/retract_face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.plasticsur == 0 && target.op_stage.face == 1

/datum/surgery_step/plastic_surgery/retract_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts adjusting the skin on [target]'s face with \the [tool].", \
	"You start adjusting the skin on [target]'s face with \the [tool].")
	..()

/datum/surgery_step/plastic_surgery/retract_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] pulls the skin on [target]'s face with \the [tool].</span>",	\
	"<span class='notice'>You pull the skin on [target]'s face with \the [tool].</span>")
	target.op_stage.plasticsur = 1

/datum/surgery_step/plastic_surgery/retract_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing skin on [target]'s face with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, tearing skin on [target]'s face with \the [tool]!</span>")
	BP.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/plastic_surgery/adjust_vocal
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100, 	\
	/obj/item/stack/cable_coil = 75, 	\
	/obj/item/weapon/wirecutters = 75,           \
	/obj/item/weapon/kitchen/utensil/fork = 50,  \
	/obj/item/device/assembly/mousetrap = 10
	)

	min_duration = 70
	max_duration = 90

/datum/surgery_step/plastic_surgery/adjust_vocal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.plasticsur == 1 && target.op_stage.face == 1

/datum/surgery_step/plastic_surgery/adjust_vocal/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	var/obj/item/organ/external/head/H = BP
	if (H.disfigured == 1)
		user.visible_message("[user] starts mending [target]'s vocal cords with \the [tool].", \
		"You start mending [target]'s vocal cords with \the [tool].")
	else
		user.visible_message("[user] starts adjusting [target]'s vocal cords with \the [tool].", \
		"You start adjusting [target]'s vocal cords with \the [tool].")
	..()

/datum/surgery_step/plastic_surgery/adjust_vocal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	var/obj/item/organ/external/head/H = BP
	if (H.disfigured == 1)
		user.visible_message("<span class='notice'>[user] mends [target]'s vocal cords with \the [tool].</span>", \
		"<span class='notice'>You mend [target]'s vocal cords with \the [tool].</span>")
		H.disfigured = 0
	else
		user.visible_message("<span class='notice'>[user] adjusts [target]'s vocal cords with \the [tool].</span>", \
		"<span class='notice'>You adjust [target]'s vocal cords with \the [tool].</span>")
	target.op_stage.plasticsur = 2

/datum/surgery_step/plastic_surgery/adjust_vocal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, clamping [target]'s trachea shut for a moment with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, clamping [user]'s trachea shut for a moment with \the [tool]!</span>")
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

/datum/surgery_step/plastic_surgery/reshape_face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.plasticsur == 2 && target.op_stage.face == 1

/datum/surgery_step/plastic_surgery/reshape_face/prepare_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	target.op_stage.plastic_new_name = sanitize_name(input(user, "Choose your character's name:", "Changing")  as text|null)
	return target.op_stage.plastic_new_name && checks_for_surgery(target, user, clothless)

/datum/surgery_step/plastic_surgery/reshape_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to alter [target]'s appearance with \the [tool].", \
	"You begin to alter [target]'s appearance with \the [tool].")
	..()

/datum/surgery_step/plastic_surgery/reshape_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] alters [target]'s appearance with \the [tool].</span>",		\
	"<span class='notice'>You alter [target]'s appearance with \the [tool].</span>")
	if(target.op_stage.plastic_new_name)
		target.real_name = target.op_stage.plastic_new_name
		target.op_stage.plastic_new_name = null

/datum/surgery_step/plastic_surgery/reshape_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing skin on [target]'s face with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, tearing skin on [target]'s face with \the [tool]!</span>")
	BP.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)

/datum/surgery_step/plastic_surgery/cauterize
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 50
	)

	min_duration = 70
	max_duration = 100

/datum/surgery_step/plastic_surgery/cauterize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.face > 0 && target.op_stage.plasticsur > 0

/datum/surgery_step/plastic_surgery/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning to cauterize the incision on [target]'s face and neck with \the [tool]." , \
	"You are beginning to cauterize the incision on [target]'s face and neck with \the [tool].")
	..()

/datum/surgery_step/plastic_surgery/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='notice'>[user] cauterizes the incision on [target]'s face and neck with \the [tool].</span>", \
	"<span class='notice'>You cauterize theon [target]'s face and neck with \the [tool].</span>")
	BP.open = 0
	BP.status &= ~ORGAN_BLEEDING
	if (target.op_stage.plasticsur == 2)
		var/obj/item/organ/external/head/H = BP
		H.disfigured = 0
	target.op_stage.plasticsur = 0
	target.op_stage.face = 0

/datum/surgery_step/plastic_surgery/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, leaving a small burn on [target]'s face with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, leaving a small burn on [target]'s face with \the [tool]!</span>")
	BP.take_damage(0, 4, used_weapon = tool)
