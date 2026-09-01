/datum/unit_test/storage_transfer_rollback
	name = "STORAGE: rejected bulk insertion restores source bookkeeping"

/datum/unit_test/storage_transfer_rollback/start_test()
	var/turf/test_turf = locate(1, 1, 1)
	var/obj/item/weapon/storage/wallet/source_storage = new(test_turf)
	var/obj/item/weapon/storage/box/target_storage = new(test_turf)
	var/obj/item/weapon/card/id/item = new(test_turf)

	if(!source_storage.try_insert(item, null, prevent_warning = TRUE, NoUpdate = TRUE) || source_storage.front_id != item)
		fail("The wallet test fixture failed to register its front ID.")
		qdel(source_storage)
		qdel(target_storage)
		return FALSE
	RegisterSignal(target_storage, COMSIG_STORAGE_ENTERED, PROC_REF(block_insertion))
	var/inserted = target_storage.transfer_item_from(source_storage, item, null, NoUpdate = TRUE)
	UnregisterSignal(target_storage, COMSIG_STORAGE_ENTERED)

	if(inserted || item.loc != source_storage || source_storage.front_id != item)
		fail("A rejected item did not restore the wallet's location and front ID.")
		qdel(source_storage)
		qdel(target_storage)
		return FALSE

	pass("Rejected insertion restores the item and its wallet bookkeeping.")
	qdel(source_storage)
	qdel(target_storage)
	return TRUE

/datum/unit_test/storage_transfer_rollback/proc/block_insertion(datum/source, obj/item/item, prevent_warning, NoUpdate)
	return COMSIG_STORAGE_PROHIBIT

/datum/unit_test/storage_bag_of_holding_safety
	name = "STORAGE: bulk insertion preserves bag of holding safety"

/datum/unit_test/storage_bag_of_holding_safety/start_test()
	var/turf/test_turf = locate(1, 1, 1)
	var/obj/item/weapon/storage/box/source_storage = new(test_turf)
	var/obj/item/weapon/storage/backpack/holding/target_storage = new(test_turf)
	var/obj/item/weapon/storage/backpack/holding/item = new(source_storage)

	var/inserted = target_storage.transfer_item_from(source_storage, item, null, NoUpdate = TRUE)
	if(inserted || !QDELETED(item))
		fail("Bulk insertion bypassed the bag of holding conflict.")
		qdel(source_storage)
		qdel(target_storage)
		return FALSE

	pass("Conflicting bags of holding are rejected through the bulk path.")
	qdel(source_storage)
	qdel(target_storage)
	return TRUE

/datum/unit_test/storage_matchbox_rejects_lit_matches
	name = "STORAGE: bulk insertion rejects lit matches"

/datum/unit_test/storage_matchbox_rejects_lit_matches/start_test()
	var/turf/test_turf = locate(1, 1, 1)
	var/obj/item/weapon/storage/box/source_storage = new(test_turf)
	var/obj/item/weapon/storage/box/matches/target_storage = new(test_turf)
	target_storage.storage_slots = 20
	target_storage.max_storage_space = 100
	var/obj/item/weapon/match/item = new(source_storage)
	item.lit = TRUE

	if(target_storage.transfer_item_from(source_storage, item, null, NoUpdate = TRUE) || item.loc != source_storage)
		fail("Bulk insertion accepted a lit match or failed to restore it.")
		qdel(source_storage)
		qdel(target_storage)
		return FALSE

	pass("Lit matches cannot enter a matchbox through bulk insertion.")
	qdel(source_storage)
	qdel(target_storage)
	return TRUE

/datum/unit_test/storage_furioso_unique_types
	name = "STORAGE: bulk insertion preserves Furioso type uniqueness"

/datum/unit_test/storage_furioso_unique_types/start_test()
	var/turf/test_turf = locate(1, 1, 1)
	var/obj/item/weapon/storage/box/source_storage = new(test_turf)
	var/obj/item/clothing/gloves/black/silence/furioso/master_item = new(test_turf)
	var/obj/item/weapon/storage/internal/furioso/target_storage = master_item.pockets
	var/obj/item/weapon/melee/classic_baton/stored_item = new(test_turf)
	var/obj/item/weapon/melee/classic_baton/item = new(source_storage)

	if(!target_storage.try_insert(stored_item, null, prevent_warning = TRUE, NoUpdate = TRUE))
		fail("The Furioso storage rejected its first item type.")
		qdel(source_storage)
		qdel(master_item)
		return FALSE
	if(target_storage.transfer_item_from(source_storage, item, null, NoUpdate = TRUE) || item.loc != source_storage)
		fail("Bulk insertion bypassed Furioso's duplicate-type restriction.")
		qdel(source_storage)
		qdel(master_item)
		return FALSE

	pass("Furioso rejects duplicate item types through bulk insertion.")
	qdel(source_storage)
	qdel(master_item)
	return TRUE

