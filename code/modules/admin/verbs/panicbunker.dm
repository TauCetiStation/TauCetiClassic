/client/proc/regisration_panic_bunker()
	set category = "Server"
	set name = "Toggle Registration Panic Bunker"

	if (config.registration_panic_bunker_age)
		config.registration_panic_bunker_age = null
		fdel("data/regisration_panic_bunker.sav")
		log_admin("[key_name(src)] disable regisration panic bunker")
		message_admins("[key_name_admin(src)] disable regisration panic bunker")
		return
	
	var/year = sanitize_integer(input("Registration year", "Year (min: 2000, max: [game_year])", game_year) as num, 2000, game_year, game_year)
	var/month = sanitize_integer(input("Registration month", "Month (min: 1, max: 12)", 1) as num, 1, 12, 1)
	var/day = sanitize_integer(input("Registration day", "Day (min: 1, max: 31)", 1) as num, 1, 31, 1)
	var/active_hours = sanitize_integer(input("Hours from current moment to keep panic bunker active (-1 to enable for current round only)", "Active hours (min: -1 or 1, max: 24)", -1) as num, -1, 24, -1)

	var/panic_age = "[year]-[month]-[day]"

	config.registration_panic_bunker_age = panic_age

	if (active_hours != -1)
		var/savefile/S = new /savefile("data/regisration_panic_bunker.sav")
		S["enabled_by"] = ckey
		S["active_until"] = world.realtime + active_hours * 36000
		S["panic_age"] = panic_age

	var/msg = "enables registration panic bunker for [active_hours != -1 ? "[active_hours] hours" : "current round"] with value: [panic_age]"
	log_admin("[key_name(src)] [msg]")
	message_admins("[key_name_admin(src)] [msg]")
