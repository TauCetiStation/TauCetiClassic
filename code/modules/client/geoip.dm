var/global/geoip_query_counter = 0
var/global/geoip_next_counter_reset = 0
var/global/list/geoip_ckey_updated = list()

/datum/geoip_data
	var/holder = null
	var/status = null
	var/city = null
	var/country = null
	var/countryCode = null
	var/isp = null
	var/proxy = null
	var/ip = null
	var/region = null
	var/regionName = null
	var/timezone = null

/datum/geoip_data/New(client/C, addr)
	set background = BACKGROUND_ENABLED

	if(!C || !addr)
		return

	if(!try_update_geoip(C, addr))
		return

	if(ticker.current_state > GAME_STATE_STARTUP && status == "updated" && !(C.ckey in geoip_ckey_updated))
		geoip_ckey_updated |= C.ckey
		message_admins("[holder] connected from ([country], [regionName], [city]) using ISP: ([isp]) with IP: ([ip]) Proxy: ([proxy])")

/datum/geoip_data/proc/try_update_geoip(client/C, addr)
	if(!C || !addr)
		return

	if(C.holder && (C.holder.rights & R_ADMIN))
		status = "admin"
		return 0//Lets save calls.

	if(status != "updated")
		holder = C.ckey

		var/msg = geoip_check(addr)
		if(msg == "limit reached" || msg == "export fail")
			status = msg
			return 0

		for(var/data in msg)
			switch(data)
				if("city")
					city = msg[data]
				if("country")
					country = msg[data]
				if("countryCode")
					countryCode = msg[data]
				if("isp")
					isp = msg[data]
				if("proxy")
					proxy = msg[data] ? "true" : "false"
				if("query")
					ip = msg[data]
				if("region")
					region = msg[data]
				if("regionName")
					regionName = msg[data]
				if("timezone")
					timezone = msg[data]
		status = "updated"
	return 1

/proc/geoip_check(var/addr)
	if(world.time > geoip_next_counter_reset)
		geoip_next_counter_reset = world.time + 900
		geoip_query_counter = 0

	geoip_query_counter++
	if(geoip_query_counter > 130)
		return "limit reached"

	var/list/vl = world.Export("http://ip-api.com/json/[addr]?fields=156447")
	if (!("CONTENT" in vl) || vl["STATUS"] != "200 OK")
		return "export fail"

	var/msg = file2text(vl["CONTENT"])
	return json2list(msg)
