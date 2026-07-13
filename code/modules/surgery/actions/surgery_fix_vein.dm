#define MEND_ARTERY_SURGERY (bodypart.open >= BP_RETRACT_OS && bodypart.status & ORGAN_ARTERY_CUT)
#define MEND_BRAIN_SURGERY (bodypart.open == BP_RIBCAGE_OS && target_zone == BP_HEAD && surgery_victim.has_brain())

#define MEND_BRAIN_ACTION "mend hematoma in [surgery_victim]'s brain with \the [tool]"
#define MEND_ARTERY_ACTION "patching the damaged vein in [surgery_victim]'s [bodypart.name] with \the [tool]"

/datum/surgery_step/fix_veins
	allowed_qualities = list(
		QUALITY_FIX_VEIN
		)

	allowed_species = list("exclude", DIONA, IPC)
	min_duration = 8 SECONDS
	max_duration = 10 SECONDS

/datum/surgery_step/fix_veins/can_use(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	if(!..())
		return FALSE

	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	if(MEND_ARTERY_SURGERY)
		msg = "<span class='notice'>[user] begin [MEND_ARTERY_ACTION].</span>"
		self_msg = "<span class='notice'>You start [MEND_ARTERY_ACTION].</span>"
		user.visible_message(msg, self_msg)
		return TRUE

	else if(MEND_BRAIN_SURGERY)
		var/obj/item/organ/internal/brain/brain = surgery_victim.organs_by_name[O_BRAIN]
		if(brain.damage > 0)
			msg = "<span class='notice'>[user] begin to [MEND_BRAIN_ACTION].</span>"
			self_msg = "<span class='notice'>You start to [MEND_BRAIN_ACTION].</span>"
			user.visible_message(msg, self_msg)
			return TRUE

/datum/surgery_step/fix_veins/end_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	if(bodypart.status & ORGAN_ARTERY_CUT)
		msg = "<span class='notice'>[user] finish [MEND_ARTERY_ACTION].</span>"
		self_msg = "<span class='notice'>You finish [MEND_ARTERY_ACTION].</span>"
		bodypart.status &= ~ORGAN_ARTERY_CUT

	else if(target_zone == BP_HEAD)
		var/obj/item/organ/internal/brain/brain = surgery_victim.organs_by_name[O_BRAIN]
		if(brain)
			msg = "<span class='notice'>[user] finish [MEND_BRAIN_ACTION].</span>"
			self_msg = "<span class='notice'>You finish [MEND_BRAIN_ACTION].</span>"
			brain.damage = 0

	user.visible_message(msg, self_msg)
