/datum/event/roundstart/area/replace/med_storage
	special_area_types = list(/area/station/medical/storage)

/datum/event/roundstart/area/replace/med_storage/setup()
	. = ..()
	random_replaceable_types = typesof(/obj/item/weapon/storage/firstaid)

	replace_types[find_replaceable_type()] = /obj/item/weapon/reagent_containers/syringe/inaprovaline
