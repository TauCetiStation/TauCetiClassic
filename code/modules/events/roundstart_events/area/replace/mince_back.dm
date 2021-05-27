/datum/event/roundstart/area/replace/mince_back
	special_area_types = list(/area/station/civilian/cold_room, /area/station/civilian/kitchen)
	replace_types = list(/obj/item/weapon/reagent_containers/food/snacks/meat = /mob/living/simple_animal/chick)

/datum/event/roundstart/area/replace/mince_back/setup()
	. = ..()
	new_atom_callback = CALLBACK(src, .proc/make_death)

/datum/event/roundstart/area/replace/mince_back/proc/make_death(mob/M)
	M.death()
