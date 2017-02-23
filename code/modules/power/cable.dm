///////////////////////////////
//CABLE STRUCTURE
///////////////////////////////


////////////////////////////////
// Definitions
////////////////////////////////

/* Cable directions (d1 and d2)


  9   1   5
	\ | /
  8 - 0 - 4
	/ | \
  10  2   6

If d1 = 0 and d2 = 0, there's no cable
If d1 = 0 and d2 = dir, it's a O-X cable, getting from the center of the tile to dir (knot cable)
If d1 = dir1 and d2 = dir2, it's a full X-X cable, getting from dir1 to dir2
By design, d1 is the smallest direction and d2 is the highest
*/

// the power cable object
/obj/structure/cable
	level = 1 //is underfloor
	anchored =1
	var/datum/powernet/powernet
	name = "power cable"
	desc = "A flexible superconducting cable for heavy-duty power transfer."
	icon = 'icons/obj/power_cond_white.dmi'
	icon_state = "0-1"
	var/d1 = 0   // cable direction 1 (see above)
	var/d2 = 1   // cable direction 2 (see above)
	layer = 2.44 //Just below unary stuff, which is at 2.45 and above pipes, which are at 2.4
	color = COLOR_RED

/obj/structure/cable/yellow
	color = COLOR_YELLOW

/obj/structure/cable/green
	color = COLOR_GREEN

/obj/structure/cable/blue
	color = COLOR_BLUE

/obj/structure/cable/pink
	color = COLOR_PINK

/obj/structure/cable/orange
	color = COLOR_ORANGE

/obj/structure/cable/cyan
	color = COLOR_CYAN

/obj/structure/cable/white
	color = COLOR_WHITE

/obj/structure/cable/New()
	..()


	// ensure d1 & d2 reflect the icon_state for entering and exiting cable

	var/dash = findtext(icon_state, "-")

	d1 = text2num( copytext( icon_state, 1, dash ) )

	d2 = text2num( copytext( icon_state, dash+1 ) )

	var/turf/T = src.loc			// hide if turf is not intact

	if(level==1) hide(T.intact)
	cable_list += src //add it to the global cable list
	update_icon()


/obj/structure/cable/Destroy()						// called when a cable is deleted
	if(powernet)
		cut_cable_from_powernet()				// update the powernets
	cable_list -= src							//remove it from global cable list
	return ..()

///////////////////////////////////
// General procedures
///////////////////////////////////

//If underfloor, hide the cable
/obj/structure/cable/hide(i)

	if(level == 1 && istype(loc, /turf))
		invisibility = i ? 101 : 0
	updateicon()

/obj/structure/cable/proc/updateicon()
	icon_state = "[d1]-[d2]"
	alpha = invisibility ? 127 : 255


// returns the powernet this cable belongs to
/obj/structure/cable/proc/get_powernet()			//TODO: remove this as it is obsolete
	return powernet

//Telekinesis has no effect on a cable
/obj/structure/cable/attack_tk(mob/user)
	return

// Items usable on a cable :
//   - Wirecutters : cut it duh !
//   - Cable coil : merge cables
//   - Multitool : get the power currently passing through the cable
//
/obj/structure/cable/attackby(obj/item/W, mob/user)

	var/turf/T = src.loc
	if(T.intact)
		return

	if(istype(W, /obj/item/weapon/wirecutters))

///// Z-Level Stuff
		if(src.d1 == 12 || src.d2 == 12)
			to_chat(user, "<span class='warning'>You must cut this cable from above.</span>")
			return
///// Z-Level Stuff

		if (shock(user, 50))
			return

		var/atom/newcable
		if(src.d1)	// 0-X cables are 1 unit, X-X cables are 2 units long
			newcable = new/obj/item/weapon/cable_coil(T, 2, color)
		else
			newcable = new/obj/item/weapon/cable_coil(T, 1, color)
		newcable.fingerprintslast = user.key

		for(var/mob/O in viewers(src, null))
			O.show_message("<span class='warning'>[user] cuts the cable.</span>", 1)

