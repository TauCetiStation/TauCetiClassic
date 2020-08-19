// Disposal bin
// Holds items for disposal into pipe system
// Draws air from turf, gradually charges internal reservoir
// Once full (~1 atm), uses air resv to flush items into the pipes
// Automatically recharges air (unless off), will flush when ready if pre-set
// Can hold items and human size things, no other draggables
// Toilets are a type of disposal bin for small objects only and work on magic. By magic, I mean torque rotation
#define SEND_PRESSURE (need_env_pressure ? (700 + ONE_ATMOSPHERE) : 0) //kPa - assume the inside of a dispoal pipe is 1 atm, so that needs to be added.
#define PRESSURE_TANK_VOLUME 150	//L

/obj/machinery/disposal
	name = "disposal unit"
	desc = "A pneumatic waste disposal unit."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "disposal"
	anchored = TRUE
	density = TRUE
	interact_open = TRUE
	active_power_usage = 600
	idle_power_usage = 100
	var/datum/gas_mixture/air_contents	// internal reservoir
	var/mode = 1	// item mode 0=off 1=charging 2=charged
	var/flush = 0	// true if flush handle is pulled
	var/obj/structure/disposalpipe/trunk/trunk = null // the attached pipe trunk
	var/flushing = 0	// true if flushing in progress
	var/flush_every_ticks = 30 //Every 30 ticks it will look whether it is ready to flush
	var/flush_count = 0 //this var adds 1 once per tick. When it reaches flush_every_ticks it resets and tries to flush.
	var/last_sound = 0
	var/need_env_pressure = 1

	// create a new disposal
	// find the attached trunk (if present) and init gas resvr.
/obj/machinery/disposal/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/disposal/atom_init_late()
	trunk = locate() in src.loc
	if(!trunk)
		mode = 0
		flush = 0
	else
		trunk.linked = src	// link the pipe trunk to self

	air_contents = new/datum/gas_mixture(PRESSURE_TANK_VOLUME)
	update()

/obj/machinery/disposal/Destroy()
	eject()
	if(trunk)
		trunk.linked = null
	return ..()

	// attack by item places it in to disposal
/obj/machinery/disposal/attackby(obj/item/I, mob/user)
	if(stat & BROKEN || !I || !user || !I.canremove)
		return

	if(isrobot(user) && !istype(I, /obj/item/weapon/storage/bag/trash))
		return
	src.add_fingerprint(user)
	if(mode<=0) // It's off
		if(isscrewdriver(I))
			if(contents.len > 0)
				to_chat(user, "Eject the items first!")
				return
			if(mode==0) // It's off but still not unscrewed
				mode=-1 // Set it to doubleoff l0l
				playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "You remove the screws around the power connection.")
				return
			else if(mode==-1)
				mode=0
				playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "You attach the screws around the power connection.")
				return
		else if(iswelder(I) && mode==-1)
			if(contents.len > 0)
				to_chat(user, "<span class='warning'>Eject the items first!</span>")
				return
			if(user.is_busy()) return
			var/obj/item/weapon/weldingtool/W = I
			if(W.use(0,user))
				to_chat(user, "You start slicing the floorweld off the disposal unit.")

				if(W.use_tool(src, user, 20, volume = 100))
					to_chat(user, "You sliced the floorweld off the disposal unit.")
					var/obj/structure/disposalconstruct/C = new (src.loc)
					src.transfer_fingerprints_to(C)
					C.ptype = 6 // 6 = disposal unit
					C.anchored = 1
					C.density = 1
					C.update()
					qdel(src)
				return
			else
				to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
				return

	if(istype(I, /obj/item/weapon/melee/energy/blade))
		to_chat(user, "<span class='warning'>You can't place that item inside the disposal unit.</span>")
		return

	if(istype(I, /obj/item/weapon/storage/bag/trash))
		var/obj/item/weapon/storage/bag/trash/T = I
		to_chat(user, "<span class='notice'>You empty the bag.</span>")
		for(var/obj/item/O in T.contents)
			T.remove_from_storage(O,src)
		T.update_icon()
		update()
		return

	var/obj/item/weapon/grab/G = I
	if(istype(G))	// handle grabbed mob
		if(ismob(G.affecting))
			var/mob/living/GM = G.affecting
			user.SetNextMove(CLICK_CD_MELEE)
			if(user.is_busy()) return
			user.visible_message("<span class='red'>[usr] starts putting [GM.name] into the disposal.</span>")
			if(G.use_tool(src, usr, 20))
				GM.loc = src
				GM.instant_vision_update(1,src)
				user.visible_message("<span class='danger'>[GM.name] has been placed in the [src] by [user].</span>")
				qdel(G)

				GM.log_combat(usr, "placed in disposals")
		return


	if(istype(I, /obj/item/weapon/holder))
		for(var/mob/living/holdermob in I.contents)
			holdermob.log_combat(usr, "placed in disposals")

	if(!I || !I.canremove || I.flags & NODROP)
		return
	user.drop_item()
	if(I)
		I.loc = src

	user.visible_message("<span class='notice'>[user.name] places \the [I] into the [src].</span>", self_message = "<span class='notice'>You place \the [I] into the [src].</span>")

	update()

