/datum/unit_test/table_parts_cannot_build_on_existing_table
	name = "TABLES: Table parts cannot build on an existing table."

/datum/unit_test/table_parts_cannot_build_on_existing_table/start_test()
	var/turf/T
	for(var/turf/simulated/floor/floor in world)
		if(locate(/obj/structure/table) in floor)
			continue
		T = floor
		break

	if(!T)
		fail("Could not find a simulated floor turf without a table for testing.")
		return FALSE

	var/obj/structure/table/existing_table = new(T)
	var/mob/living/carbon/human/user = new(T)
	var/obj/item/weapon/table_parts/parts = new(T)

	if(parts.can_place(get_turf(user)))
		fail("Table parts can be placed on a turf that already contains a table.")
		qdel(parts)
		qdel(user)
		qdel(existing_table)
		return FALSE

	if(existing_table.loc != T)
		fail("Existing table was moved or deleted while checking table parts placement.")
		qdel(parts)
		qdel(user)
		qdel(existing_table)
		return FALSE

	qdel(parts)
	qdel(user)
	qdel(existing_table)

	pass("Table parts cannot be placed on an existing table.")
	return TRUE
