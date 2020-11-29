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

	var/obj/item/device/toner/ink
	var/current_door_type = null ///holder for the door type
	var/current_pipe_color = null /// holder for the pipe color
	var/current_window_color = null ///holder for the window color
	var/static/list/doors /// list of doors used in show_radial_menu
	var/static/list/pipes /// list of pipes used in show_radial_menu
	var/available_paint_jobs = list(
		/obj/machinery/door/airlock/neutral,
		/obj/machinery/door/airlock/glass,
		/obj/machinery/door/airlock/engineering,
		/obj/machinery/door/airlock/atmos,
		/obj/machinery/door/airlock/security,
		/obj/machinery/door/airlock/command,
		/obj/machinery/door/airlock/medical,
		/obj/machinery/door/airlock/research,
		/obj/machinery/door/airlock/science,
		/obj/machinery/door/airlock/mining,
		/obj/machinery/door/airlock/maintenance,
		/obj/machinery/door/airlock/external,
		/obj/machinery/door/airlock/highsecurity)

/obj/item/weapon/airlock_painter/atom_init()
	. = ..()
	ink = new /obj/item/device/toner(src)

//uses ink charges
/obj/item/weapon/airlock_painter/use(cost)
	ink.charges -= cost
	playsound(src, 'sound/effects/spray2.ogg', VOL_EFFECTS_MASTER)
	return TRUE

/**
 * Subtracts used ink value from our ink
 *
 * Arguments:
 * * user - who are we gonna show failed can_use calls
 * * cost - amount to substract from current ink cartridge
 */
/obj/item/weapon/airlock_painter/proc/can_use(mob/user, cost = 10)
	if(!ink)
		to_chat(user, "<span class='notice'>There is no toner cardridge installed in \the [name]!</span>")
		return FALSE
	if(ink.charges < cost)
		to_chat(user, "<span class='notice'>Not enough ink!</span>")
		return FALSE
	return TRUE

/obj/item/weapon/airlock_painter/examine(mob/user)
	..()
	if(!ink)
		to_chat(user, "<span class='notice'>It doesn't have a toner cardridge installed.</span>")
		return
	to_chat(user, "<span class='notice'>Ink level is at [ink.charges/ink.max_charges*100] percent.</span>")

/obj/item/weapon/airlock_painter/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/device/toner))
		return
	if(!ink)
		user.drop_from_inventory(I, src)
		to_chat(user, "<span class='notice'>You install \the [I] into \the [name].</span>")
		ink = I
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
		return
	return ..()

/**
 * Removes toner from painter
 *
 * Arguments:
 * * user - who removes it
 */
/obj/item/weapon/airlock_painter/proc/remove_toner(mob/user)
	playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
	ink.loc = user.loc
	user.put_in_hands(ink)
	to_chat(user, "<span class='notice'>You remove \the [ink] from \the [name].</span>")
	ink = null

/obj/item/weapon/airlock_painter/attack_self(mob/user)
	var/list/choices = list(
		"Airlocks" = image(icon ='icons/obj/doors/airlocks/external/external.dmi', icon_state = "closed"),
		"Pipes" = image(icon ='icons/obj/atmospherics/mainspipe.dmi', icon_state = "intact"),
		"Windows" = image(icon ='icons/obj/window.dmi', icon_state = "rwindow0"))
	if(ink)
		var/image/img = image(icon = 'icons/obj/device.dmi', icon_state = "tonercartridge")
		choices += list("Remove toner" = img)
	var/state = show_radial_menu(user, src, choices, radius = 30, require_near = TRUE, tooltips = TRUE)
	if(!state)
		return
	switch(state)
		if("Airlocks")
			doors = list()
			for(var/airlock in available_paint_jobs)
				var/obj/machinery/door/airlock/A = new airlock
				var/image/img = image(icon = initial(A.icon), icon_state = initial(A.icon_state))
				img.add_overlay(image(icon_state = "fill_closed"))
				doors[A] = img
			state = show_radial_menu(user, src, doors, radius = 50, require_near = TRUE, tooltips = TRUE)
			if(state)
				current_door_type = state
			if(!state)
				return
		if("Pipes")
			pipes = list()
			for(var/C in pipe_colors)
				var/obj/item/pipe/P = new
				var/image/img = image(icon = P.icon, icon_state = P.icon_state)
				img.color = pipe_colors[C]
				pipes[C] = img
			state =	show_radial_menu(user, src, pipes, radius = 50,  require_near = TRUE, tooltips = TRUE)
			if(state)
				current_pipe_color = state
			if(!state)
				return
		if("Remove toner")
			remove_toner(user)
			return
		if("Windows")
			current_window_color = input(user, "Please select a color for your window.") as color|null
			return

/obj/item/weapon/airlock_painter/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity || user.incapacitated())
		return
	if(istype(target, /obj/machinery/door/airlock))
		if(isnull(current_door_type))
			to_chat(user, "<span class='notice'>Please select a paintjob for your airlock</span>")
			return
		if(istype(target, /obj/machinery/door/airlock/multi_tile))
			to_chat(user, "<span class='notice'>This airlock cannot be painted.</span>")
			return 
		var/obj/machinery/door/airlock/A = target
		A.change_paintjob(src, user, current_door_type)
	else if(istype(target, /obj/machinery/atmospherics/pipe))
		if(isnull(current_pipe_color))
			to_chat(user, "<span class='notice'>Please select a color for your pipe</span>")
			return
		var/obj/machinery/atmospherics/pipe/P = target
		P.change_paintjob(src, user, current_pipe_color)
	else if(istype(target, /obj/structure/window))
		var/obj/structure/window/W = target //windows have a null color, no need to check for it
		W.change_paintjob(src, user, current_window_color)
	else if(istype(target, /obj/machinery/door/window))
		var/obj/machinery/door/window/W = target // same as above
		W.change_paintjob(src, user, current_window_color)
