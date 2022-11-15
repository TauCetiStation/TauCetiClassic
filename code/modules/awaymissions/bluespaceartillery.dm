
/obj/machinery/artillerycontrol
	var/reload = 180
	var/intensity = 1
	name = "bluespace artillery control"
	icon_state = "control_boxp1"
	icon = 'icons/obj/machines/particle_accelerator2.dmi'
	density = TRUE
	anchored = TRUE

	var/datum/announcement/centcomm/bsa/announcement = new

/obj/machinery/artillerycontrol/process()
	if(src.reload<180)
		src.reload++

/obj/structure/artilleryplaceholder
	name = "artillery"
	icon = 'icons/obj/machines/artillery.dmi'
	anchored = TRUE
	density = TRUE

/obj/structure/artilleryplaceholder/decorative
	density = FALSE

/obj/machinery/artillerycontrol/ui_interact(mob/user)
	var/dat = ""
	dat += "Locked on<BR>"
	dat += "<B>Charge progress: [reload]/180:</B><BR>"
	dat += "The Bluespace Artillery in mode: "
	if(intensity)
		dat += "<a class='red' href='?src=\ref[src];toggle=1'>Destroy</a>"
	else
		dat += "<a class='green' href='?src=\ref[src];toggle=1'>Hurt</a>"
	dat += "<br>"
	dat += "<A href='byond://?src=\ref[src];fire=1'>Open Fire</A><BR>"
	dat += "Deployment of weapon authorized by <br>Nanotrasen Naval Command<br><br>Remember, friendly fire is grounds for termination of your contract and life.<HR>"

	var/datum/browser/popup = new(user, "scroll", "Bluespace Artillery Control")
	popup.set_content(dat)
	popup.open()


/obj/machinery/artillerycontrol/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if( href_list["toggle"] )
		intensity = !intensity
	if(href_list["fire"])
		if(src.reload < (intensity ? 180 : 90))
			return FALSE
		var/A
		A = input("Area to jump bombard", "Open Fire", A) in teleportlocs
		var/area/thearea = teleportlocs[A]
		var/list/L = list()
		for(var/turf/T in get_area_turfs(thearea.type))
			if(!iswallturf(T) && !isenvironmentturf(T))
				L+=T
		var/loc = pick(L)
		if(loc)
			if(intensity)
				announcement.play(thearea)
				message_admins("[key_name_admin(usr)] has launched an artillery strike at [thearea.name]. [ADMIN_JMP(thearea)]")
				explosion(loc,2,5,11)
			else
				explosion(loc,2,1,0)
			reload -= (intensity ? 180 : 90)
		else
			to_chat(usr,"There already everything is destroyed")