// mouse drop another mob or self
//
/obj/machinery/disposal/proc/MouseDrop_Mob(mob/living/target, mob/living/user)
	if(user.incapacitated())
		return
	if(target.buckled || get_dist(user, src) > 1 || get_dist(user, target) > 1)
		return
	//animals cannot put mobs other than themselves into disposal
	if(isanimal(user) && target != user)
		return
	if(isessence(user))
		return

	src.add_fingerprint(user)
	var/target_loc = target.loc
	var/msg
	var/self_msg

	if(target == user && !user.stat && !user.weakened && !user.stunned && !user.paralysis)
		user.visible_message("<span class='red'>[usr] starts climbing into the disposal.</span>")
	if(target != user && !user.restrained() && !user.stat && !user.weakened && !user.stunned && !user.paralysis)
		if(target.anchored)
			return
		user.visible_message("<span class='red'>[usr] starts stuffing [target.name] into the disposal.</span>")

	if(user.is_busy() || !do_after(usr, 20, target = src))
		return
	if(target_loc != target.loc)
		return
	if(target == user && !user.stat && !user.weakened && !user.stunned && !user.paralysis)	// if drop self, then climbed in
											// must be awake, not stunned or whatever
		msg = "<span class='red'>[user.name] climbs into the [src].</span>"
		self_msg = "<span class='notice'>You climb into the [src].</span>"
	else if(target != user && !user.restrained() && !user.stat && !user.weakened && !user.stunned && !user.paralysis)
		msg = "<span class='danger'>[user.name] stuffs [target.name] into the [src]!</span>"
		self_msg = "<span class='red'>You stuff [target.name] into the [src]!</span>"

		target.log_combat(user, "placed in disposals")
	else
		return

	target.loc = src
	target.instant_vision_update(1,src)

	user.visible_message(msg, self_message = self_msg)

	update()
	return

//tc, temporary hack
/obj/machinery/disposal/MouseDrop_T(atom/A, mob/user)
	if(ismob(A))
		MouseDrop_Mob(A, user)
	else if(istype(A, /obj/structure/closet/body_bag))
		var/obj/structure/closet/body_bag/target = A

		if(get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.incapacitated() || istype(user, /mob/living/silicon/ai)) return
		if(isanimal(user)) return
		if(isessence(user))
			return
		src.add_fingerprint(user)
		var/target_loc = target.loc
		var/msg
		var/self_msg

		if(user.incapacitated())
			return
		user.visible_message("<span class='notice'>[user] starts stuffing [target.name] into the disposal.</span>")
		if(user.is_busy() || !do_after(usr, 20, target = src))
			return
		if(target_loc != target.loc)
			return

		if(user.incapacitated())
			return
		msg = "<span class='notice'>[user.name] stuffs [target.name] into the [src]!</span>"
		self_msg = "<span class='notice'>You stuff [target.name] into the [src]!</span>"

		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has placed [target.name] () in disposals.</font>")
		//target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been placed in disposals by [user.name] ([user.ckey])</font>")
		//msg_admin_attack("[user] ([user.ckey]) placed [target] ([target.ckey]) in a disposals unit. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		target.loc = src

		user.visible_message(msg, self_message = self_msg)

		update()
		return

	// can breath normally in the disposal
/obj/machinery/disposal/alter_health()
	return get_turf(src)

// resist to escape the bin
/obj/machinery/disposal/container_resist()
	if(src.flushing)
		return
	go_out(usr)
	return

// leave the disposal
/obj/machinery/disposal/proc/go_out(mob/user)
	user.loc = src.loc
	user.instant_vision_update(0)
	update()
	return


// monkeys can only pull the flush lever
/obj/machinery/disposal/attack_paw(mob/user)
	if(stat & BROKEN)
		return

	flush = !flush
	update()
	return

// human interact with machine
/obj/machinery/disposal/interact(mob/user)
	if(user && user.loc == src)
		to_chat(usr, "<span class='red'>You cannot reach the controls from inside.</span>")
	else
		..()

// user interaction
/obj/machinery/disposal/ui_interact(mob/user)
	if(stat & BROKEN)
		user.unset_machine(src)
		return

	var/dat = "<head><title>Waste Disposal Unit</title></head><body><TT><B>Waste Disposal Unit</B><HR>"

	if(!isAI(user))  // AI can't pull flush handle
		if(flush)
			dat += "Disposal handle: <A href='?src=\ref[src];handle=0'>Disengage</A> <B>Engaged</B>"
		else
			dat += "Disposal handle: <B>Disengaged</B> <A href='?src=\ref[src];handle=1'>Engage</A>"

		dat += "<BR><HR><A href='?src=\ref[src];eject=1'>Eject contents</A><HR>"

	if(mode <= 0)
		dat += "Pump: <B>Off</B> <A href='?src=\ref[src];pump=1'>On</A><BR>"
	else if(mode == 1)
		dat += "Pump: <A href='?src=\ref[src];pump=0'>Off</A> <B>On</B> (pressurizing)<BR>"
	else
		dat += "Pump: <A href='?src=\ref[src];pump=0'>Off</A> <B>On</B> (idle)<BR>"

	var/per
	if(need_env_pressure)
		per = 100 * air_contents.return_pressure() / (SEND_PRESSURE)

	dat += "Pressure: [need_env_pressure ? round(per, 1):"100"]%<BR></body>"


	user.set_machine(src)
	user << browse(dat, "window=disposal;size=360x170")
	onclose(user, "disposal")

// handle machine interaction

/obj/machinery/disposal/is_operational_topic()
	return !(stat & BROKEN)

