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

#define APC_UPDATE_ICON_COOLDOWN 100 // 10 seconds


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
	anchored = 1
	use_power = NO_POWER_USE
	req_access = list(access_engine_equip)
	allowed_checks = ALLOWED_CHECK_NONE
	unacidable = TRUE
	var/area/area
	var/areastring = null
	var/obj/item/weapon/stock_parts/cell/cell
	var/start_charge = 90				// initial cell charge %
	var/cell_type = 5000				// 0=no cell, 1=regular, 2=high-cap (x5) <- old, now it's just 0=no cell, otherwise dictate cellcapacity by changing this value. 1 used to be 1000, 2 was 2500
	var/opened = 0 //0=closed, 1=opened, 2=cover removed
	var/shorted = 0
	var/lighting = 3
	var/equipment = 3
	var/environ = 3
	var/operating = 1
	var/charging = 0
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
	var/wiresexposed = 0
	powernet = 0		// set so that APCs aren't found as powernet nodes //Hackish, Horrible, was like this before I changed it :(
	var/malfhack = 0 //New var for my changes to AI malf. --NeoFite
	var/mob/living/silicon/ai/malfai = null //See above --NeoFite
	var/debug= 0
	var/autoflag= 0		// 0 = off, 1= eqp and lights off, 2 = eqp off, 3 = all on.
	var/has_electronics = 0 // 0 - none, 1 - plugged in, 2 - secured by screwdriver
	var/overload = 1 //used for the Blackout malf module
	var/beenhit = 0 // used for counting how many times it has been hit, used for Aliens at the moment
	var/mob/living/silicon/ai/occupier = null
	var/longtermpower = 10
	var/nightshift_lights = FALSE
	var/nightshift_preset = "soft"
	var/last_nightshift_switch = 0
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

/obj/machinery/power/apc/updateDialog()
	if(stat & (BROKEN|MAINT))
		return
	..()

/obj/machinery/power/apc/atom_init(mapload, ndir, building = 0)
	. = ..()
	apc_list += src
	wires = new(src)

	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if(building)
		dir = ndir
	tdir = dir		// to fix Vars bug
	dir = SOUTH

	pixel_x = (tdir & 3) ? 0 : (tdir == 4 ? 27 : -27)
	pixel_y = (tdir & 3) ? (tdir == 1 ? 27 : -27) : 0
	if(building == 0)
		init()
	else
		area = get_area(src)
		area.apc = src
		opened = 1
		operating = 0
		name = "[area.name] APC"
		stat |= MAINT
		update_icon()
		addtimer(CALLBACK(src, .proc/update), 5)

/obj/machinery/power/apc/Destroy()
	apc_list -= src
	if(malfai && operating)
		if(SSticker.mode.config_tag == "malfunction")
			if(is_station_level(z))
				var/datum/game_mode/malfunction/gm_malf = SSticker.mode
				gm_malf.apcs--
	area.apc = null
	area.power_light = 0
	area.power_equip = 0
	area.power_environ = 0
	area.power_change()
	/*if(occupier)
		malfvacate(1)*/
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
	terminal.dir = tdir
	terminal.master = src

/obj/machinery/power/apc/proc/init()
	has_electronics = 2 //installed and secured
	// is starting with a power cell installed, create it and set its charge level
	if(cell_type)
		src.cell = new/obj/item/weapon/stock_parts/cell(src)
		cell.maxcharge = cell_type	// cell_type is maximum charge (old default was 1000 or 2500 (values one and two respectively)
		cell.charge = start_charge * cell.maxcharge / 100.0 		// (convert percentage to actual value)

	var/area/A = src.loc.loc


	//if area isn't specified use current
	if(isarea(A) && src.areastring == null)
		src.area = A
		name = "[area.name] APC"
	else
		src.area = get_area_name(areastring)
		name = "[area.name] APC"
	area.apc = src
	update_icon()

	make_terminal()

	addtimer(CALLBACK(src, .proc/update), 5)

