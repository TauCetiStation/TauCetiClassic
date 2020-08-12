/obj/machinery/gateway
	name = "gateway"
	desc = "A mysterious gateway built by unknown hands, it allows for faster than light travel to far-flung locations."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "off"
	density = TRUE
	anchored = TRUE

	var/active = FALSE  // on away missions you should activate gateway from start, or place "awaystart" landmarks somewhere
	var/hacked = FALSE
	var/static/obj/transit_loc = null

/obj/machinery/gateway/atom_init()
	..()
	update_icon()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/gateway/atom_init_late()
	if(dir & SOUTH)
		density = FALSE
	if(!transit_loc)
		transit_loc = locate(/obj/effect/landmark/gateway_transit) in landmarks_list

/obj/machinery/gateway/update_icon()
	icon_state = active ? "on" : "off"
	if(hacked)
		icon_state += "_s"

/obj/machinery/gateway/Destroy()
	if(hacked)
		return QDEL_HINT_LETMELIVE
	return ..()

//this is da important part wot makes things go
/obj/machinery/gateway/center
	name = "Unknown Gateway"
	density = TRUE
	icon_state = "offcenter"

	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 5000

	//warping vars
	var/list/linked = list()
	var/ready = FALSE			//have we got all the parts for a gateway?
	var/blocked = FALSE			// used in gateway_locker to allow/disallow entering to gateway while hacked
	var/atom/destination = null

	var/block_exile_implant = TRUE

/obj/machinery/gateway/center/atom_init()
	. = ..()

/obj/machinery/gateway/center/atom_init_late()
	detect()
	gateways_list += src

	if(active)
		for(var/obj/machinery/gateway/G in linked)
			G.active = 1
			G.update_icon()

/obj/machinery/gateway/center/update_icon()
	icon_state = active ? "on" : "off"
	icon_state += "center"
	if(hacked)
		icon_state += "_s"

/obj/machinery/gateway/center/process()
	if((stat & NOPOWER) && active)
		toggleoff()

/obj/machinery/gateway/center/proc/detect() // now this checked only at the start. It's okay if it continues to work without some parts... right?
	linked = list()	//clear the list
	var/turf/T = loc

	for(var/i in alldirs)
		T = get_step(loc, i)
		var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T
		if(G)
			linked.Add(G)
			continue

		//this is only done if we fail to find a part
		ready = FALSE
		toggleoff()
		break

	if(linked.len == 8)
		ready = TRUE

/obj/machinery/gateway/center/proc/toggleon(mob/user)
	if(!ready)
		to_chat(user, "<span class='warning'>Error: Integrity check failed.</span>")
		return

	if(!destination)
		to_chat(user, "<span class='notice'>Warning: No destination found, recalibration required. You can calibrate Gateway with multitool.</span>")

	for(var/obj/machinery/gateway/G in linked)
		G.active = TRUE
		G.update_icon()
	playsound(src, 'sound/machines/gateway/gateway_open.ogg', VOL_EFFECTS_MASTER)
	active = TRUE
	update_icon()

	set_power_use(ACTIVE_POWER_USE)
	START_PROCESSING(SSmachines, src)

/obj/machinery/gateway/center/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked)
		G.active = FALSE
		G.update_icon()
	playsound(src, 'sound/machines/gateway/gateway_close.ogg', VOL_EFFECTS_MASTER)
	active = FALSE
	update_icon()

	set_power_use(IDLE_POWER_USE)
	STOP_PROCESSING(SSmachines, src)

/obj/machinery/gateway/center/proc/calibrate(user)
	if(hacked)
		to_chat(user, "<span class='bold warning'>Error: Recalibration is not possible.</span>.")
		return
	var/list/destinations_choice = list()
	for(var/obj/machinery/gateway/center/G in gateways_list)
		if(G.active && ready && powered() && src != G)
			destinations_choice[G.name] = G

	//away gates always should be able to allow pass on station
	var/atom/station_gate = locate(/obj/machinery/gateway/center/station)
	if(station_gate && !(station_gate in destinations_choice) && !istype(src,/obj/machinery/gateway/center/station))
		destinations_choice[station_gate.name] = station_gate

	if(length(awaydestinations))
		destinations_choice["Unstable destination"] = pick(awaydestinations)

	destinations_choice["None"] = null

	var/user_pick = input(user, "Select a destination from the following candidates:","Gateway Destination",null) as null|anything in destinations_choice

	if(user_pick && destinations_choice[user_pick])
		destination = destinations_choice[user_pick]
		to_chat(user, "<span class='warning bold'>Recalibration successful!</span>.")

