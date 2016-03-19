/obj/machinery/horisontal_drill
	name = "suspension field generator"
	desc = "It has stubby legs bolted up against it's body for stabilising."
	icon = 'icons/obj/xenoarchaeology.dmi'
	density = 1

/obj/machinery/horisontal_drill/process()



/obj/machinery/horisontal_drill/attack_hand(mob/user as mob)
	
/obj/machinery/horisontal_drill/proc/activate()
	//depending on the field type, we might pickup certain items
	var/turf/T = get_turf(get_step(src,dir))

/obj/machinery/horisontal_drill/proc/deactivate()


var/const/SAFETY_COOLDOWN = 100

/obj/machinery/horisontal_drill
	name = "horisontal_drill"
	desc = "This machine rips everything in front of it apart."
	icon = 'icons/obj/structures/scrap/recycling.dmi'
	icon_state = "grinder-b0"
	layer = MOB_LAYER+1 // Overhead
	anchored = 1
	density = 1
	var/safety_mode = 0 // Temporality stops the machine if it detects a mob
	var/grinding = 0
	var/icon_name = "grinder-b"
	var/blood = 0
	var/eat_dir = WEST
	var/chance_to_recycle = 1

/obj/machinery/horisontal_drill/New()
	// On us
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/horisontal_drill(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	RefreshParts()
	update_icon()

/obj/machinery/horisontal_drill/RefreshParts()
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		chance_to_recycle = 25 * M.rating //% of materials salvaged
	chance_to_recycle = min(100, chance_to_recycle)

/obj/machinery/horisontal_drill/examine(mob/user)
	..()
	user << "The power light is [(stat & NOPOWER) ? "off" : "on"]."
	user << "The safety-mode light is [safety_mode ? "on" : "off"]."
	user << "The safety-sensors status light is [emagged ? "off" : "on"]."

/obj/machinery/horisontal_drill/power_change()
	..()
	update_icon()


/obj/machinery/horisontal_drill/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grinder-oOpen", "grinder-o0", I))
		return

	if(exchange_parts(user, I))
		return

	if(default_pry_open(I))
		return

	if(default_unfasten_wrench(user, I))
		return

	default_deconstruction_crowbar(I)
	..()
	add_fingerprint(user)
	return

/obj/machinery/horisontal_drill/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		if(safety_mode)
			safety_mode = 0
			update_icon()
		playsound(src.loc, "sparks", 75, 1, -1)
		user << "<span class='notice'>You use the cryptographic sequencer on the [src.name].</span>"

/obj/machinery/horisontal_drill/update_icon()
	..()
	var/is_powered = !(stat & (BROKEN|NOPOWER))
	if(safety_mode)
		is_powered = 0
	icon_state = icon_name + "[is_powered]" + "[(blood ? "bld" : "")]" // add the blood tag at the end


/obj/machinery/horisontal_drill/proc/eat(mob/living/L)

	L.loc = src.loc

	if(issilicon(L))
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	else
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)

	var/gib = 1
	// By default, the emagged horisontal_drill will gib all non-carbons. (human simple animal mobs don't count)
	if(iscarbon(L))
		gib = 0
		if(L.stat == CONSCIOUS)
			L.say("ARRRRRRRRRRRGH!!!")
		add_blood(L)

	if(!blood && !issilicon(L))
		blood = 1
		update_icon()

	// Remove and recycle the equipped items.
	for(var/obj/item/I in L.get_equipped_items())
		if(L.unEquip(I))
			recycle(I, 0)

	// Instantly lie down, also go unconscious from the pain, before you die.
	L.Paralyse(5)

	// For admin fun, var edit emagged to 2.
	if(gib || emagged == 2)
		L.gib()
	else if(emagged == 1)
		for(var/i = 1 to 10)
			L.adjustBruteLoss(20)
			spawn(1)

/obj/item/weapon/paper/horisontal_drill
	name = "paper - 'garbage duty instructions'"
	info = "<h2>New Assignment</h2> You have been assigned to collect garbage from trash bins, located around the station. The crewmembers will put their trash into it and you will collect the said trash.<br><br>There is a recycling machine near your closet, inside maintenance; use it to recycle the trash for a small chance to get useful minerals. Then deliver these minerals to cargo or engineering. You are our last hope for a clean station, do not screw this up!"
