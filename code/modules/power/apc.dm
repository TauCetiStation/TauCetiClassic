//update_state
#define UPSTATE_CELL_IN 1
#define UPSTATE_OPENED1 2
#define UPSTATE_OPENED2 4
#define UPSTATE_MAINT 8
#define UPSTATE_BROKE 16
#define UPSTATE_BLUESCREEN 32
#define UPSTATE_WIREEXP 64
#define UPSTATE_ALLGOOD 128

//update_overlay
#define APC_UPOVERLAY_CHARGEING0 1
#define APC_UPOVERLAY_CHARGEING1 2
#define APC_UPOVERLAY_CHARGEING2 4
#define APC_UPOVERLAY_EQUIPMENT0 8
#define APC_UPOVERLAY_EQUIPMENT1 16
#define APC_UPOVERLAY_EQUIPMENT2 32
#define APC_UPOVERLAY_LIGHTING0 64
#define APC_UPOVERLAY_LIGHTING1 128
#define APC_UPOVERLAY_LIGHTING2 256
#define APC_UPOVERLAY_ENVIRON0 512
#define APC_UPOVERLAY_ENVIRON1 1024
#define APC_UPOVERLAY_ENVIRON2 2048
#define APC_UPOVERLAY_LOCKED 4096
#define APC_UPOVERLAY_OPERATING 8192

#define APC_UPDATE_ICON_COOLDOWN 50 // 5 seconds

#define APC_WAIT_FOR_CHARGE 10 // power ticks

// APC charging status:
/// The APC is not charging.
#define APC_NOT_CHARGING 0
/// The APC is charging.
#define APC_CHARGING 1
/// The APC is fully charged.
#define APC_FULLY_CHARGED 2

// APC autoset enums:
/// The APC turns automated and manual power channels off.
#define AUTOSET_FORCE_OFF 0
/// The APC turns automated power channels off.
#define AUTOSET_OFF 2
/// The APC turns automated power channels on.
#define AUTOSET_ON 1

// APC channel status:
/// The APCs power channel is manually set off.
#define APC_CHANNEL_OFF 0
/// The APCs power channel is automatically off.
#define APC_CHANNEL_AUTO_OFF 1
/// The APCs power channel is manually set on.
#define APC_CHANNEL_ON 2
/// The APCs power channel is automatically on.
#define APC_CHANNEL_AUTO_ON 3

// External power status:
/// The APC either isn't attached to a powernet or there is no power on the external powernet.
#define APC_NO_POWER 0
/// The APCs external powernet does not have enough power to charge the APC.
#define APC_LOW_POWER 1
/// The APCs external powernet has enough power to charge the APC.
#define APC_HAS_POWER 2

// APC cover status:
/// The APCs cover is closed.
#define APC_COVER_CLOSED 0
/// The APCs cover is open.
#define APC_COVER_OPENED 1
/// The APCs cover is missing.
#define APC_COVER_REMOVED 2


// the Area Power Controller (APC), formerly Power Distribution Unit (PDU)
// one per area, needs wire conection to power network

// controls power to devices in that area
// may be opened to change power cell
// three different channels (lighting/equipment/environ) - may each be set to on, off, or auto

//NOTE: STUFF STOLEN FROM AIRLOCK.DM thx


/obj/machinery/power/apc
	name = "area power controller"
	desc = "A control terminal for the area electrical systems."
	icon = 'icons/obj/power.dmi'
	icon_state = "apc0"
	anchored = TRUE
	use_power = NO_POWER_USE
	req_access = list(access_engine_equip)
	allowed_checks = ALLOWED_CHECK_NONE
	var/area/area
	var/areastring = null
	var/obj/item/weapon/stock_parts/cell/cell
	var/start_charge = 90 // initial cell charge %
	var/cell_type = 5000 // 0=no cell, 1=regular, 2=high-cap (x5) <- old, now it's just 0=no cell, otherwise dictate cellcapacity by changing this value. 1 used to be 1000, 2 was 2500
	var/opened = APC_COVER_CLOSED
	var/shorted = FALSE
	var/lighting = APC_CHANNEL_AUTO_ON
	var/equipment = APC_CHANNEL_AUTO_ON
	var/environ = APC_CHANNEL_AUTO_ON
	var/operating = 1
	var/charging = APC_NOT_CHARGING
	var/chargemode = 1
	var/chargecount = 0
	var/locked = 1
	var/coverlocked = 1
	var/aidisabled = 0
	var/tdir = null
	var/obj/machinery/power/terminal/terminal = null
	var/lastused_light = 0
	var/lastused_equip = 0
	var/lastused_environ = 0
	var/lastused_total = 0
	var/main_status = 0
	var/wiresexposed = FALSE
	powernet = 0 //HACK: set so that APCs aren't found as powernet nodes //Hackish, Horrible, was like this before I changed it :(
	var/malfhack = 0 // New var for my changes to AI malf. --NeoFite
	var/mob/living/silicon/ai/malfai = null // See above --NeoFite
	var/debug = 0
	var/autoflag = 0 // For optimization. 0 = off, 1 = eqp and lights off, 2 = eqp off, 3 = all on, other = re-autoset
	var/has_electronics = 0 // 0 - none, 1 - plugged in, 2 - secured by screwdriver
	var/overload = 1 // used for the Blackout malf module
	var/beenhit = 0 // used for counting how many times it has been hit, used for Aliens at the moment
	var/longtermpower = 10

	var/datum/smartlight_preset/smartlight_preset
	var/custom_smartlight_preset // optional /datum/smartlight_preset preset name to expand default SSsmartlight preset. For bar area, rnd/med, etc.
	var/datum/light_mode/light_mode
	var/nightshift_lights = FALSE
	COOLDOWN_DECLARE(smartlight_switch)

	var/update_state = -1
	var/update_overlay = -1
	var/static/status_overlays = 0
	var/updating_icon = 0
	var/datum/wires/apc/wires = null
	var/static/list/status_overlays_lock
	var/static/list/status_overlays_charging
	var/static/list/status_overlays_equipment
	var/static/list/status_overlays_lighting
	var/static/list/status_overlays_environ
	required_skills = list()


