#define SET_BONE_SURGERY (bodypart.open >= BP_RETRACT_OS && bodypart.stage & BP_GEL && !(bodypart.stage & BP_SET))
#define SET_BONE_ACTION  "set the bone in [surgery_victim]'s [bodypart.name] in place with \the [tool]"
/datum/surgery_step/bone_set
	allowed_qualities = list(
		QUALITY_BONE_SET
		)

	allowed_species = list("exclude", IPC, DIONA)
	min_duration = 8 SECONDS
	max_duration = 10 SECONDS


/datum/surgery_step/bone_set/can_use(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	if(SET_BONE_SURGERY)
		msg = "<span class='notice'>[user] begin to [SET_BONE_ACTION]."
		self_msg = "<span class='notice'>You start to [SET_BONE_ACTION]."
		user.visible_message(msg, self_msg)
		return TRUE

	return FALSE

/datum/surgery_step/bone_set/end_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)
	bodypart.stage |= BP_SET
	msg = "<span class='notice'>[user] finish to [SET_BONE_ACTION]."
	self_msg = "<span class='notice'>You finish to [SET_BONE_ACTION]."
	user.visible_message(msg, self_msg)
	surgery_victim.custom_pain("The pain in your [bodypart.name] is going to make you pass out!", 1)
