

/obj/machinery/power/port_gen/riteg
	name = "C.H.E.R.N.O.B.Y.L-type Portable Emergency Generator"
	icon_state = "portgen1"
	icon_state_on = "portgen1"
	power_gen = 5000
	var/rad_cooef = 40
	var/rad_range = 1

/obj/machinery/power/port_gen/riteg/attackby(obj/item/O, mob/user, params)
	if(!active)

		if(iswrench(O))

			if(!anchored && !isinspace())
				connect_to_network()
				to_chat(user, "<span class='notice'>You secure the generator to the floor.</span>")
				anchored = 1
			else if(anchored)
				disconnect_from_network()
				to_chat(user, "<span class='notice'>You unsecure the generator from the floor.</span>")
				anchored = 0

			playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)

/obj/machinery/power/port_gen/riteg/emag_act(mob/user)
	if(emagged)
		return FALSE
	emagged = 1
	emp_act(1)
	return TRUE

/obj/machinery/power/port_gen/riteg/ui_interact(mob/user)
	if ((get_dist(src, user) > 1) && !issilicon(user) && !isobserver(user))
		user.unset_machine(src)
		user << browse(null, "window=port_gen")
		return

	var/dat = text("<b>[name]</b><br>")
	if (active)
		dat += text("Generator: <A href='?src=\ref[src];action=disable'>On</A><br>")
	else
		dat += text("Generator: <A href='?src=\ref[src];action=enable'>Off</A><br>")
	dat += text("Power output: [power_gen * power_output]<br>")
	dat += text("Power current: [(powernet == null ? "Unconnected" : "[avail()]")]<br>")
	dat += "<br><A href='?src=\ref[src];action=close'>Close</A>"
	user << browse("[dat]", "window=port_gen")
	onclose(user, "port_gen")

/obj/machinery/power/port_gen/riteg/is_operational_topic()
	return TRUE

/obj/machinery/power/port_gen/riteg/Topic(href, href_list)
	if (href_list["action"] == "close")
		usr << browse(null, "window=port_gen")
		usr.unset_machine(src)
		return FALSE

	. = ..()
	if(!.)
		return

	if(href_list["action"])
		if(href_list["action"] == "enable")
			if(!active && HasFuel() && !crit_fail)
				active = 1
				icon_state = icon_state_on
		if(href_list["action"] == "disable")
			if (active)
				active = 0
				icon_state = initial(icon_state)

	src.updateUsrDialog()


/obj/machinery/power/port_gen/riteg/proc/Pulse_radiation()
	for(var/mob/living/l in range(rad_range,src))
		l.show_message("<span class=\"warning\">You feel warm</span>", SHOWMSG_FEEL)
		var/rads = rad_cooef * sqrt( 1 / (get_dist(l, src) + 1) )
		l.apply_effect(rads, IRRADIATE)

/obj/machinery/power/port_gen/riteg/process()

	if(active  && !crit_fail && anchored && powernet)
		add_avail(power_gen * power_output)
		UseFuel()
		Pulse_radiation()
		src.updateDialog()

	else
		active = 0
		icon_state = initial(icon_state)
		handleInactive()
