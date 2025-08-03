#define DRAIN_RATE 5
#define SUPPLY_CAP 100
#define OPERATION_TIME 4

/obj/machinery/disease2/incubator
	name = "Pathogenic incubator"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/virology.dmi'
	icon_state = "incubator"
	allowed_checks = ALLOWED_CHECK_TOPIC
	var/obj/item/weapon/virusdish/dish
	var/obj/item/weapon/reagent_containers/glass/beaker = null

	var/foodsupply = 0
	var/toxinsupply = 0
	var/synaptizinesupply = 0
	var/phoronsupply = 0
	var/sleeptoxinsupply = 0

	var/datum/disease2/effectholder/selected = null

	var/working = 0
	required_skills = list(/datum/skill/chemistry = SKILL_LEVEL_TRAINED, /datum/skill/research = SKILL_LEVEL_TRAINED, /datum/skill/medical = SKILL_LEVEL_PRO)

/obj/machinery/disease2/incubator/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/weapon/reagent_containers/glass) || istype(O,/obj/item/weapon/reagent_containers/syringe))

		if(beaker)
			to_chat(user, "\The [src] is already loaded.")
			return
		if(!do_skill_checks(user))
			return
		beaker = O
		user.drop_from_inventory(O, src)

		user.visible_message("[user] adds \a [O] to \the [src]!", "You add \a [O] to \the [src]!")
		SStgui.update_uis(src)

		attack_hand(user)
		return

	else if(istype(O, /obj/item/weapon/virusdish))

		if(dish)
			to_chat(user, "The dish tray is aleady full!")
			return
		if(!do_skill_checks(user))
			return
		dish = O
		user.drop_from_inventory(O, src)

		user.visible_message("[user] adds \a [O] to \the [src]!", "You add \a [O] to \the [src]!")
		SStgui.update_uis(src)

		attack_hand(user)
	else
		return ..()

/obj/machinery/disease2/incubator/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/disease2/incubator/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DishIncubator", name)
		ui.open()

/obj/machinery/disease2/incubator/tgui_data(mob/user)
	var/list/data = list()
	data["chemicals_inserted"] = !!beaker
	data["dish_inserted"] = !!dish
	data["food_supply"] = foodsupply
	data["toxin_supply"] = toxinsupply
	data["synaptizine_supply"] = synaptizinesupply
	data["phoron_supply"] = phoronsupply
	data["sleeptoxin_supply"] = sleeptoxinsupply
	data["system_in_use"] = working > 0
	data["chemical_volume"] = beaker ? beaker.reagents.total_volume : 0
	data["max_chemical_volume"] = beaker ? beaker.volume : 1
	data["virus"] = dish?.virus2
	data["infection_rate"] = dish?.virus2 ? dish.virus2.infectionchance * 10 : 0
	data["analysed"] = dish?.analysed
	data["can_breed_virus"] = null
	data["blood_already_infected"] = null
	data["effects"] = null
	data["symptomdesc"] = null
	data["symptomname"] = null
	data["supply_cap"] = SUPPLY_CAP
	if(selected != null)
		data["symptomdesc"] = selected.effect.desc
		data["symptomname"] = selected.effect.name
	if(dish && dish.virus2)
		var/list/effects[0]
		for (var/datum/disease2/effectholder/e in dish.virus2.effects)
			effects.Add(list(list("name" = (e.effect.name), "reference" = "\ref[e]")))
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
	return data

/obj/machinery/disease2/incubator/process()
	if(working > 0)
		working--
		if (!working)
			SStgui.update_uis(src)
			icon_state = "incubator"
		if(!powered(power_channel))
			icon_state = "incubator"

	if(beaker)
		var/vol = beaker.reagents.total_volume
		foodsupply += drain_reagent_from_beaker("virusfood", min(SUPPLY_CAP - foodsupply, DRAIN_RATE))
		toxinsupply += drain_reagent_from_beaker("toxin", min(SUPPLY_CAP - toxinsupply, DRAIN_RATE))
		sleeptoxinsupply += drain_reagent_from_beaker("stoxin", min(SUPPLY_CAP - sleeptoxinsupply, DRAIN_RATE))
		synaptizinesupply += drain_reagent_from_beaker("synaptizine", min(SUPPLY_CAP - synaptizinesupply, DRAIN_RATE))
		phoronsupply += drain_reagent_from_beaker("phoron", min(SUPPLY_CAP - phoronsupply, DRAIN_RATE))
		if(beaker.reagents.total_volume != vol)
			SStgui.update_uis(src)

/obj/machinery/disease2/incubator/proc/drain_reagent_from_beaker(reagent, amount)
	amount = min(beaker.reagents.get_reagent_amount(reagent), amount)
	beaker.reagents.remove_reagent(reagent, amount)
	return amount

/obj/machinery/disease2/incubator/tgui_act(action, params)
	. = ..()
	if(.)
		return

	var/mob/user = usr
	if(isnull(user))
		return

	switch(action)

		if("ejectchem")
			if (beaker)
				beaker.forceMove(loc)
				beaker = null
			return TRUE

		if ("ejectdish")
			if (dish)
				dish.forceMove(loc)
				dish = null
			return TRUE

		if ("rad")
			if (dish)
				dish.virus2.radiate()

			working = OPERATION_TIME
			icon_state = "incubator_on"
			return TRUE

		if ("food")
			if (dish && foodsupply>0)
				dish.virus2.reactfood()
				foodsupply-=1
			working = OPERATION_TIME
			icon_state = "incubator_on"
			return TRUE

		if ("toxin")
			if (dish && toxinsupply>0)
				dish.virus2.reacttoxin()
				toxinsupply-=1
			working = OPERATION_TIME
			icon_state = "incubator_on"
			return TRUE

		if ("sleeptoxin")
			if (dish && sleeptoxinsupply>0)
				dish.virus2.reactsleeptoxin()
				sleeptoxinsupply-=1
			working = OPERATION_TIME
			icon_state = "incubator_on"
			return TRUE

		if ("synaptizine")
			if (dish && synaptizinesupply>0)
				dish.virus2.reactsynaptizine()
				synaptizinesupply-=1
			working = OPERATION_TIME
			icon_state = "incubator_on"
			return TRUE

		if ("phoron")
			if (dish && phoronsupply>0)
				dish.virus2.reactphoron()
				phoronsupply-=1
			working = OPERATION_TIME
			icon_state = "incubator_on"
			return TRUE

		if ("info")
			selected = locate(params["symptomref"])
			return TRUE

		if ("back")
			selected = null
			return TRUE

		if ("virus")
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

#undef DRAIN_RATE
#undef SUPPLY_CAP
#undef OPERATION_TIME
