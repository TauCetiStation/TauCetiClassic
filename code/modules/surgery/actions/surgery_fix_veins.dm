/datum/surgery_step/fix_veins
	name = "FixOvein"
	allowed_qualities = list(
		QUALITY_SURGERY_FIXVEIN
		)

	allowed_species = list("exclude", DIONA, IPC)
	min_duration = 8 SECONDS
	max_duration = 10 SECONDS

/datum/surgery_step/fix_veins/can_use(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/I)
	if(!..())
		return FALSE

	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	if(bodypart.open >= BP_RETRACT_OS && bodypart.status & ORGAN_ARTERY_CUT)
		return TRUE

	else if(bodypart.open == BP_RIBCAGE_OS && target_zone == BP_HEAD && surgery_victim.has_brain())
		var/obj/item/organ/internal/brain/brain = surgery_victim.organs_by_name[O_BRAIN]
		if(brain.damage > 0)
			return TRUE

/datum/surgery_step/fix_veins/begin_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/I)
	. = ..()
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	if(bodypart.open >= BP_RETRACT_OS && bodypart.status & ORGAN_ARTERY_CUT)
		msg = "<span class='notice'>[user] begin patching the damaged vein in [surgery_victim]'s [bodypart.name] with \the [I].</span>"
		self_msg = "<span class='notice'>You start patching the damaged vein in [surgery_victim]'s [bodypart.name] with \the [I].</span>"
		user.visible_message(msg, self_msg)

	else if(bodypart.open == BP_RIBCAGE_OS && target_zone == BP_HEAD && surgery_victim.has_brain())
		var/obj/item/organ/internal/brain/brain = surgery_victim.organs_by_name[O_BRAIN]
		if(brain.damage > 0)
			msg = "<span class='notice'>[user] begin to mend hematoma in [surgery_victim]'s brain with \the [I].</span>"
			self_msg = "<span class='notice'>You start to mend hematoma in [surgery_victim]'s brain with \the [I].</span>"
			user.visible_message(msg, self_msg)


/datum/surgery_step/fix_veins/end_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/I)
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	if(bodypart.status & ORGAN_ARTERY_CUT)
		msg = "<span class='notice'>[user] finish patching the damaged vein in [surgery_victim]'s [bodypart.name] with \the [I].</span>"
		self_msg = "<span class='notice'>You finish patching the damaged vein in [surgery_victim]'s [bodypart.name] with \the [I].</span>"
		bodypart.status &= ~ORGAN_ARTERY_CUT

	else if(target_zone == BP_HEAD)
		var/obj/item/organ/internal/brain/brain = surgery_victim.organs_by_name[O_BRAIN]
		if(brain)
			msg = "<span class='notice'>[user] finish mend hematoma in [surgery_victim]'s brain with \the [I].</span>"
			self_msg = "<span class='notice'>You finish mend hematoma in [surgery_victim]'s brain with \the [I].</span>"
			brain.damage = 0

	user.visible_message(msg, self_msg)