/obj/machinery/power/apc/examine(mob/user)
	..()
	if(src in oview(1, user))
		if(stat & BROKEN)
			to_chat(user, "Looks broken.")
			return
		if(opened)
			if(has_electronics && terminal)
				to_chat(user, "The cover is [opened == 2 ? "removed" : "open"] and the power cell is [ cell ? "installed" : "missing"].")
			else if(!has_electronics && terminal)
				to_chat(user, "There are some wires but no any electronics.")
			else if(has_electronics && !terminal)
				to_chat(user, "Electronics installed but not wired.")
			else /* if(!has_electronics && !terminal) */
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

		status_overlays_lock[1] = image(icon, "apcox-0")    // 0=blue 1=red
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



	var/update = check_updates() 		//returns 0 if no need to update icons.
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
		else if(update_state & (UPSTATE_OPENED1|UPSTATE_OPENED2))
			var/basestate = "apc[ cell ? "2" : "1" ]"
			if(update_state & UPSTATE_OPENED1)
				if(update_state & (UPSTATE_MAINT|UPSTATE_BROKE))
					icon_state = "apcmaint" //disabled APC cannot hold cell
				else
					icon_state = basestate
		else if(update_state & UPSTATE_BLUESCREEN)
			icon_state = "apcemag"
		else if(update_state & UPSTATE_WIREEXP)
			icon_state = "apcewires"



	if(!(update_state & UPSTATE_ALLGOOD))
		if(overlays.len)
			cut_overlays()
			return



	if(update & 2)

		if(overlays.len)
			cut_overlays()

		if(!(stat & (BROKEN|MAINT)) && update_state & UPSTATE_ALLGOOD)
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
	if(opened)
		if(opened == 1)
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

		if(!charging)
			update_overlay |= APC_UPOVERLAY_CHARGEING0
		else if(charging == 1)
			update_overlay |= APC_UPOVERLAY_CHARGEING1
		else if(charging == 2)
			update_overlay |= APC_UPOVERLAY_CHARGEING2

		if(!equipment)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT0
		else if(equipment == 1)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT1
		else if(equipment == 2)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT2

		if(!lighting)
			update_overlay |= APC_UPOVERLAY_LIGHTING0
		else if(lighting == 1)
			update_overlay |= APC_UPOVERLAY_LIGHTING1
		else if(lighting == 2)
			update_overlay |= APC_UPOVERLAY_LIGHTING2

		if(!environ)
			update_overlay |= APC_UPOVERLAY_ENVIRON0
		else if(environ == 1)
			update_overlay |= APC_UPOVERLAY_ENVIRON1
		else if(environ == 2)
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
		return src.attack_hand(user)
	src.add_fingerprint(user)
	if(iscrowbar(W) && opened)
		if(has_electronics == 1)
			if(terminal)
				to_chat(user, "<span class='warning'>Disconnect wires first.</span>")
				return
			if(user.is_busy(src))
				return
			to_chat(user, "You are trying to remove the power control board...")//lpeters - fixed grammar issues
			if(W.use_tool(src, user, 50, volume = 50))
				has_electronics = 0
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
		else if(opened != 2) //cover isn't removed
			opened = 0
			update_icon()

	else if(iscrowbar(W) && !opened)
		if(stat & BROKEN)
			user.visible_message("<span class='warning'>[user.name] try open [src.name] cover.</span>", "<span class='notice'>You try open [src.name] cover.</span>")
			if(W.use_tool(src, user, 25, volume = 25))
				opened = TRUE
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
				opened = TRUE
				update_icon()

	else if(iswrench(W) && opened && (stat & BROKEN))
		if(coverlocked)
			to_chat(user, "<span class='notice'>Remove security APC bolts.</span>")
			if(W.use_tool(src, user, 5, volume = 5))
				coverlocked = FALSE
				update_icon()
		else
			to_chat(user, "<span class='warning'>APC bolts alredy removed.</span>")

	else if	(istype(W, /obj/item/weapon/stock_parts/cell) && opened)	// trying to put a cell inside
		if(cell)
			to_chat(user, "There is a power cell already installed.")
			return
		else
			if(stat & MAINT)
				to_chat(user, "<span class='warning'>There is no connector for your power cell.</span>")
				return
			user.drop_item()
			W.loc = src
			cell = W
			user.visible_message(\
				"<span class='warning'>[user.name] has inserted the power cell to [src.name]!</span>",\
				"You insert the power cell.")
			chargecount = 0
			update_icon()

	else if	(isscrewdriver(W))	// haxing
		if(opened)
			if(cell)
				to_chat(user, "<span class='warning'>Close the APC first.</span>")//Less hints more mystery!
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
				else /* has_electronics == 0 */
					to_chat(user, "<span class='warning'>There is nothing to secure.</span>")
					return
				update_icon()

		else if(emagged)
			to_chat(user, "The interface is broken.")
		else if(!(stat & BROKEN))
			wiresexposed = !wiresexposed
			to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"]")
			update_icon()

	else if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))			// trying to unlock the interface with an ID card
		if(emagged)
			to_chat(user, "The interface is broken.")
		else if(opened)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else if(wiresexposed)
			to_chat(user, "You must close the panel")
		else if(stat & (BROKEN|MAINT))
			to_chat(user, "Nothing happens.")
		else
			if(src.allowed(usr) && !wires.is_index_cut(APC_WIRE_IDSCAN))
				locked = !locked
				to_chat(user, "You [ locked ? "lock" : "unlock"] the APC interface.")
				update_icon()
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")

	else if(istype(W, /obj/item/weapon/card/emag) && !(emagged || malfhack))		// trying to unlock with an emag card
		if(opened)
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
				else
					to_chat(user, "You fail to [ locked ? "unlock" : "lock"] the APC interface.")

	else if(iscoil(W) && !terminal && opened && has_electronics != 2)
		var/turf/TT = get_turf(src)
		if(TT.intact)
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
	else if(iswirecutter(W) && terminal && opened && has_electronics!=2)
		terminal.dismantle(user)
	else if(istype(W, /obj/item/weapon/module/power_control) && opened && has_electronics == 0 && !((stat & BROKEN) || malfhack))
		if(user.is_busy()) return
		to_chat(user, "You trying to insert the power control board into the frame...")
		if(W.use_tool(src, user, 10, volume = 50))
			has_electronics = 1
			to_chat(user, "You place the power control board inside the frame.")
			qdel(W)
	else if(istype(W, /obj/item/weapon/module/power_control) && opened && has_electronics == 0 && ((stat & BROKEN) || malfhack))
		to_chat(user, "<span class='warning'>You cannot put the board inside, the frame is damaged.</span>")
		return
	else if(iswelder(W) && opened && has_electronics == 0 && !terminal)
		if(user.is_busy()) return
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.get_fuel() < 3)
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return
		to_chat(user, "You start welding the APC frame...")
		if(WT.use_tool(src, user, 50, amount = 3, volume = 50))
			if(emagged || malfhack || (stat & BROKEN) || opened == 2)
				new /obj/item/stack/sheet/metal(loc)
				user.visible_message(\
					"<span class='warning'>[src] has been cut apart by [user.name] with the weldingtool.</span>",\
					"You disassembled the broken APC frame.",\
					"<span class='warning'>You hear welding.</span>")
			else
				new /obj/item/apc_frame(loc)
				user.visible_message(\
					"<span class='warning'>[src] has been cut from the wall by [user.name] with the weldingtool.</span>",\
					"You cut the APC frame from the wall.",\
					"<span class='warning'>You hear welding.</span>")
			qdel(src)
			return
	else if(istype(W, /obj/item/apc_frame) && opened && emagged)
		emagged = 0
		if(opened == 2)
			opened = 1
		user.visible_message(\
			"<span class='warning'>[user.name] has replaced the damaged APC frontal panel with a new one.</span>",\
			"You replace the damaged APC frontal panel with a new one.")
		qdel(W)
		update_icon()
	else if(istype(W, /obj/item/apc_frame) && opened && ((stat & BROKEN) || malfhack))
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
			if(opened == 2)
				opened = 1
			update_icon()

	else if(!opened && wiresexposed && is_wire_tool(W))
		if(istype(user, /mob/living/silicon))
			return wires.interact(user)
		user.SetNextMove(CLICK_CD_MELEE)
		user.visible_message("<span class='warning'>The [src.name] has been hit with the [W.name] by [user.name]!</span>", \
			"<span class='warning'>You hit the [src.name] with your [W.name]!</span>", \
			"You hear bang")
		return wires.interact(user)

