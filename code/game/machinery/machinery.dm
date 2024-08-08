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

    min_operational_temperature (num)
        The minimal value returned by get_current_temperature() if the machine is currently
        "running".

    max_operational_temperature (num)
        The maximum value returned by get_current_temperature() if the machine is currently
        "running".

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
	w_class = SIZE_MASSIVE

	max_integrity = 200
	integrity_failure = 0.3
	damage_deflection = 15
	resistance_flags = CAN_BE_HIT

	var/icon_state_active = 0
	var/stat = 0
	var/emagged = 0 // Can be 0, 1 or 2
	var/use_power = IDLE_POWER_USE
		//0 = dont run the auto
		//1 = run auto, use idle
		//2 = run auto, use active
	var/idle_power_usage = 0
	var/active_power_usage = 0
	var/power_channel = STATIC_EQUIP
		//EQUIP,ENVIRON or LIGHT
	var/current_power_usage = 0 // How much power are we currently using, dont change by hand, change power_usage vars and then use set_power_use
	var/area/current_power_area // What area are we powering currently
	var/list/component_parts = null //list of all the parts used to build it, if made from certain kinds of frames.
	var/uid
	var/manual = 0
	var/static/gl_uid = 1
	var/panel_open = 0
	var/state_open = 0
	var/mob/living/occupant = null
	var/unsecuring_tool = /obj/item/weapon/wrench
	var/interact_open = FALSE // Can the machine be interacted with when in maint/when the panel is open.
	var/interact_offline = FALSE // Can the machine be interacted with while de-powered.
	var/allowed_checks = ALLOWED_CHECK_EVERYWHERE // should machine call allowed() in attack_hand(). See machinery/turretid for example.
	var/frequency = 0
	var/datum/radio_frequency/radio_connection
	var/radio_filter_out
	var/radio_filter_in
	var/speed_process = FALSE  // Process as fast as possible?
	var/process_last = FALSE   // Process after others

	var/min_operational_temperature = 5
	var/max_operational_temperature = 10

	var/list/required_skills //e.g. medical, engineering
	var/fumbling_time = 5 SECONDS

/obj/machinery/atom_init()
	. = ..()
	machines += src

	if (speed_process)
		START_PROCESSING(SSfastprocess, src)
	else if (process_last)
		START_PROCESSING_NAMED(SSmachines, src, processing_second)
	else
		START_PROCESSING(SSmachines, src)

	power_change()
	update_power_use()

/obj/machinery/Destroy()
	if(frequency)
		set_frequency(null)

	set_power_use(NO_POWER_USE)
	machines -= src

	stop_processing()

	dropContents()
	return ..()

/obj/machinery/proc/stop_processing()
	if (speed_process)
		STOP_PROCESSING(SSfastprocess, src)
	else if (process_last)
		STOP_PROCESSING_NAMED(SSmachines, src, processing_second)
	else
		STOP_PROCESSING(SSmachines, src)

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

		new /obj/effect/overlay/pulse2(loc, 1)
	..()

/obj/machinery/proc/open_machine()
	state_open = 1
	density = FALSE
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
	density = TRUE
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
		if(EXPLODE_HEAVY)
			if (prob(50))
				return
		if(EXPLODE_LIGHT)
			if (prob(75))
				return
	qdel(src)

// The main proc that controls power usage of a machine, change use_power only with this proc
/obj/machinery/proc/set_power_use(new_use_power)
	if(current_power_usage && current_power_area) // We are tracking the area that is powering us so we can remove power from the right one if we got moved or something
		current_power_area.removeStaticPower(current_power_usage, power_channel)
		current_power_area = null

	current_power_usage = 0
	use_power = new_use_power

	var/area/A = get_area(src)
	if(!A || !anchored || stat & NOPOWER) // Unwrenched machines aren't plugged in, unpowered machines don't use power
		return

	if(use_power == IDLE_POWER_USE && idle_power_usage)
		current_power_area = A
		current_power_usage = idle_power_usage
		current_power_area.addStaticPower(current_power_usage, power_channel)
	else if(use_power == ACTIVE_POWER_USE && active_power_usage)
		current_power_area = A
		current_power_usage = active_power_usage
		current_power_area.addStaticPower(current_power_usage, power_channel)

/obj/machinery/proc/update_power_use()
	set_power_use(use_power)

// Unwrenching = unpluging from a power source
/obj/machinery/wrenched_change()
	update_power_use()

/**
 * Can this machine work in its current state?
 * By default, we check everything.
 * But sometimes, we need to override this check.
 */
/obj/machinery/proc/is_operational()
	return !(stat & (NOPOWER | BROKEN | MAINT | EMPED))

/**
 * Can this particular `user` interact with the machine?
 * Does not check access or distance
 */
