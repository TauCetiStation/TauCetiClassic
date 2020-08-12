/obj/machinery/monkey_recycler
	name = "Recycler"
	desc = "A machine used for recycling dead monkeys into monkey cubes. Can also quickly extract cores from dead slimes"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	layer = 2.9
	density = TRUE
	anchored = TRUE
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 50
	var/grinded = 0
	var/required_grind = 5
	var/cube_production = 1
	var/list/connected_consoles = list()

/obj/machinery/monkey_recycler/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/monkey_recycler(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	RefreshParts()

/obj/machinery/monkey_recycler/Destroy()
	for(var/obj/machinery/computer/camera_advanced/xenobio/console in connected_consoles)
		console.connected_recycler = null
	connected_consoles.Cut()
	return ..()

/obj/machinery/monkey_recycler/proc/grind(atom/movable/P, mob/user)
	playsound(src, 'sound/machines/juicer.ogg', VOL_EFFECTS_MASTER)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 200) //start shaking
	use_power(500)
	var/atom/movable/M = P
	M.forceMove(src)		//To hide them from view
	addtimer(CALLBACK(src, .proc/finish_processing,M,user), 50)


/obj/machinery/monkey_recycler/proc/finish_processing(atom/movable/M, mob/user)
	if(ismonkey(M))
		src.grinded++
		to_chat(user, "<span class='notice'>The machine now has [grinded/required_grind] monkeys worth of material stored.</span>")
	else if(isslime(M))
		var/mob/living/carbon/slime/S = M
		var/C = S.cores
		for(var/i in 1 to (C+cube_production-1))		//Can extract many cores if upgraded
			new S.coretype(loc)
	qdel(M)
	pixel_x = initial(pixel_x)

/obj/machinery/monkey_recycler/RefreshParts()
	var/req_grind = 5
	var/cubes_made = 1
	for(var/obj/item/weapon/stock_parts/manipulator/B in component_parts)
		req_grind -= B.rating
		if(req_grind <= 0)
			req_grind = 1
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		cubes_made = M.rating
	cube_production = cubes_made
	required_grind = req_grind
	desc = "A machine used for recycling dead monkeys into monkey cubes. It currently produces [cubes_made] cube(s) for every [required_grind] monkey(s) inserted. Can also quickly extract cores from dead slimes."

/obj/machinery/monkey_recycler/attackby(obj/item/O, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grinder_open", "grinder", O))
		return

	if(exchange_parts(user, O))
		return

	if(default_pry_open(O))
		return

	if(default_unfasten_wrench(user, O))
		power_change()
		return

	default_deconstruction_crowbar(O)

	if (src.stat) //NOPOWER etc
		return
	if (istype(O, /obj/item/weapon/holder/monkey))
		var/mob/living/G
		for (var/mob/living/M in O.contents)
			G = M
		if (G.stat == CONSCIOUS)
			to_chat(user, "<span class='warning'>The subject is struggling far too much to put it in the recycler.</span>")
		else
			user.drop_item()
			to_chat(user, "<span class='notice'>You stuff the subject in the machine.</span>")
			grind(O, user)
	if (istype(O, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		var/grabbed = G.affecting
		if(ismonkey(grabbed) || isslime(grabbed))
			var/mob/living/carbon/target = grabbed
			if(target.stat == CONSCIOUS)
				to_chat(user, "<span class='warning'>The subject is struggling far too much to put it in the recycler.</span>")
			else
				user.drop_item()
				to_chat(user, "<span class='notice'>You stuff the subject in the machine.</span>")
				grind(target, user)
		else
			to_chat(user, "<span class='warning'>The machine only accepts monkeys and slimes!</span>")

	if(panel_open)
		if(ismultitool(O))
			var/obj/item/device/multitool/M = O
			M.buffer = src
			to_chat(user, "<span class='notice'>You save the data in the [O.name]'s buffer.</span>")
	return

/obj/machinery/monkey_recycler/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(grinded >= required_grind)
		to_chat(user, "<span class='notice'>The machine hisses loudly as it condenses the grinded monkey meat. After a moment, it dispenses a brand new monkey cube.</span>")
		playsound(src, 'sound/machines/hiss.ogg', VOL_EFFECTS_MASTER)
		grinded -= required_grind
		for(var/i = 0, i < cube_production, i++)
			new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped(loc)
		to_chat(user, "<span class='notice'>The machine's display flashes that it has [grinded] monkeys worth of material left.</span>")
	else
		to_chat(user, "<span class='danger'>The machine needs at least [required_grind] monkey(s) worth of material to produce a monkey cube. It only has [grinded].</span>")
