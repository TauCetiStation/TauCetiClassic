/obj/machinery/gateway
	name = "gateway"
	desc = "A mysterious gateway built by unknown hands, it allows for faster than light travel to far-flung locations."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "off"
	density = 1
	anchored = 1
	var/active = 0
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
/obj/machinery/gateway/centerstation
	density = TRUE
	icon_state = "offcenter"
	use_power = 1

	//warping vars
	var/list/linked = list()
	var/ready = FALSE			//have we got all the parts for a gateway?
	var/wait = 0				//this just grabs world.time at world start
	var/blocked = TRUE			// used in gateway_locker to allow/disallow entering to gateway while hacked
	var/obj/machinery/gateway/centeraway/awaygate = null

/obj/machinery/gateway/centerstation/atom_init()
	. = ..()
	wait = world.time + config.gateway_delay	//+ thirty minutes default

/obj/machinery/gateway/centerstation/atom_init_late()
	awaygate = locate(/obj/machinery/gateway/centeraway)


/obj/machinery/gateway/centerstation/update_icon()
	icon_state = active ? "on" : "off"
	icon_state += "center"
	if(hacked)
		icon_state += "_s"



obj/machinery/gateway/centerstation/process()
	if(stat & (NOPOWER) && active)
		toggleoff()
		return
	if(active)
		use_power(5000)


/obj/machinery/gateway/centerstation/proc/detect()
	linked = list()	//clear the list
	var/turf/T = loc

	for(var/i in alldirs)
		T = get_step(loc, i)
		var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T
		if(G)
			linked.Add(G)
			continue

		//this is only done if we fail to find a part
		ready = 0
		toggleoff()
		break

	if(linked.len == 8)
		ready = 1


/obj/machinery/gateway/centerstation/proc/toggleon(mob/user)
	if(!ready || linked.len != 8 || !powered())
		return
	if(!awaygate)
		to_chat(user, "<span class='notice'>Error: No destination found.</span>")
		return
	if(world.time < wait)
		to_chat(user, "<span class='notice'>Error: Warpspace triangulation in progress. Estimated time to completion: [round(((wait - world.time) / 10) / 60)] minutes.</span>")
		return

	for(var/obj/machinery/gateway/G in linked)
		G.active = 1
		G.update_icon()
	playsound(src, 'sound/machines/gateway/gateway_open.ogg', 100, 2)
	active = 1
	update_icon()


/obj/machinery/gateway/centerstation/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked)
		G.active = 0
		G.update_icon()
	playsound(src, 'sound/machines/gateway/gateway_close.ogg', 100, 2)
	active = 0
	update_icon()

/obj/machinery/gateway/centerstation/attack_hand(mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	. = ..()
	if(.)
		return
	if(!ready)
		detect()
		return
	if(!active)
		toggleon(user)
		return
	toggleoff()


//okay, here's the good teleporting stuff
/obj/machinery/gateway/centerstation/Bumped(atom/movable/M)
	if(!ready || !active || !awaygate)
		return
	if(awaygate.calibrated)
		if(hacked && blocked)
			if(ismob(M))
				to_chat(M, "<span class='danger'>Gateway Matter reacts strangely to your Touching</span>")
			return
		M.dir = SOUTH
		enter_to_transit(M, get_step(awaygate.loc, SOUTH))
	else
		var/obj/effect/landmark/dest = pick(awaydestinations)
		if(dest)
			M.dir = SOUTH
			enter_to_transit(M, dest.loc)
			use_power(5000)


/obj/machinery/gateway/centerstation/attackby(obj/item/device/W, mob/user)
	if(istype(W,/obj/item/device/multitool))
		to_chat(user, "The gate is already calibrated, there is no work for you to do here.")
	else
		..()

/////////////////////////////////////Away////////////////////////


/obj/machinery/gateway/centeraway
	density = TRUE
	icon_state = "offcenter"
	use_power = 0
	var/calibrated = 1
	var/list/linked = list()	//a list of the connected gateway chunks
	var/ready = 0
	var/obj/machinery/gateway/centerstation/stationgate = null


/obj/machinery/gateway/centeraway/atom_init_late()
	stationgate = locate(/obj/machinery/gateway/centerstation)


/obj/machinery/gateway/centeraway/update_icon()
	icon_state = active ? "on" : "off"
	icon_state += "center"
	if(hacked)
		icon_state += "_s"


/obj/machinery/gateway/centeraway/proc/detect()
	linked = list()	//clear the list
	var/turf/T = loc

	for(var/i in alldirs)
		T = get_step(loc, i)
		var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T
		if(G)
			linked.Add(G)
			continue

		//this is only done if we fail to find a part
		ready = 0
		toggleoff()
		break

	if(linked.len == 8)
		ready = 1


/obj/machinery/gateway/centeraway/proc/toggleon(mob/user)
	if(!ready || linked.len != 8)
		return 0
	if(!stationgate)
		to_chat(user, "<span class='notice'>Error: No destination found.</span>")
		return

	for(var/obj/machinery/gateway/G in linked)
		G.active = 1
		G.update_icon()
	playsound(src, 'sound/machines/gateway/gateway_open.ogg', 100, 2)
	active = 1
	update_icon()


/obj/machinery/gateway/centeraway/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked)
		G.active = 0
		G.update_icon()
	playsound(src, 'sound/machines/gateway/gateway_close.ogg', 100, 2)
	active = 0
	update_icon()

/obj/machinery/gateway/centeraway/attack_hand(mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	. = ..()
	if(.)
		return
	if(!ready)
		detect()
		return
	if(!active)
		toggleon(user)
		return
	toggleoff()


/obj/machinery/gateway/centeraway/Bumped(atom/movable/M)
	if(!ready || !active)
		return
	if(iscarbon(M))
		for(var/obj/item/weapon/implant/exile/E in M)//Checking that there is an exile implant in the contents
			if(E.imp_in == M)//Checking that it's actually implanted vs just in their pocket
				to_chat(M, "The station gate has detected your exile implant and is blocking your entry.")
				return
	M.dir = SOUTH
	enter_to_transit(M, get_step(stationgate.loc, SOUTH))


/obj/machinery/gateway/centeraway/attackby(obj/item/device/W, mob/user)
	if(istype(W,/obj/item/device/multitool))
		if(calibrated)
			to_chat(user, "The gate is already calibrated, there is no work for you to do here.")
		else
			to_chat(user, "<span class='notice'> <b>Recalibration successful!</b>:</span> This gate's systems have been fine tuned.  Travel to this gate will now be on target.")
			calibrated = 1
	else
		..()

/obj/machinery/gateway/proc/enter_to_transit(atom/movable/entered, turf/target)
	playsound(src, 'sound/machines/gateway/gateway_enter.ogg', 100, 2)
	entered.freeze_movement = TRUE
	entered.forceMove(transit_loc.loc)
	if(isliving(entered))
		var/mob/living/M = entered
		M.Stun(10, 1, 1, 1)
		var/obj/screen/cinematic = new /obj/screen{icon='icons/effects/gateway_entry.dmi'; icon_state="entry"; layer=21; mouse_opacity=0; screen_loc="1,0"; } (src)
		if(M.client)
			M.client.screen += cinematic
			M.playsound_local(M.loc, 'sound/machines/gateway/gateway_transit.ogg', 100, 2)
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
	playsound(target, 'sound/machines/gateway/gateway_enter.ogg', 100, 2)

/obj/effect/landmark/gateway_transit

/obj/effect/landmark/gateway_transit/Crossed(atom/movable/AM)
	if(!AM.freeze_movement)
		qdel(AM) // THIS IS BLUESPACE FELLAS