/obj/machinery/power/apc/atom_init(mapload, ndir, building = 0)
	. = ..()
	apc_list += src
	wires = new(src)

	// offset 27 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if(building)
		set_dir(ndir)
	tdir = dir		// to fix Vars bug
	set_dir(SOUTH)

	pixel_x = (tdir & 3) ? 0 : (tdir == 4 ? 27 : -27)
	pixel_y = (tdir & 3) ? (tdir == 1 ? 27 : -27) : 0
	if(building == 0)
		init()
	else
		area = get_area(src)
		area.apc = src
		opened = APC_COVER_OPENED
		operating = 0
		name = "[area.name] APC"
		stat |= MAINT
		update_icon()
		addtimer(CALLBACK(src, PROC_REF(update)), 5)

	init_smartlight()

/obj/machinery/power/apc/Destroy()
	apc_list -= src
	if(malfai && operating)
		var/datum/faction/malf_silicons/GM = find_faction_by_type(/datum/faction/malf_silicons)
		if(GM && is_station_level(z))
			SSticker.hacked_apcs--
	area.apc = null
	area.power_light = 0
	area.power_equip = 0
	area.power_environ = 0
	area.power_change()
	area.poweralert(FALSE, src) // Remove the power alert
	QDEL_NULL(wires)
	QDEL_NULL(cell)
	if(terminal)
		disconnect_terminal()
	return ..()

/obj/machinery/power/apc/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null

/obj/machinery/power/apc/make_terminal()
	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new/obj/machinery/power/terminal(src.loc)
	terminal.set_dir(tdir)
	terminal.master = src

/obj/machinery/power/apc/proc/init()
	has_electronics = 2 // installed and secured
	// is starting with a power cell installed, create it and set its charge level
	if(cell_type)
		cell = new/obj/item/weapon/stock_parts/cell(src)
		cell.maxcharge = cell_type	// cell_type is maximum charge (old default was 1000 or 2500 (values one and two respectively)
		cell.charge = start_charge * cell.maxcharge / 100.0 // (convert percentage to actual value)

	var/area/A = src.loc.loc

	//if area isn't specified use current
	if(isarea(A) && src.areastring == null)
		src.area = A
		name = "[area.name] APC"
	else
		src.area = get_area_by_name(areastring)
		name = "[area.name] APC"
	area.apc = src
	update_icon()

	make_terminal()

	addtimer(CALLBACK(src, PROC_REF(update)), 5)

/obj/machinery/power/apc/examine(mob/user)
	..()
	if (in_range(user, src))
		if(stat & BROKEN)
			to_chat(user, "Looks broken.")
			return
		if(opened != APC_COVER_CLOSED)
			if(has_electronics && terminal)
				to_chat(user, "The cover is [opened == APC_COVER_REMOVED ? "removed" : "open"] and the power cell is [ cell ? "installed" : "missing"].")
			else if(!has_electronics && terminal)
				to_chat(user, "There are some wires but no any electronics.")
			else if(has_electronics && !terminal)
				to_chat(user, "Electronics installed but not wired.")
			else
				to_chat(user, "There is no electronics nor connected wires.")
		else
			if(stat & MAINT)
				to_chat(user, "The cover is closed. Something wrong with it: it doesn't work.")
			else if(malfhack)
				to_chat(user, "The cover is broken. It may be hard to force it open.")
			else
				to_chat(user, "The cover is closed.")

// update the APC icon to show the three base states
// also add overlays for indicator lights
/obj/machinery/power/apc/update_icon()
	if(!status_overlays)
		status_overlays = 1
		status_overlays_lock = new
		status_overlays_charging = new
		status_overlays_equipment = new
		status_overlays_lighting = new
		status_overlays_environ = new

		status_overlays_lock.len = 2
		status_overlays_charging.len = 3
		status_overlays_equipment.len = 4
		status_overlays_lighting.len = 4
		status_overlays_environ.len = 4

		status_overlays_lock[1] = image(icon, "apcox-0") // 0=blue 1=red
		status_overlays_lock[2] = image(icon, "apcox-1")

		status_overlays_charging[1] = image(icon, "apco3-0")
		status_overlays_charging[2] = image(icon, "apco3-1")
		status_overlays_charging[3] = image(icon, "apco3-2")

		status_overlays_equipment[1] = image(icon, "apco0-0") // 0=red, 1=green, 2=blue
		status_overlays_equipment[2] = image(icon, "apco0-1")
		status_overlays_equipment[3] = image(icon, "apco0-2")
		status_overlays_equipment[4] = image(icon, "apco0-3")

		status_overlays_lighting[1] = image(icon, "apco1-0")
		status_overlays_lighting[2] = image(icon, "apco1-1")
		status_overlays_lighting[3] = image(icon, "apco1-2")
		status_overlays_lighting[4] = image(icon, "apco1-3")

		status_overlays_environ[1] = image(icon, "apco2-0")
		status_overlays_environ[2] = image(icon, "apco2-1")
		status_overlays_environ[3] = image(icon, "apco2-2")
		status_overlays_environ[4] = image(icon, "apco2-3")

	var/update = check_updates() // returns 0 if no need to update icons.
	                             // 1 if we need to update the icon_state
	                             // 2 if we need to update the overlays
	if(!update)
		return

	if(update & 1) // Updating the icon state
		if(update_state & UPSTATE_ALLGOOD)
			icon_state = "apc0"
		else if(update_state & UPSTATE_BROKE)
			if(update_state & UPSTATE_OPENED1)
				icon_state = "apc1-b-nocover"
			else
				icon_state = "apc-b"
		else if(update_state & (UPSTATE_OPENED1 | UPSTATE_OPENED2))
			var/basestate = "apc[ cell ? "2" : "1" ]"
			if(update_state & UPSTATE_OPENED1)
				if(update_state & (UPSTATE_MAINT | UPSTATE_BROKE))
					icon_state = "apcmaint" // disabled APC cannot hold cell
				else
					icon_state = basestate
		else if(update_state & UPSTATE_BLUESCREEN)
			icon_state = "apcemag"
		else if(update_state & UPSTATE_WIREEXP)
			icon_state = "apcewires"

	if(!(update_state & UPSTATE_ALLGOOD)) // Not normal state - no overlays
		if(overlays.len)
			cut_overlays()
			return

	if(update & 2) // Updating the overlays
		if(overlays.len)
			cut_overlays()

		if(!(stat & (BROKEN | MAINT)) && (update_state & UPSTATE_ALLGOOD))
			add_overlay(status_overlays_lock[locked + 1])
			add_overlay(status_overlays_charging[charging + 1])
			if(operating)
				add_overlay(status_overlays_equipment[equipment + 1])
				add_overlay(status_overlays_lighting[lighting + 1])
				add_overlay(status_overlays_environ[environ + 1])

