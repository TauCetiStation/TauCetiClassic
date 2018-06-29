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
	new/datum/stack_recipe("barber chair", /obj/structure/stool/bed/chair/barber, one_per_turf = TRUE, on_floor = TRUE),
	new/datum/stack_recipe("stool", /obj/structure/stool, one_per_turf = TRUE, on_floor = TRUE),
	new/datum/stack_recipe_list("metal chairs", list(
		new/datum/stack_recipe("grey chair", /obj/structure/stool/bed/chair/metal, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("blue chair", /obj/structure/stool/bed/chair/metal/blue, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("red chair", /obj/structure/stool/bed/chair/metal/red, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("green chair", /obj/structure/stool/bed/chair/metal/green, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("black chair", /obj/structure/stool/bed/chair/metal/black, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("white chair", /obj/structure/stool/bed/chair/metal/white, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("yellow chair", /obj/structure/stool/bed/chair/metal/yellow, one_per_turf = TRUE, on_floor = TRUE),
		), 1),
	new/datum/stack_recipe("bed", /obj/structure/stool/bed, 2, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new/datum/stack_recipe_list("office chairs",list(
		new/datum/stack_recipe("dark office chair", /obj/structure/stool/bed/chair/office/dark, 5, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("light office chair", /obj/structure/stool/bed/chair/office/light, 5, one_per_turf = TRUE, on_floor = TRUE),
		), 5),
	new/datum/stack_recipe_list("comfy chairs", list(
		new/datum/stack_recipe("beige comfy chair", /obj/structure/stool/bed/chair/comfy/beige, 2, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("black comfy chair", /obj/structure/stool/bed/chair/comfy/black, 2, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("brown comfy chair", /obj/structure/stool/bed/chair/comfy/brown, 2, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("lime comfy chair", /obj/structure/stool/bed/chair/comfy/lime, 2, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("teal comfy chair", /obj/structure/stool/bed/chair/comfy/teal, 2, one_per_turf = TRUE, on_floor = TRUE),
		), 2),
	null,
	new/datum/stack_recipe("needle", /obj/item/weapon/needle, 1),
	new/datum/stack_recipe("table parts", /obj/item/weapon/table_parts, 2),
	new/datum/stack_recipe("rack parts", /obj/item/weapon/rack_parts),
	new/datum/stack_recipe("closet", /obj/structure/closet, 2, time = 15, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new/datum/stack_recipe("canister", /obj/machinery/portable_atmospherics/canister, 10, time = 15, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new/datum/stack_recipe("cannon frame", /obj/item/weapon/cannonframe, 10, time = 15, one_per_turf = FALSE, on_floor = FALSE),
	null,
	new/datum/stack_recipe("floor tile", /obj/item/stack/tile/plasteel, 1, 4, 20),
	new/datum/stack_recipe("metal rod", /obj/item/stack/rods, 1, 2, 60),
	null,
	new/datum/stack_recipe("computer frame", /obj/structure/computerframe, 5, time = 25, one_per_turf = TRUE, on_floor = TRUE),
	new/datum/stack_recipe("wall girders", /obj/structure/girder, 2, time = 50, one_per_turf = TRUE, on_floor = TRUE),
	new/datum/stack_recipe("machine frame", /obj/machinery/constructable_frame/machine_frame, 5, time = 25, one_per_turf = TRUE, on_floor = TRUE),
	new/datum/stack_recipe("turret frame", /obj/machinery/porta_turret_construct, 5, time = 25, one_per_turf = TRUE, on_floor = TRUE),
	null,
	new/datum/stack_recipe_list("airlock assemblies", list(
		new/datum/stack_recipe("standard airlock assembly", /obj/structure/door_assembly, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("command airlock assembly", /obj/structure/door_assembly/door_assembly_com, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("security airlock assembly", /obj/structure/door_assembly/door_assembly_sec, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("engineering airlock assembly", /obj/structure/door_assembly/door_assembly_eng, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("mining airlock assembly", /obj/structure/door_assembly/door_assembly_min, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("atmospherics airlock assembly", /obj/structure/door_assembly/door_assembly_atmo, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("research airlock assembly", /obj/structure/door_assembly/door_assembly_research, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
/*		new/datum/stack_recipe("science airlock assembly", /obj/structure/door_assembly/door_assembly_science, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE), \ */
		new/datum/stack_recipe("medical airlock assembly", /obj/structure/door_assembly/door_assembly_med, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("maintenance airlock assembly", /obj/structure/door_assembly/door_assembly_mai, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("external airlock assembly", /obj/structure/door_assembly/door_assembly_ext, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("freezer airlock assembly", /obj/structure/door_assembly/door_assembly_fre, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("airtight hatch assembly", /obj/structure/door_assembly/door_assembly_hatch, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("maintenance hatch assembly", /obj/structure/door_assembly/door_assembly_mhatch, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("high security airlock assembly", /obj/structure/door_assembly/door_assembly_highsecurity, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("emergency shutter", /obj/structure/firedoor_assembly, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		new/datum/stack_recipe("multi-tile airlock assembly", /obj/structure/door_assembly/multi_tile, 4, time = 50, one_per_turf = TRUE, on_floor = TRUE),
		), 4),
	null,
	new/datum/stack_recipe("meatspike frame", /obj/structure/kitchenspike_frame, 5, time = 25, one_per_turf = TRUE, on_floor = TRUE), null,
	new/datum/stack_recipe("grenade casing", /obj/item/weapon/grenade/chem_grenade),
	new/datum/stack_recipe("light fixture frame", /obj/item/light_fixture_frame, 2),
	new/datum/stack_recipe("small light fixture frame", /obj/item/light_fixture_frame/small, 1),
	null,
	new/datum/stack_recipe("apc frame", /obj/item/apc_frame, 2),
	new/datum/stack_recipe("air alarm frame", /obj/item/alarm_frame, 2),
	new/datum/stack_recipe("fire alarm frame", /obj/item/firealarm_frame, 2),
	null,
	new/datum/stack_recipe("iron door", /obj/structure/mineral_door/iron, 20, one_per_turf = TRUE, on_floor = TRUE)
)

/obj/item/stack/sheet/metal
	name = "metal"
	desc = "Sheets made out off metal. It has been dubbed Metal Sheets."
	singular_name = "metal sheet"
	icon_state = "sheet-metal"
	m_amt = 3750
	throwforce = 14.0
	flags = CONDUCT
	origin_tech = "materials=1"

/obj/item/stack/sheet/metal/cyborg
	name = "metal"
	desc = "Sheets made out off metal. It has been dubbed Metal Sheets."
	singular_name = "metal sheet"
	icon_state = "sheet-metal"
	m_amt = 0
	throwforce = 14.0
	flags = CONDUCT

/obj/item/stack/sheet/metal/atom_init()
	recipes = metal_recipes
	. = ..()


/*
 * Plasteel
 */
var/global/list/datum/stack_recipe/plasteel_recipes = list ( \
	new/datum/stack_recipe("AI core", /obj/structure/AIcore, 4, time = 50, one_per_turf = TRUE), \
	new/datum/stack_recipe("Metal crate", /obj/structure/closet/crate, 10, time = 50, one_per_turf = TRUE), \
	)

/obj/item/stack/sheet/plasteel
	name = "plasteel"
	singular_name = "plasteel sheet"
	desc = "This sheet is an alloy of iron and phoron."
	icon_state = "sheet-plasteel"
	item_state = "sheet-metal"
	m_amt = 7500
	throwforce = 15.0
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
	new/datum/stack_recipe("knitting neele", /obj/item/weapon/knitting_needle, 1, 2),
	new/datum/stack_recipe("wood floor tile", /obj/item/stack/tile/wood, 1, 4, 20),
	new/datum/stack_recipe("table parts", /obj/item/weapon/table_parts/wood, 2),
	new/datum/stack_recipe("fancy table parts", /obj/item/weapon/table_parts/wood/fancy, 2),
	new/datum/stack_recipe("black fancy table parts", /obj/item/weapon/table_parts/wood/fancy/black, 2),
	new/datum/stack_recipe("wooden chair", /obj/structure/stool/bed/chair/wood/normal, 3, time = 10, one_per_turf = TRUE, on_floor = TRUE),
	new/datum/stack_recipe("wooden barricade", /obj/structure/barricade/wooden, 5, time = 50, one_per_turf = TRUE, on_floor = TRUE),
	new/datum/stack_recipe("crossbow frame", /obj/item/weapon/crossbowframe, 5, time = 25, one_per_turf = FALSE, on_floor = FALSE),
	new/datum/stack_recipe("wooden door", /obj/structure/mineral_door/wood, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
	new/datum/stack_recipe("bonfire", /obj/structure/bonfire, 10, time = 20, one_per_turf = TRUE, on_floor = TRUE),
	new/datum/stack_recipe("coffin", /obj/structure/closet/coffin, 5, time = 15, one_per_turf = TRUE, on_floor = TRUE),
//	new/datum/stack_recipe("apiary", /obj/item/apiary, 10, time = 25, one_per_turf = FALSE, on_floor = FALSE)
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
/obj/item/stack/sheet/cloth
	name = "unprocessed cloth"
	desc = "This roll of cloth came straight from rags. It still needs lotsa work to do, before it becomes any good."
	singular_name = "unprocessed cloth roll"
	icon_state = "sheet-cloth"
	origin_tech = "materials=1"
	var/tied_together = FALSE
	var/processed = FALSE

/obj/item/stack/sheet/cloth/attackby(obj/item/I, mob/user)
	if((istype(I, /obj/item/stack/stringed_needle) || istype(I, /obj/item/stack/cable_coil) || istype(I, /obj/item/stack/string)) && !tied_together)
		var/obj/item/stack/STR = I
		if(STR.amount < amount)
			return
		user.visible_message("<span class='notice'>[user] is tying together [src].</span>")
		if(user.is_busy() || !do_after(user, amount * 5, target = user))
			return
		STR.use(amount)
		tied_together = TRUE
	else if(I.sharp && tied_together && !processed)
		if(wet < 1)
			user.visible_message("<span class='notice'>[user] is shaping [src] up.</span>")
			if(user.is_busy() || !do_after(user, amount * 5, target = user))
				return
			var/obj/item/stack/sheet/cloth/cloth_processed/C = new(get_turf(src), amount, TRUE)
			C.color = color
			qdel(src)
		else
			to_chat(user, "<span class='notice'>Dry [src] out first</span>")
	else
		..()

/obj/item/stack/sheet/cloth/change_stack(mob/user, amount)
	var/obj/item/stack/sheet/cloth/S = ..()
	S.color = color

var/global/list/datum/stack_recipe/processed_cloth_recipes = list(
	new/datum/stack_recipe("carpet", /obj/item/stack/tile/carpet, 2, 1, 50),
	new/datum/stack_recipe("bruise pack", /obj/item/stack/medical/bruise_pack, 1, 1, 5),
	new/datum/stack_recipe("damp rag", /obj/item/weapon/reagent_containers/glass/rag, 1),
	new/datum/stack_recipe("muzzle", /obj/item/clothing/mask/muzzle, 1, 1, 1, 60),
	new/datum/stack_recipe("straight jacket", /obj/item/clothing/suit/straight_jacket, 6, 1, 1, 60),
	new/datum/stack_recipe("footwraps", /obj/item/clothing/shoes/footwraps, 1)
	)

/obj/item/stack/sheet/cloth/cloth_processed
	name = "cloth"
	desc = "This roll of cloth is made from only the finest chemicals and bunny rabbits. Or perhaps out of nicely polished rags."
	singular_name = "cloth roll"
	icon_state = "sheet-cloth"
	origin_tech = "materials=2"
	var/datum/tailoring_progress/tailoring
	tied_together = TRUE
	processed = TRUE

/obj/item/stack/sheet/cloth/cloth_processed/atom_init()
	. = ..()
	recipes = processed_cloth_recipes
	tailoring = new/datum/tailoring_progress(src)

/obj/item/stack/sheet/cloth/cloth_processed/Destroy()
	QDEL_NULL(tailoring)
	return ..()

/obj/item/stack/sheet/cloth/cloth_processed/attackby(obj/item/I, mob/user)
	if(do_tailoring(user, I, src))
		return
	else
		..()

/obj/item/stack/sheet/cloth/cloth_processed/examine(mob/user)
	..()
	var/text_to_show = ""
	for(var/A in tailoring.steps_made)
		if(text_to_show)
			text_to_show += ", [A]"
		else
			text_to_show += "It seems this piece of cloth has underwent [A]"
	if(text_to_show)
		to_chat(user, "[text_to_show]")

/obj/item/stack/sheet/cloth/cloth_processed/random/atom_init()
	. = ..()
	color = pick(COLOR_ADEQUATE_LIST)
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
