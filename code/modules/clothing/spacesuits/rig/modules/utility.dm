/obj/item/rig_module/device
	name = "mounted device"
	desc = "Some kind of hardsuit mount."
	usable = 0
	selectable = 1
	toggleable = 0
	disruptive = 0

	var/device_type
	var/obj/item/device

/obj/item/rig_module/device/healthscanner
	name = "hardsuit health scanner module"
	desc = "A hardsuit-mounted health scanner."
	icon_state = "scanner"
	interface_name = "health scanner"
	interface_desc = "Shows an informative health readout when used on a subject."
	use_power_cost = 200
	origin_tech = list(TECH_MAGNET = 3, TECH_BIO = 3, TECH_ENGINEERING = 5)
	device_type = /obj/item/device/healthanalyzer

/obj/item/rig_module/device/drill
	name = "hardsuit drill mount"
	desc = "A very heavy diamond-tipped drill."
	icon_state = "drill"
	interface_name = "mounted drill"
	interface_desc = "A diamond-tipped industrial drill."
	suit_overlay_active = "mounted-drill"
	suit_overlay_inactive = "mounted-drill"
	use_power_cost = 75
	origin_tech = list(TECH_MATERIAL = 6, TECH_POWER = 4, TECH_ENGINEERING = 6)
	device_type = /obj/item/weapon/pickaxe/drill/jackhammer // this one doesn't use energy

/obj/item/rig_module/device/anomaly_scanner
	name = "hardsuit anomaly scanner module"
	desc = "You think it's called an Elder Sarsparilla or something."
	icon_state = "eldersasparilla"
	interface_name = "Alden-Saraspova counter"
	interface_desc = "An exotic particle detector commonly used by xenoarchaeologists."
	engage_string = "Begin Scan"
	use_power_cost = 200
	usable = 1
	selectable = 0
	device_type = /obj/item/device/ano_scanner
	origin_tech = list(TECH_BLUESPACE = 4, TECH_MAGNET = 4, TECH_ENGINEERING = 6)

/obj/item/rig_module/device/orescanner
	name = "hardsuit ore scanner module"
	desc = "A clunky old ore scanner."
	icon_state = "scanner"
	interface_name = "ore detector"
	interface_desc = "A sonar system for detecting large masses of ore."
	engage_string = "Begin Scan"
	usable = 1
	selectable = 0
	use_power_cost = 200
	device_type = /obj/item/weapon/mining_scanner
	origin_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 4, TECH_ENGINEERING = 6)

/obj/item/weapon/rcd/mounted/useResource(var/amount, var/mob/user)
	var/cost = amount*70 //Arbitary number that hopefully gives it as many uses as a plain RCD.
	if(istype(loc,/obj/item/rig_module))
		var/obj/item/rig_module/module = loc
		if(module.holder && module.holder.cell)
			if(module.holder.cell.charge >= cost)
				module.holder.cell.use(cost)
				return 1
	return 0

/obj/item/weapon/rcd/mounted/checkResource(amount, mob/user)
	var/cost = amount*70
	if(istype(loc,/obj/item/rig_module))
		var/obj/item/rig_module/module = loc
		if(module.holder && module.holder.cell)
			if(module.holder.cell.charge >= cost)
				return 1
	return 0

/obj/item/weapon/rcd/mounted/attackby()
	return

/obj/item/rig_module/device/rcd
	name = "hardsuit RCD mount"
	desc = "A cell-powered rapid construction device for a hardsuit."
	icon_state = "rcd"
	interface_name = "mounted RCD"
	interface_desc = "A device for building or removing walls. Cell-powered."
	usable = 1
	engage_string = "Configure RCD"
	use_power_cost = 0
	origin_tech = list(TECH_MATERIAL = 6, TECH_MAGNET = 5, TECH_ENGINEERING = 7)
	device_type = /obj/item/weapon/rcd/mounted

/obj/item/rig_module/device/atom_init()
	. = ..()
	if(device_type)
		device = new device_type(src)
		device.canremove = FALSE // fixes some bugs

/obj/item/rig_module/device/engage(atom/target)
	if(!..() || !device)
		return 0

	if(!target)
		device.attack_self(holder.wearer)
		return 1

	var/turf/T = get_turf(target)
	if(istype(T) && !T.Adjacent(get_turf(src)))
		return 0

	var/resolved = target.attackby(device,holder.wearer)
	if(!resolved && device && target)
		device.afterattack(target,holder.wearer,1)
	return 1

