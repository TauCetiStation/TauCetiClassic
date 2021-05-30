/datum/rig_charge
	var/display_name = "undefined" // shown to the user
	var/product_type = "undefined" // some internal information like type of the grenade or chemical
	var/charges = 0 // how much left

/datum/rig_charge/New(Display_Name, Product_Type, Charges)
	display_name = Display_Name
	product_type = Product_Type
	charges = Charges

/obj/item/rig_module
	name = "hardsuit upgrade"
	desc = "It looks pretty sciency."
	icon = 'icons/obj/rig_modules.dmi'
	icon_state = "generic"

	var/damage = MODULE_NO_DAMAGE
	var/obj/item/clothing/suit/space/rig/holder

	var/module_cooldown = 10
	var/next_use = 0

	var/toggleable                      // Set to TRUE for the device to show up as an active effect.
	var/show_toggle_button              // Set to TRUE for the device to show toggle button
	var/usable                          // Set to TRUE for the device to have an on-use effect.
	var/selectable                      // Set to TRUE to be able to assign the device as primary system.
	var/redundant                       // Set to TRUE to ignore duplicate module checking when installing.
	var/permanent                       // If set, the module can't be removed.
	var/mount_type = 0                  // What mounts does this module use

	var/active                          // Basic module status
	var/activate_on_start               // Set to TRUE for the device to automatically activate on suit equip

	var/use_power_cost = 0              // Power used when single-use ability called.
	var/active_power_cost = 0           // Power used when turned on.
	var/passive_power_cost = 0          // Power used when turned off.

	var/list/datum/rig_charge/charges   // Associative list of charge types and remaining numbers. Starting charges are filled only inside init_charges() proc
	var/charge_selected                 // Currently selected option used for charge dispensing.

	var/suit_overlay
	var/image/suit_overlay_image

	//Display fluff
	var/interface_name = "hardsuit upgrade"
	var/interface_desc = "A generic hardsuit upgrade."
	var/engage_string = "Engage"
	var/activate_string = "Activate"
	var/deactivate_string = "Deactivate"

	var/list/stat_modules = list() // buttons for the stat menu

/obj/item/rig_module/atom_init()
	. = ..()

	init_charges()
	if(charges && charges.len) // auto-select the first charge
		charge_selected = charges[1]

	if(suit_overlay)
		suit_overlay_image = image("icon" = 'icons/mob/rig_modules.dmi', "icon_state" = "[suit_overlay]")

	stat_modules +=	new /obj/stat_rig_module/activate(src, src)
	stat_modules +=	new /obj/stat_rig_module/deactivate(src, src)
	stat_modules +=	new /obj/stat_rig_module/engage(src, src)
	stat_modules +=	new /obj/stat_rig_module/select(src, src)
	stat_modules +=	new /obj/stat_rig_module/charge(src, src)

/obj/item/rig_module/Destroy()
	deactivate()
	QDEL_LIST(stat_modules)
	if(holder)
		holder.installed_modules -= src
	holder = null
	. = ..()

/obj/item/rig_module/examine()
	. = ..()
	switch(damage)
		if(MODULE_NO_DAMAGE)
			to_chat(usr, "It is undamaged.")
		if(MODULE_DAMAGED)
			to_chat(usr, "It is badly damaged.")
		if(MODULE_DESTROYED)
			to_chat(usr, "It is almost completely destroyed.")

/obj/item/rig_module/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/nanopaste))
		if(user.is_busy(src))
			return

		if(!damage)
			to_chat(user, "There is no damage to mend.")
			return

		to_chat(user, "You start mending the damaged portions of \the [src]...")

		if(!I.use_tool(src, user, 30, volume = 50))
			return

		var/obj/item/stack/nanopaste/paste = I
		if(paste.use(1))
			damage = MODULE_NO_DAMAGE
			to_chat(user, "You mend the damage to [src] with [paste].")
		return

	else if(iscoil(I))
		if(user.is_busy())
			return

		switch(damage)
			if(MODULE_NO_DAMAGE)
				to_chat(user, "There is no damage to mend.")
				return
			if(MODULE_DESTROYED)
				to_chat(user, "There is no damage that you are capable of mending with such crude tools.")
				return

		var/obj/item/stack/cable_coil/cable = I
		if(!cable.amount >= 5)
			to_chat(user, "You need five units of cable to repair \the [src].")
			return

		to_chat(user, "You start mending the damaged portions of \the [src]...")
		if(cable.use_tool(src, user, 30, amount = 5, volume = 50))
			damage = MODULE_NO_DAMAGE
			to_chat(user, "You mend the damage to [src] with [cable].")
		return

	return ..()

// Called when the module is installed into a suit.
/obj/item/rig_module/proc/installed(obj/item/clothing/head/helmet/space/rig/new_holder)
	holder = new_holder
	holder.installed_modules += src
	forceMove(holder)