/obj/machinery/power/apc/proc/check_updates()
	var/last_update_state = update_state
	var/last_update_overlay = update_overlay
	update_state = 0
	update_overlay = 0

	if(cell)
		update_state |= UPSTATE_CELL_IN
	if(stat & BROKEN)
		update_state |= UPSTATE_BROKE
	if(stat & MAINT)
		update_state |= UPSTATE_MAINT
	if(opened != APC_COVER_CLOSED)
		if(opened == APC_COVER_OPENED)
			update_state |= UPSTATE_OPENED1
	else if(emagged || malfai)
		update_state |= UPSTATE_BLUESCREEN
	else if(wiresexposed)
		update_state |= UPSTATE_WIREEXP
	if(update_state <= 1)
		update_state |= UPSTATE_ALLGOOD

	if(operating)
		update_overlay |= APC_UPOVERLAY_OPERATING

	if(update_state & UPSTATE_ALLGOOD)
		if(locked)
			update_overlay |= APC_UPOVERLAY_LOCKED

		if(charging == APC_NOT_CHARGING)
			update_overlay |= APC_UPOVERLAY_CHARGEING0
		else if(charging == APC_CHARGING)
			update_overlay |= APC_UPOVERLAY_CHARGEING1
		else if(charging == APC_FULLY_CHARGED)
			update_overlay |= APC_UPOVERLAY_CHARGEING2

		if(equipment == APC_CHANNEL_OFF)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT0
		else if(equipment == APC_CHANNEL_AUTO_OFF)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT1
		else if(equipment == APC_CHANNEL_AUTO_ON)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT2

		if(lighting == APC_CHANNEL_OFF)
			update_overlay |= APC_UPOVERLAY_LIGHTING0
		else if(lighting == APC_CHANNEL_AUTO_OFF)
			update_overlay |= APC_UPOVERLAY_LIGHTING1
		else if(lighting == APC_CHANNEL_AUTO_ON)
			update_overlay |= APC_UPOVERLAY_LIGHTING2

		if(environ == APC_CHANNEL_OFF)
			update_overlay |= APC_UPOVERLAY_ENVIRON0
		else if(environ == APC_CHANNEL_AUTO_OFF)
			update_overlay |= APC_UPOVERLAY_ENVIRON1
		else if(environ == APC_CHANNEL_AUTO_ON)
			update_overlay |= APC_UPOVERLAY_ENVIRON2

	var/results = 0
	if(last_update_state == update_state && last_update_overlay == update_overlay)
		return 0
	if(last_update_state != update_state)
		results += 1
	if(last_update_overlay != update_overlay && update_overlay != 0)
		results += 2
	return results

/obj/machinery/power/apc/proc/queue_icon_update()
	set waitfor = FALSE
	if(!updating_icon)
		updating_icon = 1
		// Start the update
		sleep(APC_UPDATE_ICON_COOLDOWN)
		update_icon()
		updating_icon = 0


//attack with an item - open/close cover, insert cell, or (un)lock interface

