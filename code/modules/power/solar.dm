#define SOLAR_MAX_DIST 40
#define SOLARGENRATE 1500

// This will choose whether to get the solar list from the powernet or the powernet nodes,
// depending on the size of the nodes.
/obj/machinery/power/proc/get_solars_powernet()
	if(!powernet)
		return list()
	if(SSsun.solars.len < powernet.nodes)
		return SSsun.solars
	else
		return powernet.nodes

/obj/machinery/power/solar
	name = "solar panel"
	desc = "A solar electrical generator."
	icon = 'icons/obj/power.dmi'
	icon_state = "sp_base"
	anchored = 1
	density = 1
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	var/id = 0
	var/health = 10
	var/obscured = 0
	var/sunfrac = 0
	var/adir = SOUTH
	var/ndir = SOUTH
	var/turn_angle = 0
	var/obj/machinery/power/solar_control/control = null

/obj/machinery/power/solar/atom_init(mapload, obj/item/solar_assembly/S, process = 1)
	. = ..()
	Make(S)
	connect_to_network(process)


/obj/machinery/power/solar/disconnect_from_network()
	..()
	SSsun.solars.Remove(src)

/obj/machinery/power/solar/connect_to_network(var/process)
	var/to_return = ..()
	if(process)
		SSsun.solars.Add(src)
	return to_return


/obj/machinery/power/solar/proc/Make(obj/item/solar_assembly/S)
	if(!S)
		S = new /obj/item/solar_assembly(src)
		S.glass_type = /obj/item/stack/sheet/glass
		S.anchored = 1
	S.loc = src
	update_icon()



/obj/machinery/power/solar/attackby(obj/item/weapon/W, mob/user)

	if(iscrowbar(W))
		if(user.is_busy()) return
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
		if(do_after(user, 50,target = src))
			var/obj/item/solar_assembly/S = locate() in src
			if(S)
				S.loc = src.loc
				S.give_glass()
			playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
			user.visible_message("<span class='notice'>[user] takes the glass off the solar panel.</span>")
			qdel(src)
		return
	else if (W)
		src.add_fingerprint(user)
		src.health -= W.force
		user.SetNextMove(CLICK_CD_MELEE)
		src.healthcheck()
	..()


/obj/machinery/power/solar/blob_act()
	src.health--
	src.healthcheck()
	return


/obj/machinery/power/solar/proc/healthcheck()
	if (src.health <= 0)
		if(!(stat & BROKEN))
			broken()
		else
			new /obj/item/weapon/shard(src.loc)
			new /obj/item/weapon/shard(src.loc)
			qdel(src)
			return
	return


/obj/machinery/power/solar/update_icon()
	..()
	cut_overlays()
	if(stat & BROKEN)
		add_overlay(image('icons/obj/power.dmi', icon_state = "solar_panel-b", layer = FLY_LAYER))
	else
		add_overlay(image('icons/obj/power.dmi', icon_state = "solar_panel", layer = FLY_LAYER))
		src.dir = angle2dir(adir)
	return


/obj/machinery/power/solar/proc/update_solar_exposure()
	if(!SSsun)
		return
	if(obscured)
		sunfrac = 0
		return
	var/p_angle = abs((360+adir)%360 - (360+SSsun.angle)%360)
	if(p_angle > 90)			// if facing more than 90deg from sun, zero output
		sunfrac = 0
		return
	sunfrac = cos(p_angle) ** 2


/obj/machinery/power/solar/process()//TODO: remove/add this from machines to save on processing as needed ~Carn PRIORITY
	if(stat & BROKEN)	return
	if(!control)	return

	if(adir != ndir)
		adir = (360+adir+clamp(ndir-adir,-10,10)) % 360
		update_icon()
		update_solar_exposure()

	if(obscured)	return

	var/sgen = SOLARGENRATE * sunfrac
	add_avail(sgen)
	if(powernet && control)
		if(powernet.nodes[control])
			control.gen += sgen