///// Z-Level Stuff
		if(src.d1 == 11 || src.d2 == 11)
			var/turf/controllerlocation = locate(1, 1, z)
			for(var/obj/effect/landmark/zcontroller/controller in controllerlocation)
				if(controller.down)
					var/turf/below = locate(src.x, src.y, controller.down_target)
					for(var/obj/structure/cable/c in below)
						if(c.d1 == 12 || c.d2 == 12)
							c.Destroy()
///// Z-Level Stuff

		qdel(src)

		return	// not needed, but for clarity


	else if(istype(W, /obj/item/weapon/cable_coil))
		var/obj/item/weapon/cable_coil/coil = W
		coil.cable_join(src, user)

	else if(istype(W, /obj/item/device/multitool))

		if(powernet && (powernet.avail > 0))		// is it powered?
			to_chat(user, "\red [powernet.avail]W in power network.")

		else
			to_chat(user, "<span class='warning'>The cable is not powered.</span>")

		shock(user, 5, 0.2)

	else
		if (W.flags & CONDUCT)
			shock(user, 50, 0.7)

	src.add_fingerprint(user)

// shock the user with probability prb
/obj/structure/cable/proc/shock(mob/user, prb, siemens_coeff = 1.0)
	if(!prob(prb))
		return 0
	if (electrocute_mob(user, powernet, src, siemens_coeff))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		return 1
	else
		return 0

//explosion handling
/obj/structure/cable/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(50))
				new/obj/item/weapon/cable_coil(src.loc, src.d1 ? 2 : 1, color)
				qdel(src)

		if(3.0)
			if (prob(25))
				new/obj/item/weapon/cable_coil(src.loc, src.d1 ? 2 : 1, color)
				qdel(src)
	return

/obj/structure/cable/proc/cableColor(colorC)
	switch(colorC)
		if("red")
			color = COLOR_RED
		if("yellow")
			color = COLOR_YELLOW
		if("green")
			color = COLOR_GREEN
		if("blue")
			color = COLOR_BLUE
		if("pink")
			color = COLOR_PINK
		if("orange")
			color = COLOR_ORANGE
		if("cyan")
			color = COLOR_CYAN
		if("white")
			color = COLOR_WHITE

////////////////////////////////////////////
// Power related
///////////////////////////////////////////

/obj/structure/cable/proc/add_avail(amount)
	if(powernet)
		powernet.newavail += amount

/obj/structure/cable/proc/add_load(amount)
	if(powernet)
		powernet.newload += amount

/obj/structure/cable/proc/surplus()
	if(powernet)
		return powernet.avail-powernet.load
	else
		return 0

/obj/structure/cable/proc/avail()
	if(powernet)
		return powernet.avail
	else
		return 0

/////////////////////////////////////////////////
// Cable laying helpers
////////////////////////////////////////////////

// merge with the powernets of power objects in the given direction
/obj/structure/cable/proc/mergeConnectedNetworks(direction)
	var/turf/TB
	var/fdir = (!direction)? 0 : turn(direction, 180) //flip the direction, to match with the source position on its turf
	if(!(d1 == direction || d2 == direction)) //if the cable is not pointed in this direction, do nothing
		return
	TB = get_step(src, direction)

	for(var/obj/structure/cable/C in TB)

		if(!C)
			continue

		if(src == C)
			continue

		if(C.d1 == fdir || C.d2 == fdir) //we've got a matching cable in the neighbor turf
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

// merge with the powernets of power objects in the source turf
/obj/structure/cable/proc/mergeConnectedNetworksOnTurf()
	if(!powernet) //if we somehow have no powernet, make one (should not happen for cables)
		var/datum/powernet/newPN = new()
		newPN.add_cable(src)

	for(var/AM in loc)
		if(istype(AM,/obj/structure/cable))
			var/obj/structure/cable/C = AM
			if(C.d1 == 0 && d1==0) //only connected if they are both "nodes"
				if(C.powernet == powernet)	continue
				if(C.powernet)
					merge_powernets(powernet, C.powernet)
				else
					powernet.add_cable(C) //the cable was powernetless, let's just add it to our powernet

		else if(istype(AM,/obj/machinery/power/apc))
			var/obj/machinery/power/apc/N = AM
			if(!N.terminal)	continue // APC are connected through their terminal
			if(N.terminal.powernet)
				merge_powernets(powernet, N.terminal.powernet)
			else
				powernet.add_machine(N.terminal)

		else if(istype(AM,/obj/machinery/power)) //other power machines
			var/obj/machinery/power/M = AM
			if(M.powernet == powernet)	continue
			if(M.powernet)
				merge_powernets(powernet, M.powernet)
			else
				powernet.add_machine(M)

