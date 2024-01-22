/obj/machinery/shield
		name = "Emergency energy shield"
		desc = "An energy shield used to contain hull breaches."
		icon = 'icons/effects/effects.dmi'
		icon_state = "shield-old"
		density = TRUE
		opacity = 0
		anchored = TRUE
		can_block_air = TRUE
		unacidable = 1
		max_integrity = 200

/obj/machinery/shield/atom_init()
	set_dir(pick(1,2,3,4))
	. = ..()
	update_nearby_tiles()

/obj/machinery/shield/Destroy()
	opacity = 0
	density = FALSE
	update_nearby_tiles()
	return ..()

/obj/machinery/shield/CanPass(atom/movable/mover, turf/target, height)
	if(!height)
		return FALSE
	return ..()

/obj/machinery/shield/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BURN, BRUTE)
			playsound(loc, 'sound/effects/EMPulse.ogg', VOL_EFFECTS_MASTER, 75, TRUE)

/obj/machinery/shield/deconstruct(disassembled)
	visible_message("<span class='notice'>The [src] dissipates!</span>")
	..()

/obj/machinery/shield/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir)
	. = ..()
	if(!.)
		return
	opacity = TRUE
	VARSET_IN(src, opacity, FALSE, 2 SECONDS)

/obj/machinery/shieldgen
	name = "Emergency shield projector"
	desc = "Used to seal minor hull breaches."
	icon = 'icons/obj/objects.dmi'
	icon_state = "shieldoff"
	density = TRUE
	opacity = FALSE
	anchored = FALSE
	req_access = list(access_engine)
	max_integrity = 200
	var/active = FALSE
	var/malfunction = FALSE //Malfunction causes parts of the shield to slowly dissapate
	var/list/deployed_shields = list()
	var/is_open = FALSE //Whether or not the wires are exposed
	var/locked = FALSE
	required_skills = list(/datum/skill/engineering = SKILL_LEVEL_PRO)

/obj/machinery/shieldgen/Destroy()
	for(var/obj/machinery/shield/shield_tile in deployed_shields)
		deployed_shields -= shield_tile
		qdel(shield_tile)
	return ..()


/obj/machinery/shieldgen/proc/shields_up()
	if(active) return 0 //If it's already turned on, how did this get called?

	src.active = 1
	update_icon()

	for(var/turf/environment/target_tile in range(2, src))
		if (!(locate(/obj/machinery/shield) in target_tile))
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

/obj/machinery/shieldgen/emp_act(severity)
	switch(severity)
		if(1)
			take_damage(get_integrity() * 0.5, BURN, ENERGY)
			malfunction = TRUE
			locked = pick(0, 1)
		if(2)
			if(prob(50))
				take_damage(get_integrity() * 0.3, BURN, ENERGY) //chop off a third of the health
				malfunction = TRUE

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
		shields_down()
	else
		if(anchored)
			user.visible_message("<span class='notice'>[bicon(src)] [user] activated the shield generator.</span>", \
				"<span class='notice'>[bicon(src)] You activate the shield generator.</span>", \
				"You hear heavy droning.")
			shields_up()
		else
			to_chat(user, "The device must first be secured to the floor.")

/obj/machinery/shieldgen/attackby(obj/item/weapon/W, mob/user)
	if(isscrewing(W))
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
		if(!do_skill_checks(user))
			return
		to_chat(user, "<span class='notice'>You begin to replace the wires.</span>")
		if(coil.use_tool(src, user, 30, amount = 1, volume = 50))
			update_integrity(max_integrity)
			malfunction = FALSE
			to_chat(user, "<span class='notice'>You repair the [src]!</span>")
			update_icon()

	else if(iswrenching(W))
		if(locked)
			to_chat(user, "The bolts are covered, unlocking this would retract the covers.")
			return
		if(anchored)
			if(!do_skill_checks(user))
				return
			if(!do_skill_checks(user))
				return
			to_chat(user, "<span class='notice'>You unsecure the [src] from the floor!</span>")
			if(active)
				to_chat(user, "<span class='notice'>The [src] shuts off!</span>")
				shields_down()
			anchored = FALSE
		else
			if(isspaceturf(get_turf(src))) return //No wrenching these in space!
			to_chat(user, "<span class='notice'>You secure the [src] to the floor!</span>")
			anchored = TRUE


	else if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(allowed(user))
			src.locked = !src.locked
			to_chat(user, "The controls are now [src.locked ? "locked." : "unlocked."]")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

	else
		..()

