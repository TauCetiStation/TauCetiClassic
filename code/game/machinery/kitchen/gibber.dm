
/obj/machinery/gibber
	name = "Gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 500
	var/operating = FALSE //Is it on?
	var/dirty = FALSE // Does it need cleaning?
	var/gibtime = 80 // Time from starting until meat appears
	var/gib_throw_dir // Direction to spit meat and gibs in.
	var/meat_produced = 0
	var/ignore_clothing = 0

//auto-gibs anything that bumps into it
/obj/machinery/gibber/autogibber
	var/turf/input_plate

/obj/machinery/gibber/autogibber/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/gibber/autogibber/atom_init_late()
	for(var/i in cardinal)
		var/obj/machinery/mineral/input/input_obj = locate( /obj/machinery/mineral/input, get_step(src.loc, i) )
		if(input_obj)
			if(isturf(input_obj.loc))
				input_plate = input_obj.loc
				qdel(input_obj)
				break

	if(!input_plate)
		log_misc("a [src] didn't find an input plate.")

/obj/machinery/gibber/autogibber/Bumped(atom/A)
	if(!input_plate) return

	if(ismob(A))
		var/mob/M = A

		if(M.loc == input_plate)
			M.loc = src
			M.gib()


/obj/machinery/gibber/atom_init()
	. = ..()
	add_overlay(image('icons/obj/kitchen.dmi', "grjam"))
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/gibber(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/gibber/RefreshParts()
	var/gib_time = initial(gibtime)
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		meat_produced += 3 * B.rating
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		gib_time -= 5 * M.rating
		gibtime = gib_time
		if(M.rating >= 2)
			ignore_clothing = 1

/obj/machinery/gibber/update_icon()
	cut_overlays()
	if (dirty)
		src.add_overlay(image('icons/obj/kitchen.dmi', "grbloody"))
	if(stat & (NOPOWER|BROKEN))
		return
	if (!occupant)
		src.add_overlay(image('icons/obj/kitchen.dmi', "grjam"))
	else if (operating)
		src.add_overlay(image('icons/obj/kitchen.dmi', "gruse"))
	else
		src.add_overlay(image('icons/obj/kitchen.dmi', "gridle"))

/obj/machinery/gibber/container_resist()
	go_out()

/obj/machinery/gibber/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.SetNextMove(CLICK_CD_INTERACT)
	if(operating)
		to_chat(user, "<span class='danger'>The gibber is locked and running, wait for it to finish.</span>")
		return 1
	else
		startgibbing(user)

/obj/machinery/gibber/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/grab))
		src.add_fingerprint(user)
		var/obj/item/weapon/grab/G = W
		move_into_gibber(user, G.affecting)
		qdel(G)

	if(default_deconstruction_screwdriver(user, "grinder_open", "grinder", W))
		return

	if(exchange_parts(user, W))
		return

	if(default_pry_open(W))
		return

	if(default_unfasten_wrench(user, W))
		return


/obj/machinery/gibber/MouseDrop_T(mob/target, mob/user)
	if(user.incapacitated())
		return

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return

	move_into_gibber(user,target)

/obj/machinery/gibber/proc/move_into_gibber(mob/user,mob/living/victim)

	if(src.occupant)
		to_chat(user, "<span class='danger'>The gibber is full, empty it first!</span>")
		return

	if(operating)
		to_chat(user, "<span class='danger'>The gibber is locked and running, wait for it to finish.</span>")
		return

	if(!(iscarbon(victim)) && !(istype(victim, /mob/living/simple_animal)) )
		to_chat(user, "<span class='danger'>This is not suitable for the gibber!</span>")
		return

	if(victim.abiotic(1) && !ignore_clothing)
		to_chat(user, "<span class='danger'>Subject may not have abiotic items on.</span>")
		return
	if(user.is_busy(src)) return
	user.visible_message("<span class='warning'>[user] starts to put [victim] into the gibber!</span>")
	src.add_fingerprint(user)
	if(do_after(user, 30, target = src) && victim.Adjacent(src) && user.Adjacent(src) && victim.Adjacent(user) && !occupant)
		user.visible_message("<span class='warning'>[user] stuffs [victim] into the gibber!</span>")
		if(victim.client)
			victim.client.perspective = EYE_PERSPECTIVE
			victim.client.eye = src
		victim.loc = src
		src.occupant = victim
		update_icon()

/obj/machinery/gibber/verb/eject()
	set category = "Object"
	set name = "Empty Gibber"
	set src in oview(1)

	if (usr.incapacitated())
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/gibber/proc/go_out()
	if(operating || !src.occupant)
		return
	for(var/obj/O in src)
		O.loc = src.loc
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	update_icon()
	return

/obj/machinery/gibber/proc/startgibbing(mob/user)
	if(src.operating)
		return
	if(!src.occupant)
		visible_message("<span class='danger'>You hear a loud metallic grinding sound.</span>")
		return
	use_power(1000)
	visible_message("<span class='danger'>You hear a loud squelchy grinding sound.</span>")
	src.operating = 1
	update_icon()
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = gibtime / 100, loop = gibtime) //start shaking
	playsound(src, 'sound/effects/gibber.ogg', VOL_EFFECTS_MASTER)

	addtimer(CALLBACK(src, .proc/gib_mob, user), gibtime)

/obj/machinery/gibber/proc/gib_mob(mob/user)
	occupant.log_combat(user, "gibbed via [name]")

	occupant.ghostize(bancheck = TRUE)

	occupant.harvest()
	if(!QDELING(occupant))
		qdel(occupant)
	occupant = null

	playsound(src, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER)
	for(var/obj/item/thing in contents)
		thing.forceMove(get_turf(thing)) // Drop it onto the turf for throwing.
		thing.throw_at(get_edge_target_turf(src,gib_throw_dir),rand(1,5),15) // Being pelted with bits of meat and bone would hurt.

	pixel_x = initial(pixel_x) //return to it's spot after shaking
	operating = 0
	update_icon()
