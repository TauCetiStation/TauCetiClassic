//Regular rig suits
/obj/item/clothing/head/helmet/space/rig
	name = "hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	icon_state = "rig0-engineering"
	item_state = "eng_helm"
	armor = list(melee = 40, bullet = 5, laser = 10,energy = 5, bomb = 35, bio = 100, rad = 20)
	item_action_types = list(/datum/action/item_action/hands_free/toggle_helmet_light)

	allowed = list(/obj/item/device/flashlight)
	var/brightness_on = 4 //luminosity when on
	var/on = 0
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	var/obj/item/clothing/suit/space/rig/rig_connect
	can_be_modded = TRUE

	//Species-specific stuff.
	species_restricted = list("exclude", UNATHI, TAJARAN, SKRELL, DIONA, VOX)
	species_restricted_locked = TRUE
	sprite_sheets_refit = list(
		UNATHI = 'icons/mob/species/unathi/helmet.dmi',
		TAJARAN = 'icons/mob/species/tajaran/helmet.dmi',
		SKRELL = 'icons/mob/species/skrell/helmet.dmi',
		VOX = 'icons/mob/species/vox/helmet.dmi',
		)
	sprite_sheets_obj = list(
		UNATHI = 'icons/obj/clothing/species/unathi/hats.dmi',
		TAJARAN = 'icons/obj/clothing/species/tajaran/hats.dmi',
		SKRELL = 'icons/obj/clothing/species/skrell/hats.dmi',
		VOX = 'icons/obj/clothing/species/vox/hats.dmi',
		)

	var/rig_variant = "engineering"

/datum/action/item_action/hands_free/toggle_helmet_light
	name = "Toggle Helmet Light"

/obj/item/clothing/head/helmet/space/rig/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "You cannot turn the light on while in this [user.loc]")//To prevent some lighting anomalities.
		return
	on = !on
	icon_state = "rig[on]-[rig_variant]"
//	item_state = "rig[on]-[color]"
	update_inv_mob()
	update_item_actions()

	if(on)	set_light(brightness_on)
	else	set_light(0)

/obj/item/clothing/head/helmet/space/rig/dropped(mob/user)
	if(rig_connect)
		rig_connect.helmet = null
		rig_connect = null
		canremove = 1
	return ..()

/obj/item/clothing/suit/space/rig
	name = "hardsuit"
	desc = "A special space suit for environments that might pose hazards beyond just the vacuum of space. Provides more protection than a standard space suit."
	icon_state = "rig-engineering"
	item_state = "eng_hardsuit"
	slowdown = 0.5
	var/magpulse = FALSE
	var/offline_slowdown = 2
	can_be_modded = TRUE
	armor = list(melee = 40, bullet = 5, laser = 10,energy = 5, bomb = 35, bio = 100, rad = 20)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/storage/bag/ore,/obj/item/device/t_scanner, /obj/item/weapon/rcd)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted_locked = TRUE
	species_restricted = list("exclude" , UNATHI , TAJARAN , DIONA , VOX)
	sprite_sheets_refit = list(
		UNATHI = 'icons/mob/species/unathi/suit.dmi',
		TAJARAN = 'icons/mob/species/tajaran/suit.dmi',
		SKRELL = 'icons/mob/species/skrell/suit.dmi',
		VOX = 'icons/mob/species/vox/suit.dmi',
		)
	sprite_sheets_obj = list(
		UNATHI = 'icons/obj/clothing/species/unathi/suits.dmi',
		TAJARAN = 'icons/obj/clothing/species/tajaran/suits.dmi',
		SKRELL = 'icons/obj/clothing/species/skrell/suits.dmi',
		VOX = 'icons/obj/clothing/species/vox/suits.dmi',
		)
	//Breach thresholds, should ideally be inherited by most (if not all) hardsuits.
	breach_threshold = 18
	can_breach = 1

	//Component/device holders.
	var/obj/item/weapon/stock_parts/gloves = null               // Basic capacitor allows insulation, upgrades allow shock gloves etc.

	var/attached_boots = 1                                      // Can't wear boots if some are attached
	var/obj/item/clothing/shoes/magboots/boots = null           // Deployable boots, if any.
	var/attached_helmet = 1                                     // Can't wear a helmet if one is deployable.
	var/obj/item/clothing/head/helmet/space/rig/helmet = null   // Deployable helmet, if any.

	var/max_mounted_devices = 4                                 // Maximum devices. Easy.
	var/list/can_mount = null                                   // Types of device that can be hardpoint mounted.
	var/list/mounted_devices = null                             // Holder for the above device.
	var/obj/item/active_device = null                           // Currently deployed device, if any.

	var/mob/living/carbon/human/wearer                          // The person currently wearing the rig.
	var/offline = TRUE
	var/passive_energy_use = 1
	var/move_energy_use = 1

	var/interface_title = "Hardsuit Controller"
	var/interface_path = "hardsuit.tmpl"
	var/obj/item/rig_module/selected_module = null // Primary system (used with middle-click)
	var/list/initial_modules
	var/list/installed_modules = list() // Power consumption/use bookkeeping.
	var/cell_type = /obj/item/weapon/stock_parts/cell/high
	var/obj/item/weapon/stock_parts/cell/cell // Power supply, if any.
	item_action_types = list(/datum/action/item_action/hands_free/toggle_hardsuit_magboots, /datum/action/item_action/hands_free/toggle_hardsuit_helm)

	var/rig_variant = "engineering"

/obj/item/clothing/suit/space/rig/atom_init()
	. = ..()
	if(initial_modules && initial_modules.len)
		for(var/path in initial_modules)
			var/obj/item/rig_module/module = new path(src)
			module.installed(src)

	if(cell_type)
		cell = new cell_type(src)

/obj/item/clothing/suit/space/rig/Destroy()
	if(wearer) // remove overlays if rig gets deleted while wearing
		var/old_wearer = wearer
		wearer = null
		update_overlays(old_wearer)
		remove_actions(old_wearer)

	selected_module = null
	QDEL_NULL(cell)
	QDEL_NULL(helmet)
	QDEL_LIST(installed_modules)
	. = ..()

/mob/living/carbon/proc/handle_rig_move(NewLoc, Dir)
	if(!ishuman(src))
		return
	var/mob/living/carbon/human/H = src
	var/obj/item/clothing/suit/space/rig/rig = H.wear_suit
	if(!istype(rig))
		return
	if(!rig.offline)
		rig.cell.use(rig.move_energy_use)

