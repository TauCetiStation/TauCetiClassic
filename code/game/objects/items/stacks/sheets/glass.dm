/* Glass stack types
 * Contains:
 *		Glass sheets
 *		Reinforced glass sheets
 *		Phoron Glass Sheets
 *		Reinforced Phoron Glass Sheets (AKA Holy fuck strong windows)
 *		Glass shards - TODO: Move this into code/game/object/item/weapons
 */

 /*
 * Recipes
 */
var/global/list/datum/stack_recipe/glass_recipes = list (
	new/datum/stack_recipe("thin windows", /obj/structure/window/thin, 1, time = 5, max_per_turf = 4, build_outline = TRUE),
	new/datum/stack_recipe("table parts", /obj/item/weapon/table_parts/glass, 2),
	new/datum/stack_recipe("glass tile", /obj/item/stack/tile/glass, 1, 4, 20, required_skills = list(/datum/skill/construction = SKILL_LEVEL_NOVICE)),
)

var/global/list/datum/stack_recipe/glass_phoron_recipes = list (
	new/datum/stack_recipe("thin windows", /obj/structure/window/thin/phoron, 1, time = 5, max_per_turf = 4, build_outline = TRUE),
	new/datum/stack_recipe("glass tile", /obj/item/stack/tile/glass/phoron, 1, 4, 20, required_skills = list(/datum/skill/construction = SKILL_LEVEL_NOVICE)),
)

var/global/list/datum/stack_recipe/glass_reinforced_recipes = list (
	new/datum/stack_recipe("thin windows", /obj/structure/window/thin/reinforced, 1, time = 5, max_per_turf = 4, build_outline = TRUE),
	new/datum/stack_recipe("table parts", /obj/item/weapon/table_parts/reinforced, 2),
	new/datum/stack_recipe("glass tile", /obj/item/stack/tile/glass/reinforced, 1, 4, 20, required_skills = list(/datum/skill/construction = SKILL_LEVEL_NOVICE)),
	new/datum/stack_recipe("windoor", /obj/structure/windoor_assembly, 5, max_per_turf = 4, build_outline = TRUE, required_skills = list(/datum/skill/construction = SKILL_LEVEL_NOVICE)),
)

var/global/list/datum/stack_recipe/glass_reinforced_phoron_recipes = list (
	new/datum/stack_recipe("thin windows", /obj/structure/window/thin/reinforced/phoron, 1, time = 5, max_per_turf = 4, build_outline = TRUE),
	new/datum/stack_recipe("glass tile", /obj/item/stack/tile/glass/reinforced, 1, 4, 20, required_skills = list(/datum/skill/construction = SKILL_LEVEL_NOVICE)),
)

/*
 * Glass sheets
 */
/obj/item/stack/sheet/glass
	name = "glass"
	desc = "HOLY SHEET! That is a lot of glass."
	singular_name = "glass sheet"
	icon_state = "sheet-glass"
	g_amt = 3750
	origin_tech = "materials=1"

/obj/item/stack/sheet/glass/atom_init()
	. = ..()
	recipes = glass_recipes

/obj/item/stack/sheet/glass/cyborg
	name = "glass"
	desc = "HOLY SHEET! That is a lot of glass."
	singular_name = "glass sheet"
	icon_state = "sheet-glass"
	g_amt = 0

/obj/item/stack/sheet/glass/attackby(obj/item/I, mob/user, params)
	if(iscoil(I))
		var/list/resources_to_use = list()
		resources_to_use[I] = 5
		resources_to_use[src] = 1
		if(!use_multi(user, resources_to_use))
			return

		to_chat(user, "<span class='notice'>You attach wire to the [name].</span>")
		new /obj/item/stack/light_w(user.loc)

	else if(istype(I, /obj/item/stack/rods))
		var/list/resources_to_use = list()
		resources_to_use[I] = 1
		resources_to_use[src] = 1
		if(!use_multi(user, resources_to_use))
			return

		var/obj/item/stack/sheet/rglass/RG = new (user.loc)
		RG.add_fingerprint(user)
		for(var/obj/item/stack/sheet/rglass/G in user.loc)
			if(G==RG)
				continue
			if(G.get_amount() >= G.max_amount)
				continue
			G.attackby(RG, user)
			to_chat(usr, "You add the reinforced glass to the stack. It now contains [RG.get_amount()] sheets.")

	else
		return ..()

/obj/item/stack/sheet/glass/phoronglass/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/rods))
		var/list/resources_to_use = list()
		resources_to_use[I] = 1
		resources_to_use[src] = 1
		if(!use_multi(user, resources_to_use))
			return

		var/obj/item/stack/sheet/glass/phoronrglass/FG = new (user.loc)
		FG.add_fingerprint(user)
		for(var/obj/item/stack/sheet/glass/phoronrglass/G in user.loc)
			if(G == FG)
				continue
			if(G.get_amount() >= G.max_amount)
				continue
			G.attackby(FG, user)

	else
		return ..()

/obj/item/stack/sheet/glass/after_throw(datum/callback/callback)
	..()
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	new /obj/item/weapon/shard(loc) // todo: phoron shard types
	set_amount(get_amount() - rand(5,35))

/obj/item/stack/sheet/rglass/after_throw(datum/callback/callback)
	..()
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	new /obj/item/weapon/shard(loc)
	set_amount(get_amount() - rand(1,15))

/*
 * Reinforced glass sheets
 */
/obj/item/stack/sheet/rglass
	name = "reinforced glass"
	desc = "Glass which seems to have rods or something stuck in them."
	singular_name = "reinforced glass sheet"
	icon_state = "sheet-rglass"
	g_amt = 3750
	m_amt = 1875
	origin_tech = "materials=2"

/obj/item/stack/sheet/rglass/atom_init()
	. = ..()
	recipes = glass_reinforced_recipes

/obj/item/stack/sheet/rglass/cyborg
	name = "reinforced glass"
	desc = "Glass which seems to have rods or something stuck in them."
	singular_name = "reinforced glass sheet"
	icon_state = "sheet-rglass"
	g_amt = 0
	m_amt = 0

/*
 * Phoron Glass sheets
 */
/obj/item/stack/sheet/glass/phoronglass
	name = "phoron glass"
	desc = "A very strong and very resistant sheet of a phoron-glass alloy."
	singular_name = "phoron glass sheet"
	icon_state = "sheet-phoronglass"
	g_amt = 7500
	origin_tech = "materials=3;phorontech=2"

/obj/item/stack/sheet/glass/phoronglass/atom_init()
	. = ..()
	recipes = glass_phoron_recipes

/*
 * Reinforced phoron glass sheets
 */
/obj/item/stack/sheet/glass/phoronrglass
	name = "reinforced phoron glass"
	desc = "Phoron glass which seems to have rods or something stuck in them."
	singular_name = "reinforced phoron glass sheet"
	icon_state = "sheet-phoronrglass"
	g_amt = 7500
	m_amt = 1875
	origin_tech = "materials=4;phorontech=2"

/obj/item/stack/sheet/glass/phoronrglass/atom_init()
	. = ..()
	recipes = glass_reinforced_phoron_recipes
