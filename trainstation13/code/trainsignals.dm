//TRAIN STATION 13

//This module is responsible for railway signals system.

/obj/machinery/trainsignal
	name = "railway signal"
	desc = "A visual display device that conveys instructions or provides warning of instructions regarding the driver’s authority to proceed."
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "flood00"
	density = TRUE
	light_power = 1
	light_color = "#da0205"
	interact_offline = TRUE
	var/on = TRUE
	var/obj/item/weapon/stock_parts/cell/high/cell = null
	var/use = 5
	var/unlocked = FALSE
	var/open = FALSE
	var/brightness_on = 3

/obj/machinery/trainsignal/atom_init()
	cell = new(src)
	. = ..()

/obj/machinery/trainsignal/proc/toggle(on = !on)
	src.on = on
	if(on)
		set_light(brightness_on)
	else
		set_light(0)
	update_icon()

/obj/machinery/trainsignal/update_icon()
	icon_state = "flood[open ? "o" : ""][open && cell ? "b" : ""]0[on]"

/obj/machinery/trainsignal/process()
	if(on)
		if(cell && cell.charge >= use)
			cell.use(use)
		else
			toggle(FALSE)
			visible_message("<span class='warning'>[src] shuts down due to lack of power!</span>")
			return


/obj/machinery/trainsignal/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(open && cell)
		user.put_in_hands(cell)

		cell.add_fingerprint(user)
		cell.updateicon()

		cell = null
		toggle(FALSE)
		to_chat(user, "You remove the power cell")
		return

	if(on)
		toggle(FALSE)
		to_chat(user, "<span class='notice'>You turn off the light</span>")
		user.SetNextMove(CLICK_CD_INTERACT)
		playsound(src, 'sound/machines/floodlight.ogg', VOL_EFFECTS_MASTER, 40)
	else
		if(!cell)
			return
		if(cell.charge <= 0)
			return
		toggle(TRUE)
		to_chat(user, "<span class='notice'>You turn on the light</span>")

		user.SetNextMove(CLICK_CD_INTERACT)
		playsound(src, 'sound/machines/floodlight.ogg', VOL_EFFECTS_MASTER, 40)
		playsound(src, 'sound/machines/lightson.ogg', VOL_EFFECTS_MASTER, null, FALSE)


/obj/machinery/trainsignal/attackby(obj/item/weapon/W, mob/user)
	if (isscrewing(W))
		if (!open)
			if(unlocked)
				unlocked = FALSE
				to_chat(user, "You screw the battery panel in place.")
			else
				unlocked = TRUE
				to_chat(user, "You unscrew the battery panel.")

	if (isprying(W))
		if(unlocked)
			if(open)
				open = FALSE
				cut_overlays()
				to_chat(user, "You crowbar the battery panel in place.")
			else
				if(unlocked)
					open = TRUE
					to_chat(user, "You remove the battery panel.")

	if (istype(W, /obj/item/weapon/stock_parts/cell))
		if(open)
			if(cell)
				to_chat(user, "There is a power cell already installed.")
			else
				user.drop_from_inventory(W, src)
				cell = W
				to_chat(user, "You insert the power cell.")
	update_icon()

/obj/machinery/trainsignal/deconstruct(disassembled)
	playsound(loc, 'sound/effects/Glassbr3.ogg', VOL_EFFECTS_MASTER, 100, TRUE)
	//var/obj/machinery/trainsignal_frame/F = new(loc) // TODO railway signal construction
	//F.state = TRAINSIGNAL_NEEDS_LIGHTS
	//new /obj/item/light/tube/broken(loc)
	..()

/obj/machinery/trainsignal/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(loc, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER, 75, TRUE)

//SIGNAL SPAWNER AND SWITCH

//SIGNALS

var/list/signal_spawner = list()

/obj/effect/signalspawner
	name = "railway signal spawner"
	desc = "Spawns a signal along the rail tracks for train driver."
	icon = 'trainstation13/icons/trainareas.dmi'
	icon_state = "signal"
	anchored = TRUE
	layer = TURF_LAYER
	plane = GAME_PLANE
	unacidable = TRUE
	invisibility = INVISIBILITY_ABSTRACT

	var/list/spawntypes = list(/obj/machinery/trainsignal)

/obj/effect/signalspawner/atom_init()
	signal_spawner += src

/obj/effect/signalspawner/proc/do_spawn()
	for(var/spawntype in spawntypes)
		new spawntype(loc)

/client/proc/spawn_signal()
	set category = "Event"
	set name = "TS13 Signals - Spawn Red Signal"

	log_admin("[usr.key] has spawned railway signal.")
	message_admins("[key_name_admin(usr)] has spawned railway signal.")

	for(var/obj/effect/signalspawner/T in signal_spawner)
		if(T.anchored)
			T.do_spawn()

var/railway_signal_state = 1 //1 - red, 2 - green

var/list/railway_signals = list()

/proc/set_railway_signal_state(value)
	railway_signal_state = value

	for(var/obj/machinery/trainsignal/red in railway_signals)
		red.update_icon()

/obj/machinery/trainsignal/atom_init()
	. = ..()
	railway_signals += src
	update_icon()

/obj/machinery/trainsignal/update_icon()
	switch(railway_signal_state)
		if(1)
			light_color = "#da0205"
		if(2)
			light_color = "#66ff66"

/client/proc/toggle_signals()
	set category = "Event"
	set name = "TS13 Signals - Toggle Signal Lights"

	var/msg
	if(event_field_stage==1)
		event_field_stage=2
		msg = "ALL railway SIGNALS are GREEN!"
	else if(event_field_stage==2)
		event_field_stage=1
		msg = "ALL railway SIGNALS are RED!"

	log_admin("[usr.key] has toggled railway signals, now [msg].")
	message_admins("[key_name_admin(usr)] has toggled railway signals, now [msg].")

	for(var/obj/machinery/trainsignal/red in railway_signals)
		red.update_icon()