//////////////////////////////////////////////
// Powernets handling helpers
//////////////////////////////////////////////

/obj/structure/cable/proc/get_connections()
	. = list()	// this will be a list of all connected power objects without a powernet
	var/turf/T = loc

	if(d1)	T = get_step(src, d1)
	if(T)	. += power_list(T, src, d1, 1) //only returns these with no powernets

	T = get_step(src, d2)
	if(T)	. += power_list(T, src, d2, 1) //only returns these with no powernets

	return .

// will get both marked and unmarked connections (i.e with or without powernets)
/obj/structure/cable/proc/get_marked_connections()
	. = list()	// this will be a list of all connected power objects
	var/turf/T = loc

	if(d1)	T = get_step(src, d1)
	if(T)	. += power_list(T, src, d1, 0)

	T = get_step(src, d2)
	if(T)	. += power_list(T, src, d2, 0)

	return .

//should be called after placing a cable which extends another cable, creating a "smooth" cable that no longer terminates in the centre of a turf.
//needed as this can, unlike other placements, disconnect cables
/obj/structure/cable/proc/denode()
	var/turf/T1 = loc
	if(!T1) return

	var/list/powerlist = power_list(T1,src,0,0) //find the other cables that ended in the centre of the turf, with or without a powernet
	if(powerlist.len>0)
		var/datum/powernet/PN = new()
		propagate_network(powerlist[1],PN) //propagates the new powernet beginning at the source cable

		if(PN.is_empty()) //can happen with machines made nodeless when smoothing cables
			qdel(PN)

// cut the cable's powernet at this cable and updates the powergrid
/obj/structure/cable/proc/cut_cable_from_powernet()
	var/turf/T1 = loc
	if(!T1)	return

	var/turf/T2
	if(d2)	T2 = get_step(T1, d2)
	if(d1)	T1 = get_step(T1, d1)


	var/list/P_list = power_list(T1, src, d1,0,cable_only = 1)	// what joins on to cut cable...
	P_list += power_list(T2, src, d2,0, cable_only = 1) //...in both directions


	if(P_list.len == 0)//if nothing in both list, then the cable was a lone cable, just delete it and its powernet
		powernet.remove_cable(src)

		for(var/obj/machinery/power/P in T1)//check if it was powering a machine
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network (and delete powernet)
		return


	var/i
	var/obj/structure/cable/Cable_i

	//removes every adjacents cables, from the powernet, except the first found (to save processing)
	//that way we'll know if there was a loop somewhere
	for (i = 2, i <= P_list.len, i++)
		Cable_i = P_list[i]
		powernet.remove_cable(Cable_i)

	// remove the cut cable from its turf and powernet, so that it doesn't get count in propagate_network worklist
	loc = null
	powernet.remove_cable(src) //remove the cut cable from its powernet

	for (i = 2, i <= P_list.len, i++) // propagate network to every powernetless adjacents cables
		Cable_i = P_list[i]
		if(Cable_i.powernet == null) //if not null, there was a loop and the cable is already part of a powernet
			var/datum/powernet/newPN = new()
			propagate_network(P_list[i], newPN)

	// Disconnect machines connected to nodes
	if(d1 == 0) // if we cut a node (O-X) cable
		for(var/obj/machinery/power/P in T1)
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network

///////////////////////////////////////////////
// The cable coil object, used for laying cable
///////////////////////////////////////////////

////////////////////////////////
// Definitions
////////////////////////////////

#define MAXCOIL 30

/obj/item/weapon/cable_coil
	name = "cable coil"
	icon = 'icons/obj/power.dmi'
	icon_state = "coil"
	var/amount = MAXCOIL
	var/max_amount = MAXCOIL
	item_color = COLOR_RED
	desc = "A coil of power cable."
	throwforce = 10
	w_class = 2.0
	throw_speed = 2
	throw_range = 5
	m_amt = 50
	g_amt = 20
	flags = CONDUCT
	slot_flags = SLOT_BELT
	item_state = "coil"
	attack_verb = list("whipped", "lashed", "disciplined", "flogged")

	suicide_act(mob/user)
		to_chat(viewers(user), "<span class='warning'><b>[user] is strangling \himself with the [src.name]! It looks like \he's trying to commit suicide.</b></span>")
		return(OXYLOSS)

