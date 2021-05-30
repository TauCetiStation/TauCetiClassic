// Interface for humans.
/obj/item/clothing/suit/space/rig/verb/hardsuit_interface()

	set name = "Open Hardsuit Interface"
	set desc = "Open the hardsuit system interface."
	set category = "Hardsuit"
	set src = usr.contents

	if(wearer && wearer.wear_suit == src)
		ui_interact(usr)

/obj/item/clothing/suit/space/rig/verb/select_module()
	set name = "Select Module"
	set desc = "Selects a module as your primary system."
	set category = "Hardsuit"
	set src = usr.contents

	if(!istype(wearer) || wearer.wear_suit != src)
		to_chat(usr, "<span class='warning'>The hardsuit is not being worn.</span>")
		return

	if(offline)
		to_chat(usr, "<span class='warning'>The suit is not active.</span>")
		return

	var/list/selectable = list()
	for(var/obj/item/rig_module/module in installed_modules)
		if(module.selectable)
			selectable += module

	var/obj/item/rig_module/module = input("Which module do you wish to select?") as null|anything in selectable

	if(!istype(module))
		selected_module = null
		to_chat(usr, "<span class='bold notice'>Primary system is now: deselected.</span>")
		update_selected_action()
		return

	selected_module = module
	to_chat(usr, "<span class='bold notice'>Primary system is now: [selected_module.interface_name].</span>")
	update_selected_action()

/obj/item/clothing/suit/space/rig/verb/deselect_module()
	set name = "Deselect Module"
	set desc = "Deselects active module."
	set category = "Hardsuit"
	set src = usr.contents

	if(!istype(wearer) || wearer.wear_suit != src)
		to_chat(usr, "<span class='warning'>The hardsuit is not being worn.</span>")
		return

	if(offline)
		to_chat(usr, "<span class='warning'>The suit is not active.</span>")
		return

	selected_module = null
	to_chat(usr, "<span class='bold notice'>Primary system is now: deselected.</span>")
	update_selected_action()

/obj/item/clothing/suit/space/rig/verb/toggle_module()

	set name = "Toggle Module"
	set desc = "Toggle a system module."
	set category = "Hardsuit"
	set src = usr.contents

	if(!istype(wearer) || wearer.wear_suit != src)
		to_chat(usr, "<span class='warning'>The hardsuit is not being worn.</span>")
		return

	if(offline)
		to_chat(usr, "<span class='warning'>The suit is not active.</span>")
		return

	var/list/selectable = list()
	for(var/obj/item/rig_module/module in installed_modules)
		if(module.toggleable)
			selectable += module

	var/obj/item/rig_module/module = input("Which module do you wish to toggle?") as null|anything in selectable

	if(!istype(module))
		return

	if(module.active)
		to_chat(usr, "<span class='bold notice'>You attempt to deactivate \the [module.interface_name].</span>")
		module.deactivate()
	else
		to_chat(usr, "<span class='bold notice'>You attempt to activate \the [module.interface_name].</span>")
		module.activate()

/obj/item/clothing/suit/space/rig/verb/engage_module()

	set name = "Engage Module"
	set desc = "Engages a system module."
	set category = "Hardsuit"
	set src = usr.contents

	if(!istype(wearer) || wearer.wear_suit != src)
		to_chat(usr, "<span class='warning'>The hardsuit is not being worn.</span>")
		return

	if(offline)
		to_chat(usr, "<span class='warning'>The suit is not active.</span>")
		return

	var/list/selectable = list()
	for(var/obj/item/rig_module/module in installed_modules)
		if(module.usable)
			selectable += module

	var/obj/item/rig_module/module = input("Which module do you wish to engage?") as null|anything in selectable

	if(!istype(module))
		return

	to_chat(usr, "<span class='bold notice'>You attempt to engage the [module.interface_name].</span>")
	module.engage()
