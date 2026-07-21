#ifdef UNIT_TEST

/obj/item/surgery_radial_test_tool
	name = "surgery radial test tool"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"

/obj/item/surgery_radial_test_tool/immobilizing_pickup/pickup(mob/user)
	. = ..()
	if(.)
		ADD_TRAIT(user, TRAIT_IMMOBILIZED, "surgery_radial_test")

/obj/item/surgery_radial_test_tool/moving_storage_drop
	var/atom/movable/storage_to_move
	var/turf/storage_move_target

/obj/item/surgery_radial_test_tool/moving_storage_drop/dropped(mob/user)
	. = ..()
	if(storage_to_move && storage_move_target)
		storage_to_move.forceMove(storage_move_target)

/mob/living/carbon/human/surgery_radial_test/get_targetzone()
	return BP_CHEST

/datum/surgery_step/surgery_radial_test
	name = "surgery radial test template"
	allowed_species = null
	clothless = FALSE
	min_duration = 0
	max_duration = 0
	allowed_tools = list(/obj/item/surgery_radial_test_tool = 100)
	var/executions = 0

/datum/surgery_step/surgery_radial_test/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, silent = FALSE)
	return TRUE

/datum/surgery_step/surgery_radial_test/high
	name = "High priority surgery test"
	priority = 10

/datum/surgery_step/surgery_radial_test/high/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	executions++

/datum/surgery_step/surgery_radial_test/low
	name = "Low priority surgery test"
	priority = -10

/datum/surgery_step/surgery_radial_test/low/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	executions++

/datum/unit_test/surgery_radial_selected_step
	name = "SURGERY RADIAL: selected step overrides surgery priority."

/datum/unit_test/surgery_radial_selected_step/start_test()
	var/datum/surgery_step/surgery_radial_test/high/high_step = locate(/datum/surgery_step/surgery_radial_test/high) in surgery_steps
	var/datum/surgery_step/surgery_radial_test/low/low_step = locate(/datum/surgery_step/surgery_radial_test/low) in surgery_steps
	if(!high_step || !low_step)
		fail("Test surgery steps were not initialized.")
		return TRUE

	var/turf/test_turf = locate(1, 1, 1)
	var/mob/living/carbon/human/surgery_radial_test/user = new(test_turf)
	var/mob/living/carbon/human/surgery_radial_test/target = new(test_turf)
	var/obj/item/surgery_radial_test_tool/tool = new(user)
	user.put_in_active_hand(tool)
	high_step.executions = 0
	low_step.executions = 0

	var/old_lowpop = SSticker.is_lowpop
	SSticker.is_lowpop = TRUE
	var/result = do_surgery(target, user, tool, from_radial = TRUE, forced_zone = BP_CHEST, selected_step = low_step)
	SSticker.is_lowpop = old_lowpop

	if(!result || low_step.executions != 1 || high_step.executions)
		fail("Selected low-priority step did not execute exclusively.")
	else
		pass("Selected low-priority step executed without falling back to the priority list.")

	qdel(user)
	qdel(target)
	return TRUE

/datum/unit_test/surgery_radial_duplicate_labels
	name = "SURGERY RADIAL: duplicate labels preserve distinct steps."

/datum/unit_test/surgery_radial_duplicate_labels/start_test()
	var/datum/surgery_step/first_step = new
	var/datum/surgery_step/second_step = new
	var/obj/item/surgery_radial_test_tool/tool = new
	first_step.name = "Duplicate surgery step"
	second_step.name = "Duplicate surgery step"

	var/list/best_for_step = list()
	best_for_step[first_step] = tool
	best_for_step[second_step] = tool
	var/list/choice_to_step = list()
	var/list/choice_to_tool_loc = list()
	var/list/choice_to_tool_parent_loc = list()
	var/list/choices = build_surgery_radial_choices(best_for_step, choice_to_step, choice_to_tool_loc, choice_to_tool_parent_loc)

	if(choices.len != 2 || choice_to_step["Duplicate surgery step"] != first_step || choice_to_step["Duplicate surgery step (2)"] != second_step)
		fail("Duplicate labels overwrote a surgery step.")
	else
		pass("Duplicate labels map to two distinct surgery steps.")

	qdel(first_step)
	qdel(second_step)
	qdel(tool)
	return TRUE

/datum/unit_test/surgery_radial_step_names
	name = "SURGERY RADIAL: selectable steps have explicit names."

/datum/unit_test/surgery_radial_step_names/start_test()
	var/list/unnamed_steps = list()
	for(var/datum/surgery_step/S in surgery_steps)
		if(S.allowed_tools && S.allowed_tools.len && S.name == "surgery step")
			unnamed_steps += S.type

	if(unnamed_steps.len)
		fail("Selectable steps still use the default name: [jointext(unnamed_steps, ", ")].")
	else
		pass("Every selectable surgery step has an explicit name.")
	return TRUE

/datum/unit_test/surgery_radial_nodrop
	name = "SURGERY RADIAL: full hands respect NODROP."

