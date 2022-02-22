/datum/event/feature/area/mess

/datum/event/feature/area/mess/start()
	for(var/area/target_area in targeted_areas)
		for(var/obj/machinery/door/window/B in target_area)
			new /obj/item/weapon/shard(B.loc)
			qdel(B)

		for(var/obj/structure/closet/C in target_area)
			C.locked = FALSE
			C.welded = FALSE
			C.open()

		for(var/obj/item/toy/cards/cards in target_area)
			cards.remove_card()

		for(var/obj/item/weapon/storage/S in target_area)
			S.make_empty(FALSE)

		for(var/obj/item/ammo_box/AB in target_area)
			AB.make_empty(FALSE)

		for(var/obj/item/I in target_area)
			if(istype(I, /obj/item/device/radio/intercom))
				continue
			for(var/i in 1 to rand(2, 8))
				step(I, pick(alldirs))

		message_admins("RoundStart Event: All items in [target_area] are scattered.")
		log_game("RoundStart Event: All items in [target_area] are scattered.")

/datum/event/feature/area/mess/armory
	special_area_types = list(/area/station/security/warden, /area/station/security/armoury)

/datum/event/feature/area/mess/bridge
	special_area_types = list(/area/station/bridge)

/datum/event/feature/area/mess/med_storage
	special_area_types = list(/area/station/medical/storage, /area/station/medical/chemistry)

