//Farmbots by GauHelldragon - 12/30/2012
// A new type of buildable aiBot that helps out in hydroponics

// Made by using a robot arm on a water tank and then adding:
// A plant analyzer, a bucket, a mini-hoe and then a proximity sensor (in that order)

// Will water, weed and fertilize plants that need it
// When emagged, it will "water", "weed" and "fertilize" humans instead
// Holds up to 10 fertilizers (only the type dispensed by the machines, not chemistry bottles)
// It will fill up it's water tank at a sink when low.

// The behavior panel can be unlocked with hydroponics access and be modified to disable certain behaviors
// By default, it will ignore weeds and mushrooms, but can be set to tend to these types of plants as well.


#define FARMBOT_MODE_WATER			1
#define FARMBOT_MODE_FERTILIZE	 	2
#define FARMBOT_MODE_WEED			3
#define FARMBOT_MODE_REFILL			4
#define FARMBOT_MODE_WAITING		5

#define FARMBOT_ANIMATION_TIME		25 //How long it takes to use one of the action animations
#define FARMBOT_EMAG_DELAY			60 //How long of a delay after doing one of the emagged attack actions
#define FARMBOT_ACTION_DELAY		35 //How long of a delay after doing one of the normal actions

/obj/machinery/bot/farmbot
	name = "Farmbot"
	desc = "The botanist's best friend."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "farmbot0"
	layer = 5.0
	density = 1
	anchored = 0
	health = 50
	maxhealth = 50
	req_access =list(access_hydroponics)

	var/Max_Fertilizers = 10

	var/setting_water = 1
	var/setting_refill = 1
	var/setting_fertilize = 1
	var/setting_weed = 1
	var/setting_ignoreWeeds = 1
	var/setting_ignoreMushrooms = 1

	var/atom/target //Current target, can be a human, a hydroponics tray, or a sink
	var/mode //Which mode is being used, 0 means it is looking for work

	var/obj/structure/reagent_dispensers/watertank/tank // the water tank that was used to make it, remains inside the bot.

	var/path[] = new() // used for pathing
	var/frustration

/obj/machinery/bot/farmbot/atom_init()
	..()
	icon_state = "farmbot[src.on]"
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/bot/farmbot/atom_init_late()
	botcard = new /obj/item/weapon/card/id(src)
	botcard.access = req_access

	if ( !tank ) //Should be set as part of making it... but lets check anyway
		tank = locate(/obj/structure/reagent_dispensers/watertank) in contents
	if ( !tank ) //An admin must have spawned the farmbot! Better give it a tank.
		tank = new /obj/structure/reagent_dispensers/watertank(src)

/obj/machinery/bot/farmbot/Bump(atom/M) //Leave no door unopened!
	if ((istype(M, /obj/machinery/door)) && (!isnull(src.botcard)))
		var/obj/machinery/door/D = M
		if (!istype(D, /obj/machinery/door/firedoor) && D.check_access(src.botcard))
			D.open()
			src.frustration = 0

/obj/machinery/bot/farmbot/turn_on()
	. = ..()
	src.icon_state = "farmbot[src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/farmbot/turn_off()
	..()
	src.path = new()
	src.icon_state = "farmbot[src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/farmbot/proc/get_total_ferts()
	var/total_fert = 0
	for (var/obj/item/nutrient/fert in contents)
		total_fert++
	return total_fert