/obj/machinery/power/apc/attackby(obj/item/W, mob/user)

	if(issilicon(user) && get_dist(src,user) > 1)
		return attack_hand(user)
	add_fingerprint(user)
	if(isprying(W) && opened != APC_COVER_CLOSED)
		if(has_electronics == 1)
			if(terminal)
				to_chat(user, "<span class='warning'>Disconnect wires first.</span>")
				return
			if(user.is_busy(src))
				return
			to_chat(user, "You are trying to remove the power control board...") // lpeters - fixed grammar issues
			if(W.use_tool(src, user, 50, volume = 50))
				has_electronics = 0
				area.poweralert(FALSE, src)
				if((stat & BROKEN) || malfhack)
					user.visible_message(\
						"<span class='warning'>[user.name] has broken the power control board inside [src.name]!</span>",\
						"You broke the charred power control board and remove the remains.",
						"You hear a crack!")
					//SSticker.mode:apcs-- //XSI said no and I agreed. -rastaf0
				else
					user.visible_message(\
						"<span class='warning'>[user.name] has removed the power control board from [src.name]!</span>",\
						"You remove the power control board.")
					new /obj/item/weapon/module/power_control(loc)
		else if(opened != APC_COVER_REMOVED) // cover isn't removed
			opened = APC_COVER_CLOSED
			update_icon()

	else if(isprying(W) && opened == APC_COVER_CLOSED)
		if(stat & BROKEN)
			user.visible_message("<span class='warning'>[user.name] try open [src.name] cover.</span>", "<span class='notice'>You try open [src.name] cover.</span>")
			if(W.use_tool(src, user, 25, volume = 25))
				opened = APC_COVER_OPENED
				locked = FALSE
				if(cell)
					to_chat(user, "<span class='notice'>Power cell from [src.name] is dropped</span>")
					cell.forceMove(user.loc)
					cell = null
				update_icon()

		else if(!(stat & BROKEN) || !malfhack)
			if(coverlocked && !(stat & MAINT))
				to_chat(user, "<span class='warning'>The cover is locked and cannot be opened.</span>")
				return
			else
				opened = APC_COVER_OPENED
				update_icon()

	else if(iswrenching(W) && opened != APC_COVER_CLOSED && (stat & BROKEN))
		if(coverlocked)
			to_chat(user, "<span class='notice'>Remove security APC bolts.</span>")
			if(W.use_tool(src, user, 5, volume = 5))
				coverlocked = FALSE
				update_icon()
		else
			to_chat(user, "<span class='warning'>APC bolts alredy removed.</span>")

	else if	(istype(W, /obj/item/weapon/stock_parts/cell) && opened != APC_COVER_CLOSED) // trying to put a cell inside
		if(cell)
			to_chat(user, "There is a power cell already installed.")
			return
		else
			if(stat & MAINT)
				to_chat(user, "<span class='warning'>There is no connector for your power cell.</span>")
				return
			user.drop_from_inventory(W, src)
			cell = W
			user.visible_message(\
				"<span class='warning'>[user.name] has inserted the power cell to [src.name]!</span>",\
				"You insert the power cell.")
			chargecount = 0
			update_icon()

	else if	(isscrewing(W)) // haxing
		if(opened != APC_COVER_CLOSED)
			if(cell)
				to_chat(user, "<span class='warning'>Close the APC first.</span>") // Less hints more mystery!
				return
			else
				if(has_electronics == 1 && terminal)
					has_electronics = 2
					stat &= ~MAINT
					playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
					to_chat(user, "You screw the circuit electronics into place.")
				else if(has_electronics == 2)
					has_electronics = 1
					stat |= MAINT
					playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
					to_chat(user, "You unfasten the electronics.")
				else // has_electronics == 0
					to_chat(user, "<span class='warning'>There is nothing to secure.</span>")
					return
				update_icon()

		else if(emagged)
			to_chat(user, "The interface is broken.")
		else if(!(stat & BROKEN))
			wiresexposed = !wiresexposed
			to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"]")
			update_icon()

	else if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda)) // trying to unlock the interface with an ID card
		if(emagged)
			to_chat(user, "The interface is broken.")
		else if(opened != APC_COVER_CLOSED)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else if(wiresexposed)
			to_chat(user, "You must close the panel")
		else if(stat & (BROKEN|MAINT))
			to_chat(user, "Nothing happens.")
		else
			if(allowed(usr) && !wires.is_index_cut(APC_WIRE_IDSCAN))
				locked = !locked
				to_chat(user, "You [ locked ? "lock" : "unlock"] the APC interface.")
				update_icon()
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")

	else if(istype(W, /obj/item/weapon/card/emag) && !(emagged || malfhack)) // trying to unlock with an emag card
		if(opened != APC_COVER_CLOSED)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else if(wiresexposed)
			to_chat(user, "You must close the panel first")
		else if(stat & (BROKEN|MAINT))
			to_chat(user, "Nothing happens.")
		else
			if(user.is_busy(src))
				return
			flick("apc-spark", src)
			if(W.use_tool(src, user, 6, volume = 50))
				if(prob(50))
					emagged = 1
					locked = 0
					to_chat(user, "You emag the APC interface.")
					update_icon()
					SSticker.hacked_apcs++
					announce_hacker()
				else
					to_chat(user, "You fail to [ locked ? "unlock" : "lock"] the APC interface.")

	else if(iscoil(W) && !terminal && opened != APC_COVER_CLOSED && has_electronics != 2)
		var/turf/TT = get_turf(src)
		if(TT.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
			to_chat(user, "<span class='warning'>You must remove the floor plating in front of the APC first.</span>")
			return
		var/obj/item/stack/cable_coil/C = W
		if(C.get_amount() < 10)
			to_chat(user, "<span class='warning'>You need more wires.</span>")
			return
		if(user.is_busy()) return
		to_chat(user, "You start adding cables to the APC frame...")
		if(C.use_tool(src, user, 20, volume = 50) && C.get_amount() >= 10)
			var/turf/T = get_turf_loc(src)
			var/obj/structure/cable/N = T.get_cable_node()
			if(prob(50) && electrocute_mob(usr, N, N))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				return
			C.use(10)
			user.visible_message(\
				"<span class='warning'>[user.name] has added cables to the APC frame!</span>",\
				"You add cables to the APC frame.")
			make_terminal()
			terminal.connect_to_network()

	else if(iscutter(W) && terminal && opened != APC_COVER_CLOSED && has_electronics!=2)
		terminal.dismantle(user)

	else if(istype(W, /obj/item/weapon/module/power_control) && opened != APC_COVER_CLOSED && has_electronics == 0 && !((stat & BROKEN) || malfhack))
		if(user.is_busy()) return
		to_chat(user, "You trying to insert the power control board into the frame...")
		if(W.use_tool(src, user, 10, volume = 50))
			has_electronics = 1
			to_chat(user, "You place the power control board inside the frame.")
			qdel(W)

	else if(istype(W, /obj/item/weapon/module/power_control) && opened != APC_COVER_CLOSED && has_electronics == 0 && ((stat & BROKEN) || malfhack))
		to_chat(user, "<span class='warning'>You cannot put the board inside, the frame is damaged.</span>")
		return

	else if(iswelding(W) && opened != APC_COVER_CLOSED && has_electronics == 0 && !terminal)
		if(user.is_busy()) return
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.get_fuel() < 3)
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return
		to_chat(user, "You start welding the APC frame...")
		if(WT.use_tool(src, user, 50, amount = 3, volume = 50))
			deconstruct(TRUE, user)
			return

	else if(istype(W, /obj/item/apc_frame) && opened != APC_COVER_CLOSED && emagged)
		emagged = 0
		if(opened == APC_COVER_REMOVED)
			opened = APC_COVER_OPENED
		user.visible_message(\
			"<span class='warning'>[user.name] has replaced the damaged APC frontal panel with a new one.</span>",\
			"You replace the damaged APC frontal panel with a new one.")
		qdel(W)
		update_icon()

	else if(istype(W, /obj/item/apc_frame) && opened != APC_COVER_CLOSED && ((stat & BROKEN) || malfhack))
		if(has_electronics)
			to_chat(user, "You cannot repair this APC until you remove the electronics still inside.")
			return
		if(user.is_busy()) return
		to_chat(user, "You begin to replace the damaged APC frame...")
		if(W.use_tool(src, user, 50, volume = 50))
			user.visible_message(\
				"<span class='warning'>[user.name] has replaced the damaged APC frame with new one.</span>",\
				"You replace the damaged APC frame with new one.")
			qdel(W)
			stat &= ~BROKEN
			malfai = null
			malfhack = 0
			if(opened == APC_COVER_REMOVED)
				opened = APC_COVER_OPENED
			update_icon()

	else if(opened == APC_COVER_CLOSED && wiresexposed && is_wire_tool(W))
		if(issilicon(user))
			return wires.interact(user)
		user.SetNextMove(CLICK_CD_MELEE)
		user.visible_message("<span class='warning'>The [src.name] has been hit with the [W.name] by [user.name]!</span>", \
			"<span class='warning'>You hit the [src.name] with your [W.name]!</span>", \
			"You hear bang")
		return wires.interact(user)
	else
		..()


/obj/machinery/power/apc/deconstruct(disassembled, mob/user)
	if(flags & NODECONSTRUCT)
		return ..()
	if(!disassembled || emagged || malfhack || (stat & BROKEN) || opened == APC_COVER_REMOVED)
		new /obj/item/stack/sheet/metal(loc)
		user?.visible_message(\
			"<span class='warning'>[src] has been cut apart by [user.name] with the weldingtool.</span>",\
			"You disassembled the broken APC frame.",\
			"<span class='warning'>You hear welding.</span>")
	else
		new /obj/item/apc_frame(loc)
		user?.visible_message(\
				"<span class='warning'>[src] has been cut from the wall by [user.name] with the weldingtool.</span>",\
				"You cut the APC frame from the wall.",\
				"<span class='warning'>You hear welding.</span>")

	..()

