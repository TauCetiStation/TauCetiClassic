#define PATH2CSS(path) replacetext(replacetext("[path]", "[/obj/item]/", ""), "/", "-")

/proc/get_material_type_by_name(name)
	var/static/list/name2mat
	if(!name2mat)
		name2mat = list()
		for(var/type in subtypesof(/obj/item/stack/sheet))
			var/obj/item/stack/sheet/mat = type
			if(!initial(mat.name))
				continue
			name2mat[lowertext(initial(mat.name))] = mat
	return name2mat[name]

/datum/autolathe_recipe
	var/name
	var/category
	var/result_type
	var/list/resources
	var/max_res_amount = 1

/datum/autolathe_recipe/stack
	max_res_amount = 50

#define CATEGORY_GENERAL     "General"
#define CATEGORY_TOOLS       "Tools"
#define CATEGORY_MEDICAL     "Medical"
#define CATEGORY_ENGINEERING "Engineering"
#define CATEGORY_AMMO        "Ammo"
#define CATEGORY_DEVICES     "Devices"
#define CATEGORY_MATERIALS   "Materials"

/proc/path_to_ar(obj/path, category_name = CATEGORY_GENERAL)
	var/obj/P = path
	var/amount = 1
	var/datum/autolathe_recipe/recipe
	if(ispath(path, /obj/item/stack))
		recipe = new /datum/autolathe_recipe/stack
		var/obj/item/stack/PS = path
		recipe.max_res_amount = initial(PS.max_amount)
	else
		recipe = new /datum/autolathe_recipe
		if(ispath(path, /obj/item/ammo_box))
			var/obj/item/ammo_box/ammobox = path
			amount = initial(ammobox.max_ammo)
			P = initial(ammobox.ammo_type)
	recipe.name = initial(path.name)
	recipe.category = category_name
	recipe.result_type = path
	recipe.resources = list(
		MAT_METAL = initial(P.m_amt) * amount,
		MAT_GLASS = initial(P.g_amt) * amount,
	)
	return recipe

