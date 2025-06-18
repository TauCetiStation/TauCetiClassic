//these are probably broken

/obj/machinery/floodlight
	name = "Emergency Floodlight"
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "flood00"
	density = TRUE
	light_power = 2
	interact_offline = TRUE
	var/on = FALSE
	var/obj/item/weapon/stock_parts/cell/high/cell = null
	var/use = 5
	var/unlocked = FALSE
	var/open = FALSE
	var/brightness_on = 7

/obj/machinery/floodlight/atom_init()
	cell = new(src)
	. = ..()

/obj/machinery/floodlight/proc/toggle(on = !on)
	src.on = on
	if(on)
		set_light(brightness_on)
	else
		set_light(0)
	update_icon()

/obj/machinery/floodlight/update_icon()
	icon_state = "flood[open ? "o" : ""][open && cell ? "b" : ""]0[on]"

/obj/machinery/floodlight/process()
	if(on)
		if(cell && cell.charge >= use)
			cell.use(use)
		else
			toggle(FALSE)
			visible_message("<span class='warning'>[src] shuts down due to lack of power!</span>")
			return

/obj/machinery/floodlight/attack_hand(mob/user)
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

/obj/machinery/floodlight/verb/rotate()
	set name = "Rotate Floodlight"
	set category = "Object"
	set src in oview(1)

	if(!config.ghost_interaction && isobserver(usr))
		return
	if(ismouse(usr))
		return
	if(!usr || !isturf(usr.loc))
		return
	if(usr.incapacitated())
		return

	set_dir(turn(dir, 90))

/obj/machinery/floodlight/attackby(obj/item/weapon/W, mob/user)
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

/obj/machinery/floodlight/deconstruct(disassembled)
	playsound(loc, 'sound/effects/Glassbr3.ogg', VOL_EFFECTS_MASTER, 100, TRUE)
	//var/obj/structure/floodlight_frame/F = new(loc) // TODO floodligh construction
	//F.state = FLOODLIGHT_NEEDS_LIGHTS
	//new /obj/item/light/tube/broken(loc)
	..()

/obj/machinery/floodlight/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(loc, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER, 75, TRUE)
