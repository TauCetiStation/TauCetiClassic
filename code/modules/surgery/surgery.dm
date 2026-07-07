// Poking inside something with something
#define POKING_ACTION             "poking around inside the [surgery_victim]'s [bodypart.name] with \the [tool]"
#define NO_POKING_MESSAGE         "could not find anything inside [surgery_victim]'s [bodypart.name], and pulls \the [tool] out"
#define EYES_MENDING_ACTION "mending the nerves and lenses in [surgery_victim]'s eyes with \the [tool]"
// Fail output
#define F_ACTION_RANDOM           (pick("slips", "dragged", "spasms"))
#define FAIL_ACTION               "hand [F_ACTION_RANDOM], when you operate"

/* SURGERY STEPS */
/datum/surgery_step
	var/priority = 0	//steps with higher priority would be attempted first

	//type path referencing tools that can be used for this step, and how well are they suited for it
	var/list/allowed_tools = null
	var/list/allowed_qualities = null
	// type paths referencing mutantraces that this step applies to.
	var/list/allowed_species = list("exclude", IPC)

	//duration of the step
	var/min_duration = 0
	var/max_duration = 0

	//How much blood this step can get on surgeon. 1 - hands, 2 - full body.
	var/blood_level = 0

	//Cloth check
	var/clothless = 1
	var/required_skills = list(/datum/skill/surgery = SKILL_LEVEL_TRAINED)
	var/skills_speed_bonus = -0.30 // -30% for each surplus level
	var/msg = null
	var/self_msg = null
	var/cp_msg = null
// returns how well tool is suited for this step
/datum/surgery_step/proc/tool_quality(obj/item/tool, mob/living/carbon/C)
	for(var/quality in allowed_qualities)
		if(get_suiteble_quality(quality, allowed_qualities, C))
			return tool.get_quality(quality)

	return 0

/datum/surgery_step/proc/get_suiteble_quality(quality, list/allowed_qualities, mob/living/carbon/C)
	if(isslime(C))
		return get_surg_quality(quality)

	var/mob/living/carbon/human/H = C
	if(H.species.flags[IS_SYNTHETIC] || H.species.flags[TRAIT_NO_BLOOD])
		return get_technic_quality(quality)
	else
		return get_surg_quality(quality)

/datum/surgery_step/proc/can_infect(obj/item/organ/external/bodypart)
	if(bodypart.status & ORGAN_ROBOT)
		return FALSE
	return TRUE

// Checks if this step applies to the mutantrace of the user.
/datum/surgery_step/proc/is_valid_mutantrace(mob/living/carbon/human/target)
	if(ishuman(target) && allowed_species)
		if(("exclude" in allowed_species) == (target.get_species() in allowed_species))
			return FALSE
	return TRUE

// checks whether this step can be applied with the given user and target
/datum/surgery_step/proc/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!ishuman(target))
		return FALSE
	var/obj/item/organ/external/bodypart = target.get_bodypart(target_zone)
	if(!bodypart)
		return FALSE
	if(bodypart.is_stump())
	//stump preparing, prevert etc checks, is target bodypart is stump
		return TRUE
	return TRUE

/datum/surgery_step/proc/prepare_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return TRUE

// does stuff to begin the step, usually just printing messages. Moved germs transfering and bloodying here too
/datum/surgery_step/proc/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/bodypart = target.get_bodypart(target_zone)
	if(can_infect(bodypart) && bodypart)
		spread_germs_to_organ(bodypart, user, tool)
	if(ishuman(user) && prob(60))
		var/mob/living/carbon/human/H = user
		if(blood_level)
			H.bloody_hands(target, 0)
		if(blood_level > 1)
			H.bloody_body(target, 0)
	return

// does stuff to end the step, which is normally print a message + do whatever this step changes
/datum/surgery_step/proc/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return

// stuff that happens when the step fails
/datum/surgery_step/proc/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return null

