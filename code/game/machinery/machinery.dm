/*
Overview:
   Used to create objects that need a per step proc call.  Default definition of 'New()'
   stores a reference to src machine in global 'machines list'.  Default definition
   of 'Del' removes reference to src machine in global 'machines list'.

Class Variables:
   use_power (num)
      current state of auto power use.
      Possible Values:
         0 -- no auto power use
         1 -- machine is using power at its idle power level
         2 -- machine is using power at its active power level

   active_power_usage (num)
      Value for the amount of power to use when in active power mode

   idle_power_usage (num)
      Value for the amount of power to use when in idle power mode

   power_channel (num)
      What channel to draw from when drawing power for power mode
      Possible Values:
         EQUIP:0 -- Equipment Channel
         LIGHT:2 -- Lighting Channel
         ENVIRON:3 -- Environment Channel

   component_parts (list)
      A list of component parts of machine used by frame based machines.

   uid (num)
      Unique id of machine across all machines.

   gl_uid (global num)
      Next uid value in sequence

   stat (bitflag)
      Machine status bit flags.
      Possible bit flags:
         BROKEN:1 -- Machine is broken
         NOPOWER:2 -- No power is being supplied to machine.
         POWEROFF:4 -- tbd
         MAINT:8 -- machine is currently under going maintenance.
         EMPED:16 -- temporary broken by EMP pulse

   manual (num)
      Currently unused.

Class Procs:
   New()                     'game/machinery/machine.dm'

   Destroy()                     'game/machinery/machine.dm'

   auto_use_power()            'game/machinery/machine.dm'
      This proc determines how power mode power is deducted by the machine.
      'auto_use_power()' is called by the 'master_controller' game_controller every
      tick.

      Return Value:
         return:1 -- if object is powered
         return:0 -- if object is not powered.

      Default definition uses 'use_power', 'power_channel', 'active_power_usage',
      'idle_power_usage', 'powered()', and 'use_power()' implement behavior.

   powered(chan = EQUIP)         'modules/power/power.dm'
      Checks to see if area that contains the object has power available for power
      channel given in 'chan'.

   use_power(amount, chan=EQUIP, autocalled)   'modules/power/power.dm'
      Deducts 'amount' from the power channel 'chan' of the area that contains the object.
      If it's autocalled then everything is normal, if something else calls use_power we are going to
      need to recalculate the power two ticks in a row.

   power_change()               'modules/power/power.dm'
      Called by the area that contains the object when ever that area under goes a
      power state change (area runs out of power, or area channel is turned off).

   RefreshParts()               'game/machinery/machine.dm'
      Called to refresh the variables in the machine that are contributed to by parts
      contained in the component_parts list. (example: glass and material amounts for
      the autolathe)

      Default definition does nothing.

   assign_uid()               'game/machinery/machine.dm'
      Called by machine to assign a value to the uid variable.

   process()                  'game/machinery/machine.dm'
      Called by the 'master_controller' once per game tick for each machine that is listed in the 'machines' list.


	Compiled by Aygar
*/

/obj/machinery
	name = "machinery"
	icon = 'icons/obj/stationobjs.dmi'
	layer = DEFAULT_MACHINERY_LAYER
	var/stat = 0
	var/emagged = 0
	var/use_power = 1
		//0 = dont run the auto
		//1 = run auto, use idle
		//2 = run auto, use active
	var/idle_power_usage = 0
	var/active_power_usage = 0
	var/power_channel = EQUIP
		//EQUIP,ENVIRON or LIGHT
	var/list/component_parts = null //list of all the parts used to build it, if made from certain kinds of frames.
	var/uid
	var/manual = 0
	var/static/gl_uid = 1
	var/panel_open = 0
	var/state_open = 0
	var/mob/living/occupant = null
	var/unsecuring_tool = /obj/item/weapon/wrench
	var/interact_open = FALSE // Can the machine be interacted with when in maint/when the panel is open.
	var/interact_offline = 0 // Can the machine be interacted with while de-powered.
	var/allowed_checks = ALLOWED_CHECK_EVERYWHERE // should machine call allowed() in attack_hand(). See machinery/turretid for example.
	var/frequency = 0
	var/datum/radio_frequency/radio_connection
	var/radio_filter_out
	var/radio_filter_in

/obj/machinery/atom_init()
	. = ..()
	machines += src
	START_PROCESSING(SSmachine, src)
	power_change()

/obj/machinery/Destroy()
	if(frequency)
		set_frequency(null)
	machines -= src
	STOP_PROCESSING(SSmachine, src)

	dropContents()
	return ..()

/obj/machinery/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, radio_filter_in)

/obj/machinery/proc/locate_machinery()
	return

/obj/machinery/process()//If you dont use process or power why are you here
	return PROCESS_KILL

/obj/machinery/proc/process_atmos()//If you dont use process why are you here
	return PROCESS_KILL

/obj/machinery/emp_act(severity)
	if(use_power && stat == 0)
		use_power(7500/severity)

		var/obj/effect/overlay/pulse2 = new /obj/effect/overlay(loc)
		pulse2.icon = 'icons/effects/effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.name = "emp sparks"
		pulse2.anchored = 1
		pulse2.dir = pick(cardinal)

		QDEL_IN(pulse2, 10)
	..()

