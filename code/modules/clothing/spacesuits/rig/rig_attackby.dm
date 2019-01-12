/obj/item/clothing/suit/space/rig/attackby(obj/item/W, mob/user)

	if(!isliving(user))
		return

	if(user.a_intent == "help")

		if(isliving(loc) && !istype(W, /obj/item/weapon/patcher))
			to_chat(user, "How do you propose to modify a hardsuit while it is being worn?")
			return

		var/target_zone = user.zone_sel.selecting

		if(target_zone == BP_HEAD)

			//Installing a component into or modifying the contents of the helmet.
			if(!attached_helmet)
				to_chat(user, "\The [src] does not have a helmet mount.")
				return

			if(istype(W,/obj/item/weapon/screwdriver))
				if(!helmet)
					to_chat(user, "\The [src] does not have a helmet installed.")
				else
					to_chat(user, "You detatch \the [helmet] from \the [src]'s helmet mount.")
					helmet.loc = get_turf(src)
					src.helmet = null
				return
			else if(istype(W,/obj/item/clothing/head/helmet/space))
				if(helmet)
					to_chat(user, "\The [src] already has a helmet installed.")
				else
					to_chat(user, "You attach \the [W] to \the [src]'s helmet mount.")
					user.drop_item()
					W.loc = src
					src.helmet = W
				return
			else
				return ..()

		else if(target_zone == BP_L_LEG || target_zone == BP_R_LEG)

			//Installing a component into or modifying the contents of the feet.
			if(!attached_boots)
				to_chat(user, "\The [src] does not have boot mounts.")
				return

			if(istype(W,/obj/item/weapon/screwdriver))
				if(!boots)
					to_chat(user, "\The [src] does not have any boots installed.")
				else
					to_chat(user, "You detatch \the [boots] from \the [src]'s boot mounts.")
					boots.loc = get_turf(src)
					boots = null
				return
			else if(istype(W,/obj/item/clothing/shoes/magboots))
				if(boots)
					to_chat(user, "\The [src] already has magboots installed.")
				else
					to_chat(user, "You attach \the [W] to \the [src]'s boot mounts.")
					user.drop_item()
					W.loc = src
					boots = W

		// Check if this is a hardsuit upgrade or a modification.
		else if(istype(W,/obj/item/rig_module))

			if(!installed_modules)
				installed_modules = list()
			if(installed_modules.len)
				for(var/obj/item/rig_module/installed_mod in installed_modules)
					if(!installed_mod.redundant && istype(installed_mod,W))
						to_chat(user, "The hardsuit already has a module of that class installed.")
						return 1

			var/obj/item/rig_module/mod = W
			to_chat(user, "You begin installing \the [mod] into \the [src].")
			if(!do_after(user,40,target = src))
				return
			if(!user || !W)
				return
			if(!user.unEquip(mod))
				return
			to_chat(user, "You install \the [mod] into \the [src].")
			installed_modules |= mod
			mod.forceMove(src)
			mod.installed(src)
			update_icon()
			return 1

		else if(!cell && istype(W,/obj/item/weapon/stock_parts/cell))
			if(!user.unEquip(W))
				return
			to_chat(user, "You jack \the [W] into \the [src]'s battery mount.")
			W.forceMove(src)
			cell = W
			return

		else if(isscrewdriver(W))

			var/list/current_mounts = list()
			if(cell)
				current_mounts   += "cell"
			if(installed_modules && installed_modules.len)
				current_mounts += "system module"

			var/to_remove = input("Which would you like to modify?") as null|anything in current_mounts
			if(!to_remove)
				return

			switch(to_remove)
				if("cell")

					if(cell)
						to_chat(user, "You detach \the [cell] from \the [src]'s battery mount.")
						for(var/obj/item/rig_module/module in installed_modules)
							module.deactivate()
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

					var/obj/item/rig_module/removed = possible_removals[removal_choice]
					to_chat(user, "You detach \the [removed] from \the [src].")
					removed.forceMove(get_turf(src))
					removed.removed()
					installed_modules -= removed
					update_icon()

	return ..()