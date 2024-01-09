// move to machinery
/obj/machinery/windowtint/attack_hand(mob/user as mob)
	if(..())
		return 1

	toggle_tint()

/obj/machinery/windowtint/proc/toggle_tint()
	use_power(5)

	active = !active
	update_icon()

	for(var/obj/structure/window/fulltile/polarized/W in range(src,range))
		if ((W.id == src.id || !W.id))
			W.toggle()

	for(var/obj/structure/window/fulltile/reinforced/polarized/W in range(src,range))
		if ((W.id == src.id || !W.id))
			W.toggle()

/obj/machinery/windowtint/power_change()
	..()
	if(active && !powered(power_channel))
		toggle_tint()

/obj/machinery/windowtint/update_icon()
	icon_state = "light[active]"

/obj/machinery/windowtint/attackby(obj/item/W as obj, mob/user as mob)
	if(ispulsing(W))
		var/t = sanitize(input(user, "Enter an ID for \the [src].", src.name, null), MAX_NAME_LEN)
		src.id = t
		to_chat(user, "<span class='notice'>The new ID of \the [src] is [id]</span>")
		return
	. = ..()
