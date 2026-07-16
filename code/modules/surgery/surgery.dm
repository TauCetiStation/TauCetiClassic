// Poking inside something with something
#define POKING_ACTION             "poking around inside the [surgery_victim]'s [bodypart.name] with \the [tool]"
#define NO_POKING_MESSAGE         "could not find anything inside [surgery_victim]'s [bodypart.name], and pulls \the [tool] out"
#define EYES_MENDING_ACTION       "mending the nerves and lenses in [surgery_victim]'s eyes with \the [tool]"
// Fail output
#define F_ACTION_RANDOM           (pick("slips", "dragged", "spasms"))
#define FAIL_ACTION               "hand [F_ACTION_RANDOM], when you operate"
#define SLIME_FAIL_ACTION         "hand [F_ACTION_RANDOM], causing \him to miss the core"

// Blood level defines
#define NO_BLOOD_STEP        0
#define HANDS_BLOOD_STEP     1
#define FULLBBODY_BLOOD_STEP 2
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
	var/blood_level = HANDS_BLOOD_STEP

	//Cloth check
	var/clothless = 1
	var/required_skills = list(/datum/skill/surgery = SKILL_LEVEL_TRAINED)
	var/skills_speed_bonus = -0.30 // -30% for each surplus level
	var/msg = null
	var/self_msg = null
	var/cp_msg = null
// returns how well tool is suited for this step
/datum/surgery_step/proc/tool_quality(obj/item/tool, mob/living/carbon/C, target_zone)
	for(var/quality in allowed_qualities)
		if(get_suiteble_quality(quality, allowed_qualities, C, target_zone))
			return tool.get_quality(quality)

	return FALSE

/datum/surgery_step/proc/get_suiteble_quality(quality, list/allowed_qualities, mob/living/carbon/C, target_zone)
	if(isslime(C))
		return get_surg_quality(quality)

	var/mob/living/carbon/human/H = C
	var/obj/item/organ/external/bodypart = H.get_bodypart(target_zone)
	if(bodypart.controller.bodypart_type == BODYPART_ROBOTIC)
		return get_technic_quality(quality)
	else
		return get_surg_quality(quality)

/datum/surgery_step/proc/tool_allowed(obj/item/tool)
	for(var/T in allowed_tools)
		if(istype(tool, T))
			return allowed_tools[T]
	return FALSE

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
	if(isstump(bodypart))
	//stump preparing, prevert etc checks, is target bodypart is stump
		return TRUE
	if(bodypart.status & ORGAN_BLEEDING && !tool.get_quality(QUALITY_CLAMP))
		msg = "<span class='warning'>[target]`s [bodypart.name] bleeding!</span>"
		self_msg = "<span class='warning'>You try to reach operation zone, but [target]`s [bodypart.name] bleeding!</span>"
		user.visible_message(msg, self_msg)
		return FALSE
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
		if(blood_level == HANDS_BLOOD_STEP)
			H.bloody_hands(target, 0)
		if(blood_level == FULLBBODY_BLOOD_STEP)
			H.bloody_body(target, 0)
	return

// does stuff to end the step, which is normally print a message + do whatever this step changes
/datum/surgery_step/proc/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return

