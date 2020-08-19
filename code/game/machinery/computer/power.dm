// the power monitoring computer
// for the moment, just report the status of all APCs in the same powernet
/obj/machinery/computer/monitor
	name = "Power Monitoring Console"
	desc = "It monitors power levels across the station."
	icon = 'icons/obj/computer.dmi'
	icon_state = "power"
	light_color = "#ffcc33"
	density = 1
	anchored = 1
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 80
	circuit = /obj/item/weapon/circuitboard/powermonitor
	var/datum/powernet/powernet = null

//fix for issue 521, by QualityVan.
//someone should really look into why circuits have a powernet var, it's several kinds of retarded.
/obj/machinery/computer/monitor/atom_init()
	. = ..()
	var/obj/structure/cable/attached = null
	var/turf/T = loc
	if(isturf(T))
		attached = locate() in T
	if(attached)
		powernet = attached.get_powernet()

/obj/machinery/computer/monitor/process() //oh shit, somehow we didnt end up with a powernet... lets look for one.
	if(!powernet)
		var/obj/structure/cable/attached = null
		var/turf/T = loc
		if(isturf(T))
			attached = locate() in T
		if(attached)
			powernet = attached.get_powernet()
	return

/obj/machinery/computer/monitor/ui_interact(mob/user)

	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!issilicon(user) && !isobserver(user))
			user.unset_machine()
			user << browse(null, "window=powcomp")
			return


	var/t = "<TT><B>Power Monitoring</B><HR>"

	t += "<BR><HR><A href='?src=\ref[src];update=1'>Refresh</A>"
	t += "<BR><HR><A href='?src=\ref[src];close=1'>Close</A>"

	if(!powernet)
		t += "<span class='warning'>No connection</span>"
	else

		var/list/L = list()
		for(var/obj/machinery/power/terminal/term in powernet.nodes)
			if(istype(term.master, /obj/machinery/power/apc))
				var/obj/machinery/power/apc/A = term.master
				L += A

		t += "<PRE>Total power: [powernet.avail] W<BR>Total load:  [num2text(powernet.viewload,10)] W<BR>"

		t += "<FONT SIZE=-1>"

		if(L.len > 0)

			t += "Area                           Eqp./Lgt./Env.  Load   Cell<HR>"

			var/list/S = list(" Off","AOff","  On", " AOn")
			var/list/chg = list("N","C","F")

			for(var/obj/machinery/power/apc/A in L)

				t += copytext(add_tspace("\The [A.area]", 30), 1, 30)
				t += " [S[A.equipment+1]] [S[A.lighting+1]] [S[A.environ+1]] [add_lspace(A.lastused_total, 6)]  [A.cell ? "[add_lspace(round(A.cell.percent()), 3)]% [chg[A.charging+1]]" : "  N/C"]<BR>"

		t += "</FONT></PRE></TT>"

	user << browse(t, "window=powcomp;size=450x900")
	onclose(user, "powcomp")


/obj/machinery/computer/monitor/Topic(href, href_list)
	if(href_list["close"])
		usr << browse(null, "window=powcomp")
		usr.unset_machine(src)
		return FALSE

	. = ..()
	if(!.)
		return

	if( href_list["update"] )
		src.updateDialog()
		return