/obj/item/clothing/suit/space/rig/attack_reaction(mob/living/L, reaction_type, mob/living/carbon/human/T = null)
	if(reaction_type == REACTION_ITEM_TAKE || reaction_type == REACTION_ITEM_TAKEOFF)
		return
	var/obj/item/rig_module/stealth/module = find_module(/obj/item/rig_module/stealth)
	if(module)
		module.deactivate()


/obj/item/clothing/suit/space/rig/proc/try_use(mob/living/user, cost, use_unconcious, use_stunned)

	if(!istype(user))
		return FALSE

	var/fail_msg

	var/mob/living/carbon/human/H = user
	if(istype(H) && H.wear_suit != src)
		fail_msg = "<span class='warning'>You must be wearing \the [src] to do this.</span>"
	else if((use_unconcious && user.stat == DEAD) || (!use_unconcious && user.stat != CONSCIOUS))
		fail_msg = "<span class='warning'>You are in no fit state to do that.</span>"
	else if(!use_stunned && user.incapacitated(NONE))
		fail_msg = "<span class='warning'>You cannot use the suit in this state.</span>"
	else if(!cell)
		fail_msg = "<span class='warning'>There is no cell installed in the suit.</span>"
	else if(cost && cell.charge < cost)
		fail_msg = "<span class='warning'>Not enough stored power.</span>"

	if(fail_msg)
		to_chat(user, "[fail_msg]")
		return FALSE

	if(cost > 0)
		return cell.use(cost)
	return TRUE

/obj/item/clothing/suit/space/rig/Topic(href,href_list)
	var/mob/living/carbon/human/user = usr
	if(offline || !istype(user) || user.wear_suit != src)
		return FALSE

	if(href_list["interact_module"])

		var/module_index = text2num(href_list["interact_module"])

		if(module_index > 0 && module_index <= installed_modules.len)
			var/obj/item/rig_module/module = installed_modules[module_index]
			switch(href_list["module_mode"])
				if("activate")
					module.activate()
				if("deactivate")
					module.deactivate()
				if("engage")
					module.engage()
				if("select")
					selected_module = module
					update_selected_action()
				if("deselect")
					selected_module = null
					update_selected_action()
				if("toggle")
					if(selected_module == module)
						selected_module = null
					else
						selected_module = module
					update_selected_action()
				if("select_charge_type")
					module.charge_selected = href_list["charge_type"]
		return TRUE
	return TRUE

/obj/item/clothing/suit/space/rig/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(!user)
		return

	var/list/data = list()

	if(selected_module)
		data["primarysystem"] = "[selected_module.interface_name]"

	data["seals"] =     "[src.offline]"
	data["charge"] =       cell ? round(cell.charge,1) : 0
	data["maxcharge"] =    cell ? cell.maxcharge : 0
	data["chargestatus"] = cell ? FLOOR(cell.percent()/2, 1) : 0

	var/list/module_list = list()
	var/i = 1
	for(var/obj/item/rig_module/module in installed_modules)
		var/list/module_data = list(
			"index" =             i,
			"name" =              "[module.interface_name]",
			"desc" =              "[module.interface_desc]",
			"can_use" =           "[module.usable]",
			"can_select" =        "[module.selectable]",
			"can_toggle" =        "[module.toggleable]",
			"is_active" =         "[module.active]",
			"engagecost" =        module.use_power_cost,
			"activecost" =        module.active_power_cost,
			"passivecost" =       module.passive_power_cost,
			"engagestring" =      module.engage_string,
			"activatestring" =    module.activate_string,
			"deactivatestring" =  module.deactivate_string,
			"damage" =            module.damage,
			"show_selected" =     (module.charges && module.charges.len > 1)
			)

		if(module.charges && module.charges.len)

			module_data["charges"] = list()
			var/datum/rig_charge/selected = module.charges[module.charge_selected]
			module_data["chargetype"] = selected ? "[selected.display_name]" : "none"

			for(var/chargetype in module.charges)
				var/datum/rig_charge/charge = module.charges[chargetype]
				module_data["charges"] += list(list("caption" = "[chargetype] ([charge.charges])", "index" = "[chargetype]"))

		module_list += list(module_data)
		i++

	if(module_list.len)
		data["modules"] = module_list

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, interface_path, interface_title, 480, 550)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

//offline should not change outside this proc
/obj/item/clothing/suit/space/rig/proc/update_offline()
	var/go_offline = (!istype(wearer) || loc != wearer || wearer.wear_suit != src || !cell || cell.charge <= 0)
	if(offline != go_offline)
		offline = go_offline
		return TRUE
	return FALSE

/obj/item/clothing/suit/space/rig/process()
	var/changed = update_offline()
	if(changed)
		if(offline)
			to_chat(wearer, "<span class='danger'>Your suit beeps stridently, and suddenly goes dead.</span>")

			for(var/obj/item/rig_module/module in installed_modules)
				module.deactivate()
		if(!offline)
			for(var/obj/item/rig_module/module in installed_modules)
				if(module.activate_on_start)
					module.activate()

		if(!offline)
			slowdown = initial(slowdown)
		else
			slowdown = offline_slowdown


	if(!offline)
		var/total_energy_use = passive_energy_use

		for(var/obj/item/rig_module/module in installed_modules)
			total_energy_use += module.process_module()
			if(!wearer) // module might unequip us
				break
		if(total_energy_use > 0)
			cell.use(total_energy_use)
		else if(total_energy_use < 0)
			cell.give(-total_energy_use)

/obj/item/clothing/suit/space/rig/proc/give_actions(mob/living/carbon/human/H)
	for(var/obj/item/rig_module/module in installed_modules)
		if(module.selectable)
			var/datum/action/module_select/action = new(module)
			action.Grant(H)
		if(module.show_toggle_button)
			var/datum/action/module_toggle/action = new(module)
			action.Grant(H)

/obj/item/clothing/suit/space/rig/proc/remove_actions(mob/living/carbon/human/H)
	for(var/datum/action/module_select/action in H.actions)
		if(istype(action))
			action.Remove(H)
	for(var/datum/action/module_toggle/action in H.actions)
		if(istype(action))
			action.Remove(H)