// attack with hand - remove cell (if cover open) or interact with the APC

/obj/machinery/power/apc/interact(mob/user)
	// Synthetic human mob goes here.
	if(user.is_busy())
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/internal/liver/IO = H.organs_by_name[O_LIVER]
		var/obj/item/weapon/stock_parts/cell/C = locate(/obj/item/weapon/stock_parts/cell) in IO
		if(H.species.flags[IS_SYNTHETIC] && H.a_intent == INTENT_GRAB && C)
			user.SetNextMove(CLICK_CD_MELEE)
			if(emagged || (stat & BROKEN))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(3, 1, src)
				s.start()
				to_chat(H, "<span class='warning'>The APC power currents surge eratically, damaging your chassis!</span>")
				H.adjustFireLoss(10,0)
			else if(src.cell && src.cell.charge > 500 && H.a_intent == INTENT_GRAB)
				if(H.nutrition < C.maxcharge*0.9)
					if(src.cell.charge)
						to_chat(user, "<span class='notice'>You slot your fingers into the APC interface and start siphon off some of the stored charge for your own use.</span>")
						while(H.nutrition < C.maxcharge)
							if(do_after(user,10,target = src) && H.a_intent == INTENT_GRAB)
								if(!src.cell)
									to_chat(user, "<span class='notice'>There is no cell.</span>")
									break
								else if(emagged || malfhack || (stat & (BROKEN|EMPED)) || shorted)
									break
								else if(H.nutrition > C.maxcharge*0.9)
									to_chat(user, "<span class='notice'>You're fully charge.</span>")
									break
								else if(src.cell.charge < src.cell.maxcharge*0.1)
									to_chat (user, "<span class='notice'>There is not enough charge to draw from that APC.</span>")
									break

								else if(cell.use(500))
									H.nutrition += C.maxcharge*0.1
									to_chat(user, "<span class='notice'>Draining... Battery has [round(100.0*H.nutrition/C.maxcharge)]% of charge.</span>")

							else
								to_chat (user, "<span class='warning'>Procedure interrupted. Protocol terminated.</span>")
								break
					else

						H.nutrition += src.cell.charge/10
						src.cell.charge = 0

					if(!src.cell)
						src.charging = APC_NOT_CHARGING
						return

					if(emagged || malfhack || (stat & (BROKEN|EMPED)) || shorted)
						var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
						s.set_up(3, 1, src)
						s.start()
						to_chat (user, "<span class='warning'>Something wrong with that APC.</span>")
						H.adjustFireLoss(10,0)
						return

					if(src.cell.charge < 0)
						src.cell.charge = 0
					if(H.nutrition > C.maxcharge)
						H.nutrition = C.maxcharge

					src.charging = APC_CHARGING

				else
					to_chat(user, "<span class='notice'>You are already fully charged.</span>")
			else
				to_chat(user, "There is no charge to draw from that APC.")
			return

	if(usr == user && opened != APC_COVER_CLOSED && !issilicon(user) && !isobserver(user))
		if(cell)
			user.put_in_hands(cell)
			cell.add_fingerprint(user)
			cell.updateicon()

			src.cell = null
			user.visible_message("<span class='warning'>[user.name] removes the power cell from [src.name]!</span>", "You remove the power cell.")
			charging = APC_NOT_CHARGING
			update_icon()
		return
	// do APC interaction
	..()

/obj/machinery/power/apc/attack_alien(mob/living/carbon/xenomorph/humanoid/user)
	to_chat(user, "You don't want to break these things");
	return

/obj/machinery/power/apc/proc/get_malf_status(mob/living/silicon/ai/malf)
	if(ismalf(malf) && istype(malf))
		if(src.malfai == (malf.parent || malf))
			return 2 // 2 = APC hacked by user, and user is in its core.
		else
			return 1 // 1 = APC not hacked.
	else
		return 0 // 0 = User is not a Malf AI

/obj/machinery/power/apc/proc/update()
	if(operating && !shorted)
		area.power_light = (lighting >= APC_CHANNEL_ON)
		area.power_equip = (equipment >= APC_CHANNEL_ON)
		area.power_environ = (environ >= APC_CHANNEL_ON)
	else
		area.power_light = 0
		area.power_equip = 0
		area.power_environ = 0
	area.power_change()


// UI stuff ////////////////////

/obj/machinery/power/apc/is_operational()
	return !(stat & (BROKEN | MAINT | EMPED))

/obj/machinery/power/apc/tgui_state(mob/user)
	return global.machinery_state

/obj/machinery/power/apc/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/power/apc/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Apc", name)
		ui.open()

/obj/machinery/power/apc/tgui_data(mob/user)
	var/list/data = list(
		"locked" = locked,
		"isOperating" = operating,
		"externalPower" = main_status,
		"powerCellStatus" = cell != null,
		"powerCellCharge" = cell ? cell.percent() : 0,
		"chargeMode" = chargemode,
		"charging" = charging,
		"totalLoad" = DisplayPower(lastused_total),
		"coverLocked" = coverlocked,
		"siliconUser" = issilicon(user) || isobserver(user),
		"malfCanHack" = get_malf_status(user),
		"nightshiftLights" = nightshift_lights,
		"smartlightMode" = SSsmartlight.forced_admin_mode ? "unknown" : light_mode.name,

		"powerChannels" = list(
			list(
				"title" = "Equipment",
				"powerLoad" = DisplayPower(lastused_equip),
				"status" = equipment,
				"topicParams" = list(
					"auto" = list("eqp" = 3),
					"on"   = list("eqp" = 2),
					"off"  = list("eqp" = 1)
				)
			),
			list(
				"title" = "Lighting",
				"powerLoad" = DisplayPower(lastused_light),
				"status" = lighting,
				"topicParams" = list(
					"auto" = list("lgt" = 3),
					"on"   = list("lgt" = 2),
					"off"  = list("lgt" = 1)
				)
			),
			list(
				"title" = "Environment",
				"powerLoad" = DisplayPower(lastused_environ),
				"status" = environ,
				"topicParams" = list(
					"auto" = list("env" = 3),
					"on"   = list("env" = 2),
					"off"  = list("env" = 1)
				)
			)
		)
	)
	return data

/obj/machinery/power/apc/proc/report()
	return "[area.name] : [equipment]/[lighting]/[environ] ([lastused_equip+lastused_light+lastused_environ]) : [cell ? cell.percent() : "N/C"] ([charging])"

