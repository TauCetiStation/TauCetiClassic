/obj/item/rig_module/device
	name = "mounted device"
	desc = "Some kind of hardsuit mount."
	usable = FALSE
	selectable = TRUE
	toggleable = FALSE

	var/device_type
	var/obj/item/device

/obj/item/rig_module/device/healthscanner
	name = "hardsuit health scanner module"
	desc = "A hardsuit-mounted health scanner."
	icon_state = "scanner"
	interface_name = "health scanner"
	interface_desc = "Shows an informative health readout when used on a subject."
	use_power_cost = 100
	origin_tech = "biotech=2;programming=2"
	device_type = /obj/item/device/healthanalyzer

/obj/item/rig_module/device/drill
	name = "hardsuit drill mount"
	desc = "A very heavy diamond-tipped drill."
	icon_state = "drill"
	suit_overlay = "mounted-drill"
	interface_name = "mounted drill"
	interface_desc = "A diamond-tipped industrial drill."
	use_power_cost = 200
	origin_tech = "materials=5;powerstorage=3;engineering=3;programming=2"
	device_type = /obj/item/weapon/pickaxe/drill/jackhammer // this one doesn't use energy

/obj/item/rig_module/device/anomaly_scanner
	name = "hardsuit anomaly scanner module"
	desc = "You think it's called an Elder Sarsparilla or something."
	icon_state = "eldersasparilla"
	interface_name = "Alden-Saraspova counter"
	interface_desc = "An exotic particle detector commonly used by xenoarchaeologists."
	engage_string = "Begin Scan"
	use_power_cost = 200
	usable = TRUE
	selectable = FALSE
	device_type = /obj/item/device/ano_scanner
	origin_tech = "magnets=3;programming=2"

/obj/item/rig_module/device/orescanner
	name = "hardsuit ore scanner module"
	desc = "A clunky old ore scanner."
	icon_state = "scanner"
	interface_name = "ore detector"
	interface_desc = "A sonar system for detecting large masses of ore."
	engage_string = "Begin Scan"
	usable = TRUE
	selectable = FALSE
	use_power_cost = 200
	device_type = /obj/item/weapon/mining_scanner
	origin_tech = "magnets=2;programming=2;engineering=2"

/obj/item/weapon/rcd/mounted/useResource(amount, mob/user)
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
	usable = TRUE
	engage_string = "Configure RCD"
	use_power_cost = 0
	origin_tech = "magnets=5;programming=4;engineering=4;powerstorage=4"
	device_type = /obj/item/weapon/rcd/mounted

/obj/item/rig_module/device/atom_init()
	. = ..()
	if(device_type)
		device = new device_type(src)
		device.canremove = FALSE // so we can't place mounted devices on tables/racks
		device.w_class = ITEM_SIZE_NO_CONTAINER // so we can't put mounted devices into backpacks
		device.origin_tech = null // so we can't put them into destructive analyzer
		device.m_amt = 0 // so we can't put them into autolathe
		device.g_amt = 0

/obj/item/rig_module/device/engage(atom/target)
	if(!..() || !device)
		return 0

	if(damage > MODULE_NO_DAMAGE && prob(20))
		to_chat(holder.wearer, "<span class='warning'>[name] malfunctions and ignores your command!</span>")
		return 1

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
	suit_overlay = "mounted-injector"
	usable = TRUE
	selectable = FALSE
	toggleable = FALSE
	use_power_cost = 500
	mount_type = MODULE_MOUNT_INJECTOR
	origin_tech = "biotech=2;programming=3"

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

/obj/item/rig_module/chem_dispenser/accepts_item(obj/item/input_item, mob/living/user)

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

	if(!charge_selected)
		to_chat(holder.wearer, "<span class='danger'>You have not selected a chemical type.</span>")
		return 0

	return use_charge(charge_selected, target)

/obj/item/rig_module/chem_dispenser/proc/use_charge(charge_selected, atom/target, show_warnings = TRUE)
	var/mob/living/carbon/human/H = holder.wearer

	var/datum/rig_charge/charge = charges[charge_selected]
	if(damage > MODULE_NO_DAMAGE && prob(40))
		to_chat(H, "<span class='warning'>[name] malfunctions and injects wrong chemical!</span>")
		charge = charges[pick(charges)]

	if(!charge)
		return FALSE

	var/chems_to_use = 10
	if(charge.charges <= 0)
		if(show_warnings)
			to_chat(H, "<span class='danger'>Insufficient chems!</span>")
		return FALSE
	else if(charge.charges < chems_to_use)
		chems_to_use = charge.charges

	var/mob/living/carbon/target_mob
	if(target)
		if(istype(target,/mob/living/carbon))
			target_mob = target
		else
			return FALSE
	else
		target_mob = H

	if(target_mob != H)
		to_chat(H, "<span class='danger'>You inject [target_mob] with [chems_to_use] unit\s of [charge.display_name].</span>")
	to_chat(target_mob, "<span class='danger'>You feel a rushing in your veins as [chems_to_use] unit\s of [charge.display_name] [chems_to_use == 1 ? "is" : "are"] injected.</span>")
	target_mob.reagents.add_reagent(charge.product_type, chems_to_use)

	charge.charges -= chems_to_use
	if(charge.charges < 0)
		charge.charges = 0
	return TRUE