/obj/machinery/proc/open_machine()
	state_open = 1
	density = 0
	dropContents()
	update_icon()
	updateUsrDialog()

/obj/machinery/proc/dropContents()
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in contents)
		AM.forceMove(T)
		if(isliving(AM))
			var/mob/living/L = AM
			if(L.client)
				L.client.eye = L
				L.client.perspective = MOB_PERSPECTIVE
	occupant = null

/obj/machinery/proc/close_machine(mob/living/target = null)
	state_open = 0
	density = 1
	if(!target)
		for(var/mob/living/carbon/C in loc)
			if(C.buckled)
				continue
			else
				target = C
	if(target && !target.buckled)
		if(target.client)
			target.client.perspective = EYE_PERSPECTIVE
			target.client.eye = src
		occupant = target
		target.loc = src
		target.stop_pulling()
		if(target.pulledby)
			target.pulledby.stop_pulling()
	updateUsrDialog()
	update_icon()

/obj/machinery/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				qdel(src)
				return
		else
	return

/obj/machinery/blob_act()
	if(prob(50))
		qdel(src)

//sets the use_power var and then forces an area power update @ 7e65984ae2ec4e7eaaecc8da0bfa75642c3489c7 bay12
/obj/machinery/proc/update_use_power(new_use_power, force_update = 0)
	if ((new_use_power == use_power) && !force_update)
		return	//don't need to do anything

	use_power = new_use_power

	//force area power update
	//use_power() forces an area power update on the next tick so have to pass the correct power amount for this tick
	if (use_power >= 2)
		use_power(active_power_usage)
	else if (use_power == 1)
		use_power(idle_power_usage)
	else
		use_power(0)

/obj/machinery/proc/auto_use_power()
	if(!powered(power_channel))
		return 0
	if(src.use_power == 1)
		use_power(idle_power_usage,power_channel, 1)
	else if(src.use_power >= 2)
		use_power(active_power_usage,power_channel, 1)
	return 1

//By default, we check everything.
//But sometimes, we need to override this check.
/obj/machinery/proc/is_operational_topic()
	return !((stat & (NOPOWER|BROKEN|MAINT|EMPED)) || (panel_open && !interact_open))

/obj/machinery/Topic(href, href_list)
	..()

	if(usr.can_use_topic(src) != STATUS_INTERACTIVE || !is_operational_topic())
		usr.unset_machine(src)
		return FALSE

	if(!can_mob_interact(usr))
		return FALSE

	if((allowed_checks & ALLOWED_CHECK_TOPIC) && !emagged && !allowed(usr))
		allowed_fail(usr)
		to_chat(usr, "<span class='warning'>Access Denied.</span>")
		return FALSE

	usr.set_machine(src)
	add_fingerprint(usr)

	var/area/A = get_area(src)
	A.master.powerupdate = 1

	return TRUE

/obj/machinery/proc/is_operational()
	return !(stat & (NOPOWER|BROKEN|MAINT))

/obj/machinery/proc/issilicon_allowed(mob/living/silicon/S)
	if(istype(S) && allowed(S))
		return TRUE
	return FALSE

/obj/machinery/proc/is_interactable()
	if((stat & (NOPOWER|BROKEN)) && !interact_offline)
		return FALSE
	if(panel_open && !interact_open)
		return FALSE
	return TRUE

/obj/machinery/proc/allowed_fail(mob/user) // incase you want to add something special when allowed fails.
	return

////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/interact(mob/user)
	if(issilicon(user) || isobserver(user))
		add_hiddenprint(user)
	else if(isliving(user))
		add_fingerprint(user)
	if(ui_interact(user) != -1)
		user.set_machine(src)

/obj/machinery/attack_ai(mob/user)
	if(isrobot(user))
		// For some reason attack_robot doesn't work
		// This is to stop robots from using cameras to remotely control machines.
		if(user.client && user.client.eye == user)
			return attack_hand(user)
	else
		return attack_hand(user)

/obj/machinery/attack_paw(mob/user)
	return attack_hand(user)

// set_machine must be 0 if clicking the machinery doesn't bring up a dialog
/obj/machinery/attack_hand(mob/user)
	if ((user.lying || user.stat) && !IsAdminGhost(user))
		return 1
	if(!is_interactable())
		return 1
	if (!(ishuman(user) || issilicon(user) || ismonkey(user) || isalienqueen(user) || IsAdminGhost(user)))
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 1
	if (!can_mob_interact(user))
		return 1
	if(hasvar(src, "wires"))              // Lets close wires window if panel is closed.
		var/datum/wires/DW = vars["wires"] // Wires and machinery that uses this feature actually should be refactored.
		if(istype(DW) && !DW.can_use(user)) // Many of them do not use panel_open var.
			DW.Topic("close=1", list("close"="1"))
	if((allowed_checks & ALLOWED_CHECK_A_HAND) && !emagged && !allowed(user))
		allowed_fail(user)
		to_chat(user, "<span class='warning'>Access Denied.</span>")
		return 1

	var/area/A = get_area(src)
	A.master.powerupdate = 1 // <- wtf is this var and its comments...

	interact(user)
	return 0

