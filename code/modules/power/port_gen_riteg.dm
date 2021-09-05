

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
				anchored = TRUE
			else if(anchored)
				disconnect_from_network()
				to_chat(user, "<span class='notice'>You unsecure the generator from the floor.</span>")
				anchored = FALSE

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

	var/dat = ""
	if (active)
		dat += text("Generator: <A href='?src=\ref[src];action=disable'>On</A><br>")
	else
		dat += text("Generator: <A href='?src=\ref[src];action=enable'>Off</A><br>")
	dat += text("Power output: [power_gen * power_output]<br>")
	dat += text("Power current: [(powernet == null ? "Unconnected" : "[avail()]")]<br>")

	var/datum/browser/popup = new(user, "port_gen", src.name)
	popup.set_content(dat)
	popup.open()

/obj/machinery/power/port_gen/riteg/is_operational()
	return TRUE

/obj/machinery/power/port_gen/riteg/Topic(href, href_list)
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

	updateUsrDialog()


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
		updateDialog()

	else
		active = 0
		icon_state = initial(icon_state)
		handleInactive()
