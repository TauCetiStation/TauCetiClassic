/* SURGERY STEPS */
/datum/surgery_step
	var/name = "surgery step"
	var/priority = 0	//steps with higher priority would be attempted first

	//type path referencing tools that can be used for this step, and how well are they suited for it
	var/list/allowed_tools = null
	// type paths referencing mutantraces that this step applies to.
	var/list/allowed_species = list("exclude", IPC)

	//duration of the step
	var/min_duration = 0
	var/max_duration = 0

	//evil infection stuff that will make everyone hate me
	var/can_infect = 0
	//How much blood this step can get on surgeon. 1 - hands, 2 - full body.
	var/blood_level = 0

	//Cloth check
	var/clothless = 1
	var/required_skills = list(/datum/skill/surgery = SKILL_LEVEL_TRAINED)
	var/skills_speed_bonus = -0.30 // -30% for each surplus level

// returns how well tool is suited for this step
/datum/surgery_step/proc/tool_quality(obj/item/tool)
	for(var/T in allowed_tools)
		if(istype(tool, T))
			return allowed_tools[T]
	return FALSE

// Checks if this step applies to the mutantrace of the user.
/datum/surgery_step/proc/is_valid_mutantrace(mob/living/carbon/human/target)
	if(ishuman(target) && allowed_species)
		if(("exclude" in allowed_species) == (target.get_species() in allowed_species))
			return FALSE
	return TRUE

// checks whether this step can be applied with the given user and target
/datum/surgery_step/proc/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, silent = FALSE)
	return FALSE

/datum/surgery_step/proc/prepare_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return TRUE

// does stuff to begin the step, usually just printing messages. Moved germs transfering and bloodying here too
/datum/surgery_step/proc/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if(can_infect && BP)
		spread_germs_to_organ(BP, user, tool)
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

/proc/spread_germs_to_organ(obj/item/organ/external/BP, mob/living/carbon/human/user, obj/item/tool)
	if(!istype(user) || !istype(BP))
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

	BP.germ_level = max(germ_level, BP.germ_level)
	if(BP.germ_level)
		BP.owner.bad_bodyparts |= BP

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

/proc/has_medical_hud(mob/living/user)
	return user.has_atom_hud(DATA_HUD_MEDICAL) || user.has_atom_hud(DATA_HUD_MEDICAL_ADV)

/proc/can_use_surgery_radial(mob/living/user)
	if(isrobot(user))
		return TRUE
	if(!ishuman(user))
		return FALSE
	return is_skill_competent(user, list(/datum/skill/surgery = SKILL_LEVEL_PRO))