/obj/machinery/CheckParts(list/parts_list)
	..()
	RefreshParts()

/obj/machinery/proc/RefreshParts() //Placeholder proc for machines that are built using frames.
	return

/obj/machinery/proc/assign_uid()
	uid = gl_uid
	gl_uid++

/obj/machinery/proc/default_pry_open(obj/item/weapon/crowbar/C)
	. = !(state_open || panel_open || is_operational() || (flags & NODECONSTRUCT)) && istype(C)
	if(.)
		playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
		visible_message("<span class='notice'>[usr] pry open \the [src].</span>", "<span class='notice'>You pry open \the [src].</span>")
		open_machine()
		return 1

/obj/machinery/proc/default_deconstruction_crowbar(obj/item/weapon/crowbar/C, ignore_panel = 0)
	. = istype(C) && (panel_open || ignore_panel) &&  !(flags & NODECONSTRUCT)
	if(.)
		deconstruction()
		playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
		var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(loc)
		transfer_fingerprints_to(M)
		M.state = 2
		M.icon_state = "box_1"
		for(var/obj/item/I in component_parts)
			if(I.reliability != 100 && crit_fail)
				I.crit_fail = 1
			I.loc = loc
		qdel(src)

/obj/machinery/proc/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/weapon/screwdriver/S)
	if(istype(S) &&  !(flags & NODECONSTRUCT))
		playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(!panel_open)
			panel_open = 1
			icon_state = icon_state_open
			to_chat(user, "<span class='notice'>You open the maintenance hatch of [src].</span>")
		else
			panel_open = 0
			icon_state = icon_state_closed
			to_chat(user, "<span class='notice'>You close the maintenance hatch of [src].</span>")
		return 1
	return 0

/obj/machinery/proc/default_change_direction_wrench(mob/user, obj/item/weapon/wrench/W)
	if(panel_open && istype(W))
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		dir = turn(dir,-90)
		to_chat(user, "<span class='notice'>You rotate [src].</span>")
		return 1
	return 0

/obj/proc/default_unfasten_wrench(mob/user, obj/item/weapon/wrench/W, time = 20)
	if(istype(W) &&  !(flags & NODECONSTRUCT))
		if(user.is_busy()) return
		to_chat(user, "<span class='notice'>You begin [anchored ? "un" : ""]securing [name]...</span>")
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, time/W.toolspeed, target = src))
			to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure [name].</span>")
			anchored = !anchored
			playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
		return 1
	return 0

/obj/machinery/proc/exchange_parts(mob/user, obj/item/weapon/storage/part_replacer/W)
	var/shouldplaysound = 0
	if(istype(W) && component_parts)
		if(panel_open || W.works_from_distance)
			var/obj/item/weapon/circuitboard/CB = locate(/obj/item/weapon/circuitboard) in component_parts
			var/P
			if(W.works_from_distance)
				to_chat(user, "<span class='notice'>Following parts detected in the machine:</span>")
				for(var/var/obj/item/C in component_parts)
					to_chat(user, "<span class='notice'>    [C.name]</span>")
			for(var/obj/item/weapon/stock_parts/A in component_parts)
				for(var/D in CB.req_components)
					if(ispath(A.type, D))
						P = D
						break
				for(var/obj/item/weapon/stock_parts/B in W.contents)
					if(istype(B, P) && istype(A, P))
						if(B.rating > A.rating)
							W.remove_from_storage(B, src)
							W.handle_item_insertion(A, 1)
							component_parts -= A
							component_parts += B
							B.loc = null
							to_chat(user, "<span class='notice'>[A.name] replaced with [B.name].</span>")
							shouldplaysound = 1 //Only play the sound when parts are actually replaced!
							break
			RefreshParts()
		else
			to_chat(user, "<span class='notice'>Following parts detected in the machine:</span>")
			for(var/var/obj/item/C in component_parts)
				to_chat(user, "<span class='notice'>    [C.name]</span>")
		if(shouldplaysound)
			W.play_rped_sound()
		return 1
	return 0

/obj/machinery/proc/display_parts(mob/user)
	to_chat(user, "<span class='notice'>Following parts detected in the machine:</span>")
	for(var/obj/item/C in component_parts)
		to_chat(user, "<span class='notice'>[bicon(C)] [C.name]</span>")

//called on machinery construction (i.e from frame to machinery) but not on initialization
/obj/machinery/proc/construction()
	return

//called on deconstruction before the final deletion
/obj/machinery/proc/deconstruction()
	return

/obj/machinery/proc/state(msg)
	for(var/mob/O in hearers(src, null))
		O.show_message("[bicon(src)] <span class = 'notice'>[msg]</span>", 2)

/obj/machinery/proc/ping(text=null)
	if (!text)
		text = "\The [src] pings."

	state(text, "blue")
	playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)

/obj/machinery/tesla_act(power)
	..()
	if(prob(85))
		emp_act(2)
	else if(prob(50))
		ex_act(3)
	else if(prob(90))
		ex_act(2)
	else
		ex_act(1)
