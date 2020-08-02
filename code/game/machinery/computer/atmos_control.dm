/obj/item/weapon/circuitboard/atmoscontrol
	name = "Central Atmospherics Computer Circuitboard"
	build_path = /obj/machinery/computer/atmoscontrol

/obj/machinery/computer/atmoscontrol
	name = "Central Atmospherics Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer_generic"
	light_color = "#00b000"
	circuit = "/obj/item/weapon/circuitboard/atmoscontrol"
	req_access = list(access_ce)
	allowed_checks = ALLOWED_CHECK_NONE

	var/obj/machinery/alarm/current
	var/overridden = FALSE //not set yet, can't think of a good way to do it

/obj/machinery/computer/atmoscontrol/ui_interact(mob/user)
	if(allowed(user)) // this is very strange when you know, that this var will be set everytime someone opens with and without access and interfere with each other... but maybe i don't understand smth.
		overridden = TRUE
	else if(!emagged)
		overridden = FALSE

	var/dat = "<a href='?src=\ref[src]&reset=1'>Main Menu</a><hr>"

	if(current)
		dat += specific()
	else
		for(var/obj/machinery/alarm/alarm in alarm_list)
			if(alarm.hidden_from_console)
				continue
			dat += "<a href='?src=\ref[src]&alarm=\ref[alarm]'>"
			switch(max(alarm.danger_level, alarm.alarm_area.atmosalm))
				if (0)
					dat += "<font color=green>[alarm]</font>"
				if (1)
					dat += "<font color=blue>[alarm]</font>"
				if (2)
					dat += "<font color=red>[alarm]</font>"
			dat += "</a><br/>"
	user << browse(dat, "window=atmoscontrol")

/obj/machinery/computer/atmoscontrol/emag_act(mob/user)
	if(emagged)
		return FALSE
	user.visible_message("<span class='red'>\The [user] swipes \a suspicious card through \the [src], causing the screen to flash!</span>",
			             "<span class='red'>You swipe your card through \the [src], the screen flashing as you gain full control.</span>",
			             "You hear the swipe of a card through a reader, and an electronic warble.")

	emagged = TRUE
	overridden = TRUE
	return TRUE