/obj/machinery/power/solar/proc/broken()
	stat |= BROKEN
	update_icon()
	return


/obj/machinery/power/solar/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			if(prob(15))
				new /obj/item/weapon/shard( src.loc )
			return
		if(2.0)
			if (prob(25))
				new /obj/item/weapon/shard( src.loc )
				qdel(src)
				return
			if (prob(50))
				broken()
		if(3.0)
			if (prob(25))
				broken()
	return


/obj/machinery/power/solar/blob_act()
	if(prob(75))
		broken()
		src.density = 0


/obj/machinery/power/solar/fake/atom_init(mapload, obj/item/solar_assembly/S)
	. = ..(mapload, S, 0)

/obj/machinery/power/solar/fake/process()
	. = PROCESS_KILL
	return


//
// Solar Assembly - For construction of solar arrays.
//

/obj/item/solar_assembly
	name = "solar panel assembly"
	desc = "A solar panel assembly kit, allows constructions of a solar panel, or with a tracking circuit board, a solar tracker."
	icon = 'icons/obj/power.dmi'
	icon_state = "sp_base"
	item_state = "electropack"
	w_class = ITEM_SIZE_LARGE // Pretty big!
	anchored = 0
	var/tracker = 0
	var/glass_type = null

/obj/item/solar_assembly/attack_hand(mob/user)
	if(!anchored && isturf(loc)) // You can't pick it up
		..()

// Give back the glass type we were supplied with
/obj/item/solar_assembly/proc/give_glass()
	if(glass_type)
		new glass_type(src.loc, 2)
		glass_type = null


/obj/item/solar_assembly/attackby(obj/item/I, mob/user, params)
	if(!anchored && isturf(loc))
		if(iswrench(I))
			anchored = TRUE
			user.visible_message("<span class='notice'>[user] wrenches the solar assembly into place.</span>")
			return TRUE
	else
		if(iswrench(I))
			anchored = FALSE
			user.visible_message("<span class='notice'>[user] unwrenches the solar assembly from it's place.</span>")
			return TRUE

		if(istype(I, /obj/item/stack/sheet/glass) || istype(I, /obj/item/stack/sheet/rglass))
			var/obj/item/stack/sheet/S = I
			if(S.use(2))
				glass_type = I.type
				playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
				user.visible_message("<span class='notice'>[user] places the glass on the solar assembly.</span>")
				if(tracker)
					new /obj/machinery/power/tracker(get_turf(src), src)
				else
					new /obj/machinery/power/solar(get_turf(src), src)
			return TRUE

	if(!tracker)
		if(istype(I, /obj/item/weapon/tracker_electronics))
			tracker = 1
			qdel(I)
			user.visible_message("<span class='notice'>[user] inserts the electronics into the solar assembly.</span>")
			return TRUE
	else
		if(iscrowbar(I))
			new /obj/item/weapon/tracker_electronics(src.loc)
			tracker = 0
			user.visible_message("<span class='notice'>[user] takes out the electronics from the solar assembly.</span>")
			return TRUE

	return ..()

//
// Solar Control Computer
//

/obj/machinery/power/solar_control
	name = "solar panel control"
	desc = "A controller for solar panel arrays."
	icon = 'icons/obj/computer.dmi'
	icon_state = "solar"
	light_color = "#b88b2e"
	anchored = 1
	density = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 20
	var/light_range_on = 1.5
	var/light_power_on = 3
	var/id = 0
	var/cdir = 0
	var/gen = 0
	var/lastgen = 0
	var/track = 0			// 0=off  1=manual  2=automatic
	var/trackrate = 60		// Measured in tenths of degree per minute (i.e. defaults to 6.0 deg/min)
	var/trackdir = 1		// -1=CCW, 1=CW
	var/nexttime = 0		// Next clock time that manual tracking will move the array

/obj/machinery/power/solar_control/atom_init()
	. = ..()
	connect_to_network()
	if(!powernet)
		return
	set_panels(cdir)

