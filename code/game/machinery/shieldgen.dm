/obj/machinery/shield
		name = "Emergency energy shield"
		desc = "An energy shield used to contain hull breaches."
		icon = 'icons/effects/effects.dmi'
		icon_state = "shield-old"
		density = 1
		opacity = 0
		anchored = 1
		unacidable = 1
		var/const/max_health = 200
		var/health = max_health //The shield can only take so much beating (prevents perma-prisons)

/obj/machinery/shield/atom_init()
	set_dir(pick(1,2,3,4))
	. = ..()
	update_nearby_tiles(need_rebuild = 1)

/obj/machinery/shield/Destroy()
	opacity = 0
	density = 0
	update_nearby_tiles()
	return ..()

/obj/machinery/shield/CanPass(atom/movable/mover, turf/target, height, air_group)
	if(!height || air_group) return 0
	else return ..()

/obj/machinery/shield/attackby(obj/item/weapon/W, mob/user)
	if(!istype(W)) return

	//Calculate damage
	var/aforce = W.force
	if(W.damtype == BRUTE || W.damtype == BURN)
		src.health -= aforce

	//Play a fitting sound
	playsound(src, 'sound/effects/EMPulse.ogg', VOL_EFFECTS_MASTER)

	user.SetNextMove(CLICK_CD_MELEE)
	if (src.health <= 0)
		visible_message("<span class='notice'>The [src] dissipates!</span>")
		qdel(src)
		return

	opacity = 1
	spawn(20) if(src) opacity = 0

	..()

/obj/machinery/shield/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	if(health <=0)
		visible_message("<span class='notice'>The [src] dissipates!</span>")
		qdel(src)
		return
	opacity = 1
	spawn(20) if(src) opacity = 0

/obj/machinery/shield/ex_act(severity)
	switch(severity)
		if(1.0)
			if (prob(75))
				qdel(src)
		if(2.0)
			if (prob(50))
				qdel(src)
		if(3.0)
			if (prob(25))
				qdel(src)
	return

/obj/machinery/shield/emp_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				qdel(src)

/obj/machinery/shield/blob_act()
	qdel(src)


/obj/machinery/shield/hitby(atom/movable/AM, datum/thrownthing/throwingdatum)
	//Let everyone know we've been hit!
	visible_message("<span class='warning'><B>[src] was hit by [AM].</B></span>")

	//Super realistic, resource-intensive, real-time damage calculations.
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else
		tforce = AM:throwforce

	src.health -= tforce

	//This seemed to be the best sound for hitting a force field.
	playsound(src, 'sound/effects/EMPulse.ogg', VOL_EFFECTS_MASTER)

	//Handle the destruction of the shield
	if (src.health <= 0)
		visible_message("<span class='notice'>The [src] dissipates!</span>")
		qdel(src)
		return

	//The shield becomes dense to absorb the blow.. purely asthetic.
	opacity = 1
	spawn(20) if(src) opacity = 0

	..()
	return



/obj/machinery/shieldgen
	name = "Emergency shield projector"
	desc = "Used to seal minor hull breaches."
	icon = 'icons/obj/objects.dmi'
	icon_state = "shieldoff"
	density = TRUE
	opacity = FALSE
	anchored = FALSE
	req_access = list(access_engine)
	var/const/max_health = 100
	var/health = max_health
	var/active = FALSE
	var/malfunction = FALSE //Malfunction causes parts of the shield to slowly dissapate
	var/list/deployed_shields = list()
	var/is_open = FALSE //Whether or not the wires are exposed
	var/locked = FALSE

/obj/machinery/shieldgen/Destroy()
	for(var/obj/machinery/shield/shield_tile in deployed_shields)
		deployed_shields -= shield_tile
		qdel(shield_tile)
	return ..()


/obj/machinery/shieldgen/proc/shields_up()
	if(active) return 0 //If it's already turned on, how did this get called?

	src.active = 1
	update_icon()

	for(var/turf/target_tile in range(2, src))
		if (istype(target_tile,/turf/space) && !(locate(/obj/machinery/shield) in target_tile))
			if (malfunction && prob(33) || !malfunction)
				deployed_shields += new /obj/machinery/shield(target_tile)

/obj/machinery/shieldgen/proc/shields_down()
	if(!active) return 0 //If it's already off, how did this get called?

	src.active = 0
	update_icon()

	for(var/obj/machinery/shield/shield_tile in deployed_shields)
		deployed_shields -= shield_tile
		qdel(shield_tile)

/obj/machinery/shieldgen/process()
	if(malfunction && active)
		if(deployed_shields.len && prob(5))
			qdel(pick(deployed_shields))

	return

