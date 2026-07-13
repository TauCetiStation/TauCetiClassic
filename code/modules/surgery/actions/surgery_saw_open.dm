#define SAW_SURGERY       (bodypart.open == BP_RETRACT_OS)
#define DIONA_SAW_SURGERY (bodypart.open == BP_DEFAULT_OS && target_zone == BP_CHEST && surgery_victim.get_species() == DIONA)


#define SAW_LIMB_ACTION  "cut off [surgery_victim]'s [bodypart.name] with \the [tool]"
#define SAW_BONE_ACTION  "cut through [surgery_victim]'s ribcage with \the [tool]"
#define DIONA_SAW_ACTION "separating [surgery_victim]'s brain from \his spine with \the [tool]"
#define SLIME_SAW_ACTION "cut out one of [target]'s cores with \the [tool]"
/datum/surgery_step/saw_open
	allowed_qualities = list(
		QUALITY_SAW_OPEN,
		QUALITY_PRYING
		)

	allowed_species = null //all species

	min_duration = 8 SECONDS
	max_duration = 12 SECONDS


/datum/surgery_step/saw_open/can_use(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool)
	if(isslime(target))
		var/mob/living/carbon/slime/slime = target
		msg = "[user] begin to [SLIME_SAW_ACTION]."
		self_msg = "You begin to [SLIME_SAW_ACTION]."
		if(slime.surgery_status == PREPARED)
			user.visible_message(msg, self_msg)
			return TRUE
		return FALSE

	var/mob/living/carbon/human/surgery_victim = target
	if(!..())
		return FALSE

	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	//exeption for diona
	if(DIONA_SAW_SURGERY)
		msg = "[user] begin to [DIONA_SAW_ACTION]."
		self_msg = "You begin to [DIONA_SAW_ACTION]."
		user.visible_message(msg, self_msg)
		return TRUE
	if(SAW_SURGERY)
		switch(target_zone)
			if(O_MOUTH, BP_R_ARM, BP_L_ARM, BP_R_LEG, BP_L_LEG)
				msg = "[user] begin to [SAW_LIMB_ACTION]."
				self_msg = "You begin to [SAW_LIMB_ACTION]."
				cp_msg = "Your [bodypart.name] is being ripped apart!"
			if(BP_CHEST, BP_HEAD)
				msg = "[user] begin to [SAW_BONE_ACTION]."
				self_msg = "You begin to [SAW_BONE_ACTION]."
				cp_msg = "Something hurts horribly in your [bodypart.name]!"
		user.visible_message(msg, self_msg)
		surgery_victim.custom_pain(cp_msg, 1)
		return TRUE
	return FALSE

/datum/surgery_step/saw_open/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool)
	if(isslime(target))
		var/mob/living/carbon/slime/slime = target
		msg = "[user] finish to [SLIME_SAW_ACTION]."
		self_msg = "You finish to [SLIME_SAW_ACTION]."
		if(slime.surgery_status == PREPARED)
			if(slime.cores >= 0)
				new slime.coretype(slime.loc)
			if(slime.cores <= 0)
				var/origstate = initial(slime.icon_state)
				slime.icon_state = "[origstate] dead-nocore"
		return

	var/mob/living/carbon/human/surgery_victim = target
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)
	if(DIONA_SAW_SURGERY)
		prepare_to_detach_brain() // it kill diona and relise nymph
	else
		switch(target_zone)
			if(O_MOUTH, BP_R_ARM, BP_L_ARM, BP_R_LEG, BP_L_LEG)
				msg = "[user] finish [SAW_LIMB_ACTION]."
				self_msg = "You finish [SAW_LIMB_ACTION]."
				bodypart.droplimb(null, TRUE)
			if(BP_CHEST, BP_HEAD)
				msg = "[user] finish [SAW_BONE_ACTION]."
				self_msg = "You finish [SAW_BONE_ACTION]."
				bodypart.open = BP_INTERNALS_OS

	user.visible_message(msg, self_msg)
