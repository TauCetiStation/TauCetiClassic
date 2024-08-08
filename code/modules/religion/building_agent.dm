
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
	// deconstruct its adding a favor, not removing it

/datum/building_agent/structure/cult/wall
	name = "Стена"
	building_type = /turf/simulated/wall/cult
	deconstruct_favor_cost = 10

/datum/building_agent/structure/cult/floor
	name = "Пол"
	building_type = /turf/simulated/floor/engine/cult

/datum/building_agent/structure/cult/altar
	name = "Алтарь"
	building_type = /obj/structure/altar_of_gods/cult
	favor_cost = 150
	deconstruct_favor_cost = 50
	piety_cost = 50
	deconstruct_piety_cost = 0

/datum/building_agent/structure/cult/pedestal
	name = "Пьедестал"
	building_type = /obj/structure/pedestal/cult
	deconstruct_favor_cost = 50

/datum/building_agent/structure/cult/pylon
	name = "Пилон"
	building_type = /obj/structure/cult/pylon
	favor_cost = 200
	deconstruct_favor_cost = 50

/datum/building_agent/structure/cult/door
	name = "Дверь"
	building_type = /obj/structure/mineral_door/cult

/datum/building_agent/structure/cult/tech_table
	name = "Стол исследований"
	building_type = /obj/structure/cult/tech_table
	favor_cost = 50
	deconstruct_favor_cost = 50
	piety_cost = 150
	deconstruct_piety_cost = 20

/datum/building_agent/structure/cult/forge
	name = "Кузня"
	building_type = /obj/structure/cult/forge
	favor_cost = 50
	deconstruct_favor_cost = 50
	piety_cost = 50
	deconstruct_piety_cost = 0

/datum/building_agent/structure/cult/torture_table
	name = "Стол Пыток"
	building_type = /obj/machinery/optable/torture_table

/datum/building_agent/rune
	// Type of effect of rune
	// Apply to the rune after creating the rune
	var/datum/rune/rune_type
	// Deconstruct costs is how much will be returned, not disappear

// It was a bad idea to give them a costs
/datum/building_agent/rune/cult
	building_type = /obj/effect/rune

/datum/building_agent/rune/cult/teleport_to_heaven
	name = "Телепорт в РАЙ"
	rune_type = /datum/rune/cult/teleport/teleport_to_heaven

/datum/building_agent/rune/cult/capture_area
	name = "Захват Зоны"
	rune_type = /datum/rune/cult/capture_area

/datum/building_agent/rune/cult/portal_beacon
	name = "Маяк Портала Культа"
	rune_type = /datum/rune/cult/portal_beacon

/datum/building_agent/rune/cult/look_to_future
	name = "Назад в Будущее"
	rune_type = /datum/rune/cult/look_to_future

/datum/building_agent/rune/cult/teleport
	name = "Телепорт"
	rune_type = /datum/rune/cult/teleport/teleport

/datum/building_agent/rune/cult/item_port
	name = "Телепорт Предметов"
	rune_type = /datum/rune/cult/item_port

/datum/building_agent/rune/cult/wall
	name = "Призыв Стены"
	rune_type = /datum/rune/cult/wall

/datum/building_agent/rune/cult/bloodboil
	name = "Кипение Крови"
	rune_type = /datum/rune/cult/bloodboil

/datum/building_agent/rune/cult/charge_pylons
	name = "Активация Пилонов"
	rune_type = /datum/rune/cult/charge_pylons


// For tech_table
/datum/building_agent/tech
	var/icon
	var/icon_state
	var/researching = FALSE

/datum/building_agent/tech/cult
/datum/building_agent/tech/cult/memorize_rune
	name = "Запомнить Руну"
	icon = 'icons/obj/rune.dmi'
	icon_state = "4"
	building_type = /datum/religion_tech/cult/memorizing_rune
	favor_cost = 300
	piety_cost = 230

/datum/building_agent/tech/cult/reusable_runes
	name = "Многоразовые Руны"
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	building_type = /datum/religion_tech/cult/reusable_runes
	favor_cost = 600
	piety_cost = 50

/datum/building_agent/tech/cult/build_everywhere
	name = "Строительство Везде"
	icon = 'icons/obj/cult.dmi'
	icon_state = "pylon"
	building_type = /datum/religion_tech/cult/build_everywhere
	favor_cost = 400
	piety_cost = 100

/datum/building_agent/tech/cult/mirror_shield
	name = "Зеркальный Щит"
	icon = 'icons/obj/cult.dmi'
	icon_state = "mirror_shield"
	building_type = /datum/religion_tech/cult/mirror_shield
	favor_cost = 200
	piety_cost = 50

/datum/building_agent/tech/cult/more_runes
	name = "Увеличение Максимума Рун на 5"
	icon = 'icons/obj/rune.dmi'
	icon_state = "3"
	building_type = /datum/religion_tech/cult/more_runes
	favor_cost = 300
	piety_cost = 80

/datum/building_agent/tech/cult/improved_pylons
	name = "Улучшенные пилоны"
	icon = 'icons/obj/cult.dmi'
	icon_state = "pylon"
	building_type = /datum/religion_tech/cult/improved_pylons
	favor_cost = 300
	piety_cost = 80

// For forge
/datum/building_agent/tool/cult
/datum/building_agent/tool/cult/tome
	name = "Том"
	building_type = /obj/item/weapon/storage/bible/tome
	favor_cost = 50

/datum/building_agent/tool/cult/armor
	name = "Набор Брони"
	building_type = /obj/item/weapon/storage/backpack/cultpack/armor
	favor_cost = 200

/datum/building_agent/tool/cult/blade
	name = "Кровавая Месть"
	building_type = /obj/item/weapon/melee/cultblade
	favor_cost = 100

/datum/building_agent/tool/cult/cult_blindfold
	name = "Слепое Прозрение"
	building_type = /obj/item/clothing/glasses/cult_blindfold
	favor_cost = 120
	piety_cost = 30

/datum/building_agent/tool/cult/space_armor
	name = "Набор Космической Брони"
	building_type = /obj/item/weapon/storage/backpack/cultpack/space_armor
	favor_cost = 300
	piety_cost = 20

/datum/building_agent/tool/cult/stone
	name = "Камень Прозрения"
	building_type = /obj/item/device/cult_camera
	favor_cost = 100
	piety_cost = 50
