/obj/machinery/suit_modifier
	name = "Suit Modifier Unit"
	desc = "An industrial Suit Modifier Unit, to modifi your hardsuit."
	icon = 'icons/obj/suitstorage.dmi'
	icon_state = "industrial"
	damage_deflection = 50

	anchored = TRUE
	density = TRUE
	var/opened = FALSE
	var/active = TRUE

	var/obj/item/clothing/suit/space/rig/suit 			= null
	var/obj/item/clothing/head/helmet/space/rig/helmet 	= null

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
	var/list/syndicateModulesToMount = list()
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

/obj/machinery/suit_modifier/proc/mountSyndicateModule(obj/item/clothing/suit/space/rig/R, mob/user)
	for(var/atom/selectModule as anything in syndicateModulesAvalible)
		syndicateModulesAvalible[selectModule] = image(icon = selectModule.icon, icon_state = selectModule.icon_state)

	var/obj/item/rig_module/toInstallModule = show_radial_menu(user, src, syndicateModulesAvalible, require_near = TRUE, tooltips = TRUE)

	if(R.can_install(toInstallModule))
		toInstallModule.installed(R)
	else if(R.detach_module(user, R.installed_modules, src))
		toInstallModule.installed(R)
	else
		return

	syndicateModulesCount--

/obj/machinery/suit_modifier/proc/buyModule(obj/item/clothing/suit/space/rig/R, mob/user)
	for(var/atom/selectModule as anything in modulesAvalible)
		modulesAvalible[selectModule] = image(icon = selectModule.icon, icon_state = selectModule.icon_state)

	var/obj/item/rig_module/toBuyModule = show_radial_menu(user, src, modulesAvalible, require_near = TRUE, tooltips = TRUE)

	if(!toBuyModule)
		return
	else if(R.can_install(toBuyModule))
		toBuyModule.installed(R)
	else if(R.detach_module(user, R.installed_modules, src))
		toBuyModule.installed(R)

/obj/machinery/suit_modifier/proc/modifyRace(obj/item/clothing/suit/space/rig/R, atom/target_species)
	R.refit_for_species(target_species)
	R.helmet.refit_for_species(target_species)

/obj/machinery/suit_modifier/proc/selectRace(obj/item/clothing/C, mob/user)
	var/list/modifySelect = list()
	var/list/speciesAvailable = C.species_restricted
	speciesAvailable.Remove(DIONA)

	for(var/species in speciesAvailable)
		var/icon_path = C.sprite_sheets_obj[species]
		modifySelect[species] += image(icon = icon_path, icon_state = C.icon_state)

	var/toModify = show_radial_menu(user, src, modifySelect, require_near = TRUE, tooltips = TRUE)
	switch(toModify)
		if("Human")
			modifyRace(C, HUMAN)
		if("Skrell")
			modifyRace(C, SKRELL)
		if("Tajaran")
			modifyRace(C, TAJARAN)
		if("Unathi")
			modifyRace(C, UNATHI)
		if("Vox")
			modifyRace(C, VOX)

/obj/machinery/suit_modifier/proc/buyNewCell(obj/item/clothing/suit/space/rig/R, mob/user)
	for(var/atom/selectCell as anything in cellsToBuy)
		cellsToBuy[selectCell] = image(icon = selectCell.icon, icon_state = selectCell.icon_state)

	var/choose = show_radial_menu(user, src, cellsToBuy, require_near = TRUE, tooltips = TRUE)
	if(R.cell)
		R.detach_cell(user)
	R.cell = choose

/obj/machinery/suit_modifier/proc/chargeCell(obj/item/clothing/suit/space/rig/R, mob/user)
	if(R.cell.charge < R.cell.maxcharge)
		R.cell.charge = R.cell.maxcharge
	else
		to_chat(user, "<span class='notice'>Cell already charged.</span>")

/obj/machinery/suit_modifier/proc/showCell(obj/item/clothing/suit/space/rig/R, mob/user)
	var/list/menu = list()
	if(R.cell)
		menu += list("Charge Cell"  = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_charge") )
	menu += list("Buy New Cell"     = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_buy"))

	var/choose = show_radial_menu(user, src, menu, require_near = TRUE, tooltips = TRUE)

	switch(choose)
		if("Charge Cell")
			chargeCell(R, user)
		if("Buy New Cell")
			buyNewCell(R, user)

/obj/machinery/suit_modifier/proc/buyHolochip(obj/item/clothing/head/helmet/space/rig/H, mob/user)
	H.holochip = new /obj/item/holochip(H)
	H.holochip.holder = H

/obj/machinery/suit_modifier/proc/showHelmet(obj/item/clothing/suit/space/rig/R, mob/user)
	var/list/menu = list()
	var/obj/item/clothing/head/helmet/space/rig/H = R.helmet
	if(!H.holochip)
		menu += list("Holochip" = image(icon = 'icons/holomaps/holochips.dmi', icon_state = "holochip"))
	else
		to_chat(user, "<span class='notice'>No have modules to install.</span>")

	var/choose = show_radial_menu(user, src, menu, require_near = TRUE, tooltips = TRUE)
	switch(choose)
		if("Holochip")
			buyHolochip(H, user)

/obj/machinery/suit_modifier/proc/showMenu(obj/item/clothing/suit/space/rig/R, mob/user)
	var/list/menu = list()
	menu += list("Suit Race"           = image(icon = suit.icon, icon_state = suit.icon_state))
	if(R.cell)
		var/obj/item/weapon/stock_parts/cell/cell = R.cell
		menu += list("Cell"  		   = image(icon = cell.icon, icon_state = cell.icon_state) )
	menu += list("Suit Modules"        = image(icon = 'icons/obj/rig_modules.dmi', icon_state = "IIS"))
	var/obj/item/clothing/head/helmet/space/rig/H = R.helmet
	menu += list("Helmet Modules"      = image(icon = H.icon, icon_state = H.icon_state))
	if(emagged && syndicateModulesCount)
		menu += list("Sundicate Gifts" = image(icon = 'icons/obj/rig_modules.dmi', icon_state = "stamp"))
	var/choose = show_radial_menu(user, src, menu, require_near = TRUE, tooltips = TRUE)

	switch(choose)
		if("Suit Race")
			selectRace(R, user)
		if("Cell")
			showCell(R, user)
		if("Helmet Modules")
			showHelmet(R, user)
		if("Suit Modules")
			buyModule(R, user)
		if("Sundicate Gifts")
			mountSyndicateModule(R, user)

/obj/machinery/suit_modifier/proc/putInModifier(obj/item/clothing/C, mob/user)
	if(opened)
		if(isspacesuit(C))
			var/obj/item/clothing/suit/space/S = C
			if(suit)
				to_chat(user, "<span class ='succsess'>The unit already contains a suit.</span>")
				return
			to_chat(user, "You load the [S.name] into the modifi unit.")
			user.drop_from_inventory(S, src)
			suit = S
		update_icon()

/obj/machinery/suit_modifier/attackby(obj/item/clothing/C, mob/user)
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
	flick("industrial_emagged", src)
	return TRUE

/obj/machinery/suit_modifier/attack_hand(mob/user)
	if(!opened)
		if(suit)
			var/list/contents = list()
			contents += list("Suit"  = image(icon = suit.icon, icon_state = suit.icon_state))
			contents += list("Eject" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_eject"))

			var/toModify = show_radial_menu(user, src, contents, require_near = TRUE, tooltips = TRUE)
			switch(toModify)
				if("Suit")
					showMenu(suit, user)
				if("Eject")
					ejectSuit()
		else
			to_chat(user, "<span class='notice'>Nothing to modify.</span>")
