/datum/unit_test/suit_storage_unit_test_full
	name = "SUIT STORAGE: TEST ALL FULL"

/datum/unit_test/suit_storage_unit_test_full/start_test()
	var/list/error_list = list()
	for(var/obj/machinery/suit_storage_unit/typepath as anything in typesof(/obj/machinery/suit_storage_unit))
		var/obj/machinery/suit_storage_unit/test_unit/ssu = new typepath.type
		ssu.filled = TRUE
		ssu.make_full()
		if(!length(ssu.contents))
			error_list += ssu.name
	if(length(error_list))
		fail("Total SSU errors: [length(error_list)]")
		for(var/target in error_list)
			fail("[target]: didn`t make themself full wtf")
			return FALSE
	else
		pass("SSU successfully make full themself")
		return TRUE

/datum/unit_test/suit_storage_unit_test_dell
	name = "SUIT STORAGE: TEST ANY UNIT CAN DELETE"

/datum/unit_test/suit_storage_unit_test_dell/start_test()
	var/error_list = list()

	for(var/obj/machinery/suit_storage_unit/typepath as anything in typesof(/obj/machinery/suit_storage_unit))
		var/obj/machinery/suit_storage_unit/test_unit/ssu = new typepath.type
		HardDelete(ssu)
		if(ssu)
			error_list += ssu

	if(length(error_list))
		fail("TEST ANY UNIT CAN DELETE: TOTAL ERRORS [length(error_list)]")
		for(var/target in error_list)
			fail("[target]: didn`t Destroy() themself")
		return FALSE
	else
		pass("All units successfuly Destroy() themself")
		return TRUE

/datum/unit_test/suit_storage_unit_test_duv
	name = "SUIT STORAGE: TEST DEFAULT UV CLEAR"

/datum/unit_test/suit_storage_unit_test_duv/start_test()
	var/obj/machinery/suit_storage_unit/test_unit/ssu = new
	ssu.filled = TRUE
	ssu.make_full()
	for(var/obj/item/target in ssu.contents)
		target.contaminate()
		target.add_dirt_cover()

	ssu.default_ultra_violet_cleaning()

	for(var/obj/item/target in ssu.contents)
		if(target.contaminated)
			fail("SSU didn`t clear contaminate: [target]")
			return FALSE
		else if(target.blood_overlay)
			fail("SSU didn` clear blood_overlay: [target]")
			return FALSE
		else
			pass("SSU successfuly clear: [target]")
			return TRUE

/datum/unit_test/suit_storage_unit_test_suv_dell
	name = "SUIT STORAGE: TEST SUPER UV CLEAR"

/datum/unit_test/suit_storage_unit_test_suv_dell/start_test()
	var/obj/machinery/suit_storage_unit/test_unit/ssu = new
	ssu.emagged = TRUE

// Test unit have alredy contents insade, give them human to check kill it
	new /mob/living/carbon/human (ssu)

	ssu.super_ultra_violet_cleaning()
	if(length(ssu.contents))
		fail("SSU didnt destroy all in contents")
		return FALSE
	else
		pass("SSU successfully destroy all in contents")
		return TRUE

/datum/unit_test/suit_storage_unit_test_fast_equip_drop
	name = "SUIT STORAGE: TEST FAST EUIP"

/datum/unit_test/suit_storage_unit_test_fast_equip_drop/start_test()
	var/obj/machinery/suit_storage_unit/test_unit/ssu = new
	var/mob/living/carbon/human/H = new (ssu)

	if(!ssu.fast_equip(H))
		for(var/obj/item/something in ssu.contents)
			ssu.dispense(something)

	for(var/atom/target in ssu.contents)
		if(!ishuman(target))
			fail("SSU contents somethink like: [target], but must didn`t")
			return FALSE

	pass("SSU successfully use items in his contents")
	return TRUE
