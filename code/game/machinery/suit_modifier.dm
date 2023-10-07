/obj/machinery/suit_modifier
	name 			   = "Suit Modifier Unit"
	desc 			   = "An industrial Suit Modifier Unit, to modifi your hardsuit."
	icon 			   = 'icons/obj/suitstorage.dmi'
	icon_state 		   = "industrial"
	damage_deflection  = 35

	anchored 		   = TRUE
	density 		   = TRUE
	var/opened 		   = FALSE
	var/active 		   = TRUE
	var/recharge_coeff = 4

	var/obj/item/clothing/suit/space/rig/suit 			= null

// -== Regular Stuff ==-
	var/list/modulesAvalible = list(
		new /obj/item/rig_module/device/extinguisher(null),
		new /obj/item/rig_module/device/healthscanner(null),
		new /obj/item/rig_module/device/analyzer(null),
		new /obj/item/rig_module/device/science_tool(null),
		new /obj/item/rig_module/device/drill(null),
		new /obj/item/rig_module/device/anomaly_scanner(null),
		new /obj/item/rig_module/device/orescanner(null),
		new /obj/item/rig_module/device/rcd(null),
		new /obj/item/rig_module/chem_dispenser,
		new /obj/item/rig_module/chem_dispenser/combat(null),
		new /obj/item/rig_module/cooling_unit(null),
		new /obj/item/rig_module/teleporter_stabilizer(null),
		new /obj/item/rig_module/selfrepair(null),
		new /obj/item/rig_module/med_teleport(null),
		new /obj/item/rig_module/simple_ai(null),
		new /obj/item/rig_module/simple_ai/advanced(null),
		new /obj/item/rig_module/emp_shield(null),
		new /obj/item/rig_module/nuclear_generator(null),
		new /obj/item/rig_module/mounted_relay(null),
		new /obj/item/rig_module/metalfoam_spray(null))
	var/list/cellsToBuy = list(
		new /obj/item/weapon/stock_parts/cell/high(null),
		new /obj/item/weapon/stock_parts/cell/super(null),
		new /obj/item/weapon/stock_parts/cell/hyper(null)
	)
//  Not using. Maybe next time
	var/list/helmetModulesToBuy = list()

// -== Syndicate Stuff ==-
	var/list/syndicateModulesAvalible = list(
		new /obj/item/rig_module/emp_shield/adv(null),
		new /obj/item/rig_module/mounted(null),
		new /obj/item/rig_module/grenade_launcher(null),
		new /obj/item/rig_module/syndiemmessage)
	var/syndicateModulesCount = 2

/obj/machinery/suit_modifier/atom_init()
	. = ..()
	update_icon()

/obj/machinery/suit_modifier/update_icon()
	cut_overlays()
	if(active)
		add_overlay("industrial_ready")
	else
		add_overlay("industrial_unready")
	if(opened)
		add_overlay("industrial_open")
		if(suit)
			add_overlay("industrial_loaded")
	else
		cut_overlay("industrial_open")

/obj/machinery/suit_modifier/proc/ejectSuit()
	if(!suit)
		return
	else
		suit.forceMove(get_turf(src))
		suit = null
		update_icon()
		return

/obj/machinery/suit_modifier/proc/speak(message)
	if((stat & NOPOWER) || !message)
		return
	audible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"</span>", runechat_msg = TRUE)

/obj/machinery/suit_modifier/proc/repair(obj/R, mob/user)
	var/obj/item/clothing/suit/space/rig/RIG = R
	var/power_used = 10000
	while(RIG.breaches.len)
		RIG.repair_breaches(BRUTE, power_used, user, stop_messages = TRUE)
		RIG.repair_breaches(BURN,  power_used, user, stop_messages = TRUE)
	var/list/modules = RIG.installed_modules
	for(var/obj/item/rig_module/module in modules)
		if(module.damage > MODULE_NO_DAMAGE)
			module.damage = MODULE_NO_DAMAGE
	speak("Hardsuit and internal modules successful repaired.")

/obj/machinery/suit_modifier/proc/mountSyndicateModule(obj/R, mob/user)
	var/obj/item/clothing/suit/space/rig/RIG = R
	for(var/atom/selectModule as anything in syndicateModulesAvalible)
		syndicateModulesAvalible[selectModule] = image(icon = selectModule.icon, icon_state = selectModule.icon_state)

	var/obj/item/rig_module/toInstallModule = show_radial_menu(user, src, syndicateModulesAvalible, require_near = TRUE, tooltips = TRUE)

	if(!toInstallModule)
		return
	else if(RIG.can_install(toInstallModule))
		toInstallModule.installed(RIG)
	else if(RIG.detach_module(user, RIG.installed_modules, src))
		toInstallModule.installed(RIG)
	else
		return

	syndicateModulesCount--
	if(prob(15))
		speak("Whiskey. Echo. Whiskey.")
		sleep(2 SECOND)
		speak("Lima. Alpha. Delta.")