/obj/machinery/power/apc/proc/can_use(mob/user, loud = FALSE, act = "")
	if(IsAdminGhost(user))
		return TRUE
	if(!user.client)
		return FALSE

	autoflag = 5

	if(issilicon(user))
		var/mob/living/silicon/ai/AI = user
		var/mob/living/silicon/robot/robot = user
		if(                                                                \
		    aidisabled ||                                                  \
		    malfhack && istype(malfai) &&                                  \
		    (                                                              \
		        (istype(AI) && (malfai != AI && malfai != AI.parent)) ||   \
		        (istype(robot) && (robot in malfai.connected_robots))      \
		    )                                                              \
		) // No AI control or hacked by other MalfAI
			if(!loud)
				to_chat(user, "<span class='warning'>\The [src] have AI control disabled!</span>")
			return FALSE

	else // Human
		if(locked && act != "toggle_nightshift" && act != "change_smartlight")
			return FALSE

	return TRUE

/obj/machinery/power/apc/tgui_act(action, params)
	. = ..()
	if(.)
		return
	if(!can_use(user = usr, loud = TRUE, act = action))
		return

	switch(action)
		if("lock")
			if(issilicon(usr) && !aidisabled)
				locked = !locked
				update_icon()
				. = TRUE
		if("cover")
			coverlocked = !coverlocked
			. = TRUE
		if("breaker")
			toggle_breaker(usr)
			. = TRUE
		if("toggle_nightshift")
			if(SSsmartlight.forced_admin_mode)
				to_chat(usr, "<span class='notice'>Nothing happens.</span>")
				return

			if(!COOLDOWN_FINISHED(src, smartlight_switch))
				to_chat(usr, "<span class='warning'>[src]'s smart lighting circuit breaker is still cycling!</span>")
				return

			COOLDOWN_START(src, smartlight_switch, 4 SECONDS)
			toggle_nightshift(!nightshift_lights)
			. = TRUE
		if("change_smartlight")
			if(SSsmartlight.forced_admin_mode)
				to_chat(usr, "<span class='notice'>Nothing happens.</span>")
				return

			var/list/datum/light_mode/available_modes = smartlight_preset.get_user_available_modes()
			var/mode_name = input(usr, "Please choose lighting mode.") as null|anything in available_modes

			if(!COOLDOWN_FINISHED(src, smartlight_switch))
				to_chat(usr, "<span class='warning'>[src]'s smart lighting circuit breaker is still cycling!</span>")
				return

			if(mode_name)
				COOLDOWN_START(src, smartlight_switch, 4 SECONDS)
				set_light_mode(available_modes[mode_name])
			. = TRUE
		if("charge")
			chargemode = !chargemode
			if(!chargemode)
				charging = APC_NOT_CHARGING
				update_icon()
			. = TRUE
		if("channel")
			if(params["eqp"])
				equipment = setsubsystem(text2num(params["eqp"]))
				update_icon()
				update()
			else if(params["lgt"])
				lighting = setsubsystem(text2num(params["lgt"]))
				update_icon()
				update()
			else if(params["env"])
				environ = setsubsystem(text2num(params["env"]))
				update_icon()
				update()
			. = TRUE
		if("overload")
			if((issilicon(usr) && !aidisabled) || isobserver(usr))
				overload_lighting()
				. = TRUE
		if("hack")
			if(issilicon(usr) && !aidisabled)
				malf_hack(usr)
				. = TRUE

/obj/machinery/power/apc/proc/toggle_breaker(mob/user)
	operating = !operating
	if(user)
		add_hiddenprint(user)
	if(malfai)
		var/datum/faction/malf_silicons/GM = find_faction_by_type(/datum/faction/malf_silicons)
		if(GM && is_station_level(z))
			operating ? SSticker.hacked_apcs++ : SSticker.hacked_apcs--
	update()
	update_icon()

/obj/machinery/power/apc/proc/malf_hack(mob/living/silicon/ai/ai)
	if(ai.malfhacking)
		to_chat(ai, "<span class='warning'>You are already hacking an APC.</span>")
		return FALSE
	to_chat(ai, "Beginning override of APC systems. This takes some time, and you cannot perform other actions during the process.")
	ai.malfhack = src
	ai.malfhacking = TRUE
	addtimer(CALLBACK(src, PROC_REF(malf_hack_done), ai), 600)

/obj/machinery/power/apc/proc/malf_hack_done(mob/living/silicon/ai/ai)
	if(!aidisabled)
		ai.malfhack = null
		ai.malfhacking = FALSE
		var/datum/faction/malf_silicons/GM = find_faction_by_type(/datum/faction/malf_silicons)
		if(GM && is_station_level(z))
			SSticker.hacked_apcs++
		if(ai.parent)
			malfai = ai.parent
		else
			malfai = ai
		to_chat(ai, "Hack complete. The APC is now under your exclusive control.")
		announce_hacker()
		update_icon()

/obj/machinery/power/apc/proc/announce_hacker()
	var/hacked_amount = SSticker.hacked_apcs
	var/lowest_treshold = 3//lowest treshold in hacked apcs for an announcement to start
	var/datum/faction/malf_silicons/malf_ai = find_faction_by_type(/datum/faction/malf_silicons)
	if(malf_ai && malf_ai.intercept_hacked)
		lowest_treshold += malf_ai.intercept_apcs
	switch (SSticker.Malf_announce_stage)
		if(0)
			if(hacked_amount >= lowest_treshold)
				SSticker.Malf_announce_stage = 1
				lowest_treshold += 2
				var/datum/announcement/centcomm/malf/first/announce_first = new
				announce_first.play()
		if(1)
			if(hacked_amount >= lowest_treshold)
				SSticker.Malf_announce_stage = 2
				lowest_treshold += 2
				var/datum/announcement/centcomm/malf/second/announce_second = new
				announce_second.play()
		if(2)
			if(hacked_amount >= lowest_treshold)
				SSticker.Malf_announce_stage = 3
				lowest_treshold += 2
				var/datum/announcement/centcomm/malf/third/announce_third = new
				announce_third.play()
		if(3)
			if(hacked_amount >= lowest_treshold)
				SSticker.Malf_announce_stage = 4
				var/datum/announcement/centcomm/malf/fourth/announce_forth = new
				announce_forth.play()
////////////////////////////////