/obj/machinery/shieldgen/proc/checkhp()
	if(health <= 30)
		src.malfunction = 1
	if(health <= 0)
		qdel(src)
	update_icon()
	return

/obj/machinery/shieldgen/ex_act(severity)
	switch(severity)
		if(1.0)
			src.health -= 75
			src.checkhp()
		if(2.0)
			src.health -= 30
			if (prob(15))
				src.malfunction = 1
			src.checkhp()
		if(3.0)
			src.health -= 10
			src.checkhp()
	return

/obj/machinery/shieldgen/emp_act(severity)
	switch(severity)
		if(1)
			src.health /= 2 //cut health in half
			malfunction = 1
			locked = pick(0,1)
		if(2)
			if(prob(50))
				src.health *= 0.3 //chop off a third of the health
				malfunction = 1
	checkhp()

/obj/machinery/shieldgen/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(locked && !IsAdminGhost(user))
		to_chat(user, "The machine is locked, you are unable to use it.")
		return 1
	if(is_open)
		to_chat(user, "The panel must be closed before operating this machine.")
		return 1
	user.SetNextMove(CLICK_CD_INTERACT)
	if (src.active)
		user.visible_message("<span class='notice'>[bicon(src)] [user] deactivated the shield generator.</span>", \
			"<span class='notice'>[bicon(src)] You deactivate the shield generator.</span>", \
			"You hear heavy droning fade out.")
		src.shields_down()
	else
		if(anchored)
			user.visible_message("<span class='notice'>[bicon(src)] [user] activated the shield generator.</span>", \
				"<span class='notice'>[bicon(src)] You activate the shield generator.</span>", \
				"You hear heavy droning.")
			src.shields_up()
		else
			to_chat(user, "The device must first be secured to the floor.")

/obj/machinery/shieldgen/attackby(obj/item/weapon/W, mob/user)
	if(isscrewdriver(W))
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		if(is_open)
			to_chat(user, "<span class='notice'>You close the panel.</span>")
			is_open = 0
		else
			to_chat(user, "<span class='notice'>You open the panel and expose the wiring.</span>")
			is_open = 1

	else if(iscoil(W) && malfunction && is_open)
		var/obj/item/stack/cable_coil/coil = W
		if(user.is_busy(src)) return
		to_chat(user, "<span class='notice'>You begin to replace the wires.</span>")
		//if(do_after(user, min(60, round( ((maxhealth/health)*10)+(malfunction*10) ))) //Take longer to repair heavier damage
		if(coil.use_tool(src, user, 30, amount = 1, volume = 50))
			health = max_health
			malfunction = 0
			to_chat(user, "<span class='notice'>You repair the [src]!</span>")
			update_icon()

	else if(iswrench(W))
		if(locked)
			to_chat(user, "The bolts are covered, unlocking this would retract the covers.")
			return
		if(anchored)
			to_chat(user, "<span class='notice'>You unsecure the [src] from the floor!</span>")
			if(active)
				to_chat(user, "<span class='notice'>The [src] shuts off!</span>")
				src.shields_down()
			anchored = 0
		else
			if(istype(get_turf(src), /turf/space)) return //No wrenching these in space!
			to_chat(user, "<span class='notice'>You secure the [src] to the floor!</span>")
			anchored = 1


	else if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(src.allowed(user))
			src.locked = !src.locked
			to_chat(user, "The controls are now [src.locked ? "locked." : "unlocked."]")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

	else
		..()

/obj/machinery/shieldgen/emag_act(mob/user)
	if(malfunction)
		return FALSE
	malfunction = 1
	user.SetNextMove(CLICK_CD_MELEE)
	update_icon()
	return TRUE

/obj/machinery/shieldgen/update_icon()
	if(active)
		src.icon_state = malfunction ? "shieldonbr":"shieldon"
	else
		src.icon_state = malfunction ? "shieldoffbr":"shieldoff"
	return

////FIELD GEN START //shameless copypasta from fieldgen, powersink, and grille
#define maxstoredpower 500
/obj/machinery/shieldwallgen
	name = "Shield Generator"
	desc = "A shield generator."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "Shield_Gen"
	anchored = FALSE
	density = TRUE
	req_access = list(access_research)
	flags = CONDUCT
	use_power = NO_POWER_USE
	var/active = FALSE
	var/power = 0
	var/state = 0
	var/steps = 0
	var/last_check = 0
	var/check_delay = 10
	var/recalc = 0
	var/locked = TRUE
	var/destroyed = FALSE
	var/obj/structure/cable/attached		// the attached cable
	var/storedpower = 0