/obj/machinery/suit_modifier/proc/buyModule(obj/R, mob/user)
	var/obj/item/clothing/suit/space/rig/RIG = R
	for(var/atom/selectModule as anything in modulesAvalible)
		modulesAvalible[selectModule] = image(icon = selectModule.icon, icon_state = selectModule.icon_state)

	var/obj/item/rig_module/toBuyModule = show_radial_menu(user, src, modulesAvalible, require_near = TRUE, tooltips = TRUE)

	if(!toBuyModule)
		return
	else if(RIG.can_install(toBuyModule))
		toBuyModule.installed(RIG)
	else if(RIG.detach_module(user, RIG.installed_modules, src))
		toBuyModule.installed(RIG)

/obj/machinery/suit_modifier/proc/modifyRace(obj/R, atom/target_species)
	speak("Selected [target_species] modkit.")
	var/obj/item/clothing/suit/space/rig/RIG = R
	RIG.refit_for_species(target_species)
	RIG.helmet.refit_for_species(target_species)

/obj/machinery/suit_modifier/proc/selectRace(obj/C, mob/user)
	var/obj/item/clothing/suit/space/rig/RIG = C
	var/list/modifySelect = list()
	var/list/speciesAvailable = RIG.species_restricted
	speciesAvailable.Remove(DIONA)
	if(emagged && prob(10))
		speak("You`re one ugly motherfucker.")
	else
		speak("You're the only cute user!")
	for(var/species in speciesAvailable)
		var/icon_path = RIG.sprite_sheets_obj[species]
		modifySelect[species] += image(icon = icon_path, icon_state = C.icon_state)

	var/toModify = show_radial_menu(user, src, modifySelect, require_near = TRUE, tooltips = TRUE)
	switch(toModify)
		if("Human")
			modifyRace(RIG, HUMAN)
		if("Skrell")
			modifyRace(RIG, SKRELL)
		if("Tajaran")
			modifyRace(RIG, TAJARAN)
		if("Unathi")
			modifyRace(RIG, UNATHI)
		if("Vox")
			modifyRace(RIG, VOX)

/obj/machinery/suit_modifier/proc/buyNewCell(obj/R, mob/user)
	var/obj/item/clothing/suit/space/rig/RIG = R
	var/obj/item/weapon/stock_parts/cell/cell = RIG.cell
	for(var/atom/selectCell as anything in cellsToBuy)
		cellsToBuy[selectCell] = image(icon = selectCell.icon, icon_state = selectCell.icon_state)

	speak("Choose wisely!")
	var/choose = show_radial_menu(user, src, cellsToBuy, require_near = TRUE, tooltips = TRUE)
	if(!choose)
		return
	if(cell)
		RIG.detach_cell(user)
		speak("Old [cell] successful uninstalled!")
	cell = choose
	sleep(2 SECOND)
	speak("New [cell] successful installed!")

/obj/machinery/suit_modifier/proc/chargeCell(obj/C, mob/user)
	var/obj/item/weapon/stock_parts/cell/charging = C
	if(stat & (BROKEN|NOPOWER))
		return
	if(emagged && prob(10))
		speak("When you only have a hammer in your hands, then everything around you turns into nails.")
		sleep(3 SECOND)

	if(charging.charge < charging.maxcharge)
		while(charging.charge != charging.maxcharge)
			var/power_used = 100000
			power_used = charging.give(recharge_coeff*power_used*CELLRATE)
			use_power(power_used)
			sleep(1 SECOND)
		speak("[charging] charged!")
	else
		speak("[charging] already have maximum charge.")