/obj/machinery/proc/can_interact_with(mob/user)
	SHOULD_CALL_PARENT(TRUE)

	if(user.incapacitated())
		return FALSE
	if(!(ishuman(user) || issilicon(user) || ismonkey(user) || isxenoqueen(user) || IsAdminGhost(user))) //can we just swap it for IsAdvancedToolUser
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	if(!is_operational() && !interact_offline)
		return FALSE
	if(panel_open && !interact_open)
		return FALSE
	if(user.interact_prob_brain_damage(src))
		return FALSE

	return TRUE

/**
 * Any input()/alert() pause proc, so sometimes we need to check after if user still around and can interact
 * For topics and tgui_act
 * todo: we need atom analogues for attack_hand/attackby/topic/etc.
 */
/obj/machinery/proc/can_still_interact_with(mob/user)
	// in the future we maybe need to add or change to TGUI can_use_topic, should be fine now
	if(usr.can_use_topic(src) != STATUS_INTERACTIVE || !can_interact_with(user))
		usr.unset_machine(src)
		return FALSE
	if((allowed_checks & ALLOWED_CHECK_TOPIC) && !allowed(user))
		allowed_fail(user)
		return FALSE

	return TRUE

/obj/machinery/get_current_temperature()
	if(!is_operational())
		return 0

	if(emagged)
		return max_operational_temperature += rand(10, 20)

	return rand(min_operational_temperature, max_operational_temperature)

/obj/machinery/Topic(href, href_list)
	..()

	if(usr.can_use_topic(src) != STATUS_INTERACTIVE || !can_interact_with(usr))
		usr.unset_machine(src)
		return FALSE

	if((allowed_checks & ALLOWED_CHECK_TOPIC) && !allowed(usr))
		allowed_fail(usr)
		return FALSE

	usr.set_machine(src)
	add_fingerprint(usr)

	if(!do_skill_checks(usr))
		return FALSE

	return TRUE

/obj/machinery/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return TRUE

	if(!can_interact_with(usr))
		return

	usr.set_machine(src)
	add_fingerprint(usr)

	if(!do_skill_checks(usr))
		return TRUE
	return FALSE

/obj/machinery/proc/issilicon_allowed(mob/living/silicon/S)
	if(istype(S) && allowed(S))
		return TRUE
	return FALSE

/**
 * In case you want to add something special when access check fails
 */
/obj/machinery/proc/allowed_fail(mob/user)
	to_chat(user, "<span class='warning'>Access Denied.</span>")
	return


////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Action, when `user` clicks with his hand on the machine.
 * If this called, user has already passed as capable to interact with the machine.
 */
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
	if(!can_interact_with(user))
		return TRUE
	if(HAS_TRAIT_FROM(user, TRAIT_GREASY_FINGERS, QUALITY_TRAIT))
		if(prob(75))
			to_chat(user, "<span class='notice'>Your fingers are slipping.</span>")
			return TRUE

	if(hasvar(src, "wires"))              // Lets close wires window if panel is closed.
		var/datum/wires/DW = vars["wires"] // Wires and machinery that uses this feature actually should be refactored.
		if(istype(DW) && !DW.can_use(user)) // Many of them do not use panel_open var.
			user << browse(null, "window=wires")
			user.unset_machine(src)

	if((allowed_checks & ALLOWED_CHECK_A_HAND) && !allowed(user))
		allowed_fail(user)
		return TRUE

	interact(user)
	return FALSE

/obj/machinery/tgui_close(mob/user)
	user.unset_machine(src)

/obj/machinery/CheckParts(list/parts_list)
	..()
	RefreshParts()

/obj/machinery/proc/RefreshParts()
	var/caprat = 0
	var/binrat = 0

	var/manrat = 0
	var/lasrat = 0
	var/scanrat = 0

	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		caprat += C.rating
	for(var/obj/item/weapon/stock_parts/matter_bin/C in component_parts)
		binrat += C.rating

	for(var/obj/item/weapon/stock_parts/manipulator/C in component_parts)
		manrat += C.rating
	for(var/obj/item/weapon/stock_parts/micro_laser/C in component_parts)
		lasrat += C.rating
	for(var/obj/item/weapon/stock_parts/scanning_module/C in component_parts)
		scanrat += C.rating

	idle_power_usage = initial(idle_power_usage) * caprat * CAPACITOR_POWER_MULTIPLIER * binrat * MATTERBIN_POWER_MULTIPLIER
	active_power_usage = initial(active_power_usage) * manrat * MANIPULATOR_POWER_MULTIPLIER * lasrat * LASER_POWER_MULTIPLIER * scanrat * SCANER_POWER_MULTIPLIER
	return

/obj/machinery/proc/assign_uid()
	uid = gl_uid
	gl_uid++

/obj/machinery/proc/default_pry_open(obj/item/weapon/I)
	. = isprying(I) && !(state_open || panel_open || is_operational() || (flags & NODECONSTRUCT))
	if(.)
		playsound(src, 'sound/items/Crowbar.ogg', VOL_EFFECTS_MASTER)
		visible_message("<span class='notice'>[usr] pry open \the [src].</span>", "<span class='notice'>You pry open \the [src].</span>")
		open_machine()
		return 1

