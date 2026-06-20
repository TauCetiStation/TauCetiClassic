/datum/surgery_step/clamp
	allowed_qualities = list(QUALITY_CLAMP)

/datum/surgery_step/clamp/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return FALSE

/datum/surgery_step/clamp/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
/datum/surgery_step/clamp/prepare_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
/datum/surgery_step/clamp/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
/datum/surgery_step/clamp/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