/obj/machinery/bot/farmbot/ui_interact(mob/user)
	var/dat
	dat += "<TT><B>Automatic Hyrdoponic Assisting Unit v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A><BR>"

	dat += "Water Tank: "
	if ( tank )
		dat += "\[[tank.reagents.total_volume]/[tank.reagents.maximum_volume]\]"
	else
		dat += "Error: Water Tank not Found"

	dat += "<br>Fertilizer Storage: <A href='?src=\ref[src];eject=1'>\[[get_total_ferts()]/[Max_Fertilizers]\]</a>"

	dat += "<br>Behaviour controls are [src.locked ? "locked" : "unlocked"]<hr>"
	if(!src.locked || issilicon(user) || isobserver(user))
		dat += "<TT>Watering Controls:<br>"
		dat += " Water Plants : <A href='?src=\ref[src];water=1'>[src.setting_water ? "Yes" : "No"]</A><BR>"
		dat += " Refill Watertank : <A href='?src=\ref[src];refill=1'>[src.setting_refill ? "Yes" : "No"]</A><BR>"
		dat += "<br>Fertilizer Controls:<br>"
		dat += " Fertilize Plants : <A href='?src=\ref[src];fertilize=1'>[src.setting_fertilize ? "Yes" : "No"]</A><BR>"
		dat += "<br>Weeding Controls:<br>"
		dat += " Weed Plants : <A href='?src=\ref[src];weed=1'>[src.setting_weed ? "Yes" : "No"]</A><BR>"
		dat += "<br>Ignore Weeds : <A href='?src=\ref[src];ignoreWeed=1'>[src.setting_ignoreWeeds ? "Yes" : "No"]</A><BR>"
		dat += "Ignore Mushrooms : <A href='?src=\ref[src];ignoreMush=1'>[src.setting_ignoreMushrooms ? "Yes" : "No"]</A><BR>"
		dat += "</TT>"

	var/datum/browser/popup = new(user, "window=autofarm", src.name)
	popup.set_content(dat)
	popup.open()

/obj/machinery/bot/farmbot/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if ((href_list["power"]) && (src.allowed(usr)))
		if (src.on)
			turn_off()
		else
			turn_on()
	else if(!locked || issilicon(usr) || isobserver(usr))
		if(href_list["water"])
			setting_water = !setting_water
		else if(href_list["refill"])
			setting_refill = !setting_refill
		else if(href_list["fertilize"])
			setting_fertilize = !setting_fertilize
		else if(href_list["weed"])
			setting_weed = !setting_weed
		else if(href_list["ignoreWeed"])
			setting_ignoreWeeds = !setting_ignoreWeeds
		else if(href_list["ignoreMush"])
			setting_ignoreMushrooms = !setting_ignoreMushrooms
		else if(href_list["eject"])
			flick("farmbot_hatch",src)
			for (var/obj/item/nutrient/fert in contents)
				fert.loc = get_turf(src)

	src.updateUsrDialog()

/obj/machinery/bot/farmbot/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(allowed(user))
			locked = !locked
			to_chat(user, "Controls are now [locked ? "locked." : "unlocked."]")
			updateUsrDialog()
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

	else if (istype(W, /obj/item/nutrient))
		if ( get_total_ferts() >= Max_Fertilizers )
			to_chat(user, "The fertilizer storage is full!")
			return
		to_chat(user, "<span class='notice'>You insert [W] into [src]</span>.")
		user.drop_from_inventory(W, src)
		flick("farmbot_hatch",src)
		updateUsrDialog()
		return

	else
		..()

/obj/machinery/bot/farmbot/emag_act(mob/user)
	..()
	if(user)
		to_chat(user, "<span class='warning'>You short out [src]'s plant identifier circuits.</span>")
	spawn(0)
		audible_message("<span class='warning'><B>[src] buzzes oddly!</B></span>")
	flick("farmbot_broke", src)
	src.emagged = 1
	src.on = 1
	src.icon_state = "farmbot[src.on]"
	target = null
	mode = FARMBOT_MODE_WAITING //Give the emagger a chance to get away! 15 seconds should be good.
	spawn(150)
		mode = 0

/obj/machinery/bot/farmbot/explode()
	src.on = 0
	visible_message("<span class='warning'><B>[src] blows apart!</B></span>")
	var/turf/Tsec = get_turf(src)

	new /obj/item/weapon/minihoe(Tsec)
	new /obj/item/weapon/reagent_containers/glass/bucket(Tsec)
	new /obj/item/device/assembly/prox_sensor(Tsec)
	new /obj/item/device/plant_analyzer(Tsec)

	if ( tank )
		tank.loc = Tsec

	for ( var/obj/item/nutrient/fert in contents )
		if ( prob(50) )
			fert.loc = Tsec

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
	return