#define R(path, category_name) path_to_ar(path, category_name)
var/global/list/datum/autolathe_recipe/autolathe_recipes = list(
	R(/obj/item/weapon/crowbar,     CATEGORY_TOOLS),
	R(/obj/item/device/multitool,   CATEGORY_TOOLS),
	R(/obj/item/device/t_scanner,   CATEGORY_TOOLS),
	R(/obj/item/weapon/weldingtool, CATEGORY_TOOLS),
	R(/obj/item/weapon/screwdriver, CATEGORY_TOOLS),
	R(/obj/item/weapon/wirecutters, CATEGORY_TOOLS),
	R(/obj/item/weapon/wrench,      CATEGORY_TOOLS),
	R(/obj/item/weapon/shovel,      CATEGORY_TOOLS),
	R(/obj/item/weapon/minihoe,     CATEGORY_TOOLS),
	R(/obj/item/weapon/scalpel,                               CATEGORY_MEDICAL),
	R(/obj/item/weapon/circular_saw,                          CATEGORY_MEDICAL),
	R(/obj/item/weapon/surgicaldrill,                         CATEGORY_MEDICAL),
	R(/obj/item/weapon/retractor,                             CATEGORY_MEDICAL),
	R(/obj/item/weapon/cautery,                               CATEGORY_MEDICAL),
	R(/obj/item/weapon/hemostat,                              CATEGORY_MEDICAL),
	R(/obj/item/weapon/reagent_containers/food/drinks/drinkingglass, CATEGORY_MEDICAL),
	R(/obj/item/weapon/reagent_containers/glass/beaker,       CATEGORY_MEDICAL),
	R(/obj/item/weapon/reagent_containers/glass/beaker/large, CATEGORY_MEDICAL),
	R(/obj/item/weapon/reagent_containers/glass/beaker/vial,  CATEGORY_MEDICAL),
	R(/obj/item/weapon/reagent_containers/syringe,            CATEGORY_MEDICAL),
	R(/obj/item/clothing/accessory/stethoscope,               CATEGORY_MEDICAL),
	R(/obj/item/weapon/storage/pill_bottle,                   CATEGORY_MEDICAL),
	R(/obj/item/stack/cable_coil/random,             CATEGORY_ENGINEERING),
	R(/obj/item/weapon/module/power_control,         CATEGORY_ENGINEERING),
	R(/obj/item/weapon/airlock_electronics,          CATEGORY_ENGINEERING),
	R(/obj/item/weapon/airalarm_electronics,         CATEGORY_ENGINEERING),
	R(/obj/item/weapon/firealarm_electronics,        CATEGORY_ENGINEERING),
	R(/obj/item/weapon/rcd_ammo,                     CATEGORY_ENGINEERING),
	R(/obj/item/weapon/camera_assembly,              CATEGORY_ENGINEERING),
	R(/obj/item/conveyor_construct,                  CATEGORY_ENGINEERING),
	R(/obj/item/conveyor_switch_construct,           CATEGORY_ENGINEERING),
	R(/obj/item/weapon/table_parts/stall,            CATEGORY_ENGINEERING),
	R(/obj/item/weapon/stock_parts/console_screen,  CATEGORY_ENGINEERING),
	R(/obj/item/weapon/stock_parts/matter_bin,      CATEGORY_ENGINEERING),
	R(/obj/item/weapon/stock_parts/micro_laser,     CATEGORY_ENGINEERING),
	R(/obj/item/weapon/stock_parts/manipulator,     CATEGORY_ENGINEERING),
	R(/obj/item/weapon/stock_parts/capacitor,       CATEGORY_ENGINEERING),
	R(/obj/item/weapon/stock_parts/scanning_module, CATEGORY_ENGINEERING),
	R(/obj/item/ammo_box/eight_shells/beanbag,     CATEGORY_AMMO),
	R(/obj/item/ammo_box/magazine/colt/rubber,     CATEGORY_AMMO),
	R(/obj/item/ammo_box/magazine/glock/rubber,    CATEGORY_AMMO),
	R(/obj/item/ammo_box/speedloader/c38,          CATEGORY_AMMO),
	R(/obj/item/device/taperecorder,         CATEGORY_DEVICES),
	R(/obj/item/device/assembly/igniter,     CATEGORY_DEVICES),
	R(/obj/item/device/assembly/signaler,    CATEGORY_DEVICES),
	R(/obj/item/device/radio/headset,        CATEGORY_DEVICES),
	R(/obj/item/device/assembly/voice,       CATEGORY_DEVICES),
	R(/obj/item/device/radio/off,            CATEGORY_DEVICES),
	R(/obj/item/device/assembly/infra,       CATEGORY_DEVICES),
	R(/obj/item/device/assembly/timer,       CATEGORY_DEVICES),
	R(/obj/item/device/assembly/prox_sensor, CATEGORY_DEVICES),
	R(/obj/item/device/flashlight,           CATEGORY_DEVICES),
	R(/obj/item/device/tagger/shop,          CATEGORY_DEVICES),
	R(/obj/item/device/cardpay,              CATEGORY_DEVICES),
	R(/obj/item/device/analyzer,             CATEGORY_DEVICES),
	R(/obj/item/device/plant_analyzer,       CATEGORY_DEVICES),
	R(/obj/item/device/healthanalyzer,       CATEGORY_DEVICES),
	R(/obj/item/stack/sheet/metal,       CATEGORY_MATERIALS),
	R(/obj/item/stack/sheet/glass,       CATEGORY_MATERIALS),
	R(/obj/item/stack/sheet/rglass,      CATEGORY_MATERIALS),
	R(/obj/item/stack/rods,              CATEGORY_MATERIALS),
	R(/obj/item/weapon/reagent_containers/glass/bucket,       CATEGORY_GENERAL),
	R(/obj/item/weapon/kitchen/utensil/spoon,                 CATEGORY_GENERAL),
	R(/obj/item/weapon/kitchen/utensil/fork,                  CATEGORY_GENERAL),
	R(/obj/item/weapon/reagent_containers/spray/extinguisher, CATEGORY_GENERAL),
	R(/obj/item/weapon/storage/visuals/tray,                  CATEGORY_GENERAL),
	R(/obj/item/clothing/head/welding,                        CATEGORY_GENERAL),
	R(/obj/item/weapon/kitchenknife,                          CATEGORY_GENERAL),
	R(/obj/item/weapon/light/tube,                            CATEGORY_GENERAL),
	R(/obj/item/weapon/light/tube/smart,                      CATEGORY_GENERAL),
	R(/obj/item/weapon/light/bulb,                            CATEGORY_GENERAL),
	R(/obj/item/ashtray/glass,                                CATEGORY_GENERAL),
	R(/obj/item/toy/gun,                                      CATEGORY_GENERAL),
	R(/obj/item/toy/ammo/gun,                                 CATEGORY_GENERAL),
	R(/obj/item/weapon/game_kit/random,                       CATEGORY_GENERAL),
	R(/obj/item/newscaster_frame,                             CATEGORY_GENERAL),
	R(/obj/item/device/tabletop_assistant,                    CATEGORY_GENERAL),
)