/obj/item/weapon/cable_coil/cyborg
	max_amount = 50
	m_amt = 0
	g_amt = 0

/obj/item/weapon/cable_coil/New(loc, amount = max_amount, var/param_color = null)
	..()
	src.amount = amount
	if (param_color)
		item_color = param_color
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()
	update_wclass()

///////////////////////////////////
// General procedures
///////////////////////////////////

//you can use wires to heal robotics
/obj/item/weapon/cable_coil/attack(mob/M, mob/user)
	if(hasorgans(M))

		var/datum/organ/external/S = M:get_organ(user.zone_sel.selecting)
		if(!(S.status & ORGAN_ROBOT) || user.a_intent != "help")
			return ..()

		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.species.flags[IS_SYNTHETIC])
				if(M == user)
					to_chat(user, "\red You can't repair damage to your own body - it's against OH&S.")
					return

		if(S.burn_dam > 0)
			if(use(1))
				S.heal_damage(0,15,0,1)
				user.visible_message("\red \The [user] repairs some burn damage on \the [M]'s [S.display_name] with \the [src].")
				return
			else
				to_chat(user, "Need more cable!")
		else
			to_chat(user, "Nothing to fix!")


	else
		return ..()

/obj/item/weapon/cable_coil/update_icon()
	if(!color)
		color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_ORANGE, COLOR_WHITE, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN)
		item_color = color
	if(amount == 1)
		icon_state = "coil1"
		name = "cable piece"
	else if(amount == 2)
		icon_state = "coil2"
		name = "cable piece"
	else
		icon_state = "coil"
		name = "cable coil"

/obj/item/weapon/cable_coil/proc/update_wclass()
	if(amount == 1)
		w_class = 1.0
	else
		w_class = 2.0


/obj/item/weapon/cable_coil/examine(mob/user)
	..()
	if(src in view(1, user))
		if(amount == 1)
			to_chat(user, "A short piece of power cable.")
		else if(amount == 2)
			to_chat(user, "A piece of power cable.")
		else
			to_chat(user, "A coil of power cable. There are [amount] lengths of cable in the coil.")


/obj/item/weapon/cable_coil/verb/make_restraint()
	set name = "Make Cable Restraints"
	set category = "Object"
	var/mob/M = usr

	if(ishuman(M) && !M.restrained() && !M.stat && !M.paralysis && ! M.stunned)
		if(!istype(usr.loc,/turf)) return
		if(!src.use(15))
			to_chat(usr, "<span class='warning'>You need at least 15 lengths to make restraints!</span>")
			return
		var/obj/item/weapon/handcuffs/cable/B = new /obj/item/weapon/handcuffs/cable(usr.loc)
		B.color = item_color
		to_chat(usr, "<span class='notice'>You wind some cable together to make some restraints.</span>")
	else
		to_chat(usr, "<span class='notice'>\blue You cannot do that.</span>")
	..()

// Items usable on a cable coil :
//   - Wirecutters : cut them duh !
//   - Cable coil : merge cables
/obj/item/weapon/cable_coil/attackby(obj/item/weapon/W, mob/user)
	..()
	if( istype(W, /obj/item/weapon/wirecutters) && src.use(1))
		new/obj/item/weapon/cable_coil(user.loc, 1,item_color)
		to_chat(user, "<span class='notice'>You cut a piece off the cable coil.</span>")
		src.update_icon()
		src.update_wclass()
		return

	else if( istype(W, /obj/item/weapon/cable_coil) )
		var/obj/item/weapon/cable_coil/C = W
		if(C.amount == C.max_amount)
			to_chat(user, "<span class='notice'>The coil is too long, you cannot add any more cable to it.</span>")
			return

		if( (C.amount + src.amount <= C.max_amount) )
			C.give(src.amount)
			to_chat(user, "<span class='notice'>You join the cable coils together.</span>")
			qdel(src)
			return
		else
			to_chat(user, "<span class='notice'>You transfer [C.max_amount - C.amount ] length\s of cable from one coil to the other.</span>")
			src.use(C.max_amount-C.amount)
			C.give(C.max_amount-C.amount)
			return

