/obj/structure/spacepod_frame
	desc = "An empty pod frame."
	density = 1
	opacity = 0

	anchored = 1
	layer = 3.9

	icon = 'icons/goonstation/48x48/pod_construction.dmi'
	icon_state = "pod_1"

	var/construct = TRUE
	var/state_num = 1
	var/result = "/obj/spacepod/civilian"

/obj/structure/spacepod_frame/New()
	..()
	bound_width = 64
	bound_height = 64

	dir = EAST

/obj/structure/spacepod_frame/Destroy()
	return ..()

/obj/structure/spacepod_frame/attackby(obj/item/W, mob/user, params)

	if(istype(W, /obj/item/stack/cable_coil) && state_num == 1)
		var/obj/item/stack/cable_coil/C = W
		if(C.amount >= 10)
			user.visible_message("[user] wires the [src]")
			to_chat(user, "<span class='notice'> You wire [src].</span>")
			desc = "A crudely-wired pod frame."
			state_num = 2
			C.amount -= 10
			if(C.amount <= 0)
				qdel(C)
			return
		else
			to_chat(user, "<span class='warning'>Not enough [10 - C.amount] [C].</span>")
			return

	else if(istype(W, /obj/item/weapon/wirecutters) && state_num == 2)
		user.visible_message("[user] cuts out the [src]'s wiring.")
		to_chat(user, "<span class='notice'>You remove the [src]'s wiring.</span>")
		desc = "A wired pod frame.."
		state_num = 3
		playsound(src, 'sound/items/Wirecutter.ogg', 50, 1)
		return

	else if(istype(W, /obj/item/weapon/screwdriver))
		if(state_num == 3)
			user.visible_message("[user] unclips [src]'s wiring harnesses.")
			to_chat(user, "<span class='notice'>You unclip [src]'s wiring harnesses.</span>")
			state_num = 3.1
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			return
		else if(state_num == 4)
			user.visible_message("[user] secures the mainboard.")
			to_chat(user, "<span class='notice'>You secure the mainboard.</span>")
			state_num = 5
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			return

	else if(istype(W, /obj/item/weapon/circuitboard/mecha/pod) && state_num == 3.1)
		user.visible_message("[user] inserts the mainboard into the [src].")
		to_chat(user, "<span class='notice'>You insert the mainboard into the [src].</span>")
		state_num = 4
		user.drop_item(W)
		qdel(W)
		return

	else if(istype(W, /obj/item/pod_parts/core) && state_num == 5)
		user.visible_message("[user] inserts the core into the [src].")
		to_chat(user, "<span class='notice'>You carefully insert the core into the [src].</span>")
		state_num = 6
		user.drop_item(W)
		qdel(W)
		return

	else if(istype(W,/obj/item/weapon/wrench))
		if(state_num == 6)
			user.visible_message("[user] secures the core's bolts..")
			to_chat(user, "<span class='notice'>You secure the core's bolts.</span>")
			state_num = 7
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			return
		else if(state_num == 8)
			user.visible_message("[user] secures the [src]'s bulkhead panelling.")
			to_chat(user, "<span class='notice'>You secure the [src]'s bulkhead panelling.</span>")
			state_num = 9
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			return

	else if(istype(W, /obj/item/stack/sheet/metal) && state_num == 7)
		var/obj/item/stack/sheet/metal/M = W
		if(M.amount >= 5)
			user.visible_message("[user] fabricates a pressure bulkhead for the [src].")
			to_chat(user, "<span class='notice'>You frabricate a pressure bulkhead for the [src].</span>")
			M.amount -= 5
			if(M.amount <= 0)
				qdel(M)
			state_num = 8
			return
		else
			to_chat(user, "<span class='warning'>Not enough [5 - M.amount] [M].</span>")
			return

	else if(istype(W, /obj/item/weapon/weldingtool))
		if(state_num == 9)
			user.visible_message("[user] seals the [src]'s bulkhead panelling with a weld.")
			to_chat(user, "<span class='notice'>You seal the [src]'s bulkhead panelling with a weld.</span>")
			state_num = 10
			playsound(src, 'sound/items/Welder.ogg', 50, 1)
			return
		else if(state_num == 11)
			user.visible_message("[user] welds the [src]'s armor.")
			to_chat(user, "<span class='notice'>You weld the [src]'s armor.</span>")
			state_num = 12
			playsound(src, 'sound/items/Welder.ogg', 50, 1)
			return

	else if(istype(W, /obj/item/pod_parts/armor) && state_num == 10)
		user.visible_message("[user] installs the [src]'s armor plating.")
		to_chat(user, "<span class='notice'>You install the [src]'s armor plating.</span>")
		state_num = 11
		user.drop_item(W)
		qdel(W)
		return

	else if(istype(W, /obj/item/weapon/stock_parts/cell) && state_num == 12)
		playsound(src, 'sound/effects/engine_alert2.ogg', 70, 1)
		usr.visible_message("<span class='danger'> [usr] Initialisate Space Pod. Engine is starting and make loud noise")
		to_chat(usr, "<span class='warning'>You start engine in the [src].</span>")
		var/obj/spacepod/sp = new result(src.loc)
		var/obj/item/weapon/stock_parts/cell/B = sp.battery
		qdel(src)
		B.loc = src.loc
		qdel(B)
		sp.battery = null
		user.drop_item(W)
		W.forceMove(sp)
		sp.battery = W
		return

	update_icon()
	..()

/obj/structure/spacepod_frame/update_icon()

	if(state_num == 3.1)
		icon_state = "pod_3"
		return

	icon_state = "pod_[state_num]"

/obj/structure/spacepod_frame/attack_hand()
	return