/datum/event/feature/area/replace/del_surgeon_tools
	special_area_types = list(/area/station/medical/surgery2, /area/station/medical/surgery)
	replace_types = list(/obj/item = null)

/datum/event/feature/area/replace/del_surgeon_tools/setup()
	. = ..()
	num_replaceable = rand(3, 8)