/obj/machinery/suit_modifier/proc/showCell(obj/R, mob/user)
	var/obj/item/clothing/suit/space/rig/RIG = R
	var/obj/item/weapon/stock_parts/cell/cell = RIG.cell
	var/list/menu = list()
	if(cell)
		menu += list("Charge Cell"  = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_charge") )
	menu += list("Buy New Cell"     = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_buy"))

	var/choose = show_radial_menu(user, src, menu, require_near = TRUE, tooltips = TRUE)

	switch(choose)
		if("Charge Cell")
			chargeCell(cell, user)
		if("Buy New Cell")
			buyNewCell(RIG, user)

/obj/machinery/suit_modifier/proc/buyHolochip(obj/H, mob/user)
	var/obj/item/clothing/head/helmet/space/rig/HEL = H
	HEL.holochip = new /obj/item/holochip(HEL)
	HEL.holochip.holder = HEL

/obj/machinery/suit_modifier/proc/showHelmet(obj/R, mob/user)
	var/list/menu = list()
	var/obj/item/clothing/suit/space/rig/RIG = R
	var/obj/item/clothing/head/helmet/space/rig/HEL = RIG.helmet
	if(!HEL.holochip)
		menu += list("Holochip" = image(icon = 'icons/holomaps/holochips.dmi', icon_state = "holochip"))
	else
		speak("Sad news! We haven't new modules to install in your helmet!")

	var/choose = show_radial_menu(user, src, menu, require_near = TRUE, tooltips = TRUE)
	switch(choose)
		if("Holochip")
			buyHolochip(HEL, user)

/obj/machinery/suit_modifier/proc/showMenu(obj/R, mob/user)
	var/obj/item/clothing/suit/space/rig/RIG = R
	var/list/menu = list()
	var/obj/item/clothing/head/helmet/space/rig/HEL = RIG.helmet
	var/obj/item/weapon/stock_parts/cell/cell = RIG.cell
	menu 	 += list("Helmet Modules"  = image(icon = HEL.icon, 				   icon_state = HEL.icon_state))
	menu 	 += list("Suit Race"       = image(icon = suit.icon, icon_state = suit.icon_state))
	menu 	 += list("Cell"  		   = image(icon = cell.icon, 				   icon_state = cell.icon_state) )
	menu 	 += list("Suit Modules"    = image(icon = 'icons/obj/rig_modules.dmi', icon_state = "IIS"))
	if(emagged && syndicateModulesCount)
		menu += list("Sundicate Gifts" = image(icon = 'icons/obj/rig_modules.dmi', icon_state = "stamp"))
	menu 	 += list("Repair Suit" 	   = image(icon = 'icons/hud/radial.dmi', 	   icon_state = "radial_repair"))
	var/choose = show_radial_menu(user, src, menu, require_near = TRUE, tooltips = TRUE)

	if(emagged && prob(25))
		speak("Who do you need to kill next?")
	switch(choose)
		if("Suit Race")
			selectRace(RIG, user)
		if("Cell")
			showCell(RIG, user)
		if("Helmet Modules")
			showHelmet(RIG, user)
		if("Suit Modules")
			buyModule(RIG, user)
		if("Sundicate Gifts")
			mountSyndicateModule(RIG, user)
		if("Repair Suit")
			repair(RIG, user)

/obj/machinery/suit_modifier/proc/putInModifier(obj/C, mob/user)
	if(opened)
		if(ishardsuit(C))
			var/obj/item/clothing/suit/space/rig/RIG = C
			if(suit)
				to_chat(user, "<span class ='succsess'>The unit already contains a hardsuit.</span>")
				return
			to_chat(user, "You load the [RIG.name] into the modifi unit.")
			user.drop_from_inventory(RIG, src)
			suit = RIG
		update_icon()

/obj/machinery/suit_modifier/attackby(obj/C, mob/user)
	if(ishardsuit(C))
		putInModifier(C, user)

/obj/machinery/suit_modifier/AltClick(mob/user)
	add_fingerprint(user)
	opened = !opened
	update_icon()

/obj/machinery/suit_modifier/emag_act(mob/user)
	if(emagged)
		return FALSE
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	emagged = TRUE
	speak("bzz... I... Am... Robot!")
	flick_overlay_view(image(icon = 'icons/obj/suitstorage.dmi', icon_state = "industrial_emagged"), src.loc, 3 SECONDS)
	return TRUE

/obj/machinery/suit_modifier/attack_hand(mob/user)
	if(!opened)
		if(suit)
			var/list/contents = list()
			contents += list("Suit"  = image(icon = suit.icon, 			 	icon_state = suit.icon_state))
			contents += list("Eject" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_eject"))

			var/toModify = show_radial_menu(user, src, contents, require_near = TRUE, tooltips = TRUE)
			switch(toModify)
				if("Suit")
					showMenu(suit, user)
				if("Eject")
					ejectSuit()
		else
			speak("Nothing to modify.")