/obj/item/clothing/suit/space/rig/proc/update_selected_action()
	if(!wearer)
		return

	var/mob/living/carbon/human/H = wearer
	for(var/datum/action/module_select/action in H.actions)
		if(istype(action))
			if(selected_module == action.target) // highlight selected module
				action.background_icon_state = "bg_spell"
			else
				action.background_icon_state = "bg_default"
	H.update_action_buttons()

/obj/item/clothing/suit/space/rig/proc/update_activated_actions()
	if(!wearer)
		return

	var/mob/living/carbon/human/H = wearer
	for(var/datum/action/module_toggle/action in H.actions)
		if(istype(action))
			var/obj/item/rig_module/module = action.target
			if(istype(module))
				if(module.active) // highlight active modules
					action.background_icon_state = "bg_active"
					action.name = module.deactivate_string
				else
					action.background_icon_state = "bg_default"
					action.name = module.activate_string
	H.update_action_buttons()

/obj/item/clothing/suit/space/rig/equipped(mob/M, slot)
	..()
	var/mob/living/carbon/human/H = M

	if(!istype(H))
		return

	if(slot == SLOT_WEAR_SUIT)
		wearer = H
		update_overlays(wearer)
		give_actions(wearer)

		if(!offline) // so rigs without cell are slow
			slowdown = initial(slowdown)
		else
			slowdown = offline_slowdown

	if(H.wear_suit != src)
		return

	START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/space/rig/dropped(mob/user)
	..()
	var/old_wearer = wearer
	wearer = null
	var/mob/living/carbon/human/H

	if(helmet)
		H = helmet.loc
		if(istype(H))
			if(helmet && H.head == helmet)
				helmet.canremove = 1
				var/dropped_helmet = helmet
				H.drop_from_inventory(helmet)
				helmet = dropped_helmet		//attach the helmet back to the suit
				helmet.loc = src

	if(boots)
		H = boots.loc
		if(istype(H))
			if(boots && H.shoes == boots)
				boots.canremove = 1
				H.drop_from_inventory(boots)
				boots.loc = src

	if(old_wearer)
		update_overlays(old_wearer)
		remove_actions(old_wearer)
		disable_magpulse(old_wearer)
		selected_module = null

		STOP_PROCESSING(SSobj, src)
		process() // process one last time so we can disable all modules and other stuff

/obj/item/clothing/suit/space/rig/verb/toggle_helmet()

	set name = "Toggle Helmet"
	set category = "Object"
	set src in usr

	if(!isliving(src.loc)) return

	if(!helmet)
		to_chat(usr, "There is no helmet installed.")
		return

	var/mob/living/carbon/human/H = usr

	if(!istype(H)) return
	if(H.incapacitated())
		return
	if(H.wear_suit != src) return

	if(H.head == helmet)
		helmet.canremove = 1
		var/dropped_helmet = helmet
		H.drop_from_inventory(helmet)
		helmet = dropped_helmet		//attach the helmet back to the suit
		helmet.loc = src
		to_chat(H, "<span class='notice'>You retract your hardsuit helmet.</span>")

	else if(H.equip_to_slot_if_possible(helmet, SLOT_HEAD))
		helmet.canremove = 0
		if(helmet.on)
			helmet.set_light(helmet.brightness_on)
		else
			helmet.set_light(0)

		to_chat(H, "<span class='notice'>You deploy your hardsuit helmet, sealing you off from the world.</span>")
		return

/obj/item/clothing/suit/space/rig/verb/toggle_magboots()

	set name = "Toggle Space Suit Magboots"
	set category = "Object"
	set src in usr

	if(!isliving(src.loc)) return

	if(!boots)
		to_chat(usr, "\The [src] does not have any boots installed.")
		return

	var/mob/living/carbon/human/H = usr

	if(!istype(H)) return
	if(H.incapacitated())
		return
	if(H.wear_suit != src) return

	if(magpulse)
		disable_magpulse(H)
	else
		enable_magpulse(H)
	H.update_gravity(H.mob_has_gravity())

/obj/item/clothing/suit/space/rig/proc/enable_magpulse(mob/user)
		flags |= NOSLIP | AIR_FLOW_PROTECT
		slowdown += boots.slowdown_off
		magpulse = TRUE
		to_chat(user, "You enable \the [src] the mag-pulse traction system.")

/obj/item/clothing/suit/space/rig/proc/disable_magpulse(mob/user)
		flags &= ~(NOSLIP | AIR_FLOW_PROTECT)
		slowdown = initial(slowdown)
		magpulse = FALSE
		to_chat(user, "You disable \the [src] the mag-pulse traction system.")

/obj/item/clothing/suit/space/rig/negates_gravity()
	return flags & NOSLIP

/obj/item/clothing/suit/space/rig/examine(mob/user)
	..()
	to_chat(user, "Its mag-pulse traction system appears to be [magpulse ? "enabled" : "disabled"].")

/obj/item/clothing/suit/space/rig/emp_act(severity)
	for(var/obj/item/rig_module/installed_mod in installed_modules)
		if(installed_mod.type == /obj/item/rig_module/emp_shield)
			var/obj/item/rig_module/emp_shield/shield = installed_mod
			if(shield.uses > 0)
				shield.uses--
				shield.interface_desc = "Device for protecting the hardsuit from EMP. Can withstand [shield.uses] more EMPs."
				to_chat(wearer, "<span class='warning'>[installed_mod.name] absorbs EMP. [shield.uses] uses left!</span>")
				return

	//drain some charge
	if(cell)
		cell.emplode(severity + 1)

	//possibly damage some modules
	take_hit((100/severity), "electrical pulse", is_emp = TRUE)

/obj/item/clothing/suit/space/rig/proc/find_module(module_type)
	for(var/obj/item/rig_module/module in installed_modules)
		if(istype(module, module_type))
			return module
	return null

/obj/item/clothing/suit/space/rig/proc/can_install(obj/item/rig_module/new_module)
	if(installed_modules.len >= max_mounted_devices)
		to_chat(usr, "The hardsuit has a maximum amount of modules installed.")
		return FALSE

	if(new_module.redundant)
		return TRUE

	for(var/obj/item/rig_module/installed_mod in installed_modules)
		if(installed_mod.type == new_module.type)
			to_chat(usr, "The hardsuit already has a module of that class installed.")
			return FALSE
		if(installed_mod.mount_type & new_module.mount_type)
			to_chat(usr, "The hardsuit already has [installed_mod.name] installed in that mount spot.")
			return FALSE

	return TRUE