/datum/unit_test/surgery_radial_nodrop/start_test()
	var/turf/test_turf = locate(1, 1, 1)
	var/mob/living/carbon/human/surgery_radial_test/user = new(test_turf)
	var/obj/item/left_item = new(user)
	var/obj/item/right_item = new(user)
	var/obj/item/surgery_radial_test_tool/chosen = new(test_turf)
	left_item.flags |= NODROP
	right_item.flags |= NODROP
	user.put_in_l_hand(left_item)
	user.put_in_r_hand(right_item)

	var/list/tool_state = prepare_surgery_tool(user, chosen, test_turf, null)
	if(tool_state || user.l_hand != left_item || user.r_hand != right_item || chosen.loc != test_turf)
		fail("Preparing a radial tool bypassed NODROP or changed inventory.")
	else
		pass("Tool acquisition aborted without changing either hand.")

	qdel(user)
	qdel(chosen)
	return TRUE

/datum/unit_test/surgery_radial_moved_tool
	name = "SURGERY RADIAL: moved tools are rejected without stealing."

/datum/unit_test/surgery_radial_moved_tool/start_test()
	var/turf/test_turf = locate(1, 1, 1)
	var/mob/living/carbon/human/surgery_radial_test/user = new(test_turf)
	var/mob/living/carbon/human/surgery_radial_test/other = new(test_turf)
	var/obj/item/surgery_radial_test_tool/chosen = new(test_turf)
	var/atom/original_loc = chosen.loc
	chosen.mob_pickup(other, other.hand)

	if(other.get_active_hand() != chosen)
		fail("Test setup could not give the tool to the second mob.")
	else if(is_surgery_tool_source_valid(user, chosen, original_loc, null))
		fail("A tool moved into another mob's hand was accepted.")
	else if(other.get_active_hand() != chosen || chosen.loc != other)
		fail("Source validation changed the second mob's inventory.")
	else
		pass("Moved tool was rejected without changing its new owner.")

	qdel(user)
	qdel(other)
	return TRUE

/datum/unit_test/surgery_radial_failed_pickup_restore
	name = "SURGERY RADIAL: failed pickup restores storage contents."

/datum/unit_test/surgery_radial_failed_pickup_restore/start_test()
	var/turf/test_turf = locate(1, 1, 1)
	var/mob/living/carbon/human/surgery_radial_test/user = new(test_turf)
	var/obj/item/weapon/storage/backpack/storage = new(test_turf)
	var/obj/item/surgery_radial_test_tool/immobilizing_pickup/chosen = new(storage)

	var/list/tool_state = prepare_surgery_tool(user, chosen, storage, test_turf)
	REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, "surgery_radial_test")
	if(tool_state || chosen.loc != storage || user.l_hand == chosen || user.r_hand == chosen)
		fail("A tool removed before a failed hand equip was not restored to its storage.")
	else
		pass("Failed pickup restored the tool to its unchanged storage.")

	qdel(user)
	qdel(storage)
	return TRUE

/datum/unit_test/surgery_radial_storage_return_recheck
	name = "SURGERY RADIAL: storage return rechecks the destination after dropping."

/datum/unit_test/surgery_radial_storage_return_recheck/start_test()
	var/turf/test_turf = locate(1, 1, 1)
	var/turf/moved_turf = get_step(test_turf, EAST)
	var/mob/living/carbon/human/surgery_radial_test/user = new(test_turf)
	var/obj/item/weapon/storage/backpack/storage = new(test_turf)
	var/obj/item/surgery_radial_test_tool/moving_storage_drop/chosen = new(storage)
	chosen.storage_to_move = storage
	chosen.storage_move_target = moved_turf

	var/list/tool_state = prepare_surgery_tool(user, chosen, storage, test_turf)
	if(!tool_state)
		fail("Test setup could not pick up the storage tool.")
	else
		restore_surgery_tool(user, chosen, tool_state)
		if(storage.loc != moved_turf || chosen.loc != test_turf)
			fail("The tool was inserted after its original storage moved during the drop.")
		else
			pass("A moved storage was rejected after the tool drop.")

	qdel(user)
	qdel(chosen)
	qdel(storage)
	return TRUE

/datum/unit_test/surgery_radial_borg_items
	name = "SURGERY RADIAL: borg scan uses active carriers and gripper payloads."

/datum/unit_test/surgery_radial_borg_items/start_test()
	var/turf/test_turf = locate(1, 1, 1)
	var/mob/living/silicon/robot/R = new(test_turf)
	var/obj/item/weapon/reagent_containers/glass/beaker/direct_tool = new(R)
	var/obj/item/weapon/gripper/medical/gripper = new(R)
	var/obj/item/weapon/reagent_containers/glass/beaker/payload = new(gripper)
	var/obj/item/weapon/reagent_containers/dropper/inactive_tool = new(R)
	gripper.wrap(payload)
	R.module_state_1 = direct_tool
	R.module_state_2 = gripper

	var/list/robot_slots = list()
	var/list/robot_carriers = list()
	var/list/items = get_surgery_environment_items(R, robot_slots, robot_carriers)
	if(!(direct_tool in items) || !(payload in items) || (gripper in items) || (inactive_tool in items))
		fail("Borg environment did not reflect active tools and the wrapped payload.")
	else if(robot_slots[direct_tool] != 1 || robot_slots[payload] != 2 || robot_carriers[payload] != gripper)
		fail("Borg tool source metadata was not preserved.")
	else
		pass("Only active carriers and the wrapped payload were exposed.")

	qdel(R)
	return TRUE

#endif
