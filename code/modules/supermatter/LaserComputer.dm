//The laser control computer
//Used to control the lasers
/obj/machinery/computer/lasercon
	name = "Laser control computer"
	var/list/lasers = list()
	icon_state = "atmos"
	var/id
	//var/advanced = 0

/obj/machinery/computer/lasercon

/obj/machinery/computer/lasercon/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/lasercon/atom_init_late()
	for(var/obj/machinery/zero_point_emitter/las in machines)
		if(las.id == src.id)
			lasers += las

/obj/machinery/computer/lasercon/process()
	..()
	updateDialog()

/obj/machinery/computer/lasercon/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!issilicon(user))
			user.machine = null
			user << browse(null, "window=laser_control")
			return
	var/t = "<TT>"
	for(var/obj/machinery/zero_point_emitter/laser in lasers)
		t += "Zero Point Laser<br>"
		t += "Power level: <A href = '?src=\ref[laser];input=-0.005'>-</A> <A href = '?src=\ref[laser];input=-0.001'>-</A> <A href = '?src=\ref[laser];input=-0.0005'>-</A> <A href = '?src=\ref[laser];input=-0.0001'>-</A> [laser.energy]MeV <A href = '?src=\ref[laser];input=0.0001'>+</A> <A href = '?src=\ref[laser];input=0.0005'>+</A> <A href = '?src=\ref[laser];input=0.001'>+</A> <A href = '?src=\ref[laser];input=0.005'>+</A><BR>"
		t += "Frequency: <A href = '?src=\ref[laser];freq=-10000'>-</A> <A href = '?src=\ref[laser];freq=-1000'>-</A> [laser.freq] <A href = '?src=\ref[laser];freq=1000'>+</A> <A href = '?src=\ref[laser];freq=10000'>+</A><BR>"
		t += "Output: [laser.active ? "<B>Online</B> <A href = '?src=\ref[laser];online=1'>Offline</A>" : "<A href = '?src=\ref[laser];online=1'>Online</A> <B>Offline</B> "]<BR>"
	t += "<hr>"

	var/datum/browser/popup = new(user, "laser_control", "Laser status monitor", 500, 800)
	popup.set_content(t)
	popup.open()

	user.machine = src


/obj/machinery/computer/lasercon/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["input"])
		var/i = text2num(href_list["input"])
		var/d = i
		for(var/obj/machinery/zero_point_emitter/laser in lasers)
			var/new_power = laser.energy + d
			new_power = max(new_power,0.0001)	//lowest possible value
			new_power = min(new_power,0.01)		//highest possible value
			laser.energy = new_power
	else if(href_list["online"])
		var/obj/machinery/zero_point_emitter/laser = href_list["online"]
		laser.active = !laser.active
	else if(href_list["freq"])
		var/amt = text2num(href_list["freq"])
		for(var/obj/machinery/zero_point_emitter/laser in lasers)
			var/new_freq = laser.frequency + amt
			new_freq = max(new_freq,1)		//lowest possible value
			new_freq = min(new_freq,20000)	//highest possible value
			laser.frequency = new_freq

	updateDialog()
