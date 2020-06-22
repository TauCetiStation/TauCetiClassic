/obj/item/clothing/suit/space/rig/attackby(obj/item/I, mob/user, params)
	if(!isliving(user))
		return

	var/is_wearing = FALSE
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.wear_suit == src)
			is_wearing = TRUE

	if(istype(I, /obj/item/clothing/head/helmet/space))
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

	else if(isscrewdriver(I))
		if(is_wearing)
			to_chat(user, "How do you propose to modify a hardsuit while it is being worn?")
			return

		var/list/current_mounts = list()
		if(cell)
			current_mounts += "cell"
		if(installed_modules && installed_modules.len)
			current_mounts += "system module"
		if(helmet)
			current_mounts += "helmet"
		if(boots)
			current_mounts += "boots"

		var/to_remove = input("Which would you like to modify?") as null|anything in current_mounts
		if(!to_remove)
			return
		if(!Adjacent(user) || wearer)
			return

		switch(to_remove)
			if("cell")
				if(cell)
					to_chat(user, "You detach \the [cell] from \the [src]'s battery mount.")
					for(var/obj/item/rig_module/module in installed_modules)
						module.deactivate()
					cell.updateicon()
					user.put_in_hands(cell)
					cell = null
				else
					to_chat(user, "There is nothing loaded in that mount.")

			if("system module")
				var/list/possible_removals = list()
				for(var/obj/item/rig_module/module in installed_modules)
					if(module.permanent)
						continue
					possible_removals[module.name] = module

				if(!possible_removals.len)
					to_chat(user, "There are no installed modules to remove.")
					return

				var/removal_choice = input("Which module would you like to remove?") as null|anything in possible_removals
				if(!removal_choice)
					return
				if(!Adjacent(user) || wearer)
					return

				var/obj/item/rig_module/removed = possible_removals[removal_choice]
				to_chat(user, "You detach \the [removed] from \the [src].")
				removed.forceMove(get_turf(src))
				removed.removed()
				installed_modules -= removed

			if("helmet")
				to_chat(user, "You detatch \the [helmet] from \the [src]'s helmet mount.")
				helmet.forceMove(get_turf(src))
				helmet = null

			if("boots")
				to_chat(user, "You detatch \the [boots] from \the [src]'s boot mounts.")
				boots.forceMove(get_turf(src))
				boots = null
		return

	// If we've gotten this far, all we have left to do before we pass off to root procs
	// is check if any of the loaded modules want to use the item we've been given.
	for(var/obj/item/rig_module/module in installed_modules)
		if(module.accepts_item(I, user)) //Item is handled in this proc
			return

	return ..()