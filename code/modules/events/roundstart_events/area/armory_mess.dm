/datum/event/roundstart/area/armory_mess
	special_area_types = list(/area/station/security/warden, /area/station/security/armoury)

/datum/event/roundstart/area/armory_mess/start()
	for(var/area/target_area in targeted_areas)
		for(var/obj/machinery/door/window/brigdoor/B in target_area)
			qdel(B)

		for(var/obj/item/I in target_area)
			for(var/i in 1 to rand(2, 8))
				step(I, pick(alldirs))

	message_admins("RoundStart Event: All items in armory are scattered.")
	log_game("RoundStart Event: All items in armory are scattered.")
