// buttons that appear at the top of the screen

/datum/action/module_select
	name = "Select module"

/datum/action/module_select/New(Target)
	..()
	if(istype(Target, /obj/item/rig_module))
		var/obj/item/rig_module/module = Target
		name = "Select [module.interface_name]"

/datum/action/module_select/Trigger()
	if(!Checks())
		return

	if(istype(target, /obj/item/rig_module))
		var/obj/item/rig_module/module = target
		if(module.holder)
			if(module.holder.selected_module == module)
				module.holder.selected_module = null
				to_chat(owner, "<span class='bold notice'>Primary system is now: deselected.</span>")
			else
				module.holder.selected_module = module
				to_chat(owner, "<span class='bold notice'>Primary system is now: [module.interface_name].</span>")
			module.holder.update_selected_action()

/datum/action/module_toggle
	name = "Toggle module"

/datum/action/module_toggle/New(Target)
	..()
	if(istype(Target, /obj/item/rig_module))
		var/obj/item/rig_module/module = Target
		name = "[module.activate_string]"

/datum/action/module_toggle/Trigger()
	if(!Checks())
		return

	if(istype(target, /obj/item/rig_module))
		var/obj/item/rig_module/module = target
		if(module.holder)
			if(module.active) // activate and deactivate will update action icons
				module.deactivate()
			else if(!module.holder.offline)
				module.activate()