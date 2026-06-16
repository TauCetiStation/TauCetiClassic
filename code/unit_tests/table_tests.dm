/datum/unit_test/clickplace_item_offsets
	name = "TABLE: TEST CLICKPLACE ITEM OFFSETS"

/datum/unit_test/clickplace_item_offsets/proc/cleanup(list/things)
	for(var/atom/thing in things)
		qdel(thing)

/datum/unit_test/clickplace_item_offsets/proc/find_test_turfs()
	for(var/turf/candidate in world)
		if(candidate.density)
			continue
		if(locate(/obj/structure/table) in candidate)
			continue
		if(locate(/obj/structure/closet) in candidate)
			continue

		for(var/direction in cardinal)
			var/turf/neighbor = get_step(candidate, direction)
			if(!neighbor || neighbor.density)
				continue
			if(locate(/obj/structure/table) in neighbor)
				continue
			if(locate(/obj/structure/closet) in neighbor)
				continue
			return list(candidate, neighbor)

	return null

/datum/unit_test/clickplace_item_offsets/proc/check_clickplace(atom/place_on, mob/living/carbon/monkey/user, obj/item/item, params, expected_x, expected_y, label)
	user.put_in_hands(item)
	place_on.attackby(item, user, params)

	if(item.loc != place_on.loc)
		fail("[label] clickplace moved item to [item.loc], expected [place_on.loc].")
		return FALSE
	if(user.get_active_hand() == item || user.get_inactive_hand() == item)
		fail("[label] clickplace left item in user's hands.")
		return FALSE
	if(item.pixel_x != expected_x || item.pixel_y != expected_y)
		fail("[label] clickplace offset is [item.pixel_x], [item.pixel_y], expected [expected_x], [expected_y].")
		return FALSE

	return TRUE

/datum/unit_test/clickplace_item_offsets/start_test()
	var/list/test_turfs = find_test_turfs()
	if(!test_turfs)
		fail("Could not find turfs for clickplace offset tests.")
		return FALSE

	var/turf/place_turf = test_turfs[1]
	var/turf/user_turf = test_turfs[2]
	var/list/things_to_cleanup = list()

	var/mob/living/carbon/monkey/user = new(user_turf)
	user.m_intent = MOVE_INTENT_WALK
	things_to_cleanup += user

	var/list/click_params = list(ICON_X = "24", ICON_Y = "8")
	var/params = list2params(click_params)

	var/obj/structure/table/table = new(place_turf)
	var/obj/item/table_item = new(user_turf)
	things_to_cleanup += table
	things_to_cleanup += table_item

	if(!check_clickplace(table, user, table_item, params, 8, -8, "table"))
		cleanup(things_to_cleanup)
		return FALSE

	qdel(table)
	things_to_cleanup -= table

	var/obj/structure/closet/closet = new(place_turf)
	var/obj/item/closet_item = new(user_turf)
	closet.open()
	things_to_cleanup += closet
	things_to_cleanup += closet_item

	if(!check_clickplace(closet, user, closet_item, params, 8, -8, "open closet"))
		cleanup(things_to_cleanup)
		return FALSE

	cleanup(things_to_cleanup)
	pass("Clickplace preserves clicked item offsets when putdown animation is skipped.")
	return TRUE
