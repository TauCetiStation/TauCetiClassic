/obj/item/table_under_interaction_test_weapon
	name = "table under interaction test weapon"
	force = 5
	var/attacked = FALSE

/obj/item/table_under_interaction_test_weapon/attack(mob/living/M, mob/living/user, def_zone)
	attacked = TRUE
	return TRUE

/obj/item/table_under_interaction_test_target
	name = "table under interaction test target"
	var/attacked_by_called = FALSE

/obj/item/table_under_interaction_test_target/attackby(obj/item/W, mob/user, params)
	attacked_by_called = TRUE
	return TRUE

/datum/unit_test/crawling_under_table_interactions
	name = "TABLE: TEST CRAWLING UNDER TABLE INTERACTION BLOCK"

/datum/unit_test/crawling_under_table_interactions/proc/cleanup(list/things)
	for(var/atom/thing in things)
		qdel(thing)

/datum/unit_test/crawling_under_table_interactions/start_test()
	var/turf/test_turf
	var/turf/adjacent_turf
	var/turf/floor_turf
	for(var/turf/candidate in world)
		if(candidate.density)
			continue
		if(locate(/obj/structure/table) in candidate)
			continue
		var/list/valid_neighbors = list()
		for(var/direction in cardinal)
			var/turf/neighbor = get_step(candidate, direction)
			if(!neighbor || neighbor.density)
				continue
			if(locate(/obj/structure/table) in neighbor)
				continue
			valid_neighbors += neighbor
		if(length(valid_neighbors) < 2)
			continue
		test_turf = candidate
		adjacent_turf = valid_neighbors[1]
		floor_turf = valid_neighbors[2]
		break

	if(!test_turf || !adjacent_turf || !floor_turf)
		fail("Could not find a turf for table interaction tests.")
		return FALSE

	var/list/things_to_cleanup = list()
	var/obj/structure/table/table = new(test_turf)
	var/obj/structure/table/adjacent_table = new(adjacent_turf)
	var/mob/living/carbon/monkey/under_monkey = new(test_turf)
	var/mob/living/carbon/monkey/top_monkey = new(test_turf)
	var/mob/living/carbon/monkey/adjacent_top_monkey = new(adjacent_turf)
	var/mob/living/carbon/monkey/standing_monkey = new(test_turf)
	var/mob/living/carbon/monkey/crawling_no_table_monkey = new(floor_turf)
	var/obj/item/table_under_interaction_test_target/top_item = new(test_turf)
	var/obj/item/table_under_interaction_test_target/adjacent_top_item = new(adjacent_turf)
	var/obj/item/pull_item = new(test_turf)
	var/obj/item/adjacent_pull_item = new(adjacent_turf)
	var/obj/item/floor_item = new(floor_turf)
	var/obj/item/table_under_interaction_test_weapon/attack_weapon = new(test_turf)
	var/obj/item/table_under_interaction_test_weapon/held_weapon = new(test_turf)
	things_to_cleanup += table
	things_to_cleanup += adjacent_table
	things_to_cleanup += under_monkey
	things_to_cleanup += top_monkey
	things_to_cleanup += adjacent_top_monkey
	things_to_cleanup += standing_monkey
	things_to_cleanup += crawling_no_table_monkey
	things_to_cleanup += top_item
	things_to_cleanup += adjacent_top_item
	things_to_cleanup += pull_item
	things_to_cleanup += adjacent_pull_item
	things_to_cleanup += floor_item
	things_to_cleanup += attack_weapon
	things_to_cleanup += held_weapon

	under_monkey.SetCrawling(TRUE)
	crawling_no_table_monkey.SetCrawling(TRUE)
	table.Crossed(under_monkey)

	if(!table_blocks_under_interaction(under_monkey, top_monkey))
		fail("Crawling monkey under table can still interact with a mob on the table.")
		cleanup(things_to_cleanup)
		return FALSE

	if(!table_blocks_under_interaction(under_monkey, top_item))
		fail("Crawling monkey under table can still interact with an item on the table.")
		cleanup(things_to_cleanup)
		return FALSE

	if(!table_blocks_under_interaction(under_monkey, adjacent_top_monkey))
		fail("Crawling monkey under table can still interact with a mob on an adjacent table.")
		cleanup(things_to_cleanup)
		return FALSE

	if(!table_blocks_under_interaction(under_monkey, adjacent_top_item))
		fail("Crawling monkey under table can still interact with an item on an adjacent table.")
		cleanup(things_to_cleanup)
		return FALSE

	if(!table_blocks_under_interaction(under_monkey, table, TRUE))
		fail("Crawling monkey under table can still interact with the table surface.")
		cleanup(things_to_cleanup)
		return FALSE

	if(!table_blocks_under_interaction(under_monkey, adjacent_table, TRUE))
		fail("Crawling monkey under table can still interact with an adjacent table surface.")
		cleanup(things_to_cleanup)
		return FALSE

	if(table_blocks_under_interaction(standing_monkey, top_monkey))
		fail("Standing monkey on the table turf is blocked from normal interactions.")
		cleanup(things_to_cleanup)
		return FALSE

	if(table_blocks_under_interaction(crawling_no_table_monkey, adjacent_top_monkey))
		fail("Crawling monkey without a table on its turf is blocked from normal interactions.")
		cleanup(things_to_cleanup)
		return FALSE

	if(table_blocks_under_interaction(under_monkey, floor_item))
		fail("Crawling monkey under table is blocked from interacting with a nearby target that is not on a table.")
		cleanup(things_to_cleanup)
		return FALSE

	under_monkey.layer = MOB_LAYER
	if(!table_blocks_under_interaction(under_monkey, top_monkey))
		fail("Crawling monkey on the table turf is not treated as under the table when its layer is reset.")
		cleanup(things_to_cleanup)
		return FALSE

	if(top_monkey.can_be_attacked(under_monkey))
		fail("Crawling monkey under table can still start an unarmed attack on a mob on the table.")
		cleanup(things_to_cleanup)
		return FALSE

	if(adjacent_top_monkey.can_be_attacked(under_monkey))
		fail("Crawling monkey under table can still start an unarmed attack on a mob on an adjacent table.")
		cleanup(things_to_cleanup)
		return FALSE

	top_monkey.attackby(attack_weapon, under_monkey, null)
	if(attack_weapon.attacked)
		fail("Crawling monkey under table can still start an armed attack on a mob on the table.")
		cleanup(things_to_cleanup)
		return FALSE

	adjacent_top_monkey.attackby(attack_weapon, under_monkey, null)
	if(attack_weapon.attacked)
		fail("Crawling monkey under table can still start an armed attack on a mob on an adjacent table.")
		cleanup(things_to_cleanup)
		return FALSE

	held_weapon.melee_attack_chain(top_item, under_monkey, null)
	if(top_item.attacked_by_called)
		fail("Crawling monkey under table can still start an item melee chain against an item on the table.")
		cleanup(things_to_cleanup)
		return FALSE

	held_weapon.melee_attack_chain(adjacent_top_item, under_monkey, null)
	if(adjacent_top_item.attacked_by_called)
		fail("Crawling monkey under table can still start an item melee chain against an item on an adjacent table.")
		cleanup(things_to_cleanup)
		return FALSE

	table.Crossed(under_monkey)
	if(under_monkey.CanUseMouseDrop(table, top_item))
		fail("Crawling monkey under table can still drag an item onto the table surface.")
		cleanup(things_to_cleanup)
		return FALSE

	if(under_monkey.CanUseMouseDrop(adjacent_table, adjacent_top_item))
		fail("Crawling monkey under table can still drag an item onto an adjacent table surface.")
		cleanup(things_to_cleanup)
		return FALSE

	pull_item.CtrlClick(under_monkey)
	if(under_monkey.pulling != pull_item)
		fail("CtrlClick pull from under the table was blocked.")
		cleanup(things_to_cleanup)
		return FALSE

	under_monkey.stop_pulling()
	adjacent_pull_item.CtrlClick(under_monkey)
	if(under_monkey.pulling != adjacent_pull_item)
		fail("CtrlClick pull from under the table to an adjacent table was blocked.")
		cleanup(things_to_cleanup)
		return FALSE

	under_monkey.stop_pulling()
	cleanup(things_to_cleanup)
	pass("Crawling under table blocks top-side interactions while preserving CtrlClick pull.")
	return TRUE
