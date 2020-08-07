/*
field_generator power level display
   The icon used for the field_generator need to have 'FG_POWER_LEVELS' number of icon states
   named 'Field_Gen +p[num]' where 'num' ranges from 1 to 'FG_POWER_LEVELS'

   The power level is displayed using overlays. The current displayed power level is stored in 'powerlevel'.
   The overlay in use and the powerlevel variable must be kept in sync.  A powerlevel equal to 0 means that
   no power level overlay is currently in the overlays list.
   -Aygar
*/

#define FG_MAX_POWER    250
#define FG_FIELD_RANGE  9
#define FG_POWER_LEVELS 6

#define FG_UNSECURED 0
#define FG_SECURED   1
#define FG_WELDED    2

#define FG_OFFLINE   0
#define FG_CHARGING  1
#define FG_ONLINE    2

/obj/machinery/field_generator
	name = "Field Generator"
	desc = "A large thermal battery that projects a high amount of energy when powered."
	icon = 'icons/obj/machines/field_generator.dmi'
	icon_state = "Field_Gen"
	anchored = FALSE
	density = TRUE
	use_power = NO_POWER_USE

	var/var_edit_start = FALSE
	var/var_power      = FALSE

	var/power      = 20
	var/active     = FG_OFFLINE
	var/state      = FG_UNSECURED
	var/warming_up = 0
	var/clean_up   = FALSE

	var/list/obj/machinery/containment_field/fields
	var/list/obj/machinery/field_generator/connected_gens


/obj/machinery/field_generator/Destroy()
	if(active != FG_OFFLINE)
		cleanup()
	return ..()

/obj/machinery/field_generator/update_icon()
	cut_overlays()
	if(warming_up)
		add_overlay("+a[warming_up]")
	if(length(fields))
		add_overlay("+on")
	// Power level indicator
	// Scale % power to % FG_POWER_LEVELS and truncate value
	var/level = round(FG_POWER_LEVELS * power / FG_MAX_POWER)
	// Clamp between 0 and FG_POWER_LEVELS for out of range power values
	level = between(0, level, FG_POWER_LEVELS)
	if(level)
		add_overlay("+p[level]")

