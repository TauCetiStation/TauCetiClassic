/datum/event/feature/area/replace/mice_attack
	special_area_types = list(/area/station/civilian/cold_room)
	replace_types = list(
		/obj/item/weapon/reagent_containers/food = null,
		/obj/machinery/door/window = /obj/item/weapon/shard,
		/obj/structure/window/thin = /obj/item/weapon/shard,
	)

/datum/event/feature/area/replace/mice_attack/start()
	..()
	var/list/mice = typesof(/mob/living/simple_animal/mouse) - /mob/living/simple_animal/mouse/brown/Tom
	for(var/area/target_area in targeted_areas)
		message_admins("RoundStart Event: Change [target_area]")
		log_game("RoundStart Event: Change [target_area]")
		var/list/all_atoms = target_area.GetAreaAllContents()
		for(var/A in all_atoms)
			if(!prob(30))
				continue
			var/atom/atom = A
			var/mouse_type = pick(mice)
			var/mob/living/simple_animal/mouse/M = new mouse_type(atom.loc)
			M.death()