//remove cables from the stack
/obj/item/weapon/cable_coil/proc/use(used)
	if(src.amount < used)
		return 0
	else
		amount -= used
		if ((src.amount <= 0) && !istype(loc,/obj/item/weapon/robot_module) && !istype(loc,/mob/living/silicon))
			. = 1
			qdel(src)
		else
			update_icon()
			update_wclass()
		return 1

//add cables to the stack
/obj/item/weapon/cable_coil/proc/give(extra)
	if(amount + extra > max_amount)
		amount = max_amount
	else
		amount += extra
	update_icon()
	update_wclass()

///////////////////////////////////////////////
// Cable laying procedures
//////////////////////////////////////////////

// called when cable_coil is clicked on a turf/simulated/floor
/obj/item/weapon/cable_coil/proc/turf_place(turf/simulated/floor/F, mob/user)
	if(!isturf(user.loc))
		return

	if(!use(1))
		to_chat(user, "<span class='warning'>You need more cable.</span>")
		return

	if(get_dist(F,user) > 1) //too far
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away.</span>")
		return

	if(F.intact)		// if floor is intact, complain
		to_chat(user, "<span class='warning'>You can't lay cable there unless the floor tiles are removed.</span>")
		return

	else
		var/dirn

		if(user.loc == F)
			dirn = user.dir			// if laying on the tile we're on, lay in the direction we're facing
		else
			dirn = get_dir(F, user)

		for(var/obj/structure/cable/LC in F)
			if((LC.d1 == dirn && LC.d2 == 0 ) || ( LC.d2 == dirn && LC.d1 == 0))
				to_chat(user, "<span class='warning'>There's already a cable at that position.</span>")
				return
///// Z-Level Stuff
		// check if the target is open space
		if(istype(F, /turf/simulated/floor/open))
			for(var/obj/structure/cable/LC in F)
				if((LC.d1 == dirn && LC.d2 == 11 ) || ( LC.d2 == dirn && LC.d1 == 11))
					to_chat(user, "<span class='warning'>There's already a cable at that position.</span>")
					return

			var/turf/simulated/floor/open/temp = F
			var/obj/structure/cable/C = new(F)
			var/obj/structure/cable/D = new(temp.floorbelow)

			C.cableColor(item_color)

			C.d1 = 11
			C.d2 = dirn
			C.add_fingerprint(user)
			C.updateicon()

			C.powernet = new()
			powernets += C.powernet
			C.powernet.cables += C

			C.mergeConnectedNetworks(C.d2)
			C.mergeConnectedNetworksOnTurf()

			D.cableColor(item_color)

			D.d1 = 12
			D.d2 = 0
			D.add_fingerprint(user)
			D.updateicon()

			D.powernet = C.powernet
			D.powernet.cables += D

			D.mergeConnectedNetworksOnTurf()

		// do the normal stuff
		else
///// Z-Level Stuff

			for(var/obj/structure/cable/LC in F)
				if((LC.d1 == dirn && LC.d2 == 0 ) || ( LC.d2 == dirn && LC.d1 == 0))
					to_chat(user, "There's already a cable at that position.")
					return

			var/obj/structure/cable/C = new(F)

			C.cableColor(item_color)

			//set up the new cable
			C.d1 = 0 //it's a O-X node cable
			C.d2 = dirn
			C.add_fingerprint(user)
			C.updateicon()

			//create a new powernet with the cable, if needed it will be merged later
			var/datum/powernet/PN = new()
			PN.add_cable(C)

			C.mergeConnectedNetworks(C.d2) //merge the powernet with adjacents powernets
			C.mergeConnectedNetworksOnTurf() //merge the powernet with on turf powernets

			if (C.shock(user, 50))
				if (prob(50)) //fail
					new/obj/item/weapon/cable_coil(C.loc, 1, C.color)
					qdel(C)


