/datum/objective/escape
	explanation_text = "Escape on the shuttle or an escape pod alive and free."

/datum/objective/escape/check_completion()
	if(issilicon(owner.current))
		return OBJECTIVE_LOSS
	if(isbrain(owner.current))
		return OBJECTIVE_LOSS
	if(SSshuttle.location<2)
		return OBJECTIVE_LOSS
	if(!owner.current || owner.current.stat ==2)
		return OBJECTIVE_LOSS
	var/turf/location = get_turf(owner.current.loc)
	if(!location)
		return OBJECTIVE_LOSS

	if(istype(location, /turf/simulated/shuttle/floor4)) // Fails traitors if they are in the shuttle brig -- Polymorph
		if(istype(owner.current, /mob/living/carbon))
			var/mob/living/carbon/C = owner.current
			if (!C.restrained())
				return OBJECTIVE_WIN
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
	else
		return OBJECTIVE_LOSS
