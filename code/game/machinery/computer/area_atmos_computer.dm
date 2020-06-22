/obj/machinery/computer/area_atmos
	name = "Area Air Control"
	desc = "A computer used to control the stationary scrubbers and pumps in the area."
	icon_state = "area_atmos"
	state_broken_preset = "atmosb"
	state_nopower_preset = "atmos0"
	light_color = "#e6ffff"
	circuit = "/obj/item/weapon/circuitboard/area_atmos"

	var/list/connectedscrubbers = new()
	var/status = ""

	var/range = 25

	//Simple variable to prevent me from doing attack_hand in both this and the child computer
	var/zone = "This computer is working on a wireless range, the range is currently limited to 25 meters."

/obj/machinery/computer/area_atmos/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/area_atmos/atom_init_late()
	scanscrubbers()

/obj/machinery/computer/area_atmos/ui_interact(mob/user)
	var/dat = {"
	<html>
		<head>
			<style type="text/css">
				a.green:link
				{
					color:#00CC00;
				}
				a.green:visited
				{
					color:#00CC00;
				}
				a.green:hover
				{
					color:#00CC00;
				}
				a.green:active
				{
					color:#00CC00;
				}
				a.red:link
				{
					color:#FF0000;
				}
				a.red:visited
				{
					color:#FF0000;
				}
				a.red:hover
				{
					color:#FF0000;
				}
				a.red:active
				{
					color:#FF0000;
				}
			</style>
		</head>
		<body>
			<center><h1>Area Air Control</h1></center>
			<font color="red">[status]</font><br>
			<a href="?src=\ref[src];scan=1">Scan</a>
			<table border="1" width="90%">"}
	for(var/obj/machinery/portable_atmospherics/powered/scrubber/huge/scrubber in connectedscrubbers)
		dat += {"
				<tr>
					<td>[scrubber.name]</td>
					<td width="150"><a class="green" href="?src=\ref[src];scrub=\ref[scrubber];toggle=1">Turn On</a> <a class="red" href="?src=\ref[src];scrub=\ref[scrubber];toggle=0">Turn Off</a></td>
				</tr>"}

	dat += {"
			</table><br>
			<i>[zone]</i>
		</body>
	</html>"}
	user << browse("[dat]", "window=miningshuttle;size=400x400")
	status = ""

/obj/machinery/computer/area_atmos/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["scan"])
		scanscrubbers()
	else if(href_list["toggle"])
		var/obj/machinery/portable_atmospherics/powered/scrubber/huge/scrubber = locate(href_list["scrub"])

		if(!validscrubber(scrubber))
			spawn(20)
				status = "ERROR: Couldn't connect to scrubber! (timeout)"
				connectedscrubbers -= scrubber
				src.updateUsrDialog()
			return

		scrubber.on = text2num(href_list["toggle"])
		scrubber.update_icon()

	src.updateUsrDialog()

/obj/machinery/computer/area_atmos/proc/validscrubber(obj/machinery/portable_atmospherics/powered/scrubber/huge/scrubber)
	if(!isobj(scrubber) || get_dist(scrubber.loc, src.loc) > src.range || scrubber.loc.z != src.loc.z)
		return 0

	return 1

/obj/machinery/computer/area_atmos/proc/scanscrubbers()
	connectedscrubbers = new()

	var/found = 0
	for(var/obj/machinery/portable_atmospherics/powered/scrubber/huge/scrubber in range(range, src.loc))
		if(istype(scrubber))
			found = 1
			connectedscrubbers += scrubber

	if(!found)
		status = "ERROR: No scrubber found!"

	src.updateUsrDialog()


/obj/machinery/computer/area_atmos/area
	zone = "This computer is working in a wired network limited to this area."

/obj/machinery/computer/area_atmos/area/validscrubber(obj/machinery/portable_atmospherics/powered/scrubber/huge/scrubber)
	if(!isobj(scrubber))
		return FALSE

	var/area/A_src = get_area(src)
	var/area/A_scrub = get_area(scrubber)
	if(!A_src || !A_scrub)
		return FALSE

	if(A_src != A_scrub)
		return FALSE

	return TRUE

/obj/machinery/computer/area_atmos/area/scanscrubbers()
	connectedscrubbers = new()

	var/area/A = get_area(src)
	if(!A)
		return

	for(var/obj/machinery/portable_atmospherics/powered/scrubber/huge/scrubber in scrubber_huge_list)
		var/area/A2 = get_area(scrubber)
		if(A2 && A2 == A)
			connectedscrubbers += scrubber

	if(!length(connectedscrubbers))
		status = "ERROR: No scrubber found!"

	src.updateUsrDialog()
