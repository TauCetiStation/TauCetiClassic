
// A small class that allows any type to assign a religious value
// Maybe rename
/datum/building_agent
	var/name
	var/atom/building_type
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

// Used in tome
/datum/building_agent/structure/cult

/datum/building_agent/structure/cult/wall
	name = "Wall"
	building_type = /turf/simulated/wall/cult
	favor_cost = 0
	deconstruct_favor_cost = 0
	piety_cost = 0
	deconstruct_piety_cost = 0

/datum/building_agent/structure/cult/floor
	name = "Floor"
	building_type = /turf/simulated/floor/engine/cult
	favor_cost = 100
	deconstruct_favor_cost = 50
	piety_cost = 10
	deconstruct_piety_cost = 1

/datum/building_agent/structure/cult/altar
	name = "Altar"
	building_type = /obj/structure/altar_of_gods/cult
	favor_cost = 100
	deconstruct_favor_cost = 50
	piety_cost = 10
	deconstruct_piety_cost = 1

/datum/building_agent/structure/cult/pedestal
	name = "Pedestal"
	building_type = /obj/structure/pedestal/cult
	favor_cost = 100
	deconstruct_favor_cost = 50
	piety_cost = 10
	deconstruct_piety_cost = 1

/datum/building_agent/structure/cult/pylon
	name = "Pylon"
	building_type = /obj/structure/cult/pylon
	favor_cost = 100
	deconstruct_favor_cost = 50
	piety_cost = 10
	deconstruct_piety_cost = 1

/datum/building_agent/structure/cult/door
	name = "Door"
	building_type = /obj/structure/mineral_door/cult
	favor_cost = 100
	deconstruct_favor_cost = 50
	piety_cost = 10
	deconstruct_piety_cost = 1

// Remove runes for free
/datum/building_agent/rune
	// Type of effect of rune
	// Apply to the rune after creating the rune
	var/datum/rune/rune_type
	// Deconstruct costs is how much will be returned, not disappear

/datum/building_agent/rune/cult
	building_type = /obj/effect/rune

/datum/building_agent/rune/cult/New()
	deconstruct_favor_cost = favor_cost * 0.5
	deconstruct_piety_cost = piety_cost * 0.5

/datum/building_agent/rune/cult/teleport_to_heaven
	name = "Teleport to HEAVEN"
	rune_type = /datum/rune/cult/teleport_to_heaven
	favor_cost = 100
	piety_cost = 10

/datum/building_agent/rune/cult/capture_area
	name = "Capture a area"
	rune_type = /datum/rune/cult/capture_area
	favor_cost = 100
	piety_cost = 10

/datum/building_agent/rune/cult/portal_beacon
	name = "Beacon of Cult Portal"
	rune_type = /datum/rune/cult/portal_beacon
	favor_cost = 100
	piety_cost = 10

/datum/building_agent/rune/cult/look_to_future
	name = "Back to the Future"
	rune_type = /datum/rune/cult/look_to_future
	favor_cost = 100
	piety_cost = 10

// For tech_table
/datum/building_agent/tech
	var/icon
	var/icon_state

/datum/building_agent/tech/cult
/datum/building_agent/tech/cult/memorize_rune
	name = "Memorize rune"
	icon = 'icons/obj/rune.dmi'
	icon_state = "4"
	building_type = /datum/religion_tech/cult/memorizing_rune
	favor_cost = 100
	piety_cost = 10

/datum/building_agent/tech/cult/reusable_runes
	name = "Reusable runes"
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	building_type = /datum/religion_tech/cult/reusable_runes
	favor_cost = 100
	piety_cost = 10

/datum/building_agent/tech/cult/build_everywhere
	name = "Build everywhere"
	icon = 'icons/obj/rune.dmi'
	icon_state = "2"
	building_type = /datum/religion_tech/cult/build_everywhere
	favor_cost = 100
	piety_cost = 10

// For forge
/datum/building_agent/tool/cult
/datum/building_agent/tool/cult/tome
	name = "Tome"
	building_type = /obj/item/weapon/storage/bible/tome
	favor_cost = 100
	deconstruct_favor_cost = 50
	piety_cost = 10
	deconstruct_piety_cost = 1
