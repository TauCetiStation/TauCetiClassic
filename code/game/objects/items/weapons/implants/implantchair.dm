//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/machinery/implantchair
	name = "loyalty implanter"
	desc = "Used to implant occupants with loyalty implants."
	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "implantchair"
	density = 1
	opacity = 0
	anchored = 1

	var/ready = 1
	var/malfunction = 0
	var/list/obj/item/weapon/implant/mindshield/implant_list = list()
	var/max_implants = 5
	var/injection_cooldown = 600
	var/replenish_cooldown = 6000
	var/replenishing = 0
	var/injecting = 0

/obj/machinery/implantchair/atom_init()
	. = ..()
	add_implants()


/obj/machinery/implantchair/ui_interact(mob/user)
	var/health_text = ""
	if(src.occupant)
		if(src.occupant.health <= -100)
			health_text = "<FONT color=red>Dead</FONT>"
		else if(src.occupant.health < 0)
			health_text = "<FONT color=red>[round(src.occupant.health,0.1)]</FONT>"
		else
			health_text = "[round(src.occupant.health,0.1)]"

	var/dat ="<B>Implanter Status</B><BR>"

	dat +="<B>Current occupant:</B> [src.occupant ? "<BR>Name: [src.occupant]<BR>Health: [health_text]<BR>" : "<FONT color=red>None</FONT>"]<BR>"
	dat += "<B>Implants:</B> [src.implant_list.len ? "[implant_list.len]" : "<A href='?src=\ref[src];replenish=1'>Replenish</A>"]<BR>"
	if(src.occupant)
		dat += "[src.ready ? "<A href='?src=\ref[src];implant=1'>Implant</A>" : "Recharging"]<BR>"
	user.set_machine(src)
	user << browse(dat, "window=implant")
	onclose(user, "implant")


/obj/machinery/implantchair/Topic(href, href_list)
	if((get_dist(src, usr) <= 1) || istype(usr, /mob/living/silicon/ai))
		if(href_list["implant"])
			if(src.occupant)
				injecting = 1
				go_out()
				ready = 0
				spawn(injection_cooldown)
					ready = 1

		if(href_list["replenish"])
			ready = 0
			spawn(replenish_cooldown)
				add_implants()
				ready = 1

		src.updateUsrDialog()
		src.add_fingerprint(usr)
		return


/obj/machinery/implantchair/attackby(obj/item/weapon/grab/G, mob/user)
	if(!istype(G))
		return
	if(!ismob(G.affecting))
		return
	for(var/mob/living/carbon/slime/M in range(1, G.affecting))
		if(M.Victim == G.affecting)
			to_chat(user, "[G.affecting:name] will not fit into the [src.name] because they have a slime latched onto their head.")
			return
	var/mob/M = G.affecting
	if(put_mob(M))
		qdel(G)
	src.updateUsrDialog()


/obj/machinery/implantchair/proc/go_out(mob/M)
	if(!( src.occupant ))
		return
	if(M == occupant) // so that the guy inside can't eject himself -Agouri
		return
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	if(injecting)
		implant(src.occupant)
		injecting = 0
	src.occupant = null
	icon_state = "implantchair"
	return


/obj/machinery/implantchair/proc/put_mob(mob/living/carbon/M)
	if(!iscarbon(M))
		to_chat(usr, "<span class='warning'><B>The [src.name] cannot hold this!</B></span>")
		return
	if(src.occupant)
		to_chat(usr, "<span class='warning'><B>The [src.name] is already occupied!</B></span>")
		return
	if(M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.stop_pulling()
	M.loc = src
	src.occupant = M
	src.add_fingerprint(usr)
	icon_state = "implantchair_on"
	return 1


/obj/machinery/implantchair/proc/implant(mob/M)
	if (!istype(M, /mob/living/carbon))
		return
	for(var/obj/item/weapon/implant/mindshield/imp in implant_list)
		visible_message("<span class='userdanger'>[M] has been implanted by the [src.name].</span>")
		if(imp.implanted(M))
			imp.inject(M)
		implant_list -= imp
		break


/obj/machinery/implantchair/proc/add_implants()
	for(var/i=0, i<src.max_implants, i++)
		var/obj/item/weapon/implant/mindshield/I = new(src)
		implant_list += I
	return

/obj/machinery/implantchair/verb/get_out()
	set name = "Eject occupant"
	set category = "Object"
	set src in oview(1)
	if(usr.incapacitated())
		return
	src.go_out(usr)
	add_fingerprint(usr)
	return

/obj/machinery/implantchair/verb/move_inside()
	set name = "Move Inside"
	set category = "Object"
	set src in oview(1)
	if(usr.incapacitated() || stat & (NOPOWER|BROKEN))
		return
	put_mob(usr)
	return