/obj/machinery/field_generator/process()
	if(var_edit_start)
		if(active == FG_OFFLINE)
			active = FG_CHARGING
			state = FG_WELDED
			power = FG_MAX_POWER
			anchored = TRUE
			warming_up = 3
			start_fields()
			update_icon()
			playsound(src, 'sound/machines/cfieldstart.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		var_edit_start = FALSE

	if(active == FG_ONLINE)
		calc_power()
		update_icon()
	return

/obj/machinery/field_generator/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(state == FG_WELDED)
		if(in_range(src, user) || isobserver(user))//Need to actually touch the thing to turn it on
			if(active != FG_OFFLINE)
				to_chat(user, "<span class='red'>You are unable to turn off the [src] once it is online.</span>")
				return 1
			else
				user.visible_message(
					"<span class='notice'>[user] turns on the [src].</span>",
					"<span class='notice'>You turn on the [src].</span>",
					"<span class='notice'>You hear heavy droning.</span>")
				turn_on()
				playsound(src, 'sound/machines/cfieldbeforestart.ogg', VOL_EFFECTS_MASTER, null, FALSE)
				log_investigate("<font color='green'>activated</font> by [key_name(user)].",INVESTIGATE_SINGULO)
	else
		to_chat(user, "<span class='notice'>The [src] needs to be firmly secured to the floor first.</span>")
		return 1


/obj/machinery/field_generator/attackby(obj/item/W, mob/user)
	if(active != FG_OFFLINE)
		to_chat(user, "<span class='red'>The [src] needs to be off.</span>")
	else if(iswrench(W))
		switch(state)
			if(FG_UNSECURED)
				state = FG_SECURED
				playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
				user.visible_message(
					"<span class='notice'>[user] secures [src] to the floor.</span>",
					"<span class='notice'>You secure the external reinforcing bolts to the floor.</span>",
					"<span class='notice'>You hear ratchet.</span>")
				anchored = TRUE
			if(FG_SECURED)
				state = FG_UNSECURED
				playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
				user.visible_message(
					"<span class='notice'>[user] unsecures [src] reinforcing bolts from the floor.</span>",
					"<span class='notice'>You undo the external reinforcing bolts.</span>",
					"<span class='notice'>You hear ratchet.</span>")
				anchored = FALSE
			if(FG_WELDED)
				to_chat(user, "<span class='red'>The [src] needs to be unwelded from the floor.</span>")
	else if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		switch(state)
			if(FG_UNSECURED)
				to_chat(user, "<span class='red'>The [src] needs to be wrenched to the floor.</span>")
			if(FG_SECURED)
				if(!user.is_busy() && WT.use(0, user))
					user.visible_message(
						"<span class='notice'>[user.name] starts to weld the [src.name] to the floor.</span>",
						"<span class='notice'>You start to weld the [src] to the floor.</span>",
						"<span class='notice'>You hear welding.</span>")
					if(WT.use_tool(src, user, 20, volume = 50))
						state = FG_WELDED
						to_chat(user, "<span class='notice'>You weld the field generator to the floor.</span>")
			if(FG_WELDED)
				if (!user.is_busy() && WT.use(0, user))
					user.visible_message(
						"<span class='notice'>[user.name] starts to cut the [src.name] free from the floor.</span>",
						"<span class='notice'>You start to cut the [src] free from the floor.</span>",
						"<span class='notice'>You hear welding.</span>")
					if (WT.use_tool(src, user, 20, volume = 50))
						state = FG_SECURED
						to_chat(user, "<span class='notice'>You cut the [src] free from the floor.</span>")
	else
		..()


/obj/machinery/field_generator/emp_act()
	return FALSE

/obj/machinery/field_generator/blob_act()
	if(active != FG_OFFLINE)
		return FALSE
	else
		..()

/obj/machinery/field_generator/bullet_act(obj/item/projectile/Proj)
	if(Proj.flag != "bullet")
		power += Proj.damage
		update_icon()
	return FALSE

/obj/machinery/field_generator/proc/turn_off()
	active = FG_OFFLINE
	cleanup()
	cool_down()

/obj/machinery/field_generator/proc/cool_down()
	set waitfor = FALSE

	while(warming_up > 0 && active == FG_OFFLINE)
		sleep(50)
		warming_up--
		update_icon()

/obj/machinery/field_generator/proc/turn_on()
	active = FG_CHARGING
	warming_up = 1
	warm_up()
	update_icon()

/obj/machinery/field_generator/proc/warm_up()
	set waitfor = FALSE

	while(warming_up < 3 && active != FG_OFFLINE)
		sleep(50)
		warming_up++
		update_icon()
		if(warming_up >= 3)
			start_fields()
			playsound(src, 'sound/machines/cfieldstart.ogg', VOL_EFFECTS_MASTER)

/obj/machinery/field_generator/proc/calc_power()
	if(var_power)
		return

	power = min(power, FG_MAX_POWER)

	var/power_draw = 2 + length(fields)
	if(!draw_power(round(power_draw / 2, 1)))
		visible_message("<span class='warning'>The [src] shuts down!</span>")
		turn_off()
		playsound(src, 'sound/machines/cfieldfail.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		log_investigate("ran out of power and <font color='red'>deactivated</font>",INVESTIGATE_SINGULO)
		power = 0

// This could likely be better, it tends to start loopin if you have a complex generator loop setup.
//  Still works well enough to run the engine fields will likely recode the field gens and fields sometime -Mport
/obj/machinery/field_generator/proc/draw_power(draw = 0, failsafe = 0, obj/machinery/field_generator/G, obj/machinery/field_generator/last)
	if(var_power)
		return TRUE

	if((G && G == src) || (failsafe >= 8))  //Loopin, set fail
		return FALSE
	else
		failsafe++

	if(power >= draw)  //We have enough power
		power -= draw
		return TRUE
	else  //Need more power
		draw -= power
		power = 0
		for(var/thing in connected_gens)
			var/obj/machinery/field_generator/FG = thing
			if(FG == last)  //We just asked you
				continue
			if(G)  //Another gen is askin for power and we dont have it
				return FG.draw_power(draw, failsafe, G, src)  //Can you take the load
			else  //We are askin another for power
				return FG.draw_power(draw, failsafe, src, src)

/obj/machinery/field_generator/proc/start_fields()
	if(state != FG_WELDED || !anchored)
		turn_off()
		return
	addtimer(CALLBACK(src, .proc/setup_field, NORTH), 1)
	addtimer(CALLBACK(src, .proc/setup_field, SOUTH), 2)
	addtimer(CALLBACK(src, .proc/setup_field, EAST), 3)
	addtimer(CALLBACK(src, .proc/setup_field, WEST), 4)
	active = FG_ONLINE

/obj/machinery/field_generator/proc/setup_field(NSEW)
	LAZYINITLIST(fields)
	LAZYINITLIST(connected_gens)

	var/turf/T = loc
	var/obj/machinery/field_generator/G = null
	var/steps = 0

	for(var/dist in 1 to FG_FIELD_RANGE)
		T = get_step(T, NSEW)

		if(T.density)
			return

		for(var/atom/A in T.contents)
			if(ismob(A))
				continue
			if(!istype(A, /obj/machinery/field_generator))
				if(A.density)
					return
			else
				G = A

		if(G)
			if(G.active == FG_OFFLINE)
				return
			LAZYINITLIST(G.fields)
			LAZYINITLIST(G.connected_gens)
			break
		else
			steps++

	if(!G)
		return

	T = loc

	for(var/dist in 1 to steps) // creates each field tile
		var/field_dir = get_dir(T, get_step(G.loc, NSEW))
		T = get_step(T, NSEW)
		if(!locate(/obj/machinery/containment_field) in T)
			var/obj/machinery/containment_field/CF = new
			CF.set_master(src, G)
			CF.loc = T
			CF.dir = field_dir

	connected_gens |= G
	G.connected_gens |= src


/obj/machinery/field_generator/proc/cleanup()
	if(clean_up)
		return

	clean_up = TRUE

	if(length(fields))
		for(var/obj/machinery/containment_field/CF in fields)  // `fileds` list will be cleared by field themself in `Destroy()` so no `Cut()`.
			if(!QDESTROYING(CF))
				qdel(CF)

	if(length(connected_gens))
		for(var/obj/machinery/field_generator/FG in connected_gens)
			FG.connected_gens -= src
			FG.cleanup()
		connected_gens.Cut()

	clean_up = FALSE
	update_icon()

	//This is here to help fight the "hurr durr, release singulo cos nobody will notice before the
	//singulo eats the evidence". It's not fool-proof but better than nothing.
	//I want to avoid using global variables.
	addtimer(CALLBACK(src, .proc/warn_admins), 1)

/obj/machinery/field_generator/proc/warn_admins()
	var/temp = TRUE //stops spam
	for(var/obj/singularity/O in poi_list)
		if(O.last_warning && temp)
			if((world.time - O.last_warning) > 50) //to stop message-spam
				temp = FALSE
				message_admins("<span class='danger'>A singulo exists and a containment field has failed. [ADMIN_JMP(O)]</span>")
				log_investigate("has <font color='red'>failed</font> whilst a singulo exists.",INVESTIGATE_SINGULO)
		O.last_warning = world.time


#undef FG_MAX_POWER
#undef FG_FIELD_RANGE
#undef FG_POWER_LEVELS

#undef FG_UNSECURED
#undef FG_SECURED
#undef FG_WELDED

#undef FG_OFFLINE
#undef FG_CHARGING
#undef FG_ONLINE
