
// A small class that makes it easier to create possible buildings for the construction of religious buildings
/datum/building_agent
	var/name
	var/building_type
	var/favor_cost
	var/deconstruct_favor_cost
	var/piety_cost
	var/deconstruct_piety_cost

/datum/building_agent/proc/get_costs()
	var/costs = ""

	if(favor_cost || piety_cost)
		costs += "("

	if(favor_cost > 0)
		costs += "[favor_cost] favor"

	if(piety_cost > 0)
		if(favor_cost > 0)
			costs += " "
		costs += "[piety_cost] piety"

	if(favor_cost || piety_cost)
		costs += ")"

	return costs

/////////////////////////
//________CULT_________//
/////////////////////////
/datum/building_agent/cult

// Used in tome
/datum/building_agent/cult/structure

/datum/building_agent/cult/structure/wall
	name = "Wall"
	building_type = /turf/simulated/wall/cult
	favor_cost = 0
	deconstruct_favor_cost = 0
	piety_cost = 0
	deconstruct_piety_cost = 0

/datum/building_agent/cult/structure/floor
	name = "Floor"
	building_type = /turf/simulated/floor/engine/cult
	favor_cost = 100
	deconstruct_favor_cost = 50
	piety_cost = 10
	deconstruct_piety_cost = 1

/datum/building_agent/cult/structure/altar
	name = "Altar"
	building_type = /obj/structure/altar_of_gods/cult
	favor_cost = 100
	deconstruct_favor_cost = 50
	piety_cost = 10
	deconstruct_piety_cost = 1

/datum/building_agent/cult/structure/pedestal
	name = "Pedestal"
	building_type = /obj/structure/pedestal/cult
	favor_cost = 100
	deconstruct_favor_cost = 50
	piety_cost = 10
	deconstruct_piety_cost = 1

/datum/building_agent/cult/structure/pylon
	name = "Pylon"
	building_type = /obj/structure/cult/pylon
	favor_cost = 100
	deconstruct_favor_cost = 50
	piety_cost = 10
	deconstruct_piety_cost = 1

/datum/building_agent/cult/structure/door
	name = "Door"
	building_type = /obj/structure/mineral_door/cult
	favor_cost = 100
	deconstruct_favor_cost = 50
	piety_cost = 10
	deconstruct_piety_cost = 1

// Remove runes for free
/datum/building_agent/cult/rune
	building_type = /obj/effect/rune
	// Type of effect of rune
	// Apply to the rune after creating the rune
	var/rune_type

/datum/building_agent/cult/rune/teleport_to_heaven
	name = "Teleport to HEAVEN"
	rune_type = /datum/rune/cult/teleport_to_heaven
	favor_cost = 100
	deconstruct_favor_cost = 50
	piety_cost = 10
	deconstruct_piety_cost = 1

// For forge
/datum/building_agent/cult/tool
/datum/building_agent/cult/tool/tome
	name = "Tome"
	building_type = /obj/item/weapon/storage/bible/tome
	favor_cost = 100
	deconstruct_favor_cost = 50
	piety_cost = 10
	deconstruct_piety_cost = 1
