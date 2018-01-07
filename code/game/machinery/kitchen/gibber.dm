
/obj/machinery/gibber
	name = "Gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = TRUE
	anchored = TRUE
	use_power = 1
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
	overlays += image('icons/obj/kitchen.dmi', "grjam")
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
	overlays.Cut()
	if (dirty)
		src.overlays += image('icons/obj/kitchen.dmi', "grbloody")
	if(stat & (NOPOWER|BROKEN))
		return
	if (!occupant)
		src.overlays += image('icons/obj/kitchen.dmi', "grjam")
	else if (operating)
		src.overlays += image('icons/obj/kitchen.dmi', "gruse")
	else
		src.overlays += image('icons/obj/kitchen.dmi', "gridle")

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
	if(user.stat || user.restrained())
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
	user.visible_message("\red [user] starts to put [victim] into the gibber!")
	src.add_fingerprint(user)
	if(do_after(user, 30, target = src) && victim.Adjacent(src) && user.Adjacent(src) && victim.Adjacent(user) && !occupant)
		user.visible_message("\red [user] stuffs [victim] into the gibber!")
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

	if (usr.stat != CONSCIOUS)
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
	playsound(src.loc, 'sound/effects/gibber.ogg', 100, 1)

	var/slab_name = occupant.name
	var/slab_count = 3
	var/slab_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	var/slab_nutrition = src.occupant.nutrition / 15

/*	// Some mobs have specific meat item types.
	if(istype(src.occupant,/mob/living/simple_animal))
		var/mob/living/simple_animal/critter = src.occupant
		if(critter.meat_amount)
			slab_count = critter.meat_amount
		if(critter.meat_type)
			slab_type = critter.meat_type
	else if(istype(src.occupant,/mob/living/carbon/human))
		slab_name = src.occupant.real_name
		slab_type = /obj/item/weapon/reagent_containers/food/snacks/meat/human
	else if(istype(src.occupant, /mob/living/carbon/monkey))
		slab_type = /obj/item/weapon/reagent_containers/food/snacks/meat/monkey
*/
	// Small mobs don't give as much nutrition.
	if(src.occupant.small)
		slab_nutrition *= 0.5
	slab_nutrition /= slab_count

	spawn(gibtime)
		for(var/i=1 to slab_count)
			var/obj/item/weapon/reagent_containers/food/snacks/meat/new_meat = new slab_type(get_turf(get_step(src, 8)))
			new_meat.name = "[slab_name] [new_meat.name]"
			new_meat.reagents.add_reagent("nutriment",slab_nutrition)

			if(src.occupant.reagents)
				src.occupant.reagents.trans_to(new_meat, round(occupant.reagents.total_volume/slab_count,1))

		src.occupant.attack_log += "\[[time_stamp()]\] Was gibbed by <b>[user]/[user.ckey]</b>" //One shall not simply gib a mob unnoticed!
		user.attack_log += "\[[time_stamp()]\] Gibbed <b>[src.occupant]/[src.occupant.ckey]</b>"
		msg_admin_attack("[user.name] ([user.ckey]) gibbed [src.occupant] ([src.occupant.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		src.occupant.ghostize(bancheck = TRUE)

		src.operating = 0
		src.occupant.gib()
		qdel(src.occupant)
		src.occupant = null

		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
		operating = 0
		for (var/obj/item/thing in contents)
			thing.loc = get_turf(thing) // Drop it onto the turf for throwing.
			thing.throw_at(get_edge_target_turf(src,gib_throw_dir),rand(1,5),15) // Being pelted with bits of meat and bone would hurt.

		pixel_x = initial(pixel_x) //return to it's spot after shaking
		update_icon()