/obj/item/clothing/suit/space/rig/proc/take_hit(damage, source, is_emp = FALSE)

	if(!installed_modules.len)
		return

	var/chance
	if(!is_emp)
		var/damage_resistance = breach_threshold
		chance = 2*max(0, damage - damage_resistance)
	else
		//Want this to be roughly independant of the number of modules, meaning that X emp hits will disable Y% of the suit's modules on average.
		//that way people designing hardsuits don't have to worry (as much) about how adding that extra module will affect emp resiliance by 'soaking' hits for other modules
		chance = 2*max(0, damage)*min(installed_modules.len/15, 1)

	if(!prob(chance))
		return

	var/list/valid_modules = list()
	for(var/obj/item/rig_module/module in installed_modules)
		if(module.damage < MODULE_DESTROYED)
			valid_modules += module

	if(!valid_modules.len)
		return
	var/obj/item/rig_module/dam_module = pick(valid_modules)

	if(!dam_module)
		return

	dam_module.damage++

	if(!source)
		source = "hit"

	if(wearer)
		var/obj/item/rig_module/simple_ai/ai = find_module(/obj/item/rig_module/simple_ai)
		if(ai && ai.active)
			ai.handle_module_damage(source, dam_module)
		else
			to_chat(wearer, "<span class='danger'>The [source] has damaged one of your rig modules</span>")
	dam_module.deactivate()

/obj/item/clothing/suit/space/rig/proc/update_overlays(mob/user)
	var/equipped = (wearer == user)

	for(var/obj/item/rig_module/module in installed_modules)
		if(module.suit_overlay_image)
			user.cut_overlay(module.suit_overlay_image)
			if(equipped)
				user.add_overlay(module.suit_overlay_image)

// action buttons
/datum/action/item_action/hands_free/toggle_hardsuit_magboots
	name = "Toggle hardsuit magboots"
	button_icon_state = "toggle_rig_magboots"
	action_type = AB_INNATE


/datum/action/item_action/hands_free/toggle_hardsuit_magboots/Activate()
	var/obj/item/clothing/suit/space/rig/S = target
	S.toggle_magboots()


/datum/action/item_action/hands_free/toggle_hardsuit_helm
	name = "Toggle helmet"
	button_icon_state = "toggle_rig_helm"
	action_type = AB_INNATE

/datum/action/item_action/hands_free/toggle_hardsuit_helm/Activate()
	var/obj/item/clothing/suit/space/rig/S = target
	S.toggle_helmet()



//Engineering rig
/obj/item/clothing/head/helmet/space/rig/engineering
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "rig0-engineering"
	item_state = "eng_helm"
	armor = list(melee = 50, bullet = 5, laser = 10,energy = 5, bomb = 65, bio = 100, rad = 80)
	siemens_coefficient = 0

/obj/item/clothing/suit/space/rig/engineering
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding. Heavy insulation layer adds additional weight"
	icon_state = "rig-engineering"
	item_state = "eng_hardsuit"
	slowdown = 1.5
	armor = list(melee = 50, bullet = 5, laser = 10,energy = 5, bomb = 65, bio = 100, rad = 80)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/storage/bag/ore,/obj/item/device/t_scanner,/obj/item/weapon/pickaxe, /obj/item/weapon/rcd)
	siemens_coefficient = 0
	max_mounted_devices = 4
	initial_modules = list(/obj/item/rig_module/simple_ai, /obj/item/rig_module/device/extinguisher, /obj/item/rig_module/cooling_unit, /obj/item/rig_module/metalfoam_spray)

//Chief Engineer's rig
/obj/item/clothing/head/helmet/space/rig/engineering/chief
	name = "advanced hardsuit helmet"
	desc = "An advanced helmet designed for work in a hazardous, low pressure environment. Shines with a high polish."
	icon_state = "rig0-chief"
	item_state = "ce_helm"
	rig_variant = "chief"
	armor = list(melee = 55, bullet = 5, laser = 15,energy = 10, bomb = 65, bio = 100, rad = 90)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/space/rig/engineering/chief
	icon_state = "rig-chief"
	name = "advanced hardsuit"
	desc = "An advanced suit that protects against hazardous, low pressure environments. Shines with a high polish."
	item_state = "ce_hardsuit"
	slowdown = 0.5
	armor = list(melee = 55, bullet = 5, laser = 15,energy = 10, bomb = 65, bio = 100, rad = 90)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	max_mounted_devices = 7
	initial_modules = list(/obj/item/rig_module/simple_ai/advanced, /obj/item/rig_module/selfrepair, /obj/item/rig_module/device/rcd, /obj/item/rig_module/nuclear_generator, /obj/item/rig_module/device/extinguisher, /obj/item/rig_module/cooling_unit, /obj/item/rig_module/emp_shield)

//Mining rig
/obj/item/clothing/head/helmet/space/rig/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating."
	icon_state = "rig0-mining"
	item_state = "mining_helm"
	slowdown = 0.6
	rig_variant = "mining"
	armor = list(melee = 60, bullet = 5, laser = 10,energy = 5, bomb = 55, bio = 100, rad = 20)

/obj/item/clothing/suit/space/rig/mining
	icon_state = "rig-mining"
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating."
	item_state = "mining_hardsuit"
	armor = list(melee = 90, bullet = 5, laser = 10,energy = 5, bomb = 55, bio = 100, rad = 20)
	breach_threshold = 26
	max_mounted_devices = 4
	initial_modules = list(/obj/item/rig_module/simple_ai, /obj/item/rig_module/device/orescanner, /obj/item/rig_module/device/drill)

//Red Faction mining rig
/obj/item/clothing/head/helmet/space/rig/RF_mining
	name = "Red mining helmet"
	desc = "A special mining helmet designed for work in a hazardous, low pressure environment."
	icon_state = "rig0-RedMiner"
	item_state = "RedMiner_helm"
	rig_variant = "RedMiner"
	armor = list(melee = 40, bullet = 10, laser = 10,energy = 5, bomb = 50, bio = 100, rad = 50)

