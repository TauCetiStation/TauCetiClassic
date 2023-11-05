/*
	Telecomms monitor tracks the overall trafficing of a telecommunications network
	and displays a heirarchy of linked machines.
*/


/obj/machinery/computer/telecomms/monitor
	name = "Telecommunications Monitor"
	icon_state = "comm_monitor"

	var/screen = 0				// the screen number:
	var/list/machinelist = list()	// the machines located by the computer
	var/obj/machinery/telecomms/SelectedMachine

	var/network = "NULL"		// the network to probe

	var/temp = ""				// temporary feedback messages
	circuit = /obj/item/weapon/circuitboard/comm_monitor

	light_color = "#50ab00"

/obj/machinery/computer/telecomms/monitor/attack_hand(mob/user)
	user.set_machine(src)
	var/dat = "<title>Telecommunications Monitor</title>"
	for(var/obj/structure/sensor_tower/S as anything in global.sensor_towers)
		dat += "[uppertext(S.name)]: [S.enabled ? "<font color='green'>Enabled</font>" : "<font color='red'>Disabled</font>"]<br>"
	var/datum/browser/popup = new(user, "telemonitor", "Telecommunications Monitor")
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/telecomms/monitor/attackby(obj/item/weapon/D, mob/user)
	..()
	updateUsrDialog()
	return

/obj/machinery/computer/telecomms/monitor/emag_act(mob/user)
	return FALSE