/obj/machinery/shieldgen/atom_break(damage_flag)
	. = ..()
	if(!.)
		return
	locked = FALSE
	malfunction = TRUE
	update_icon()

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
	required_skills = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED)

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

	var/surplus = max(PN.avail - PN.load, 0)
	var/shieldload = min(rand(50,200), surplus)
	if(shieldload==0 && !storedpower)		// no cable or no power, and no power stored
		power = 0
		return 0
	else
		power = 1	// IVE GOT THE POWER!
		if(PN) //runtime errors fixer. They were caused by PN.load trying to access missing network in case of working on stored power.
			storedpower += shieldload
			PN.load += shieldload //uses powernet power.
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
		for(var/dir in list(1,2,4,8)) cleanup(dir)
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
			visible_message("<span class='warning'>The [src.name] shuts down due to lack of power!</span>", \
				"You hear heavy droning fade out")
			icon_state = "Shield_Gen"
			src.active = 0
			for(var/dir in list(1,2,4,8)) cleanup(dir)

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
		var/obj/machinery/shieldwall/CF = new/obj/machinery/shieldwall(src, G) //(ref to this gen, ref to connected gen)
		CF.loc = T
		CF.set_dir(field_dir)


/obj/machinery/shieldwallgen/attackby(obj/item/W, mob/user)
	if(iswrenching(W))
		if(active)
			to_chat(user, "Turn off the field generator first.")
			return
		if(state == 0)
			state = 1
			playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
			if(!do_skill_checks(user))
				return
			to_chat(user, "You secure the external reinforcing bolts to the floor.")
			src.anchored = TRUE
			return

		else if(state == 1)
			state = 0
			playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
			if(!do_skill_checks(user))
				return
			to_chat(user, "You undo the external reinforcing bolts.")
			src.anchored = FALSE
			return

	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (allowed(user))
			src.locked = !src.locked
			to_chat(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

	else
		add_fingerprint(user)
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
	cleanup(1)
	cleanup(2)
	cleanup(4)
	cleanup(8)
	attached = null
	return ..()

/obj/machinery/shieldwallgen/bullet_act(obj/item/projectile/Proj, def_zone)
	. = ..()
	storedpower -= Proj.damage

//////////////Containment Field START
/obj/machinery/shieldwall
		name = "energy shield"
		desc = "An energy shield."
		icon = 'icons/effects/effects.dmi'
		icon_state = "energyshield"
		anchored = TRUE
		density = TRUE
		can_block_air = TRUE
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

		resistance_flags = FULL_INDESTRUCTIBLE

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

/obj/machinery/shieldwall/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BURN, BRUTE)
			playsound(loc, 'sound/effects/EMPulse.ogg', VOL_EFFECTS_MASTER, 75, TRUE)

/obj/machinery/shieldwall/bullet_act(obj/item/projectile/Proj, def_zone)
	. = ..()
	if(needs_power)
		var/obj/machinery/shieldwallgen/G
		if(prob(50))
			G = gen_primary
		else
			G = gen_secondary
		G.storedpower -= Proj.damage

/obj/machinery/shieldwall/ex_act(severity)
	if(needs_power)
		var/obj/machinery/shieldwallgen/G
		if(prob(50))
			G = gen_primary
		else
			G = gen_secondary
		switch(severity)
			if(EXPLODE_DEVASTATE)
				G.storedpower -= 200

			if(EXPLODE_HEAVY) //medium boom
				G.storedpower -= 50

			if(EXPLODE_LIGHT) //lil boom
				G.storedpower -= 20

/obj/machinery/shieldwall/CanPass(atom/movable/mover, turf/target, height=0)
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