/obj/machinery/bot/farmbot/process()
	//set background = 1

	if(!src.on)
		return

	if ( emagged && prob(1) )
		flick("farmbot_broke", src)

	if ( mode == FARMBOT_MODE_WAITING )
		return

	if ( !mode || !target || !(target in view(7,src)) ) //Don't bother chasing down targets out of view

		mode = 0
		target = null
		if ( !find_target() )
			// Couldn't find a target, wait a while before trying again.
			mode = FARMBOT_MODE_WAITING
			spawn(100)
				mode = 0
			return

	if ( mode && target )
		if ( get_dist(target,src) <= 1 || ( emagged && mode == FARMBOT_MODE_FERTILIZE ) )
			// If we are in emagged fertilize mode, we throw the fertilizer, so distance doesn't matter
			frustration = 0
			use_farmbot_item()
		else
			move_to_target()
	return

/obj/machinery/bot/farmbot/proc/use_farmbot_item()
	if ( !target )
		mode = 0
		return 0

	if ( emagged && !ismob(target) ) // Humans are plants!
		mode = 0
		target = null
		return 0

	if ( !emagged && !istype(target,/obj/machinery/hydroponics) && !istype(target,/obj/structure/sink) ) // Humans are not plants!
		mode = 0
		target = null
		return 0

	if ( mode == FARMBOT_MODE_FERTILIZE )
		//Find which fertilizer to use
		var/obj/item/nutrient/fert
		for ( var/obj/item/nutrient/nut in contents )
			fert = nut
			break
		if ( !fert )
			target = null
			mode = 0
			return
		fertilize(fert)

	if ( mode == FARMBOT_MODE_WEED )
		weed()

	if ( mode == FARMBOT_MODE_WATER )
		water()

	if ( mode == FARMBOT_MODE_REFILL )
		refill()




/obj/machinery/bot/farmbot/proc/find_target()
	if ( emagged ) //Find a human and help them!
		for ( var/mob/living/carbon/human/human in view(7,src) )
			if (human.stat == DEAD)
				continue

			var/list/options = list(FARMBOT_MODE_WEED)
			if ( get_total_ferts() )
				options.Add(FARMBOT_MODE_FERTILIZE)
			if ( tank && tank.reagents.total_volume >= 1 )
				options.Add(FARMBOT_MODE_WATER)
			mode = pick(options)
			target = human
			return mode
		return 0
	else
		if ( setting_refill && tank && tank.reagents.total_volume < 100 )
			for ( var/obj/structure/sink/source in view(7,src) )
				target = source
				mode = FARMBOT_MODE_REFILL
				return 1
		for ( var/obj/machinery/hydroponics/tray in view(7,src) )
			var/newMode = GetNeededMode(tray)
			if ( newMode )
				mode = newMode
				target = tray
				return 1
		return 0

/obj/machinery/bot/farmbot/proc/GetNeededMode(obj/machinery/hydroponics/tray)
	if ( !tray.planted || tray.dead )
		return 0
	if ( tray.myseed.plant_type == 1 && setting_ignoreWeeds )
		return 0
	if ( tray.myseed.plant_type == 2 && setting_ignoreMushrooms )
		return 0

	if ( setting_water && tray.waterlevel <= 10 && tank && tank.reagents.total_volume >= 1 )
		return FARMBOT_MODE_WATER

	if ( setting_weed && tray.weedlevel >= 5 )
		return FARMBOT_MODE_WEED

	if ( setting_fertilize && tray.nutrilevel <= 2 && get_total_ferts() )
		return FARMBOT_MODE_FERTILIZE

	return 0

/obj/machinery/bot/farmbot/proc/move_to_target()
	//Mostly copied from medibot code.

	if(src.frustration > 8)
		target = null
		mode = 0
		frustration = 0
		src.path = new()
	if(src.target && (src.path.len) && (get_dist(src.target,src.path[src.path.len]) > 2))
		src.path = new()
	if(src.target && src.path.len == 0 && (get_dist(src,src.target) > 1))
		spawn(0)
			var/turf/dest = get_step_towards(target,src)  //Can't pathfind to a tray, as it is dense, so pathfind to the spot next to the tray

			src.path = get_path_to(src, dest, /turf/proc/Distance, 0, 30,id=botcard)
			if(src.path.len == 0)
				for ( var/turf/spot in orange(1,target) ) //The closest one is unpathable, try  the other spots
					if ( spot == dest ) //We already tried this spot
						continue
					if ( spot.density )
						continue
					src.path = get_path_to(src, spot, /turf/proc/Distance, 0, 30,id=botcard)
					if ( src.path.len > 0 )
						break

				if ( src.path.len == 0 )
					target = null
					mode = 0
		return

	if(src.path.len > 0 && src.target)
		step_to(src, src.path[1])
		src.path -= src.path[1]
		spawn(3)
			if(src.path.len)
				step_to(src, src.path[1])
				src.path -= src.path[1]

	if(src.path.len > 8 && src.target)
		src.frustration++