// attack with hand - remove cell (if cover open) or interact with the APC

/obj/machinery/power/apc/interact(mob/user)
	//Synthetic human mob goes here.
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

								else if(src.cell.use(500))
									H.nutrition += C.maxcharge*0.1
									to_chat(user, "<span class='notice'>Draining... Battery has [round(100.0*H.nutrition/C.maxcharge)]% of charge.</span>")

							else
								to_chat (user, "<span class='warning'>Procedure interrupted. Protocol terminated.</span>")
								break
					else

						H.nutrition += src.cell.charge/10
						src.cell.charge = 0

					if(!src.cell)
						src.charging = 0
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

					src.charging = 1

				else
					to_chat(user, "<span class='notice'>You are already fully charged.</span>")
			else
				to_chat(user, "There is no charge to draw from that APC.")
			return

	if(usr == user && opened && !issilicon(user) && !isobserver(user))
		if(cell)
			user.put_in_hands(cell)
			cell.add_fingerprint(user)
			cell.updateicon()

			src.cell = null
			user.visible_message("<span class='warning'>[user.name] removes the power cell from [src.name]!</span>", "You remove the power cell.")
			//user << "You remove the power cell."
			charging = 0
			src.update_icon()
		return
	// do APC interaction
	..()

/obj/machinery/power/apc/attack_alien(mob/living/carbon/xenomorph/humanoid/user)
	to_chat(user, "You don't want to break these things");
	return

