///SCI TELEPAD///
/obj/machinery/telepad
	name = "telepad"
	desc = "A bluespace telepad used for teleporting objects to and from a location."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	active_power_usage = 5000
	var/efficiency
	var/obj/machinery/computer/telescience/computer

/obj/machinery/telepad/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/telesci_pad(null)
	component_parts += new /obj/item/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)
	RefreshParts()

/obj/machinery/telepad/Destroy()
	if(computer)
		computer.close_wormhole()
		computer.telepad = null
		computer = null
	return ..()

/obj/machinery/telepad/RefreshParts()
	..()

	var/E
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		E += C.rating
	efficiency = E

/obj/machinery/telepad/attackby(obj/item/I, mob/user)
	if(default_deconstruction_screwdriver(user, "pad-idle-o", "pad-idle", I))
		return

	if(panel_open)
		if(ispulsing(I))
			var/obj/item/device/multitool/M = I
			M.buffer = src
			to_chat(user, "<span class='notice'>You save the data in the [I.name]'s buffer.</span>")

	if(exchange_parts(user, I))
		return

	default_deconstruction_crowbar(I)


//CARGO TELEPAD//
/obj/machinery/telepad_cargo
	name = "cargo telepad"
	desc = "A telepad used by the Rapid Crate Sender."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 500
	var/stage = 0

/obj/machinery/telepad_cargo/attackby(obj/item/weapon/W, mob/user)
	if(iswrenching(W))
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		if(anchored)
			anchored = FALSE
			to_chat(user, "<span class='notice'>The [src] can now be moved.</span>")
		else if(!anchored)
			anchored = TRUE
			to_chat(user, "<span class='notice'>The [src] is now secured.</span>")
		return
	else if(isscrewing(W))
		if(stage == 0)
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "<span class='notice'>You unscrew the telepad's tracking beacon.</span>")
			stage = 1
		else if(stage == 1)
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "<span class='notice'>You screw in the telepad's tracking beacon.</span>")
			stage = 0
		return
	else if(iswelding(W) && stage == 1)
		playsound(src, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You disassemble the telepad.</span>")
		new /obj/item/stack/sheet/metal(get_turf(src))
		new /obj/item/stack/sheet/glass(get_turf(src))
		qdel(src)
		return
	else
		return ..()

///TELEPAD CALLER///
/obj/item/device/telepad_beacon
	name = "telepad beacon"
	desc = "Use to warp in a cargo telepad."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"
	origin_tech = "bluespace=3"

/obj/item/device/telepad_beacon/attack_self(mob/user)
	if(user)
		to_chat(user, "<span class='notice'>Locked In.</span>")
		new /obj/machinery/telepad_cargo(user.loc)
		playsound(src, 'sound/effects/pop.ogg', VOL_EFFECTS_MASTER)
		qdel(src)
	return

///HANDHELD TELEPAD USER///
/obj/item/weapon/rcs
	name = "rapid-crate-sender (RCS)"
	desc = "Use this to send crates and closets to cargo telepads."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "rcs"
	flags = CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	var/rcharges = 10
	var/obj/machinery/pad = null
	var/last_charge = 30
	var/mode = 0
	var/rand_x = 0
	var/rand_y = 0
	var/emagged = 0
	var/teleporting = 0

/obj/item/weapon/rcs/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/rcs/examine(mob/user)
	..()
	to_chat(user, "There are [rcharges] charges left.")

/obj/item/weapon/rcs/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/rcs/process()
	if(rcharges > 10)
		rcharges = 10
	if(last_charge == 0)
		rcharges++
		last_charge = 30
	else
		last_charge--

/obj/item/weapon/rcs/attack_self(mob/user)
	if(emagged)
		if(mode == 0)
			mode = 1
			playsound(src, 'sound/effects/pop.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			to_chat(user, "<span class='notice'>The telepad locator has become uncalibrated.</span>")
		else
			mode = 0
			playsound(src, 'sound/effects/pop.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			to_chat(user, "<span class='notice'>You calibrate the telepad locator.</span>")

/obj/item/weapon/rcs/emag_act(mob/user)
	if(emagged == 0)
		emagged = 1
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		user.SetNextMove(CLICK_CD_INTERACT)
		to_chat(user, "<span class='notice'>You emag the RCS. Click on it to toggle between modes.</span>")
		return TRUE
	return FALSE