/obj/machinery/bot/farmbot/proc/fertilize(obj/item/nutrient/fert)
	if ( !fert )
		target = null
		mode = 0
		return 0

	if ( emagged ) // Warning, hungry humans detected: throw fertilizer at them
		spawn(0)
			fert.loc = src.loc
			fert.throw_at(target, 16, 3, src)
		src.visible_message("<span class='warning'><b>[src] launches [fert.name] at [target.name]!</b></span>")
		flick("farmbot_broke", src)
		spawn (FARMBOT_EMAG_DELAY)
			mode = 0
			target = null
		return 1

	else // feed them plants~
		var/obj/machinery/hydroponics/tray = target
		tray.nutrilevel = 10
		tray.yieldmod = fert.yieldmod
		tray.mutmod = fert.mutmod
		qdel(fert)
		tray.update_icon()
		icon_state = "farmbot_fertile"
		mode = FARMBOT_MODE_WAITING

		spawn (FARMBOT_ACTION_DELAY)
			mode = 0
			target = null
		spawn (FARMBOT_ANIMATION_TIME)
			icon_state = "farmbot[src.on]"
		return 1

/obj/machinery/bot/farmbot/proc/weed()
	icon_state = "farmbot_hoe"
	spawn(FARMBOT_ANIMATION_TIME)
		icon_state = "farmbot[src.on]"

	if ( emagged ) // Warning, humans infested with weeds!
		mode = FARMBOT_MODE_WAITING
		spawn(FARMBOT_EMAG_DELAY)
			mode = 0

		if ( prob(50) ) // better luck next time little guy
			src.visible_message("<span class='warning'><b>[src] swings wildly at [target] with a minihoe, missing completely!</b></span>")

		else // yayyy take that weeds~
			var/attackVerb = pick("slashed", "sliced", "cut", "clawed")
			var/mob/living/carbon/human/human = target

			src.visible_message("<span class='warning'><B>[src] [attackVerb] [human]!</B></span>")
			var/damage = 5
			var/dam_zone = pick(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_L_LEG , BP_R_LEG)
			var/obj/item/organ/external/BP = human.bodyparts_by_name[ran_zone(dam_zone)]
			var/armor = human.run_armor_check(BP, "melee")
			human.apply_damage(damage, BRUTE, BP, armor, DAM_SHARP | DAM_EDGE)

	else // warning, plants infested with weeds!
		mode = FARMBOT_MODE_WAITING
		spawn(FARMBOT_ACTION_DELAY)
			mode = 0

		var/obj/machinery/hydroponics/tray = target
		tray.weedlevel = 0
		tray.update_icon()

/obj/machinery/bot/farmbot/proc/water()
	if ( !tank || tank.reagents.total_volume < 1 )
		mode = 0
		target = null
		return 0

	icon_state = "farmbot_water"
	spawn(FARMBOT_ANIMATION_TIME)
		icon_state = "farmbot[src.on]"

	if ( emagged ) // warning, humans are thirsty!
		var/splashAmount = min(70,tank.reagents.total_volume)
		src.visible_message("<span class='warning'>[src] splashes [target] with a bucket of water!</span>")
		playsound(src, 'sound/effects/slosh.ogg', VOL_EFFECTS_MASTER, 25)
		if ( prob(50) )
			tank.reagents.reaction(target, TOUCH) //splash the human!
		else
			tank.reagents.reaction(target.loc, TOUCH) //splash the human's roots!
		spawn(5)
			tank.reagents.remove_any(splashAmount)

		mode = FARMBOT_MODE_WAITING
		spawn(FARMBOT_EMAG_DELAY)
			mode = 0
	else
		var/obj/machinery/hydroponics/tray = target
		var/b_amount = tank.reagents.get_reagent_amount("water")
		if(b_amount > 0 && tray.waterlevel < 100)
			if(b_amount + tray.waterlevel > 100)
				b_amount = 100 - tray.waterlevel
			tank.reagents.remove_reagent("water", b_amount)
			tray.waterlevel += b_amount
			playsound(src, 'sound/effects/slosh.ogg', VOL_EFFECTS_MASTER, 25)

	//		Toxicity dilutation code. The more water you put in, the lesser the toxin concentration.
			tray.toxic -= round(b_amount/4)
			if (tray.toxic < 0 ) // Make sure it won't go overboard
				tray.toxic = 0

		tray.update_icon()
		mode = FARMBOT_MODE_WAITING
		spawn(FARMBOT_ACTION_DELAY)
			mode = 0