/obj/item/clothing/suit/space/rig/RF_mining
	name = "Red mining hardsuit"
	desc = "A special suit that protects against hazardous, has reinforced plating."
	icon_state = "RedMiner"
	item_state = "RedMiner"
	rig_variant = "RedMiner"
	armor = list(melee = 40, bullet = 11, laser = 10,energy = 5, bomb = 50, bio = 100, rad = 50)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/bag/ore,/obj/item/weapon/pickaxe)

//Syndicate rig
/obj/item/clothing/head/helmet/space/rig/syndi
	name = "blood-red hybrid helmet"
	desc = "An advanced helmet designed for work in special operations. Property of Gorlex Marauders."
	icon_state = "rig0-syndie"
	item_state = "syndie_helm"
	var/space_armor = list(melee = 60, bullet = 55, laser = 30,energy = 30, bomb = 50, bio = 100, rad = 60)
	var/combat_armor = list(melee = 60, bullet = 65, laser = 55,energy = 45, bomb = 50, bio = 100, rad = 60)
	var/obj/machinery/camera/camera
	var/combat_mode = FALSE
	species_restricted = list("exclude" , SKRELL , DIONA, VOX)
	var/image/lamp = null
	var/equipped_on_head = FALSE
	var/rig_type = "syndie"
	var/glowtype = "terror"
	flags = BLOCKHAIR | PHORONGUARD
	light_color = LIGHT_COLOR_NUKE_OPS

/obj/item/clothing/head/helmet/space/rig/syndi/atom_init()
	. = ..()
	armor = combat_mode ? combat_armor : space_armor // in case some child spawns with combat mode on

	holochip = new /obj/item/holochip/nuclear(src)
	holochip.holder = src

/obj/item/clothing/head/helmet/space/rig/syndi/AltClick(mob/user)
	var/mob/living/carbon/wearer = loc
	if(!istype(wearer) || wearer.head != src)
		to_chat(usr, "<span class='warning'>The helmet is not being worn.</span>")
		return
	toggle()

/obj/item/clothing/head/helmet/space/rig/syndi/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_HEAD)
		equipped_on_head = TRUE
		update_icon(user)

/obj/item/clothing/head/helmet/space/rig/syndi/dropped(mob/user)
	. = ..()
	if(equipped_on_head)
		equipped_on_head = FALSE
		update_icon(user)

/obj/item/clothing/head/helmet/space/rig/syndi/proc/checklight()
	if(on)
		set_light(l_range = brightness_on, l_color = light_color)
	else if(combat_mode)
		set_light(l_range = 1.23) // Minimal possible light_range that'll make helm lights visible in full dark from distance. Most likely going to break if somebody will touch lightning formulae.
	else
		set_light(0)

/obj/item/clothing/head/helmet/space/rig/syndi/update_icon(mob/user)
	icon_state = "rig[on]-[rig_type][combat_mode ? "-combat" : ""]"
	if(user)
		user.cut_overlay(lamp)
		if(equipped_on_head && camera && on)
			lamp = image(icon = 'icons/mob/nuclear_helm_overlays.dmi', icon_state = "[glowtype][combat_mode ? "_combat" : ""]_glow")
			if(ishuman(user)) //Lets Update Lamps offset because human have height
				var/mob/living/carbon/human/H = user
				H.human_update_offset(lamp, TRUE)
			lamp.plane = LIGHTING_LAMPS_PLANE
			lamp.layer = ABOVE_LIGHTING_LAYER
			lamp.alpha = 255
			user.add_overlay(lamp)
		update_inv_mob()

/obj/item/clothing/head/helmet/space/rig/syndi/attack_self(mob/user)
	if(camera)
		on = !on
	else
		camera = new /obj/machinery/camera(src)
		camera.replace_networks(list("NUKE"))
		cameranet.removeCamera(camera)
		camera.c_tag = user.name
		to_chat(user, "<span class='notice'>User scanned as [camera.c_tag]. Camera activated.</span>")
	checklight()
	update_icon(user)

/obj/item/clothing/head/helmet/space/rig/syndi/verb/toggle()
	set category = "Object"
	set name = "Adjust helmet"
	set src in usr

	if(!usr.incapacitated())
		combat_mode = !combat_mode
		if(combat_mode)
			armor = combat_armor
			canremove = FALSE
			flags |= (HEADCOVERSEYES | HEADCOVERSMOUTH)
			usr.visible_message("<span class='notice'>[usr] moves faceplate of their helmet into combat position, covering their visor and extending cameras.</span>")
		else
			armor = space_armor
			canremove = TRUE
			flags &= ~(HEADCOVERSEYES | HEADCOVERSMOUTH)
			usr.visible_message("<span class='notice'>[usr] pulls up faceplate from helmet's visor, retracting cameras</span>")
		checklight()
		update_icon(usr)

/obj/item/clothing/head/helmet/space/rig/syndi/examine(mob/user)
	..()
	if(src in view(1, user))
		to_chat(user, "This helmet has a built-in camera. It's [camera ? "" : "in"]active.")

/obj/item/clothing/head/helmet/space/rig/syndi/attackby(obj/item/I, mob/user, params)
	var/mob/living/carbon/human/H = user
	if(!istype(H) || H.species.flags[IS_SYNTHETIC])
		return ..()
	if(!istype(I, /obj/item/weapon/reagent_containers/pill))
		return ..()
	if(!combat_mode && equipped_on_head)
		user.SetNextMove(CLICK_CD_RAPID)
		var/obj/item/weapon/reagent_containers/pill/P = I
		P.reagents.trans_to_ingest(user, I.reagents.total_volume)
		to_chat(user, "<span class='notice'>[src] consumes [I] and injects reagents to you!</span>")
		qdel(I)