/obj/machinery/disposal/Topic(href, href_list)
	if(href_list["close"])
		usr.unset_machine(src)
		usr << browse(null, "window=disposal")
		return FALSE

	. = ..()
	if(!.)
		return

	if(usr.loc == src)
		to_chat(usr, "<span class='red'>You cannot reach the controls from inside.</span>")
		return FALSE

	if(mode == -1 && !href_list["eject"]) // only allow ejecting if mode is -1
		to_chat(usr, "<span class='red'>The disposal units power is disabled.</span>")
		return FALSE

	if(src.flushing)
		return FALSE

	if(href_list["pump"])
		if(text2num(href_list["pump"]))
			mode = 1
		else
			mode = 0
		update()

	if(href_list["handle"])
		flush = text2num(href_list["handle"])
		update()

	if(href_list["eject"])
		eject()

	updateUsrDialog()

// eject the contents of the disposal unit
/obj/machinery/disposal/proc/eject()
	for(var/atom/movable/AM in src)
		AM.loc = src.loc
		AM.pipe_eject(0)
	update()

// update the icon & overlays to reflect mode & status
/obj/machinery/disposal/proc/update()
	cut_overlays()
	if(stat & BROKEN)
		icon_state = "disposal-broken"
		mode = 0
		flush = 0
		return

	// flush handle
	if(flush)
		add_overlay(image('icons/obj/pipes/disposal.dmi', "dispover-handle"))

	// only handle is shown if no power
	if(stat & NOPOWER || mode == -1)
		return

	// 	check for items in disposal - occupied light
	if(contents.len > 0)
		add_overlay(image('icons/obj/pipes/disposal.dmi', "dispover-full"))

	// charging and ready light
	if(mode == 1)
		add_overlay(image('icons/obj/pipes/disposal.dmi', "dispover-charge"))
	else if(mode == 2)
		add_overlay(image('icons/obj/pipes/disposal.dmi', "dispover-ready"))

