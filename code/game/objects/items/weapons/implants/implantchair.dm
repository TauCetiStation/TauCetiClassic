/obj/machinery/implantchair
	name = "loyalty implanter modifier"
	cases = list("модификатор имплантера лояльности", "модификатора имплантера лояльности", "модификатору имплантера лояльности", "модификатор имплантера лояльности", "модификатор имплантера лояльности", "модификатор имплантера лояльности")
	desc = "Используется для вживления пациентам имплантатов лояльности."
	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "implantchair"
	density = TRUE
	opacity = 0
	anchored = TRUE

	var/ready = 1
	var/malfunction = 0
	var/list/obj/item/weapon/implant/mind_protect/mindshield/implant_list = list()
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
			health_text = "<FONT color=red>Мёртв</FONT>"
		else if(src.occupant.health < 0)
			health_text = "<FONT color=red>[round(src.occupant.health,0.1)]</FONT>"
		else
			health_text = "[round(src.occupant.health,0.1)]"

	var/dat ="<B>Статус импланта</B><BR>"

	dat +="<B>Пациент:</B> [src.occupant ? "<BR>Имя: [src.occupant]<BR>Здоровье: [health_text]<BR>" : "<FONT color=red>Отсуствует</FONT>"]<BR>"
	dat += "<B>Импланты:</B> [src.implant_list.len ? "[implant_list.len]" : "<A href='?src=\ref[src];replenish=1'>Пополнить</A>"]<BR>"
	if(src.occupant)
		dat += "[src.ready ? "<A href='?src=\ref[src];implant=1'>Имплант</A>" : "Перезарядка"]<BR>"
	user.set_machine(src)

	var/datum/browser/popup = new(user, "implant", (C_CASE(src, NOMINATIVE_CASE)))
	popup.set_content(dat)
	popup.open()


/obj/machinery/implantchair/Topic(href, href_list)
	if((get_dist(src, usr) <= 1) || isAI(usr))
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

		updateUsrDialog()
		add_fingerprint(usr)
		return


/obj/machinery/implantchair/attackby(obj/item/weapon/grab/G, mob/user)
	if(!istype(G))
		return
	if(!ismob(G.affecting))
		return
	for(var/mob/living/carbon/slime/M in range(1, G.affecting))
		if(M.Victim == G.affecting)
			to_chat(user, "[G.affecting:name] не помещаются в [CASE(src, NOMINATIVE_CASE)], потому что у них на голове слизистая защёлка.")
			return
	var/mob/M = G.affecting
	if(put_mob(M))
		qdel(G)
	updateUsrDialog()


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
		to_chat(usr, "<span class='warning'><B>[C_CASE(src, NOMINATIVE_CASE)] не может хранить это!</B></span>")
		return
	if(src.occupant)
		to_chat(usr, "<span class='warning'><B>[C_CASE(src, NOMINATIVE_CASE)] уже занят кем-то!!</B></span>")
		return
	if(M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.stop_pulling()
	M.loc = src
	src.occupant = M
	add_fingerprint(usr)
	icon_state = "implantchair_on"
	return 1


/obj/machinery/implantchair/proc/implant(mob/M)
	if (!iscarbon(M))
		return
	for(var/obj/item/weapon/implant/mind_protect/mindshield/imp in implant_list)
		visible_message("<span class='userdanger'>[M] был[VERB_RU(M)] [(ANYMORPH(M, "имплантирован", "имплантирована", "имплантировано", "имплантированы"))] [src.name].</span>")
		if(imp.implanted(M))
			imp.inject(M)
		implant_list -= imp
		break


/obj/machinery/implantchair/proc/add_implants()
	for(var/i=0, i<src.max_implants, i++)
		var/obj/item/weapon/implant/mind_protect/mindshield/I = new(src)
		implant_list += I
	return

/obj/machinery/implantchair/verb/get_out()
	set name = "Eject occupant"
	set category = "Object"
	set src in oview(1)
	if(usr.incapacitated())
		return
	go_out(usr)
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