/obj/machinery/power/solar_control/disconnect_from_network()
	..()
	SSsun.solars.Remove(src)

/obj/machinery/power/solar_control/connect_to_network()
	var/to_return = ..()
	if(powernet)
		SSsun.solars.Add(src)
	return to_return

/obj/machinery/power/solar_control/update_icon()
	if(stat & BROKEN)
		icon_state = "powerb"
		set_light(0)
		cut_overlays()
		return
	if(stat & NOPOWER)
		icon_state = "power0"
		set_light(0)
		cut_overlays()
		return
	icon_state = "solar"
	set_light(light_range_on, light_power_on)
	cut_overlays()
	if(cdir > 0)
		add_overlay(image('icons/obj/computer.dmi', "solar_overlay_[dir]", FLY_LAYER, angle2dir(cdir)))
	return

/obj/machinery/power/solar_control/attackby(I, mob/user)
	if(isscrewdriver(I))
		if(user.is_busy()) return
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		if(do_after(user, 20, target = src))
			if (src.stat & BROKEN)
				to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				new /obj/item/weapon/shard( src.loc )
				var/obj/item/weapon/circuitboard/solar_control/M = new /obj/item/weapon/circuitboard/solar_control( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				qdel(src)
			else
				to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/solar_control/M = new /obj/item/weapon/circuitboard/solar_control( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				qdel(src)
	else
		src.attack_hand(user)
	return


/obj/machinery/power/solar_control/process()
	lastgen = gen
	gen = 0

	if(stat & (NOPOWER | BROKEN))
		return

	//use_power(250)
	if(track==1 && nexttime < world.time && trackdir*trackrate)
		// Increments nexttime using itself and not world.time to prevent drift
		nexttime = nexttime + 6000/trackrate
		// Nudges array 1 degree in desired direction
		cdir = (cdir+trackdir+360)%360
		set_panels(cdir)
		update_icon()

	src.updateDialog()


// called by solar tracker when sun position changes
/obj/machinery/power/solar_control/proc/tracker_update(angle)
	if(track != 2 || stat & (NOPOWER | BROKEN))
		return
	cdir = angle
	set_panels(cdir)
	update_icon()
	src.updateDialog()


/obj/machinery/power/solar_control/ui_interact(mob/user)
	if(stat & (BROKEN | NOPOWER))
		return
	if (!in_range(src, user) && !issilicon(user) && !isobserver(user))
		user.unset_machine()
		user << browse(null, "window=solcon")
		return

	var/t = "<TT><B>Solar Generator Control</B><HR><PRE>"
	t += "<B>Generated power</B> : [round(lastgen)] W<BR>"
	t += "Station Rotational Period: [60/abs(SSsun.rate)] minutes<BR>"
	t += "Station Rotational Direction: [SSsun.rate<0 ? "CCW" : "CW"]<BR>"
	t += "Star Orientation: [SSsun.angle]&deg ([angle2text(SSsun.angle)])<BR>"
	t += "Array Orientation: [rate_control(src,"cdir","[cdir]&deg",1,10,60)] ([angle2text(cdir)])<BR>"
	t += "<BR><HR><BR>"
	t += "Tracking: "
	switch(track)
		if(0)
			t += "<B>Off</B> <A href='?src=\ref[src];track=1'>Manual</A> <A href='?src=\ref[src];track=2'>Automatic</A><BR>"
		if(1)
			t += "<A href='?src=\ref[src];track=0'>Off</A> <B>Manual</B> <A href='?src=\ref[src];track=2'>Automatic</A><BR>"
		if(2)
			t += "<A href='?src=\ref[src];track=0'>Off</A> <A href='?src=\ref[src];track=1'>Manual</A> <B>Automatic</B><BR>"

	t += "Manual Tracking Rate: [rate_control(src,"tdir","[trackrate/10]&deg/min ([trackdir<0 ? "CCW" : "CW"])",1,10)]<BR>"
	t += "Manual Tracking Direction: "
	switch(trackdir)
		if(-1)
			t += "<A href='?src=\ref[src];trackdir=1'>CW</A> <B>CCW</B><BR>"
		if(1)
			t += "<B>CW</B> <A href='?src=\ref[src];trackdir=-1'>CCW</A><BR>"
	t += "<A href='?src=\ref[src];close=1'>Close</A></TT>"
	user << browse(t, "window=solcon")
	onclose(user, "solcon")


/obj/machinery/power/solar_control/Topic(href, href_list)
	if(href_list["close"])
		usr << browse(null, "window=solcon")
		usr.unset_machine(src)
		return FALSE

	. = ..()
	if(!.)
		return

	if(href_list["dir"])
		cdir = text2num(href_list["dir"])
		set_panels(cdir)
		update_icon()

	else if(href_list["rate control"])
		if(href_list["cdir"])
			src.cdir = clamp((360 + src.cdir + text2num(href_list["cdir"])) % 360, 0, 359)
			spawn(1)
				set_panels(cdir)
				update_icon()
		if(href_list["tdir"])
			src.trackrate = clamp(src.trackrate + text2num(href_list["tdir"]), 0, 360)
			if(src.trackrate)
				nexttime = world.time + 6000 / trackrate

	else if(href_list["track"])
		if(src.trackrate)
			nexttime = world.time + 6000 / trackrate
		track = text2num(href_list["track"])
		if(powernet && (track == 2))
			if(!SSsun.solars.Find(src,1,0))
				SSsun.solars.Add(src)
			for(var/obj/machinery/power/tracker/T in get_solars_powernet())
				if(powernet.nodes[T])
					cdir = T.sun_angle
					break

	else if(href_list["trackdir"])
		trackdir = text2num(href_list["trackdir"])

	set_panels(cdir)
	update_icon()
	src.updateUsrDialog()


/obj/machinery/power/solar_control/proc/set_panels(cdir)
	if(!powernet) return
	for(var/obj/machinery/power/solar/S in get_solars_powernet())
		if(powernet.nodes[S])
			if(get_dist(S, src) < SOLAR_MAX_DIST)
				if(!S.control)
					S.control = src
				S.ndir = cdir


/obj/machinery/power/solar_control/power_change()
	if(powered())
		stat &= ~NOPOWER
		update_icon()
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
			update_icon()
			update_power_use()
	update_power_use()


/obj/machinery/power/solar_control/proc/broken()
	stat |= BROKEN
	update_icon()


/obj/machinery/power/solar_control/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				broken()
		if(3.0)
			if (prob(25))
				broken()
	return


/obj/machinery/power/solar_control/blob_act()
	if (prob(75))
		broken()
		src.density = 0


//
// MISC
//

/obj/item/weapon/paper/solar
	name = "paper- 'Going green! Setup your own solar array instructions.'"
	info = "<h1>Welcome</h1><p>At greencorps we love the environment, and space. With this package you are able to help mother nature and produce energy without any usage of fossil fuel or phoron! Singularity energy is dangerous while solar energy is safe, which is why it's better. Now here is how you setup your own solar array.</p><p>You can make a solar panel by wrenching the solar assembly onto a cable node. Adding a glass panel, reinforced or regular glass will do, will finish the construction of your solar panel. It is that easy!.</p><p>Now after setting up 19 more of these solar panels you will want to create a solar tracker to keep track of our mother nature's gift, the sun. These are the same steps as before except you insert the tracker equipment circuit into the assembly before performing the final step of adding the glass. You now have a tracker! Now the last step is to add a computer to calculate the sun's movements and to send commands to the solar panels to change direction with the sun. Setting up the solar computer is the same as setting up any computer, so you should have no trouble in doing that. You do need to put a wire node under the computer, and the wire needs to be connected to the tracker.</p><p>Congratulations, you should have a working solar array. If you are having trouble, here are some tips. Make sure all solar equipment are on a cable node, even the computer. You can always deconstruct your creations if you make a mistake.</p><p>That's all to it, be safe, be green!</p>"