/obj/item/clothing/suit/space/rig/syndi
	name = "blood-red hybrid suit"
	desc = "An advanced suit that protects against injuries during special operations. Property of Gorlex Marauders."
	icon_state = "rig-syndie-space"
	item_state = "syndie_hardsuit"
	rig_variant = "rig-syndie"
	slowdown = 0.9
	allowed = list(/obj/item/device/flashlight,
	               /obj/item/weapon/tank,
	               /obj/item/device/suit_cooling_unit,
	               /obj/item/weapon/gun,
	               /obj/item/ammo_box/magazine,
	               /obj/item/ammo_casing,
	               /obj/item/weapon/melee/baton,
	               /obj/item/weapon/melee/energy/sword,
	               /obj/item/weapon/handcuffs)
	species_restricted = list("exclude" , UNATHI , TAJARAN , DIONA, VOX)
	max_mounted_devices = 4
	initial_modules = list(/obj/item/rig_module/simple_ai/advanced, /obj/item/rig_module/selfrepair/adv, /obj/item/rig_module/emp_shield)
	cell_type = /obj/item/weapon/stock_parts/cell/super
	var/combat_mode = FALSE
	var/combat_armor = list(melee = 60, bullet = 65, laser = 55, energy = 45, bomb = 50, bio = 100, rad = 60)
	var/space_armor = list(melee = 30, bullet = 20, laser = 20, energy = 30, bomb = 50, bio = 100, rad = 60)
	var/combat_slowdown = 0
	item_action_types = list(/datum/action/item_action/hands_free/toggle_hardsuit_magboots, /datum/action/item_action/hands_free/toggle_hardsuit_helm,
	/datum/action/item_action/hands_free/toggle_space_suit_mode)

/datum/action/item_action/hands_free/toggle_space_suit_mode
	name = "Toggle space suit mode"

/datum/action/item_action/hands_free/toggle_space_suit_mode/Activate()
	var/obj/item/clothing/suit/space/rig/syndi/S = target
	S.toggle_mode()

/obj/item/clothing/suit/space/rig/syndi/atom_init()
	. = ..()
	armor = combat_mode ? combat_armor : space_armor // in case some child spawns with combat mode on
	var/obj/item/clothing/shoes/magboots/syndie/SB = new(src)
	boots = SB

/obj/item/clothing/suit/space/rig/syndi/AltClick(mob/user)
	if(wearer?.wear_suit != src)
		to_chat(usr, "<span class='warning'>The hardsuit is not being worn.</span>")
		return
	toggle_mode()

/obj/item/clothing/suit/space/rig/syndi/update_icon(mob/user)
	..()
	icon_state = "[rig_variant]-[combat_mode ? "combat" : "space"]"
	update_inv_mob()

/obj/item/clothing/suit/space/rig/syndi/verb/toggle_mode()
	set category = "Object"
	set name = "Adjust space suit"
	set src in usr

	if(!usr.incapacitated())
		combat_mode = !combat_mode
		var/obj/item/clothing/head/helmet/space/rig/syndi/H = helmet
		if(istype(H))
			if(H.combat_mode != combat_mode)
				H.toggle()
		if(combat_mode)
			canremove = FALSE
			can_breach = FALSE
			flags_pressure &= ~STOPS_PRESSUREDMAGE
			playsound(usr, 'sound/effects/air_release.ogg', VOL_EFFECTS_MASTER)
			slowdown = combat_slowdown
			usr.visible_message("<span class='notice'>[usr]'s suit depressurizes, exposing armor plates.</span>")
			armor = combat_armor
		else
			canremove = TRUE
			can_breach = TRUE
			flags_pressure |= STOPS_PRESSUREDMAGE
			playsound(usr, 'sound/effects/inflate.ogg', VOL_EFFECTS_MASTER, 30)
			slowdown = initial(slowdown)
			usr.visible_message("<span class='notice'>[usr]'s suit inflates and pressurizes.</span>")
			armor = space_armor
		if(magpulse)
			slowdown += boots.slowdown_off
		update_icon(usr)
		update_item_actions()

/obj/item/clothing/suit/space/rig/syndi/disable_magpulse(mob/user)
	flags &= ~(NOSLIP | AIR_FLOW_PROTECT)
	if(combat_mode)
		slowdown = combat_slowdown
	else
		slowdown = initial(slowdown)
	magpulse = FALSE
	to_chat(user, "You disable \the [src] the mag-pulse traction system.")

/obj/item/clothing/head/helmet/space/rig/syndi/heavy
	name = "heavy hybrid helmet"
	desc = "An advanced helmet designed for work in special operations. Created using older design of armored hardsuits."
	icon_state = "rig0-heavy"
	item_state = "syndie_helm"
	combat_armor = list(melee = 75, bullet = 80, laser = 70,energy = 55, bomb = 50, bio = 100, rad = 30)
	space_armor = list(melee = 60, bullet = 65, laser = 55, energy = 45, bomb = 50, bio = 100, rad = 60)
	rig_type = "heavy"

/obj/item/clothing/suit/space/rig/syndi/heavy
	name = "heavy hybrid suit"
	desc = "An advanced suit that protects against injuries during special operations. Heavily armored and rarely used aside from open combat conflicts."
	icon_state = "rig-heavy-space"
	item_state = "syndie_hardsuit"
	rig_variant = "rig-heavy"
	slowdown = 1.2
	initial_modules = list(/obj/item/rig_module/simple_ai/advanced, /obj/item/rig_module/selfrepair/adv, /obj/item/rig_module/chem_dispenser/combat, /obj/item/rig_module/emp_shield)
	combat_armor = list(melee = 75, bullet = 80, laser = 70,energy = 55, bomb = 50, bio = 100, rad = 30)
	space_armor = list(melee = 45, bullet = 30, laser = 30, energy = 45, bomb = 50, bio = 100, rad = 60)
	combat_slowdown = 0.5

/obj/item/clothing/head/helmet/space/rig/syndi/elite
	name = "Syndicate elite hybrid helmet"
	desc = "A hybrid helmet made by the best engineers and designers on special order for elite syndicate operatives"
	icon_state = "rig0-syndie_elit"
	rig_type = "syndie_elit"
	item_state = "syndicate-helm-elite"
	space_armor = list(melee = 65, bullet = 65, laser = 55,energy = 40, bomb = 50, bio = 100, rad = 70)
	combat_armor = list(melee = 85, bullet = 80, laser = 70,energy = 70, bomb = 75, bio = 75, rad = 70)
	glowtype = "terrorelit"
	light_color = "#e51a1a"
	can_be_modded = FALSE

/obj/item/clothing/head/helmet/space/rig/syndi/elite/comander
	name = "Syndicate elite hybrid helmet"
	desc = "A hybrid helmet made by the best engineers and designers on special order for elite syndicate operatives"
	icon_state = "rig0-syndie_elitcom"
	item_state = "syndicate-helm-commander"
	rig_type = "syndie_elitcom"