/// Outputs a consolidated warning about necrotic organs that can't be treated by "fix" step.
/datum/surgery_step/proc/necrotic_organs_warning(mob/living/user, mob/living/carbon/human/target, list/dead_organs)
	if(!length(dead_organs))
		return
	var/list/organ_names = list()
	for(var/obj/item/organ/internal/IO as anything in dead_organs)
		organ_names += IO.name
	if(organ_names.len == 1)
		to_chat(user, "<span class='warning'>[target]'s [organ_names[1]] is necrotic and can't be treated this way.</span>")
	else
		to_chat(user, "<span class='warning'>[target]'s [get_english_list(organ_names)] are necrotic and can't be treated this way.</span>")

/proc/spread_germs_to_organ(obj/item/organ/external/bodypart, mob/living/carbon/human/user, obj/item/tool)
	if(!istype(user) || !istype(bodypart))
		return

	var/germ_level = 0
	if(user.gloves)
		germ_level += user.gloves.germ_level
	else
		germ_level += user.germ_level

	if(tool.blood_DNA && tool.blood_DNA.len) //germs from blood-stained tools
		germ_level += GERM_LEVEL_AMBIENT * 0.25

	if(HAS_TRAIT(tool, TRAIT_XENO_FUR))
		germ_level += GERM_LEVEL_AMBIENT * 0.25

	if(ishuman(user) && !user.is_skip_breathe() && !user.wear_mask) //wearing a mask helps preventing people from breathing germs into open incisions
		germ_level += user.germ_level * 0.25

	bodypart.germ_level = max(germ_level, bodypart.germ_level)
	if(bodypart.germ_level)
		bodypart.owner.bad_bodyparts |= bodypart

/proc/checks_for_surgery(mob/living/carbon/M, mob/living/user, check_covering = TRUE)
	if(!user.Adjacent(M))
		return FALSE
	if(!can_operate(M, user))
		return FALSE
	if(!istype(M))
		return FALSE
	if(user.a_intent == INTENT_HARM)	//check for Hippocratic Oath
		return FALSE
	if(user.is_busy(null)) // No target so we allow multiple players to do surgeries on one pawn.
		return FALSE
	if(ishuman(M) && check_covering)
		return check_human_covering(M, user)
	return TRUE

/proc/get_human_covering(mob/living/carbon/human/T)
	var/covered
	for(var/obj/item/I in list(T.wear_suit, T.w_uniform, T.gloves, T.glasses, T.head, T.wear_mask, T.shoes))
		if(I && I.body_parts_covered)
			covered |= I.body_parts_covered
	return covered

/proc/check_covered_bodypart(mob/living/carbon/human/T, covered)
	for(var/obj/item/I in list(T.wear_suit, T.w_uniform, T.gloves, T.glasses, T.head, T.wear_mask, T.shoes))
		if(I && I.body_parts_covered & covered)
			return TRUE
	return FALSE

/proc/get_clothing_by_covered_bodypart(mob/living/carbon/human/T, covered)
	var/static/list/zone_by_clothing_part = list(
		BP_CHEST = UPPER_TORSO,
		BP_GROIN = LOWER_TORSO,
		BP_L_LEG = LEG_LEFT,
		BP_R_LEG = LEG_RIGHT,
		BP_L_ARM = ARM_LEFT,
		BP_R_ARM = ARM_RIGHT,
		BP_HEAD = HEAD,
	)
	var/zone = zone_by_clothing_part[covered]
	for(var/obj/item/clothing/I in list(T.wear_suit, T.w_uniform, T.gloves, T.glasses, T.head, T.wear_mask, T.shoes))
		if(I && (I.body_parts_covered & zone))
			return I
	return FALSE

/proc/check_human_covering(mob/living/carbon/human/T, mob/living/user, covered)
	var/static/list/zone_by_clothing_part = list(
		BP_CHEST = UPPER_TORSO,
		BP_GROIN = LOWER_TORSO,
		BP_L_LEG = LEG_LEFT,
		BP_R_LEG = LEG_RIGHT,
		BP_L_ARM = ARM_LEFT,
		BP_R_ARM = ARM_RIGHT,
		BP_HEAD = HEAD,
		O_MOUTH = FACE,
		O_EYES = EYES,
	)

	var/zone = zone_by_clothing_part[user.get_targetzone()]
	if(!zone)
		return TRUE

	return !check_covered_bodypart(T, zone)