// timed process
// charge the gas reservoir and perform flush if ready
/obj/machinery/disposal/process()
	if(stat & BROKEN)			// nothing can happen if broken
		return

	if(!air_contents) // Potentially causes a runtime otherwise (if this is really shitty, blame pete //Donkie)
		return

	flush_count++
	if( flush_count >= flush_every_ticks )
		if( contents.len )
			if(mode == 2)
				feedback_inc("disposal_auto_flush",1)
				INVOKE_ASYNC(src, .proc/flush)
		flush_count = 0

	src.updateDialog()

	if(flush && air_contents.return_pressure() >= SEND_PRESSURE )	// flush can happen even without power
		flush()

	if(stat & NOPOWER)			// won't charge if no power
		return

	if(mode != 1)		// if off or ready, no need to charge
		return

	// otherwise charge

	var/atom/L = loc						// recharging from loc turf

	if(need_env_pressure)
		var/datum/gas_mixture/env = L.return_air()
		var/pressure_delta = (SEND_PRESSURE*1.01) - air_contents.return_pressure()

		if(env.temperature > 0)
			var/transfer_moles = 0.1 * pressure_delta*air_contents.volume/(env.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = env.remove(transfer_moles)
			air_contents.merge(removed)


	// if full enough, switch to ready mode
	if(air_contents.return_pressure() >= SEND_PRESSURE)
		mode = 2
		set_power_use(IDLE_POWER_USE)
		update()
	return

// perform a flush
/obj/machinery/disposal/proc/flush()

	flushing = 1
	flick("[icon_state]-flush", src)

	var/wrapcheck = 0
	var/obj/structure/disposalholder/H = new()	// virtual holder object which actually
												// travels through the pipes.
	//Hacky test to get drones to mail themselves through disposals.
	for(var/mob/living/silicon/robot/drone/D in src)
		wrapcheck = 1

	for(var/obj/item/smallDelivery/O in src)
		wrapcheck = 1

	if(wrapcheck == 1)
		H.tomail = 1



	sleep(10)
	if(last_sound < world.time + 1)
		playsound(src, 'sound/machines/disposalflush.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		last_sound = world.time
	sleep(5) // wait for animation to finish


	H.init(src, air_contents)	// copy the contents of disposer to holder
	air_contents = new(PRESSURE_TANK_VOLUME)	// new empty gas resv.

	H.start(src) // start the holder processing movement
	flushing = 0
	// now reset disposal state
	flush = 0
	if(mode == 2)	// if was ready,
		mode = 1	// switch to charging
		set_power_use(ACTIVE_POWER_USE)
	update()
	return


// called when area power changes
/obj/machinery/disposal/power_change()
	..()	// do default setting/reset of stat NOPOWER bit
	update()	// update icon
	return


// called when holder is expelled from a disposal
// should usually only occur if the pipe network is modified
/obj/machinery/disposal/proc/expel(obj/structure/disposalholder/H)

	var/turf/target
	playsound(src, 'sound/machines/hiss.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	if(H) // Somehow, someone managed to flush a window which broke mid-transit and caused the disposal to go in an infinite loop trying to expel null, hopefully this fixes it
		for(var/atom/movable/AM in H)
			target = get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))
			AM.forceMove(src.loc)
			AM.pipe_eject(0)
			if(!isdrone(AM)) //Poor drones kept smashing windows and taking system damage being fired out of disposals. ~Z
				AM.throw_at(target, 5, 2)

		H.vent_gas(loc)
		qdel(H)

/obj/machinery/disposal/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (istype(mover,/obj/item) && mover.throwing)
		var/obj/item/I = mover
		if(istype(I, /obj/item/projectile))
			return
		if(prob(75))
			I.loc = src
			visible_message("\the [I] lands in \the [src].")
		else
			visible_message("\the [I] bounces off of \the [src]'s rim!")
		return 0
	else
		return ..(mover, target, height, air_group)

// virtual disposal object
// travels through pipes in lieu of actual items
// contents will be items flushed by the disposal
// this allows the gas flushed to be tracked

/obj/structure/disposalholder
	invisibility = 101
	var/datum/gas_mixture/gas = null	// gas used to flush, will appear at exit point
	var/active = 0	// true if the holder is moving, otherwise inactive
	dir = 0
	var/count = 2048	//*** can travel 2048 steps before going inactive (in case of loops)
	var/has_fat_guy = 0	// true if contains a fat person
	var/destinationTag = "" // changes if contains a delivery container
	var/tomail = 0 //changes if contains wrapped package
	var/hasmob = 0 //If it contains a mob
	var/has_bodybag = 0 // if it contains a bodybag

	var/partialTag = "" //set by a partial tagger the first time round, then put in destinationTag if it goes through again.

/obj/structure/disposalholder/Destroy()
	qdel(gas)
	active = 0
	return ..()

// initialize a holder from the contents of a disposal unit
/obj/structure/disposalholder/proc/init(obj/machinery/disposal/D, datum/gas_mixture/flush_gas)
	gas = flush_gas	// transfer gas resv. into holder object -- let's be explicit about the data this proc consumes, please.

	//Check for any living mobs trigger hasmob.
	//hasmob effects whether the package goes to cargo or its tagged destination.
	for(var/mob/living/M in D)
		if(M && M.stat != DEAD && !istype(M,/mob/living/silicon/robot/drone))
			hasmob = 1

	// now everything inside the disposal gets put into the holder
	// note AM since can contain mobs or objs
	for(var/atom/movable/AM in D)
		AM.loc = src
		if(istype(AM, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = AM
			has_fat_guy = HAS_TRAIT(H, TRAIT_FAT) // is a human and fat? set flag on holder
		if(istype(AM, /obj/structure/bigDelivery) && !hasmob)
			var/obj/structure/bigDelivery/T = AM
			src.destinationTag = T.sortTag
		if(istype(AM, /obj/item/smallDelivery) && !hasmob)
			var/obj/item/smallDelivery/T = AM
			src.destinationTag = T.sortTag
		//Drones can mail themselves through maint.
		if(istype(AM, /mob/living/silicon/robot/drone))
			var/mob/living/silicon/robot/drone/drone = AM
			src.destinationTag = drone.mail_destination
		if(istype(AM, /obj/structure/closet/body_bag))
			has_bodybag = 1


// start the movement process
// argument is the disposal unit the holder started in
/obj/structure/disposalholder/proc/start(obj/machinery/disposal/D)
	if(!D.trunk)
		D.expel(src)	// no trunk connected, so expel immediately
		return

	loc = D.trunk
	active = 1
	dir = DOWN
	addtimer(CALLBACK(src, .proc/move), 1)

// movement process, persists while holder is moving through pipes
/obj/structure/disposalholder/proc/move()
	var/obj/structure/disposalpipe/last
	while(active)
		sleep(1)		// was 1
		if(!loc) return // check if we got GC'd

		if(hasmob && prob(3))
			for(var/mob/living/H in src)
				if(!istype(H,/mob/living/silicon/robot/drone)) //Drones use the mailing code to move through the disposal system,
					H.take_overall_damage(20, 0, "Blunt Trauma")//horribly maim any living creature jumping down disposals.  c'est la vie

		if(has_bodybag && prob(3))
			for(var/obj/structure/closet/body_bag/B in src)
				for(var/mob/living/H in B)
					if(!istype(H,/mob/living/silicon/robot/drone))
						H.take_overall_damage(20, 0, "Blunt Trauma")

		if(has_fat_guy && prob(2)) // chance of becoming stuck per segment if contains a fat guy
			active = 0
			// find the fat guys
			for(var/mob/living/carbon/human/H in src)

			break
		sleep(1)		// was 1
		var/obj/structure/disposalpipe/curr = loc
		last = curr
		if(curr)
			curr = curr.transfer(src)

		if(!loc) return

		if(!curr)
			last.expel(src, loc, dir)

		//
		if(!(count--))
			active = 0
	return



// find the turf which should contain the next pipe
/obj/structure/disposalholder/proc/nextloc()
	return get_step(loc,dir)

// find a matching pipe on a turf
/obj/structure/disposalholder/proc/findpipe(turf/T)

	if(!T)
		return null

	var/fdir = turn(dir, 180)	// flip the movement direction
	for(var/obj/structure/disposalpipe/P in T)
		if(fdir & P.dpdir)		// find pipe direction mask that matches flipped dir
			return P
	// if no matching pipe, return null
	return null

// merge two holder objects
// used when a a holder meets a stuck holder
/obj/structure/disposalholder/proc/merge(obj/structure/disposalholder/other)
	for(var/atom/movable/AM in other)
		AM.loc = src		// move everything in other holder to this one
		if(ismob(AM))
			var/mob/M = AM
			M.instant_vision_update(1,src)

	if(other.has_fat_guy)
		has_fat_guy = 1
	qdel(other)


/obj/structure/disposalholder/proc/settag(new_tag)
	destinationTag = new_tag

/obj/structure/disposalholder/proc/setpartialtag(new_tag)
	if(partialTag == new_tag)
		destinationTag = new_tag
		partialTag = ""
	else
		partialTag = new_tag


// called when player tries to move while in a pipe
/obj/structure/disposalholder/relaymove(mob/user)

	if(!istype(user,/mob/living))
		return

	var/mob/living/U = user

	if (U.stat || U.last_special <= world.time)
		return

	U.last_special = world.time+100

	if (src.loc)
		for (var/mob/M in hearers(src.loc.loc))
			to_chat(M, "<FONT size=[max(0, 5 - get_dist(src, M))]>CLONG, clong!</FONT>")

	playsound(src, 'sound/effects/clang.ogg', VOL_EFFECTS_MASTER, null, FALSE)

// called to vent all gas in holder to a location
/obj/structure/disposalholder/proc/vent_gas(atom/location)
	location.assume_air(gas)  // vent all gas to turf
	return

// Disposal pipes

/obj/structure/disposalpipe
	icon = 'icons/obj/pipes/disposal.dmi'
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	anchored = 1
	density = 0

	level = 1			// underfloor only
	var/dpdir = 0		// bitmask of pipe directions
	dir = 0				// dir will contain dominant direction for junction pipes
	var/health = 10 	// health points 0-10
	layer = 2.3			// slightly lower than wires and other pipes
	var/base_icon_state	// initial icon state on map

	// new pipe, set the icon_state as on map
/obj/structure/disposalpipe/atom_init()
	. = ..()
	base_icon_state = icon_state

	// pipe is deleted
	// ensure if holder is present, it is expelled
/obj/structure/disposalpipe/Destroy()
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		// holder was present
		H.active = 0
		var/turf/T = src.loc
		if(T.density)
			// deleting pipe is inside a dense turf (wall)
			// this is unlikely, but just dump out everything into the turf in case

			for(var/atom/movable/AM in H)
				AM.loc = T
				AM.pipe_eject(0)
			qdel(H)
			return ..()

		// otherwise, do normal expel from turf
		if(H)
			expel(H, T, 0)
	return ..()

// returns the direction of the next pipe object, given the entrance dir
// by default, returns the bitmask of remaining directions
/obj/structure/disposalpipe/proc/nextdir(fromdir)
	return dpdir & (~turn(fromdir, 180))

// transfer the holder through this pipe segment
// overriden for special behaviour
//
/obj/structure/disposalpipe/proc/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.dir = nextdir
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.loc = P
	else			// if wasn't a pipe, then set loc to turf
		H.loc = T
		return null

	return P


// update the icon_state to reflect hidden status
/obj/structure/disposalpipe/proc/update()
	var/turf/T = src.loc
	hide(T.intact && !istype(T,/turf/space))	// space never hides pipes

// hide called by levelupdate if turf intact status changes
// change visibility status and force update of icon
/obj/structure/disposalpipe/hide(intact)
	invisibility = intact ? 101: 0	// hide if floor is intact
	updateicon()

// update actual icon_state depending on visibility
// if invisible, append "f" to icon_state to show faded version
// this will be revealed if a T-scanner is used
// if visible, use regular icon_state
/obj/structure/disposalpipe/proc/updateicon()
	if(invisibility)
		icon_state = "[base_icon_state]f"
	else
		icon_state = base_icon_state
	return


// expel the held objects into a turf
// called when there is a break in the pipe
//

/obj/structure/disposalpipe/proc/expel(obj/structure/disposalholder/H, turf/T, direction)
	if(!istype(H))
		return

	// Empty the holder if it is expelled into a dense turf.
	// Leaving it intact and sitting in a wall is stupid.
	if(T.density)
		for(var/atom/movable/AM in H)
			AM.loc = T
			AM.pipe_eject(0)
		qdel(H)
		return
	if(T.intact && istype(T,/turf/simulated/floor)) //intact floor, pop the tile
		var/turf/simulated/floor/F = T
		//F.health	= 100
		F.burnt	= 1
		F.intact	= 0
		F.levelupdate()
		new /obj/item/stack/tile(H)	// add to holder so it will be thrown with other stuff
		F.icon_state = "Floor[F.burnt ? "1" : ""]"

	var/turf/target
	if(direction)		// direction is specified
		if(istype(T, /turf/space)) // if ended in space, then range is unlimited
			target = get_edge_target_turf(T, direction)
		else						// otherwise limit to 10 tiles
			target = get_ranged_target_turf(T, direction, 10)

		playsound(src, 'sound/machines/hiss.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		if(H)
			for(var/atom/movable/AM in H)
				AM.forceMove(T)
				AM.pipe_eject(direction)
				AM.throw_at(target, 100, 2)
			H.vent_gas(T)
			qdel(H)

	else	// no specified direction, so throw in random direction

		playsound(src, 'sound/machines/hiss.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		if(H)
			for(var/atom/movable/AM in H)
				target = get_offset_target_turf(T, rand(5)-rand(5), rand(5)-rand(5))
				AM.forceMove(T)
				AM.pipe_eject(0)
				AM.throw_at(target, 5, 2)

			H.vent_gas(T)	// all gas vent to turf
			qdel(H)

	return

// call to break the pipe
// will expel any holder inside at the time
// then delete the pipe
// remains : set to leave broken pipe pieces in place
/obj/structure/disposalpipe/proc/broken(remains = 0)
	if(remains)
		for(var/D in cardinal)
			if(D & dpdir)
				var/obj/structure/disposalpipe/broken/P = new(src.loc)
				P.dir = D

	src.invisibility = 101	// make invisible (since we won't delete the pipe immediately)
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		// holder was present
		H.active = 0
		var/turf/T = src.loc
		if(T.density)
			// broken pipe is inside a dense turf (wall)
			// this is unlikely, but just dump out everything into the turf in case

			for(var/atom/movable/AM in H)
				AM.loc = T
				AM.pipe_eject(0)
			qdel(H)
			return

		// otherwise, do normal expel from turf
		if(H)
			expel(H, T, 0)

	QDEL_IN(src, 2) // delete pipe after 2 ticks to ensure expel proc finished


// pipe affected by explosion
/obj/structure/disposalpipe/ex_act(severity)

	switch(severity)
		if(1.0)
			broken(0)
			return
		if(2.0)
			health -= rand(5,15)
			healthcheck()
			return
		if(3.0)
			health -= rand(0,15)
			healthcheck()
			return


// test health for brokenness
/obj/structure/disposalpipe/proc/healthcheck()
	if(health < -2)
		broken(0)
	else if(health<1)
		broken(1)
	return

//attack by item
//weldingtool: unfasten and convert to obj/disposalconstruct

/obj/structure/disposalpipe/attackby(obj/item/I, mob/user)

	var/turf/T = src.loc
	if(T.intact)
		return		// prevent interaction with T-scanner revealed pipes
	src.add_fingerprint(user)
	if(user.is_busy()) return
	if(iswelder(I))
		var/obj/item/weapon/weldingtool/W = I

		if(W.use(0,user))
			// check if anything changed over 2 seconds
			to_chat(user, "You start slicing the disposal pipe.")
			if(W.use_tool(src, user, 30, volume = 100))
				to_chat(user, "<span class='notice'>You sliced the disposal pipe.</span>")
				welded()
			else
				to_chat(user, "<span class='warning'>You must stay still while welding the pipe.</span>")
		else
			to_chat(user, "<span class='warning'>You need more welding fuel to cut the pipe.</span>")
			return

// called when pipe is cut with welder
/obj/structure/disposalpipe/proc/welded()

	var/obj/structure/disposalconstruct/C = new (src.loc)
	switch(base_icon_state)
		if("pipe-s")
			C.ptype = 0
		if("pipe-c")
			C.ptype = 1
		if("pipe-j1")
			C.ptype = 2
		if("pipe-j2")
			C.ptype = 3
		if("pipe-y")
			C.ptype = 4
		if("pipe-t")
			C.ptype = 5
		if("pipe-j1s")
			C.ptype = 9
		if("pipe-j2s")
			C.ptype = 10
		if("pipe-tagger")
			C.ptype = 11
		if("pipe-tagger-partial")
			C.ptype = 12
	src.transfer_fingerprints_to(C)
	C.dir = dir
	C.density = 0
	C.anchored = 1
	C.update()

	qdel(src)

// *** TEST verb
//client/verb/dispstop()
//	for(var/obj/structure/disposalholder/H in world)
//		H.active = 0

// a straight or bent segment
/obj/structure/disposalpipe/segment
	icon_state = "pipe-s"

/obj/structure/disposalpipe/segment/atom_init()
	. = ..()
	if(icon_state == "pipe-s")
		dpdir = dir | turn(dir, 180)
	else
		dpdir = dir | turn(dir, -90)

	update()

//a three-way junction with dir being the dominant direction
/obj/structure/disposalpipe/junction
	icon_state = "pipe-j1"

/obj/structure/disposalpipe/junction/atom_init()
	. = ..()
	if(icon_state == "pipe-j1")
		dpdir = dir | turn(dir, -90) | turn(dir,180)
	else if(icon_state == "pipe-j2")
		dpdir = dir | turn(dir, 90) | turn(dir,180)
	else // pipe-y
		dpdir = dir | turn(dir,90) | turn(dir, -90)
	update()


// next direction to move
// if coming in from secondary dirs, then next is primary dir
// if coming in from primary dir, then next is equal chance of other dirs

/obj/structure/disposalpipe/junction/nextdir(fromdir)
	var/flipdir = turn(fromdir, 180)
	if(flipdir != dir)	// came from secondary dir
		return dir		// so exit through primary
	else				// came from primary
						// so need to choose either secondary exit
		var/mask = ..(fromdir)

		// find a bit which is set
		var/setbit = 0
		if(mask & NORTH)
			setbit = NORTH
		else if(mask & SOUTH)
			setbit = SOUTH
		else if(mask & EAST)
			setbit = EAST
		else
			setbit = WEST

		if(prob(50))	// 50% chance to choose the found bit or the other one
			return setbit
		else
			return mask & (~setbit)


/obj/structure/disposalpipe/tagger
	name = "package tagger"
	icon_state = "pipe-tagger"
	var/sort_tag = ""
	var/partial = 0

/obj/structure/disposalpipe/tagger/proc/updatedesc()
	desc = initial(desc)
	if(sort_tag)
		desc += "\nIt's tagging objects with the '[sort_tag]' tag."

/obj/structure/disposalpipe/tagger/proc/updatename()
	if(sort_tag)
		name = "[initial(name)] ([sort_tag])"
	else
		name = initial(name)

/obj/structure/disposalpipe/tagger/atom_init()
	. = ..()
	dpdir = dir | turn(dir, 180)
	if(sort_tag)
		tagger_locations |= sort_tag
	updatename()
	updatedesc()
	update()

/obj/structure/disposalpipe/tagger/attackby(obj/item/I, mob/user)
	if(..())
		return

	if(istype(I, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = I

		if(O.currTag)// Tag set
			sort_tag = O.currTag
			playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "<span class='notice'>You changed tag to '[sort_tag]'.</span>")
			updatename()
			updatedesc()

/obj/structure/disposalpipe/tagger/transfer(obj/structure/disposalholder/H)
	if(sort_tag)
		if(partial)
			H.setpartialtag(sort_tag)
		else
			H.settag(sort_tag)
	return ..()

/obj/structure/disposalpipe/tagger/partial //needs two passes to tag
	name = "partial package tagger"
	icon_state = "pipe-tagger-partial"
	partial = 1

//a three-way junction that sorts objects
/obj/structure/disposalpipe/sortjunction
	name = "sorting junction"
	icon_state = "pipe-j1s"
	desc = "An underfloor disposal pipe with a package sorting mechanism."

	var/sortType = ""
	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0

/obj/structure/disposalpipe/sortjunction/proc/updatedesc()
	desc = initial(desc)
	if(sortType)
		desc += "\nIt's filtering objects with the '[sortType]' tag."

/obj/structure/disposalpipe/sortjunction/proc/updatename()
	if(sortType)
		name = "[initial(name)] ([sortType])"
	else
		name = initial(name)

/obj/structure/disposalpipe/sortjunction/proc/updatedir()
	posdir = dir
	negdir = turn(posdir, 180)

	if(icon_state == "pipe-j1s")
		sortdir = turn(posdir, -90)
	else if(icon_state == "pipe-j2s")
		sortdir = turn(posdir, 90)

	dpdir = sortdir | posdir | negdir

/obj/structure/disposalpipe/sortjunction/atom_init()
	. = ..()
	if(sortType)
		tagger_locations |= sortType

	updatedir()
	updatename()
	updatedesc()
	update()

/obj/structure/disposalpipe/sortjunction/attackby(obj/item/I, mob/user)
	if(..())
		return

	if(istype(I, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = I

		if(O.currTag)// Tag set
			sortType = O.currTag
			playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "<span class='notice'>You changed filter to '[sortType]'.</span>")
			updatename()
			updatedesc()

/obj/structure/disposalpipe/sortjunction/proc/divert_check(checkTag)
	return sortType == checkTag

// next direction to move
// if coming in from negdir, then next is primary dir or sortdir
// if coming in from posdir, then flip around and go back to posdir
// if coming in from sortdir, go to posdir

/obj/structure/disposalpipe/sortjunction/nextdir(fromdir, sortTag)
	if(fromdir != sortdir)	// probably came from the negdir
		if(divert_check(sortTag))
			return sortdir
		else
			return posdir
	else				// came from sortdir
						// so go with the flow to positive direction
		return posdir

/obj/structure/disposalpipe/sortjunction/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir, H.destinationTag)
	H.dir = nextdir
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		// find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.loc = P
	else			// if wasn't a pipe, then set loc to turf
		H.loc = T
		return null

	return P

//a three-way junction that filters all wrapped and tagged items
/obj/structure/disposalpipe/sortjunction/wildcard
	name = "wildcard sorting junction"
	desc = "An underfloor disposal pipe which filters all wrapped and tagged items."

/obj/structure/disposalpipe/sortjunction/wildcard/divert_check(checkTag)
	return checkTag != ""

//junction that filters all untagged items
/obj/structure/disposalpipe/sortjunction/untagged
	name = "untagged sorting junction"
	desc = "An underfloor disposal pipe which filters all untagged items."

/obj/structure/disposalpipe/sortjunction/untagged/divert_check(checkTag)
	return checkTag == ""

/obj/structure/disposalpipe/sortjunction/flipped //for easier and cleaner mapping
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/wildcard/flipped
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/untagged/flipped
	icon_state = "pipe-j2s"

//a trunk joining to a disposal bin or outlet on the same turf
/obj/structure/disposalpipe/trunk
	icon_state = "pipe-t"
	var/obj/linked 	// the linked obj/machinery/disposal or obj/disposaloutlet

/obj/structure/disposalpipe/trunk/atom_init()
	..()
	dpdir = dir
	update()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/disposalpipe/trunk/atom_init_late()
	getlinked()

/obj/structure/disposalpipe/trunk/proc/getlinked()
	linked = null
	var/obj/machinery/disposal/D = locate() in src.loc
	if(D)
		linked = D
		if (!D.trunk)
			D.trunk = src

	var/obj/structure/disposaloutlet/O = locate() in src.loc
	if(O)
		linked = O

	update()
	return

	// Override attackby so we disallow trunkremoval when somethings ontop
/obj/structure/disposalpipe/trunk/attackby(obj/item/I, mob/user)

	//Disposal bins or chutes
	/*
	These shouldn't be required
	var/obj/machinery/disposal/D = locate() in src.loc
	if(D && D.anchored)
		return

	//Disposal outlet
	var/obj/structure/disposaloutlet/O = locate() in src.loc
	if(O && O.anchored)
		return
	*/

	//Disposal constructors
	var/obj/structure/disposalconstruct/C = locate() in src.loc
	if(C && C.anchored)
		return

	var/turf/T = src.loc
	if(T.intact)
		return		// prevent interaction with T-scanner revealed pipes
	src.add_fingerprint(user)
	if(iswelder(I))
		var/obj/item/weapon/weldingtool/W = I
		if(user.is_busy()) return
		if(W.use(0,user))
			to_chat(user, "You start slicing the disposal pipe.")
			if(W.use_tool(src, user, 30, volume = 100))
				to_chat(user, "<span class='notice'>You sliced the disposal pipe.</span>")
				welded()
			else
				to_chat(user, "<span class='warning'>You must stay still while welding the pipe.</span>")
		else
			to_chat(user, "<span class='warning'>You need more welding fuel to cut the pipe.</span>")
			return

	// would transfer to next pipe segment, but we are in a trunk
	// if not entering from disposal bin,
	// transfer to linked object (outlet or bin)

/obj/structure/disposalpipe/trunk/transfer(obj/structure/disposalholder/H)

	if(H.dir == DOWN)		// we just entered from a disposer
		return ..()		// so do base transfer proc
	// otherwise, go to the linked object
	if(linked)
		var/obj/structure/disposaloutlet/O = linked
		if(istype(O) && (H))
			O.expel(H)	// expel at outlet
		else
			var/obj/machinery/disposal/D = linked
			if(H)
				D.expel(H)	// expel at disposal
	else
		if(H)
			src.expel(H, src.loc, 0)	// expel at turf
	return null

	// nextdir

/obj/structure/disposalpipe/trunk/nextdir(fromdir)
	if(fromdir == DOWN)
		return dir
	else
		return 0

// a broken pipe
/obj/structure/disposalpipe/broken
	icon_state = "pipe-b"
	dpdir = 0		// broken pipes have dpdir=0 so they're not found as 'real' pipes
					// i.e. will be treated as an empty turf
	desc = "A broken piece of disposal pipe."

/obj/structure/disposalpipe/broken/atom_init()
	. = ..()
	update()

	// called when welded
	// for broken pipe, remove and turn into scrap

/obj/structure/disposalpipe/broken/welded()
//		var/obj/item/scrap/S = new(src.loc)
//		S.set_components(200,0,0)
	qdel(src)

// the disposal outlet machine

/obj/structure/disposaloutlet
	name = "disposal outlet"
	desc = "An outlet for the pneumatic disposal system."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "outlet"
	density = 1
	anchored = 1
	var/active = 0
	var/turf/target	// this will be where the output objects are 'thrown' to.
	var/mode = 0

/obj/structure/disposaloutlet/atom_init(mapload, dir)
	..()
	if(dir)
		src.dir = dir
	return INITIALIZE_HINT_LATELOAD

/obj/structure/disposaloutlet/atom_init_late()
	target = get_ranged_target_turf(src, dir, 10)

	var/obj/structure/disposalpipe/trunk/trunk = locate() in loc
	if(trunk)
		trunk.linked = src	// link the pipe trunk to self

// expel the contents of the holder object, then delete it
// called when the holder exits the outlet
/obj/structure/disposaloutlet/proc/expel(obj/structure/disposalholder/H)

	flick("outlet-open", src)
	playsound(src, 'sound/machines/warning-buzzer.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	sleep(20)	//wait until correct animation frame
	playsound(src, 'sound/machines/hiss.ogg', VOL_EFFECTS_MASTER, null, FALSE)

	if(H)
		for(var/atom/movable/AM in H)
			AM.forceMove(src.loc)
			AM.pipe_eject(dir)
			if(!isdrone(AM)) //Drones keep smashing windows from being fired out of chutes. Bad for the station. ~Z
				AM.throw_at(target, 3, 2)
		H.vent_gas(src.loc)
		qdel(H)

	return

/obj/structure/disposaloutlet/attackby(obj/item/I, mob/user)
	if(!I || !user)
		return
	src.add_fingerprint(user)
	if(isscrewdriver(I))
		if(mode==0)
			mode=1
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "You remove the screws around the power connection.")
			return
		else if(mode==1)
			mode=0
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "You attach the screws around the power connection.")
			return
	else if(iswelder(I) && mode==1 && !user.is_busy())
		var/obj/item/weapon/weldingtool/W = I
		if(W.use(0,user))
			to_chat(user, "You start slicing the floorweld off the disposal outlet.")
			if(W.use_tool(src, user, 20, volume = 100))
				to_chat(user, "You sliced the floorweld off the disposal outlet.")
				var/obj/structure/disposalconstruct/C = new (src.loc)
				src.transfer_fingerprints_to(C)
				C.ptype = 7 // 7 =  outlet
				C.update()
				C.anchored = 1
				C.density = 1
				C.dir = dir
				qdel(src)
			return
		else
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			return



// called when movable is expelled from a disposal pipe or outlet
// by default does nothing, override for special behaviour

/atom/movable/proc/pipe_eject(direction)
	return

// check if mob has client, if so restore client view on eject
/mob/pipe_eject(direction)
	instant_vision_update(0)
	return

/obj/effect/decal/cleanable/blood/gibs/pipe_eject(direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = alldirs.Copy()

	src.streak(dirs)

/obj/effect/decal/cleanable/blood/gibs/robot/pipe_eject(direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = alldirs.Copy()

	src.streak(dirs)

// hostile mob escape from disposals
/obj/machinery/disposal/attack_animal(mob/living/simple_animal/M)
	if(M.environment_smash)
		..()
		playsound(M, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
		visible_message("<span class='danger'>[M.name] smashes [src] apart!</span>")
		qdel(src)
	return

#undef SEND_PRESSURE
#undef PRESSURE_TANK_VOLUME
