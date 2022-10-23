/obj/machinery/computer/research_shuttle/new_shuttle_white
	icon = 'icons/locations/shuttles/computer_shuttle_white.dmi'

/obj/machinery/computer/mining_shuttle/new_shuttle_mining
	icon = 'icons/locations/shuttles/computer_shuttle_mining.dmi'

/obj/machinery/computer/security/erokez
	name = "security camera monitor"
	desc = "Used to access the various cameras on the station."
	icon = 'icons/obj/computer.dmi'
	icon_state = "erokez"
	light_color = "#ffffbb"
	network = list("SS13")

/obj/machinery/computer/security/erokez/update_icon()
	icon_state = initial(icon_state)
	if(stat & BROKEN)
		icon_state += "b"
	return

/obj/machinery/computer/crew/erokez
	name = "crew monitoring computer"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon = 'icons/obj/computer.dmi'
	icon_state = "erokezz"
	light_color = "#315ab4"

/obj/machinery/computer/crew/erokez/update_icon()
	icon_state = initial(icon_state)
	if(stat & BROKEN)
		icon_state += "b"
	return
