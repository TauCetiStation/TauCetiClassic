/obj/item/rig_module/device
	name = "mounted device"
	desc = "Some kind of hardsuit mount."
	usable = FALSE
	selectable = TRUE
	toggleable = FALSE

	var/device_type
	var/obj/item/device
	var/need_adjacent = TRUE

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
	use_power_cost = 100 // normal drills use 15 energy, we mine 3 turfs at a time
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
				return TRUE
	return FALSE

/obj/item/weapon/rcd/mounted/checkResource(amount, mob/user)
	var/cost = amount*70
	if(istype(loc,/obj/item/rig_module))
		var/obj/item/rig_module/module = loc
		if(module.holder && module.holder.cell)
			if(module.holder.cell.charge >= cost)
				return TRUE
	return FALSE

/obj/item/weapon/rcd/mounted/attackby(obj/item/I, mob/user, params)
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
	if(!isturf(holder.wearer.loc) && target)
		return FALSE

	if(!..() || !device)
		return FALSE

	if(damage > MODULE_NO_DAMAGE && prob(20))
		to_chat(holder.wearer, "<span class='warning'>[name] malfunctions and ignores your command!</span>")
		return TRUE

	if(!target)
		device.attack_self(holder.wearer)
		return TRUE

	var/turf/T = get_turf(target)
	if(need_adjacent && istype(T) && !T.Adjacent(get_turf(src)))
		return FALSE

	var/resolved
	if(need_adjacent) // so we don't telepathically bash the target
		resolved = target.attackby(device,holder.wearer)
	if(!resolved && device && target)
		device.afterattack(target,holder.wearer,1)
	return TRUE

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

	var/max_reagent_volume = 80 //Used when refilling.

/obj/item/rig_module/chem_dispenser/init_charges()
	charges = list()
	charges["dexalin plus"]  = new /datum/rig_charge("dexalin plus",  "dexalinp",      80)
	charges["dylovene"]      = new /datum/rig_charge("dylovene",      "anti_toxin",    80)
	charges["hyronalin"]     = new /datum/rig_charge("hyronalin",     "hyronalin",     80)
	charges["spaceacillin"]  = new /datum/rig_charge("spaceacillin",  "spaceacillin",  80)
	charges["tramadol"]      = new /datum/rig_charge("tramadol",      "tramadol",      80)
	charges["tricordrazine"] = new /datum/rig_charge("tricordrazine", "tricordrazine", 80)

/obj/item/rig_module/chem_dispenser/ninja
	interface_desc = "Dispenses loaded chemicals directly into the wearer's bloodstream. This variant is made to be extremely light and flexible."

/obj/item/rig_module/chem_dispenser/ninja/init_charges()
	//just over a syringe worth of each. Want more? Go refill. Gives the ninja another reason to have to show their face.
	charges = list()
	charges["dexalin plus"]  = new /datum/rig_charge("dexalin plus",  "dexalinp",      20)
	charges["dylovene"]      = new /datum/rig_charge("dylovene",      "anti_toxin",    20)
	charges["sugar"]         = new /datum/rig_charge("sugar",         "sugar",         80)
	charges["hyronalin"]     = new /datum/rig_charge("hyronalin",     "hyronalin",     20)
	charges["radium"]        = new /datum/rig_charge("radium",        "radium",        20)
	charges["spaceacillin"]  = new /datum/rig_charge("spaceacillin",  "spaceacillin",  20)
	charges["tramadol"]      = new /datum/rig_charge("tramadol",      "tramadol",      20)
	charges["tricordrazine"] = new /datum/rig_charge("tricordrazine", "tricordrazine", 20)

/obj/item/rig_module/chem_dispenser/accepts_item(obj/item/input_item, mob/living/user)

	if(!input_item.is_open_container())
		return FALSE

	if(!input_item.reagents || !input_item.reagents.total_volume)
		to_chat(user, "\The [input_item] is empty.")
		return FALSE

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
		return FALSE
	return TRUE