// called when cable_coil is click on an installed obj/cable
// or click on a turf that already contains a "node" cable
/obj/item/weapon/cable_coil/proc/cable_join(obj/structure/cable/C, mob/user)
	var/turf/U = user.loc
	if(!isturf(U))
		return

	var/turf/T = C.loc

	if(!isturf(T) || T.intact)		// sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if(get_dist(C, user) > 1)		// make sure it's close enough
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away.</span>")
		return


	if(U == T) //if clicked on the turf we're standing on, try to put a cable in the direction we're facing
		turf_place(T,user)
		return

	var/dirn = get_dir(C, user)

	// one end of the clicked cable is pointing towards us
	if(C.d1 == dirn || C.d2 == dirn)
		if(U.intact)						// can't place a cable if the floor is complete
			to_chat(user, "<span class='warning'>You can't lay cable there unless the floor tiles are removed.</span>")
			return
		else
			// cable is pointing at us, we're standing on an open tile
			// so create a stub pointing at the clicked cable on our tile

			var/fdirn = turn(dirn, 180)		// the opposite direction

			for(var/obj/structure/cable/LC in U)		// check to make sure there's not a cable there already
				if(LC.d1 == fdirn || LC.d2 == fdirn)
					to_chat(user, "<span class='warning'>There's already a cable at that position.</span>")
					return

			if(!use(1))
				return

			var/obj/structure/cable/NC = new(U)
			NC.cableColor(item_color)

			NC.d1 = 0
			NC.d2 = fdirn
			NC.add_fingerprint()
			NC.updateicon()

			//create a new powernet with the cable, if needed it will be merged later
			var/datum/powernet/newPN = new()
			newPN.add_cable(NC)

			NC.mergeConnectedNetworks(NC.d2) //merge the powernet with adjacents powernets
			NC.mergeConnectedNetworksOnTurf() //merge the powernet with on turf powernets

			if (NC.shock(user, 50))
				if (prob(50)) //fail
					new/obj/item/weapon/cable_coil(NC.loc, 1, NC.color)
					qdel(NC)

			return

	// exisiting cable doesn't point at our position, so see if it's a stub
	else if(C.d1 == 0)
							// if so, make it a full cable pointing from it's old direction to our dirn
		var/nd1 = C.d2	// these will be the new directions
		var/nd2 = dirn


		if(nd1 > nd2)		// swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2


		for(var/obj/structure/cable/LC in T)		// check to make sure there's no matching cable
			if(LC == C)			// skip the cable we're interacting with
				continue
			if((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1) )	// make sure no cable matches either direction
				to_chat(user, "<span class='warning'>There's already a cable at that position.</span>")
				return

		if(!use(1))
			to_chat(user, "<span class='warning'>Need more cable.</span>")
			return

		C.cableColor(item_color)

		C.d1 = nd1
		C.d2 = nd2

		C.add_fingerprint()
		C.updateicon()


		C.mergeConnectedNetworks(C.d1) //merge the powernets...
		C.mergeConnectedNetworks(C.d2) //...in the two new cable directions
		C.mergeConnectedNetworksOnTurf()

		if (C.shock(user, 50))
			if (prob(50)) //fail
				new/obj/item/weapon/cable_coil(C.loc, 2, C.color)
				qdel(C)
				return

		C.denode()// this may have disconnected some cables that terminated on the centre of the turf, disconnect them.
		return

//////////////////////////////
// Misc.
/////////////////////////////

/obj/item/weapon/cable_coil/cut
	item_state = "coil2"

/obj/item/weapon/cable_coil/cut/New(loc)
	..()
	src.amount = rand(1,2)
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()
	update_wclass()

/obj/item/weapon/cable_coil/yellow
	item_color = COLOR_YELLOW

/obj/item/weapon/cable_coil/blue
	item_color = COLOR_BLUE

/obj/item/weapon/cable_coil/green
	item_color = COLOR_GREEN

/obj/item/weapon/cable_coil/pink
	item_color = COLOR_PINK

/obj/item/weapon/cable_coil/orange
	item_color = COLOR_ORANGE

/obj/item/weapon/cable_coil/cyan
	item_color = COLOR_CYAN

/obj/item/weapon/cable_coil/white
	item_color = COLOR_WHITE

/obj/item/weapon/cable_coil/random/New()
	item_color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_WHITE, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN)
	..()
