/datum/unit_test/crawling_monkey_table_layer
	name = "TABLE: TEST CRAWLING MONKEY LAYER"

/datum/unit_test/crawling_monkey_table_layer/start_test()
	var/obj/structure/table/table = new
	var/mob/living/carbon/monkey/monkey = new

	if(!monkey.checkpass(PASSTABLE))
		fail("Monkey does not have PASSTABLE by default.")
		qdel(monkey)
		qdel(table)
		return FALSE

	monkey.SetCrawling(TRUE)

	if(!monkey.checkpass(PASSCRAWL))
		fail("Monkey does not have PASSCRAWL after SetCrawling(TRUE).")
		qdel(monkey)
		qdel(table)
		return FALSE

	var/initial_layer = monkey.layer

	if(!table.CanPass(monkey, null))
		fail("Crawling monkey cannot pass table.")
		qdel(monkey)
		qdel(table)
		return FALSE

	if(monkey.layer != initial_layer)
		fail("CanPass changed crawling monkey layer to [monkey.layer], expected [initial_layer].")
		qdel(monkey)
		qdel(table)
		return FALSE

	table.Crossed(monkey)

	if(monkey.layer != BELOW_CONTAINERS_LAYER)
		fail("Crawling monkey layer is [monkey.layer], expected [BELOW_CONTAINERS_LAYER] under table.")
		qdel(monkey)
		qdel(table)
		return FALSE

	if(!table.CheckExit(monkey, null))
		fail("Crawling monkey cannot exit table.")
		qdel(monkey)
		qdel(table)
		return FALSE

	if(monkey.layer != BELOW_CONTAINERS_LAYER)
		fail("CheckExit changed crawling monkey layer to [monkey.layer], expected [BELOW_CONTAINERS_LAYER].")
		qdel(monkey)
		qdel(table)
		return FALSE

	table.Uncrossed(monkey)

	if(monkey.layer != MOB_LAYER)
		fail("Crawling monkey layer is [monkey.layer], expected [MOB_LAYER] after leaving table.")
		qdel(monkey)
		qdel(table)
		return FALSE

	qdel(monkey)
	qdel(table)
	pass("Crawling monkeys change table layer only after crossing state changes.")
	return TRUE