/obj/item/rig_module/chem_dispenser/engage(atom/target)
	if(!isturf(holder.wearer.loc) && target)
		return FALSE

	if(!..())
		return FALSE

	if(!charge_selected)
		to_chat(holder.wearer, "<span class='danger'>You have not selected a chemical type.</span>")
		return FALSE

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

	interface_name = "combat chem dispenser"
	interface_desc = "Dispenses loaded chemicals directly into the bloodstream."

/obj/item/rig_module/chem_dispenser/combat/init_charges()
	charges = list()
	charges["tricordrazine"] = new /datum/rig_charge("tricordrazine", "tricordrazine", 30)
	charges["inaprovaline"]  = new /datum/rig_charge("inaprovaline",  "inaprovaline",  30)
	charges["tramadol"]      = new /datum/rig_charge("tramadol",      "tramadol",      30)
	charges["dexalin"]       = new /datum/rig_charge("dexalin",       "dexalin",       30)

/obj/item/rig_module/chem_dispenser/medical
	name = "hardsuit mounted chemical injector"
	desc = "A complex web of tubing and needles suitable for hardsuit use."
	selectable = TRUE // Also can inject others

	interface_name = "medical chem dispenser"
	interface_desc = "Dispenses loaded chemicals directly into the bloodstream."

/obj/item/rig_module/chem_dispenser/medical/init_charges()
	// starts almost empty but could be loaded with a lot of different chemicals
	charges = list()
	charges["tricordrazine"] = new /datum/rig_charge("tricordrazine", "tricordrazine", 30)
	charges["inaprovaline"]  = new /datum/rig_charge("inaprovaline",  "inaprovaline",  30)
	charges["tramadol"]      = new /datum/rig_charge("tramadol",      "tramadol",      30)
	charges["dexalin"]       = new /datum/rig_charge("dexalin",       "dexalin",       30)
	charges["dexalin plus"]  = new /datum/rig_charge("dexalin plus",  "dexalinp",      0)
	charges["dylovene"]      = new /datum/rig_charge("dylovene",      "anti_toxin",    0)
	charges["kelotane"]      = new /datum/rig_charge("kelotane",      "kelotane",      0)
	charges["dermaline"]     = new /datum/rig_charge("dermaline",     "dermaline",     0)
	charges["bicaridine"]    = new /datum/rig_charge("bicaridine",    "bicaridine",    0)
	charges["oxycodone"]     = new /datum/rig_charge("oxycodone",     "oxycodone",     0)
	charges["hyperzine"]     = new /datum/rig_charge("hyperzine",     "hyperzine",     0)

/obj/item/rig_module/chem_dispenser/medical/ert // variant for the medical ert rigs
	name = "hardsuit mounted chemical injector"

/obj/item/rig_module/chem_dispenser/medical/ert/init_charges()
	charges = list()
	charges["tricordrazine"] = new /datum/rig_charge("tricordrazine", "tricordrazine", 30)
	charges["inaprovaline"]  = new /datum/rig_charge("inaprovaline",  "inaprovaline",  30)
	charges["tramadol"]      = new /datum/rig_charge("tramadol",      "tramadol",      30)
	charges["dexalin plus"]  = new /datum/rig_charge("dexalin plus",  "dexalinp",      30)
	charges["dylovene"]      = new /datum/rig_charge("dylovene",      "anti_toxin",    30)
	charges["kelotane"]      = new /datum/rig_charge("kelotane",      "kelotane",      30)
	charges["bicaridine"]    = new /datum/rig_charge("bicaridine",    "bicaridine",    30)

