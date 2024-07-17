/datum/objective/bomb
	explanation_text = "Detonate a bomb in one of the following compartments: Captain's office, armory, toxin storage, EVA, telecommunications, atmospherics."
	required_equipment = /obj/item/device/radio/beacon/syndicate_bomb/objective
	global_objective = TRUE
	var/already_completed = FALSE
	var/list/areas_for_objective = list(/area/station/bridge/captain_quarters,
										/area/station/security/armoury,
										/area/station/rnd/storage,
										/area/station/ai_monitored/eva,
										/area/station/tcommsat,
										/area/station/engineering/atmos)

/datum/objective/bomb/New()
	..()
	RegisterSignal(SSexplosions, COMSIG_EXPLOSIONS_EXPLODE, PROC_REF(react))

/datum/objective/bomb/proc/react(datum/source, turf/epicenter, devastation_range, heavy_impact_range, light_impact_range)
	var/area/A = get_area(epicenter)
	for(var/area in areas_for_objective)
		if(istype(A, area) && devastation_range >= 1)
			already_completed = TRUE
	UnregisterSignal(SSexplosions, COMSIG_EXPLOSIONS_EXPLODE)

/datum/objective/bomb/check_completion()
	if(!already_completed)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/obj/item/device/radio/beacon/syndicate_bomb/objective
	bomb_type = /obj/machinery/syndicatebomb/objective

/obj/machinery/syndicatebomb/objective
	min_timer = 120
	timer = 120