/obj/machinery/gateway/center/attack_hand(mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	. = ..()

	if(.)
		return

	if(!active && powered())
		toggleon(user)
		return

	toggleoff()

// okay, here's a good teleporting stuff
/obj/machinery/gateway/center/Bumped(atom/movable/M)
	if(!ready || !active)
		return

	if(hacked && blocked)
		if(ismob(M))
			to_chat(M, "<span class='danger'>Gateway Matter reacts strangely to your Touching</span>")
		return

	if(!destination)
		to_chat(M, "<span class='warning'>Error: No destination set, calibration required. You can calibrate Gateway with multitool.</span>")
		return

	if(block_exile_implant && iscarbon(M))
		for(var/obj/item/weapon/implant/exile/E in M)//Checking that there is an exile implant in the contents
			if(E.imp_in == M)//Checking that it's actually implanted vs just in their pocket
				to_chat(M, "The gate has detected your exile implant and is blocking your entry.")
				return

	M.dir = SOUTH
	enter_to_transit(M, get_step(destination.loc, SOUTH))
	use_power(1000)

/obj/machinery/gateway/center/attackby(obj/item/device/W, mob/user)
	if(ismultitool(W))
		calibrate(user)
	else
		..()

/obj/machinery/gateway/proc/enter_to_transit(atom/movable/entered, turf/target)
	playsound(src, 'sound/machines/gateway/gateway_enter.ogg', VOL_EFFECTS_MASTER)
	entered.freeze_movement = TRUE
	entered.forceMove(transit_loc.loc)
	if(isliving(entered))
		var/mob/living/M = entered
		M.Stun(10, 1, 1, 1)
		var/obj/screen/cinematic = new /obj/screen{icon='icons/effects/gateway_entry.dmi'; icon_state="entry"; layer=21; mouse_opacity=0; screen_loc="1,0"; } (src)
		if(M.client)
			M.client.screen += cinematic
			M.playsound_local(M.loc, 'sound/machines/gateway/gateway_transit.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		addtimer(CALLBACK(src, .proc/exit_from_transit, entered, target, cinematic), 100)
	else
		addtimer(CALLBACK(src, .proc/exit_from_transit, entered, target), 100)

/obj/machinery/gateway/proc/exit_from_transit(atom/movable/entered, turf/target, obj/screen/cinematic)
	if(isliving(entered))
		var/mob/living/M = entered
		if(M.client)
			cinematic.icon_state = "exit"
			flick("exit", cinematic)
			sleep(12)
			M.client.screen -= cinematic
		qdel(cinematic)
		M.AdjustStunned(-10, 1, 1, 0)
	entered.freeze_movement = FALSE
	entered.forceMove(target)
	playsound(target, 'sound/machines/gateway/gateway_enter.ogg', VOL_EFFECTS_MASTER)

/obj/effect/landmark/gateway_transit

/obj/effect/landmark/gateway_transit/Crossed(atom/movable/AM)
	. = ..()
	if(!AM.freeze_movement)
		qdel(AM) // THIS IS BLUESPACE FELLAS

/* station gate tweaks */
/obj/machinery/gateway/center/station
	name = "NSS Exodus Gateway"
	block_exile_implant = FALSE

/obj/machinery/gateway/center/station/atom_init()
	. = ..()
	name = "[station_name()] Gateway"

/obj/machinery/gateway/center/station/process()
	..()
	if(active && !hacked && !config.gateway_enabled)
		toggleoff()

/obj/machinery/gateway/center/station/calibrate(user)
	if(!hacked && !config.gateway_enabled)
		to_chat(user, "<span class='warning'>Error: Remote activation required, make a request to the CentComm for this.</span>")
		return
	..()

/obj/machinery/gateway/center/station/toggleon(mob/user)
	if(!hacked && !config.gateway_enabled)
		to_chat(user, "<span class='warning'>Error: Remote activation required, make a request to the CentComm for this.</span>")
		return
	..()