/obj/item/rig_module/chem_dispenser/combat
	name = "hardsuit combat chemical injector"
	desc = "A complex web of tubing and needles suitable for hardsuit use."
	suit_overlay = null // hidden

	charges = list(
		list("tricordrazine", "tricordrazine", "tricordrazine",      30),
		list("inaprovaline",  "inaprovaline",  "inaprovaline",       30),
		list("tramadol",      "tramadol",      "tramadol", 		     30),
		list("dexalin",       "dexalin",       "dexalin", 	     	 30),
		)

	interface_name = "combat chem dispenser"
	interface_desc = "Dispenses loaded chemicals directly into the bloodstream."


/obj/item/rig_module/chem_dispenser/medical // starts almost empty but could be loaded with a lot of different chemicals
	name = "hardsuit mounted chemical injector"
	desc = "A complex web of tubing and needles suitable for hardsuit use."
	selectable = TRUE // Also can inject others

	charges = list(
		list("tricordrazine", "tricordrazine", "tricordrazine",      30),
		list("inaprovaline",  "inaprovaline",  "inaprovaline",       30),
		list("tramadol",      "tramadol",      "tramadol", 		     30),
		list("dexalin",       "dexalin",       "dexalin", 	     	 30),
		list("dexalin plus",  "dexalin plus",  "dexalinp",           0),
		list("dylovene",      "dylovene",      "anti_toxin",         0),
		list("kelotane",      "kelotane",      "kelotane",           0),
		list("dermaline",     "dermaline",     "dermaline",          0),
		list("bicaridine",    "bicaridine",    "bicaridine",         0),
		list("oxycodone",     "oxycodone",     "oxycodone",          0),
		list("hyperzine",     "hyperzine",     "hyperzine",          0),
		)

	interface_name = "medical chem dispenser"
	interface_desc = "Dispenses loaded chemicals directly into the bloodstream."

/obj/item/rig_module/cooling_unit
	name = "hardsuit mounted cooling unit"
	toggleable = TRUE
	origin_tech = list(TECH_MAGNET = 2, TECH_MATERIAL = 2, TECH_ENGINEERING = 5)
	interface_name = "mounted cooling unit"
	interface_desc = "A heat sink with a liquid cooled radiator."
	module_cooldown = 0 SECONDS //no cd because its critical for a life-support module
	var/charge_consumption = 50
	var/max_cooling = 12
	var/thermostat = T20C

/obj/item/rig_module/cooling_unit/process_module()
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
	activate_string = "Begin repair"
	deactivate_string = "Stop repair"
	toggleable = TRUE
	usable = FALSE
	selectable = FALSE
	use_power_cost = 0
	module_cooldown = 0
	origin_tech = "engineering=3;programming=3"

	charges = list(
		list("metal", "metal", "metal", 30),
	)
	charge_selected = 0

/obj/item/rig_module/selfrepair/activate(forced = FALSE)
	if(!..())
		return 0

	var/mob/living/carbon/human/H = holder.wearer

	to_chat(H, "<span class='notice'>Starting self-repair sequence</span>")

	return 1

/obj/item/rig_module/selfrepair/process_module()
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

		active_power_cost = chargeuse * 150
	else if(holder.burn_damage && charge.charges > 0)
		var/chargeuse = min(charge.charges, 3)

		charge.charges -= chargeuse
		holder.repair_breaches(BURN, chargeuse, H, stop_messages = TRUE)

		active_power_cost = chargeuse * 150
	else
		deactivate()
		to_chat(H, "<span class='danger'>Not enough materials to continue self-repair</span>")

	return active_power_cost