//Proc for one-use abilities like teleport.
/obj/item/rig_module/proc/engage()

	if(damage >= MODULE_DESTROYED)
		to_chat(holder.wearer, "<span class='warning'>The [interface_name] is damaged beyond use!</span>")
		return FALSE

	if(world.time < next_use)
		to_chat(holder.wearer, "<span class='warning'>You cannot use the [interface_name] again so soon.</span>")
		return FALSE

	if(!holder.try_use(holder.wearer, use_power_cost, use_unconcious = FALSE, use_stunned = FALSE))
		return FALSE

	next_use = world.time + module_cooldown

	return TRUE

// Proc for toggling on active abilities.
/obj/item/rig_module/proc/activate(forced = FALSE)
	if(active)
		return FALSE

	if(!forced && !engage())
		return FALSE
	else if(forced && (damage >= MODULE_DESTROYED || !holder.try_use(holder.wearer, use_power_cost, use_unconcious = TRUE, use_stunned = TRUE)))
		return FALSE // forced skips some checks

	active = TRUE

	if(show_toggle_button)
		holder.update_activated_actions()

	return TRUE

// Proc for toggling off active abilities.
/obj/item/rig_module/proc/deactivate()

	if(!active)
		return FALSE

	active = FALSE

	if(show_toggle_button)
		holder.update_activated_actions()

	return TRUE

// Called when the module is uninstalled from a suit.
/obj/item/rig_module/proc/removed()
	deactivate()
	holder = null
	return

// Called by the hardsuit each rig process tick.
/obj/item/rig_module/proc/process_module()
	if(active)
		return active_power_cost
	else
		return passive_power_cost

// Called at the module init, used to fill module charges if needed
/obj/item/rig_module/proc/init_charges()
	return

// Called by holder rigsuit attackby()
// Checks if an item is usable with this module and handles it if it is
/obj/item/rig_module/proc/accepts_item(obj/item/input_device)
	return FALSE

/mob/proc/rig_setup_stat(obj/item/clothing/suit/space/rig/R)
	if(R && R.installed_modules.len && !R.offline && statpanel("Hardsuit Modules"))
		var/cell_status = R.cell ? "[R.cell.charge]/[R.cell.maxcharge]" : "ERROR"
		stat("Suit charge", cell_status)
		for(var/obj/item/rig_module/module in R.installed_modules)
			for(var/obj/stat_rig_module/SRM in module.stat_modules)
				if(SRM.CanUse())
					stat(SRM.module.interface_name,SRM)

/obj/stat_rig_module
	var/module_mode = ""
	var/obj/item/rig_module/module

/obj/stat_rig_module/atom_init(mapload, obj/item/rig_module/module)
	. = ..()
	src.module = module

/obj/stat_rig_module/proc/AddHref(list/href_list)
	return

/obj/stat_rig_module/proc/CanUse()
	return FALSE

/obj/stat_rig_module/Click()
	if(CanUse())
		var/list/href_list = list(
			"interact_module" = module.holder.installed_modules.Find(module),
			"module_mode" = module_mode
			)
		AddHref(href_list)
		module.holder.Topic(usr, href_list)

/obj/stat_rig_module/DblClick()
	return

/obj/stat_rig_module/activate/atom_init(mapload, obj/item/rig_module/module)
	. = ..()
	name = module.activate_string
	if(module.active_power_cost)
		name += " ([module.active_power_cost]A)"
	module_mode = "activate"

/obj/stat_rig_module/activate/CanUse()
	return module.toggleable && !module.active

/obj/stat_rig_module/deactivate/atom_init(mapload, obj/item/rig_module/module)
	. = ..()
	name = module.deactivate_string
	// Show cost despite being 0, if it means changing from an active cost.
	if(module.active_power_cost || module.passive_power_cost)
		name += " ([module.passive_power_cost]P)"

	module_mode = "deactivate"

/obj/stat_rig_module/deactivate/CanUse()
	return module.toggleable && module.active

/obj/stat_rig_module/engage/atom_init(mapload, obj/item/rig_module/module)
	. = ..()
	name = module.engage_string
	if(module.use_power_cost)
		name += " ([module.use_power_cost]E)"
	module_mode = "engage"

/obj/stat_rig_module/engage/CanUse()
	return module.usable

/obj/stat_rig_module/select/atom_init(mapload, obj/item/rig_module/module)
	. = ..()
	name = "Select"
	module_mode = "toggle"

/obj/stat_rig_module/select/CanUse()
	if(module.selectable)
		name = module.holder.selected_module == module ? "Selected" : "Select"
		return 1
	return 0

/obj/stat_rig_module/charge/atom_init(mapload, obj/item/rig_module/module)
	. = ..()
	name = "Change Charge"
	module_mode = "select_charge_type"

/obj/stat_rig_module/charge/AddHref(list/href_list)
	var/charge_index = module.charges.Find(module.charge_selected)
	if(!charge_index)
		charge_index = 0
	else
		charge_index = charge_index == module.charges.len ? 1 : charge_index+1

	href_list["charge_type"] = module.charges[charge_index]

/obj/stat_rig_module/charge/CanUse()
	if(module.charges && module.charges.len)
		var/datum/rig_charge/charge = module.charges[module.charge_selected]
		name = "[charge.display_name] ([charge.charges]C) - Change"
		return 1
	return 0
