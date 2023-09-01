/obj/item/clothing/suit/space/rig/attackby(obj/item/I, mob/user, params)
	if(!isliving(user))
		return

	var/is_wearing = FALSE
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.wear_suit == src)
			is_wearing = TRUE

	if(istype(I, /obj/item/clothing/head/helmet/space/rig))
		if(is_wearing)
			to_chat(user, "How do you propose to modify a hardsuit while it is being worn?")
			return

		//Installing a component into or modifying the contents of the helmet.
		if(!attached_helmet)
			to_chat(user, "\The [src] does not have a helmet mount.")
			return

		if(helmet)
			to_chat(user, "\The [src] already has a helmet installed.")
		else
			to_chat(user, "You attach \the [I] to \the [src]'s helmet mount.")
			user.drop_from_inventory(I, src)
			helmet = I
			var/obj/item/clothing/head/helmet/space/rig/R = I
			R.rig_connect = src
		return

	else if(istype(I, /obj/item/clothing/shoes/magboots))
		if(is_wearing)
			to_chat(user, "How do you propose to modify a hardsuit while it is being worn?")
			return

		//Installing a component into or modifying the contents of the feet.
		if(!attached_boots)
			to_chat(user, "\The [src] does not have boot mounts.")
			return

		if(boots)
			to_chat(user, "\The [src] already has magboots installed.")
		else
			to_chat(user, "You attach \the [I] to \the [src]'s boot mounts.")
			user.drop_from_inventory(I, src)
			boots = I
		return

	// Check if this is a hardsuit upgrade or a modification.
	else if(istype(I, /obj/item/rig_module))
		if(is_wearing)
			to_chat(user, "How do you propose to modify a hardsuit while it is being worn?")
			return
		if(user.is_busy())
			return

		var/obj/item/rig_module/mod = I
		if(!can_install(mod))
			return

		to_chat(user, "You begin installing \the [mod] into \the [src].")
		if(!I.use_tool(src, user, 40, volume = 50))
			return
		if(!user || !I)
			return
		if(!can_install(mod))
			return
		if(!user.unEquip(mod))
			return
		to_chat(user, "You install \the [mod] into \the [src].")
		mod.installed(src)
		return TRUE

	else if(!cell && istype(I, /obj/item/weapon/stock_parts/cell))
		if(is_wearing)
			to_chat(user, "How do you propose to modify a hardsuit while it is being worn?")
			return

		if(!user.unEquip(I))
			return
		to_chat(user, "You jack \the [I] into \the [src]'s battery mount.")
		I.forceMove(src)
		cell = I
		return

	else if(isscrewing(I))
		if(is_wearing)
			to_chat(user, "How do you propose to modify a hardsuit while it is being worn?")
			return

		var/list/current_mounts = list()
		var/list/current_mounts_modules = list()

		for(var/obj/item/rig_module/mounted in src)
			current_mounts_modules += mounted

		if(helmet)
			current_mounts += list("Helmet" = image(icon = helmet.icon, icon_state = helmet.icon_state))
		if(cell)
			current_mounts += list("Cell" = image(getFlatIcon(cell)))
		if(boots)
			current_mounts += list("Boots" = image(icon = boots.icon, icon_state = boots.icon_state))
		if(current_mounts_modules.len)
			current_mounts += list("Modules" = image(icon = 'icons/obj/rig_modules.dmi', icon_state = "IIS"))

		var/to_remove = show_radial_menu(user, src, current_mounts, require_near = TRUE, tooltips = TRUE)

		if(!to_remove)
			return
		if(!Adjacent(user) || wearer)
			return

		switch(to_remove)
			if("Cell")
				detach_cell(user)
			if("Helmet")
				detach_helmet(user)
			if("Boots")
				detach_boots(user)
			if("Modules")
				detach_module(user, current_mounts_modules)
		return

	// If we've gotten this far, all we have left to do before we pass off to root procs
	// is check if any of the loaded modules want to use the item we've been given.
	for(var/obj/item/rig_module/module in installed_modules)
		if(module.accepts_item(I, user)) //Item is handled in this proc
			return

	return ..()

/obj/item/clothing/suit/space/rig/proc/detach_cell(mob/user)
	to_chat(user, "You detach \the [cell] from \the [src]'s battery mount.")
	for(var/obj/item/rig_module/module in installed_modules)
		module.deactivate()
	cell.updateicon()
	user.put_in_hands(cell)
	cell = null

/obj/item/clothing/suit/space/rig/proc/detach_helmet(mob/user)
	to_chat(user, "You detatch \the [helmet] from \the [src]'s helmet mount.")
	helmet.rig_connect = null
	user.put_in_hands(helmet)
	helmet = null

/obj/item/clothing/suit/space/rig/proc/detach_boots(mob/user)
	to_chat(user, "You detatch \the [boots] from \the [src]'s boot mounts.")
	user.put_in_hands(boots)
	boots = null

/obj/item/clothing/suit/space/rig/proc/detach_module(mob/user, var/list/current_mounts_modules)
	for(var/atom/module as anything in current_mounts_modules)
		current_mounts_modules[module] = image(icon = module.icon, icon_state = module.icon_state)

	var/removal_choice = show_radial_menu(user, src, current_mounts_modules, require_near = TRUE, tooltips = TRUE)

	if(!removal_choice)
		return
	if(!Adjacent(user) || wearer)
		return

	var/obj/item/rig_module/removed = removal_choice
	to_chat(user, "You detach \the [removed] from \the [src].")
	user.put_in_hands(removed)
	removed.removed()
	installed_modules -= removed