/obj/machinery/shieldwallgen/proc/power()
	if(!anchored)
		power = 0
		return 0
	var/turf/T = src.loc

	var/obj/structure/cable/C = T.get_cable_node()
	var/datum/powernet/PN
	if(C)	PN = C.powernet		// find the powernet of the connected cable

	if(!PN)
		power = 0
		return 0

	var/surplus = max(PN.avail-PN.load, 0)
	var/shieldload = min(rand(50,200), surplus)
	if(shieldload==0 && !storedpower)		// no cable or no power, and no power stored
		power = 0
		return 0
	else
		power = 1	// IVE GOT THE POWER!
		if(PN) //runtime errors fixer. They were caused by PN.newload trying to access missing network in case of working on stored power.
			storedpower += shieldload
			PN.newload += shieldload //uses powernet power.
//		message_admins("[PN.load]", 1)
//		use_power(250) //uses APC power

/obj/machinery/shieldwallgen/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(state != 1)
		to_chat(user, "<span class='warning'>The shield generator needs to be firmly secured to the floor first.</span>")
		return 1
	if(src.locked && !issilicon(user) && !IsAdminGhost(user))
		to_chat(user, "<span class='warning'>The controls are locked!</span>")
		return 1
	if(power != 1)
		to_chat(user, "<span class='warning'>The shield generator needs to be powered by wire underneath.</span>")
		return 1

	user.SetNextMove(CLICK_CD_INTERACT)
	if(src.active >= 1)
		src.active = 0
		icon_state = "Shield_Gen"

		user.visible_message("[user] turned the shield generator off.", \
			"You turn off the shield generator.", \
			"You hear heavy droning fade out.")
		for(var/dir in list(1,2,4,8)) src.cleanup(dir)
	else
		src.active = 1
		icon_state = "Shield_Gen +a"
		user.visible_message("[user] turned the shield generator on.", \
			"You turn on the shield generator.", \
			"You hear heavy droning.")

/obj/machinery/shieldwallgen/process()
	spawn(100)
		power()
		if(power)
			storedpower -= 50 //this way it can survive longer and survive at all
	if(storedpower >= maxstoredpower)
		storedpower = maxstoredpower
	if(storedpower <= 0)
		storedpower = 0
//	if(shieldload >= maxshieldload) //there was a loop caused by specifics of process(), so this was needed.
//		shieldload = maxshieldload

	if(src.active == 1)
		if(!src.state == 1)
			src.active = 0
			return
		spawn(1)
			setup_field(1)
		spawn(2)
			setup_field(2)
		spawn(3)
			setup_field(4)
		spawn(4)
			setup_field(8)
		src.active = 2
	if(src.active >= 1)
		if(src.power == 0)
			src.visible_message("<span class='warning'>The [src.name] shuts down due to lack of power!</span>", \
				"You hear heavy droning fade out")
			icon_state = "Shield_Gen"
			src.active = 0
			for(var/dir in list(1,2,4,8)) src.cleanup(dir)

/obj/machinery/shieldwallgen/proc/setup_field(NSEW = 0)
	var/turf/T = src.loc
	var/turf/T2 = src.loc
	var/obj/machinery/shieldwallgen/G
	var/steps = 0
	var/oNSEW = 0

	if(!NSEW)//Make sure its ran right
		return

	if(NSEW == 1)
		oNSEW = 2
	else if(NSEW == 2)
		oNSEW = 1
	else if(NSEW == 4)
		oNSEW = 8
	else if(NSEW == 8)
		oNSEW = 4

	for(var/dist = 0, dist <= 9, dist += 1) // checks out to 8 tiles away for another generator
		T = get_step(T2, NSEW)
		T2 = T
		steps += 1
		if(locate(/obj/machinery/shieldwallgen) in T)
			G = (locate(/obj/machinery/shieldwallgen) in T)
			steps -= 1
			if(!G.active)
				return
			G.cleanup(oNSEW)
			break

	if(isnull(G))
		return

	T2 = src.loc

	for(var/dist = 0, dist < steps, dist += 1) // creates each field tile
		var/field_dir = get_dir(T2,get_step(T2, NSEW))
		T = get_step(T2, NSEW)
		T2 = T
		var/obj/machinery/shieldwall/CF = new/obj/machinery/shieldwall/(src, G) //(ref to this gen, ref to connected gen)
		CF.loc = T
		CF.set_dir(field_dir)