// stuff that happens when the step fails
/datum/surgery_step/proc/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool)
	if(isslime(target))
		msg = "<span class='warning'>[user]'s [SLIME_FAIL_ACTION]!</span>"
		self_msg = "<span class='warning'>Your`s [SLIME_FAIL_ACTION]!</span>"

	else if(ishuman(target))
		var/mob/living/carbon/human/surgery_victim = target
		var/obj/item/organ/external/bodypart = surgery_victim.get_bodypart(target_zone)
		msg = "<span class='warning'>[user]'s [FAIL_ACTION] [surgery_victim]!</span>"
		self_msg = "<span class='warning'>Your [FAIL_ACTION] [surgery_victim]!</span>"

		bodypart.take_damage(pick(5, 10, 20), 0, DAM_SHARP|DAM_EDGE, tool)
		bodypart.trauma_kit = FALSE
		bodypart.burn_kit = FALSE
		if((issawopen(tool) || isretract(tool)) && !isstump(bodypart) && pick(0, 1))
			bodypart.fracture()
		if((issurgcutt(tool) || issawopen(tool)) && bodypart.open == BP_RIBCAGE_OS)
			if(pick(0, 1))
				for(var/obj/item/organ in bodypart.bodypart_organs)
					if(isorgan(organ))
						if(pick(0, 1))
							organ.take_damage(10, 0, DAM_SHARP|DAM_EDGE, tool)
		if(bodypart.open >= BP_RETRACT_OS && check_inside(bodypart))
		//implant remove
			bodypart.take_damage(20, 0, DAM_SHARP|DAM_EDGE, tool)
			if(length(bodypart.embedded_objects))
				var/fail_prob = 10
				fail_prob += 100 - tool_quality(tool)
				var/obj/item/weapon/implant/imp = locate(/obj/item/weapon/implant) in bodypart.embedded_objects
				if(prob(fail_prob))
					user.visible_message("<span class='warning'>Something cheeps inside [CASE(bodypart, GENITIVE_CASE)] [surgery_victim]!</span>")
					playsound(imp, 'sound/items/countdown.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -3)
					addtimer(CALLBACK(imp, TYPE_PROC_REF(/obj/item/weapon/implant, use_implant)), 3 SECONDS)

	if(msg && self_msg)
		user.visible_message(msg, self_msg)

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
		var/obj/item/organ/external/bodypart = H.get_bodypart(target_zone)
		if(bodypart.controller.bodypart_type == BODYPART_ROBOTIC)
			skillcheck = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED)

	if(!handle_fumbling(user, M, SKILL_TASK_AVERAGE, skillcheck, "<span class='notice'>You fumble around figuring out how to operate [M].</span>"))
		return

	for(var/datum/surgery_step/S in surgery_steps)
		//check, if target undressed for clothless operations
		if(S.clothless && ishuman(M) && !check_human_covering(M, user, covered))
			return FALSE

		//check if tool is right or close enough and if this step is possible
		if((S.tool_allowed(tool) || S.tool_quality(tool, M, target_zone)) && S.can_use(user, M, target_zone, tool) && S.is_valid_mutantrace(M))
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
			if((user.mood_prob(S.tool_quality(tool, M, target_zone)) || user.mood_prob(S.tool_allowed(tool)))\
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

/datum/surgery_step/proc/prepare_to_detach_brain(mob/living/user, mob/living/carbon/human/surgery_victim, obj/item/organ/external/bodypart, obj/item/tool)
	var/mob/living/simple_animal/borer/borer = surgery_victim.has_brain_worms()
	if(borer)
		borer.detatch() //Should remove borer if the brain is removed - RR
	surgery_victim.log_combat(user, "debrained with [tool.name] (INTENT: [uppertext(user.a_intent)])")
	SEND_SIGNAL(user, COMSIG_HUMAN_HARMED_OTHER, surgery_victim)

	if(surgery_victim.get_species() == IPC)
		var/obj/item/organ/external/chest/robot/ipc/ipc_chest = bodypart
		var/obj/item/device/mmi/mmi_positron = new ipc_chest.posibrain_type(surgery_victim.loc)
		if(ipc_chest.posibrain_species == DIONA)
			var/mob/living/carbon/monkey/diona/nymph = new(surgery_victim)
			nymph.real_name = surgery_victim.real_name
			nymph.name = surgery_victim.real_name
			nymph.dna = surgery_victim.dna.Clone()
			nymph.dna.SetSEState(MONKEYBLOCK, 1)
			nymph.dna.SetSEValueRange(MONKEYBLOCK, 0xDAC, 0xFFF)
			if(surgery_victim.mind)
				surgery_victim.mind.transfer_to(nymph)
			for(var/datum/language/L as anything in surgery_victim.languages)
				nymph.add_language(L.name, surgery_victim.languages[L])
			for(var/datum/quirk/Q in surgery_victim.roundstart_quirks)
				nymph.saved_quirks += Q.type
			mmi_positron.transfer_nymph(nymph)
		else
			mmi_positron.transfer_identity(surgery_victim)

	surgery_victim.death()//You want them to die after the brain was transferred, so not to trigger client death() twice.
