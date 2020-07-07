/obj/item/weapon/airlock_painter
	name = "universal painter"
	desc = "An advanced autopainter preprogrammed with several paintjobs for airlocks, windows and pipes. Use it on an airlock during or after construction to change the paintjob, or on window or pipe."
	icon_state = "paint sprayer"
	item_state = "paint sprayer"

	w_class = ITEM_SIZE_NORMAL

	m_amt = 50
	g_amt = 50
	origin_tech = "engineering=1"

	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT

	var/static/list/modes // used to dye pipes, contains pipe colors.
	var/obj/item/device/toner/ink

/obj/item/weapon/airlock_painter/atom_init()
	. = ..()

	if(!modes)
		modes = new()
		for(var/C in pipe_colors)
			modes += "[C]"

	ink = new /obj/item/device/toner(src)

	//This proc doesn't just check if the painter can be used, but also uses it.
	//Only call this if you are certain that the painter will be used right after this check!
/obj/item/weapon/airlock_painter/use(cost)
	if(cost < 0)
		stack_trace("[src.type]/use() called with a negative parameter [cost]")
		return 0
	if(can_use(usr, cost))
		ink.charges -= cost
		playsound(src, 'sound/effects/spray2.ogg', VOL_EFFECTS_MASTER)
		return 1
	else
		return 0

	//This proc only checks if the painter can be used.
	//Call this if you don't want the painter to be used right after this check, for example
	//because you're expecting user input.
/obj/item/weapon/airlock_painter/proc/can_use(mob/user, cost = 10)
	if(!ink)
		to_chat(user, "<span class='notice'>There is no toner cardridge installed installed in \the [name]!</span>")
		return 0
	else if(ink.charges < cost)
		to_chat(user, "<span class='notice'>Not enough ink!</span>")
		if(ink.charges < 1)
			to_chat(user, "<span class='notice'>\The [name] is out of ink!</span>")
		return 0
	else
		return 1

/obj/item/weapon/airlock_painter/examine(mob/user)
	..()
	if(!ink)
		to_chat(user, "<span class='notice'>It doesn't have a toner cardridge installed.</span>")
		return
	var/ink_level = "high"
	if(ink.charges < 1)
		ink_level = "empty"
	else if((ink.charges/ink.max_charges) <= 0.25) //25%
		ink_level = "low"
	else if((ink.charges/ink.max_charges) > 1) //Over 100% (admin var edit)
		ink_level = "dangerously high"
	to_chat(user, "<span class='notice'>Its ink levels look [ink_level].</span>")

/obj/item/weapon/airlock_painter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/toner))
		if(ink)
			to_chat(user, "<span class='notice'>\the [name] already contains \a [ink].</span>")
			return
		user.drop_from_inventory(I, src)
		to_chat(user, "<span class='notice'>You install \the [I] into \the [name].</span>")
		ink = I
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)

	else
		return ..()

/obj/item/weapon/airlock_painter/attack_self(mob/user)
	if(ink)
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
		ink.loc = user.loc
		user.put_in_hands(ink)
		to_chat(user, "<span class='notice'>You remove \the [ink] from \the [name].</span>")
		ink = null

/obj/item/weapon/airlock_painter/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return

	if(!istype(target, /obj/machinery/atmospherics/pipe) || \
		istype(target, /obj/machinery/atmospherics/components/unary/tank) || \
		istype(target, /obj/machinery/atmospherics/pipe/simple/heat_exchanging) || \
		!in_range(user, target))
	{
		return
	}

	var/obj/machinery/atmospherics/pipe/P = target

	var/selected_color = input("Which colour do you want to use?", "Universal painter") in modes
	if(!selected_color)
		return

	user.visible_message("<span class='notice'>[user] paints \the [P] [selected_color].</span>", "<span class='notice'>You paint \the [P] [selected_color].</span>")
	P.change_color(pipe_colors[selected_color])