/obj/item/rig_module/cooling_unit
	name = "hardsuit mounted cooling unit"
	icon_state = "cloak"
	toggleable = TRUE
	origin_tech = "engineering=3;programming=3"
	interface_name = "mounted cooling unit"
	interface_desc = "A heat sink with a liquid cooled radiator."
	module_cooldown = 0 SECONDS //no cd because its critical for a life-support module
	show_toggle_button = TRUE
	activate_string = "Begin cooling"
	deactivate_string = "Stop cooling"
	var/charge_consumption = 200
	var/max_cooling = 30 // uses way more energy, cools better
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
	icon_state = "selfrepair"
	interface_name = "self-repair module"
	interface_desc = "A module capable of repairing stuctural rig damage on the spot."
	activate_string = "Begin repair"
	deactivate_string = "Stop repair"
	toggleable = TRUE
	usable = FALSE
	selectable = FALSE
	show_toggle_button = TRUE
	use_power_cost = 0
	module_cooldown = 0
	origin_tech = "engineering=3;programming=3"

/obj/item/rig_module/selfrepair/init_charges()
	charges = list()
	charges["metal"] = new /datum/rig_charge("metal", "metal", 30)

/obj/item/rig_module/selfrepair/activate(forced = FALSE)
	if(!..())
		return FALSE

	var/mob/living/carbon/human/H = holder.wearer

	to_chat(H, "<span class='notice'>Starting self-repair sequence</span>")

	return TRUE

/obj/item/rig_module/selfrepair/process_module()
	if(!active)
		return passive_power_cost

	var/mob/living/carbon/human/H = holder.wearer

	if(!holder.brute_damage && !holder.burn_damage)
		deactivate()
		to_chat(H, "<span class='notice'>Self-repair is completed</span>")
		return passive_power_cost

	var/datum/rig_charge/charge = charges["metal"]

	if(!charge)
		deactivate()
		return FALSE

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
		var/datum/rig_charge/charge = charges["metal"]

		var/total_used = 30
		total_used = min(total_used, 30 - charge.charges)
		total_used = min(total_used, metal.get_amount())

		metal.use(total_used)
		charge.charges += total_used
		if(total_used)
			to_chat(user, "<font color='notice'>You transfer [total_used] of metal lists into the suit reservoir.</font>")
		return TRUE

	return FALSE

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
						if(istype(A, /area/station/medical/sleeper))
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

/obj/item/weapon/reagent_containers/spray/extinguisher/mounted
	volume = 400

/obj/item/weapon/reagent_containers/spray/extinguisher/mounted/atom_init()
	. = ..()
	flags |= OPENCONTAINER

/obj/item/rig_module/device/extinguisher
	name = "hardsuit fire extinguisher"
	desc = "Hardsuit mounted fire extinguisher designed to work in hazardous environments."
	icon_state = "extinguisher"
	interface_name = "fire extinguisher"
	interface_desc = "Hardsuit mounted fire extinguisher."
	use_power_cost = 20
	module_cooldown = 5
	origin_tech = "materials=1;engineering=1;programming=2"
	device_type = /obj/item/weapon/reagent_containers/spray/extinguisher/mounted
	need_adjacent = FALSE

/obj/item/rig_module/device/extinguisher/init_charges()
	charges = list()
	charges["aqueous_foam"] = new /datum/rig_charge("Aqueous Film Forming Foam", "aqueous_foam", 0) // syncs with the extinguisher

/obj/item/rig_module/device/extinguisher/atom_init()
	. = ..()
	if(device)
		var/obj/item/weapon/reagent_containers/spray/extinguisher/ext = device
		ext.safety = FALSE
		charges["aqueous_foam"].charges = ext.reagents.total_volume

/obj/item/rig_module/device/extinguisher/engage(atom/target)
	. = ..()
	if(device)
		addtimer(CALLBACK(src, .proc/update_foam_ammount), 5) // because extinguisher uses spawns

/obj/item/rig_module/device/extinguisher/proc/update_foam_ammount()
	if(device)
		var/obj/item/weapon/reagent_containers/spray/extinguisher/ext = device
		charges["aqueous_foam"].charges = ext.reagents.total_volume

/obj/item/rig_module/metalfoam_spray
	name = "hardsuit metal foam spray"
	desc = "Hardsuit mounted metal foam spray designed to quickly patch holes."
	icon_state = "metalfoam_spray"
	interface_name = "metal foam spray"
	interface_desc = "Hardsuit mounted metal foam spray designed to quickly patch holes."
	use_power_cost = 100
	module_cooldown = 5
	origin_tech = "materials=2;engineering=2;programming=2"
	usable = FALSE
	selectable = TRUE
	toggleable = FALSE
	var/per_use = 5
	var/spray_ammount = 0 // 0 does 1x1 tile
	var/max_volume = 100

