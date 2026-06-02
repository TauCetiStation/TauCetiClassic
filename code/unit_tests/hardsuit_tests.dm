/datum/unit_test/hardsuit_test_helmet
	name = "HARDSUIT: TEST SPAWN HELMET"

/datum/unit_test/hardsuit_test_helmet/start_test()
	var/list/error_list = list()
	for(var/obj/item/clothing/suit/space/rig/typepath as anything in typesof(/obj/item/clothing/suit/space/rig))
		var/obj/item/clothing/suit/space/rig/rig = new typepath.type
		if(!rig.helmet)
			error_list += rig::name

	if(length(error_list))
		fail("Some RIG`s spawn without helmet!")
		for(var/target in error_list)
			fail("[target]: spawn without helmet!")
			return FALSE
	else
		pass("All RIG`s spawn currectly!")
		return TRUE

