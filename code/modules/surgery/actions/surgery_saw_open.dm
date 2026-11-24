/datum/surgery_step/surgery_saw
	name = "Saw"
	allowed_qualities = list(
		QUALITY_SURGERY_SAW,
		QUALITY_PRYING
		)

	allowed_species = null //all species

	min_duration = 8 SECONDS
	max_duration = 12 SECONDS


/datum/surgery_step/surgery_saw/can_use(mob/living/user, mob/living/carbon/target, target_zone, obj/item/I)
	if(isslime(target))
		var/mob/living/carbon/slime/slime = target
		if(slime.surgery_status == SLIME_SKIN_PREPARED)
			return TRUE
		return FALSE

	var/mob/living/carbon/human/surgery_victim = target
	if(!..())
		return FALSE

	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	//exeption for diona
	if(bodypart.open == BP_DEFAULT_OS && target_zone == BP_CHEST && surgery_victim.get_species() == DIONA)
		return TRUE
	if(bodypart.open == BP_RETRACT_OS)
		return TRUE
	return FALSE

/datum/surgery_step/surgery_saw/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/I)
	. = ..()
	if(isslime(target))
		var/mob/living/carbon/slime/slime = target
		msg = "[user] begin to cut out one of [target]'s cores with \the [I]."
		self_msg = "You begin to cut out one of [target]'s cores with \the [I]."
		if(slime.surgery_status == SLIME_SKIN_PREPARED)
			user.visible_message(msg, self_msg)

	var/mob/living/carbon/human/surgery_victim = target
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)

	//exeption for diona
	if(bodypart.open == BP_DEFAULT_OS && target_zone == BP_CHEST && surgery_victim.get_species() == DIONA)
		msg = "[user] begin to separating [surgery_victim]'s brain from \his spine with \the [I]."
		self_msg = "You begin to separating [surgery_victim]'s brain from \his spine with \the [I]."
		user.visible_message(msg, self_msg)
	if(bodypart.open == BP_RETRACT_OS)
		switch(target_zone)
			if(O_MOUTH, BP_R_ARM, BP_L_ARM, BP_R_LEG, BP_L_LEG)
				msg = "[user] begin to cut off [surgery_victim]'s [bodypart.name] with \the [I]."
				self_msg = "You begin to cut off [surgery_victim]'s [bodypart.name] with \the [I]."
				cp_msg = "Your [bodypart.name] is being ripped apart!"
			if(BP_CHEST, BP_HEAD)
				msg = "[user] begin to cut through [surgery_victim]'s ribcage with \the [I]."
				self_msg = "You begin to cut through [surgery_victim]'s ribcage with \the [I]."
				cp_msg = "Something hurts horribly in your [bodypart.name]!"
		user.visible_message(msg, self_msg)
		surgery_victim.custom_pain(cp_msg, 1)


/datum/surgery_step/surgery_saw/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/I)
	if(isslime(target))
		var/mob/living/carbon/slime/slime = target
		msg = "[user] finish to cut out one of [target]'s cores with \the [I]."
		self_msg = "You finish to cut out one of [target]'s cores with \the [I]."
		if(slime.surgery_status == SLIME_SKIN_PREPARED)
			if(slime.cores >= 0)
				new slime.coretype(slime.loc)
			if(slime.cores <= 0)
				var/origstate = initial(slime.icon_state)
				slime.icon_state = "[origstate] dead-nocore"
		return

	var/mob/living/carbon/human/surgery_victim = target
	var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)
	if(bodypart.open == BP_DEFAULT_OS && target_zone == BP_CHEST && surgery_victim.get_species() == DIONA)
		prepare_to_detach_brain() // it kill diona and relise nymph
	else
		switch(target_zone)
			if(O_MOUTH, BP_R_ARM, BP_L_ARM, BP_R_LEG, BP_L_LEG)
				msg = "[user] finish cut off [surgery_victim]'s [bodypart.name] with \the [I]."
				self_msg = "You finish cut off [surgery_victim]'s [bodypart.name] with \the [I]."
				bodypart.droplimb(null, TRUE)
			if(BP_CHEST, BP_HEAD)
				msg = "[user] finish cut through [surgery_victim]'s ribcage with \the [I]."
				self_msg = "You finish cut through [surgery_victim]'s ribcage with \the [I]."
				bodypart.open = BP_INTERNALS_OS

	user.visible_message(msg, self_msg)
