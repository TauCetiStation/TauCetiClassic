#define ESCAPE_POD_1 /area/shuttle/escape_pod1/station
#define ESCAPE_POD_2 /area/shuttle/escape_pod2/station
#define ESCAPE_POD_3 /area/shuttle/escape_pod3/station
#define ESCAPE_POD_5 /area/shuttle/escape_pod5/station


/obj/machinery/computer/escapepod_console
	name = "EscapePod Console"
	icon = 'code/modules/locations/shuttles/pod.dmi'
	icon_state = "pod_console"
	req_access = list(access_captain)
	var/hacked = FALSE   //is escape pod hacked and ready to go in deep space?
	var/area/current_pod //area to check and set pod to HACKED

/obj/machinery/computer/escapepod_console/atom_init()
	. = ..()
	current_pod = get_area(src.loc)//now we get smth like /area/shuttle/escape_pod1/station - go ahead with this

/obj/machinery/computer/escapepod_console/ui_interact(mob/user)
	var/dat
	dat = {"Current pod: [current_pod]<br>
	Hacked : [hacked ? "yes" : "no"]<br>"}/*
		<a href='?src=\ref[src];mine=1'>Mining Statin</a> |
		<a href='?src=\ref[src];station=1'>NSS Exodus</a> |
		<a href='?src=\ref[src];sci=1'>Research Outpost</a><br>
		<a href='?src=\ref[user];mach_close=flightcomputer'>Close</a>"}*/

	user << browse(entity_ja(dat), "window=podflightcomputer;size=300x450")
	onclose(user, "podflightcomputer")

/obj/machinery/computer/escapepod_console/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(!current_pod)
		to_chat(usr, "\red Pod not found!")
		return FALSE
	/*if(autopilot.moving)
		to_chat(usr, "\blue Shuttle is already moving.")
		return FALSE

	var/result = FALSE
	if(href_list["mine"])
		result = autopilot.mine_sci_move_to(MINE_DOCK)
	else if(href_list["sci"])
		result = autopilot.mine_sci_move_to(SCI_DOCK)
	else if(href_list["station"])
		result = autopilot.mine_sci_move_to(STATION_DOCK)
	if(result)
		to_chat(usr, "\blue Shuttle recieved message and will be sent shortly.")*/

	updateUsrDialog()

//there is no another way to get to SSshuttle
/obj/machinery/computer/escapepod_console/proc/allow_escape()
	if(!hacked)
		hacked = TRUE
		if( istype(current_pod, ESCAPE_POD_1) ||\
			istype(current_pod, ESCAPE_POD_2) ||\
			istype(current_pod, ESCAPE_POD_3) ||\
			istype(current_pod, ESCAPE_POD_5))
			SSshuttle.is_escapepod_hacked[current_pod] = TRUE //current_pod is some of these macro names
			to_chat(world, "SSshuttle.is_escapepod_hacked[current_pod] = [SSshuttle.is_escapepod_hacked[current_pod]]")
		else
			to_chat(world, "current_pod was not in list!")

/obj/machinery/computer/escapepod_console/attackby(obj/item/weapon/W, mob/user)

	if(istype(W, /obj/item/device/pda) && W.GetID())
		//this is for future var/obj/item/weapon/card/I = W.GetID()
		allow_escape()
	else if(istype(W, /obj/item/weapon/card))
		//same var/obj/item/weapon/card/I = W
		allow_escape()

#undef ESCAPE_POD_1
#undef ESCAPE_POD_2
#undef ESCAPE_POD_3
#undef ESCAPE_POD_5