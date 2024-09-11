/datum/objective/escape
	explanation_text = "Escape on the shuttle or an escape pod alive and free."

/datum/objective/escape/check_completion()
	if(issilicon(owner.current))
		return OBJECTIVE_LOSS
	if(isbrain(owner.current))
		return OBJECTIVE_LOSS
	if(SSshuttle.location<2)
		return OBJECTIVE_LOSS
	if(!owner.current || owner.current.stat ==DEAD)
		return OBJECTIVE_LOSS
	var/turf/location = get_turf(owner.current.loc)
	if(!location)
		return OBJECTIVE_LOSS

	if(iscarbon(owner.current))
		var/mob/living/carbon/C = owner.current
		if(C.restrained())
			return OBJECTIVE_LOSS

	var/area/check_area = location.loc
	if(istype(check_area, /area/shuttle/escape/centcom))
		return OBJECTIVE_WIN
	if(istype(check_area, /area/shuttle/escape_pod1/centcom))
		return OBJECTIVE_WIN
	if(istype(check_area, /area/shuttle/escape_pod2/centcom))
		return OBJECTIVE_WIN
	if(istype(check_area, /area/shuttle/escape_pod3/centcom))
		return OBJECTIVE_WIN
	if(istype(check_area, /area/shuttle/escape_pod4/centcom))
		return OBJECTIVE_WIN
	if(istype(check_area, /area/shuttle/escape_pod5/centcom))
		return OBJECTIVE_WIN
	if(istype(check_area, /area/shuttle/escape_pod6/centcom))
		return OBJECTIVE_WIN
	else
		return OBJECTIVE_LOSS
