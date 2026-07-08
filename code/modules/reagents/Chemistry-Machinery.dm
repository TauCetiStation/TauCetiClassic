#define MAX_PILL_SPRITE 24
#define MAX_BOTTLE_SPRITE 3

/obj/machinery/chem_dispenser
	name = "chem dispenser"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	active_power_usage = 600
	var/ui_title = "Chem Dispenser 5000"
	var/amount = 30
	var/accept_glass = 0
	var/obj/item/weapon/reagent_containers/beaker = null
	var/obj/item/weapon/reagent_containers/bio_supplements_cartridge/cartridge = null
	var/hackedcheck = FALSE
	var/hackable = FALSE
	var/msg_hack_enable = ""
	var/msg_hack_disable = ""
	var/list/dispensable_reagents = list(
		"hydrogen", "lithium", "carbon", "nitrogen", "oxygen", "fluorine",
		"sodium", "aluminum", "silicon", "phosphorus", "sulfur", "chlorine", "potassium", "iron",
		"copper", "mercury", "radium", "water", "ethanol", "sugar", "sacid", "tungsten"
	)
	var/list/premium_reagents = list()
	required_skills = list(/datum/skill/chemistry = SKILL_LEVEL_TRAINED)
	fumbling_time = 2 SECONDS

	var/list/bio_cost_low = list("aluminum", "copper", "hydrogen", "mercury", "phosphorus", "sacid", "sugar", "water")
	var/list/bio_cost_high = list("chlorine", "fluorine", "lithium", "oxygen", "radium", "sodium", "tungsten")

/obj/machinery/chem_dispenser/atom_init()
	. = ..()
	dispensable_reagents = sortList(dispensable_reagents)
	cartridge = new /obj/item/weapon/reagent_containers/bio_supplements_cartridge(src)

/obj/machinery/chem_dispenser/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(cartridge)
	return ..()

/obj/machinery/chem_dispenser/power_change()
	if(anchored && powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
			update_power_use()
	update_power_use()

/obj/machinery/chem_dispenser/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
		if(EXPLODE_LIGHT)
			return
	qdel(src)

/obj/machinery/chem_dispenser/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/chem_dispenser/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemDispenser", ui_title)
		ui.open()

/obj/machinery/chem_dispenser/tgui_data(mob/user)
	var/list/data = list()
	data["amount"] = amount
	data["isBeakerLoaded"] = beaker ? 1 : 0
	data["glass"] = accept_glass
	data["cartridgeLoaded"] = cartridge ? 1 : 0
	data["cartridgeOk"] = cartridge && cartridge.reagents && cartridge.reagents.has_reagent("bio_supplements")
	if(cartridge)
		data["cartridgeName"] = cartridge.name
		data["cartridgeVolume"] = cartridge.reagents.total_volume
		data["cartridgeMaxVolume"] = cartridge.volume
	var/list/beakerContents = list()
	var/beakerCurrentVolume = 0
	if(beaker?.reagents?.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
			beakerCurrentVolume += R.volume
	data["beakerContents"] = beakerContents

	if (beaker)
		data["beakerCurrentVolume"] = beakerCurrentVolume
		data["beakerMaxVolume"] = beaker.volume
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null

	var/list/chemicals = list()
	for (var/re in dispensable_reagents)
		var/datum/reagent/temp = chemical_reagents_list[re]
		if(temp)
			chemicals.Add(list(list("title" = temp.name, "id" = temp.id))) // list in a list because Byond merges the first list...
	data["chemicals"] = chemicals
	return data

/obj/machinery/chem_dispenser/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return
	switch(action)
		if("change_amount")
			. = TRUE
			var/new_amount = clamp(round(text2num(params["new_amount"])), 0, 100)
			if(amount == new_amount)
				return

			amount = new_amount

			if(iscarbon(usr))
				playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MISC, 20)

		if("dispense")
			. = TRUE
			if (!beaker || !dispensable_reagents.Find(params["chemical"]))
				return
			if(!cartridge || !cartridge.reagents.has_reagent("bio_supplements"))
				return

			var/datum/reagents/R = beaker.reagents
			var/space = R.maximum_volume - R.total_volume
			var/bio_available = cartridge.reagents.get_reagent_amount("bio_supplements")
			var/bio_cost = 0.1
			var/power_cost = 0
			var/chem = params["chemical"]
			if(chem in bio_cost_low)
				bio_cost = 0.05
				power_cost = 25
			else if(chem in bio_cost_high)
				bio_cost = 0.2
			else
				power_cost = 5

			if(iscarbon(usr))
				playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MISC, 20)

			var/dispense_amount = min(amount, round(bio_available / bio_cost), space)
			if(dispense_amount > 0)
				playsound(src, 'sound/effects/Liquid_transfer_mono.ogg', VOL_EFFECTS_MASTER, 40)

			R.add_reagent(chem, dispense_amount)
			cartridge.reagents.remove_reagent("bio_supplements", round(dispense_amount * bio_cost))

			if(power_cost > 0)
				use_power(dispense_amount * power_cost)
			SStgui.update_uis(src)

		if("eject_beaker")
			. = TRUE
			if(!beaker)
				return

			beaker.forceMove(loc)
			beaker = null
			SStgui.update_uis(src)

			if(iscarbon(usr))
				playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MISC, 20)

			playsound(src, 'sound/items/insert_key.ogg', VOL_EFFECTS_MASTER, 25)

		if("eject_cartridge")
			. = TRUE
			if(!cartridge)
				return

			cartridge.forceMove(loc)
			cartridge = null
			SStgui.update_uis(src)

			if(iscarbon(usr))
				playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MISC, 20)

			playsound(src, 'sound/items/insert_key.ogg', VOL_EFFECTS_MASTER, 25)

/obj/machinery/chem_dispenser/attackby(obj/item/weapon/B, mob/user)
//	if(isrobot(user))
//		return
	if(ispulsing(B) && hackable)
		hackedcheck = !hackedcheck
		if(hackedcheck)
			to_chat(user, msg_hack_enable)
			dispensable_reagents += premium_reagents
		else
			to_chat(user, msg_hack_disable)
			dispensable_reagents -= premium_reagents
		return
	if(default_unfasten_wrench(user, B))
		power_change()
		return

	if(istype(B, /obj/item/weapon/reagent_containers/bio_supplements_cartridge))
		if(cartridge)
			to_chat(user, "\The [src] already has a cartridge loaded.")
			return
		cartridge = B
		user.drop_from_inventory(B, src)
		to_chat(user, "You insert [B] into \the [src].")
		playsound(src, 'sound/items/insert_key.ogg', VOL_EFFECTS_MASTER, 25)
		SStgui.update_uis(src)
		return

	if(src.beaker)
		to_chat(user, "Something is already loaded into the machine.")
		return
	if(istype(B, /obj/item/weapon/reagent_containers/glass) || istype(B, /obj/item/weapon/reagent_containers/food))
		if(!accept_glass && istype(B,/obj/item/weapon/reagent_containers/food))
			to_chat(user, "<span class='notice'>This machine only accepts beakers</span>")
			return
		if(istype(B, /obj/item/weapon/reagent_containers/food/drinks/cans))
			var/obj/item/weapon/reagent_containers/food/drinks/cans/C = B
			if(!C.canopened)
				to_chat(user, "<span class='notice'>You need to open the drink!</span>")
				return
		if(!do_skill_checks(user))
			return
		src.beaker =  B
		user.drop_from_inventory(B, src)
		to_chat(user, "You set [B] on the machine.")
		playsound(src, 'sound/items/insert_key.ogg', VOL_EFFECTS_MASTER, 25)
		SStgui.update_uis(src)
		return
	return ..()