/obj/machinery/power/apc/proc/get_malf_status(mob/living/silicon/ai/malf)
	if(SSticker && SSticker.mode && (malf.mind in SSticker.mode.malf_ai) && istype(malf))
		if(src.malfai == (malf.parent || malf))
			if(src.occupier == malf)
				return 3 // 3 = User is shunted in this APC
			else if(istype(malf.loc, /obj/machinery/power/apc))
				return 4 // 4 = User is shunted in another APC
			else
				return 2 // 2 = APC hacked by user, and user is in its core.
		else
			return 1 // 1 = APC not hacked.
	else
		return 0 // 0 = User is not a Malf AI

/obj/machinery/power/apc/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	if(!user)
		return

	var/list/data = list(
		"locked" = locked,
		"isOperating" = operating,
		"externalPower" = main_status,
		"powerCellStatus" = cell ? cell.percent() : null,
		"chargeMode" = chargemode,
		"chargingStatus" = charging,
		"totalLoad" = round(lastused_equip) + lastused_light + round(lastused_environ),
		"coverLocked" = coverlocked,
		"siliconUser" = issilicon(user) || isobserver(user),
		"malfStatus" = get_malf_status(user),
		"nightshift_lights" = nightshift_lights,
		"nightshift_preset" = nightshift_preset,

		"powerChannels" = list(
			list(
				"title" = "Equipment",
				"powerLoad" = round(lastused_equip),
				"status" = equipment,
				"topicParams" = list(
					"auto" = list("eqp" = 3),
					"on"   = list("eqp" = 2),
					"off"  = list("eqp" = 1)
				)
			),
			list(
				"title" = "Lighting",
				"powerLoad" = lastused_light,
				"status" = lighting,
				"topicParams" = list(
					"auto" = list("lgt" = 3),
					"on"   = list("lgt" = 2),
					"off"  = list("lgt" = 1)
				)
			),
			list(
				"title" = "Environment",
				"powerLoad" = round(lastused_environ),
				"status" = environ,
				"topicParams" = list(
					"auto" = list("env" = 3),
					"on"   = list("env" = 2),
					"off"  = list("env" = 1)
				)
			)
		)
	)

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "apc.tmpl", "[area.name] - APC", 520, data["siliconUser"] ? 485 : 460)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/power/apc/proc/report()
	return "[area.name] : [equipment]/[lighting]/[environ] ([lastused_equip+lastused_light+lastused_environ]) : [cell ? cell.percent() : "N/C"] ([charging])"

