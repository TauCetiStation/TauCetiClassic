
// A small holder that allows any type to assign a religious value
// Maybe rename
/datum/building_agent
	var/name
	var/atom/building_type
	var/favor_cost = 0
	var/deconstruct_favor_cost = 0
	var/piety_cost = 0
	var/deconstruct_piety_cost = 0

/datum/building_agent/proc/get_costs(coef = 1)
	var/costs = ""

	if(favor_cost || piety_cost)
		costs += "("

	if(favor_cost > 0)
		costs += "[favor_cost * coef] favor"

	if(piety_cost > 0)
		if(favor_cost > 0)
			costs += " "
		costs += "[piety_cost * coef] piety"

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
	favor_cost = 50
	deconstruct_favor_cost = 25
	piety_cost = 0
	deconstruct_piety_cost = 0

/datum/building_agent/structure/cult/floor
	name = "Floor"
	building_type = /turf/simulated/floor/engine/cult
	favor_cost = 10
	deconstruct_favor_cost = 5
	piety_cost = 0
	deconstruct_piety_cost = 0

/datum/building_agent/structure/cult/altar
	name = "Altar"
	building_type = /obj/structure/altar_of_gods/cult
	favor_cost = 150
	deconstruct_favor_cost = 50
	piety_cost = 50
	deconstruct_piety_cost = 0

/datum/building_agent/structure/cult/pedestal
	name = "Pedestal"
	building_type = /obj/structure/pedestal/cult
	favor_cost = 100
	deconstruct_favor_cost = 50
	piety_cost = 10
	deconstruct_piety_cost = 0

/datum/building_agent/structure/cult/pylon
	name = "Pylon"
	building_type = /obj/structure/cult/pylon
	favor_cost = 150
	deconstruct_favor_cost = 75
	piety_cost = 0
	deconstruct_piety_cost = 0

/datum/building_agent/structure/cult/door
	name = "Door"
	building_type = /obj/structure/mineral_door/cult
	favor_cost = 125
	deconstruct_favor_cost = 50
	piety_cost = 0
	deconstruct_piety_cost = 1

/datum/building_agent/structure/cult/tech_table
	name = "Tech Table"
	building_type = /obj/structure/cult/tech_table
	favor_cost = 50
	deconstruct_favor_cost = 50
	piety_cost = 100
	deconstruct_piety_cost = 20

/datum/building_agent/structure/cult/forge
	name = "Forge"
	building_type = /obj/structure/cult/forge
	favor_cost = 50
	deconstruct_favor_cost = 50
	piety_cost = 50
	deconstruct_piety_cost = 0

/datum/building_agent/structure/cult/torture_table
	name = "Torture Table"
	building_type = /obj/machinery/optable/torture_table
	favor_cost = 200
	deconstruct_favor_cost = 50
	piety_cost = 10
	deconstruct_piety_cost = 0

/datum/building_agent/rune
	// Type of effect of rune
	// Apply to the rune after creating the rune
	var/datum/rune/rune_type
	// Deconstruct costs is how much will be returned, not disappear

// It was a bad idea to give them a costs
/datum/building_agent/rune/cult
	building_type = /obj/effect/rune

/datum/building_agent/rune/cult/teleport_to_heaven
	name = "Teleport to HEAVEN"
	rune_type = /datum/rune/cult/teleport/teleport_to_heaven

/datum/building_agent/rune/cult/capture_area
	name = "Capture a Area"
	rune_type = /datum/rune/cult/capture_area

/datum/building_agent/rune/cult/portal_beacon
	name = "Beacon of Cult Portal"
	rune_type = /datum/rune/cult/portal_beacon

/datum/building_agent/rune/cult/look_to_future
	name = "Back to The Future"
	rune_type = /datum/rune/cult/look_to_future

/datum/building_agent/rune/cult/teleport
	name = "Teleport"
	rune_type = /datum/rune/cult/teleport/teleport

/datum/building_agent/rune/cult/item_port
	name = "Item Teleport"
	rune_type = /datum/rune/cult/item_port

/datum/building_agent/rune/cult/wall
	name = "Summon wall"
	rune_type = /datum/rune/cult/wall

/datum/building_agent/rune/cult/bloodboil
	name = "Bloodboil"
	rune_type = /datum/rune/cult/bloodboil

/datum/building_agent/rune/cult/armor
	name = "Summon a regimentals"
	rune_type = /datum/rune/cult/armor


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
	favor_cost = 300
	piety_cost = 150

/datum/building_agent/tech/cult/reusable_runes
	name = "Reusable runes"
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	building_type = /datum/religion_tech/cult/reusable_runes
	favor_cost = 700
	piety_cost = 10

/datum/building_agent/tech/cult/build_everywhere
	name = "Build everywhere"
	icon = 'icons/obj/rune.dmi'
	icon_state = "2"
	building_type = /datum/religion_tech/cult/build_everywhere
	favor_cost = 400
	piety_cost = 50

/datum/building_agent/tech/cult/mirror_shield
	name = "Mirror shield"
	icon = 'icons/obj/cult.dmi'
	icon_state = "mirror_shield"
	building_type = /datum/religion_tech/cult/mirror_shield
	favor_cost = 200
	piety_cost = 50

/datum/building_agent/tech/cult/more_runes
	name = "Maximum runes increased by 10"
	icon = 'icons/obj/rune.dmi'
	icon_state = "3"
	building_type = /datum/religion_tech/cult/more_runes
	favor_cost = 300
	piety_cost = 80

// For forge
/datum/building_agent/tool/cult
/datum/building_agent/tool/cult/tome
	name = "Tome"
	building_type = /obj/item/weapon/storage/bible/tome
	favor_cost = 200
	piety_cost = 10
