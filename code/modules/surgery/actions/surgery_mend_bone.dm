#define BONE_GEL_SURGERY ((bodypart.stage & BP_SET || !(bodypart.stage & BP_GEL)) && bodypart.open >= BP_RETRACT_OS)
#define BONE_GEL_ACTION  "[bodypart.stage & BP_SET ? "mending" : "applying medication"] to the damaged bones in [surgery_victim]'s [bodypart.name] with \the [tool] "

#define MEND_IPC_EYES_SURGERY (target_zone == O_EYES && bodypart.controller.bodypart_type == BODYPART_ROBOTIC)
#define MEND_IPC_FACE_SURGERY (target_zone == O_MOUTH && bodypart.controller.bodypart_type == BODYPART_ROBOTIC)
#define MEND_IPC_FACE_ACTION  "repair [surgery_victim]'s screen with \the [tool]"

/datum/surgery_step/mend_bones
	allowed_qualities = list(
		QUALITY_MENDING_BONE,
		QUALITY_MENDING_IPC
		)

	allowed_species = list("exclude", DIONA)
	min_duration = 4 SECONDS
	max_duration = 6 SECONDS

/datum/surgery_step/mend_bones/can_use(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)
	if(MEND_IPC_EYES_SURGERY)
		var/obj/item/organ/internal/eyes/eyes = bodypart.bodypart_organs[O_EYES]
		if(!eyes)
			return FALSE
		if(eyes.surgery_stage == BP_RETRACT_OS)
			msg = "<span class='notice'>[user] begin to [EYES_MENDING_ACTION].</span>"
			self_msg = "<span class='notice'>You start to [EYES_MENDING_ACTION].</span>"
			user.visible_message(msg, self_msg)
			return TRUE
	if(MEND_IPC_FACE_SURGERY)
		var/obj/item/organ/external/head/head = bodypart
		if(head.ps_status == BP_RETRACT_OS)
			msg = "<span class='notice'>[user] begin to [MEND_IPC_FACE_ACTION].</span>"
			self_msg = "<span class='notice'>You start to [MEND_IPC_FACE_ACTION].</span>"
			user.visible_message(msg, self_msg)
			return TRUE

	if(BONE_GEL_SURGERY)
		msg = "<span class='notice'>[user] beging to [BONE_GEL_ACTION].</span>"
		self_msg = "<span class='notice'>You start to [BONE_GEL_ACTION].</span>"
		user.visible_message(msg, self_msg)
		return TRUE

/datum/surgery_step/mend_bones/end_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	if(MEND_IPC_EYES_SURGERY)
		fix_eyes()
	if(MEND_IPC_FACE_SURGERY)
		var/obj/item/organ/external/head/head = bodypart
		head.disfigured = FALSE
		msg = "<span class='notice'>[user] finish to [MEND_IPC_FACE_ACTION].</span>"
		self_msg = "<span class='notice'>You finish to [MEND_IPC_FACE_ACTION].</span>"
		user.visible_message(msg, self_msg)
	else if(BONE_GEL_SURGERY)
		msg = "<span class='notice'>[user] finish to [BONE_GEL_ACTION].</span>"
		self_msg = "<span class='notice'>You finish to [BONE_GEL_ACTION].</span>"
		user.visible_message(msg, self_msg)
		if(bodypart.stage & BP_SET)
			bodypart.status &= ~(ORGAN_BROKEN | ORGAN_SPLINTED)
			bodypart.stage &= ~(BP_GEL | BP_SET)
			bodypart.perma_injury = 0
		else
			bodypart.stage |= BP_GEL