/obj/machinery/power/apc/proc/update()
	if(operating && !shorted)
		area.power_light = (lighting > 1)
		area.power_equip = (equipment > 1)
		area.power_environ = (environ > 1)
//		if(area.name == "AI Chamber")
//			spawn(10)
//				world << " [area.name] [area.power_equip]"
	else
		area.power_light = 0
		area.power_equip = 0
		area.power_environ = 0
//		if(area.name == "AI Chamber")
//			world << "[area.power_equip]"
	area.power_change()

/obj/machinery/power/apc/proc/can_use(mob/user, loud = 0) //used by attack_hand() and Topic()
	if(IsAdminGhost(user))
		return 1
	if(!user.client)
		return 0
	autoflag = 5
	if(issilicon(user))
		var/mob/living/silicon/ai/AI = user
		var/mob/living/silicon/robot/robot = user
		if(                                                             \
			src.aidisabled ||                                            \
			malfhack && istype(malfai) &&                                \
			(                                                            \
				(istype(AI) && (malfai!=AI && malfai != AI.parent)) ||   \
				(istype(robot) && (robot in malfai.connected_robots))    \
			)                                                            \
		)
			if(!loud)
				to_chat(user, "<span class='warning'>\The [src] have AI control disabled!</span>")
				nanomanager.close_user_uis(user, src)

			return 0
	else
		if((!in_range(src, user) || !istype(src.loc, /turf)))
			nanomanager.close_user_uis(user, src)

			return 0

	return 1

/obj/machinery/power/apc/is_operational_topic()
	return !(stat & (BROKEN|MAINT|EMPED))

/obj/machinery/power/apc/Topic(href, href_list, usingUI = TRUE)
	. = ..(href, href_list)
	if(!.)
		return

	if(!can_use(usr, 1))
		return

	else if(href_list["lock"])
		coverlocked = !coverlocked

	else if(href_list["toggle_nightshift"])
		toggle_nightshift_lights()

	else if(href_list["change_nightshift"])
		var/new_preset = input(usr, "Please choose night shift lighting.") as null|anything in lighting_presets
		if(new_preset && lighting_presets[new_preset])
			set_nightshift_preset(new_preset)

	else if(href_list["breaker"])
		operating = !operating
		if(malfai)
			if(SSticker.mode.config_tag == "malfunction")
				if(is_station_level(z))
					var/datum/game_mode/malfunction/gm_malf = SSticker.mode
					operating ? gm_malf.apcs++ : gm_malf.apcs--

		src.update()
		update_icon()

	else if(href_list["cmode"])
		chargemode = !chargemode
		if(!chargemode)
			charging = 0
			update_icon()

	else if(href_list["eqp"])
		var/val = text2num(href_list["eqp"])

		equipment = setsubsystem(val)

		update_icon()
		update()

	else if(href_list["lgt"])
		var/val = text2num(href_list["lgt"])

		lighting = setsubsystem(val)

		update_icon()
		update()
	else if(href_list["env"])
		var/val = text2num(href_list["env"])

		environ = setsubsystem(val)

		update_icon()
		update()
	else if( href_list["close"] )
		nanomanager.close_user_uis(usr, src)
		return FALSE

	else if(href_list["overload"])
		if( (issilicon(usr) && !src.aidisabled) || isobserver(usr) )
			src.overload_lighting()

	else if(href_list["malfhack"])
		var/mob/living/silicon/ai/malfai = usr
		if( issilicon(usr) && !src.aidisabled )
			if(malfai.malfhacking)
				to_chat(malfai, "You are already hacking an APC.")
				return FALSE
			to_chat(malfai, "Beginning override of APC systems. This takes some time, and you cannot perform other actions during the process.")
			malfai.malfhack = src
			malfai.malfhacking = 1
			sleep(600)
			if(src)
				if(!src.aidisabled)
					malfai.malfhack = null
					malfai.malfhacking = 0
					if(SSticker.mode.config_tag == "malfunction")
						if(is_station_level(z))
							var/datum/game_mode/malfunction/gm_malf = SSticker.mode
							gm_malf.apcs++
					if(malfai.parent)
						src.malfai = malfai.parent
					else
						src.malfai = usr
					to_chat(malfai, "Hack complete. The APC is now under your exclusive control.")
					update_icon()

	/*else if(href_list["occupyapc"])
		malfoccupy(usr)


	else if(href_list["deoccupyapc"])
		malfvacate()*/

	if(usingUI)
		src.updateDialog()

