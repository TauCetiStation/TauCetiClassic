/* Diffrent misc types of sheets
 * Contains:
 *		Metal
 *		Plasteel
 *		Wood
 *		Cloth
 *		Cardboard
 */

/*
 * Metal
 */
var/global/list/datum/stack_recipe/metal_recipes = list (
	new/datum/stack_recipe("barber chair", /obj/structure/stool/bed/chair/barber, max_per_turf = 1, build_outline = TRUE),
	new/datum/stack_recipe("stool", /obj/structure/stool, max_per_turf = 1, build_outline = TRUE),
	new/datum/stack_recipe_list("metal chairs", list(
		new/datum/stack_recipe("grey chair", /obj/structure/stool/bed/chair/metal, max_per_turf = 1, build_outline = TRUE),
		new/datum/stack_recipe("blue chair", /obj/structure/stool/bed/chair/metal/blue, max_per_turf = 1, build_outline = TRUE),
		new/datum/stack_recipe("red chair", /obj/structure/stool/bed/chair/metal/red, max_per_turf = 1, build_outline = TRUE),
		new/datum/stack_recipe("green chair", /obj/structure/stool/bed/chair/metal/green, max_per_turf = 1, build_outline = TRUE),
		new/datum/stack_recipe("black chair", /obj/structure/stool/bed/chair/metal/black, max_per_turf = 1, build_outline = TRUE),
		new/datum/stack_recipe("white chair", /obj/structure/stool/bed/chair/metal/white, max_per_turf = 1, build_outline = TRUE),
		new/datum/stack_recipe("yellow chair", /obj/structure/stool/bed/chair/metal/yellow, max_per_turf = 1, build_outline = TRUE),
		), 1),
	new/datum/stack_recipe("bed", /obj/structure/stool/bed, 2, max_per_turf = 1, build_outline = TRUE),
	null,
	new/datum/stack_recipe_list("office chairs",list(
		new/datum/stack_recipe("dark office chair", /obj/structure/stool/bed/chair/office/dark, 5, max_per_turf = 1, build_outline = TRUE),
		new/datum/stack_recipe("light office chair", /obj/structure/stool/bed/chair/office/light, 5, max_per_turf = 1, build_outline = TRUE),
		), 5),
	new/datum/stack_recipe_list("comfy chairs", list(
		new/datum/stack_recipe("black comfy chair", /obj/structure/stool/bed/chair/comfy/black, 2, max_per_turf = 1, build_outline = TRUE),
		new/datum/stack_recipe("beige comfy chair", /obj/structure/stool/bed/chair/comfy/white, 2, max_per_turf = 1, build_outline = TRUE),
		new/datum/stack_recipe("brown comfy chair", /obj/structure/stool/bed/chair/comfy/brown, 2, max_per_turf = 1, build_outline = TRUE),
		new/datum/stack_recipe("lime comfy chair", /obj/structure/stool/bed/chair/comfy/lime, 2, max_per_turf = 1, build_outline = TRUE),
		new/datum/stack_recipe("teal comfy chair", /obj/structure/stool/bed/chair/comfy/green, 2, max_per_turf = 1, build_outline = TRUE),
		), 2),
	new/datum/stack_recipe_list("Cabinets", list(
			new/datum/stack_recipe("Light filling cabinet", /obj/structure/filingcabinet/filingcabinet, 4, time = 15, max_per_turf = 1, build_outline = TRUE),
			new/datum/stack_recipe("Dark filling cabinet", /obj/structure/filingcabinet, 4, time = 15, max_per_turf = 1, build_outline = TRUE),
			new/datum/stack_recipe("Light chest drawer", /obj/structure/filingcabinet/chestdrawer, 4, time = 15, max_per_turf = 1, build_outline = TRUE),
			new/datum/stack_recipe("Dark chest drawer", /obj/structure/filingcabinet/chestdrawer/black, 4, time = 15, max_per_turf = 1, build_outline = TRUE),
		), 4),
	null,
	new/datum/stack_recipe("table parts", /obj/item/weapon/table_parts, 2),
	new/datum/stack_recipe("rack parts", /obj/item/weapon/rack_parts),
	new/datum/stack_recipe("closet", /obj/structure/closet, 2, time = 15, max_per_turf = 1, build_outline = TRUE,  required_skills = list(/datum/skill/construction = SKILL_LEVEL_NOVICE)),
	null,
	new/datum/stack_recipe("canister", /obj/machinery/portable_atmospherics/canister, 10, time = 15, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
	null,
	new/datum/stack_recipe("floor tile", /obj/item/stack/tile/plasteel, 1, 4, 20, required_skills = list(/datum/skill/construction = SKILL_LEVEL_NOVICE)),
	new/datum/stack_recipe("grid floor tile", /obj/item/stack/tile/grid, 1, 4, 20, required_skills = list(/datum/skill/construction = SKILL_LEVEL_NOVICE)),
	new/datum/stack_recipe("metal rod", /obj/item/stack/rods, 1, 2, 60, required_skills = list(/datum/skill/construction = SKILL_LEVEL_NOVICE)),
	null,
	new/datum/stack_recipe("computer frame", /obj/structure/computerframe, 5, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
	new/datum/stack_recipe("wall girders", /obj/structure/girder, 2, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_TRAINED)),
	new/datum/stack_recipe("machine frame", /obj/machinery/constructable_frame/machine_frame, 5, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
	new/datum/stack_recipe("turret frame", /obj/machinery/porta_turret_construct, 5, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
	null,
	new/datum/stack_recipe_list("airlock assemblies", list(
		new/datum/stack_recipe("standard airlock assembly", /obj/structure/door_assembly, 4, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
		new/datum/stack_recipe("command airlock assembly", /obj/structure/door_assembly/door_assembly_com, 4, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
		new/datum/stack_recipe("security airlock assembly", /obj/structure/door_assembly/door_assembly_sec, 4, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
		new/datum/stack_recipe("engineering airlock assembly", /obj/structure/door_assembly/door_assembly_eng, 4, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
		new/datum/stack_recipe("mining airlock assembly", /obj/structure/door_assembly/door_assembly_min, 4, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
		new/datum/stack_recipe("atmospherics airlock assembly", /obj/structure/door_assembly/door_assembly_atmo, 4, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
		new/datum/stack_recipe("research airlock assembly", /obj/structure/door_assembly/door_assembly_research, 4, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
/*		new/datum/stack_recipe("science airlock assembly", /obj/structure/door_assembly/door_assembly_science, 4, time = 50, max_per_turf = 1, build_outline = TRUE), \ */
		new/datum/stack_recipe("medical airlock assembly", /obj/structure/door_assembly/door_assembly_med, 4, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
		new/datum/stack_recipe("maintenance airlock assembly", /obj/structure/door_assembly/door_assembly_mai, 4, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
		new/datum/stack_recipe("external airlock assembly", /obj/structure/door_assembly/door_assembly_ext, 4, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
		new/datum/stack_recipe("freezer airlock assembly", /obj/structure/door_assembly/door_assembly_fre, 4, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
		new/datum/stack_recipe("airtight hatch assembly", /obj/structure/door_assembly/door_assembly_hatch, 4, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
		new/datum/stack_recipe("maintenance hatch assembly", /obj/structure/door_assembly/door_assembly_mhatch, 4, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
		new/datum/stack_recipe("high security airlock assembly", /obj/structure/door_assembly/door_assembly_highsecurity, 4, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
		new/datum/stack_recipe("emergency shutter", /obj/structure/firedoor_assembly, 4, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
		new/datum/stack_recipe("multi-tile airlock assembly", /obj/structure/door_assembly/multi_tile, 4, time = 50, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
		), 4),
	null,
	new/datum/stack_recipe("meatspike frame", /obj/structure/kitchenspike_frame, 5, time = 25, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_NOVICE)), null,
	new/datum/stack_recipe("grenade casing", /obj/item/weapon/grenade/chem_grenade, required_skills = list(/datum/skill/construction = SKILL_LEVEL_TRAINED)),
	new/datum/stack_recipe("light fixture frame", /obj/item/light_fixture_frame, 2, required_skills = list(/datum/skill/construction = SKILL_LEVEL_NOVICE)),
	new/datum/stack_recipe("small light fixture frame", /obj/item/light_fixture_frame/small, 1, required_skills = list(/datum/skill/construction = SKILL_LEVEL_NOVICE)),
	null,
	new/datum/stack_recipe("apc frame", /obj/item/apc_frame, 2, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
	new/datum/stack_recipe("air alarm frame", /obj/item/alarm_frame, 2, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
	new/datum/stack_recipe("fire alarm frame", /obj/item/firealarm_frame, 2, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
	new/datum/stack_recipe("door control frame", /obj/item/door_control_frame, 1, required_skills = list(/datum/skill/construction = SKILL_LEVEL_PRO)),
	new/datum/stack_recipe("metal picture frame", /obj/item/weapon/picture_frame/metal, 1, time = 15),
	null,
	new/datum/stack_recipe("metal door", /obj/structure/mineral_door/metal, 20, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_TRAINED)),
	new/datum/stack_recipe("windowsill", /obj/structure/windowsill, 2, max_per_turf = 1, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_TRAINED), time = 20)
)

/obj/item/stack/sheet/metal
	name = "metal"
	desc = "Sheets made out off metal. It has been dubbed Metal Sheets."
	singular_name = "metal sheet"
	icon_state = "sheet-metal"
	hitsound = list('sound/items/trayhit2.ogg')
	m_amt = 3750
	throwforce = 5.0
	flags = CONDUCT
	origin_tech = "materials=1"

/obj/item/stack/sheet/metal/cyborg
	name = "metal"
	desc = "Sheets made out off metal. It has been dubbed Metal Sheets."
	singular_name = "metal sheet"
	icon_state = "sheet-metal"
	m_amt = 0
	throwforce = 5.0
	flags = CONDUCT

/obj/item/stack/sheet/metal/atom_init()
	recipes = metal_recipes
	. = ..()

/*
 * Plasteel
 */
var/global/list/datum/stack_recipe/plasteel_recipes = list ( \
	new/datum/stack_recipe("AI core", /obj/structure/AIcore, 4, time = 50, max_per_turf = 1, required_skills = list(/datum/skill/construction = SKILL_LEVEL_MASTER)), \
	new/datum/stack_recipe("Metal crate", /obj/structure/closet/crate, 10, time = 50, max_per_turf = 1, required_skills = list(/datum/skill/construction = SKILL_LEVEL_TRAINED)), \
	)

/obj/item/stack/sheet/plasteel
	name = "plasteel"
	singular_name = "plasteel sheet"
	desc = "This sheet is an alloy of steel and platinum."
	icon_state = "sheet-plasteel"
	item_state = "sheet-metal"
	m_amt = 7500
	throwforce = 7.0
	flags = CONDUCT
	origin_tech = "materials=2"

/obj/item/stack/sheet/plasteel/atom_init()
	recipes = plasteel_recipes
	. = ..()

/*
 * Wood
 */
var/global/list/datum/stack_recipe/wood_recipes = list (
	new/datum/stack_recipe("wooden sandals", /obj/item/clothing/shoes/sandal, 1),
	new/datum/stack_recipe("condiment shelf", /obj/item/weapon/condiment_shelf, 5, time = 15),
	new/datum/stack_recipe("wood floor tile", /obj/item/stack/tile/wood, 1, 4, 20),
	new/datum/stack_recipe("table parts", /obj/item/weapon/table_parts/wood, 2),
	new/datum/stack_recipe("fancy table parts", /obj/item/weapon/table_parts/wood/fancy, 2),
	new/datum/stack_recipe("black fancy table parts", /obj/item/weapon/table_parts/wood/fancy/black, 2),
	new/datum/stack_recipe("wooden chair", /obj/structure/stool/bed/chair/wood/normal, 3, time = 10, max_per_turf = 1, build_outline = TRUE),
	new/datum/stack_recipe("wooden barricade", /obj/structure/barricade/wooden, 5, time = 50, max_per_turf = 1, build_outline = TRUE),
	new/datum/stack_recipe("wooden door", /obj/structure/mineral_door/wood, 10, time = 20, max_per_turf = 1, build_outline = TRUE),
	new/datum/stack_recipe("bonfire", /obj/structure/bonfire/dynamic, 10, time = 20, max_per_turf = 1, build_outline = TRUE, floor_path = list(/turf/simulated/floor, /turf/environment/snow)),
	new/datum/stack_recipe("wooden noticeboard", /obj/item/noticeboard_frame/wood, 10, time = 20, build_outline = TRUE),
	new/datum/stack_recipe("coffin", /obj/structure/closet/coffin, 5, time = 15, max_per_turf = 1, build_outline = TRUE),
	new/datum/stack_recipe("wooden picture frame", /obj/item/weapon/picture_frame/wooden, 1, time = 15),
	new/datum/stack_recipe("painting frame", /obj/item/painting_frame, 2, time = 15),
	new/datum/stack_recipe("display case chassis", /obj/structure/displaycase_chassis, 5, time = 2 SECONDS, max_per_turf = 1, build_outline = TRUE), \
	new/datum/stack_recipe("painting easel", /obj/structure/easel, 4, time = 15, max_per_turf = 1, build_outline = TRUE),
//	new/datum/stack_recipe("apiary", /obj/item/apiary, 10, time = 25, max_per_turf = FALSE, build_outline = FALSE)
	)

/obj/item/stack/sheet/wood
	name = "wooden plank"
	desc = "One can only guess that this is a bunch of wood."
	singular_name = "wood plank"
	icon_state = "sheet-wood"
	origin_tech = "materials=1;biotech=1"

/obj/item/stack/sheet/wood/cyborg
	name = "wooden plank"
	desc = "One can only guess that this is a bunch of wood."
	singular_name = "wood plank"
	icon_state = "sheet-wood"

/obj/item/stack/sheet/wood/atom_init()
	recipes = wood_recipes
	. = ..()

/*
 * Cloth
 */
var/global/list/datum/stack_recipe/cloth_recipes = list (
	new/datum/stack_recipe("rags", /obj/item/stack/medical/bruise_pack/rags/not_old, 1, 5, 25, 15),
	null,
	new/datum/stack_recipe("19x19 canvas", /obj/item/canvas/nineteen_nineteen, 3, time = 30),
	new/datum/stack_recipe("23x19 canvas", /obj/item/canvas/twentythree_nineteen, 4, time = 30),
	new/datum/stack_recipe("23x23 canvas", /obj/item/canvas/twentythree_twentythree, 5, time = 30),
	)

var/global/list/datum/stack_recipe/old_cloth_recipes = list (
	new/datum/stack_recipe("rags", /obj/item/stack/medical/bruise_pack/rags/old, 1, 5, 25, 15),
	null,
	new/datum/stack_recipe("19x19 canvas", /obj/item/canvas/nineteen_nineteen, 3, time = 30),
	new/datum/stack_recipe("23x19 canvas", /obj/item/canvas/twentythree_nineteen, 4, time = 30),
	new/datum/stack_recipe("23x23 canvas", /obj/item/canvas/twentythree_twentythree, 5, time = 30),
	)
/obj/item/stack/sheet/cloth
	name = "cloth"
	desc = "This roll of cloth is made from only the finest chemicals and bunny rabbits."
	singular_name = "cloth roll"
	icon_state = "sheet-cloth"
	origin_tech = "materials=2"

/obj/item/stack/sheet/cloth/atom_init(mapload, new_amount = null, merge = FALSE, force_old = FALSE, old_chance = 33)
	recipes = cloth_recipes
	. = ..()
	if(force_old || prob(old_chance))
		make_old()
		recipes = old_cloth_recipes

/*
 * Cardboard
 */
var/global/list/datum/stack_recipe/cardboard_recipes = list ( \
	new/datum/stack_recipe("box", /obj/item/weapon/storage/box), \
	new/datum/stack_recipe("shotgun shell box", /obj/item/weapon/storage/box/shotgun), \
	new/datum/stack_recipe("light tubes", /obj/item/weapon/storage/box/lights/tubes), \
	new/datum/stack_recipe("light bulbs", /obj/item/weapon/storage/box/lights/bulbs), \
	new/datum/stack_recipe("cardboard tube", /obj/item/weapon/c_tube), \
	new/datum/stack_recipe("mouse traps", /obj/item/weapon/storage/box/mousetraps), \
	new/datum/stack_recipe("cardborg suit", /obj/item/clothing/suit/cardborg, 3), \
	new/datum/stack_recipe("cardborg helmet", /obj/item/clothing/head/cardborg), \
	new/datum/stack_recipe("pizza box", /obj/item/pizzabox), \
	null, \
	new/datum/stack_recipe_list("folders",list( \
		new/datum/stack_recipe("blue folder", /obj/item/weapon/folder/blue), \
		new/datum/stack_recipe("grey folder", /obj/item/weapon/folder), \
		new/datum/stack_recipe("red folder", /obj/item/weapon/folder/red), \
		new/datum/stack_recipe("white folder", /obj/item/weapon/folder/white), \
		new/datum/stack_recipe("yellow folder", /obj/item/weapon/folder/yellow), \
		new/datum/stack_recipe("green folder", /obj/item/weapon/folder/green), \
		new/datum/stack_recipe("brown folder", /obj/item/weapon/folder/brown), \
		new/datum/stack_recipe("pink folder", /obj/item/weapon/folder/pink), \
		new/datum/stack_recipe("purple folder", /obj/item/weapon/folder/purple), \
		)) \
)

/obj/item/stack/sheet/cardboard	//BubbleWrap
	name = "cardboard"
	desc = "Large sheets of card, like boxes folded flat."
	singular_name = "cardboard sheet"
	icon_state = "sheet-card"
	origin_tech = "materials=1"

/obj/item/stack/sheet/cardboard/atom_init()
	recipes = cardboard_recipes
	. = ..()