/proc/do_surgery(mob/living/carbon/M, mob/living/user, obj/item/tool)
	checks_for_surgery(M, user, FALSE)
	var/target_zone = user.get_targetzone()
	var/covered
	if(ishuman(M))
		covered = get_human_covering(M)

	var/skillcheck = list(/datum/skill/surgery = SKILL_LEVEL_TRAINED)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.flags[IS_SYNTHETIC])
			skillcheck = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED)

	if(!handle_fumbling(user, M, SKILL_TASK_AVERAGE, skillcheck, "<span class='notice'>You fumble around figuring out how to operate [M].</span>"))
		return

	for(var/datum/surgery_step/S in surgery_steps)
		//check, if target undressed for clothless operations
		if(S.clothless && ishuman(M) && !check_human_covering(M, user, covered))
			return FALSE

		//check if tool is right or close enough and if this step is possible
		if(S.tool_quality(tool, M) && S.can_use(user, M, target_zone, tool) && S.is_valid_mutantrace(M))
			if(!S.prepare_step(user, M, target_zone, tool))	//for some kind of checks
				return TRUE

			S.begin_step(user, M, target_zone, tool)		//...start on it
			var/step_duration = rand(S.min_duration, S.max_duration)

			//We had proper tools! (or RNG smiled.) and User did not move or change hands.
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(prob(H.traumatic_shock) && !H.incapacitated(NONE))
					to_chat(user, "<span class='warning'>The patient is writhing in pain, this interferes with the operation!</span>")
					S.fail_step(user, H, target_zone, tool) //patient movements due to pain interfere with surgery
			if(user.mood_prob(S.tool_quality(tool, M))\
			   && tool.use_tool(M, user, step_duration, volume=100, required_skills_override = S.required_skills, skills_speed_bonus = S.skills_speed_bonus, particle_type = /particles/tool/surgery)\
			   && user.get_targetzone()\
			   && target_zone == user.get_targetzone())
				S.end_step(user, M, target_zone, tool)          //finish successfully
			else if(tool.loc == user && user.Adjacent(M))       //or (also check for tool in hands and being near the target)
				S.fail_step(user, M, target_zone, tool)         //malpractice~
			else	// this failing silently was a pain.
				to_chat(user, "<span class='warning'>You must remain close to your patient to conduct surgery.</span>")

			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.update_surgery()										//shows surgery results
			return	TRUE	  												//don't want to do weapony things after surgery
	return FALSE

/proc/sort_surgeries()
	var/gap = surgery_steps.len
	var/swapped = 1
	while (gap > 1 || swapped)
		swapped = 0
		if(gap > 1)
			gap = round(gap / 1.247330950103979)
		if(gap < 1)
			gap = 1
		for(var/i = 1; gap + i <= surgery_steps.len; i++)
			var/datum/surgery_step/l = surgery_steps[i]		//Fucking hate
			var/datum/surgery_step/r = surgery_steps[gap+i]	//how lists work here
			if(l.priority < r.priority)
				surgery_steps.Swap(i, gap + i)
				swapped = 1

/datum/surgery_status
	var/plastic_new_name = null
	var/plasticsur = 0
	var/eyes = 0
	var/face = 0
	var/appendix = 0
	var/ribcage = 0
	var/skull = 0
	var/brain_cut = 0
	var/brain_fix = 0
	var/list/bodyparts = list() // Holds info about removed bodyparts

/datum/surgery_step/ipc

	allowed_species = list(IPC)
	required_skills = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED, /datum/skill/surgery = SKILL_LEVEL_NOVICE)
	skills_speed_bonus = -0.2

/datum/surgery_step/proc/fix_eyes(mob/living/user, mob/living/carbon/human/surgery_victim, obj/item/tool)
	var/obj/item/organ/internal/eyes/eyes = surgery_victim.organs_by_name[O_EYES]
	msg = "<span class='notice'>[user] finish [EYES_MENDING_ACTION].</span>"
	self_msg = "<span class='notice'>You finish [EYES_MENDING_ACTION].</span>"

	surgery_victim.cure_nearsighted(list(EYE_DAMAGE_TRAIT, EYE_DAMAGE_TEMPORARY_TRAIT))
	surgery_victim.sdisabilities &= ~BLIND
	eyes.damage = 0
