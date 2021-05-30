/obj/machinery/mining/brace
	name = "mining drill brace"
	desc = "A machinery brace for an industrial drill. It looks easily two feet thick."
	icon_state = "mining_brace"
	var/obj/machinery/mining/drill/connected

/obj/machinery/mining/brace/atom_init()
	. = ..()

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/miningdrillbrace(null)

/obj/machinery/mining/brace/Destroy()
	if(connected)
		connected.disconnect_brace(src)
	return ..()


/obj/machinery/mining/brace/attackby(obj/item/weapon/W, mob/user)
	if(connected && connected.active && !connected.wires_protector_disable)
		to_chat(user, "<span class='notice'>You can't work with the brace of a running drill!</span>")
		return

	if(default_deconstruction_screwdriver(user,"mining_brace","mining_brace", W))
		return
	if(default_deconstruction_crowbar(W, 1))
		return

	if(iswrench(W))

		if(istype(get_turf(src), /turf/space))
			to_chat(user, "<span class='notice'>You can't anchor something to empty space. Idiot.</span>")
			return
		user.SetNextMove(CLICK_CD_INTERACT)
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]anchor the brace.</span>")

		anchored = !anchored
		if(anchored)
			connect()
		else
			disconnect()
			if(connected && connected.active && connected.wires_protector_disable)
				connected.cut_hand(user)

/obj/machinery/mining/brace/proc/connect()
	connected = locate(/obj/machinery/mining/drill, get_step(src, dir))

	if(!connected)
		return

	icon_state = "mining_brace_active"
	connected.connect_brace(src)

/obj/machinery/mining/brace/proc/disconnect()

	if(!connected) return

	icon_state = "mining_brace"

	connected.disconnect_brace(src)

	connected = null

/obj/machinery/mining/brace/verb/rotate()
	set name = "Rotate"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return

	if (src.anchored)
		to_chat(usr, "It is anchored in place!")
		return 0

	src.set_dir(turn(src.dir, 90))
	return 1