/obj/item/clothing/suit/space/rig/syndi/elite
	name = "Syndicate elite hybrid suit"
	desc = "A hybrid suit made by the best engineers and designers on special order for elite syndicate operatives"
	icon_state = "rig-syndie_elit-space"
	item_state = "syndicate-elite"
	rig_variant = "rig-syndie_elit"
	slowdown = 0.7
	combat_armor = list(melee = 80, bullet = 75, laser = 65, energy = 65, bomb = 70, bio = 70, rad = 70)
	space_armor = list(melee = 65, bullet = 60, laser = 50, energy = 35, bomb = 50, bio = 100, rad = 70)
	combat_slowdown = 0.2
	initial_modules = list(/obj/item/rig_module/simple_ai/advanced, /obj/item/rig_module/selfrepair/adv, /obj/item/rig_module/syndiemmessage, /obj/item/rig_module/emp_shield)
	can_be_modded = FALSE

/obj/item/clothing/suit/space/rig/syndi/elite/comander
	name = "Syndicate elite hybrid suit"
	desc = "A hybrid suit made by the best engineers and designers on special order for elite syndicate operatives"
	icon_state = "rig-syndie_elitcom-space"
	item_state = "syndicate-commander"
	rig_variant = "rig-syndie_elitcom"

/obj/item/clothing/head/helmet/space/rig/syndi/hazmat
	name = "hazmat hybrid helmet"
	desc = "Anyone wearing this should not be considered human."
	icon_state = "rig0-hazmat"
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	unacidable = TRUE
	combat_armor = list(melee = 55, bullet = 60, laser = 50, energy = 55, bomb = 100, bio = 100, rad = 100)
	space_armor = list(melee = 55, bullet = 50, laser = 40, energy = 45, bomb = 80, bio = 100, rad = 80)
	glowtype = "terrohazmat"
	rig_type = "hazmat"

/obj/item/clothing/suit/space/rig/syndi/hazmat
	name = "hazmat hybrid suit"
	desc = "Menacing space suit painted in blood-red colors resembling an outdated hazmat suit. Designed for chemical and psychological warfare."
	icon_state = "rig-hazmat-space"
	item_state = "syndie_hazmat"
	rig_variant = "rig-hazmat"
	slowdown = 0.7
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	unacidable = TRUE
	initial_modules = list(/obj/item/rig_module/simple_ai/advanced, /obj/item/rig_module/selfrepair/adv, /obj/item/rig_module/emp_shield, /obj/item/rig_module/cooling_unit/advanced)
	allowed = list(/obj/item/device/flashlight,
	               /obj/item/weapon/tank,
	               /obj/item/device/suit_cooling_unit,
	               /obj/item/weapon/gun,
	               /obj/item/ammo_box/magazine,
	               /obj/item/ammo_casing,
	               /obj/item/weapon/melee/baton,
	               /obj/item/weapon/melee/energy/sword,
	               /obj/item/weapon/handcuffs)
	combat_armor = list(melee = 55, bullet = 60, laser = 50, energy = 55, bomb = 100, bio = 100, rad = 100)
	space_armor = list(melee = 30, bullet = 20, laser = 20, energy = 45, bomb = 80, bio = 100, rad = 80)

//Wizard Rig
/obj/item/clothing/head/helmet/space/rig/wizard
	name = "gem-encrusted hardsuit helmet"
	desc = "A bizarre gem-encrusted helmet that radiates magical energies."
	icon_state = "rig0-wiz"
	item_state = "wiz_helm"
	rig_variant = "wiz"
	unacidable = 1 //No longer shall our kind be foiled by lone chemists with spray bottles!
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 25, bomb = 33, bio = 100, rad = 66)

/obj/item/clothing/head/helmet/space/rig/wizard/atom_init(mapload, ...)
	. = ..()
	AddComponent(/datum/component/magic_item/wizard)

/obj/item/clothing/suit/space/rig/wizard
	icon_state = "rig-wiz"
	name = "gem-encrusted hardsuit"
	desc = "A bizarre gem-encrusted suit that radiates magical energies."
	item_state = "wiz_hardsuit"
	slowdown = 0.5
	unacidable = 1
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 25, bomb = 33, bio = 100, rad = 66)
	max_mounted_devices = 4
	initial_modules = list(/obj/item/rig_module/simple_ai, /obj/item/rig_module/emp_shield/adv)

/obj/item/clothing/suit/space/rig/wizard/atom_init(mapload, ...)
	. = ..()
	AddComponent(/datum/component/magic_item/wizard)

//Medical Rig
/obj/item/clothing/head/helmet/space/rig/medical
	name = "medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has minor radiation shielding."
	icon_state = "rig0-medical"
	item_state = "medical_helm"
	rig_variant = "medical"
	armor = list(melee = 30, bullet = 5, laser = 10,energy = 5, bomb = 25, bio = 100, rad = 50)

/obj/item/clothing/suit/space/rig/medical
	icon_state = "rig-medical"
	name = "medical hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has minor radiation shielding."
	item_state = "medical_hardsuit"
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/storage/firstaid,/obj/item/device/healthanalyzer,/obj/item/stack/medical)
	armor = list(melee = 30, bullet = 5, laser = 10,energy = 5, bomb = 25, bio = 100, rad = 50)
	max_mounted_devices = 4
	initial_modules = list(/obj/item/rig_module/simple_ai, /obj/item/rig_module/device/healthscanner)

//CMO Rig
/obj/item/clothing/head/helmet/space/rig/medical/cmo
	name = "advanced medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has minor radiation shielding."
	icon_state = "rig0-cmo"
	item_state = "cmo_helm"
	rig_variant = "cmo"

/obj/item/clothing/suit/space/rig/medical/cmo
	icon_state = "rig-cmo"
	name = "advanced medical hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has minor radiation shielding."
	item_state = "cmo_hardsuit"
	slowdown = 0.2
	max_mounted_devices = 6
	initial_modules = list(/obj/item/rig_module/simple_ai/advanced, /obj/item/rig_module/selfrepair, /obj/item/rig_module/med_teleport, /obj/item/rig_module/chem_dispenser/medical, /obj/item/rig_module/device/healthscanner)

//Security
/obj/item/clothing/head/helmet/space/rig/security
	name = "security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "rig0-sec"
	item_state = "sec_helm"
	rig_variant = "sec"
	armor = list(melee = 45, bullet = 30, laser = 30, energy = 30, bomb = 65, bio = 100, rad = 10)

