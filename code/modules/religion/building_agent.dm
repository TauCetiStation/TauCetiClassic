
// A small class that makes it easier to create possible buildings for the construction of religious buildings
/datum/building_agent
	var/name
	var/building_type
	var/favor_cost
	var/piety_cost
	// TODO: Replace Pylon on Pedestal

// For cultists
/datum/building_agent/cult

/datum/building_agent/cult/wall
	name = "Wall"
	building_type = /turf/simulated/wall/cult
	favor_cost = 0
	piety_cost = 0

/datum/building_agent/cult/floor
	name = "Floor"
	building_type = /turf/simulated/floor/engine/cult
	favor_cost = 0
	piety_cost = 0

/datum/building_agent/cult/altar
	name = "Altar"
	building_type = /obj/structure/altar_of_gods/cult
	favor_cost = 0
	piety_cost = 0

/datum/building_agent/cult/pylon
	name = "Pylon"
	building_type = /obj/structure/cult/pylon
	favor_cost = 0
	piety_cost = 0