/obj/item/rig_module/chem_dispenser
	name = "hardsuit mounted chemical dispenser"
	desc = "A complex web of tubing and needles suitable for hardsuit use."
	icon_state = "injector"
	usable = 1
	selectable = 0
	toggleable = 0
	disruptive = 0
	use_power_cost = 500

	engage_string = "Inject"

	interface_name = "integrated chemical dispenser"
	interface_desc = "Dispenses loaded chemicals directly into the wearer's bloodstream."

	charges = list(
		list("dexalin plus",  "dexalin plus",  "dexalinp",          80),
		list("dylovene",    "dylovene",        "anti_toxin",        80),
		list("hyronalin",     "hyronalin",     "hyronalin",         80),
		list("spaceacillin",   "spaceacillin", "spaceacillin",      80),
		list("tramadol",      "tramadol",      "tramadol",          80),
		list("tricordrazine", "tricordrazine", "tricordrazine",     80)
		)

	var/max_reagent_volume = 80 //Used when refilling.

/obj/item/rig_module/chem_dispenser/ninja
	interface_desc = "Dispenses loaded chemicals directly into the wearer's bloodstream. This variant is made to be extremely light and flexible."

	//just over a syringe worth of each. Want more? Go refill. Gives the ninja another reason to have to show their face.
	charges = list(
		list("dexalin plus",  "dexalin plus",  "dexalinp",          20),
		list("dylovene",    "dylovene",        "anti_toxin",        20),
		list("sugar",       "sugar",           "sugar", 			80),
		list("hyronalin",     "hyronalin",     "hyronalin",         20),
		list("radium",        "radium",        "radium",            20),
		list("spaceacillin",   "spaceacillin", "spaceacillin",      20),
		list("tramadol",      "tramadol",      "tramadol",          20),
		list("tricordrazine", "tricordrazine", "tricordrazine",     20)
	)

/obj/item/rig_module/chem_dispenser/accepts_item(var/obj/item/input_item, var/mob/living/user)

	if(!input_item.is_open_container())
		return 0

	if(!input_item.reagents || !input_item.reagents.total_volume)
		to_chat(user, "\The [input_item] is empty.")
		return 0

	// Magical chemical filtration system, do not question it.
	var/total_transferred = 0
	for(var/datum/reagent/R in input_item.reagents.reagent_list)
		for(var/chargetype in charges)
			var/datum/rig_charge/charge = charges[chargetype]
			if(charge.product_type == R.id)

				var/chems_to_transfer = R.volume

				if((charge.charges + chems_to_transfer) > max_reagent_volume)
					chems_to_transfer = max_reagent_volume - charge.charges

				charge.charges += chems_to_transfer
				input_item.reagents.remove_reagent(R.id, chems_to_transfer)
				total_transferred += chems_to_transfer

				break

	if(total_transferred)
		to_chat(user, "<font color='blue'>You transfer [total_transferred] units into the suit reservoir.</font>")
	else
		to_chat(user, "<span class='danger'>None of the reagents seem suitable.</span>")
	return 1

/obj/item/rig_module/chem_dispenser/engage(atom/target)
	if(!..())
		return 0

	var/mob/living/carbon/human/H = holder.wearer

	if(!charge_selected)
		to_chat(H, "<span class='danger'>You have not selected a chemical type.</span>")
		return 0

	var/datum/rig_charge/charge = charges[charge_selected]

	if(!charge)
		return 0

	var/chems_to_use = 10
	if(charge.charges <= 0)
		to_chat(H, "<span class='danger'>Insufficient chems!</span>")
		return 0
	else if(charge.charges < chems_to_use)
		chems_to_use = charge.charges

	var/mob/living/carbon/target_mob
	if(target)
		if(istype(target,/mob/living/carbon))
			target_mob = target
		else
			return 0
	else
		target_mob = H

	if(target_mob != H)
		to_chat(H, "<span class='danger'>You inject [target_mob] with [chems_to_use] unit\s of [charge.display_name].</span>")
	to_chat(target_mob, "<span class='danger'>You feel a rushing in your veins as [chems_to_use] unit\s of [charge.display_name] [chems_to_use == 1 ? "is" : "are"] injected.</span>")
	target_mob.reagents.add_reagent(charge.product_type, chems_to_use)

	charge.charges -= chems_to_use
	if(charge.charges < 0)
		charge.charges = 0

	return 1

/obj/item/rig_module/chem_dispenser/combat
	name = "hardsuit combat chemical injector"
	desc = "A complex web of tubing and needles suitable for hardsuit use."

	charges = list(
		list("synaptizine", "synaptizine", "synaptizine",        30),
		list("hyperzine",   "hyperzine",   "hyperzine",          30),
		list("oxycodone",   "oxycodone",   "oxycodone", 		 30),
		list("sugar",       "sugar",       "sugar", 			 80)
		)

	interface_name = "combat chem dispenser"
	interface_desc = "Dispenses loaded chemicals directly into the bloodstream."