var/global/list/datum/autolathe_recipe/autolathe_recipes_hidden = list(
	R(/obj/item/device/radio/electropack, CATEGORY_DEVICES),
	R(/obj/item/device/harmonica, CATEGORY_DEVICES),
	R(/obj/item/weapon/handcuffs, CATEGORY_GENERAL),
	R(/obj/item/weapon/bell, CATEGORY_GENERAL),
	R(/obj/item/device/tagger, CATEGORY_DEVICES),
	R(/obj/item/weapon/flamethrower/full, CATEGORY_TOOLS),
	R(/obj/item/weapon/rcd, CATEGORY_TOOLS),
	R(/obj/item/weapon/weldingtool/largetank, CATEGORY_TOOLS),
	R(/obj/item/ammo_casing/a357, CATEGORY_AMMO),
	R(/obj/item/ammo_box/magazine/stechkin, CATEGORY_AMMO),
	R(/obj/item/ammo_box/magazine/colt, CATEGORY_AMMO),
	R(/obj/item/ammo_box/magazine/glock, CATEGORY_AMMO),
	R(/obj/item/ammo_box/speedloader/c38m, CATEGORY_AMMO),
	R(/obj/item/ammo_box/eight_shells, CATEGORY_AMMO),
	R(/obj/item/ammo_box/eight_shells/buckshot, CATEGORY_AMMO),
	R(/obj/item/weapon/stock_parts/matter_bin/adv,      CATEGORY_ENGINEERING),
	R(/obj/item/weapon/stock_parts/micro_laser/high,    CATEGORY_ENGINEERING),
	R(/obj/item/weapon/stock_parts/manipulator/nano,    CATEGORY_ENGINEERING),
	R(/obj/item/weapon/stock_parts/capacitor/adv,       CATEGORY_ENGINEERING),
	R(/obj/item/weapon/stock_parts/scanning_module/adv, CATEGORY_ENGINEERING),

)
#undef R
var/global/list/datum/autolathe_recipe/autolathe_recipes_all = autolathe_recipes + autolathe_recipes_hidden

/obj/machinery/autolathe
	name = "autolathe"
	desc = "It produces items using metal and glass."
	icon_state = "autolathe"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	allowed_checks = ALLOWED_CHECK_TOPIC

	var/list/stored_material  = list(MAT_METAL = 0, MAT_GLASS = 0)
	var/list/storage_capacity = list(MAT_METAL = 0, MAT_GLASS = 0)

	var/hacked = FALSE
	var/disabled = FALSE
	var/shocked = FALSE
	var/datum/wires/autolathe/wires = null

	var/busy = FALSE
	var/man_rating

/obj/machinery/autolathe/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/autolathe(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()

	wires = new(src)

/obj/machinery/autolathe/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/autolathe/RefreshParts()
	..()

	var/mb_rating = 0
	man_rating = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/MB in component_parts)
		mb_rating += MB.rating
	mb_rating *= 25000
	storage_capacity[MAT_METAL] = mb_rating * 3
	storage_capacity[MAT_GLASS] = mb_rating * 3
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		man_rating += M.rating - 1

/obj/machinery/autolathe/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/autolathe/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Autolathe", "Autolathe")
		ui.open()

/obj/machinery/autolathe/tgui_status(mob/user)
	if(disabled)
		return STATUS_CLOSE
	return ..()

/obj/machinery/autolathe/tgui_data(mob/user, datum/tgui/ui)
	var/list/data = list()

	var/list/material_data = list()
	for(var/mat_id in stored_material)
		var/amount = stored_material[mat_id]
		var/list/material_info = list(
			"name" = mat_id,
			"amount" = amount,
			"path" = PATH2CSS(get_material_type_by_name(mat_id))
		)
		material_data += list(material_info)
	data["busy"] = busy
	data["materials"] = material_data
	return data