/*/obj/machinery/power/apc/proc/malfoccupy(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(istype(malf.loc, /obj/machinery/power/apc)) // Already in an APC
		to_chat(malf, "<span class='warning'>You must evacuate your current apc first.</span>")
		return
	if(src.z != ZLEVEL_STATION)
		return
	src.occupier = new /mob/living/silicon/ai(src,malf.laws,null,1)
	src.occupier.adjustOxyLoss(malf.getOxyLoss())
	if(!findtext(src.occupier.name,"APC Copy"))
		src.occupier.name = "[malf.name] APC Copy"
	if(malf.parent)
		src.occupier.parent = malf.parent
	else
		src.occupier.parent = malf
	malf.mind.transfer_to(src.occupier)
	src.occupier.eyeobj.name = "[src.occupier.name] (AI Eye)"
	if(malf.parent)
		qdel(malf)
	src.occupier.verbs += /mob/living/silicon/ai/proc/corereturn
	src.occupier.verbs += /datum/game_mode/malfunction/proc/takeover
	src.occupier.cancel_camera()

/obj/machinery/power/apc/proc/malfvacate(forced)
	if(!src.occupier)
		return
	if(src.occupier.parent && src.occupier.parent.stat != DEAD)
		src.occupier.mind.transfer_to(src.occupier.parent)
		src.occupier.parent.adjustOxyLoss(src.occupier.getOxyLoss())
		src.occupier.parent.cancel_camera()
		qdel(src.occupier)

	else
		to_chat(src.occupier, "<span class='warning'>Primary core damaged, unable to return core processes.</span>")
		if(forced)
			src.occupier.loc = src.loc
			src.occupier.death()
			src.occupier.gib()*/


/obj/machinery/power/apc/proc/ion_act()
	//intended to be exactly the same as an AI malf attack
	if(!src.malfhack && is_station_level(z))
		if(prob(3))
			src.locked = 1
			if(src.cell.charge > 0)
//				world << "<span class='warning'>blew APC in [src.loc.loc]</span>"
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
	if(terminal && terminal.powernet)
		terminal.powernet.newload += amount

/obj/machinery/power/apc/avail()
	if(terminal)
		return terminal.avail()
	else
		return 0

