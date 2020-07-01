/obj/machinery/disease2/incubator
	name = "Pathogenic incubator"
	density = 1
	anchored = 1
	icon = 'icons/obj/virology.dmi'
	icon_state = "incubator"
	allowed_checks = ALLOWED_CHECK_TOPIC
	var/obj/item/weapon/virusdish/dish
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/radiation = 0

	var/on = 0
	var/power = 0

	var/foodsupply = 0
	var/toxinsupply = 0
	var/synaptizinesupply = 0
	var/phoronsupply = 0
	var/sleeptoxinsupply = 0

	var/datum/disease2/effectholder/selected = null

	var/working = 0

/obj/machinery/disease2/incubator/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/weapon/reagent_containers/glass) || istype(O,/obj/item/weapon/reagent_containers/syringe))

		if(beaker)
			to_chat(user, "\The [src] is already loaded.")
			return

		beaker = O
		user.drop_item()
		O.loc = src

		user.visible_message("[user] adds \a [O] to \the [src]!", "You add \a [O] to \the [src]!")
		nanomanager.update_uis(src)

		src.attack_hand(user)
		return

	else if(istype(O, /obj/item/weapon/virusdish))

		if(dish)
			to_chat(user, "The dish tray is aleady full!")
			return

		dish = O
		user.drop_item()
		O.loc = src

		user.visible_message("[user] adds \a [O] to \the [src]!", "You add \a [O] to \the [src]!")
		nanomanager.update_uis(src)

		src.attack_hand(user)
	else
		return ..()

/obj/machinery/disease2/incubator/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	var/data[0]
	data["chemicals_inserted"] = !!beaker
	data["dish_inserted"] = !!dish
	data["food_supply"] = foodsupply
	data["radiation"] = radiation
	data["toxinsupply"] = toxinsupply
	data["synaptizinesupply"] = synaptizinesupply
	data["phoronsupply"] = phoronsupply
	data["sleeptoxinsupply"] = sleeptoxinsupply
	data["on"] = on
	data["system_in_use"] = foodsupply > 0 || radiation > 0
	data["chemical_volume"] = beaker ? beaker.reagents.total_volume : 0
	data["max_chemical_volume"] = beaker ? beaker.volume : 1
	data["virus"] = dish ? dish.virus2 : null
	data["infection_rate"] = dish && dish.virus2 ? dish.virus2.infectionchance * 10 : 0
	data["analysed"] = dish && dish.analysed ? 1 : 0
	data["can_breed_virus"] = null
	data["blood_already_infected"] = null
	data["working"] = working
	data["effects"] = null
	data["symptomdesc"] = null
	data["symptomname"] = null
	if(selected != null)
		data["symptomdesc"] = selected.effect.desc
		data["symptomname"] = selected.effect.name
	if(dish && dish.virus2)
		var/list/effects[0]
		for (var/datum/disease2/effectholder/e in dish.virus2.effects)
			effects.Add(list(list("name" = (e.effect.name), "stage" = (e.stage), "reference" = "\ref[e]")))
		data["effects"] = effects
		data["affected_species"] = jointext(dish.virus2.affected_species, ", ")

	if (beaker)
		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in beaker.reagents.reagent_list
		data["can_breed_virus"] = dish && dish.virus2 && B

		if (B)
			if (!B.data["virus2"])
				B.data["virus2"] = list()

			var/list/virus = B.data["virus2"]
			for (var/ID in virus)
				data["blood_already_infected"] = virus[ID]

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, "dish_incubator.tmpl", src.name, 400, 600)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/disease2/incubator/process()
	if(working > 0)
		working--
		if (!working)
			nanomanager.update_uis(src)
			icon_state = "incubator"
		if(!powered(power_channel))
			icon_state = "incubator"

	if(beaker)
		var/vol = beaker.reagents.total_volume
		foodsupply += drain_reagent_from_beaker("virusfood")
		toxinsupply += drain_reagent_from_beaker("toxin")
		sleeptoxinsupply += drain_reagent_from_beaker("stoxin")
		synaptizinesupply += drain_reagent_from_beaker("synaptizine")
		phoronsupply += drain_reagent_from_beaker("phoron")
		if(beaker.reagents.total_volume != vol)
			nanomanager.update_uis(src)

/obj/machinery/disease2/incubator/proc/drain_reagent_from_beaker(reagent)
	if(beaker.reagents.get_reagent_amount(reagent))
		var/ammount = (min(beaker.reagents.get_reagent_amount(reagent), 5))
		beaker.reagents.remove_reagent(reagent, 5)
		return ammount
	return 0

/obj/machinery/disease2/incubator/Topic(href, href_list)
	var/mob/user = usr
	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")

	if (href_list["close"])
		user.unset_machine(src)
		ui.close()
		return FALSE

	. = ..()
	if(!.)
		return

	if (href_list["ejectchem"])
		if (beaker)
			beaker.loc = src.loc
			beaker = null
		return TRUE

	if (href_list["power"])
		if (dish)
			on = !on
			icon_state = on ? "incubator_on" : "incubator"
		return TRUE

	if (href_list["ejectdish"])
		if (dish)
			dish.loc = src.loc
			dish = null
		return TRUE

	if (href_list["rad"])
		if (dish)
			dish.virus2.radiate()

		working = 1
		icon_state = "incubator_on"
		return TRUE

	if (href_list["food"])
		if (dish && foodsupply>0)
			dish.virus2.reactfood()
			foodsupply-=1
		working = 1
		icon_state = "incubator_on"
		return TRUE

	if (href_list["toxin"])
		if (dish && toxinsupply>0)
			dish.virus2.reacttoxin()
			toxinsupply-=1
		working = 1
		icon_state = "incubator_on"
		return TRUE

	if (href_list["sleeptoxin"])
		if (dish && sleeptoxinsupply>0)
			dish.virus2.reactsleeptoxin()
			sleeptoxinsupply-=1
		working = 1
		icon_state = "incubator_on"
		return TRUE

	if (href_list["synaptizine"])
		if (dish && synaptizinesupply>0)
			dish.virus2.reactsynaptizine()
			synaptizinesupply-=1
		working = 1
		icon_state = "incubator_on"
		return TRUE

	if (href_list["phoron"])
		if (dish && phoronsupply>0)
			dish.virus2.reactphoron()
			phoronsupply-=1
		working = 1
		icon_state = "incubator_on"
		return TRUE

	if (href_list["symptominfo"])
		selected = locate(href_list["symptominfo"])
		return TRUE

	if (href_list["back"])
		selected = null
		return TRUE

	if (href_list["virus"])
		if(!dish)
			return TRUE

		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in beaker.reagents.reagent_list
		if(!B)
			return TRUE

		if(!B.data["virus2"])
			B.data["virus2"] = list()

		var/list/virus = list("[dish.virus2.uniqueID]" = dish.virus2.getcopy())
		B.data["virus2"] += virus

		ping("\The [src] pings, \"Injection complete.\"")
		return TRUE

	return FALSE