/obj/item/rig_module/metalfoam_spray/init_charges()
	charges = list()
	charges["foaming agent"] = new /datum/rig_charge("foaming agent", "foaming agent", 40)

/obj/item/rig_module/metalfoam_spray/engage(atom/target)
	if(!isturf(holder.wearer.loc) && target)
		return FALSE

	if(!..())
		return FALSE

	if(damage > MODULE_NO_DAMAGE && prob(50))
		to_chat(holder.wearer, "<span class='warning'>[name] malfunctions and ignores your command!</span>")
		return TRUE

	if(!target)
		return FALSE

	if(charges["foaming agent"].charges <= 0)
		to_chat(holder.wearer, "<span class='warning'>[interface_name] is empty</span>")
		return FALSE

	var/turf/T = get_turf(target)
	if(!istype(T))
		return FALSE

	charges["foaming agent"].charges = max(charges["foaming agent"].charges - per_use, 0)
	playsound(src, 'sound/effects/spray2.ogg', VOL_EFFECTS_MASTER, null, null, -6)
	INVOKE_ASYNC(src, .proc/spray_at, T)

	return TRUE

/obj/item/rig_module/metalfoam_spray/proc/spray_at(turf/T)
	var/obj/effect/decal/chempuff/D = new/obj/effect/decal/chempuff(get_turf(src))
	D.icon += "#989da0"

	step_towards(D, T)
	sleep(5)
	var/datum/effect/effect/system/foam_spread/s = new()
	s.set_up(spray_ammount, D.loc, metalfoam = 1)
	s.start()
	qdel(D)

/obj/item/rig_module/metalfoam_spray/accepts_item(obj/item/input_item, mob/living/user)

	if(!input_item.is_open_container())
		return FALSE

	if(!input_item.reagents || !input_item.reagents.total_volume)
		return FALSE

	var/datum/rig_charge/charge = charges["foaming agent"]

	var/total_transferred = min(input_item.reagents.get_reagent_amount("foaming_agent"), max_volume - charge.charges)
	if(total_transferred <= 0)
		return FALSE

	charge.charges += total_transferred
	input_item.reagents.remove_reagent("foaming_agent", total_transferred)

	to_chat(user, "<font color='blue'>You transfer [total_transferred] units into the [interface_name].</font>")
	return TRUE

/obj/item/rig_module/stealth
	name = "hardsuit stealth system"
	desc = "System that makes hardsuit invisible."
	interface_name = "Turn invisibility"
	interface_desc = "System that makes hardsuit invisible."
	origin_tech = "engineering=6;programming=6;bluespace=6;combat=6;phorontech=6"
	active_power_cost = 55
	permanent = TRUE
	show_toggle_button = TRUE
	toggleable = TRUE
	activate_string = "Invisibility On"
	deactivate_string = "Invisibility Off"
	module_cooldown = 30 SECONDS

/obj/item/rig_module/stealth/activate(forced = FALSE)
	if(!..())
		return FALSE
	if(holder.wearer.is_busy())
		return FALSE

	var/mob/living/carbon/human/H = holder.wearer
	holder.canremove = FALSE
	to_chat(H, "<span class='notice'>Starting invisibility protocol, please wait until it done.</span>")
	if(do_after(H, 40, target = H))
		if(!active)
			to_chat(H, "<span class='danger'>ERROR! Invisibility protocol has been stoped.</span>")
			return FALSE
		to_chat(H, "<span class='notice'>Invisibility protocol has been engaged.</span>")
		holder.wearer.alpha = 4
		return TRUE

/obj/item/rig_module/stealth/deactivate()
	. = ..()
	if(!.)
		return FALSE

	holder.canremove = TRUE
	holder.wearer.alpha = 255

	return TRUE