/obj/machinery/power/apc/process()

	if(stat & (BROKEN|MAINT))
		return
	if(!area.requires_power)
		return


	lastused_light = area.usage(STATIC_LIGHT)
	lastused_equip = area.usage(STATIC_EQUIP)
	lastused_environ = area.usage(STATIC_ENVIRON)
	if(area.powerupdate)
		if(debug) log_debug("power update in [area.name] / [name]")
		area.clear_usage()

	lastused_total = lastused_light + lastused_equip + lastused_environ

	//store states to update icon if any change
	var/last_lt = lighting
	var/last_eq = equipment
	var/last_en = environ
	var/last_ch = charging

	var/excess = surplus()

	if(!src.avail())
		main_status = 0
	else if(excess < 0)
		main_status = 1
	else
		main_status = 2

	var/perapc = 0
	if(terminal && terminal.powernet)
		perapc = terminal.powernet.perapc

	if(debug)
		log_debug( "Status: [main_status] - Excess: [excess] - Last Equip: [lastused_equip] - Last Light: [lastused_light]")

	if(cell && !shorted)
		//var/cell_charge = cell.charge
		var/cell_maxcharge = cell.maxcharge

		// draw power from cell as before

		var/cellused = min(cell.charge, CELLRATE * lastused_total)	// clamp deduction to a max, amount left in cell
		cell.use(cellused)

		if(excess > 0 || perapc > lastused_total)		// if power excess, or enough anyway, recharge the cell
														// by the same amount just used
			cell.give(cellused)
			add_load(cellused/CELLRATE)		// add the load used to recharge the cell


		else		// no excess, and not enough per-apc

			if( (cell.charge/CELLRATE+perapc) >= lastused_total)		// can we draw enough from cell+grid to cover last usage?

				cell.give(CELLRATE * perapc)	//recharge with what we can
				add_load(perapc)		// so draw what we can from the grid
				charging = 0

			else if(autoflag != 0)	// not enough power available to run the last tick!
				charging = 0
				chargecount = 0
				// This turns everything off in the case that there is still a charge left on the battery, just not enough to run the room.
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)
				autoflag = 0


		// set channels depending on how much charge we have left

		// Allow the APC to operate as normal if the cell can charge
		if(charging && longtermpower < 10)
			longtermpower += 1
		else if(longtermpower > -10)
			longtermpower -= 2


		if(cell.charge >= 1250 || longtermpower > 0)              // Put most likely at the top so we don't check it last, effeciency 101
			if(autoflag != 3)
				equipment = autoset(equipment, 1)
				lighting = autoset(lighting, 1)
				environ = autoset(environ, 1)
				autoflag = 3
				area.poweralert(1, src)
				if(cell.charge >= 4000)
					area.poweralert(1, src)
		else if(cell.charge < 1250 && cell.charge > 750 && longtermpower < 0)                       // <30%, turn off equipment
			if(autoflag != 2)
				equipment = autoset(equipment, 2)
				lighting = autoset(lighting, 1)
				environ = autoset(environ, 1)
				area.poweralert(0, src)
				autoflag = 2
		else if(cell.charge < 750 && cell.charge > 10 && longtermpower < 0)        // <15%, turn off lighting & equipment
			if(autoflag != 1)
				equipment = autoset(equipment, 2)
				lighting = autoset(lighting, 2)
				environ = autoset(environ, 1)
				area.poweralert(0, src)
				autoflag = 1
		else if(cell.charge <= 0)                                   // zero charge, turn all off
			if(autoflag != 0)
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)
				area.poweralert(0, src)
				autoflag = 0

		// now trickle-charge the cell

		if(chargemode && charging == 1 && operating)
			if(excess > 0)		// check to make sure we have enough to charge
				// Max charge is perapc share, capped to cell capacity, or % per second constant (Whichever is smallest)
				var/ch = min(perapc*CELLRATE, (cell_maxcharge - cell.charge), (cell_maxcharge*CHARGELEVEL))
				add_load(ch/CELLRATE) // Removes the power we're taking from the grid
				cell.give(ch) // actually recharge the cell

			else
				charging = 0		// stop charging
				chargecount = 0

		// show cell as fully charged if so

		if(cell.charge >= cell_maxcharge)
			charging = 2

		if(chargemode)
			if(!charging)
				if(excess > cell_maxcharge*CHARGELEVEL)
					chargecount++
				else
					chargecount = 0

				if(chargecount == 10)

					chargecount = 0
					charging = 1

		else // chargemode off
			charging = 0
			chargecount = 0

	else // no cell, switch everything off

		charging = 0
		chargecount = 0
		equipment = autoset(equipment, 0)
		lighting = autoset(lighting, 0)
		environ = autoset(environ, 0)
		area.poweralert(0, src)
		autoflag = 0


	// update icon & area power if anything changed

	if(last_lt != lighting || last_eq != equipment || last_en != environ)
		queue_icon_update()
		update()
	else if(last_ch != charging)
		queue_icon_update()

