//TODO: refactor this when propper forge system exists (how naive)
/obj/machinery/trash_burner
	name = "Trash Burner"
	desc = "Makeshift scrap refinement at it finest."
	brightness_color = "#a0a080"
	brightness_range = 2
	brightness_power = 1
	var/scrap = 0
	var/max_items = 30

/obj/machinery/trash_burner/attackby(obj/item/W as obj, mob/user as mob)
	if(default_deconstruction_crowbar(I))
		return

	if(lit)
		..()
		return

	if(istype(I, /obj/item/weapon/storage/bag/trash/miners))
		if(max_items > contents.len)
			user << "<span class='notice'>[src] is full.</span>"
			return
		var/obj/item/weapon/storage/bag/trash/T = W
		user << "<span class='notice'>You empty the bag.</span>"
		for(var/obj/item/O in T.contents)
			T.remove_from_storage(O,src)
		T.update_icon()
		return

	if(istype(I, /obj/item/weapon/scrap_lump))
		if(max_items > contents.len)
			user << "<span class='notice'>[src] is full.</span>"
			return
		user.drop_item()
		if(W)
			W.loc = src
		return
	//TODO: Refactor this copypaste
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.isOn())
			light()
	else if(istype(W, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/L = W
		if(L.lit)
			light()
	else if(istype(W, /obj/item/weapon/match))
		var/obj/item/weapon/match/M = W
		if(M.lit)
			light()
	else if(istype(W, /obj/item/candle))
		var/obj/item/candle/C = W
		if(C.lit)
			light()
	if(default_pry_open(I))
		return

	if(default_unfasten_wrench(user, I))
		return
	..()

/obj/machinery/trash_burner/default_deconstruction_crowbar(obj/item/weapon/crowbar/C, ignore_panel = 0)
	. = istype(C)
	if(.)
		playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
		extinguish()
		qdel(src)

/obj/machinery/trash_burner/proc/light()
	if(feed())
		lit = 1
		update_icon()

/obj/machinery/trash_burner/proc/extinguish()
	while(fuel > 0)
		fuel -= 10
		new /obj/item/weapon/scrap_lump(loc)
	if(scrap > 0)
		var/obj/item/stack/sheet/NS = new /obj/item/stack/sheet/refined_scrap(src.loc)
		NS.amount = min(scrap, NS.max_amount)
		scrap = 0
	lit = 0
	update_icon()

/obj/machinery/trash_burner/proc/feed()
	if(contents.len)
		fuel = 10 * contents.len
		for(var/obj/O in contents)
			qdel(O)
		contents.Cut()
		return 1
	return 0

/obj/machinery/trash_burner/process()
	if(lit)
		fuel -= 1
		if(prob(10))
			scrap += 1
		if(fuel <= 0)
			extinguish()