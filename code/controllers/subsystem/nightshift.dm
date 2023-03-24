SUBSYSTEM_DEF(nightshift)
	name = "Night shift"
	init_order = SS_INIT_NIGHTSHIFT
	wait = SS_WAIT_NIGHTSHIFT
	priority = SS_PRIORITY_NIGHTSHIFT
	flags = SS_NO_FIRE

	var/nightshift_active = FALSE
	var/nightshift_start_time = 23
	var/nightshift_end_time = 8
	var/high_security_mode = FALSE

	var/forced_admin_mode = FALSE

/datum/controller/subsystem/nightshift/Initialize(timeofday)
	if(config.nightshift)
		check_nightshift()
	..()

/datum/controller/subsystem/nightshift/fire(resumed = FALSE)
	if(config.nightshift)
		check_nightshift()

/datum/controller/subsystem/nightshift/proc/check_nightshift()
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
		update_nightshift(night_time)

/datum/controller/subsystem/nightshift/proc/update_nightshift(active, admin_preset)
	nightshift_active = active
	for(var/obj/machinery/power/apc/APC in apc_list)
		if (is_station_level(APC.z) || is_mining_level(APC.z))
			var/preset = "soft"
			if(admin_preset)
				preset = admin_preset
				forced_admin_mode = TRUE
			else
				forced_admin_mode = FALSE

			if(is_type_in_typecache(get_area(APC), hard_lighting_arealist))
				preset = "hard"

			APC.set_nightshift(active, preset)
			CHECK_TICK

var/global/list/lighting_presets = list(
	"soft" = list("color" = "#ffe4c9", "power" = 0.8, "range" = 8),
	"hard" = list("color" = "#e8e9ff", "power" = 0.8, "range" = 8),
	"3000K" = list("color" = "#ffb46b", "power" = 0.8, "range" = 8),
	"4000K" = list("color" = "#ffd1a3", "power" = 0.8, "range" = 8),
	"5000K" = list("color" = "#ffe4ce", "power" = 0.8, "range" = 8),
	"6000K" = list("color" = "#fff3ef", "power" = 0.8, "range" = 8),
)

var/global/list/lighting_presets_admin = list(
	"Shadows Soft" = list("color" = "#ffe4c9", "power" = 0.5, "range" = 5),
	"Shadows Hard" = list("color" = "#e8e9ff", "power" = 0.5, "range" = 5),
	"Horror" = list("color" = "#e8e9ff", "power" = 0.5, "range" = 4),
	"Code Red" = list("color" = "#690101", "power" = 0.8, "range" = 8),
	"Blue Night" = list("color" = "#22566a", "power" = 0.8, "range" = 8),
	"Soft Blue" = list("color" = "#009eda", "power" = 0.8, "range" = 8),
	"Neon" = list("color" = "#b77ad0", "power" = 0.8, "range" = 6),
	"Neon Dark" = list("color" = "#a339ce", "power" = 0.8, "range" = 6),
)

var/global/hard_lighting_arealist = typecacheof(typesof(/area/station/medical) + typesof(/area/station/rnd) + typesof(/area/asteroid/research_outpost))


/client/proc/add_nightshift_preset()
	set category = "Debug"
	set name = "Add Nightshift Preset"

	if(!check_rights(R_VAREDIT)) // todo: debug, maybe, we can't trust admin sanity
		return

	var/color = input("Select hex color for ligthing", "New Night Shift Preset") as null|color

	if(!color)
		return

	var/power = clamp(input("Select power for ligthing, in range 0.1-5", "New Night Shift Preset", 0.8) as null|num, 0, 5)

	if(!power)
		return

	var/range = clamp(round(input("Select range for ligthing, in range 1-12", "New Night Shift Preset", 8) as null|num), 1, 12) // note: 1 will be adjusted to MINIMUM_USEFUL_LIGHT_RANGE (1.4 currently)

	if(!range)
		return

	var/preset_name = "[color]_[power]_[range]"

	lighting_presets_admin[preset_name] = list("color" = color, "power" = power, "range" = range)

	if(tgui_alert(usr, "Set new preset for station?", "Confirm", list("Yes","No")) == "Yes")
		SSnightshift.update_nightshift(TRUE, preset_name)
		message_admins("[key_name_admin(usr)] switched night shift mode to new preset '[preset_name]'.")
		log_admin("[key_name(usr)] switched night shift mode to new preset '[preset_name]'.")
		return