/obj/machinery/proc/default_deconstruction_crowbar(obj/item/weapon/I, ignore_panel = 0)
	. = isprying(I) && (panel_open || ignore_panel) && !(flags & NODECONSTRUCT)
	if(.)
		if(!handle_fumbling(usr, src, SKILL_TASK_AVERAGE, list(/datum/skill/engineering = SKILL_LEVEL_TRAINED), "<span class='notice'>You fumble around, figuring out how to deconstruct [src].</span>"))
			return
		playsound(src, 'sound/items/Crowbar.ogg', VOL_EFFECTS_MASTER)
		deconstruct(TRUE)

/obj/machinery/proc/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/weapon/I)
	if(isscrewing(I) &&  !(flags & NODECONSTRUCT))
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		if(!panel_open)
			if(!handle_fumbling(user, src, SKILL_TASK_EASY, list(/datum/skill/engineering = SKILL_LEVEL_TRAINED), "<span class='notice'>You fumble around, figuring out how to open the maintenance hatch of [src].</span>"))
				return 0
			panel_open = 1
			icon_state = icon_state_open
			to_chat(user, "<span class='notice'>You open the maintenance hatch of [src].</span>")
		else
			if(!handle_fumbling(user, src, SKILL_TASK_EASY, list(/datum/skill/engineering = SKILL_LEVEL_TRAINED), "<span class='notice'>You fumble around, figuring out how to close the maintenance hatch of [src].</span>"))
				return 1
			panel_open = 0
			icon_state = icon_state_closed
			to_chat(user, "<span class='notice'>You close the maintenance hatch of [src].</span>")
		return 1
	return 0

/obj/machinery/proc/default_change_direction_wrench(mob/user, obj/item/weapon/I)
	if(panel_open && iswrenching(I))
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		set_dir(turn(dir,-90))
		to_chat(user, "<span class='notice'>You rotate [src].</span>")
		return 1
	return 0

/obj/proc/default_unfasten_wrench(mob/user, obj/item/weapon/I, time = SKILL_TASK_VERY_EASY)
	if(iswrenching(I) &&  !(flags & NODECONSTRUCT))
		if(user.is_busy()) return
		to_chat(user, "<span class='notice'>You begin [anchored ? "un" : ""]securing [name]...</span>")
		if(I.use_tool(src, user, time, volume = 50, required_skills_override = list(/datum/skill/engineering = SKILL_LEVEL_NOVICE)))
			to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure [name].</span>")
			anchored = !anchored
			playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
			wrenched_change()
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
				for(var/obj/item/C in component_parts)
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
			for(var/obj/item/C in component_parts)
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

/obj/machinery/proc/spawn_frame(disassembled)
	var/obj/machinery/constructable_frame/machine_frame/new_frame = new /obj/machinery/constructable_frame/machine_frame(loc)

	new_frame.state = 2
	new_frame.icon_state = "box_1"
	. = new_frame
	if(!disassembled)
		new_frame.update_integrity(new_frame.max_integrity * 0.5) //the frame is already half broken
	transfer_fingerprints_to(new_frame)

/obj/machinery/atom_break(damage_flag)
	. = ..()
	if(stat & BROKEN || flags & NODECONSTRUCT)
		return
	stat |= BROKEN
	update_icon()
	return TRUE

/obj/machinery/deconstruct(disassembled = TRUE)
	if(flags & NODECONSTRUCT)
		return ..() //Just delete us, no need to call anything else.

	deconstruction()
	if(!length(component_parts))
		return ..() //we don't have any parts.
	spawn_frame(disassembled)
	for(var/obj/item/part in component_parts)
		part.forceMove(loc)
		if(part.reliability != 100 && crit_fail)
			part.crit_fail = 1
	LAZYCLEARLIST(component_parts)
	..()

//called on deconstruction before the final deletion
/obj/machinery/proc/deconstruction()
	return

/obj/machinery/proc/state(msg)
	audible_message("[bicon(src)] <span class = 'notice'>[msg]</span>")

/obj/machinery/proc/ping(text=null)
	if (!text)
		text = "\The [src] pings."

	state(text, "blue")
	playsound(src, 'sound/machines/ping.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/machinery/tesla_act(power)
	..()
	if(prob(85))
		emp_act(2)
	else if(prob(50))
		ex_act(EXPLODE_LIGHT)
	else if(prob(90))
		ex_act(EXPLODE_HEAVY)
	else
		ex_act(EXPLODE_DEVASTATE)

/obj/machinery/proc/do_skill_checks(mob/user)
	if (!required_skills || !user || issilicon(user) || isobserver(user))
		return TRUE
	return handle_fumbling(user, src, fumbling_time, required_skills, check_busy = FALSE)
