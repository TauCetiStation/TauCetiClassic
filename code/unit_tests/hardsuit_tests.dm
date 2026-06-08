/datum/unit_test/hardsuit_test_helmet
	name = "HARDSUIT: TEST SPAWN HELMET"

/datum/unit_test/hardsuit_test_helmet/start_test()
	var/list/error_list = list()
	for(var/obj/item/clothing/suit/space/rig/typepath as anything in typesof(/obj/item/clothing/suit/space/rig))
		var/obj/item/clothing/suit/space/rig/hardsuit = new typepath.type
		if(!hardsuit.helmet)
			error_list += hardsuit.name

	if(length(error_list))
		fail("Some RIG`s spawn without helmet!")
		for(var/target in error_list)
			fail("[target]: spawn without helmet!")
			return FALSE

	pass("All RIG`s spawn currectly!")
	return TRUE

