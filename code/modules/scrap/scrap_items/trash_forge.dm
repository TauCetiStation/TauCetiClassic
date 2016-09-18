//TODO: refactor this when propper forge system exists (how naive)
/obj/machinery/trash_forge
	var/list/valid_fuel = list(/obj/item/stack/sheet/wood = 1, \
								/obj/item/weapon/ore/coal = 1.2, \
								/obj/item/stack/sheet/mineral/phoron = 1.4
								)
	name = "Scrap Forge"
	desc = "Strike while the iron is hot!"
	brightness_color = "#a0a080"
	brightness_range = 2
	brightness_power = 1
	var/lit = 0
	var/ready = 0
	var/temperature = 0

/obj/machinery/trash_forge/examine()
	set src in usr
	usr << "\icon[src] This [callme] is used to burn fuel and heat metal."
	if(lit)
		usr << "It's burning bright!"
	else
		usr << "It's cold. Add some fuel and light it up!"

/obj/machinery/trash_forge/attackby(obj/item/W as obj, mob/user as mob)
	if(default_deconstruction_crowbar(I))
		return
	if(lit)
		..()
		return
	//use 5 sheets of wood or phoron or 1 coal piece
	if(W.type in valid_fuel)
		var/temperature_will_be = valid_fuel[W.type]
		if(istype(W.type, /obj/item/stack/sheet))
			var/obj/item/stack/sheet/fuel = W
			if(fuel.use(5))
				ready = 1
		else
			user.drop_item()
			ready = 1
			qdel(W)
		if(ready)
			temperature = temperature_will_be
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

/obj/machinery/trash_forge/default_deconstruction_crowbar(obj/item/weapon/crowbar/C, ignore_panel = 0)
	. = istype(C)
	if(.)
		playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
		extinguish()
		qdel(src)

/obj/machinery/trash_forge/proc/light()
	if(feed())
		lit = 1
		set_light(brightness_range, brightness_power, brightness_color)
		update_icon()

/obj/machinery/trash_forge/proc/get_temperature()
	if(lit)
		return temperature
	return 0

/obj/machinery/trash_forge/proc/extinguish()
	ready = 0
	lit = 0
	set_light(0)
	temperature = 0
	update_icon()

/obj/machinery/trash_forge/proc/feed()
	if(ready)
		fuel = 200
		return 1
	return 0

/obj/machinery/trash_forge/process()
	if(lit)
		fuel -= 1
		if(fuel <= 0)
			extinguish()