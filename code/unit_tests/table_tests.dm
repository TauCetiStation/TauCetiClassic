/datum/unit_test/crawling_monkey_table_top_movement
	name = "TABLE: TEST CRAWLING MONKEY TABLE TOP MOVEMENT"

/datum/unit_test/crawling_monkey_table_top_movement/proc/cleanup(list/atoms)
	for(var/atom/movable/A as anything in atoms)
		qdel(A)

/datum/unit_test/crawling_monkey_table_top_movement/proc/fail_with_cleanup(message, list/atoms)
	fail(message)
	cleanup(atoms)
	return FALSE

/datum/unit_test/crawling_monkey_table_top_movement/start_test()
	var/turf/first_table_turf = locate(1, 1, 1)
	var/turf/second_table_turf = locate(2, 1, 1)

	if(!first_table_turf || !second_table_turf)
		fail("Unable to locate table movement test turfs.")
		return FALSE

	first_table_turf = first_table_turf.ChangeTurf(/turf/simulated/floor/plating/airless)
	second_table_turf = second_table_turf.ChangeTurf(/turf/simulated/floor/plating/airless)

	var/obj/structure/table/first_table = new(first_table_turf)
	var/obj/structure/table/second_table = new(second_table_turf)
	var/mob/living/carbon/monkey/monkey = new(first_table_turf)
	var/list/created_atoms = list(first_table, second_table, monkey)

	monkey.SetCrawling(TRUE)
	monkey.layer = MOB_LAYER

	if(!monkey.Move(second_table_turf, EAST))
		return fail_with_cleanup("Crawling monkey cannot move between tables while on top.", created_atoms)

	if(monkey.layer != MOB_LAYER)
		return fail_with_cleanup("Crawling monkey layer is [monkey.layer], expected [MOB_LAYER] after crawling across table tops.", created_atoms)

	cleanup(created_atoms)
	pass("Crawling monkeys keep the correct layer when crawling across table tops.")
	return TRUE
