/obj/machinery/computer/bluespace_computer
	name = "\improper Telepad Control Console"
	desc = "Used to teleport objects to and from the telescience telepad."
	icon_state = "teleport"
	circuit = /obj/item/weapon/circuitboard/telesci_console
	light_color = "#315ab4"
	idle_power_usage = 250
	active_power_usage = 75000
	var/obj/machinery/bluespace_pad/pad = null
	var/temp_msg = "Telescience control console initialized.<BR>Welcome."