/proc/get_surgery_environment_items(mob/living/user, list/robot_slots, list/robot_carriers)
	var/list/items = list()

	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		var/list/active_modules = list(R.module_state_1, R.module_state_2, R.module_state_3)
		for(var/slot in 1 to active_modules.len)
			var/obj/item/carrier = active_modules[slot]
			if(!carrier)
				continue
			var/obj/item/I = SEND_SIGNAL(carrier, COMSIG_HAND_GET_ITEM)
			if(!I)
				I = carrier
			items |= I
			if(robot_slots)
				robot_slots[I] = slot
			if(robot_carriers)
				robot_carriers[I] = carrier
		return items

	var/datum/personal_crafting/C = new
	for(var/obj/item/I in C.get_environment(user))
		items |= I
		if(istype(I, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = I
			if(S.try_open(user, check_only = TRUE))
				for(var/obj/item/SI in S.contents)
					items |= SI
	qdel(C)
	return items

/proc/get_available_surgery_tools(mob/living/user, mob/living/carbon/human/target, target_zone, list/robot_slots, list/robot_carriers)
	var/list/best_for_step = list()
	var/list/items = get_surgery_environment_items(user, robot_slots, robot_carriers)

	if(!items.len)
		return best_for_step

	for(var/datum/surgery_step/S in surgery_steps)
		if(!S.is_valid_mutantrace(target))
			continue
		var/best_quality = 0
		var/obj/item/best_tool
		for(var/obj/item/I in items)
			if(isrobot(user) && istype(S, /datum/surgery_step/cavity/place_item) && robot_carriers && robot_carriers[I] == I)
				continue
			var/quality = S.tool_quality(I)
			if(!quality || quality <= best_quality)
				continue
			if(!S.can_use(user, target, target_zone, I, TRUE))
				continue
			best_tool = I
			best_quality = quality
			if(best_quality >= 100)
				break
		if(best_tool)
			best_for_step[S] = best_tool

	return best_for_step

/proc/build_surgery_radial_choices(list/best_for_step, list/choice_to_step, list/choice_to_tool_loc, list/choice_to_tool_parent_loc)
	var/list/step_choices = list()
	var/list/used_step_names = list()

	for(var/datum/surgery_step/S in best_for_step)
		var/obj/item/tool = best_for_step[S]
		var/choice_name = avoid_assoc_duplicate_keys(S.name, used_step_names)
		step_choices[choice_name] = image(icon = tool.icon, icon_state = tool.icon_state)
		choice_to_step[choice_name] = S
		choice_to_tool_loc[choice_name] = tool.loc
		if(istype(tool.loc, /obj/item/weapon/storage))
			choice_to_tool_parent_loc[choice_name] = tool.loc.loc

	return step_choices

/proc/restore_displaced_surgery_item(mob/living/carbon/human/user, list/tool_state)
	var/obj/item/dropped_item = tool_state["dropped_item"]
	var/turf/dropped_turf = tool_state["dropped_turf"]
	if(QDELETED(dropped_item) || dropped_item.loc != dropped_turf || !user.Adjacent(dropped_turf))
		return

	var/dropped_hand = tool_state["dropped_hand"]
	var/hand_slot = dropped_hand ? SLOT_L_HAND : SLOT_R_HAND
	if(!dropped_item.mob_can_equip(user, hand_slot, TRUE))
		return
	dropped_item.mob_pickup(user, dropped_hand)

/proc/is_surgery_tool_source_valid(mob/living/carbon/human/user, obj/item/chosen, atom/tool_original_loc, atom/tool_original_parent_loc)
	if(QDELETED(chosen) || chosen.loc != tool_original_loc)
		return FALSE
	if(istype(tool_original_loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = tool_original_loc
		return S.loc == tool_original_parent_loc && S.try_open(user, check_only = TRUE)
	if(isturf(tool_original_loc))
		return user.Adjacent(chosen)
	return tool_original_loc == user && (user.l_hand == chosen || user.r_hand == chosen)

/proc/can_restore_surgery_tool_to_storage(mob/living/carbon/human/user, obj/item/chosen, obj/item/weapon/storage/S, atom/tool_original_parent_loc)
	if(QDELETED(chosen) || QDELETED(S) || S.loc != tool_original_parent_loc || !S.try_open(user, check_only = TRUE))
		return FALSE
	if(chosen.loc == S)
		return TRUE
	return S.can_be_inserted(chosen, TRUE)

/proc/try_restore_surgery_tool_to_storage(mob/living/carbon/human/user, obj/item/chosen, obj/item/weapon/storage/S, atom/tool_original_parent_loc)
	if(!can_restore_surgery_tool_to_storage(user, chosen, S, tool_original_parent_loc))
		return FALSE
	if(chosen.loc == S)
		return TRUE
	if(!isturf(chosen.loc))
		return FALSE
	return S.handle_item_insertion(chosen, prevent_warning = TRUE)

/proc/prepare_surgery_tool(mob/living/carbon/human/user, obj/item/chosen, atom/tool_original_loc, atom/tool_original_parent_loc)
	var/list/tool_state = list(
		"original_hand" = user.hand,
		"tool_original_loc" = tool_original_loc,
		"tool_original_parent_loc" = tool_original_parent_loc,
	)

	if(chosen.loc == user)
		var/chosen_hand
		if(user.l_hand == chosen)
			chosen_hand = 1
		else if(user.r_hand == chosen)
			chosen_hand = 0
		else
			return
		user.activate_hand(chosen_hand)
		if(user.hand != chosen_hand || user.get_active_hand() != chosen)
			return
		return tool_state

	var/chosen_hand
	for(var/i in 1 to 2)
		var/hand_index = i == 1 ? user.hand : !user.hand
		var/hand_slot = hand_index ? SLOT_L_HAND : SLOT_R_HAND
		if(chosen.mob_can_equip(user, hand_slot, TRUE))
			chosen_hand = hand_index
			break

	if(isnull(chosen_hand))
		for(var/i in 1 to 2)
			var/hand_index = i == 1 ? user.hand : !user.hand
			var/hand_slot = hand_index ? SLOT_L_HAND : SLOT_R_HAND
			var/obj/item/held_item = hand_index ? user.l_hand : user.r_hand
			if(!held_item || held_item == tool_original_loc || held_item.flags & (NODROP | DROPDEL | ABSTRACT))
				continue
			if(!user.has_bodypart_for_slot(hand_slot) || !user.specie_has_slot(hand_slot))
				continue

			user.activate_hand(hand_index)
			if(user.hand != hand_index)
				continue
			var/turf/dropped_turf = get_turf(user)
			if(!user.drop_item(dropped_turf) || held_item.loc != dropped_turf)
				return
			tool_state["dropped_item"] = held_item
			tool_state["dropped_turf"] = dropped_turf
			tool_state["dropped_hand"] = hand_index
			if(!chosen.mob_can_equip(user, hand_slot, TRUE))
				restore_displaced_surgery_item(user, tool_state)
				return
			chosen_hand = hand_index
			break

	if(isnull(chosen_hand))
		return

	user.activate_hand(chosen_hand)
	if(user.hand != chosen_hand)
		restore_displaced_surgery_item(user, tool_state)
		return

	var/picked_up = chosen.mob_pickup(user, chosen_hand)
	if(!picked_up || user.get_active_hand() != chosen)
		if(istype(tool_original_loc, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = tool_original_loc
			try_restore_surgery_tool_to_storage(user, chosen, S, tool_original_parent_loc)
		restore_displaced_surgery_item(user, tool_state)
		return

	return tool_state

/proc/restore_surgery_tool(mob/living/carbon/human/user, obj/item/chosen, list/tool_state)
	var/atom/tool_original_loc = tool_state["tool_original_loc"]
	var/atom/tool_original_parent_loc = tool_state["tool_original_parent_loc"]

	if(!QDELETED(chosen) && (user.l_hand == chosen || user.r_hand == chosen))
		var/chosen_hand = user.l_hand == chosen ? 1 : 0
		user.activate_hand(chosen_hand)
		if(user.hand == chosen_hand && user.get_active_hand() == chosen)
			if(istype(tool_original_loc, /obj/item/weapon/storage))
				var/obj/item/weapon/storage/S = tool_original_loc
				var/returned = FALSE
				if(can_restore_surgery_tool_to_storage(user, chosen, S, tool_original_parent_loc))
					var/turf/drop_turf = get_turf(user)
					if(user.drop_item(drop_turf) && chosen.loc == drop_turf)
						returned = try_restore_surgery_tool_to_storage(user, chosen, S, tool_original_parent_loc)
				if(!returned && user.get_active_hand() == chosen)
					user.drop_item(get_turf(user))
				if(!returned)
					to_chat(user, "<span class='warning'>[chosen] can no longer be returned to [S], leaving it on the floor.</span>")
			else if(isturf(tool_original_loc))
				var/atom/drop_target = user.Adjacent(tool_original_loc) ? tool_original_loc : get_turf(user)
				user.drop_item(drop_target)
			else if(tool_original_loc != user)
				user.drop_item(get_turf(user))

	restore_displaced_surgery_item(user, tool_state)
	user.activate_hand(tool_state["original_hand"])

/proc/try_show_surgery_radial_menu(mob/living/user, mob/living/carbon/human/target, target_zone)
	set waitfor = FALSE

	if(QDELETED(user) || QDELETED(target))
		return
	if(!ishuman(user) && !isrobot(user))
		return
	if(!has_medical_hud(user))
		return
	if(!can_use_surgery_radial(user))
		return
	if(!ishuman(target))
		return
	if(!user.client)
		return
	if(!user.Adjacent(target) || user.incapacitated())
		return

	var/list/robot_slots = list()
	var/list/robot_carriers = list()
	var/list/best_for_step = get_available_surgery_tools(user, target, target_zone, robot_slots, robot_carriers)
	if(!best_for_step.len)
		return

	var/list/choice_to_step = list()
	var/list/choice_to_tool_loc = list()
	var/list/choice_to_tool_parent_loc = list()
	var/list/step_choices = build_surgery_radial_choices(best_for_step, choice_to_step, choice_to_tool_loc, choice_to_tool_parent_loc)

	var/chosen_name = show_radial_menu(user, target, step_choices, radius = 36, require_near = TRUE, tooltips = TRUE)

	if(!chosen_name || QDELETED(user) || QDELETED(target))
		return
	if(!user.client || !has_medical_hud(user) || !can_use_surgery_radial(user))
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_IMMOBILIZED) || user.get_targetzone() != target_zone)
		return
	if(!checks_for_surgery(target, user, FALSE))
		return

	var/datum/surgery_step/chosen_step = choice_to_step[chosen_name]
	var/obj/item/chosen = best_for_step[chosen_step]
	if(QDELETED(chosen) || !(chosen_step in surgery_steps))
		return
	if(!chosen_step.tool_quality(chosen) || !chosen_step.is_valid_mutantrace(target) || !chosen_step.can_use(user, target, target_zone, chosen, TRUE))
		return

	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		var/slot = robot_slots[chosen]
		var/obj/item/carrier = robot_carriers[chosen]
		var/list/active_modules = list(R.module_state_1, R.module_state_2, R.module_state_3)
		if(!slot || active_modules[slot] != carrier)
			return
		var/obj/item/current_tool = SEND_SIGNAL(carrier, COMSIG_HAND_GET_ITEM)
		if(!current_tool)
			current_tool = carrier
		if(current_tool != chosen)
			return
		R.select_module(slot)
		if(R.get_active_hand() != chosen)
			return
		if(do_surgery(target, user, chosen, from_radial = TRUE, forced_zone = target_zone, selected_step = chosen_step))
			INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(try_show_surgery_radial_menu), user, target, target_zone)
		return

	var/atom/tool_original_loc = choice_to_tool_loc[chosen_name]
	var/atom/tool_original_parent_loc = choice_to_tool_parent_loc[chosen_name]
	var/mob/living/carbon/human/H = user
	if(!is_surgery_tool_source_valid(H, chosen, tool_original_loc, tool_original_parent_loc))
		return
	var/list/tool_state = prepare_surgery_tool(H, chosen, tool_original_loc, tool_original_parent_loc)
	if(!tool_state)
		to_chat(user, "<span class='warning'>You can't safely pick up [chosen].</span>")
		return

	var/surgery_started = do_surgery(target, user, chosen, from_radial = TRUE, forced_zone = target_zone, selected_step = chosen_step)
	restore_surgery_tool(H, chosen, tool_state)
	if(surgery_started)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(try_show_surgery_radial_menu), user, target, target_zone)

/proc/do_surgery(mob/living/carbon/M, mob/living/user, obj/item/tool, from_radial = FALSE, forced_zone = null, datum/surgery_step/selected_step = null)
	if(from_radial && !selected_step)
		return FALSE
	if(selected_step && !(selected_step in surgery_steps))
		return FALSE
	var/target_zone = forced_zone || user.get_targetzone()
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

	var/list/steps_to_try = selected_step ? list(selected_step) : surgery_steps
	for(var/datum/surgery_step/S in steps_to_try)
		//check, if target undressed for clothless operations
		if(S.clothless && ishuman(M) && !check_human_covering(M, user, covered))
			return FALSE

		//check if tool is right or close enough and if this step is possible
		if(S.tool_quality(tool) && S.can_use(user, M, target_zone, tool) && S.is_valid_mutantrace(M))
			if(!S.prepare_step(user, M, target_zone, tool))	//for some kind of checks
				return TRUE

			S.begin_step(user, M, target_zone, tool)		//...start on it
			var/step_duration = rand(S.min_duration, S.max_duration)

			//We had proper tools! (or RNG smiled.) and User did not move or change hands.
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(!HAS_TRAIT(H, TRAIT_NO_PAIN) && !HAS_TRAIT(H, TRAIT_IMMOBILIZED))
					H.adjustHalLoss(25)
				if(prob(H.traumatic_shock) && !H.incapacitated(NONE))
					to_chat(user, "<span class='warning'>The patient is writhing in pain, this interferes with the operation!</span>")
					S.fail_step(user, H, target_zone, tool) //patient movements due to pain interfere with surgery
			if(user.mood_prob(S.tool_quality(tool)) && tool.use_tool(M,user, step_duration, volume=100, required_skills_override = S.required_skills, skills_speed_bonus = S.skills_speed_bonus) && user.get_targetzone() && target_zone == user.get_targetzone())
				S.end_step(user, M, target_zone, tool)		//finish successfully
			else if(user.get_active_hand() == tool && user.Adjacent(M))		//or (also check for tool in hands and being near the target)
				S.fail_step(user, M, target_zone, tool)		//malpractice~
			else	// this failing silently was a pain.
				to_chat(user, "<span class='warning'>You must remain close to your patient to conduct surgery.</span>")

			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.update_surgery()
				// When called from manual tool use, kick off the radial chain for the next step.
				// When called from radial, it re-opens itself after the step (via INVOKE_ASYNC).
				if(!from_radial)
					try_show_surgery_radial_menu(user, H, target_zone)
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
	can_infect = FALSE
	allowed_species = list(IPC)
	required_skills = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED, /datum/skill/surgery = SKILL_LEVEL_NOVICE)
	skills_speed_bonus = -0.2
