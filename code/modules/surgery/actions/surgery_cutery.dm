#define CUTERIZE_SURGERY (bodypart.open > BP_DEFAULT_OS && bodypart.controller.bodypart_type != BODYPART_ROBOTIC)
#define CUTERIZE_ACTION  "cauterize the incision on [surgery_victim]'s [bodypart.name] with \the [tool]."

/datum/surgery_step/cutery
	allowed_qualities = list(
		QUALITY_CAUTER
		)

	min_duration = 6 SECONDS
	max_duration = 8 SECONDS

/datum/surgery_step/cutery/can_use(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	switch(target_zone)
		if(O_MOUTH)
			var/obj/item/organ/external/head/head = bodypart
			if(head.ps_status > BP_DEFAULT_OS)
				msg = "<span class='notice'>[user] begin to [CUTERIZE_ACTION].</span>"
				self_msg = "<span class='notice'>You start to [CUTERIZE_ACTION].</span>"
				user.visible_message(msg, self_msg)
				return TRUE
		if(O_EYES)
			var/obj/item/organ/internal/eyes/eyes = bodypart.bodypart_organs[O_EYES]
			if(eyes.surgery_stage > BP_DEFAULT_OS)
				msg = "<span class='notice'>[user] begin to [CUTERIZE_ACTION].</span>"
				self_msg = "<span class='notice'>You start to [CUTERIZE_ACTION].</span>"
				user.visible_message(msg, self_msg)
				return TRUE
		else
			if(CUTERIZE_SURGERY)
				msg = "<span class='notice'>[user] begin to [CUTERIZE_ACTION].</span>"
				self_msg = "<span class='notice'>You start to [CUTERIZE_ACTION].</span>"
				user.visible_message(msg, self_msg)
				return TRUE
	return FALSE

/datum/surgery_step/cutery/end_step(mob/living/user, mob/living/carbon/human/surgery_victim, target_zone, obj/item/tool)
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)
	msg = "<span class='notice'>[user] finish to [CUTERIZE_ACTION].</span>"
	self_msg = "<span class='notice'>You finish to [CUTERIZE_ACTION].</span>"
	cp_msg = "Your [bodypart.name] is begin burned!"

	switch(target_zone)
		if(O_MOUTH)
			var/obj/item/organ/external/head/head = bodypart
			head.ps_status = BP_DEFAULT_OS
		if(O_EYES)
			var/obj/item/organ/internal/eyes/eyes = bodypart.bodypart_organs[O_EYES]
			eyes.surgery_stage = BP_DEFAULT_OS
		else
			if(bodypart.cavity)
				bodypart.cavity = FALSE
			bodypart.open = BP_DEFAULT_OS

	bodypart.status &= ~ORGAN_BLEEDING

	user.visible_message(msg, self_msg)
	surgery_victim.custom_pain(cp_msg, 1)
