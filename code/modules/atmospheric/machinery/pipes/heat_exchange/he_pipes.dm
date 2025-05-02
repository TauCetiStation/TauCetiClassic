/obj/machinery/atmospherics/pipe/simple/heat_exchanging
	icon = 'icons/atmos/heat.dmi'
	icon_state = "intact"
	pipe_icon = "hepipe"
	color = "#404040"
	undertile = TRUE
	connect_types = CONNECT_TYPE_HE
	var/icon_temperature = T20C //stop small changes in temperature causing an icon refresh

	minimum_temperature_difference = 20
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT

	maximum_pressure = 360 * ONE_ATMOSPHERE
	fatigue_pressure = 300 * ONE_ATMOSPHERE
	alert_pressure = 360 * ONE_ATMOSPHERE

	can_buckle = 1
	buckle_lying = 1

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/atom_init()
	. = ..()
	color = "#404040" //we don't make use of the fancy overlay system for colours, use this to set the default.

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/atmos_init()
	normalize_dir()
	..()

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/can_be_node(obj/machinery/atmospherics/pipe/simple/heat_exchanging/target)
	if(istype(target, /obj/machinery/atmospherics/pipe/simple/heat_exchanging) && ..())
		return TRUE

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/process_atmos()
	last_power_draw = 0
	last_flow_rate = 0

	var/datum/gas_mixture/pipe_air = return_air()
	var/turf/local_turf = loc

	var/environment_temperature
	if(istype(loc, /turf/simulated) && !local_turf.blocks_air)
		var/datum/gas_mixture/environment = loc.return_air()
		environment_temperature = environment.temperature
	else
		environment_temperature = local_turf.temperature

	if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
		parent.temperature_interact(loc, volume, thermal_conductivity)

	if(buckled_mob)
		var/hc = pipe_air.heat_capacity()
		var/avg_temp = (pipe_air.temperature * hc + buckled_mob.bodytemperature * 3500) / (hc + 3500)
		pipe_air.temperature = avg_temp
		buckled_mob.bodytemperature = avg_temp

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/process()
	if(!parent)
		return //machines subsystem fires before atmos is initialized so this prevents race condition runtimes

	var/datum/gas_mixture/pipe_air = return_air()

	set_light(0, 0, null)

	//fancy radiation glowing
	if(pipe_air.temperature && (icon_temperature > 500 || pipe_air.temperature > 500)) //start glowing at 500K
		if(abs(pipe_air.temperature - icon_temperature) > 10)
			icon_temperature = pipe_air.temperature

			var/h_r = heat2color_r(icon_temperature)
			var/h_g = heat2color_g(icon_temperature)
			var/h_b = heat2color_b(icon_temperature)

			if(icon_temperature < 2000) //scale up overlay until 2000K
				var/scale = (icon_temperature - 500) / 1500
				h_r = 64 + (h_r - 64) * scale
				h_g = 64 + (h_g - 64) * scale
				h_b = 64 + (h_b - 64) * scale

			animate(src, color = rgb(h_r, h_g, h_b), time = 20, easing = SINE_EASING)

			set_light(1, clamp(pipe_air.temperature * 0.03, 0, 30), rgb(h_r, h_g, h_b))

	if(buckled_mob)
		var/heat_limit = 1000

		var/mob/living/carbon/human/H = buckled_mob
		if(istype(H) && H.species)
			heat_limit = H.species.heat_level_3

		if(pipe_air.temperature > heat_limit + 1)
			buckled_mob.apply_damage(4 * log(pipe_air.temperature - heat_limit), BURN, BP_CHEST, used_weapon = "Excessive Heat")