/datum/unit_test/storage_sheetsnatcher_matching_stack
	name = "STORAGE: sheet snatcher restores a matching-stack remainder"

/datum/unit_test/storage_sheetsnatcher_matching_stack/start_test()
	var/turf/test_turf = locate(1, 1, 1)
	var/obj/item/weapon/storage/box/source_storage = new(test_turf)
	var/obj/item/weapon/storage/bag/sheetsnatcher/target_storage = new(test_turf)
	var/obj/item/stack/sheet/metal/stored_stack = new(target_storage, 290)
	var/obj/item/stack/sheet/metal/item = new(source_storage, 50)

	if(!target_storage.transfer_item_from(source_storage, item, null, NoUpdate = TRUE))
		fail("The sheet snatcher rejected a stack that had room for a partial transfer.")
		qdel(source_storage)
		qdel(target_storage)
		return FALSE
	if(stored_stack.get_amount() != 300 || item.get_amount() != 40 || item.loc != source_storage)
		fail("The matching-stack remainder was not restored to its source storage.")
		qdel(source_storage)
		qdel(target_storage)
		return FALSE

	pass("A matching sheet stack fills the snatcher and leaves its remainder in the source.")
	qdel(source_storage)
	qdel(target_storage)
	return TRUE

/datum/unit_test/storage_sheetsnatcher_new_stack
	name = "STORAGE: sheet snatcher splits a new stack at capacity"

/datum/unit_test/storage_sheetsnatcher_new_stack/start_test()
	var/turf/test_turf = locate(1, 1, 1)
	var/obj/item/weapon/storage/box/source_storage = new(test_turf)
	var/obj/item/weapon/storage/bag/sheetsnatcher/target_storage = new(test_turf)
	new /obj/item/stack/sheet/glass(target_storage, 290)
	var/obj/item/stack/sheet/metal/item = new(source_storage, 50)

	if(!target_storage.transfer_item_from(source_storage, item, null, NoUpdate = TRUE))
		fail("The sheet snatcher rejected a new sheet type that had room for a partial transfer.")
		qdel(source_storage)
		qdel(target_storage)
		return FALSE

	var/obj/item/stack/sheet/metal/inserted_stack
	for(var/obj/item/stack/sheet/metal/candidate in target_storage)
		inserted_stack = candidate
		break
	if(!inserted_stack || inserted_stack.get_amount() != 10 || item.get_amount() != 40 || item.loc != source_storage)
		fail("The new sheet type was not split between the target and source storages.")
		qdel(source_storage)
		qdel(target_storage)
		return FALSE

	pass("A new sheet type fills the remaining capacity and leaves its remainder in the source.")
	qdel(source_storage)
	qdel(target_storage)
	return TRUE

/datum/unit_test/storage_try_open_check_only
	name = "STORAGE: try_open check_only has no UI side effects"

/datum/unit_test/storage_try_open_check_only/start_test()
	var/turf/test_turf = locate(1, 1, 1)
	var/mob/user = new(test_turf)
	var/obj/item/weapon/storage/box/open_storage = new(test_turf)
	var/obj/item/weapon/storage/lockbox/lockbox = new(test_turf)
	var/obj/item/weapon/storage/secure/secure_storage = new(test_turf)

	if(!open_storage.try_open(user, check_only = TRUE) || open_storage.storage_ui)
		fail("The base check-only path either failed or opened the storage UI.")
		qdel(user)
		qdel(open_storage)
		qdel(lockbox)
		qdel(secure_storage)
		return FALSE
	if(lockbox.try_open(user, check_only = TRUE))
		fail("A locked lockbox passed the check-only access test.")
		qdel(user)
		qdel(open_storage)
		qdel(lockbox)
		qdel(secure_storage)
		return FALSE

	lockbox.locked = FALSE
	if(!lockbox.try_open(user, check_only = TRUE) || lockbox.storage_ui)
		fail("An unlocked lockbox failed check-only access or opened its UI.")
		qdel(user)
		qdel(open_storage)
		qdel(lockbox)
		qdel(secure_storage)
		return FALSE
	if(secure_storage.try_open(user) || secure_storage.storage_ui)
		fail("A locked secure storage opened its UI before reporting failure.")
		qdel(user)
		qdel(open_storage)
		qdel(lockbox)
		qdel(secure_storage)
		return FALSE

	pass("Check-only access validates storage state without opening a UI.")
	qdel(user)
	qdel(open_storage)
	qdel(lockbox)
	qdel(secure_storage)
	return TRUE
