/datum/surgery_step/bone_set
	name = "Set bone"
	allowed_qualities = list(
		QUALITY_SURGERY_BONESET
		)

	allowed_species = list("exclude", IPC, DIONA)
	min_duration = 8 SECONDS
	max_duration = 10 SECONDS


/datum/surgery_step/bone_set/can_use(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)
	if(bodypart.open >= BP_RETRACT_OS && (bodypart.stage & BONEGEL_STAGE) && !(bodypart.stage & BONESET_STAGE))
		return TRUE
	return FALSE

/datum/surgery_step/bone_set/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/I)
	. = ..()
	if(bodypart.open >= BP_RETRACT_OS && (bodypart.stage & BONEGEL_STAGE) && !(bodypart.stage & BONESET_STAGE))
		msg = "<span class='notice'>[user] begin to set the bone in [surgery_victim]'s [bodypart.name] in place with \the [tool].</span>"
		self_msg = "<span class='notice'>You start to set the bone in [surgery_victim]'s [bodypart.name] in place with \the [tool].</span>"
		user.visible_message(msg, self_msg)

/datum/surgery_step/bone_set/end_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)
	bodypart.stage |= BONESET_STAGE
	msg = "<span class='notice'>[user] finish to set the bone in [surgery_victim]'s [bodypart.name] in place with \the [tool].</span>"
	self_msg = "<span class='notice'>You finish to set the bone in [surgery_victim]'s [bodypart.name] in place with \the [tool].</span>"
	user.visible_message(msg, self_msg)
	surgery_victim.custom_pain("The pain in your [bodypart.name] is going to make you pass out!", 1)
