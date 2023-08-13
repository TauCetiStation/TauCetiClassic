#define TIMER_MIN 600
#define TIMER_MAX 780

var/global/bomb_set

/obj/machinery/nuclearbomb
	name = "Nuclear Fission Explosive"
	desc = "Uh oh. RUN!!!!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb0"
	density = TRUE
	can_buckle = 1
	use_power = NO_POWER_USE
	unacidable = TRUE	//aliens can't destroy the bomb

	resistance_flags = FULL_INDESTRUCTIBLE

	var/deployed = FALSE
	var/lighthack = FALSE
	var/opened = FALSE
	var/timeleft = TIMER_MAX
	var/timing = FALSE
	var/r_code = "ADMIN"
	var/safety = TRUE
	var/authorized = FALSE
	var/obj/item/weapon/disk/nuclear/auth = null
	var/datum/wires/nuclearbomb/wires = null
	var/removal_stage = 0 // 0 is no removal, 1 is covers removed, 2 is covers open,
	                      // 3 is sealant open, 4 is unwrenched, 5 is removed from bolts.
	var/detonated = FALSE //used for scoreboard.
	var/spray_icon_state
	var/nuketype = ""
	var/cur_code
	var/datum/announcement/station/nuke/announce_nuke = new

/obj/machinery/nuclearbomb/atom_init()
	. = ..()
	r_code = "[rand(10000, 99999.0)]"//Creates a random code upon object spawn.
	wires = new(src)

/obj/machinery/nuclearbomb/Destroy()
	QDEL_NULL(wires)
	QDEL_NULL(auth)
	return ..()

/obj/machinery/nuclearbomb/process()
	if(detonated || !timing)
		bomb_set = FALSE
	else
		bomb_set = TRUE //So long as there is one nuke timing, it means one nuke is armed.
		timeleft = max(timeleft - 2, 0) // 2 seconds per process()
		playsound(src, 'sound/items/timer.ogg', VOL_EFFECTS_MASTER, 30, FALSE)
		if(timeleft <= 0)
			explode()

/obj/machinery/nuclearbomb/attackby(obj/item/weapon/O, mob/user)
	if(isscrewing(O))
		add_fingerprint(user)
		if(removal_stage == 5)
			if(!opened)
				opened = TRUE
				to_chat(user, "You unscrew the control panel of [src].")
			else
				opened = FALSE
				to_chat(user, "You screw the control panel of [src] back on.")
		else if(auth)
			if(!opened)
				opened = TRUE
				to_chat(user, "You unscrew the control panel of [src].")
			else
				opened = FALSE
				to_chat(user, "You screw the control panel of [src] back on.")
		else
			if(!opened)
				to_chat(user, "The [src] emits a buzzing noise, the panel staying locked in.")
			if(opened)
				opened = FALSE
				to_chat(user, "You screw the control panel of [src] back on.")
		update_icon()
		return FALSE

	if(is_wire_tool(O) && opened)
		if(wires.interact(user))
			return FALSE

	if(istype(O, /obj/item/weapon/disk/nuclear))
		if(!deployed)
			if(!deploy(user))
				return
		insert_disk(user, O)
		return FALSE

	if(deployed)
		switch(removal_stage)
			if(0)
				if(iswelding(O))
					var/obj/item/weapon/weldingtool/WT = O
					if(!WT.isOn())
						return FALSE
					if (WT.get_fuel() < 5) // uses up 5 fuel.
						to_chat(user, "<span class = 'red'>You need more fuel to complete this task.</span>")
						return FALSE
					if(user.is_busy())
						return FALSE
					user.visible_message("[user] starts cutting thru something on [src] like \he knows what to do.", "With [O] you start cutting thru first layer...")

					if(O.use_tool(src, user, SKILL_TASK_CHALLENGING, amount = 5, volume = 50))
						user.visible_message("[user] finishes cutting something on [src].", "You cut thru first layer.")
						removal_stage = 1
				return FALSE
			if(1)
				if(isprying(O))
					user.visible_message("[user] starts smashing [src].", "You start forcing open the covers with [O]...")
					if(user.is_busy())
						return FALSE
					if(O.use_tool(src, user, SKILL_TASK_AVERAGE, volume = 50))
						user.visible_message("[user] finishes smashing [src].", "You force open covers.")
						removal_stage = 2
				return FALSE
			if(2)
				if(iswelding(O))
					var/obj/item/weapon/weldingtool/WT = O
					if(!WT.isOn())
						return FALSE
					if (WT.get_fuel() < 5) // uses up 5 fuel.
						to_chat(user, "<span class = 'red'>You need more fuel to complete this task.</span>")
						return FALSE
					if(user.is_busy())
						return FALSE
					user.visible_message("[user] starts cutting something on [src].. Again.", "You start cutting apart the safety plate with [O]...")

					if(O.use_tool(src, user, SKILL_TASK_DIFFICULT , amount = 5, volume = 50))
						user.visible_message("[user] finishes cutting something on [src].", "You cut apart the safety plate.")
						removal_stage = 3
				return FALSE
			if(3)
				if(iswrenching(O))
					if(user.is_busy())
						return FALSE
					user.visible_message("[user] begins poking inside [src].", "You begin unwrenching bolts...")
					if(O.use_tool(src, user, SKILL_TASK_TOUGH, volume = 50))
						user.visible_message("[user] begins poking inside [src].", "You unwrench bolts.")
						removal_stage = 4
				return FALSE
			if(4)
				if(isprying(O))
					if(user.is_busy())
						return FALSE
					user.visible_message("[user] begings hitting [src].", "You begin forcing open last safety layer...")
					if(O.use_tool(src, user, SKILL_TASK_TOUGH, volume = 50))
						user.visible_message("[user] finishes hitting [src].", "You can now get inside the [src]. Use screwdriver to open control panel")
						removal_stage = 5
				return FALSE
	return ..()

