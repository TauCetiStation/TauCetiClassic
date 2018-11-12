/obj/machinery/bluespace_pad
	name = "BluePad"
	desc = "BlueSpace pad opening a gap in the bluespace."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	anchored = 1
	use_power = 1
	idle_power_usage = 200
	active_power_usage = 5000
	var/efficiency
	var/obj/machinery/computer/bluespace_computer