/obj/machinery/power/apc/proc/ion_act()
	// intended to be exactly the same as an AI malf attack
	if(!src.malfhack && is_station_level(z))
		if(prob(3))
			src.locked = 1
			if(src.cell.charge > 0)
				src.cell.charge = 0
				cell.corrupt()
				src.malfhack = 1
				update_icon()
				var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
				smoke.set_up(3, 0, src.loc)
				smoke.attach(src)
				smoke.start()
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(3, 1, src)
				s.start()
				visible_message("<span class='warning'>The [src.name] suddenly lets out a blast of smoke and some sparks!</span>", blind_message = "<span class='warning'>You hear sizzling electronics.</span>")


/obj/machinery/power/apc/surplus()
	if(terminal)
		return terminal.surplus()
	else
		return 0

/obj/machinery/power/apc/add_load(amount)
	if(terminal)
		terminal.add_load(amount)

/obj/machinery/power/apc/avail()
	if(terminal)
		return terminal.avail()
	else
		return 0

/obj/machinery/power/apc/process()
	if(stat & (BROKEN | MAINT))
		return
	if(!area.requires_power)
		return

	lastused_light = area.usage(STATIC_LIGHT)
	lastused_equip = area.usage(STATIC_EQUIP)
	lastused_environ = area.usage(STATIC_ENVIRON)
	area.clear_usage()

	lastused_total = lastused_light + lastused_equip + lastused_environ

	// Store states to update icon if any change:
	var/last_lt = lighting
	var/last_eq = equipment
	var/last_en = environ
	var/last_ch = charging

	var/p_avail = terminal ? terminal.avail() : 0
	var/excess = terminal ? terminal.surplus() : 0

	if(!p_avail)
		main_status = APC_NO_POWER
	else if(excess < 0)
		main_status = APC_LOW_POWER
	else
		main_status = APC_HAS_POWER

	if(cell && !shorted)
		var/cell_maxcharge = cell.maxcharge
		var/cell_percent = cell.percent()

		// Draw power from cell:
		var/cell_used = cell.use(lastused_total * CELLRATE)
		var/cell_returned = 0

		if(excess > 0) // If power excess, recharge the cell by the same amount just used
			cell_returned = cell.give(min(excess * CELLRATE, cell_used))

		if(terminal)
			terminal.add_load(cell_used / CELLRATE) // If excess is not enough, then there is no power left for the rest of APCs anyway - may make net excess negative to help engineers
			excess = terminal.surplus() // Update for charging conditions

		if(round(cell_returned) < round(cell_used)) // Returned power is less than used from the cell
			charging = APC_NOT_CHARGING
			chargecount = 0
			if(p_avail)
				main_status = APC_LOW_POWER

		// Allow the APC to operate as normal if the cell can charge:
		if(charging != APC_NOT_CHARGING)
			if(longtermpower < 10)
				longtermpower += 1
		else
			if(longtermpower > -10)
				longtermpower -= 2

		// Set channels depending on how much charge we have left:
		if(cell_percent >= 30 || longtermpower > 0) // Put most likely at the top so we don't check it last, effeciency 101
			if(autoflag != 3)
				equipment = autoset(equipment, AUTOSET_ON)
				lighting = autoset(lighting, AUTOSET_ON)
				environ = autoset(environ, AUTOSET_ON)
				area.poweralert(FALSE, src)
				autoflag = 3
		else if(cell_percent >= 15) // < 30%, turn off equipment
			if(autoflag != 2)
				equipment = autoset(equipment, AUTOSET_OFF)
				lighting = autoset(lighting, AUTOSET_ON)
				environ = autoset(environ, AUTOSET_ON)
				area.poweralert(TRUE, src)
				autoflag = 2
		else if(cell_percent >= 1) // < 15%, turn off lighting & equipment
			if(autoflag != 1)
				equipment = autoset(equipment, AUTOSET_OFF)
				lighting = autoset(lighting, AUTOSET_OFF)
				environ = autoset(environ, AUTOSET_ON)
				area.poweralert(TRUE, src)
				autoflag = 1
		else // Zero charge, turn everything off
			if(autoflag != 0)
				equipment = autoset(equipment, AUTOSET_FORCE_OFF)
				lighting = autoset(lighting, AUTOSET_FORCE_OFF)
				environ = autoset(environ, AUTOSET_FORCE_OFF)
				area.poweralert(TRUE, src)
				autoflag = 0

		if(chargemode && operating) // Charging the cell
			switch(charging)
				if(APC_FULLY_CHARGED)
					if(cell_percent < 100) // Lost some charge
						charging = APC_CHARGING

				if(APC_CHARGING)
					if(cell.charge >= cell_maxcharge) // Charged.
						charging = APC_FULLY_CHARGED
					else if(excess > 0) // Trying to charge with available power
						cell.give(min(excess * CELLRATE, cell_maxcharge * CHARGELEVEL))
						terminal?.add_load(cell_maxcharge * CHARGELEVEL / CELLRATE) // Same reason as pervious add_load
					else // No power to charge
						charging = APC_NOT_CHARGING
						chargecount = 0

				if(APC_NOT_CHARGING)
					if(excess * CELLRATE >= cell_maxcharge * CHARGELEVEL) // Has enough power to start APC charging
						chargecount++
					else
						chargecount = 0

					if(chargecount > APC_WAIT_FOR_CHARGE) // APC has needed power long enough
						chargecount = 0
						charging = APC_CHARGING

		else // Chargemode is Off
			charging = APC_NOT_CHARGING
			chargecount = 0

	else // No cell, switch everything off
		charging = APC_NOT_CHARGING
		chargecount = 0
		equipment = autoset(equipment, AUTOSET_FORCE_OFF)
		lighting = autoset(lighting, AUTOSET_FORCE_OFF)
		environ = autoset(environ, AUTOSET_FORCE_OFF)
		area.poweralert(TRUE, src)
		autoflag = 0

	if(debug)
		log_debug( "Status: [main_status] - Excess: [excess] - Last Equip: [lastused_equip] - Last Light: [lastused_light]")

	// Update icon & area power if anything changed:
	if(last_lt != lighting || last_eq != equipment || last_en != environ)
		queue_icon_update()
		update()
	else if(last_ch != charging)
		queue_icon_update()

// val 0=off, 1=off(auto) 2=on 3=on(auto)
// on 0=off, 1=on, 2=autooff
/proc/autoset(val, on)
	switch(on)
		if(AUTOSET_FORCE_OFF)
			if(val == APC_CHANNEL_ON)           // if on, return off
				return APC_CHANNEL_OFF
			else if(val == APC_CHANNEL_AUTO_ON) // if auto-on, return auto-off
				return APC_CHANNEL_AUTO_OFF

		if(AUTOSET_ON)
			if(val == APC_CHANNEL_AUTO_OFF)     // if auto-off, return auto-on
				return APC_CHANNEL_AUTO_ON

		if(AUTOSET_OFF)
			if(val == APC_CHANNEL_AUTO_ON)      // if auto-on, return auto-off
				return APC_CHANNEL_AUTO_OFF

	return val

