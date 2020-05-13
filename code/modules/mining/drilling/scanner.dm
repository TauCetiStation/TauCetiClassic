/obj/item/weapon/mining_scanner
	name = "ore detector"
	desc = "A complex device used to locate ore deep underground."
	icon = 'icons/obj/device.dmi'
	icon_state = "forensic0-old" //GET A BETTER SPRITE.
	item_state = "electronic"
	var/range = 2
	var/speed = 50
	var/list/ore_list = list(
		"iron" = 0,
		"uranium" = 0,
		"gold" = 0,
		"silver" = 0,
		"diamond" = 0,
		"phoron" = 0,
		"osmium" = 0,
		"hydrogen" = 0,
		"silicates" = 0,
		"carbonaceous rock" = 0
		)

	origin_tech = "magnets=1;engineering=1"

/obj/item/weapon/mining_scanner/attack_self(mob/user)
	if(user.is_busy())
		return

	to_chat(user, "You begin sweeping \the [src] about, scanning for metal deposits.")

	if(!use_tool(src, user, speed, volume = 50))
		return

	find_ore(user)

	to_chat(user, "[bicon(src)] <span class='notice'>The scanner beeps and displays a readout.</span>")

	show_ore_count(user)

/obj/item/weapon/mining_scanner/proc/find_ore(mob/user)
	for(var/metal in ore_list)
		ore_list[metal] = 0

	for(var/turf/T in range(user, range))
		if(!T.has_resources)
			continue

		for(var/metal in T.resources)
			ore_list[metal] += T.resources[metal]

/obj/item/weapon/mining_scanner/proc/show_ore_count(mob/user)
	var/list/metals = list(
		"surface minerals" = 0,
		"precious metals" = 0,
		"nuclear fuel" = 0,
		"exotic matter" = 0
		)

	for(var/ore in ore_list)
		var/ore_type
		switch(ore)
			if("silicates" || "carbonaceous rock" || "iron") ore_type = "surface minerals"
			if("gold" || "silver" || "diamond")              ore_type = "precious metals"
			if("uranium")                                    ore_type = "nuclear fuel"
			if("phoron" || "osmium" || "hydrogen")           ore_type = "exotic matter"

		if(ore_type)
			metals[ore_type] += ore_list[ore]

	for(var/ore_type in metals)
		var/result = "no sign"
		switch(metals[ore_type])
			if(1 to 50) result = "trace amounts"
			if(51 to 150) result = "significant amounts"
			if(151 to INFINITY) result = "huge quantities"

		to_chat(user, "- [result] of [ore_type].")

/*
/	IMPROVED SACANER
*/
/obj/item/weapon/mining_scanner/improved
	name = "Improved ore detector"
	desc = "A complex device used to locate ore deep underground."

	range = 3
	speed = 30
	var/mode = 2
	var/list/modes = list("3x3" = 1, "5x5" = 2, "7x7" = 3)

/obj/item/weapon/mining_scanner/improved/verb/change_mode()
	set name = "Toggle Scaner Mode"
	set category = "Object"
	set src in usr

	if(!istype(usr, /mob/living))
		return
	if(usr.incapacitated())
		return

	if(get_dist(usr, src) > 1)
		to_chat(usr, "You have moved too far away.")
		return
	var/switchMode = input("Select a sensor mode:", "Scaner Sensor Mode", range) in modes
	range =  modes[switchMode]
	to_chat(usr, "You set [switchMode] range mode")

/obj/item/weapon/mining_scanner/improved/show_ore_count(mob/user)
	for(var/ore_type in ore_list)
		var/result = "no sign"
		switch(ore_list[ore_type])
			if(1 to 50) result = "trace amounts"
			if(51 to 150) result = "significant amounts"
			if(151 to INFINITY) result = "huge quantities"

		to_chat(user, "- [result] of [ore_type].")

/obj/item/weapon/mining_scanner/improved/adv
	name = "Advanced ore detector"
	desc = "A complex device used to locate ore deep underground."
	speed = 10
	modes = list("3x3" = 1, "5x5" = 2, "7x7" = 3, "9x9" = 4, "11x11" = 5)

/obj/item/weapon/mining_scanner/improved/adv/show_ore_count(mob/user)
	for(var/ore_type in ore_list)
		var/result = ore_list[ore_type]
		to_chat(user, "- [result] of [ore_type].")