/obj/machinery/chem_dispenser/old/atom_init()
	. = ..()
	make_old()

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_dispenser/constructable
	name = "portable chem dispenser"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "minidispenser"
	amount = 5
	dispensable_reagents = list()
	var/list/dispensable_reagent_tiers = list(
		list(
				"hydrogen",
				"oxygen",
				"silicon",
				"phosphorus",
				"sulfur",
				"carbon",
				"nitrogen",
				"water"
		),
		list(
				"lithium",
				"sugar",
				"sacid",
				"copper",
				"mercury",
				"sodium"
		),
		list(
				"ethanol",
				"chlorine",
				"potassium",
				"aluminum",
				"radium",
				"fluorine",
				"iron",
				"fuel",
				"silver"
		),
		list(
				"ammonia",
				"diethylamine"
		)
	)
	required_skills = list(/datum/skill/chemistry = SKILL_LEVEL_NOVICE)

/obj/machinery/chem_dispenser/constructable/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/chem_dispenser(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/cell/high(null)
	RefreshParts()

/obj/machinery/chem_dispenser/constructable/RefreshParts()
	..()

	var/i
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		for(i=1, i<=M.rating, i++)
			dispensable_reagents |= dispensable_reagent_tiers[i]
	dispensable_reagents = sortList(dispensable_reagents)

/obj/machinery/chem_dispenser/constructable/attackby(obj/item/I, mob/user)
	..()
	if(default_deconstruction_screwdriver(user, "minidispenser-o", "minidispenser", I))
		return

	if(exchange_parts(user, I))
		return

	if(panel_open)
		if(isprying(I))
			if(beaker)
				var/obj/item/weapon/reagent_containers/glass/B = beaker
				B.loc = loc
				beaker = null
			default_deconstruction_crowbar(I)
			return TRUE

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_dispenser/soda
	icon_state = "soda_dispenser"
	name = "soda fountain"
	desc = "A drink fabricating machine, capable of producing many sugary drinks with just one touch."
	ui_title = "Soda Dispens-o-matic"
	accept_glass = 1
	dispensable_reagents = list("water","ice","coffee","cream","tea","icetea","cola","spacemountainwind","dr_gibb","space_up","tonic","sodawater","lemon_lime","sugar","orangejuice","limejuice","watermelonjuice")
	premium_reagents = list("thirteenloko","grapesoda")
	hackable = TRUE
	msg_hack_enable = "You change the mode from 'McNano' to 'Pizza King'."
	msg_hack_disable = "You change the mode from 'Pizza King' to 'McNano'."
	required_skills = list()
	resistance_flags = FULL_INDESTRUCTIBLE

/obj/machinery/chem_dispenser/beer
	icon_state = "booze_dispenser"
	name = "booze dispenser"
	ui_title = "Booze Portal 9001"
	accept_glass = 1
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	dispensable_reagents = list("lemon_lime","sugar","orangejuice","limejuice","sodawater","tonic","beer","kahlua","whiskey","wine","vodka","gin","rum","tequilla","vermouth","cognac","ale","mead")
	premium_reagents = list("goldschlager","patron","watermelonjuice","berryjuice")
	hackable = TRUE
	msg_hack_enable = "You disable the 'nanotrasen-are-cheap-bastards' lock, enabling hidden and very expensive boozes."
	msg_hack_disable = "You re-enable the 'nanotrasen-are-cheap-bastards' lock, disabling hidden and very expensive boozes."
	required_skills = list()
	resistance_flags = FULL_INDESTRUCTIBLE
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_master
	name = "ChemMaster 3000"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 500
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/obj/item/weapon/storage/pill_bottle/loaded_pill_bottle = null
	var/mode = 1
	var/condi = 0
	var/useramount = 30 // Last used amount
	var/pillamount = 10
	var/bottlesprite = 1
	var/pillsprite = 1
	var/max_pill_count = 24
	required_skills = list(/datum/skill/chemistry = SKILL_LEVEL_TRAINED)

	// Temperature control
	var/temperature = T20C
	var/heater_mode = 0  // 0=off, 1=heating, 2=cooling
	var/const/MAX_HEATING_TEMP = 500
	var/const/MIN_COOLING_TEMP = 200
	var/const/TEMP_CHANGE_RATE = 10  // K per process tick

	var/list/pill_icon_cache
	var/list/bottle_icon_cache
	var/sprite_icons_loaded = FALSE


/obj/machinery/chem_master/atom_init()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(150)
	reagents = R
	R.my_atom = src

/obj/machinery/chem_master/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
		if(EXPLODE_LIGHT)
			return
	qdel(src)

/obj/machinery/chem_master/power_change()
	if(anchored && powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
			update_power_use()
	update_power_use()

/obj/machinery/chem_master/process()
	if(heater_mode == 1)
		if(temperature < MAX_HEATING_TEMP)
			temperature = min(temperature + TEMP_CHANGE_RATE, MAX_HEATING_TEMP)
		use_power(active_power_usage)
	else if(heater_mode == 2)
		if(temperature > MIN_COOLING_TEMP)
			temperature = max(temperature - TEMP_CHANGE_RATE, MIN_COOLING_TEMP)
		use_power(active_power_usage)
	else
		if(abs(temperature - T20C) < 1)
			temperature = T20C
		else if(temperature > T20C)
			temperature = max(temperature - TEMP_CHANGE_RATE * 0.5, T20C)
		else
			temperature = min(temperature + TEMP_CHANGE_RATE * 0.5, T20C)

	SStgui.update_uis(src)

/obj/machinery/chem_master/attackby(obj/item/B, mob/user)

	if(default_unfasten_wrench(user, B))
		power_change()
		return

	if(istype(B, /obj/item/weapon/reagent_containers/glass))
		if(src.beaker)
			to_chat(user, "<span class='alert'>A beaker is already loaded into the machine.</span>")
			return
		src.beaker = B
		user.drop_from_inventory(B, src)
		to_chat(user, "You add the beaker to the machine!")
		SStgui.update_uis(src)
		icon_state = "mixer1"

	else if(!condi && istype(B, /obj/item/weapon/storage/pill_bottle))
		if(src.loaded_pill_bottle)
			to_chat(user, "<span class='alert'>A pill bottle is already loaded into the machine.</span>")
			return

		src.loaded_pill_bottle = B
		user.drop_from_inventory(B, src)
		to_chat(user, "You add the pill bottle into the dispenser slot!")
		SStgui.update_uis(src)

	return

/obj/machinery/chem_master/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/chem_master/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemMaster", name)
		ui.open()

/obj/machinery/chem_master/tgui_data(mob/user)
	var/list/data = list()

	data["condi"] = condi

	// Temperature
	data["temperature"] = round(temperature)
	data["temperature_c"] = round(temperature - T0C)
	data["heater_mode"] = heater_mode

	// Beaker
	data["beaker_loaded"] = !!beaker
	if(beaker)
		data["beaker_volume"] = beaker.reagents.total_volume
		data["beaker_max"] = beaker.volume
		var/list/beaker_reagents = list()
		for(var/datum/reagent/G in beaker.reagents.reagent_list)
			beaker_reagents += list(list(
				"id" = G.id,
				"reagent_ref" = "\ref[G]",
				"name" = G.name,
				"volume" = G.volume
			))
		data["beaker_reagents"] = beaker_reagents

	// Buffer
	data["buffer_volume"] = reagents.total_volume
	data["buffer_max"] = reagents.maximum_volume
	data["mode"] = mode
	var/list/buffer_reagents = list()
	for(var/datum/reagent/N in reagents.reagent_list)
		buffer_reagents += list(list(
			"id" = N.id,
			"reagent_ref" = "\ref[N]",
			"name" = N.name,
			"volume" = N.volume
		))
	data["buffer_reagents"] = buffer_reagents

	// Pill bottle
	data["pill_bottle_loaded"] = !!loaded_pill_bottle
	if(loaded_pill_bottle)
		data["pill_bottle_count"] = loaded_pill_bottle.contents.len
		data["pill_bottle_max"] = loaded_pill_bottle.storage_slots

	// Sprites
	data["pillsprite"] = pillsprite
	data["bottlesprite"] = bottlesprite
	data["max_pill_sprite"] = MAX_PILL_SPRITE
	data["max_bottle_sprite"] = MAX_BOTTLE_SPRITE

	// Icon cache (only sent when sprite picker opened)
	if(sprite_icons_loaded)
		if(!pill_icon_cache)
			pill_icon_cache = list()
			for(var/i = 1 to MAX_PILL_SPRITE)
				var/icon/pill = icon('icons/obj/chemical.dmi', "pill[i]")
				pill.Blend("#ffffff", ICON_UNDERLAY)
				pill_icon_cache["[i]"] = icon2base64(pill)
		if(!bottle_icon_cache)
			bottle_icon_cache = list()
			for(var/i = 1 to MAX_BOTTLE_SPRITE)
				var/icon/bottle = icon('icons/obj/chemical.dmi', "bottle[i]")
				bottle.Blend("#ffffff", ICON_UNDERLAY)
				bottle_icon_cache["[i]"] = icon2base64(bottle)
		data["pill_icons"] = pill_icon_cache
		data["bottle_icons"] = bottle_icon_cache

	return data

/obj/machinery/chem_master/tgui_act(action, params)
	. = ..()
	if(.)
		return

	var/mob/user = usr
	if(isnull(user))
		return

	switch(action)
		if("load_sprite_icons")
			sprite_icons_loaded = TRUE
			SStgui.update_uis(src)
			return TRUE

		if("eject")
			if(beaker)
				beaker.forceMove(loc)
				beaker = null
				reagents.clear_reagents()
				icon_state = "mixer0"
			SStgui.update_uis(src)
			return TRUE

		if("ejectp")
			if(loaded_pill_bottle)
				loaded_pill_bottle.forceMove(loc)
				loaded_pill_bottle = null
			SStgui.update_uis(src)
			return TRUE

		if("heat")
			heater_mode = 1
			SStgui.update_uis(src)
			return TRUE

		if("cool")
			heater_mode = 2
			SStgui.update_uis(src)
			return TRUE

		if("heatoff")
			heater_mode = 0
			SStgui.update_uis(src)
			return TRUE

		if("toggle")
			mode = !mode
			SStgui.update_uis(src)
			return TRUE

		if("add")
			var/id = params["id"]
			var/amount = text2num(params["amount"])
			if(amount > 0 && beaker)
				beaker.reagents.trans_id_to(src, id, amount)
			SStgui.update_uis(src)
			return TRUE

		if("addcustom")
			var/id = params["id"]
			var/amt_temp = input(user, "Select the amount to transfer.", "Transfer how much?", useramount) as num|null
			if(!amt_temp)
				return FALSE
			useramount = clamp(round(amt_temp), 0, 300)
			if(beaker)
				beaker.reagents.trans_id_to(src, id, useramount)
			SStgui.update_uis(src)
			return TRUE

		if("remove")
			var/id = params["id"]
			var/amount = text2num(params["amount"])
			if(amount > 0)
				if(mode)
					if(beaker)
						reagents.trans_id_to(beaker, id, amount)
				else
					reagents.remove_reagent(id, amount)
			SStgui.update_uis(src)
			return TRUE

		if("removecustom")
			var/id = params["id"]
			var/amt_temp = input(user, "Select the amount to transfer.", "Transfer how much?", useramount) as num|null
			if(!amt_temp)
				return FALSE
			useramount = clamp(round(amt_temp), 0, 300)
			if(mode)
				if(beaker)
					reagents.trans_id_to(beaker, id, useramount)
			else
				reagents.remove_reagent(id, useramount)
			SStgui.update_uis(src)
			return TRUE

		if("createpill")
			if(reagents.total_volume == 0)
				return FALSE
			if(!condi)
				var/amount = 1
				var/vol_each = min(reagents.total_volume, 50)
				if(text2num(params["many"]))
					amount = min(max(round(input(user, "Max 10. Buffer content will be split evenly.", "How many pills?", amount) as num|null), 0), 10)
					if(!amount)
						return FALSE
					vol_each = min(reagents.total_volume / amount, 50)
				var/name = sanitize_safe(input(user, "Name:", "Name your pill!", "[reagents.get_master_reagent_name()] ([vol_each]u)") as text|null, MAX_NAME_LEN)
				if(!name || !reagents.total_volume)
					return FALSE
				var/obj/item/weapon/reagent_containers/pill/P
				for(var/i = 0; i < amount; i++)
					if(loaded_pill_bottle && loaded_pill_bottle.contents.len < loaded_pill_bottle.storage_slots)
						P = new/obj/item/weapon/reagent_containers/pill(loaded_pill_bottle)
					else
						P = new/obj/item/weapon/reagent_containers/pill(loc)
					P.name = "[name] pill"
					P.icon_state = "pill[pillsprite]"
					P.pixel_x = rand(-7, 7)
					P.pixel_y = rand(-7, 7)
					reagents.trans_to(P, vol_each)
			else
				if(beaker && reagents.total_volume)
					var/obj/item/weapon/reagent_containers/food/condiment/P = new(loc)
					reagents.trans_to(P, 50)
			SStgui.update_uis(src)
			return TRUE

		if("createbottle")
			if(!condi)
				var/name = sanitize_safe(input(user, "Name:", "Name your bottle!", (reagents.total_volume ? reagents.get_master_reagent_name() : " ")) as text|null, MAX_NAME_LEN)
				if(!name)
					return FALSE
				var/amount = 1
				if(text2num(params["bulk"]))
					amount = ceil(reagents.total_volume / 30)
				for(var/i in 1 to amount)
					var/obj/item/weapon/reagent_containers/glass/bottle/P = new(loc)
					P.name = "[name] bottle"
					P.icon_state = "bottle[bottlesprite]"
					P.pixel_x = rand(-7, 7)
					P.pixel_y = rand(-7, 7)
					reagents.trans_to(P, 30)
			else
				if(text2num(params["bulk"]))
					to_chat(user, "Sorry! \"CondiMaster Neo\" DRM forbids mass production. Please contact our support to upgrade your license.")
				else
					var/obj/item/weapon/reagent_containers/food/condiment/P = new(loc)
					reagents.trans_to(P, 50)
			SStgui.update_uis(src)
			return TRUE

		if("set_pillsprite")
			pillsprite = clamp(text2num(params["value"]), 1, MAX_PILL_SPRITE)
			SStgui.update_uis(src)
			return TRUE

		if("set_bottlesprite")
			bottlesprite = clamp(text2num(params["value"]), 1, MAX_BOTTLE_SPRITE)
			SStgui.update_uis(src)
			return TRUE

		if("analyze")
			var/ref = params["reagent_ref"]
			if(ref)
				var/datum/reagent/R = locate(ref)
				if(R)
					var/dat = ""
					dat += "<H1>[condi ? "Condiment" : "Chemical"] information:</H1>"
					dat += "<B>Name:</B> [initial(R.name)]<BR><BR>"
					dat += "<B>State:</B> "
					if(initial(R.reagent_state) == SOLID)
						dat += "Solid"
					else if(initial(R.reagent_state) == LIQUID)
						dat += "Liquid"
					else if(initial(R.reagent_state) == GAS)
						dat += "Gas"
					else
						dat += "Unknown"
					dat += "<BR>"
					dat += "<B>Color:</B> <span style='color:[initial(R.color)];background-color:[initial(R.color)];font:Lucida Console'>[initial(R.color)]</span><BR><BR>"
					dat += "<B>Description:</B> [initial(R.description)]<BR><BR>"
					if(initial(R.name) == "Blood")
						var/datum/reagent/blood/G = R
						var/A = G.data["blood_type"]
						var/B = G.data["blood_DNA"]
						dat += "<B>Blood Type:</B> [A]<br>"
						dat += "<B>DNA:</B> [B]<BR><BR><BR>"
					var/const/P = 3
					var/T = initial(R.custom_metabolism) * (60 / P)
					dat += "<B>Metabolization Rate:</B> [T]u/minute<BR>"
					dat += "<B>Overdose Threshold:</B> [initial(R.overdose) ? "[initial(R.overdose)]u" : "none"]<BR>"
					var/datum/browser/popup = new(user, "chem_master_analyze", name)
					popup.set_content(dat)
					popup.open()
			return TRUE

	return FALSE


/obj/machinery/chem_master/condimaster
	name = "CondiMaster 3000"
	condi = 1
	required_skills = list(/datum/skill/chemistry = SKILL_LEVEL_NOVICE)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_master/constructable
	name = "ChemMaster 2999"
	desc = "Used to seperate chemicals and distribute them in a variety of forms."
	required_skills = list(/datum/skill/chemistry = SKILL_LEVEL_TRAINED)

/obj/machinery/chem_master/constructable/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/chem_master(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(null)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(null)

/obj/machinery/chem_master/constructable/attackby(obj/item/B, mob/user, params)

	if(default_deconstruction_screwdriver(user, "mixer0_nopower", "mixer0_", B))
		if(beaker)
			beaker.loc = src.loc
			beaker = null
			reagents.clear_reagents()
		if(loaded_pill_bottle)
			loaded_pill_bottle.loc = src.loc
			loaded_pill_bottle = null
		return

	if(exchange_parts(user, B))
		return

	if(panel_open)
		if(isprying(B))
			default_deconstruction_crowbar(B)
			return TRUE
		else
			to_chat(user, "<span class='warning'>You can't use the [src.name] while it's panel is opened.</span>")
			return TRUE

	if(istype(B, /obj/item/weapon/reagent_containers/glass))
		if(src.beaker)
			to_chat(user, "<span class='alert'>A beaker is already loaded into the machine.</span>")
			return
		src.beaker = B
		user.drop_from_inventory(B, src)
		to_chat(user, "You add the beaker to the machine!")
		SStgui.update_uis(src)
		icon_state = "mixer1"

	else if(!condi && istype(B, /obj/item/weapon/storage/pill_bottle))
		if(src.loaded_pill_bottle)
			to_chat(user, "<span class='alert'>A pill bottle is already loaded into the machine.</span>")
			return
		src.loaded_pill_bottle = B
		user.drop_from_inventory(B, src)
		to_chat(user, "You add the pill bottle into the dispenser slot!")
		SStgui.update_uis(src)

	return

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/obj/machinery/reagentgrinder

	name = "All-In-One Grinder"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = 2.9
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	pass_flags = PASSTABLE
	var/speed = 1
	var/inuse = FALSE
	var/obj/item/weapon/reagent_containers/beaker = null
	var/limit = 10
	var/list/blend_items = list (
		//Sheets,
		/obj/item/stack/sheet/mineral/phoron = list("phoron" = 20),
		/obj/item/stack/sheet/mineral/uranium = list("uranium" = 20),
		/obj/item/stack/sheet/mineral/clown = list("banana" = 20),
		/obj/item/stack/sheet/mineral/silver = list("silver" = 20),
		/obj/item/stack/sheet/mineral/gold = list("gold" = 20),
		/obj/item/weapon/grown/nettle = list("sacid" = 0),
		/obj/item/weapon/grown/deathnettle = list("sanguisacid" = 0),

		//Blender Stuff,
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans = list("soymilk" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = list("ketchup" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn = list("cornoil" = 0),
		///obj/item/weapon/reagent_containers/food/snacks/grown/wheat = list("flour" = -5),
		/obj/item/weapon/reagent_containers/food/snacks/grown/ricestalk = list("rice" = -5),
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherries = list("cherryjelly" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/plastellium = list("plasticide" = 5),
		/obj/item/weapon/reagent_containers/food/snacks/egg = list("egg" = -5),


		//archaeology,
		/obj/item/weapon/rocksliver = list("ground_rock" = 50),



		//All types that you can put into the grinder to transfer the reagents to the beaker. !Put all recipes above this!,
		/obj/item/weapon/reagent_containers/pill = list(),
		/obj/item/weapon/reagent_containers/food = list(),
		/obj/item/weapon/coin = list()
	)

	var/list/juice_items = list (

		//Juicer Stuff,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = list("tomatojuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = list("carrotjuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries = list("berryjuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = list("banana" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = list("potato" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon = list("lemonjuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange = list("orangejuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/lime = list("limejuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice = list("watermelonjuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries = list("poisonberryjuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes = list("grapejuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/grapes = list("grapejuice" = 0),
	)


	var/list/holdingitems = list()
	required_skills = list(/datum/skill/chemistry = SKILL_LEVEL_NOVICE)

/obj/machinery/reagentgrinder/atom_init()
	. = ..()
	beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/reagentgrinder(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/reagentgrinder/RefreshParts()
	. = ..()

	speed = 1
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		speed = M.rating

/obj/machinery/reagentgrinder/update_icon()
	icon_state = "juicer"+num2text(!isnull(beaker))
	return


/obj/machinery/reagentgrinder/attackby(obj/item/O, mob/user)

	if(iswrenching(O))
		default_unfasten_wrench(user, O)
		return

	if (istype(O,/obj/item/weapon/reagent_containers/glass) || \
		istype(O,/obj/item/weapon/reagent_containers/food/drinks/drinkingglass) || \
		istype(O,/obj/item/weapon/reagent_containers/food/drinks/shaker))

		if (beaker)
			return TRUE
		else
			src.beaker =  O
			user.drop_from_inventory(O, src)
			update_icon()
			updateUsrDialog()
			return FALSE

	if(holdingitems && holdingitems.len >= limit)
		to_chat(usr, "The machine cannot hold anymore items.")
		return TRUE

	//Fill machine with the plantbag!
	if(istype(O, /obj/item/weapon/storage/bag/plants))

		var/obj/item/weapon/storage/bag/plants/P = O
		for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in O.contents)
			P.remove_from_storage(G, src)
			holdingitems += G
			if(holdingitems && holdingitems.len >= limit) //Sanity checking so the blender doesn't overfill
				to_chat(user, "You fill the All-In-One grinder to the brim.")
				break

		if(!O.contents.len)
			to_chat(user, "You empty the plant bag into the All-In-One grinder.")

		updateUsrDialog()
		return FALSE

	if (!is_type_in_list(O, blend_items) && !is_type_in_list(O, juice_items))
		to_chat(user, "Cannot refine into a reagent.")
		return TRUE

	user.drop_from_inventory(O, src)
	holdingitems += O
	updateUsrDialog()
	return FALSE

/obj/machinery/reagentgrinder/deconstruct(disassembled)
	drop_all_items()
	if(beaker)
		beaker.forceMove(loc)
		beaker = null
	return ..()


/obj/machinery/reagentgrinder/attack_ai(mob/user)
	if(IsAdminGhost(user))
		return ..()
	return FALSE

/obj/machinery/reagentgrinder/ui_interact(mob/user) // The microwave Menu
	var/is_chamber_empty = 0
	var/is_beaker_ready = 0
	var/processing_chamber = ""
	var/beaker_contents = ""
	var/dat = ""

	if(!inuse)
		for (var/obj/item/O in holdingitems)
			processing_chamber += "\A [O.name]<BR>"

		if (!processing_chamber)
			is_chamber_empty = 1
			processing_chamber = "Nothing."
		if (!beaker)
			beaker_contents = "<B>No beaker attached.</B><br>"
		else
			is_beaker_ready = 1
			beaker_contents = "<B>The beaker contains:</B><br>"
			var/anything = 0
			for(var/datum/reagent/R in beaker.reagents.reagent_list)
				anything = 1
				beaker_contents += "[R.volume] - [R.name]<br>"
			if(!anything)
				beaker_contents += "Nothing<br>"


		dat = {"
			<b>Processing chamber contains:</b><br>
			[processing_chamber]<br>
			[beaker_contents]<hr>
			"}
		if (is_beaker_ready && !is_chamber_empty && !(stat & (NOPOWER|BROKEN)))
			dat += "<A href='byond://?src=\ref[src];action=grind'>Grind the reagents</a><BR>"
			dat += "<A href='byond://?src=\ref[src];action=juice'>Juice the reagents</a><BR><BR>"
		if(holdingitems && holdingitems.len > 0)
			dat += "<A href='byond://?src=\ref[src];action=eject'>Eject the reagents</a><BR>"
		if (beaker)
			dat += "<A href='byond://?src=\ref[src];action=detach'>Detach the beaker</a><BR>"
	else
		dat += "Please wait..."

	var/datum/browser/popup = new(user, "reagentgrinder", "All-In-One Grinder")
	popup.set_content("<TT>[dat]</TT>")
	popup.open()


/obj/machinery/reagentgrinder/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	switch(href_list["action"])
		if ("grind")
			grind()
		if("juice")
			juice()
		if("eject")
			eject()
		if ("detach")
			detach()

	updateUsrDialog()

/obj/machinery/reagentgrinder/examine(mob/user)
	. = ..()
	if(!user.Adjacent(src) && !issilicon(user) && !isobserver(user))
		to_chat(user,"<span class='warning'>You're too far away to examine [src]'s contents and display!</span>")
		return

	if(inuse)
		to_chat(user, "<span class='warning'>\The [src] is operating.</span>")
		return

	if(beaker || length(holdingitems))
		to_chat(user, "<span class='notice'>\The [src] contains:</span>")
		if(beaker)
			to_chat(user, "<span class='notice'>- \A [beaker].</span>")
		for(var/i in holdingitems)
			var/obj/item/O = i
			to_chat(user, "<span class='notice'>- \A [O.name].</span>")

	if(!(stat & (NOPOWER|BROKEN)))
		to_chat(user, "<span class='notice'>The status display reads:</span>")
		to_chat(user, "<span class='notice'>- Grinding reagents at <b>[speed*100]%</b>.</span>")
		if(beaker)
			for(var/datum/reagent/R in beaker.reagents.reagent_list)
				to_chat(user, "<span class='notice'>- [R.volume] units of [R.name].</span>")

/obj/machinery/reagentgrinder/proc/detach()

	if(usr.incapacitated())
		return
	if (!beaker)
		return
	beaker.loc = src.loc
	beaker = null
	update_icon()

/obj/machinery/reagentgrinder/proc/drop_all_items()
	if(holdingitems.len == 0)
		return
	for(var/obj/item/O as anything in holdingitems)
		O.forceMove(loc)
	holdingitems.Cut()

/obj/machinery/reagentgrinder/proc/eject()

	if(usr.incapacitated())
		return
	drop_all_items()

/obj/machinery/reagentgrinder/proc/is_allowed(obj/item/weapon/reagent_containers/O)
	for (var/i in blend_items)
		if(istype(O, i))
			return TRUE
	return FALSE

/obj/machinery/reagentgrinder/proc/get_allowed_by_id(obj/item/weapon/grown/O)
	for (var/i in blend_items)
		if (istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_snack_by_id(obj/item/weapon/reagent_containers/food/snacks/O)
	for(var/i in blend_items)
		if(istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_juice_by_id(obj/item/weapon/reagent_containers/food/snacks/O)
	for(var/i in juice_items)
		if(istype(O, i))
			return juice_items[i]

/obj/machinery/reagentgrinder/proc/get_grownweapon_amount(obj/item/weapon/grown/O)
	if (!istype(O))
		return 5
	else if (O.potency == -1)
		return 5
	else
		return round(O.potency)

/obj/machinery/reagentgrinder/proc/get_juice_amount(obj/item/weapon/reagent_containers/food/snacks/grown/O)
	if (!istype(O))
		return 5
	else if (O.potency == -1)
		return 5
	else
		return round(5*sqrt(O.potency))

/obj/machinery/reagentgrinder/proc/remove_object(obj/item/O)
	holdingitems -= O
	qdel(O)

/obj/machinery/reagentgrinder/proc/start_shaking()
	var/static/list/transforms
	if(!transforms)
		var/matrix/M1 = matrix()
		var/matrix/M2 = matrix()
		var/matrix/M3 = matrix()
		var/matrix/M4 = matrix()
		M1.Translate(-1, 0)
		M2.Translate(0, 1)
		M3.Translate(1, 0)
		M4.Translate(0, -1)
		transforms = list(M1, M2, M3, M4)
	animate(src, transform=transforms[1], time=0.4, loop=-1)
	animate(transform=transforms[2], time=0.2)
	animate(transform=transforms[3], time=0.4)
	animate(transform=transforms[4], time=0.6)

/obj/machinery/reagentgrinder/proc/shake_for(duration)
	start_shaking() //start shaking
	addtimer(CALLBACK(src, PROC_REF(stop_shaking)), duration)

/obj/machinery/reagentgrinder/proc/stop_shaking()
	update_icon()
	animate(src, transform = matrix())

/obj/machinery/reagentgrinder/proc/operate_for(time, silent = FALSE, juicing = FALSE)
	shake_for(time / speed)
	inuse = TRUE
	if(!silent)
		if(!juicing)
			playsound(src, 'sound/machines/blender.ogg', VOL_EFFECTS_MASTER, 35)
		else
			playsound(src, 'sound/machines/juicer.ogg', VOL_EFFECTS_MASTER, 20)
	use_power(active_power_usage * time * 0.1) // .1 needed here to convert time (in deciseconds) to seconds such that watts * seconds = joules
	addtimer(CALLBACK(src, PROC_REF(stop_operating)), time / speed)

/obj/machinery/reagentgrinder/proc/stop_operating()
	inuse = FALSE
	updateUsrDialog()
	power_change()

/obj/machinery/reagentgrinder/proc/juice()
	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	operate_for(50, juicing = TRUE)
	//Snacks
	for (var/obj/item/weapon/reagent_containers/food/snacks/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

		var/allowed = get_allowed_juice_by_id(O)
		if(isnull(allowed))
			break

		for (var/r_id in allowed)

			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = get_juice_amount(O)

			beaker.reagents.add_reagent(r_id, min(amount, space))

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

		remove_object(O)

/obj/machinery/reagentgrinder/proc/grind()

	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	operate_for(60)
	//Snacks and Plants
	for (var/obj/item/weapon/reagent_containers/food/snacks/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

		var/allowed = get_allowed_snack_by_id(O)
		if(isnull(allowed))
			break

		for (var/r_id in allowed)

			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			if(amount <= 0)
				if(amount == 0)
					if (O.reagents != null && O.reagents.has_reagent("nutriment"))
						beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("nutriment"), space))
						O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
				else
					if (O.reagents != null && O.reagents.has_reagent("nutriment"))
						beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("nutriment")*abs(amount)), space))
						O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))

			else
				O.reagents.trans_id_to(beaker, r_id, min(amount, space))

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

		if(O.reagents.reagent_list.len == 0)
			remove_object(O)

	//Sheets
	for (var/obj/item/stack/sheet/O in holdingitems)
		var/allowed = get_allowed_by_id(O)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		for(var/i = 1; i <= round(O.get_amount(), 1); i++)
			for (var/r_id in allowed)
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				var/amount = allowed[r_id]
				beaker.reagents.add_reagent(r_id,min(amount, space))
				if (space < amount)
					break
			if (i == round(O.get_amount(), 1))
				remove_object(O)
				break
	//Plants
	for (var/obj/item/weapon/grown/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
		if (space <= O.reagents.total_volume)
			break
		O.reagents.trans_to(beaker, O.reagents.total_volume)
		remove_object(O)

	//xenoarch
	for(var/obj/item/weapon/rocksliver/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/allowed = get_allowed_by_id(O)
		for (var/r_id in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			beaker.reagents.add_reagent(r_id,min(amount, space), O.geological_data)

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break
		remove_object(O)

	//Everything else - Transfers reagents from it into beaker
	for (var/obj/item/weapon/reagent_containers/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/amount = O.reagents.total_volume
		O.reagents.trans_to(beaker, amount)
		if(!O.reagents.total_volume)
			remove_object(O)

//Coin
	for (var/obj/item/weapon/coin/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/amount = O.reagents.total_volume
		O.reagents.trans_to(beaker, amount)
		if(!O.reagents.total_volume)
			remove_object(O)

// Bio-Supplements Mixer
#define BIO_PRODUCE_RATE 1.0
#define MAX_PHORON_TEMP 293
#define MIN_PHORON_TEMP 73
#define MIN_PHORON_EFFICIENCY 0.1

/obj/machinery/portable_atmospherics/bio_supplements_mixer
	name = "Bio-BADs Mixer"
	desc = "A bulky piece of pharmaceutical hardware covered in Zeng-Hu branding and warning decals. It smells faintly of burnt phoron."
	density = TRUE
	anchored = FALSE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "med_mixer0_nopower"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	active_power_usage = 200
	allowed_checks = ALLOWED_CHECK_TOPIC
	volume = 200
	start_pressure = ONE_ATMOSPHERE
	var/obj/item/weapon/reagent_containers/fuel_beaker = null
	var/obj/item/weapon/reagent_containers/nutriment_beaker = null
	var/obj/item/weapon/reagent_containers/blood_beaker = null
	var/obj/item/weapon/reagent_containers/bio_supplements_cartridge/cartridge = null

	var/working = FALSE
	var/list/beaker_original_flags = list()

	// Heating/cooling system (like radiocarbon spectrometer)
	var/mixer_temperature = 0
	var/mixer_seal_integrity = 100
	var/mixer_rpm = 0
	var/mixer_rpm_target = 500
	var/coolant_usage_rate = 0
	var/fresh_coolant = 0
	var/coolant_purity = 0
	var/datum/reagents/coolant_reagents
	var/used_coolant = 0
	var/list/coolant_reagents_purity = list()
	var/last_process_worldtime = 0

	required_skills = list(/datum/skill/chemistry = SKILL_LEVEL_TRAINED)

/obj/machinery/portable_atmospherics/bio_supplements_mixer/atom_init()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(300)
	reagents = R
	R.my_atom = src
	coolant_reagents = new/datum/reagents(500)
	coolant_reagents.my_atom = src
	coolant_reagents_purity["water"] = 0.5
	coolant_reagents_purity["icecoffee"] = 0.6
	coolant_reagents_purity["icetea"] = 0.6
	coolant_reagents_purity["milkshake"] = 0.6
	coolant_reagents_purity["leporazine"] = 0.7
	coolant_reagents_purity["kelotane"] = 0.7
	coolant_reagents_purity["sterilizine"] = 0.7
	coolant_reagents_purity["dermaline"] = 0.7
	coolant_reagents_purity["cryoxadone"] = 0.9
	coolant_reagents_purity["coolant"] = 1
	coolant_reagents_purity["adminordrazine"] = 2
	last_process_worldtime = world.time

/obj/machinery/portable_atmospherics/bio_supplements_mixer/Destroy()
	disconnect()
	for(var/obj/item/weapon/reagent_containers/G in beaker_original_flags)
		G.flags = beaker_original_flags[G]
	beaker_original_flags.Cut()
	QDEL_NULL(fuel_beaker)
	QDEL_NULL(nutriment_beaker)
	QDEL_NULL(blood_beaker)
	QDEL_NULL(cartridge)
	QDEL_NULL(coolant_reagents)
	return ..()

/obj/machinery/portable_atmospherics/bio_supplements_mixer/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/weapon/wrench))
		if(connected_port)
			disconnect()
			playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
			user.visible_message("[user] disconnects [src] from the port.", "<span class='notice'>You disconnect [src] from the port.</span>")
			anchored = FALSE
			update_icon()
		else
			var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/components/unary/portables_connector) in loc
			if(!possible_port)
				to_chat(user, "<span class='notice'>No connector port here.</span>")
				return
			if(possible_port.connected_device)
				to_chat(user, "<span class='notice'>The port is already in use.</span>")
				return
			if(connect(possible_port))
				playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
				user.visible_message("[user] connects [src] to the port.", "<span class='notice'>You connect [src] to the port.</span>")
				anchored = TRUE
				update_icon()
			else
				to_chat(user, "<span class='notice'>[src] failed to connect to the port.</span>")
		SStgui.update_uis(src)
		return

	if(istype(O, /obj/item/weapon/reagent_containers/bio_supplements_cartridge))
		if(cartridge)
			to_chat(user, "\The [src] already has a cartridge loaded.")
			return
		cartridge = O
		user.drop_from_inventory(O, src)
		to_chat(user, "You insert [O] into \the [src].")
		SStgui.update_uis(src)
		return

	if(istype(O, /obj/item/weapon/reagent_containers/blood))
		if(blood_beaker)
			to_chat(user, "\The [src] already has an organic liquid container loaded.")
			return
		blood_beaker = O
		to_chat(user, "You load [O] into \the [src].")
		SStgui.update_uis(src)
		return

	if(istype(O, /obj/item/weapon/reagent_containers/glass))
		var/obj/item/weapon/reagent_containers/glass/G = O
		if(G.reagents.has_reagent("fuel") || G.reagents.has_reagent("nutriment") || is_valid_organic_beaker(G.reagents))
			if(!do_skill_checks(user))
				return
			if(G.reagents.has_reagent("fuel"))
				if(fuel_beaker)
					to_chat(user, "\The [src] already has a fuel beaker loaded.")
					return
				fuel_beaker = G
			else if(G.reagents.has_reagent("nutriment"))
				if(nutriment_beaker)
					to_chat(user, "\The [src] already has a nutriment beaker loaded.")
					return
				nutriment_beaker = G
			else if(is_valid_organic_beaker(G.reagents))
				if(blood_beaker)
					to_chat(user, "\The [src] already has an organic liquid container loaded.")
					return
				blood_beaker = G
			user.drop_from_inventory(G, src)
			beaker_original_flags[G] = G.flags
			G.flags &= ~OPENCONTAINER
			to_chat(user, "You load [G] into \the [src].")
			SStgui.update_uis(src)
		else
			user.SetNextMove(CLICK_CD_INTERACT)
			if(working)
				to_chat(user, "<span class='warning'>You can't do that while [src] is mixing!</span>")
				return
			var/choice = tgui_alert(user, "What do you want to do with the container?", name, list("Add coolant", "Empty coolant"))
			if(choice == "Add coolant")
				var/amount_transferred = min(coolant_reagents.maximum_volume - coolant_reagents.total_volume, G.reagents.total_volume)
				G.reagents.trans_to(coolant_reagents, amount_transferred)
				to_chat(user, "<span class='info'>You empty [amount_transferred]u of coolant into [src].</span>")
				update_coolant()
			else if(choice == "Empty coolant")
				var/amount_transferred = min(G.reagents.maximum_volume - G.reagents.total_volume, coolant_reagents.total_volume)
				coolant_reagents.trans_to(G, amount_transferred)
				to_chat(user, "<span class='info'>You remove [amount_transferred]u of coolant from [src].</span>")
				update_coolant()
		return
	return ..()

/obj/machinery/portable_atmospherics/bio_supplements_mixer/proc/update_coolant()
	var/total_purity = 0
	fresh_coolant = 0
	coolant_purity = 0
	for(var/datum/reagent/current_reagent in coolant_reagents.reagent_list)
		if(!current_reagent)
			continue
		var/cur_purity = coolant_reagents_purity[current_reagent.id]
		if(!cur_purity)
			cur_purity = 0.1
		else if(cur_purity > 1)
			cur_purity = 1
		total_purity += cur_purity * current_reagent.volume
		fresh_coolant += current_reagent.volume
	if(total_purity && fresh_coolant)
		coolant_purity = total_purity / fresh_coolant

/obj/machinery/portable_atmospherics/bio_supplements_mixer/proc/has_ingredients()
	if(!fuel_beaker || !fuel_beaker.reagents || !fuel_beaker.reagents.has_reagent("fuel"))
		return FALSE
	if(!nutriment_beaker || !nutriment_beaker.reagents || !nutriment_beaker.reagents.has_reagent("nutriment"))
		return FALSE
	if(!blood_beaker || !blood_beaker.reagents || !is_valid_organic_beaker(blood_beaker.reagents))
		return FALSE
	if(!has_phoron_connection())
		return FALSE
	return TRUE

/obj/machinery/portable_atmospherics/bio_supplements_mixer/proc/is_valid_organic_beaker(datum/reagents/R)
	if(!R)
		return FALSE
	if(R.has_reagent("blood") || R.has_reagent("enzyme"))
		return TRUE
	if(R.has_reagent("milk") || R.has_reagent("beer") || R.has_reagent("ale"))
		return TRUE
	for(var/datum/reagent/reag in R.reagent_list)
		if(findtext(reag.id, "juice"))
			return TRUE
	return FALSE

/obj/machinery/portable_atmospherics/bio_supplements_mixer/proc/get_organic_reagent_to_consume()
	if(!blood_beaker || !blood_beaker.reagents)
		return null
	var/static/list/organic_reagents = list("blood", "enzyme", "milk", "beer", "ale")
	for(var/reag_id in organic_reagents)
		if(blood_beaker.reagents.has_reagent(reag_id))
			return reag_id
	for(var/datum/reagent/reag in blood_beaker.reagents.reagent_list)
		if(findtext(reag.id, "juice"))
			return reag.id
	return null

/obj/machinery/portable_atmospherics/bio_supplements_mixer/proc/has_phoron_connection()
	return get_available_phoron() >= BIO_PRODUCE_RATE * 5

/obj/machinery/portable_atmospherics/bio_supplements_mixer/proc/get_available_phoron()
	if(!connected_port)
		return 0
	if(air_contents.gas["phoron"] >= BIO_PRODUCE_RATE * 5)
		return air_contents.gas["phoron"]
	var/datum/pipeline/P = connected_port.PARENT1
	if(!P || !P.air)
		return 0
	return P.air.gas["phoron"]

/obj/machinery/portable_atmospherics/bio_supplements_mixer/proc/get_phoron_temperature()
	if(!connected_port || get_available_phoron() < BIO_PRODUCE_RATE * 5)
		return 0
	if(air_contents.gas["phoron"] >= BIO_PRODUCE_RATE * 5)
		return air_contents.temperature
	var/datum/pipeline/P = connected_port.PARENT1
	if(!P || !P.air)
		return 0
	return P.air.temperature

/obj/machinery/portable_atmospherics/bio_supplements_mixer/proc/get_phoron_efficiency()
	var/temp = get_phoron_temperature()
	if(temp <= 0)
		return 0
	return clamp(1.0 - (temp - MIN_PHORON_TEMP) / (MAX_PHORON_TEMP - MIN_PHORON_TEMP) * (1.0 - MIN_PHORON_EFFICIENCY), MIN_PHORON_EFFICIENCY, 1.0)

/obj/machinery/portable_atmospherics/bio_supplements_mixer/process()
	if(working)
		if(!powered(power_channel))
			working = FALSE
			playsound(src, null, channel = 502)
			for(var/i in 1 to 3)
				new /mob/living/simple_animal/bio_slime(loc)
			visible_message("<span class='warning'>Bio-slime creatures burst out of [src] as the power cuts!</span>")
			update_icon()
			SStgui.update_uis(src)
			return

		if(!has_ingredients())
			working = FALSE
			playsound(src, null, channel = 502)
			update_icon()
			visible_message("<span class='notice'>[src] stops - missing ingredients.</span>")
			SStgui.update_uis(src)
		else
			// Calculate time difference
			var/deltaT = min((world.time - last_process_worldtime) * 0.1, 5)

			// Move RPM toward target
			if(mixer_rpm < mixer_rpm_target)
				mixer_rpm = min(mixer_rpm + 100 * deltaT, mixer_rpm_target)
			else if(mixer_rpm > mixer_rpm_target)
				mixer_rpm = max(mixer_rpm - 100 * deltaT, mixer_rpm_target)

			// Heat up according to RPM
			mixer_temperature += mixer_rpm * deltaT * 0.05

			// Use coolant to cool down
			if(coolant_usage_rate > 0)
				var/coolant_used = min(fresh_coolant, coolant_usage_rate * deltaT)
				if(coolant_used > 0)
					fresh_coolant -= coolant_used
					used_coolant += coolant_used
					mixer_temperature = max(mixer_temperature - coolant_used * coolant_purity * 20, 0)

			// Degrade seal over time according to temperature
			mixer_seal_integrity -= (max(mixer_temperature, 1) / 1000) * deltaT

			// Emergency stop
			if(mixer_seal_integrity <= 0 || mixer_temperature >= 1273)
				working = FALSE
				playsound(src, null, channel = 502)
				update_icon()
				visible_message("<span class='notice'>[bicon(src)] [src] buzzes unhappily. It has failed mid-mix!</span>", 2)
				// Release phoron into atmosphere on overheat
				if(mixer_temperature >= 1273)
					var/turf/simulated/T = get_turf(src)
					if(istype(T))
						var/datum/gas_mixture/GM = T.return_air()
						GM.adjust_gas("phoron", 10)
						visible_message("<span class='warning'>[bicon(src)] [src] vents hot phoron gas!</span>", 2)
				last_process_worldtime = world.time
				SStgui.update_uis(src)
				return

			playsound(src, 'sound/machines/stove.ogg', VOL_EFFECTS_MASTER, 20, channel = 502)
			var/rpm_rate = BIO_PRODUCE_RATE * (mixer_rpm / 500)
			fuel_beaker.reagents.remove_reagent("fuel", rpm_rate)
			nutriment_beaker.reagents.remove_reagent("nutriment", rpm_rate)
			var/organic_reagent = get_organic_reagent_to_consume()
			if(organic_reagent)
				blood_beaker.reagents.remove_reagent(organic_reagent, rpm_rate)
			if(air_contents.gas["phoron"] >= rpm_rate * 5)
				air_contents.gas["phoron"] = max(0, air_contents.gas["phoron"] - rpm_rate * 5)
			else if(connected_port)
				var/datum/pipeline/P = connected_port.PARENT1
				if(P && P.air)
					P.air.gas["phoron"] = max(0, P.air.gas["phoron"] - rpm_rate * 5)
			update_connected_network()
			reagents.add_reagent("bio_supplements", rpm_rate * get_phoron_efficiency())
			var/turf/simulated/T = get_turf(src)
			if(istype(T))
				var/datum/gas_mixture/GM = T.return_air()
				GM.adjust_gas("carbon_dioxide", 2)

			if(prob(5))
				visible_message("<span class='notice'>[bicon(src)] [src] [pick("whirrs", "chuffs", "clicks")][pick(" excitedly", " energetically", " busily")].</span>", 2)
	else
		// Gradually cool down over time
		if(mixer_temperature > 0)
			mixer_temperature = max(mixer_temperature - 5 - 10 * rand(), 0)
		if(used_coolant)
			coolant_reagents.remove_any(used_coolant)
			used_coolant = 0

	last_process_worldtime = world.time

/obj/machinery/portable_atmospherics/bio_supplements_mixer/power_change()
	if(anchored && powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
			update_power_use()
	update_power_use()
	update_icon()

/obj/machinery/portable_atmospherics/bio_supplements_mixer/Move(NewLoc, Dir, step_x, step_y)
	. = ..()
	if(. && !moving_diagonally)
		disconnect()

/obj/machinery/portable_atmospherics/bio_supplements_mixer/update_icon()
	if(working)
		icon_state = "med_mixer1"
	else if(!connected_port || (stat & NOPOWER))
		icon_state = "med_mixer0_nopower"
	else
		icon_state = "med_mixer0"

/obj/machinery/portable_atmospherics/bio_supplements_mixer/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/portable_atmospherics/bio_supplements_mixer/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BioSupplementsMixer", name)
		ui.open()

/obj/machinery/portable_atmospherics/bio_supplements_mixer/tgui_data(mob/user)
	var/list/data = list()
	data["fuel_loaded"] = !!fuel_beaker
	data["fuel_amount"] = fuel_beaker && fuel_beaker.reagents ? fuel_beaker.reagents.total_volume : 0
	data["fuel_max"] = fuel_beaker ? fuel_beaker.volume : 1

	data["nutriment_loaded"] = !!nutriment_beaker
	data["nutriment_amount"] = nutriment_beaker && nutriment_beaker.reagents ? nutriment_beaker.reagents.total_volume : 0
	data["nutriment_max"] = nutriment_beaker ? nutriment_beaker.volume : 1

	data["blood_loaded"] = !!blood_beaker
	data["blood_amount"] = blood_beaker && blood_beaker.reagents ? blood_beaker.reagents.total_volume : 0
	data["blood_max"] = blood_beaker ? blood_beaker.volume : 1

	data["phoron_ok"] = has_phoron_connection()
	data["phoron_temp"] = round(get_phoron_temperature())
	data["phoron_efficiency"] = round(get_phoron_efficiency() * 100)

	data["bio_amount"] = reagents.get_reagent_amount("bio_supplements")
	data["bio_max"] = reagents.maximum_volume
	data["working"] = working

	data["cartridge_loaded"] = !!cartridge
	if(cartridge)
		data["cartridge_name"] = cartridge.name
		data["cartridge_volume"] = cartridge.reagents.total_volume
		data["cartridge_max_volume"] = cartridge.volume

	data["mixer_temperature"] = round(mixer_temperature)
	data["mixer_seal_integrity"] = round(mixer_seal_integrity)
	data["mixer_rpm"] = round(mixer_rpm)
	data["mixer_rpm_target"] = mixer_rpm_target
	data["coolant_usage_rate"] = coolant_usage_rate
	data["unused_coolant_abs"] = round(fresh_coolant)
	data["unused_coolant_per"] = round(fresh_coolant / coolant_reagents.maximum_volume * 100)
	data["coolant_purity"] = round(coolant_purity * 100)

	return data

/obj/machinery/portable_atmospherics/bio_supplements_mixer/tgui_act(action, params)
	. = ..()
	if(.)
		return

	var/mob/user = usr
	if(isnull(user))
		return

	switch(action)
		if("eject_fuel")
			if(fuel_beaker)
				if(beaker_original_flags[fuel_beaker])
					fuel_beaker.flags = beaker_original_flags[fuel_beaker]
					beaker_original_flags -= fuel_beaker
				fuel_beaker.forceMove(loc)
				fuel_beaker = null
			SStgui.update_uis(src)
			return TRUE

		if("eject_nutriment")
			if(nutriment_beaker)
				if(beaker_original_flags[nutriment_beaker])
					nutriment_beaker.flags = beaker_original_flags[nutriment_beaker]
					beaker_original_flags -= nutriment_beaker
				nutriment_beaker.forceMove(loc)
				nutriment_beaker = null
			SStgui.update_uis(src)
			return TRUE

		if("eject_blood")
			if(blood_beaker)
				if(beaker_original_flags[blood_beaker])
					blood_beaker.flags = beaker_original_flags[blood_beaker]
					beaker_original_flags -= blood_beaker
				blood_beaker.forceMove(loc)
				blood_beaker = null
			SStgui.update_uis(src)
			return TRUE

		if("eject_cartridge")
			if(cartridge)
				cartridge.forceMove(loc)
				cartridge = null
			SStgui.update_uis(src)
			return TRUE

		if("produce")
			if(!has_ingredients())
				to_chat(user, "<span class='warning'>Not enough ingredients! Need: Welding fuel, Nutriment, Organic Liquid, and Phoron gas connection.</span>")
				return TRUE
			working = TRUE
			update_icon()
			playsound(src, 'sound/machines/pacman_on.ogg', VOL_EFFECTS_MASTER, 30, channel = 501)
			visible_message("<span class='notice'>[src] begins synthesizing Bio-supplements.</span>")
			SStgui.update_uis(src)
			return TRUE

		if("stop")
			working = FALSE
			playsound(src, null, channel = 502)
			update_icon()
			playsound(src, 'sound/machines/pacman_off.ogg', VOL_EFFECTS_MASTER, 30, channel = 501)
			visible_message("<span class='notice'>[src] stops synthesizing.</span>")
			SStgui.update_uis(src)
			return TRUE

		if("dispense")
			if(!cartridge)
				to_chat(user, "<span class='warning'>No cartridge loaded!</span>")
				return TRUE
			var/space = cartridge.reagents.maximum_volume - cartridge.reagents.total_volume
			var/amount = min(reagents.get_reagent_amount("bio_supplements"), space)
			if(amount > 0)
				reagents.trans_id_to(cartridge, "bio_supplements", amount)
			SStgui.update_uis(src)
			return TRUE

		if("rpm")
			mixer_rpm_target = clamp(text2num(params["target"]), 1, 1000)
			return TRUE

		if("coolant_level")
			coolant_usage_rate = text2num(params["level"])
			return TRUE

	return FALSE

#undef BIO_PRODUCE_RATE

/obj/machinery/bads_tank
	name = "Bio-BADs tank"
	desc = "A heavy-duty containment vessel filled with thick amber liquid. Factory seals and biohazard stickers are plastered across its surface."
	icon = 'icons/atmos/tank.dmi'
	icon_state = "generic_map"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	allowed_checks = ALLOWED_CHECK_TOPIC
	var/bads_amount = 0
	var/max_bads = 300

/obj/machinery/bads_tank/atom_init()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(max_bads)
	reagents = R
	R.my_atom = src
	reagents.add_reagent("bio_supplements", max_bads)

/obj/machinery/bads_tank/on_reagent_change()
	bads_amount = reagents.get_reagent_amount("bio_supplements")
	SStgui.update_uis(src)

/obj/machinery/bads_tank/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/reagent_containers/bio_supplements_cartridge))
		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[src] is already full.</span>")
			return
		var/available = W.reagents.get_reagent_amount("bio_supplements")
		if(available <= 0)
			to_chat(user, "<span class='warning'>The cartridge is empty.</span>")
			return
		var/transferred = W.reagents.trans_id_to(src, "bio_supplements", available)
		to_chat(user, "<span class='notice'>You refill [src] with [transferred] units from the cartridge.</span>")
		return

	to_chat(user, "<span class='warning'>[src] is sealed and cannot be refilled.</span>")

/obj/machinery/bads_tank/proc/consume(amount)
	if(reagents.get_reagent_amount("bio_supplements") >= amount)
		reagents.remove_reagent("bio_supplements", amount)
		bads_amount = reagents.get_reagent_amount("bio_supplements")
		return TRUE
	return FALSE

/obj/machinery/bads_tank/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>It contains [bads_amount]/[max_bads] units of Bio-BADs. Enough for [round(bads_amount / 50)] clone(s).</span>")

/obj/machinery/bads_tank/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/bads_tank/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BadsTank", name)
		ui.open()

/obj/machinery/bads_tank/tgui_data(mob/user)
	var/list/data = list()
	data["bads_amount"] = bads_amount
	data["max_bads"] = max_bads
	data["clones_possible"] = round(bads_amount / 50)
	return data