/obj/machinery/autolathe/tgui_static_data(mob/user)
	var/list/data = list()

	var/list/recipes = list()
	var/list/ARecipes = hacked ? autolathe_recipes_all : autolathe_recipes
	var/list/categories = list("All")
	for(var/datum/autolathe_recipe/AR in ARecipes)
		categories |= AR.category
		recipes.Add(list(list(
			"category" = AR.category,
			"name" = AR.name,
			"ref" = "\ref[AR]",
			"requirements" = AR.resources,
			"hidden" = (AR in autolathe_recipes_hidden),
			"path" = PATH2CSS(AR.result_type),
			"max_mult" = AR.max_res_amount
		)))
	data["recipes"] = recipes
	data["categories"] = categories
	data["coeff"] = 2 ** man_rating
	return data

/obj/machinery/autolathe/tgui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/autolathe),
		get_asset_datum(/datum/asset/spritesheet/sheetmaterials)
	)

/obj/machinery/autolathe/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if(electrocute_mob(user, get_area(src), src, 0.7))
		return 1
	else
		return 0

/obj/machinery/autolathe/interact(mob/user)
	if(shocked && !issilicon(user) && !isobserver(user))
		shock(user,50)
	if(disabled)
		to_chat(user, "<span class='warning'>You press the button, but nothing happens.</span>")
		return
	..()

/obj/machinery/autolathe/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/pai_cable))
		return
	if(busy)
		to_chat(user, "<span class='warning'>The autolathe is busy. Please wait for completion of previous operation.</span>")
		return 1

	if(default_deconstruction_screwdriver(user, "autolathe", "autolathe", I))
		update_icon()
		updateUsrDialog()
		return

	if(exchange_parts(user, I))
		return

	if(panel_open)
		if(isprying(I))
			default_deconstruction_crowbar(I)
			return 1
		else if(is_wire_tool(I))
			wires.interact(user)
			return 1

	if(stat)
		return 1

	var/amount = 1
	var/obj/item/stack/stack
	var/m_amt = I.m_amt
	var/g_amt = I.g_amt
	if(istype(I, /obj/item/stack))
		stack = I
		amount = stack.get_amount()
		if(m_amt)
			amount = min(amount, round((storage_capacity[MAT_METAL] - stored_material[MAT_METAL]) / m_amt))
			flick("[initial(icon_state)]_metal", src)
		if(g_amt)
			amount = min(amount, round((storage_capacity[MAT_GLASS] - stored_material[MAT_GLASS]) / g_amt))
			flick("[initial(icon_state)]_glass", src)
	else if(istype(I, /obj/item/ammo_box))
		m_amt = 0
		g_amt = 0
		var/obj/item/ammo_box/ammobox = I
		if(ammobox.stored_ammo.len)
			for(var/obj/item/ammo_casing/ammo_type in ammobox.stored_ammo)
				m_amt += ammo_type.m_amt
				g_amt += ammo_type.g_amt
	m_amt *= amount
	g_amt *= amount

	if((stored_material[MAT_METAL] + m_amt > storage_capacity[MAT_METAL]) || (stored_material[MAT_GLASS] + g_amt > storage_capacity[MAT_GLASS]))
		to_chat(user, "<span class='warning'>The autolathe is full. Please remove metal from the autolathe in order to insert more.</span>")
		return 1
	if(m_amt == 0 && g_amt == 0)
		to_chat(user, "<span class='warning'>This object does not contain significant amounts of metal or glass, or cannot be accepted by the autolathe due to size or hazardous materials.</span>")
		return 1

	take_item(I, amount)
	icon_state = "autolathe"
	busy = TRUE
	use_power(max(1000, (m_amt + g_amt) * amount / 10))
	stored_material[MAT_METAL] += m_amt
	stored_material[MAT_GLASS] += g_amt
	to_chat(user, "You insert [amount] sheet[amount>1 ? "s" : ""] to the autolathe.")
	if(I && I.loc == src)
		qdel(I)
	busy = FALSE
	updateUsrDialog()

