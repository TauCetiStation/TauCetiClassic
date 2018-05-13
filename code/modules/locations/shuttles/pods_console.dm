#define ESCAPE_POD_1 /area/shuttle/escape_pod1/station
#define ESCAPE_POD_2 /area/shuttle/escape_pod2/station
#define ESCAPE_POD_3 /area/shuttle/escape_pod3/station
#define ESCAPE_POD_5 /area/shuttle/escape_pod5/station


/obj/machinery/computer/escapepod_console
	name = "EscapePod Console"
	icon = 'code/modules/locations/shuttles/pods_machinery.dmi'
	desc = "This is pod's on-board computer. Try not to destroy this important thing!"
	icon_state = "console"
	density = FALSE
	req_access = list(access_captain)
	var/hacked = FALSE   //is escape pod hacked and ready to go in deep space?
	var/area/current_pod //area to check and set pod to HACKED

/obj/machinery/computer/escapepod_console/atom_init()
	. = ..()
	current_pod = get_area(src.loc)//now we get smth like /area/shuttle/escape_pod1/station - go ahead with this

/obj/machinery/computer/escapepod_console/ui_interact(mob/user)
	var/dat
	dat = {"Current pod: [current_pod]<br>
	Hacked : [hacked ? "yes" : "no"]<br>"}

	user << browse(entity_ja(dat), "window=podflightcomputer;size=300x450")
	onclose(user, "podflightcomputer")

/obj/machinery/computer/escapepod_console/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(!current_pod)
		to_chat(usr, "\red Pod not found!")
		return FALSE

	updateUsrDialog()

//there is no another way to get to SSshuttle
/obj/machinery/computer/escapepod_console/proc/allow_escape()
	if(!hacked)
		hacked = TRUE//Hacked only once per round
		if( ispath(current_pod.type, ESCAPE_POD_1) ||\
			ispath(current_pod.type, ESCAPE_POD_2) ||\
			ispath(current_pod.type, ESCAPE_POD_3) ||\
			ispath(current_pod.type, ESCAPE_POD_5))
			SSshuttle.is_escapepod_hacked[current_pod.type] = TRUE //current_pod is some of these macro names
			to_chat(world, "SSshuttle.is_escapepod_hacked :[current_pod.type] = [SSshuttle.is_escapepod_hacked[current_pod.type]]")
		else
			to_chat(world, "current_pod was not in list!")

/obj/machinery/computer/escapepod_console/attackby(obj/item/weapon/W, mob/user)

	if(istype(W, /obj/item/device/pda) && W.GetID())
		var/obj/item/weapon/card/I = W.GetID()
		if(check_access(I))
			visible_message("<span class='info'>[user] applies a PDA to [src]. </span>")
			to_chat(user, "<span class='info'>You hear that [src] softly beeps two times. </span>")
			allow_escape()

	else if(istype(W, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/I = W
		if(check_access(I))
			visible_message("<span class='info'>[user] swipes a card through [src] and it softly beeps three times.</span>")
			allow_escape()

	else if (istype(W, /obj/item/weapon/card/emag))
		visible_message("<span class='info'>[user] swipes a card through [src], it flashes red and beeps one time .</span>")
		allow_escape()//emag should serve just as a pass, without using it's charges. Broken emag is also accepted.
	..()

#undef ESCAPE_POD_1
#undef ESCAPE_POD_2
#undef ESCAPE_POD_3
#undef ESCAPE_POD_5