/obj/machinery/bot/farmbot/proc/refill()
	if ( !tank || !tank.reagents.total_volume > 600 || !istype(target,/obj/structure/sink) )
		mode = 0
		target = null
		return

	mode = FARMBOT_MODE_WAITING
	playsound(src, 'sound/effects/slosh.ogg', VOL_EFFECTS_MASTER, 25)
	src.visible_message("<span class='notice'>[src] starts filling it's tank from [target].</span>")
	spawn(300)
		src.visible_message("<span class='notice'>[src] finishes filling it's tank.</span>")
		src.mode = 0
		tank.reagents.add_reagent("water", tank.reagents.maximum_volume - tank.reagents.total_volume )
		playsound(src, 'sound/effects/slosh.ogg', VOL_EFFECTS_MASTER, 25)


/obj/item/weapon/farmbot_arm_assembly
	name = "water tank/robot arm assembly"
	desc = "A water tank with a robot arm permanently grafted to it."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "water_arm"
	var/build_step = 0
	var/created_name = "Farmbot" //To preserve the name if it's a unique farmbot I guess
	w_class = ITEM_SIZE_NORMAL

/obj/item/weapon/farmbot_arm_assembly/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/weapon/farmbot_arm_assembly/atom_init_late()
	// If an admin spawned it, it won't have a watertank it, so lets make one for em!
	var/tank = locate(/obj/structure/reagent_dispensers/watertank) in contents
	if(!tank)
		new /obj/structure/reagent_dispensers/watertank(src)


/obj/structure/reagent_dispensers/watertank/attackby(obj/item/I, mob/user)

	if(!istype(I, /obj/item/robot_parts/l_arm) && !istype(I, /obj/item/robot_parts/r_arm))
		return ..()

	to_chat(user, "<span class='notice'>You add \the [I] to the [src]</span>")

	new /obj/item/weapon/farmbot_arm_assembly(loc)

	qdel(I)
	qdel(src)

/obj/item/weapon/farmbot_arm_assembly/attackby(obj/item/I, mob/user, params)
	if((istype(I, /obj/item/device/plant_analyzer)) && !build_step)
		build_step++
		to_chat(user, "You add the plant analyzer to [src]!")
		name = "farmbot assembly"
		qdel(I)

	else if(istype(I, /obj/item/weapon/reagent_containers/glass/bucket) && build_step == 1)
		build_step++
		to_chat(user, "You add a bucket to [src]!")
		src.name = "farmbot assembly with bucket"
		qdel(I)

	else if(istype(I, /obj/item/weapon/minihoe) && build_step == 2)
		build_step++
		to_chat(user, "You add a minihoe to [src]!")
		src.name = "farmbot assembly with bucket and minihoe"
		qdel(I)

	else if(isprox(I) && build_step == 3)
		build_step++
		to_chat(user, "You complete the Farmbot! Beep boop.")
		var/obj/machinery/bot/farmbot/S = new /obj/machinery/bot/farmbot(get_turf(src))
		S.name = src.created_name
		qdel(I)
		qdel(src)

	else if(istype(I, /obj/item/weapon/pen))
		var/t = sanitize_safe(input(user, "Enter new robot name", src.name, input_default(src.created_name)) as text, MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		created_name = t

	else
		return ..()

/obj/item/weapon/farmbot_arm_assembly/attack_hand(mob/user)
	return //it's a converted watertank, no you cannot pick it up and put it in your backpack
