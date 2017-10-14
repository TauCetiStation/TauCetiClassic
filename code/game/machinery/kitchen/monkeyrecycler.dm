/obj/machinery/monkey_recycler
	name = "Monkey Recycler"
	desc = "A machine used for recycling dead monkeys into monkey cubes."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	layer = 2.9
	density = TRUE
	anchored = TRUE
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 50
	ghost_must_be_admin = TRUE
	var/grinded = 0
	var/required_grind = 5
	var/cube_production = 1

/obj/machinery/monkey_recycler/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/monkey_recycler(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	RefreshParts()
	
/obj/machinery/monkey_recycler/proc/grind(var/M, mob/user)
	user.drop_item()
	qdel(M)
	to_chat(user, "\blue You stuff the monkey in the machine.")
	playsound(src.loc, 'sound/machines/juicer.ogg', 50, 1)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 200) //start shaking
	use_power(500)
	src.grinded++
	sleep(50)
	pixel_x = initial(pixel_x)
	to_chat(user, "\blue The machine now has [grinded] monkeys worth of material stored.")

/obj/machinery/monkey_recycler/RefreshParts()
	var/req_grind = 5
	var/cubes_made = 1
	for(var/obj/item/weapon/stock_parts/manipulator/B in component_parts)
		req_grind -= B.rating
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		cubes_made = M.rating
	cube_production = cubes_made
	required_grind = req_grind
	desc = "A machine used for recycling dead monkeys into monkey cubes. It currently produces [cubes_made] cube(s) for every [required_grind] monkey(s) inserted."

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

	if (src.stat != CONSCIOUS) //NOPOWER etc
		return
	if (istype(O, /obj/item/weapon/holder/monkey))
		var/mob/living/G
		for (var/mob/living/M in O.contents)
			G = M
		if (G.stat == CONSCIOUS)
			to_chat(user, "\red The monkey is struggling far too much to put it in the recycler.")
		else
			grind(O, user)
	if (istype(O, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		var/grabbed = G.affecting
		if(ismonkey(grabbed))
			var/mob/living/carbon/monkey/target = grabbed
			if(target.stat == CONSCIOUS)
				to_chat(user, "\red The monkey is struggling far too much to put it in the recycler.")
			else
				grind(target, user)
		else
			to_chat(user, "\red The machine only accepts monkeys!")
	return

/obj/machinery/monkey_recycler/attack_hand(mob/user)
	if (..())
		return
	if(grinded >= required_grind)
		to_chat(user, "\blue The machine hisses loudly as it condenses the grinded monkey meat. After a moment, it dispenses a brand new monkey cube.")
		playsound(src.loc, 'sound/machines/hiss.ogg', 50, 1)
		grinded -= required_grind
		for(var/i = 0, i < cube_production, i++)
			new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped(src.loc)
		to_chat(user, "\blue The machine's display flashes that it has [grinded] monkeys worth of material left.")
	else
		to_chat(user, "<span class='danger'>The machine needs at least [required_grind] monkey(s) worth of material to produce a monkey cube. It only has [grinded].</span>")
	return