/obj/item/rig_module/selfrepair/accepts_item(obj/item/input_item, mob/living/user)
	var/mob/living/carbon/human/H = holder.wearer

	if(istype(input_item, /obj/item/stack/sheet/metal) && istype(H) && user == H)
		var/obj/item/stack/sheet/metal/metal = input_item
		var/datum/rig_charge/charge = charges[charges[1]]

		var/total_used = 30
		total_used = min(total_used, 30 - charge.charges)
		total_used = min(total_used, metal.get_amount())

		metal.use(total_used)
		charge.charges += total_used
		if(total_used)
			to_chat(user, "<font color='notice'>You transfer [total_used] of metal lists into the suit reservoir.</font>")
		return 1

	return 0

/obj/item/rig_module/med_teleport
	name = "hardsuit medical teleport system"
	origin_tech = "programming=2;materials=2;bluespace=1"
	interface_name = "automated medical teleport system"
	interface_desc = "System capable of saving the suit owner. But only once"
	icon_state = "teleporter"

	var/preparing = FALSE
	var/teleport_timer = 0

/obj/item/rig_module/med_teleport/process_module()
	var/mob/living/carbon/human/H = holder.wearer
	if(!H || damage>=MODULE_DESTROYED)
		preparing = FALSE
		return

	var/should_work = (H.health < config.health_threshold_crit && H.stat != CONSCIOUS)
	if(should_work)
		if(!preparing)
			preparing = TRUE
			teleport_timer = 0

		teleport_timer++
		if(teleport_timer == 55)
			to_chat(H, "<span class='danger'>Automated medical teleport system attempts to teleport your body...</span>")

		if(teleport_timer > 60)
			if(damage > MODULE_NO_DAMAGE)
				if(prob(50))
					to_chat(H, "<span class='danger'>Medical teleport system malfunctions and fails to teleport you</span>")
					teleport_timer = 0
					return

			var/obj/item/device/beacon/medical/target_beacon
			for(var/obj/item/device/beacon/medical/medical in beacon_medical_list)
				if(medical)
					if(isturf(medical.loc))
						var/area/A = get_area(medical)
						if(istype(A, /area/medical/sleeper))
							target_beacon = medical
							break
			if(target_beacon)
				if(H.wear_suit == holder) // rig stays
					H.remove_from_mob(holder)
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				var/datum/effect/effect/system/spark_spread/s2 = new /datum/effect/effect/system/spark_spread
				s.set_up(3, 1, H)
				s2.set_up(3, 1, target_beacon)
				s.start()
				s2.start()
				H.forceMove(get_turf(target_beacon))
			else
				to_chat(H, "<span class='danger'>Medical teleport system fails to teleport your body because there were no medical beacons in medbay</span>")
			holder.installed_modules -= src
			qdel(src) // We are done
	else
		preparing = FALSE

/obj/item/rig_module/nuclear_generator
	name = "hardsuit nuclear reactor module"
	desc = "Looks like a small machine of doom"
	origin_tech = "programming=4;engineering=4;bluespace=4;powerstorage=4"
	interface_name = "compact nuclear reactor"
	interface_desc = "Passively generates energy. Becomes very unstable if damaged"
	mount_type = MODULE_MOUNT_CHEST
	icon_state = "nuclear"
	suit_overlay = "nuclear"

	passive_power_cost = -50
	var/unstable = FALSE

/obj/item/rig_module/nuclear_generator/process_module()
	if(damage == MODULE_DAMAGED && prob(2))
		if(holder.wearer)
			to_chat(holder.wearer, "<span class='warning'>Your damaged [name] irradiates you</span>")
			holder.wearer.apply_effect(rand(5, 25), IRRADIATE, 0)

	if(damage >= MODULE_DESTROYED)
		if(!unstable)

			if(holder.wearer)
				holder.wearer.visible_message("<span class='warning'>The nuclear reactor inside [holder.wearer]'s [holder] is gloving red and looks very unstable</span>")
				to_chat(holder.wearer, "<span class='danger'>\[DANGER\] Your [name] is unstable and will explode in about a minute, remove your suit immediately</span>")
				message_admins("[key_name_admin(holder.wearer)]'s [holder] has a damaged [name] that will explode in about a minute [ADMIN_JMP(src)]")
			else
				holder.visible_message("<span class='warning'>The nuclear reactor inside [holder] is gloving red and looks very unstable</span>")
			unstable = TRUE
			addtimer(CALLBACK(src, .proc/boom), rand(60 SECONDS, 120 SECONDS))
			light_color = LIGHT_COLOR_FLARE
			set_light(5)

	return passive_power_cost

/obj/item/rig_module/nuclear_generator/proc/boom()
	if(unstable)
		explosion(loc,1,2,4,5) // syndicate minibomb

		if(holder)
			holder.installed_modules -= src
		qdel(src)