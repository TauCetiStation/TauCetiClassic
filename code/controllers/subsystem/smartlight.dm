SUBSYSTEM_DEF(smartlight)
	name = "Smart light"
	init_order = SS_INIT_SMARTLIGHT
	wait = SS_WAIT_SMARTLIGHT
	priority = SS_PRIORITY_SMARTLIGHT
	flags = SS_NO_FIRE

	var/datum/smartlight_preset/smartlight_preset

	var/nightshift_active = FALSE
	var/nightshift_start_time = 23
	var/nightshift_end_time = 8
	var/high_security_mode = FALSE

	var/forced_admin_mode = FALSE

/datum/controller/subsystem/smartlight/Initialize(timeofday)
	if(SSmapping.config.smartlight_preset)
		var/type = smartlight_presets[SSmapping.config.smartlight_preset]
		if(type)
			smartlight_preset = new type

	if(!smartlight_preset)
		var/error = "Can't load smartlight preset from map config!"
		if(SSmapping.config.smartlight_preset)
			error += " Wrong preset name: [SSmapping.config.smartlight_preset]"
		stack_trace(error)
		smartlight_preset = new /datum/smartlight_preset/default

	if(config.nightshift)
		check_nightshift()
	..()

/datum/controller/subsystem/smartlight/fire(resumed = FALSE)
	if(config.nightshift)
		check_nightshift()

/datum/controller/subsystem/smartlight/proc/check_nightshift()
	if(forced_admin_mode)
		return

	var/emergency = security_level >= SEC_LEVEL_RED
	var/current_hour = text2num(time2text(world.realtime, "hh"))
	var/current_minute = text2num(time2text(world.realtime, "mm"))

	var/time = current_hour + current_minute / 60 // So 8:30 will become somthing like 8.5
	var/night_time = (time < nightshift_end_time) || (time > nightshift_start_time)
	if(high_security_mode != emergency)
		high_security_mode = emergency
	if(emergency)
		night_time = FALSE
	if(nightshift_active != night_time)
		toggle_nightshift(night_time)

/datum/controller/subsystem/smartlight/proc/toggle_nightshift(active)
	nightshift_active = active
	for(var/obj/machinery/power/apc/APC in apc_list)
		if (is_station_level(APC.z) || is_mining_level(APC.z)) // todo: change for z-level trait STATION_SMART_LIGHT
			APC.toggle_nightshift(nightshift_active)
			CHECK_TICK

/datum/controller/subsystem/smartlight/proc/update_mode(datum/light_mode/new_mode, forced = FALSE)
	for(var/obj/machinery/power/apc/APC in apc_list)
		if (is_station_level(APC.z) || is_mining_level(APC.z))
			APC.set_light_mode(new_mode, forced)
			CHECK_TICK

/datum/controller/subsystem/smartlight/proc/reset_smartlight()
	for(var/obj/machinery/power/apc/APC in apc_list)
		if (is_station_level(APC.z) || is_mining_level(APC.z))
			APC.reset_smartlight()
			CHECK_TICK

/datum/controller/subsystem/smartlight/proc/sync_apc()
	for(var/obj/machinery/power/apc/APC in apc_list)
		if (is_station_level(APC.z) || is_mining_level(APC.z))
			APC.sync_smartlight()
			CHECK_TICK

/client/proc/add_smartlight_preset()
	set category = "Debug"
	set name = "Smartlight: Add Preset"

	if(!check_rights(R_VAREDIT)) // todo: debug, maybe, we can't trust admins sanity
		return

	var/color = input("Select hex color for ligthing", "New Night Shift Preset") as null|color

	if(!color) // doulbe input because https://www.byond.com/forum/post/2650322 and I NEED THIS HEX INPUT
		color = input("Select hex color for ligthing", "New Night Shift Preset") as null|text

	if(!color)
		return

	var/power = clamp(input("Select power for ligthing, in range 0.1-5", "New Night Shift Preset", 0.8) as null|num, 0, 5)

	if(!power)
		return

	var/range = clamp(round(input("Select range for ligthing, in range 1-12", "New Night Shift Preset", 8) as null|num), 1, 12) // note: 1 will be adjusted to MINIMUM_USEFUL_LIGHT_RANGE (1.4 currently)

	if(!range)
		return

	var/preset_name = "[color]_[power]_[range]"

	var/datum/light_mode/LM = new
	LM.name = preset_name
	LM.color = color
	LM.power = power
	LM.range = range

	light_modes_by_name[preset_name] = LM

	if(tgui_alert(usr, "Set new preset for station?", "Confirm", list("Yes","No")) == "Yes")
		SSsmartlight.can_fire = FALSE
		SSsmartlight.update_mode(LM, TRUE)
		message_admins("[key_name_admin(usr)] switched smartlight mode to new preset '[preset_name]'.")
		log_admin("[key_name(usr)] switched smartlight mode to new preset '[preset_name]'.")
		return

/client/proc/set_area_smartlight()
	set category = "Debug"
	set name = "Smartlight: Set Area"

	if(!check_rights(R_VAREDIT)) // todo: debug, maybe, we can't trust admins sanity
		return

	var/area/A = get_area(usr)
	var/obj/machinery/power/apc/APC = A.get_apc()
	if(!APC)
		to_chat(usr, "Can't find area APC.")
		return

	var/mode = input("Select new lighting mode for area.", "Force Mode") as null|anything in light_modes_by_name
	if(!mode)
		return

	APC.set_light_mode(light_modes_by_name[mode])
