/datum/unit_test/suit_storage_unit_test_full
	name = "SUIT STORAGE: TEST FULL"

/datum/unit_test/suit_storage_unit_test_full/start_test()
	var/obj/machinery/suit_storage_unit/test_unit/ssu = new
	ssu.fulled = TRUE
	ssu.make_full()

	if(!ssu.contents.len)
		fail("SSU didn`t make themself full wtf")
	else
		pass("SSU successfully make full themself")

/datum/unit_test/suit_storage_unit_test_duv
	name = "SUIT STORAGE: TEST DEFAULT UV CLEAR"

/datum/unit_test/suit_storage_unit_test_duv/start_test()
	var/obj/machinery/suit_storage_unit/test_unit/ssu = new
	for(var/obj/item/target in ssu.contents)
		target.contaminate()
		target.add_dirt_cover()

	ssu.default_ultra_violet_cleaning()

	for(var/obj/item/target in ssu.contents)
		if(target.contaminated)
			fail("SSU didn`t clear contaminate: [target]")
		else if(target.blood_overlay)
			fail("SSU didn` clear blood_overlay: [target]")
		else
			pass("SSU successfuly clear: [target]")

/datum/unit_test/suit_storage_unit_test_suv_dell
	name = "SUIT STORAGE: TEST SUPER UV CLEAR"

/datum/unit_test/suit_storage_unit_test_suv_dell/start_test()
	var/obj/machinery/suit_storage_unit/test_unit/ssu = new
	ssu.emagged = TRUE

// Test unit have alredy contents insade, give them human to check kill it
	new /mob/living/carbon/human (ssu)

	ssu.super_ultra_violet_cleaning()
	if(ssu.contents.len)
		fail("SSU didnt destroy all in contents")
	else
		pass("SSU successfully destroy all in contents")

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

	pass("SSU successfully use items in his contents")