// val 0=off, 1=off(auto) 2=on 3=on(auto)
// on 0=off, 1=on, 2=autooff

/proc/autoset(val, on)

	if(on == 0)
		if(val == 2)			// if on, return off
			return 0
		else if(val == 3)		// if auto-on, return auto-off
			return 1

	else if(on == 1)
		if(val == 1)			// if auto-off, return auto-on
			return 3

	else if(on == 2)
		if(val == 3)			// if auto-on, return auto-off
			return 1

	return val

// damage and destruction acts
/obj/machinery/power/apc/emp_act(severity)
	flick("apc-spark", src)
	if(cell)
		cell.emplode(severity)
	if(occupier)
		occupier.emplode(severity)
	lighting = 0
	equipment = 0
	environ = 0
	update()
	spawn(600/severity)
		lighting = 3
		equipment = 3
		environ = 3
		update()
	..()

/obj/machinery/power/apc/ex_act(severity)

	switch(severity)
		if(1.0)
			//set_broken() //now Destroy() do what we need
			if(cell)
				cell.ex_act(1.0) // more lags woohoo
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				set_broken()
				if(cell && prob(50))
					cell.ex_act(2.0)
		if(3.0)
			if(prob(25))
				set_broken()
				if(cell && prob(25))
					cell.ex_act(3.0)
	return

/obj/machinery/power/apc/blob_act()
	if(prob(75))
		set_broken()
		if(cell && prob(5))
			cell.blob_act()

/obj/machinery/power/apc/proc/set_broken()
	if(malfai && operating)
		if(SSticker.mode.config_tag == "malfunction")
			if(is_station_level(z))
				var/datum/game_mode/malfunction/gm_malf = SSticker.mode
				gm_malf.apcs--
	stat |= BROKEN
	operating = 0
	/*if(occupier)
		malfvacate(1)*/
	update_icon()
	update()

// overload all the lights in this APC area

/obj/machinery/power/apc/proc/overload_lighting(skip_sound_and_sparks = 0)
	if(/* !get_connection() || */ !operating || shorted)
		return
	if( cell && cell.charge>=20)
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
		return (val == 1) ? 0 : val
	else
		return (val == 3)

/obj/machinery/power/apc/proc/set_nightshift(on, preset = null)
	set waitfor = FALSE
	nightshift_lights = on

	if(on && preset && preset != nightshift_preset && lighting_presets[preset])
		nightshift_preset = preset
		for(var/obj/machinery/light/L in area)
			var/list/preset_data = lighting_presets[nightshift_preset]
			L.nightshift_light_range = preset_data["range"]
			L.nightshift_light_power = preset_data["power"]
			L.nightshift_light_color = preset_data["color"]

	for(var/obj/machinery/light/L in area)
		if(L.nightshift_allowed)
			L.nightshift_enabled = nightshift_lights
			L.update(FALSE)
		CHECK_TICK

/obj/machinery/power/apc/proc/toggle_nightshift_lights(mob/living/user)
	if(last_nightshift_switch > world.time - 20) //~2 seconds between each toggle to prevent spamming
		to_chat(usr, "<span class='warning'>[src]'s night lighting circuit breaker is still cycling!</span>")
		return
	last_nightshift_switch = world.time
	set_nightshift(!nightshift_lights)

/obj/machinery/power/apc/proc/set_nightshift_preset(preset)
	if(last_nightshift_switch > world.time - 20) //~2 seconds between each change to prevent spamming
		to_chat(usr, "<span class='warning'>[src]'s night lighting circuit breaker is still cycling!</span>")
		return
	last_nightshift_switch = world.time
	set_nightshift(nightshift_lights, preset)

#undef APC_UPDATE_ICON_COOLDOWN