/obj/item/rig_module/chem_dispenser/injector
	name = "hardsuit mounted chemical injector"
	desc = "A complex web of tubing and a large needle suitable for hardsuit use."
	usable = 0
	selectable = 1
	disruptive = 1

	interface_name = "mounted chem injector"
	interface_desc = "Dispenses loaded chemicals via an arm-mounted injector."

/obj/item/rig_module/cooling_unit
	name = "hardsuit mounted cooling unit"
	toggleable = 1
	origin_tech = list(TECH_MAGNET = 2, TECH_MATERIAL = 2, TECH_ENGINEERING = 5)
	interface_name = "mounted cooling unit"
	interface_desc = "A heat sink with a liquid cooled radiator."
	module_cooldown = 0 SECONDS //no cd because its critical for a life-support module
	var/charge_consumption = 50
	var/max_cooling = 12
	var/thermostat = T20C

/obj/item/rig_module/cooling_unit/process()
	if(!active)
		return passive_power_cost

	var/mob/living/carbon/human/H = holder.wearer

	var/temp_adj = min(H.bodytemperature - thermostat, max_cooling) //Actually copies the original CU code

	if (temp_adj < 0.5)
		return passive_power_cost

	H.bodytemperature -= temp_adj
	active_power_cost = round((temp_adj/max_cooling)*charge_consumption)
	return active_power_cost

/obj/item/rig_module/selfrepair
	name = "hardsuit self-repair module"
	desc = "A somewhat complicated looking complex full of tools."
	icon_state = "scanner"
	interface_name = "self-repair module"
	interface_desc = "A module capable of repairing stuctural rig damage on the spot."
	engage_string = "Begin repair"
	usable = 1
	selectable = 0
	use_power_cost = 0
	module_cooldown = 0
	origin_tech = list(TECH_MATERIAL = 4, TECH_MAGNET = 4, TECH_ENGINEERING = 6)

	charges = list(
		list("metal", "metal", "metal", 30),
	)
	charge_selected = 0

/obj/item/rig_module/selfrepair/engage()
	if(!..())
		return 0

	var/mob/living/carbon/human/H = holder.wearer

	if(active)
		to_chat(H, "<span class='danger'>Self-repair in already active.</span>")
		return 0

	if(!charge_selected)
		to_chat(H, "<span class='danger'>You have not selected a material type.</span>")
		return 0

	var/datum/rig_charge/charge = charges[charge_selected]

	if(!charge)
		return 0

	if(holder.brute_damage || holder.burn_damage)
		active = TRUE
		to_chat(H, "<span class='notice'>Starting self-repair sequence</span>")

	return 1

/obj/item/rig_module/selfrepair/process()
	if(!active)
		return passive_power_cost

	var/mob/living/carbon/human/H = holder.wearer

	if(!holder.brute_damage && !holder.burn_damage)
		deactivate()
		to_chat(H, "<span class='notice'>Self-repair is completed</span>")
		return passive_power_cost

	if(!charge_selected)
		deactivate()
		return 0

	var/datum/rig_charge/charge = charges[charge_selected]

	if(!charge)
		deactivate()
		return 0

	active_power_cost = passive_power_cost
	if(holder.brute_damage && charge.charges > 0)
		var/chargeuse = min(charge.charges, 3)

		charge.charges -= chargeuse
		holder.repair_breaches(BRUTE, chargeuse, H, stop_messages = TRUE)

		active_power_cost = chargeuse * 200
	else if(holder.burn_damage && charge.charges > 0)
		var/chargeuse = min(charge.charges, 3)

		charge.charges -= chargeuse
		holder.repair_breaches(BURN, chargeuse, H, stop_messages = TRUE)

		active_power_cost = chargeuse * 200
	else
		deactivate()
		to_chat(H, "<span class='danger'>Not enough materials to continue self-repair</span>")

	return active_power_cost

/obj/item/rig_module/selfrepair/accepts_item(var/obj/item/input_item, var/mob/living/user)
	var/mob/living/carbon/human/H = holder.wearer

	if(istype(input_item, /obj/item/stack/sheet/metal) && istype(H) && user == H)
		var/obj/item/stack/sheet/metal/metal = input_item
		var/datum/rig_charge/charge = charges[1]

		var/total_used = 30
		total_used = min(total_used, 30 - charge.charges)
		total_used = min(total_used, metal.get_amount())

		metal.use(total_used)
		if(total_used)
			to_chat(user, "<font color='notice'>You transfer [total_used] of metal lists into the suit reservoir.</font>")
		return 1

	return 0