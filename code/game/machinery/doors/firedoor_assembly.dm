/obj/structure/firedoor_assembly
	name = "emergency shutter assembly"
	desc = "It can save lives."
	icon = 'icons/obj/doors/DoorHazard.dmi'
	icon_state = "door_construction"
	anchored = 0
	opacity = 0
	density = 1
	var/wired = 0

/obj/structure/firedoor_assembly/update_icon()
	if(anchored)
		icon_state = "door_anchored"
	else
		icon_state = "door_construction"

/obj/structure/firedoor_assembly/attackby(obj/item/C, mob/user)
	if(iscoil(C) && !wired && anchored)
		var/obj/item/stack/cable_coil/cable = C
		if (cable.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one length of coil to wire \the [src].</span>")
			return
		if(user.is_busy(src)) return
		user.visible_message("[user] wires \the [src].", "You start to wire \the [src].")
		if(cable.use_tool(src, user, 40, volume = 50) && !wired && anchored)
			if (cable.use(1))
				wired = 1
				to_chat(user, "<span class='notice'>You wire \the [src].</span>")

	else if(iswirecutter(C) && wired )
		if(user.is_busy(src)) return
		user.visible_message("[user] cuts the wires from \the [src].", "You start to cut the wires from \the [src].")

		if(C.use_tool(src, user, 40, volume = 100))
			to_chat(user, "<span class='notice'>You cut the wires!</span>")
			new /obj/item/stack/cable_coil/random(src.loc, 1)
			wired = 0

	else if(istype(C, /obj/item/weapon/airalarm_electronics) && wired)
		if(anchored)
			playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
			user.visible_message("<span class='warning'>[user] has inserted a circuit into \the [src]!</span>",
								  "You have inserted the circuit into \the [src]!")
			new /obj/machinery/door/firedoor(src.loc)
			qdel(C)
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You must secure \the [src] first!</span>")
	else if(iswrench(C))
		anchored = !anchored
		user.visible_message("<span class='warning'>[user] has [anchored ? "" : "un" ]secured \the [src]!</span>",
							 "You have [anchored ? "" : "un" ]secured \the [src]!")
		update_icon()
	else if(!anchored && iswelder(C))
		var/obj/item/weapon/weldingtool/WT = C
		if(user.is_busy(src)) return
		if(WT.use(0, user))
			user.visible_message("<span class='warning'>[user] dissassembles \the [src].</span>",
			"You start to dissassemble \the [src].")
			if(C.use_tool(src, user, 40, volume = 50))
				user.visible_message("<span class='warning'>[user] has dissassembled \the [src].</span>",
									 "You have dissassembled \the [src].")
				new /obj/item/stack/sheet/metal(src.loc, 2)
				qdel(src)
		else
			to_chat(user, "<span class='notice'>You need more welding fuel.</span>")
	else
		return ..()