/obj/machinery/autolathe/deconstruction()
	. = ..()
	if(stored_material[MAT_METAL] >= 3750)
		new /obj/item/stack/sheet/metal(loc, round(stored_material[MAT_METAL] / 3750))
	if(stored_material[MAT_GLASS] >= 3750)
		new /obj/item/stack/sheet/glass(loc, round(stored_material[MAT_GLASS] / 3750))

/obj/machinery/autolathe/update_icon()
	cut_overlays()
	if(panel_open)
		add_overlay("[initial(icon_state)]-open")
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/autolathe/power_change()
	..()
	update_icon()

/obj/machinery/autolathe/proc/take_item(obj/item/I, amount)
	if(istype(I, /obj/item/stack))
		var/obj/item/stack/S = I
		S.use(amount)
	else
		usr.remove_from_mob(I)
		I.loc = src

/obj/machinery/autolathe/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if (.)
		return

	if(ispAI(usr))
		var/mob/living/silicon/pai/TempUsr = usr
		if(TempUsr.hackobj != src)
			return
	if(busy)
		to_chat(usr, "<span class='warning'>The autolathe is busy. Please wait for completion of previous operation.</span>")
		return FALSE

	if(action == "make")
		var/coeff = 2 ** man_rating
		var/turf/T = get_turf(src)
		// critical exploit fix start -walter0o
		var/datum/autolathe_recipe/recipe = locate(params["make"])

		if(!istype(recipe))
			return FALSE

		var/list/datum/autolathe_recipe/recipes

		if(hacked)
			recipes = autolathe_recipes_all
		else
			recipes = autolathe_recipes

		if(!locate(recipe, recipes))
			return FALSE

		// now check for legit multiplier, also only stacks should pass with one to prevent raw-materials-manipulation -walter0o

		var/multiplier = text2num(params["multiplier"])

		if(!multiplier)
			multiplier = 1
		var/max_multiplier = 1

		if(istype(recipe, /datum/autolathe_recipe/stack)) // stacks are the only items which can have a multiplier higher than 1 -walter0o
			max_multiplier = min(recipe.max_res_amount,
				recipe.resources[MAT_METAL] ? round(stored_material[MAT_METAL] / recipe.resources[MAT_METAL]) : INFINITY,
				recipe.resources[MAT_GLASS] ? round(stored_material[MAT_GLASS] / recipe.resources[MAT_GLASS]) : INFINITY)

		if((multiplier > max_multiplier) || (multiplier <= 0)) // somebody is trying to exploit, alert admins-walter0o

			var/turf/LOC = get_turf(usr)
			message_admins("[key_name_admin(usr)] tried to exploit an autolathe with multiplier set to <u>[multiplier]</u> on <u>[recipe]</u>  ! ([LOC ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[LOC.x];Y=[LOC.y];Z=[LOC.z]'>JMP</a>" : "null"])" , 0)
			log_admin("EXPLOIT : [key_name(usr)] tried to exploit an autolathe with multiplier set to [multiplier] on [recipe]  !")
			return FALSE

		var/power = max(2000, (recipe.resources[MAT_METAL] + recipe.resources[MAT_GLASS]) * multiplier / 5)
		if(stored_material[MAT_METAL] >= recipe.resources[MAT_METAL] * multiplier / coeff && stored_material[MAT_GLASS] >= recipe.resources[MAT_GLASS] * multiplier / coeff)
			busy = TRUE
			use_power(power)
			icon_state = "autolathe"
			flick("autolathe_n",src)
			spawn(32/coeff)
				if(istype(recipe, /datum/autolathe_recipe/stack))
					stored_material[MAT_METAL] -= recipe.resources[MAT_METAL] * multiplier
					stored_material[MAT_GLASS] -= recipe.resources[MAT_GLASS] * multiplier
					new recipe.result_type(T, multiplier)
				else
					stored_material[MAT_METAL] -= recipe.resources[MAT_METAL] / coeff
					stored_material[MAT_GLASS] -= recipe.resources[MAT_GLASS] / coeff
					var/obj/new_item = new recipe.result_type(T)
					new_item.m_amt /= coeff
					new_item.g_amt /= coeff
				if(stored_material[MAT_METAL] < 0)
					stored_material[MAT_METAL] = 0
				if(stored_material[MAT_GLASS] < 0)
					stored_material[MAT_GLASS] = 0
				busy = FALSE
	updateUsrDialog()
#undef PATH2CSS
