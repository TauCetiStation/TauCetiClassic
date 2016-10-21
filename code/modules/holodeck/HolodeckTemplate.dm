#define HOLO_SIZE_X 10
#define HOLO_SIZE_Y 10

/datum/map_template/holoscene
	var/holoscene_id
	var/list/holo_objs = list()
	var/list/holo_mobs = list()
	var/special_atmo = FALSE
	var/restricted = FALSE

/datum/map_template/holoscene/proc/id()
	if(holoscene_id)
		return holoscene_id
	else
		return null

/datum/map_template/holoscene/proc/set_air_change(turf/simulated/T, datum/gas_mixture/env)
	var/turf/simulated/TT
	if(!special_atmo)
		for(var/i = 0 to HOLO_SIZE_X - 1)
			for(var/j = 0 to HOLO_SIZE_Y - 1)
				TT = locate(T.x + i, T.y + j, T.z)
				var/datum/gas_mixture/mixt = TT.return_air()
				if(mixt)
					mixt.copy_from(env)

/datum/map_template/holoscene/turnoff
	name = "Empty"
	holoscene_id = "turnoff"
	mappath = "maps/templates/holodeck/turnoff.dmm"

/datum/map_template/holoscene/basketball
	name = "Basketball Court"
	holoscene_id = "basketball"
	mappath = "maps/templates/holodeck/basketball.dmm"

/datum/map_template/holoscene/beach
	name = "Beach"
	holoscene_id = "beach"
	mappath = "maps/templates/holodeck/beach.dmm"

/datum/map_template/holoscene/boxingcourt
	name = "Boxing Ring"
	holoscene_id = "boxingcourt"
	mappath = "maps/templates/holodeck/boxingcourt.dmm"

/datum/map_template/holoscene/burntest
	name = "Atmospheric Burn Simulation"
	holoscene_id = "burntest"
	mappath = "maps/templates/holodeck/burntest.dmm"
	special_atmo = TRUE
	restricted = TRUE

/datum/map_template/holoscene/courtroom
	name = "Courtroom"
	holoscene_id = "courtroom"
	mappath = "maps/templates/holodeck/courtroom.dmm"

/datum/map_template/holoscene/desert
	name = "Desert"
	holoscene_id = "desert"
	mappath = "maps/templates/holodeck/desert.dmm"

/datum/map_template/holoscene/emptycourt
	name = "Empty Court"
	holoscene_id = "emptycourt"
	mappath = "maps/templates/holodeck/emptycourt.dmm"

/datum/map_template/holoscene/meetinghall
	name = "Meeting Hall"
	holoscene_id = "meetinghall"
	mappath = "maps/templates/holodeck/meetinghall.dmm"

/datum/map_template/holoscene/picnicarea
	name = "Picnic Area"
	holoscene_id = "picnicarea"
	mappath = "maps/templates/holodeck/picnicarea.dmm"

/datum/map_template/holoscene/snowfield
	name = "Snow Field"
	holoscene_id = "snowfield"
	mappath = "maps/templates/holodeck/snowfield.dmm"

/datum/map_template/holoscene/space
	name = "Space"
	holoscene_id = "space"
	mappath = "maps/templates/holodeck/space.dmm"

/datum/map_template/holoscene/theatre
	name = "Theatre"
	holoscene_id = "theatre"
	mappath = "maps/templates/holodeck/theatre.dmm"

/datum/map_template/holoscene/thunderdomecourt
	name = "Thunderdome Court"
	holoscene_id = "thunderdomecourt"
	mappath = "maps/templates/holodeck/thunderdomecourt.dmm"

/datum/map_template/holoscene/wildlifecarp
	name = "Wildlife Simulation"
	holoscene_id = "wildlifecarp"
	mappath = "maps/templates/holodeck/wildlifecarp.dmm"
	restricted = TRUE