/obj/item/clothing/suit/space/rig/security
	icon_state = "rig-sec"
	name = "security hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	item_state = "sec_hardsuit"
	armor = list(melee = 45, bullet = 30, laser = 30, energy = 30, bomb = 65, bio = 100, rad = 10)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/melee/baton)
	breach_threshold = 20
	slowdown = 0.7
	max_mounted_devices = 4
	initial_modules = list(/obj/item/rig_module/simple_ai, /obj/item/rig_module/selfrepair, /obj/item/rig_module/device/flash)

	var/brightness_on = 2 //luminosity when on
	var/on = 0

	light_color = "#ff00ff"
	item_action_types = list(/datum/action/item_action/hands_free/toggle_hardsuit_magboots, /datum/action/item_action/hands_free/toggle_hardsuit_helm,
	/datum/action/item_action/hands_free/toggle_hardsuit_light)

/datum/action/item_action/hands_free/toggle_hardsuit_light
	name = "Toggle Hardsuit Light"

/obj/item/clothing/suit/space/rig/security/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "You cannot turn the light on while in this [user.loc]")//To prevent some lighting anomalities.
		return
	on = !on
	icon_state = "rig-sec[on ? "-light" : ""]"
	update_inv_mob()
	update_item_actions()

	if(on)	set_light(brightness_on)
	else	set_light(0)

//HoS Rig
/obj/item/clothing/head/helmet/space/rig/security/hos
	name = "advanced security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "rig0-hos"
	item_state = "hos_helm"
	rig_variant = "hos"

/obj/item/clothing/suit/space/rig/security/hos
	icon_state = "rig-hos"
	name = "advanced security hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	item_state = "hos_hardsuit"
	slowdown = 0.3
	max_mounted_devices = 6
	initial_modules = list(/obj/item/rig_module/simple_ai/advanced, /obj/item/rig_module/selfrepair, /obj/item/rig_module/mounted/taser, /obj/item/rig_module/med_teleport, /obj/item/rig_module/chem_dispenser/combat, /obj/item/rig_module/grenade_launcher/flashbang)

	item_action_types = list(/datum/action/item_action/hands_free/toggle_hardsuit_magboots, /datum/action/item_action/hands_free/toggle_hardsuit_helm)

//Atmospherics Rig (BS12)
/obj/item/clothing/head/helmet/space/rig/atmos
	desc = "A special helmet designed for work in a hazardous, low pressure environments. Has improved thermal protection and minor radiation shielding."
	name = "atmospherics hardsuit helmet"
	icon_state = "rig0-atmos"
	item_state = "atmos_helm"
	rig_variant = "atmos"
	armor = list(melee = 40, bullet = 5, laser = 10,energy = 5, bomb = 65, bio = 100, rad = 50)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/space/rig/atmos
	desc = "A special suit that protects against hazardous, low pressure environments. Has improved thermal protection and minor radiation shielding."
	icon_state = "rig-atmos"
	name = "atmos hardsuit"
	item_state = "atmos_hardsuit"
	armor = list(melee = 40, bullet = 5, laser = 10,energy = 5, bomb = 65, bio = 100, rad = 50)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	max_mounted_devices = 4
	initial_modules = list(/obj/item/rig_module/simple_ai, /obj/item/rig_module/device/extinguisher, /obj/item/rig_module/cooling_unit, /obj/item/rig_module/metalfoam_spray)

//Science rig
/obj/item/clothing/head/helmet/space/rig/science
	desc = "A special helmet designed for work in a hazardous, low pressure environments. Has low weight and improved module management system."
	name = "science hardsuit helmet"
	icon_state = "rig0-science"
	item_state = "sceince_helm"
	rig_variant = "science"
	unacidable = TRUE
	armor = list(melee = 5, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 60)

/obj/item/clothing/suit/space/rig/science
	desc = "A special suit that protects against hazardous, low pressure environments. Has low weight and improved module management system."
	icon_state = "rig-science"
	name = "science hardsuit"
	item_state = "science_hardsuit"
	armor = list(melee = 5, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 60)
	unacidable = TRUE
	max_mounted_devices = 6
	slowdown = 0.2
	offline_slowdown = 3.5
	initial_modules = list( /obj/item/rig_module/teleporter_stabilizer , /obj/item/rig_module/cooling_unit, /obj/item/rig_module/device/science_tool, /obj/item/rig_module/device/analyzer , /obj/item/rig_module/simple_ai, /obj/item/rig_module/device/anomaly_scanner)

/obj/item/clothing/head/helmet/space/rig/science/rd
	desc = "A special helmet designed for work in a hazardous, low pressure environments. Has low weight and integrated HUD."
	name = "advanced science hardsuit helmet"
	icon_state = "rig0-rd"
	item_state = "rd_helm"
	rig_variant = "rd"
	armor = list(melee = 10, bullet = 10, laser = 15, energy = 10, bomb = 55, bio = 100, rad = 70)

/obj/item/clothing/head/helmet/space/rig/science/rd/equipped(mob/living/carbon/human/user, slot)
	..()
	if(slot != SLOT_HEAD)
		return
	var/datum/atom_hud/data/diagnostic/diag_hud = global.huds[DATA_HUD_DIAGNOSTIC]
	diag_hud.add_hud_to(user)

/obj/item/clothing/head/helmet/space/rig/science/rd/dropped(mob/user)
	. = ..()
	if(!istype(user))
		return
	var/datum/atom_hud/data/diagnostic/diag_hud = global.huds[DATA_HUD_DIAGNOSTIC]
	diag_hud.remove_hud_from(user)

/obj/item/clothing/suit/space/rig/science/rd
	desc = "A special suit that protects against hazardous, low pressure environments. Has low weight and improved module management system."
	icon_state = "rig-rd"
	name = "advanced science hardsuit"
	item_state = "rd_hardsuit"
	armor = list(melee = 10, bullet = 10, laser = 15, energy = 10, bomb = 55, bio = 100, rad = 70)
	max_mounted_devices = 8
	slowdown = 0.2
	offline_slowdown = 4
	initial_modules = list(/obj/item/rig_module/mounted_relay, /obj/item/rig_module/teleporter_stabilizer, /obj/item/rig_module/simple_ai/advanced, /obj/item/rig_module/selfrepair, /obj/item/rig_module/cooling_unit, /obj/item/rig_module/device/science_tool, /obj/item/rig_module/device/analyzer, /obj/item/rig_module/device/anomaly_scanner)
