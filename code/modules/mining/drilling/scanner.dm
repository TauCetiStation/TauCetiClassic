/obj/item/weapon/mining_scanner
	name = "ore detector"
	desc = "A complex device used to locate ore deep underground."
	icon = 'icons/obj/device.dmi'
	icon_state = "forensic0-old" //GET A BETTER SPRITE.
	item_state = "electronic"
	var/range = 2
	var/speed = 50

	//matter = list("metal" = 3000)

	origin_tech = "magnets=1;engineering=1"

/obj/item/weapon/mining_scanner/attack_self(mob/user)

	to_chat(user, "You begin sweeping \the [src] about, scanning for metal deposits.")

	if(!do_after(user,speed,target = user)) return

	if(!user || !src) return

	var/list/metals = list(
		"surface minerals" = 0,
		"precious metals" = 0,
		"nuclear fuel" = 0,
		"exotic matter" = 0
		)

	for(var/turf/T in oview(range,get_turf(user)))

		if(!T.has_resources)
			continue

		for(var/metal in T.resources)

			var/ore_type

			switch(metal)
				if("silicates" || "carbonaceous rock" || "iron") ore_type = "surface minerals"
				if("gold" || "silver" || "diamond")              ore_type = "precious metals"
				if("uranium")                                    ore_type = "nuclear fuel"
				if("phoron" || "osmium" || "hydrogen")           ore_type = "exotic matter"

			if(ore_type) metals[ore_type] += T.resources[metal]

	to_chat(user, "[bicon(src)] \blue The scanner beeps and displays a readout.")

	for(var/ore_type in metals)

		var/result = "no sign"

		switch(metals[ore_type])
			if(1 to 50) result = "trace amounts"
			if(51 to 150) result = "significant amounts"
			if(151 to INFINITY) result = "huge quantities"

		to_chat(user, "- [result] of [ore_type].")

/obj/item/weapon/mining_scanner/improved
	name = "Improved ore detector"
	desc = "A complex device used to locate ore deep underground."

	range = 3
	speed = 30
	var/mode = 2
	var/list/modes = list("3x3" = 1, "5x5" = 2, "7x7" = 3)

/obj/item/weapon/mining_scanner/improved/verb/change_mode(mob/user as mob)
	set name = "Toggle Scaner Mode"
	set category = "Object"
	set src in usr

	if(!istype(usr, /mob/living))
		return
	if(usr.stat) return

	if(get_dist(usr, src) > 1)
		to_chat(usr, "You have moved too far away.")
		return
	var/switchMode = input("Select a sensor mode:", "Scaner Sensor Mode", range) in modes
	range =  modes[switchMode]
	to_chat(user, "You set [switchMode] range mode")


/obj/item/weapon/mining_scanner/improved/adv
	name = "Advanced ore detector"
	desc = "A complex device used to locate ore deep underground."
	speed = 10
	modes = list("3x3" = 1, "5x5" = 2, "7x7" = 3, "9x9" = 4, "11x11" = 5)