/obj/machinery/alarm/proc/return_status()
	var/turf/location = get_turf(src)
	var/datum/gas_mixture/environment = location.return_air()
	var/total = environment.gas["oxygen"] + environment.gas["carbon_dioxide"] + environment.gas["phoron"] + environment.gas["nitrogen"]
	var/output = "<b>Air Status:</b><br>"

	if(total == 0)
		output += "<font color='red'><b>Warning: Cannot obtain air sample for analysis.</b></font>"
		return output

	output += {"
<style>
.dl0 { color: green; }
.dl1 { color: orange; }
.dl2 { color: red; font-weght: bold;}
</style>
"}

	var/partial_pressure = R_IDEAL_GAS_EQUATION * environment.temperature / environment.volume

	var/list/current_settings = TLV["pressure"]
	var/environment_pressure = environment.return_pressure()
	var/pressure_dangerlevel = get_danger_level(environment_pressure, current_settings)

	current_settings = TLV["oxygen"]
	var/oxygen_dangerlevel = get_danger_level(environment.gas["oxygen"] * partial_pressure, current_settings)
	var/oxygen_percent = environment.gas["oxygen"] ? round(environment.gas["oxygen"] / total * 100, 2) : 0

	current_settings = TLV["carbon dioxide"]
	var/co2_dangerlevel = get_danger_level(environment.gas["carbon_dioxide"] * partial_pressure, current_settings)
	var/co2_percent = environment.gas["carbon_dioxide"] ? round(environment.gas["carbon_dioxide"] / total * 100, 2) : 0

	current_settings = TLV["phoron"]
	var/phoron_dangerlevel = get_danger_level(environment.gas["phoron"] * partial_pressure, current_settings)
	var/phoron_percent = environment.gas["phoron"] ? round(environment.gas["phoron"] / total * 100, 2) : 0

	current_settings = TLV["other"]
	var/other_moles = 0
	for(var/g in trace_gas)
		other_moles += environment.gas[g] // this is only going to be used in a partial pressure calc, so we don't need to worry about group_multiplier here.
	var/other_dangerlevel = get_danger_level(other_moles * partial_pressure, current_settings)

	current_settings = TLV["temperature"]
	var/temperature_dangerlevel = get_danger_level(environment.temperature, current_settings)

	output += {"
Pressure: <span class='dl[pressure_dangerlevel]'>[environment_pressure]</span>kPa<br>
Oxygen: <span class='dl[oxygen_dangerlevel]'>[oxygen_percent]</span>%<br>
Carbon dioxide: <span class='dl[co2_dangerlevel]'>[co2_percent]</span>%<br>
Toxins: <span class='dl[phoron_dangerlevel]'>[phoron_percent]</span>%<br>
"}

	if (other_dangerlevel == 2)
		output += "Notice: <span class='dl2'>High Concentration of Unknown Particles Detected</span><br>"
	else if (other_dangerlevel == 1)
		output += "Notice: <span class='dl1'>Low Concentration of Unknown Particles Detected</span><br>"

	output += "Temperature: <span class='dl[temperature_dangerlevel]'>[environment.temperature]</span>K ([round(environment.temperature - T0C, 0.1)]C)<br>"

	//'Local Status' should report the LOCAL status, damnit.
	output += "Local Status: "
	switch(max(pressure_dangerlevel, oxygen_dangerlevel, co2_dangerlevel, phoron_dangerlevel, other_dangerlevel, temperature_dangerlevel))
		if(2)
			output += "<span class='dl2'>DANGER: Internals Required</span><br>"
		if(1)
			output += "<span class='dl1'>Caution</span><br>"
		if(0)
			output += "<span class='dl0'>Optimal</span><br>"

	output += "Area Status: "
	if(alarm_area.atmosalm)
		output += "<span class='dl1'>Atmos alert in area</span>"
	else if (alarm_area.fire)
		output += "<span class='dl1'>Fire alarm in area</span>"
	else
		output += "No alerts"

	return output

/obj/machinery/computer/atmoscontrol/proc/specific()
	if(!current)
		return ""
	var/dat = "<h3>[current.name]</h3><hr>"
	dat += current.return_status()
	if(current.remote_control || overridden)
		dat += "<hr>[return_controls()]"
	return dat

//a bunch of this is copied from atmos alarms
/obj/machinery/computer/atmoscontrol/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["reset"])
		current = null
	if(href_list["alarm"])
		current = locate(href_list["alarm"])
		if(href_list["command"])
			var/device_id = href_list["id_tag"]
			switch(href_list["command"])
				if(
					"power",
					"adjust_external_pressure",
					"checks",
					"co2_scrub",
					"tox_scrub",
					"n2o_scrub",
					"panic_siphon",
					"scrubbing"
				)
					current.send_signal(device_id, list (href_list["command"] = text2num(href_list["val"])))
					updateUsrDialog()
				//if("adjust_threshold") //was a good idea but required very wide window
				if("set_threshold")
					var/env = href_list["env"]
					var/threshold = text2num(href_list["var"])
					var/list/selected = current.TLV[env]
					var/list/thresholds = list("lower bound", "low warning", "high warning", "upper bound")
					var/newval = input("Enter [thresholds[threshold]] for [env]", "Alarm triggers", selected[threshold]) as num|null

					if (isnull(newval) || ..() || (current.locked && issilicon(usr)))
						return FALSE

					if (newval < 0)
						selected[threshold] = -1.0
					else if (env=="temperature" && newval > 5000)
						selected[threshold] = 5000
					else if (env=="pressure" && newval>50*ONE_ATMOSPHERE)
						selected[threshold] = 50*ONE_ATMOSPHERE
					else if (env!="temperature" && env != "pressure" && newval > 200)
						selected[threshold] = 200
					else
						newval = round(newval, 0.01)
						selected[threshold] = newval

					if(threshold == 1)
						if(selected[1] > selected[2])
							selected[2] = selected[1]
						if(selected[1] > selected[3])
							selected[3] = selected[1]
						if(selected[1] > selected[4])
							selected[4] = selected[1]

					if(threshold == 2)
						if(selected[1] > selected[2])
							selected[1] = selected[2]
						if(selected[2] > selected[3])
							selected[3] = selected[2]
						if(selected[2] > selected[4])
							selected[4] = selected[2]

					if(threshold == 3)
						if(selected[1] > selected[3])
							selected[1] = selected[3]
						if(selected[2] > selected[3])
							selected[2] = selected[3]
						if(selected[3] > selected[4])
							selected[4] = selected[3]

					if(threshold == 4)
						if(selected[1] > selected[4])
							selected[1] = selected[4]
						if(selected[2] > selected[4])
							selected[2] = selected[4]
						if(selected[3] > selected[4])
							selected[3] = selected[4]

					//Sets the temperature the built-in heater/cooler tries to maintain.
					if(env == "temperature")
						if(current.target_temperature < selected[2])
							current.target_temperature = selected[2]
						if(current.target_temperature > selected[3])
							current.target_temperature = selected[3]

					updateUsrDialog()
			return

		if(href_list["screen"])
			current.screen = text2num(href_list["screen"])
			updateUsrDialog()
			return

		//commenting this out because it causes compile errors
		//I tried fixing it but wasn't sucessful.
		//if(href_list["atmos_unlock"])
		//	switch(href_list["atmos_unlock"])
		//		if("0")
		//			current.alarm_area.air_doors_close()
		//		if("1")
		//			current.alarm_area.air_doors_open()

		if(href_list["atmos_alarm"])
			if (current.alarm_area.atmosalert(2))
				current.apply_danger_level(2)

			updateUsrDialog()
			current.update_icon()
			return

		if(href_list["atmos_reset"])
			if (current.alarm_area.atmosalert(0))
				current.apply_danger_level(0)

			updateUsrDialog()
			current.update_icon()
			return

		if(href_list["mode"])
			current.mode = text2num(href_list["mode"])
			current.apply_mode()
			updateUsrDialog()
			return

	updateUsrDialog()

//copypasta from alarm code, changed to work with this without derping hard
//---START COPYPASTA----

/obj/machinery/computer/atmoscontrol/proc/return_controls()
	var/output = ""//"<B>[alarm_zone] Air [name]</B><HR>"

	switch(current.screen)
		if (AALARM_SCREEN_MAIN)
			if(current.alarm_area.atmosalm)
				output += {"<a href='?src=\ref[src];alarm=\ref[current];atmos_reset=1'>Reset - Atmospheric Alarm</a><hr>"}
			else
				output += {"<a href='?src=\ref[src];alarm=\ref[current];atmos_alarm=1'>Activate - Atmospheric Alarm</a><hr>"}

			output += {"
<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_SCRUB]'>Scrubbers Control</a><br>
<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_VENT]'>Vents Control</a><br>
<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_MODE]'>Set environmental mode</a><br>
<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_SENSORS]'>Sensor Control</a><br>
<HR>
"}
			if (current.mode == AALARM_MODE_PANIC)
				output += "<font color='red'><B>PANIC SYPHON ACTIVE</B></font><br><A href='?src=\ref[src];alarm=\ref[current];mode=[AALARM_MODE_SCRUBBING]'>turn syphoning off</A>"
			else
				output += "<A href='?src=\ref[src];alarm=\ref[current];mode=[AALARM_MODE_PANIC]'><font color='red'><B>ACTIVATE PANIC SYPHON IN AREA</B></font></A>"

			output += "<br><br>Atmospheric Lockdown: <a href='?src=\ref[src];alarm=\ref[current];atmos_unlock=[current.alarm_area.air_doors_activated]'>[current.alarm_area.air_doors_activated ? "<b>ENABLED</b>" : "Disabled"]</a>"
		if (AALARM_SCREEN_VENT)
			var/sensor_data = ""
			if(current.alarm_area.air_vent_names.len)
				for(var/id_tag in current.alarm_area.air_vent_names)
					var/long_name = current.alarm_area.air_vent_names[id_tag]
					var/list/data = current.alarm_area.air_vent_info[id_tag]
					var/state = ""
					if(!data)
						state = "<font color='red'> can not be found!</font>"
						data = list("external" = 0) //for "0" instead of empty string
					else if (data["timestamp"] + AALARM_REPORT_TIMEOUT < world.time)
						state = "<font color='red'> not responding!</font>"
					sensor_data += {"
<B>[long_name]</B>[state]<BR>
<B>Operating:</B>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=power;val=[!data["power"]]'>[data["power"]?"on":"off"]</A>
<BR>
<B>Pressure checks:</B>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=checks;val=[data["checks"]^1]' [(data["checks"]&1)?"style='font-weight:bold;'":""]>external</A>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=checks;val=[data["checks"]^2]' [(data["checks"]&2)?"style='font-weight:bold;'":""]>internal</A>
<BR>
<B>External pressure bound:</B>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=adjust_external_pressure;val=-1000'>-</A>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=adjust_external_pressure;val=-100'>-</A>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=adjust_external_pressure;val=-10'>-</A>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=adjust_external_pressure;val=-1'>-</A>
[data["external"]]
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=adjust_external_pressure;val=+1'>+</A>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=adjust_external_pressure;val=+10'>+</A>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=adjust_external_pressure;val=+100'>+</A>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=adjust_external_pressure;val=+1000'>+</A>
<BR>
"}
					if (data["direction"] == "siphon")
						sensor_data += {"
<B>Direction:</B>
siphoning
<BR>
"}
					sensor_data += {"<HR>"}
			else
				sensor_data = "No vents connected.<BR>"
			output = {"<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br>[sensor_data]"}
		if (AALARM_SCREEN_SCRUB)
			var/sensor_data = ""
			if(current.alarm_area.air_scrub_names.len)
				for(var/id_tag in current.alarm_area.air_scrub_names)
					var/long_name = current.alarm_area.air_scrub_names[id_tag]
					var/list/data = current.alarm_area.air_scrub_info[id_tag]
					var/state = ""
					if(!data)
						state = "<font color='red'> can not be found!</font>"
						data = list("external" = 0) //for "0" instead of empty string
					else if (data["timestamp"]+AALARM_REPORT_TIMEOUT < world.time)
						state = "<font color='red'> not responding!</font>"

					sensor_data += {"
<B>[long_name]</B>[state]<BR>
<B>Operating:</B>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=power;val=[!data["power"]]'>[data["power"]?"on":"off"]</A><BR>
<B>Type:</B>
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=scrubbing;val=[!data["scrubbing"]]'>[data["scrubbing"]?"scrubbing":"syphoning"]</A><BR>
"}

					if(data["scrubbing"])
						sensor_data += {"
<B>Filtering:</B>
Carbon Dioxide
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=co2_scrub;val=[!data["filter_co2"]]'>[data["filter_co2"]?"on":"off"]</A>;
Toxins
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=tox_scrub;val=[!data["filter_phoron"]]'>[data["filter_phoron"]?"on":"off"]</A>;
Nitrous Oxide
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=n2o_scrub;val=[!data["filter_n2o"]]'>[data["filter_n2o"]?"on":"off"]</A>
<BR>
"}
					sensor_data += {"
<B>Panic syphon:</B> [data["panic"]?"<font color='red'><B>PANIC SYPHON ACTIVATED</B></font>":""]
<A href='?src=\ref[src];alarm=\ref[current];id_tag=[id_tag];command=panic_siphon;val=[!data["panic"]]'><font color='[(data["panic"]?"blue'>Dea":"red'>A")]ctivate</font></A><BR>
<HR>
"}
			else
				sensor_data = "No scrubbers connected.<BR>"
			output = {"<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br>[sensor_data]"}

		if (AALARM_SCREEN_MODE)
			output += {"
<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br>
<b>Air machinery mode for the area:</b><ul>"}
			var/list/modes = list(AALARM_MODE_SCRUBBING   = "Filtering - Scrubs out contaminants",\
					AALARM_MODE_REPLACEMENT = "<font color='blue'>Replace Air - Siphons out air while replacing</font>",\
					AALARM_MODE_PANIC       = "<font color='red'>Panic - Siphons air out of the room</font>",\
					AALARM_MODE_CYCLE       = "<font color='red'>Cycle - Siphons air before replacing</font>",\
					AALARM_MODE_FILL        = "<font color='green'>Fill - Shuts off scrubbers and opens vents</font>",\
					AALARM_MODE_OFF         = "<font color='blue'>Off - Shuts off vents and scrubbers</font>",)
			for(var/m in 1 to modes.len)
				if (current.mode==m)
					output += {"<li><A href='?src=\ref[src];alarm=\ref[current];mode=[m]'><b>[modes[m]]</b></A> (selected)</li>"}
				else
					output += {"<li><A href='?src=\ref[src];alarm=\ref[current];mode=[m]'>[modes[m]]</A></li>"}
			output += "</ul>"

		if (AALARM_SCREEN_SENSORS)
			output += {"
<a href='?src=\ref[src];alarm=\ref[current];screen=[AALARM_SCREEN_MAIN]'>Main menu</a><br>
<b>Alarm thresholds:</b><br>
Partial pressure for gases
<style>/* some CSS woodoo here. Does not work perfect in ie6 but who cares? */
table td { border-left: 1px solid black; border-top: 1px solid black;}
table tr:first-child th { border-left: 1px solid black;}
table th:first-child { border-top: 1px solid black; font-weight: normal;}
table tr:first-child th:first-child { border: none;}
.dl0 { color: green; }
.dl1 { color: orange; }
.dl2 { color: red; font-weght: bold;}
</style>
<table cellspacing=0>
<TR><th></th><th class=dl2>min2</th><th class=dl1>min1</th><th class=dl1>max1</th><th class=dl2>max2</th></TR>
"}
			var/list/gases = list(
				"oxygen"         = "O<sub>2</sub>",
				"carbon dioxide" = "CO<sub>2</sub>",
				"phoron"         = "Toxin",
				"other"          = "Other",
			)
			var/list/tlv
			for (var/g in gases)
				output += "<TR><th>[gases[g]]</th>"
				tlv = current.TLV[g]
				for(var/i in 1 to 4)
					output += "<td><A href='?src=\ref[src];alarm=\ref[current];command=set_threshold;env=[g];var=[i]'>[tlv[i] >= 0?tlv[i]:"OFF"]</A></td>"
				output += "</TR>"

			tlv = current.TLV["pressure"]
			output += "<TR><th>Pressure</th>"
			for(var/i in 1 to 4)
				output += "<td><A href='?src=\ref[src];alarm=\ref[current];command=set_threshold;env=pressure;var=[i]'>[tlv[i]>= 0?tlv[i]:"OFF"]</A></td>"
			output += "</TR>"

			tlv = current.TLV["temperature"]
			output += "<TR><th>Temperature</th>"
			for(var/i in 1 to 4)
				output += "<td><A href='?src=\ref[src];alarm=\ref[current];command=set_threshold;env=temperature;var=[i]'>[tlv[i]>= 0?tlv[i]:"OFF"]</A></td>"
			output += "</TR>"
			output += "</table>"

	return output
//---END COPYPASTA----
