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

	var/list/modulesToBuy = list(
		/obj/item/rig_module/simple_ai,
		/obj/item/rig_module/emp_shield/adv,
		/obj/item/rig_module/device/healthscanner,
		/obj/item/rig_module/device/analyzer,
		/obj/item/rig_module/device/science_tool,
		/obj/item/rig_module/device/drill,
		/obj/item/rig_module/device/anomaly_scanner,
		/obj/item/rig_module/device/orescanner,
		/obj/item/rig_module/device/rcd,
		/obj/item/rig_module/chem_dispenser,
		/obj/item/rig_module/chem_dispenser/combat,
		/obj/item/rig_module/cooling_unit,
		/obj/item/rig_module/emp_shield,
		/obj/item/rig_module/teleporter_stabilizer,
		/obj/item/rig_module/selfrepair,
		/obj/item/rig_module/med_teleport,
		/obj/item/rig_module/nuclear_generator,
		/obj/item/rig_module/mounted_relay,
		/obj/item/rig_module/device/extinguisher,
		/obj/item/rig_module/metalfoam_spray,

	)

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
		if(helmet)
			add_overlay("industrial_helm")
		if(suit)
			add_overlay("industrial_suit")
	else
		cut_overlay("industrial_open")

/obj/machinery/suit_modifier/proc/eject_helmet()
	if(!helmet)
		return
	else
		helmet.forceMove(get_turf(src))
		helmet = null
		update_icon()
		return

/obj/machinery/suit_modifier/proc/eject_suit()
	if(!suit)
		return
	else
		suit.forceMove(get_turf(src))
		suit = null
		update_icon()
		return

/obj/machinery/suit_modifier/proc/buy_module(obj/item/clothing/C, mob/user)

/obj/machinery/suit_modifier/proc/detach_module()

/obj/machinery/suit_modifier/proc/attach_module()

/obj/machinery/suit_modifier/proc/modify_race(obj/item/clothing/C, atom/target_species, mob/user)
	C.refit_for_species(target_species)
	if(ishardhelmet(C))
		eject_helmet()
	else if(ishardsuit(C))
		eject_suit()

/obj/machinery/suit_modifier/proc/show_menu(obj/item/clothing/C, mob/user)
	var/list/modifySelect = list()
	var/list/speciesAvailable = C.species_restricted
	speciesAvailable.Remove(DIONA)

	for(var/species in speciesAvailable)
		var/icon_path = C.sprite_sheets_obj[species]
		modifySelect[species] += image(icon = icon_path, icon_state = C.icon_state)

	var/toModifi = show_radial_menu(user, src, modifySelect, require_near = TRUE, tooltips = TRUE)
	switch(toModifi)
		if("Human")
			modify_race(C, HUMAN, user)
		if("Skrell")
			modify_race(C, SKRELL, user)
		if("Tajaran")
			modify_race(C, TAJARAN, user)
		if("Unathi")
			modify_race(C, UNATHI, user)
		if("Vox")
			modify_race(C, VOX, user)

/obj/machinery/suit_modifier/attack_hand(mob/user)
	if(!opened)
		if(helmet || suit)
			var/list/contents = list()
			if(helmet)
				contents += list("Helmet" = image(icon = helmet.icon, icon_state = helmet.icon_state))
			if(suit)
				contents += list("Suit"   = image(icon = suit.icon, icon_state = suit.icon_state))
			var/toModify = show_radial_menu(user, src, contents, require_near = TRUE, tooltips = TRUE)

			switch(toModify)
				if("Helmet")
					show_menu(helmet, user)
				if("Suit")
					show_menu(suit, user)
		else
			to_chat(user, "<span class='notice'>Nothing to modify.</span>")

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
		if(isspacehelmet(C))
			var/obj/item/clothing/head/helmet/H = C
			if(helmet)
				to_chat(user, "<span class ='succsess'>The unit already contains a helmet.</span>")
				return
			to_chat(user, "You load the [H.name] into the modifi unit.")
			user.drop_from_inventory(H, src)
			helmet = H
		update_icon()

/obj/machinery/suit_modifier/attackby(obj/item/clothing/C, mob/user)
	if(ishardsuit(C) || ishardhelmet(C))
		putInModifier(C, user)

/obj/machinery/suit_modifier/AltClick(mob/user)
	add_fingerprint(user)
	opened = !opened
	update_icon()
