var/datum/subsystem/nightshift/SSnightshift

/datum/subsystem/nightshift
	name = "Night shift"
	init_order = SS_INIT_NIGHTSHIFT
	wait = SS_WAIT_NIGHTSHIFT
	priority = SS_PRIORITY_NIGHTSHIFT
	flags = SS_NO_FIRE // change to SS_NO_TICK_CHECK for dynamic ligthing changes

	var/nightshift_active = FALSE
	var/nightshift_start_time = 23
	var/nightshift_end_time = 8
	var/high_security_mode = FALSE


/datum/subsystem/nightshift/New()
	NEW_SS_GLOBAL(SSnightshift)

/datum/subsystem/nightshift/Initialize(timeofday)
	if(config.nightshift)
		check_nightshift()
	..()

/datum/subsystem/nightshift/fire(resumed = FALSE)
	if(config.nightshift)
		check_nightshift()

/datum/subsystem/nightshift/proc/check_nightshift()
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

/datum/subsystem/nightshift/proc/update_nightshift(active)
	nightshift_active = active
	for(var/obj/machinery/power/apc/APC in apc_list)
		if (is_station_level(APC.z) || is_mining_level(APC.z))
			var/preset = "soft"
			if(is_type_in_list(get_area(APC), hard_lighting_arealist))
				preset = "hard"

			APC.set_nightshift(active, preset)
			CHECK_TICK

var/list/lighting_presets = list(
	"soft" = list("color" = "#ffe4c9", "power" = 0.8, "range" = 8),
	"hard" = list("color" = "#e8e9ff", "power" = 0.8, "range" = 8),
	"3000K" = list("color" = "#ffb46b", "power" = 0.8, "range" = 8),
	"4000K" = list("color" = "#ffd1a3", "power" = 0.8, "range" = 8),
	"5000K" = list("color" = "#ffe4ce", "power" = 0.8, "range" = 8),
	"6000K" = list("color" = "#fff3ef", "power" = 0.8, "range" = 8),
)

var/hard_lighting_arealist = list(
	/area/station/medical/reception,
	/area/station/medical/morgue,
	/area/station/medical/hallway,
	/area/station/medical/genetics_cloning,
	/area/station/medical/cmo,
	/area/station/medical/psych,
	/area/station/medical/patients_rooms,
	/area/station/medical/patient_a,
	/area/station/medical/patient_b,
	/area/station/medical/medbreak,
	/area/station/medical/surgeryobs,
	/area/station/medical/surgery,
	/area/station/medical/surgery2,
	/area/station/medical/storage,
	/area/station/medical/chemistry,
	/area/station/medical/sleeper,
	/area/station/medical/virology,
	/area/station/rnd/lab,
	/area/station/rnd/hor,
	/area/station/rnd/hallway,
	/area/station/rnd/xenobiology,
	/area/station/rnd/storage,
	/area/station/rnd/test_area,
	/area/station/rnd/mixing,
	/area/station/rnd/misc_lab,
	/area/station/rnd/telesci,
	/area/station/rnd/scibreak,
	/area/station/rnd/server,
	/area/station/rnd/chargebay,
	/area/station/rnd/robotics,
	/area/station/rnd/brainstorm_center,
	/area/asteroid/research_outpost/hallway,
	/area/asteroid/research_outpost/gearstore,
	/area/asteroid/research_outpost/maint,
	/area/asteroid/research_outpost/iso1,
	/area/asteroid/research_outpost/iso2,
	/area/asteroid/research_outpost/harvesting,
	/area/asteroid/research_outpost/outpost_misc_lab,
	/area/asteroid/research_outpost/anomaly,
	/area/asteroid/research_outpost/med,
	/area/asteroid/research_outpost/entry,
	/area/asteroid/research_outpost/longtermstorage,
	/area/asteroid/research_outpost/tempstorage,
	/area/asteroid/research_outpost/maintstore2,
	/area/station/medical/genetics,
	)