/obj/machinery/shieldwallgen/attackby(obj/item/W, mob/user)
	if(iswrench(W))
		if(active)
			to_chat(user, "Turn off the field generator first.")
			return
		if(state == 0)
			state = 1
			playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "You secure the external reinforcing bolts to the floor.")
			src.anchored = 1
			return

		else if(state == 1)
			state = 0
			playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "You undo the external reinforcing bolts.")
			src.anchored = 0
			return

	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (src.allowed(user))
			src.locked = !src.locked
			to_chat(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

	else
		src.add_fingerprint(user)
		visible_message("<span class='warning'>The [src.name] has been hit with \the [W.name] by [user.name]!</span>")
		user.SetNextMove(CLICK_CD_MELEE)

/obj/machinery/shieldwallgen/proc/cleanup(NSEW)
	var/obj/machinery/shieldwall/F
	var/obj/machinery/shieldwallgen/G
	var/turf/T = src.loc
	var/turf/T2 = src.loc

	for(var/dist = 0, dist <= 9, dist += 1) // checks out to 8 tiles away for fields
		T = get_step(T2, NSEW)
		T2 = T
		if(locate(/obj/machinery/shieldwall) in T)
			F = (locate(/obj/machinery/shieldwall) in T)
			qdel(F)

		if(locate(/obj/machinery/shieldwallgen) in T)
			G = (locate(/obj/machinery/shieldwallgen) in T)
			if(!G.active)
				break

/obj/machinery/shieldwallgen/Destroy()
	src.cleanup(1)
	src.cleanup(2)
	src.cleanup(4)
	src.cleanup(8)
	attached = null
	return ..()

/obj/machinery/shieldwallgen/bullet_act(obj/item/projectile/Proj)
	storedpower -= Proj.damage
	..()
	return


//////////////Containment Field START
/obj/machinery/shieldwall
		name = "energy shield"
		desc = "An energy shield."
		icon = 'icons/effects/effects.dmi'
		icon_state = "energyshield"
		anchored = 1
		density = 1
		layer = INFRONT_MOB_LAYER
		unacidable = 1
		light_range = 3
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		var/needs_power = 0
		var/active = 1
//		var/power = 10
		var/delay = 5
		var/last_active
		var/mob/U
		var/obj/machinery/shieldwallgen/gen_primary
		var/obj/machinery/shieldwallgen/gen_secondary

/obj/machinery/shieldwall/atom_init(mapload, obj/machinery/shieldwallgen/A, obj/machinery/shieldwallgen/B)
	. = ..()
	gen_primary = A
	gen_secondary = B
	if(A && B)
		needs_power = 1

/obj/machinery/shieldwall/attack_hand(mob/user)
	return


/obj/machinery/shieldwall/process()
	if(needs_power)
		if(isnull(gen_primary)||isnull(gen_secondary))
			qdel(src)
			return

		if(!(gen_primary.active)||!(gen_secondary.active))
			qdel(src)
			return
//
		if(prob(50))
			gen_primary.storedpower -= 10
		else
			gen_secondary.storedpower -=10


/obj/machinery/shieldwall/bullet_act(obj/item/projectile/Proj)
	if(needs_power)
		var/obj/machinery/shieldwallgen/G
		if(prob(50))
			G = gen_primary
		else
			G = gen_secondary
		G.storedpower -= Proj.damage
	..()
	return


/obj/machinery/shieldwall/ex_act(severity)
	if(needs_power)
		var/obj/machinery/shieldwallgen/G
		switch(severity)
			if(1.0) //big boom
				if(prob(50))
					G = gen_primary
				else
					G = gen_secondary
				G.storedpower -= 200

			if(2.0) //medium boom
				if(prob(50))
					G = gen_primary
				else
					G = gen_secondary
				G.storedpower -= 50

			if(3.0) //lil boom
				if(prob(50))
					G = gen_primary
				else
					G = gen_secondary
				G.storedpower -= 20
	return


/obj/machinery/shieldwall/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(istype(mover) && mover.checkpass(PASSGLASS))
		if(prob(20))
			if(istype(mover, /obj/item/projectile))
				var/obj/item/projectile/P = mover
				visible_message("<span class='warning'><b>\The [P.name] flies through the \the [src.name].</b></span>")
				P.damage -= 10
			return TRUE
		else
			if(istype(mover, /obj/item/projectile))
				visible_message("<span class='warning'>\The [mover] hits the \the [src.name].</span>")
			return FALSE
	else
		if(istype(mover, /obj/item/projectile))
			var/obj/item/projectile/P = mover
			if(P.damage > 15)
				if(prob(10))
					visible_message("<span class='warning'><b>\The [P.name] flies through the \the [src.name].</span></b>")
					P.damage -= 10
					return TRUE
				else
					visible_message("<span class='warning'>\The [P.name] hits the \the [src.name].</span>")
					return FALSE
			else
				if(prob(5))
					visible_message("<span class='warning'><b>\The [P.name] flies through the \the [src.name].</b></span>")
					P.damage -= P.damage / 2
					return TRUE
				else
					visible_message("<span class='warning'>\The [P.name] hits the \the [src.name].</span>")
					return FALSE
		else
			return !src.density
