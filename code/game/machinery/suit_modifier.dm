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

	var/list/speciesAvailable = list(HUMAN, SKRELL, UNATHI, TAJARAN, DIONA, VOX)

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

/obj/machinery/suit_modifier/proc/eject(obj/I)
	if(!I)
		return
	else
		I.forceMove(get_turf(src))
		I = null
		update_icon()
		return

/obj/machinery/suit_modifier/proc/modify_race(obj/item/clothing/C, atom/target_species, mob/user)

	C.refit_for_species(target_species)
	eject(C)

/obj/machinery/suit_modifier/proc/show_menu(obj/item/clothing/C, mob/user)
	var/list/modifySelect = list()
	var/obj/item/clothing/temp = C
	for(var/species in speciesAvailable)
		temp.icon = temp.sprite_sheets_obj[species]
		modifySelect += list(species = image(icon = temp.icon, icon_state = temp.icon_state))

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
				contents += list("Helmet" = image(getFlatIcon(helmet)))
			if(suit)
				contents += list("Suit"   = image(getFlatIcon(suit)))
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
			if(helmet)
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
