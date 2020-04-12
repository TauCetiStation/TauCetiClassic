//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/machinery/particle_accelerator/control_box
	name = "Particle Accelerator Control Computer"
	desc = "This controls the density of the particles."
	icon = 'icons/obj/machines/particle_accelerator2.dmi'
	icon_state = "control_box"
	reference = "control_box"
	anchored = 0
	density = 1
	use_power = NO_POWER_USE
	idle_power_usage = 500
	active_power_usage = 10000
	construction_state = 0
	active = 0
	dir = 1
	allowed_checks = ALLOWED_CHECK_TOPIC
	var/list/obj/structure/particle_accelerator/connected_parts
	var/assembled = 0
	var/parts = null

/obj/machinery/particle_accelerator/control_box/atom_init()
	connected_parts = list()
	. = ..()

/obj/machinery/particle_accelerator/control_box/Destroy()
	if(active)
		toggle_power()
	return ..()

/obj/machinery/particle_accelerator/control_box/interact(mob/user)
	if(construction_state >= 3)
		..()

/obj/machinery/particle_accelerator/control_box/update_state()
	if(construction_state < 3)
		set_power_use(NO_POWER_USE)
		assembled = 0
		active = 0
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = null
			part.powered = 0
			part.update_icon()
		connected_parts = list()
		return
	if(!part_scan())
		set_power_use(IDLE_POWER_USE)
		active = 0
		connected_parts = list()

/obj/machinery/particle_accelerator/control_box/update_icon()
	if(active)
		icon_state = "[reference]p1"
	else
		if(use_power)
			if(assembled)
				icon_state = "[reference]p"
			else
				icon_state = "u[reference]p"
		else
			switch(construction_state)
				if(0)
					icon_state = "[reference]"
				if(1)
					icon_state = "[reference]"
				if(2)
					icon_state = "[reference]w"
				else
					icon_state = "[reference]c"
	return

/obj/machinery/particle_accelerator/control_box/Topic(href, href_list)
	if(href_list["close"])
		usr.unset_machine(src)
		usr << browse(null, "window=pacontrol")
		return FALSE

	. = ..()
	if(!.)
		return

	if(href_list["togglep"])
		src.toggle_power()
		log_investigate("turned [active?"<font color='red'>ON</font>":"<font color='green'>OFF</font>"] by [key_name(usr)]",INVESTIGATE_SINGULO)
		if (active)
			message_admins("PA Control Computer turned ON by [key_name(usr, usr.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) in ([x],[y],[z] - [ADMIN_JMP(src)])",0,1)
			log_game("PA Control Computer turned ON by [usr.ckey]([usr]) in ([x],[y],[z])")
	else if(href_list["scan"])
		src.part_scan()
	else if(href_list["strengthup"])
		strength++
		if(strength > 2)
			strength = 2
		else
			message_admins("PA Control Computer increased to [strength] by [key_name(usr, usr.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) in ([x],[y],[z] - [ADMIN_JMP(src)])",0,1)
			log_game("PA Control Computer increased to [strength] by [usr.ckey]([usr]) in ([x],[y],[z])")
			log_investigate("increased to <font color='red'>[strength]</font> by [key_name(usr)]",INVESTIGATE_SINGULO)
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = strength
			part.update_icon()

	else if(href_list["strengthdown"])
		strength--
		if(strength < 0)
			strength = 0
		else
			log_investigate("decreased to <font color='green'>[strength]</font> by [key_name(usr)]",INVESTIGATE_SINGULO)
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = strength
			part.update_icon()

	src.updateDialog()
	src.update_icon()


/obj/machinery/particle_accelerator/control_box/power_change()
	..()
	if(stat & NOPOWER)
		active = 0
		set_power_use(NO_POWER_USE)
	else if(!stat && construction_state == 3)
		set_power_use(IDLE_POWER_USE)
	return


/obj/machinery/particle_accelerator/control_box/process()
	if(src.active)
		//a part is missing!
		if( length(connected_parts) < 6 )
			log_investigate("lost a connected part; It <font color='red'>powered down</font>.",INVESTIGATE_SINGULO)
			src.toggle_power()
			return
		//emit some particles
		for(var/obj/structure/particle_accelerator/particle_emitter/PE in connected_parts)
			if(PE)
				PE.emit_particle(src.strength)
	return


/obj/machinery/particle_accelerator/control_box/proc/part_scan()
	for(var/obj/structure/particle_accelerator/fuel_chamber/F in orange(1,src))
		src.dir = F.dir
	connected_parts = list()
	var/tally = 0
	var/ldir = turn(dir,-90)
	var/rdir = turn(dir,90)
	var/odir = turn(dir,180)
	var/turf/T = src.loc
	T = get_step(T,rdir)
	if(check_part(T,/obj/structure/particle_accelerator/fuel_chamber))
		tally++
	T = get_step(T,odir)
	if(check_part(T,/obj/structure/particle_accelerator/end_cap))
		tally++
	T = get_step(T,dir)
	T = get_step(T,dir)
	if(check_part(T,/obj/structure/particle_accelerator/power_box))
		tally++
	T = get_step(T,dir)
	if(check_part(T,/obj/structure/particle_accelerator/particle_emitter/center))
		tally++
	T = get_step(T,ldir)
	if(check_part(T,/obj/structure/particle_accelerator/particle_emitter/left))
		tally++
	T = get_step(T,rdir)
	T = get_step(T,rdir)
	if(check_part(T,/obj/structure/particle_accelerator/particle_emitter/right))
		tally++
	if(tally >= 6)
		assembled = 1
		return 1
	else
		assembled = 0
		return 0


/obj/machinery/particle_accelerator/control_box/proc/check_part(turf/T, type)
	if(!(T)||!(type))
		return 0
	var/obj/structure/particle_accelerator/PA = locate(/obj/structure/particle_accelerator) in T
	if(istype(PA, type))
		if(PA.connect_master(src))
			if(PA.report_ready(src))
				src.connected_parts.Add(PA)
				return 1
	return 0


/obj/machinery/particle_accelerator/control_box/proc/toggle_power()
	src.active = !src.active
	if(src.active)
		set_power_use(ACTIVE_POWER_USE)
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = src.strength
			part.powered = 1
			part.update_icon()
	else
		set_power_use(IDLE_POWER_USE)
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = null
			part.powered = 0
			part.update_icon()
	return 1


/obj/machinery/particle_accelerator/control_box/ui_interact(mob/user)
	if(!in_range(src, user) && !issilicon(user) && !isobserver(user))
		user.unset_machine()
		user << browse(null, "window=pacontrol")
		return

	var/dat = ""
	dat += "Particle Accelerator Control Panel<BR>"
	dat += "<A href='?src=\ref[src];close=1'>Close</A><BR><BR>"
	dat += "Status:<BR>"
	if(!assembled)
		dat += "Unable to detect all parts!<BR>"
		dat += "<A href='?src=\ref[src];scan=1'>Run Scan</A><BR><BR>"
	else
		dat += "All parts in place.<BR><BR>"
		dat += "Power:"
		if(active)
			dat += "On<BR>"
		else
			dat += "Off <BR>"
		dat += "<A href='?src=\ref[src];togglep=1'>Toggle Power</A><BR><BR>"
		dat += "Particle Strength: [src.strength] "
		dat += "<A href='?src=\ref[src];strengthdown=1'>--</A>|<A href='?src=\ref[src];strengthup=1'>++</A><BR><BR>"

	user << browse(dat, "window=pacontrol;size=420x500")
	onclose(user, "pacontrol")