// damage and destruction acts
/obj/machinery/power/apc/emp_act(severity)
	flick("apc-spark", src)
	if(cell)
		cell.emplode(severity)
	lighting = APC_CHANNEL_OFF
	equipment = APC_CHANNEL_OFF
	environ = APC_CHANNEL_OFF
	stat |= EMPED
	update()
	addtimer(CALLBACK(src, PROC_REF(after_emp)), 600 / severity)
	..()

/obj/machinery/power/apc/proc/after_emp()
	lighting = APC_CHANNEL_AUTO_ON
	equipment = APC_CHANNEL_AUTO_ON
	environ = APC_CHANNEL_AUTO_ON
	stat &= ~EMPED
	update()

/obj/machinery/power/apc/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			//set_broken() //now Destroy() do what we need
			if(cell)
				SSexplosions.high_mov_atom += cell
			qdel(src)
			return
		if(EXPLODE_HEAVY)
			if(prob(50))
				set_broken()
				if(cell && prob(50))
					SSexplosions.med_mov_atom += cell
		if(EXPLODE_LIGHT)
			if(prob(25))
				set_broken()
				if(cell && prob(25))
					SSexplosions.low_mov_atom += cell

/obj/machinery/power/apc/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(stat & BROKEN)
		switch(damage_type)
			if(BRUTE, BURN)
				return damage_amount
		return
	. = ..()

/obj/machinery/power/apc/atom_break(damage_flag)
	. = ..()
	if(.)
		set_broken()

/obj/machinery/power/apc/proc/set_broken()
	if(malfai && operating)
		var/datum/faction/malf_silicons/GM = find_faction_by_type(/datum/faction/malf_silicons)
		if(GM && is_station_level(z))
			SSticker.hacked_apcs--
	stat |= BROKEN
	operating = 0
	update_icon()
	update()

// overload all the lights in this APC area
/obj/machinery/power/apc/proc/overload_lighting(skip_sound_and_sparks = 0)
	if(!operating || shorted)
		return
	if(cell && cell.charge >= 20)
		cell.use(20);
		break_lights(skip_sound_and_sparks)

/obj/machinery/power/apc/proc/break_lights(skip_sound_and_sparks)
	set waitfor = FALSE

	for(var/obj/machinery/light/L in area)
		L.on = 1
		L.broken(skip_sound_and_sparks)
		stoplag()

/obj/machinery/power/apc/proc/shock(mob/user, prb)
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if(isxeno(user))
		return 0
	if(electrocute_mob(user, src, src))
		return 1
	else
		return 0

/obj/machinery/power/apc/proc/setsubsystem(val)
	if(cell && cell.charge > 0)
		return (val == APC_CHANNEL_AUTO_OFF) ? APC_CHANNEL_OFF : val
	if(val == APC_CHANNEL_AUTO_ON) // No charge left
		return APC_CHANNEL_AUTO_OFF
	return APC_CHANNEL_OFF

/obj/machinery/power/apc/proc/init_smartlight()
	if(custom_smartlight_preset)
		var/type = smartlight_presets[custom_smartlight_preset]
		smartlight_preset = new type
	else
		smartlight_preset = new

	smartlight_preset.expand_onto(SSsmartlight.smartlight_preset)

	if(SSsmartlight.nightshift_active && smartlight_preset.nightshift_mode)
		nightshift_lights = TRUE
		set_light_mode(global.light_modes_by_type[smartlight_preset.nightshift_mode])
	else
		nightshift_lights = FALSE
		set_light_mode(global.light_modes_by_type[smartlight_preset.default_mode])

/obj/machinery/power/apc/proc/sync_smartlight()
	set waitfor = FALSE
	// todo: need to preserve local user settings (idk how)
	init_smartlight()

/obj/machinery/power/apc/proc/set_light_mode(datum/light_mode/new_mode, forced = FALSE)
	set waitfor = FALSE

	if(light_mode == new_mode)
		return

	if(SSsmartlight.forced_admin_mode && !forced)
		return

	light_mode = new_mode

	for(var/obj/machinery/light/L in area)
		L.set_light_mode(light_mode)

/obj/machinery/power/apc/proc/toggle_nightshift(active)
	nightshift_lights = active
	reset_smartlight()

/obj/machinery/power/apc/proc/reset_smartlight()
	if(nightshift_lights && smartlight_preset.nightshift_mode)
		set_light_mode(global.light_modes_by_type[smartlight_preset.nightshift_mode])
	else
		set_light_mode(global.light_modes_by_type[smartlight_preset.default_mode])

/obj/machinery/power/apc/proc/get_light_mode()
	return light_mode

/obj/machinery/power/apc/smallcell
	cell_type = 2500

/obj/machinery/power/apc/mediumcell
	cell_type = 10000

/obj/machinery/power/apc/largecell
	cell_type = 20000

/obj/machinery/power/apc/proc/disable_autocharge()
	chargemode = FALSE

/obj/machinery/power/apc/proc/toggle_power_use()
	toggle_breaker()

/obj/machinery/power/apc/proc/disable_random_categories()
	equipment = prob(50) ? APC_CHANNEL_OFF : equipment
	lighting = prob(50) ? APC_CHANNEL_OFF : lighting
	environ = prob(50) ? APC_CHANNEL_OFF : environ

/obj/machinery/power/apc/proc/make_short_circuit()
	shorted = TRUE

#undef APC_WAIT_FOR_CHARGE

#undef APC_UPDATE_ICON_COOLDOWN

#undef APC_COVER_CLOSED
#undef APC_COVER_OPENED
#undef APC_COVER_REMOVED

#undef APC_NO_POWER
#undef APC_LOW_POWER
#undef APC_HAS_POWER

#undef APC_CHANNEL_OFF
#undef APC_CHANNEL_AUTO_OFF
#undef APC_CHANNEL_ON
#undef APC_CHANNEL_AUTO_ON

#undef AUTOSET_FORCE_OFF
#undef AUTOSET_OFF
#undef AUTOSET_ON

#undef APC_NOT_CHARGING
#undef APC_CHARGING
#undef APC_FULLY_CHARGED