/obj/machinery/nuclearbomb/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/nuclearbomb/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NuclearBomb", name)
		ui.open()

/obj/machinery/nuclearbomb/tgui_data(mob/user)
	var/list/data = list()

	data["deployed"] = deployed
	data["timing"] = timing
	data["timeLeft"] = timeleft
	data["safety"] = safety
	data["hasDisk"] = auth ? TRUE : FALSE
	data["authorized"] = authorized
	data["code"] = cur_code
	data["timerMin"] = TIMER_MIN
	data["timerMax"] = TIMER_MAX

	return data

/obj/machinery/nuclearbomb/tgui_act(action, params)
	. = ..()
	if(.)
		return
	add_fingerprint(usr)
	switch(action)
		if("deploy")
			deploy(usr)
		if("ejectDisk")
			eject_disk(usr)
		if("toggleSafety")
			toggle_safety(usr)
		if("type")
			var/list/allowed_digits = list("1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "E", "R")
			var/digit = params["digit"]
			if(digit in allowed_digits)
				code_typed(usr, digit)
		if("adjustTimer")
			var/time = params["time"]
			adjust_timer(usr, time)
		if("bombSet")
			bomb_set(usr)
		if("insertDisk")
			insert_disk(usr)

	return TRUE

/obj/machinery/nuclearbomb/proc/insert_disk(mob/user, disk)
	if(disk)
		if(user.drop_from_inventory(disk, src))
			auth = disk
	else
		var/obj/item/I = usr.get_active_hand()
		if(istype(I, /obj/item/weapon/disk/nuclear))
			if(usr.drop_from_inventory(I, src))
				auth = I
	add_fingerprint(user)

/obj/machinery/nuclearbomb/proc/code_typed(mob/user, digit)
	if(!auth || !deployed)
		return
	if(digit == "E")
		if(r_code == cur_code)
			cur_code = null
			if(auth)
				authorized = TRUE
		else
			cur_code = "ERROR"
	else
		if(digit == "R")
			authorized = FALSE
			cur_code = null
			if(!timing)
				safety = TRUE
		else
			cur_code += digit
			if(length(cur_code) > 5)
				cur_code = "ERROR"
	update_icon()

/obj/machinery/nuclearbomb/proc/toggle_safety(mob/user)
	if(!authorized || timing && !safety)
		return
	safety = !safety

/obj/machinery/nuclearbomb/proc/adjust_timer(mob/user, time)
	if(authorized)
		timeleft = clamp(time, TIMER_MIN, TIMER_MAX)

/obj/machinery/nuclearbomb/proc/eject_disk(mob/user)
	if(auth)
		if(user && in_range(src, user))
			user.put_in_hands(auth)
		else
			auth.forceMove(loc)
		auth = null
		authorized = FALSE
		cur_code = null
		if(!timing)
			safety = TRUE
	update_icon()

/obj/machinery/nuclearbomb/proc/bomb_set(mob/user)
	if(!authorized || safety)
		return
	if(timing)
		timing = FALSE
		set_security_level("red")
	else
		var/area/nuclearbombloc = get_area(loc)
		announce_nuke.play(nuclearbombloc)
		set_security_level("delta")
		notify_ghosts("[src] has been activated!", source = src, action = NOTIFY_ORBIT, header = "Nuclear bomb")
		timing = TRUE
	update_icon()

/obj/machinery/nuclearbomb/proc/deploy(mob/user)
	if(deployed)
		if(timing)
			return FALSE
		to_chat(user, "<span class = 'red'>You close several panels to make [src] undeployed.</span>")
		visible_message("<span class = 'red'>The anchoring bolts slide back into the depths of [src] and timer has stopped.</span>")
		deployed = FALSE
		anchored = FALSE
		eject_disk(user)
	else
		if(user.incapacitated())
			return FALSE
		if(!ishuman(user))
			to_chat(user, "<span class = 'red'>You don't have the dexterity to do this!</span>")
			return FALSE
		if(!istype(get_area(src), /area/station)) // If outside of station
			to_chat(user, "<span class = 'red'>Bomb cannot be deployed here.</span>")
			return FALSE
		if(!ishuman(user) && !isobserver(user))
			to_chat(user, "<span class = 'red'>You don't have the dexterity to do this!</span>")
			return FALSE
		var/turf/current_location = get_turf(user)//What turf is the user on?
		if((!current_location || is_centcom_level(current_location.z)) && isnukeop(user))//If turf was not found or they're on z level 2.
			to_chat(user, "<span class = 'red'>It's not the best idea to plant a bomb on your own base.</span>")
			return FALSE
		if(!istype(get_area(src), /area/station)) // If outside of station
			to_chat(user, "<span class = 'red'>Bomb cannot be deployed here.</span>")
			return FALSE

		to_chat(user, "<span class = 'red'>You adjust some panels to make [src] deployed.</span>")
		visible_message("<span class = 'red'>With a steely snap, bolts slide out of [src] and anchor it to the flooring!</span>")
		deployed = TRUE
		anchored = TRUE
		if(!lighthack)
			flick("nuclearbomb3", src)
	update_icon()
	return TRUE

/obj/machinery/nuclearbomb/update_icon()
	cut_overlays()
	if(opened)
		add_overlay(image(icon, "npanel_open"))
	if(lighthack)
		icon_state = initial(icon_state)
	else if(detonated)
		icon_state = "nuclearbomb3"
	else if(timing)
		icon_state = "nuclearbombc"
	else if(authorized)
		icon_state = "nuclearbomb1"
	else if(deployed)
		icon_state = "nuclearbomb2"
	else
		icon_state = initial(icon_state)

/obj/machinery/nuclearbomb/is_operational()
	return TRUE

/obj/machinery/nuclearbomb/ex_act(severity)
	return

/obj/machinery/nuclearbomb/blob_act()
	if(detonated)
		return
	return ..()

#define NUKERANGE 80
/obj/machinery/nuclearbomb/proc/explode()
	if(safety)
		timing = FALSE
		timeleft = TIMER_MAX
		set_security_level("red")
		flick("nuclearbomb1", src)
		visible_message("<span class='notice'>\The [src] flicks with green. Looks like the safety fuse prevented explosion.</span>")
		update_icon()
		return
	if(detonated)
		return
	detonated = TRUE
	safety = TRUE
	update_icon()
	playsound(src, 'sound/machines/Alarm.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, 5)
	if(SSticker)
		SSticker.explosion_in_progress = TRUE
	sleep(100)

	SSlag_switch.set_measure(DISABLE_NON_OBSJOBS, TRUE)

	var/off_station = 0
	var/turf/bomb_location = get_turf(src)
	if( bomb_location && is_station_level(bomb_location.z) )
		if( (bomb_location.x < (128-NUKERANGE)) || (bomb_location.x > (128+NUKERANGE)) || (bomb_location.y < (128-NUKERANGE)) || (bomb_location.y > (128+NUKERANGE)) )
			off_station = 1
		else
			SSStatistics.score.nuked++
			sleep(10)
			SSticker.station_explosion_detonation(src)
	else
		off_station = 2

	if(SSticker)
		var/datum/faction/nuclear/N = find_faction_by_type(/datum/faction/nuclear)
		if(N)
			var/obj/machinery/computer/syndicate_station/syndie_location = locate(/obj/machinery/computer/syndicate_station)
			if(syndie_location)
				N.syndies_didnt_escape = is_station_level(syndie_location.z)
			N.nuke_off_station = off_station
		SSticker.station_explosion_cinematic(off_station,null)
		SSticker.explosion_in_progress = FALSE
		if(N)
			N.nukes_left = FALSE
		else
			to_chat(world, "<B>The station was destoyed by the nuclear blast!</B>")

		SSticker.station_was_nuked = (off_station<2)	//offstation==1 is a draw. the station becomes irradiated and needs to be evacuated.
														//kinda shit but I couldn't  get permission to do what I wanted to do.

		if(!SSticker.mode.check_finished())//If the mode does not deal with the nuke going off so just reboot because everyone is stuck as is
			to_chat(world, "<B>Resetting in 45 seconds!</B>")

			feedback_set_details("end_error","nuke - unhandled ending")

			if(blackbox)
				blackbox.save_all_data_to_sql()
			sleep(450)
			log_game("Rebooting due to nuclear detonation")
			world.Reboot(end_state = "nuke - unhandled ending")

/obj/machinery/nuclearbomb/MouseDrop_T(mob/living/M, mob/living/user)
	if(!ishuman(M) || !ishuman(user))
		return
	if(user.is_busy())
		return
	if(buckled_mob)
		do_after(usr, 30, 1, src)
		unbuckle_mob()
	else if(do_after(usr, 30, 1, src))
		M.loc = loc
		..()

/obj/machinery/nuclearbomb/post_buckle_mob(mob/living/M)
	if(M == buckled_mob)
		M.pixel_y = 10
	else
		M.pixel_y = M.default_pixel_y

/obj/machinery/nuclearbomb/bullet_act(obj/item/projectile/Proj, def_zone)
	. = ..()
	if(buckled_mob)
		buckled_mob.bullet_act(Proj)
		if(buckled_mob.weakened || buckled_mob.health < 0 || buckled_mob.halloss > 80)
			unbuckle_mob()

/obj/machinery/nuclearbomb/MouseDrop(over_object, src_location, over_location)
	..()
	if(!istype(over_object, /obj/structure/droppod))
		return
	if(!ishuman(usr) || !Adjacent(usr) || !Adjacent(over_object) || !usr.Adjacent(over_object))
		return
	var/obj/structure/droppod/D = over_object
	if(!timing && !auth && !buckled_mob)
		if(usr.is_busy())
			return
		visible_message("<span class='notice'>[usr] start putting [src] into [D]!</span>","<span class='notice'>You start putting [src] into [D]!</span>")
		if(do_after(usr, 100, 1, src) && !timing && !auth && !buckled_mob)
			D.Stored_Nuclear = src
			loc = D
			D.icon_state = "dropod_opened_n[D.item_state]"
			visible_message("<span class='notice'>[usr] put [src] into [D]!</span>","<span class='notice'>You succesfully put [src] into [D]!</span>")
			D.verbs += /obj/structure/droppod/proc/Nuclear

//==========DAT FUKKEN DISK===============
/obj/item/weapon/disk
	icon = 'icons/obj/items.dmi'
	w_class = SIZE_MINUSCULE
	item_state = "card-id"
	icon_state = "datadisk0"

/obj/item/weapon/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "nucleardisk"

/obj/item/weapon/disk/nuclear/atom_init()
	. = ..()
	poi_list += src
	START_PROCESSING(SSobj, src)

/obj/item/weapon/disk/nuclear/process()
	var/turf/disk_loc = get_turf(src)
	if(!is_centcom_level(disk_loc.z) && !is_station_level(disk_loc.z))
		to_chat(get(src, /mob), "<span class='danger'>You can't help but feel that you just lost something back there...</span>")
		qdel(src)

/obj/item/weapon/disk/nuclear/Destroy()
	if(blobstart.len > 0)
		var/turf/targetturf = get_turf(pick(blobstart))
		var/turf/diskturf = get_turf(src)
		forceMove(targetturf) //move the disc, so ghosts remain orbitting it even if it's "destroyed"
		message_admins("[src] has been destroyed in ([COORD(diskturf)] - [ADMIN_JMP(diskturf)]). Moving it to ([COORD(targetturf)] - [ADMIN_JMP(targetturf)]).")
		log_game("[src] has been destroyed in [COORD(diskturf)]. Moving it to [COORD(targetturf)].")
	else
		throw EXCEPTION("Unable to find a blobstart landmark")
	return QDEL_HINT_LETMELIVE //Cancel destruction regardless of success

#undef TIMER_MIN
#undef TIMER_MAX

/obj/machinery/nuclearbomb/fake
	var/false_activation = FALSE

/obj/machinery/nuclearbomb/fake/atom_init()
	. = ..()
	r_code = "HONK"
	if(SSticker)
		var/image/I = image('icons/obj/clothing/masks.dmi', src, "sexyclown")
		add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/faction, "fake_nuke", I, /datum/faction/nuclear)

/obj/machinery/nuclearbomb/fake/explode()
	if(safety)
		timing = FALSE
		return
	if(detonated)
		return
	detonated = TRUE
	playsound(src, 'sound/machines/Alarm.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, 30)
	update_icon()
	addtimer(CALLBACK(src, PROC_REF(fail)), 13 SECONDS) //Good taste, right?

/obj/machinery/nuclearbomb/fake/examine(mob/user, distance)
	. = ..()
	if(isnukeop(user) || isobserver(user))
		to_chat(user, "<span class ='boldwarning'>This is a fake one!</span>")

/obj/machinery/nuclearbomb/fake/process() //Yes, it's alike normal, but not exactly
	if(timing && !detonated)
		timeleft = max(timeleft - 2, 0) // 2 seconds per process()
		playsound(src, 'sound/items/timer.ogg', VOL_EFFECTS_MASTER, 30, FALSE)
		if(timeleft <= 0)
			explode()

/obj/machinery/nuclearbomb/fake/proc/fail(mob/user) //Resetting theatre of one actor and many watchers
	playsound(src, 'sound/effects/scary_honk.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, 30)
	detonated = FALSE
	timing = FALSE
	safety = TRUE
	deployed = FALSE
	anchored = FALSE
	update_icon()

/obj/machinery/nuclearbomb/fake/deploy(mob/user)
	if(false_activation)
		to_chat(user, "<span class = 'red'>It doesn't react. Maybe broken?</span>")
		return
	if(!isnukeop(user))
		to_chat(user, "<span class = 'red'>It doesn't react. Maybe broken?</span>")
		return
	if(tgui_alert(user, "False decoy activation. Continue?", "Decoy activation", list("Yes","No")) != "Yes")
		return
	deployed = TRUE
	anchored = TRUE
	timing = TRUE
	safety = FALSE
	false_activation = TRUE
	update_icon()
	return
