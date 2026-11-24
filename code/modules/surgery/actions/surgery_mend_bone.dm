/datum/surgery_step/mend_bones
	name = "Glue bone"
	allowed_qualities = list(
		QUALITY_SURGERY_MENDINGBONE,
		QUALITY_MENDING_IPC
		)

	allowed_species = list("exclude", DIONA)
	min_duration = 4 SECONDS
	max_duration = 6 SECONDS

/datum/surgery_step/mend_bones/can_use(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/I)
	if(!..())
		return FALSE
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)
	if(target_zone == O_EYES && bodypart.controller.bodypart_type == BODYPART_ROBOTIC)
		var/obj/item/organ/internal/eyes/eyes = bodypart.bodypart_organs[O_EYES]
		if(!eyes)
			return FALSE
		if(eyes.surgery_stage == BP_RETRACT_OS)
			return TRUE
	if(target_zone == O_MOUTH && bodypart.controller.bodypart_type == BODYPART_ROBOTIC)
		var/obj/item/organ/external/head/head = bodypart
		if(head.ps_status == BP_RETRACT_OS)
			return TRUE

	if((bodypart.stage & BONESET_STAGE || !(bodypart.stage & BONEGEL_STAGE)) && bodypart.open >= BP_RETRACT_OS)
		return TRUE

/datum/surgery_step/mend_bones/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/I)
	. = ..()
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)
	if(target_zone == O_EYES && bodypart.controller.bodypart_type == BODYPART_ROBOTIC)
		var/obj/item/organ/internal/eyes/eyes = bodypart.bodypart_organs[O_EYES]
		if(eyes.surgery_stage == BP_RETRACT_OS)
			msg = "<span class='notice'>[user] begin to mending the nerves and lenses in [surgery_victim]'s eyes with \the [I].</span>"
			self_msg = "<span class='notice'>You start to mending the nerves and lenses in [surgery_victim]'s eyes with \the [I].</span>"
			user.visible_message(msg, self_msg)

	if(target_zone == O_MOUTH && bodypart.controller.bodypart_type == BODYPART_ROBOTIC)
		var/obj/item/organ/external/head/head = bodypart
		if(head.ps_status == BP_RETRACT_OS)
			msg = "<span class='notice'>[user] begin to repair [surgery_victim]'s screen with \the [I].</span>"
			self_msg = "<span class='notice'>You start to repair [surgery_victim]'s screen with \the [I].</span>"
			user.visible_message(msg, self_msg)

	if((bodypart.stage & BONESET_STAGE || !(bodypart.stage & BONEGEL_STAGE)) && bodypart.open >= BP_RETRACT_OS)
		msg = "<span class='notice'>[user] beging to [bodypart.stage & BONESET_STAGE ? "mending" : "applying medication"] to the damaged bones in [surgery_victim]'s [bodypart.name] with \the [I].</span>"
		self_msg = "<span class='notice'>You start to [bodypart.stage & BONESET_STAGE ? "mending" : "applying medication"] to the damaged bones in [surgery_victim]'s [bodypart.name] with \the [I].</span>"
		user.visible_message(msg, self_msg)

/datum/surgery_step/mend_bones/end_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/I)
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	if(target_zone == O_EYES && bodypart.controller.bodypart_type == BODYPART_ROBOTIC)
		fix_eyes()
	if(target_zone == O_MOUTH && bodypart.controller.bodypart_type == BODYPART_ROBOTIC)
		var/obj/item/organ/external/head/head = bodypart
		head.disfigured = FALSE
		msg = "<span class='notice'>[user] finish to repair [surgery_victim]'s screen with \the [I].</span>"
		self_msg = "<span class='notice'>You finish to repair [surgery_victim]'s screen with \the [I].</span>"
		user.visible_message(msg, self_msg)
	else if((bodypart.stage & BONESET_STAGE || !(bodypart.stage & BONEGEL_STAGE)) && bodypart.open >= BP_RETRACT_OS)
		msg = "<span class='notice'>[user] finish to [bodypart.stage & BONESET_STAGE ? "mending" : "applying medication"] to the damaged bones in [surgery_victim]'s [bodypart.name] with \the [I].</span>"
		self_msg = "<span class='notice'>You finish to [bodypart.stage & BONESET_STAGE ? "mending" : "applying medication"] to the damaged bones in [surgery_victim]'s [bodypart.name] with \the [I].</span>"
		user.visible_message(msg, self_msg)
		if(bodypart.stage & BONESET_STAGE)
			bodypart.status &= ~(ORGAN_BROKEN | ORGAN_SPLINTED)
			bodypart.stage &= ~(BONEGEL_STAGE | BONESET_STAGE)
			bodypart.perma_injury = 0
		else
			bodypart.stage |= BONEGEL_STAGE
