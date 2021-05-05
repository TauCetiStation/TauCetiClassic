/obj/machinery/computer/gyrotron_control
	name = "gyrotron control console"
	icon = 'icons/obj/machines/power/fusion.dmi'
	icon_state = "engine"
	light_color = COLOR_BLUE

	var/id_tag
	var/scan_range = 25

/obj/machinery/computer/gyrotron_control/ui_interact(mob/user)

	if(!id_tag)
		to_chat(user, "<span class='warning'>This console has not been assigned an ident tag. Please contact your system administrator or conduct a manual update with a standard multitool.</span>")
		return

	var/dat = "<td><b>Gyrotron controller #[id_tag]</b>"

	dat = "<table><tr>"
	dat += "<td><b>Mode</b></td>"
	dat += "<td><b>Fire Delay</b></td>"
	dat += "<td><b>Power</b></td>"
	dat += "</tr>"

	for(var/obj/machinery/power/emitter/gyrotron/G in gyrotrons)
		if(!G || G.id_tag != id_tag || get_dist(src, G) > scan_range)
			continue

		dat += "<tr>"
		if(G.state != 2 || (G.stat & (NOPOWER | BROKEN))) //Error data not found.
			dat += "<td><span style='color: red'>ERROR</span></td>"
			dat += "<td><span style='color: red'>ERROR</span></td>"
			dat += "<td><span style='color: red'>ERROR</span></td>"
		else
			dat += "<td><a href='?src=\ref[src];machine=\ref[G];toggle=1'>[G.active  ? "Emitting" : "Standing By"]</a></td>"
			dat += "<td><a href='?src=\ref[src];machine=\ref[G];modifyrate=1'>[G.rate]</a></td>"
			dat += "<td><a href='?src=\ref[src];machine=\ref[G];modifypower=1'>[G.mega_energy]</a></td>"

	dat += "</tr></table>"

	var/datum/browser/popup = new(user, "gyrotron_controller_[id_tag]", "Gyrotron Remote Control Console", 500, 400, src)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/gyrotron_control/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(stat & (NOPOWER | BROKEN))
		return

	var/obj/machinery/power/emitter/gyrotron/G = locate(href_list["machine"])
	if(!G || G.id_tag != id_tag || get_dist(src, G) > scan_range)
		return

	if(href_list["modifypower"])
		var/new_val = input("Enter new emission power level (1 - 50)", "Modifying power level", G.mega_energy) as num
		if(!new_val)
			to_chat(usr, "<span class='warning'>That's not a valid number.</span>")
			return
		G.mega_energy = clamp(new_val, 1, 50)
		G.active_power_usage = G.mega_energy * 1500
		updateUsrDialog()
		return

	if(href_list["modifyrate"])
		var/new_val = input("Enter new emission delay between 1 and 10 seconds.", "Modifying emission rate", G.rate) as num
		if(!new_val)
			to_chat(usr, "<span class='warning'>That's not a valid number.</span>")
			return
		G.rate = clamp(new_val, 1, 10)
		updateUsrDialog()
		return

	if(href_list["toggle"])
		G.activate(usr)
		updateUsrDialog()
		return

/obj/machinery/computer/gyrotron_control/attackby(obj/item/W, mob/user)
	if(ismultitool(W))
		var/new_ident = sanitize_safe(input("Enter a new ident tag.", "Gyrotron Control", input_default(id_tag)) as null|text, MAX_LNAME_LEN)
		if(new_ident && user.Adjacent(src))
			id_tag = new_ident
		return
	return ..()
