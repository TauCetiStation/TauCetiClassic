/var/security_level = 0


/proc/set_security_level(level)
	switch(level)
		if("green")
			level = SEC_LEVEL_GREEN
		if("blue")
			level = SEC_LEVEL_BLUE
		if("red")
			level = SEC_LEVEL_RED
		if("delta")
			level = SEC_LEVEL_DELTA

	//Will not be announced if you try to set to the same level as it already is
	if(level >= SEC_LEVEL_GREEN && level <= SEC_LEVEL_DELTA && level != security_level)
		switch(level)
			if(SEC_LEVEL_GREEN)
				security_level = SEC_LEVEL_GREEN
				station_announce(config.alert_desc_green, subtitle = "Attention! Security level lowered to green", sound = "downtogreen")

				for(var/obj/machinery/firealarm/FA in firealarm_list)
					if(FA.z == ZLEVEL_STATION || FA.z == ZLEVEL_ASTEROID)
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_green")
			if(SEC_LEVEL_BLUE)
				if(security_level < SEC_LEVEL_BLUE)
					station_announce(config.alert_desc_blue_upto, subtitle = "Attention! Security level elevated to blue", sound = "blue")
				else
					station_announce(config.alert_desc_blue_downto, subtitle = "Attention! Security level lowered to blue", sound = "downtoblue")
				security_level = SEC_LEVEL_BLUE
				for(var/obj/machinery/firealarm/FA in firealarm_list)
					if(FA.z == ZLEVEL_STATION || FA.z == ZLEVEL_ASTEROID)
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_blue")
			if(SEC_LEVEL_RED)
				if(security_level < SEC_LEVEL_RED)
					station_announce(config.alert_desc_red_upto, subtitle = "Attention! Code red!", sound = "red")
				else
					station_announce(config.alert_desc_red_downto, "Attention! Code red!", sound = "downtored")
				security_level = SEC_LEVEL_RED

				var/obj/machinery/computer/communications/CC = locate() in communications_list
				if(CC)
					CC.post_status("alert", "redalert")

				for(var/obj/machinery/firealarm/FA in firealarm_list)
					if(FA.z == ZLEVEL_STATION || FA.z == ZLEVEL_ASTEROID)
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_red")

			if(SEC_LEVEL_DELTA)
				security_level = SEC_LEVEL_DELTA
				station_announce(config.alert_desc_delta, subtitle = "Attention! Delta security level reached!", sound = "delta")
				for(var/obj/machinery/firealarm/FA in firealarm_list)
					if(FA.z == ZLEVEL_STATION || FA.z == ZLEVEL_ASTEROID)
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_delta")
	else
		return

/proc/get_security_level()
	switch(security_level)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/num2seclevel(num)
	switch(num)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/seclevel2num(seclevel)
	switch( lowertext(seclevel) )
		if("green")
			return SEC_LEVEL_GREEN
		if("blue")
			return SEC_LEVEL_BLUE
		if("red")
			return SEC_LEVEL_RED
		if("delta")
			return SEC_LEVEL_DELTA
