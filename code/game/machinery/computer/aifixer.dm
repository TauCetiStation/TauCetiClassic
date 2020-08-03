/obj/machinery/computer/aifixer
	name = "AI System Integrity Restorer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "ai-fixer"
	light_color = "#a97faa"
	circuit = /obj/item/weapon/circuitboard/aifixer
	req_access = list(access_heads)
	var/mob/living/silicon/ai/occupier = null
	var/active = 0
	circuit = /obj/item/weapon/circuitboard/aifixer

/obj/machinery/computer/aifixer/atom_init()
	add_overlay(image('icons/obj/computer.dmi', "ai-fixer-empty"))
	. = ..()

/obj/machinery/computer/aifixer/attackby(I, user)
	if(istype(I, /obj/item/device/aicard))
		if(stat & (NOPOWER | BROKEN))
			to_chat(user, "This terminal isn't functioning right now, get it working!")
			return
		var/obj/item/device/aicard/AIcard = I
		AIcard.transfer_ai("AIFIXER", "AICARD", src, user)
	else
		..()
	return

/obj/machinery/computer/aifixer/ui_interact(mob/user)
	var/dat = "<h3>AI System Integrity Restorer</h3><br><br>"

	if (src.occupier)
		var/laws
		dat += "Stored AI: [src.occupier.name]<br>System integrity: [(src.occupier.health+100)/2]%<br>"

		if (src.occupier.laws.zeroth)
			laws += "0: [src.occupier.laws.zeroth]<BR>"

		var/number = 1
		for (var/index = 1, index <= src.occupier.laws.inherent.len, index++)
			var/law = src.occupier.laws.inherent[index]
			if (length(law) > 0)
				laws += "[number]: [law]<BR>"
				number++

		for (var/index = 1, index <= src.occupier.laws.supplied.len, index++)
			var/law = src.occupier.laws.supplied[index]
			if (length(law) > 0)
				laws += "[number]: [law]<BR>"
				number++

		dat += "Laws:<br>[laws]<br>"

		if (src.occupier.stat == DEAD)
			dat += "<b>AI nonfunctional</b>"
		else
			dat += "<b>AI functional</b>"
		if (!src.active)
			dat += {"<br><br><A href='byond://?src=\ref[src];fix=1'>Begin Reconstruction</A>"}
		else
			dat += "<br><br>Reconstruction in process, please wait.<br>"
	dat += {" <A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")

/obj/machinery/computer/aifixer/process()
	if(..())
		src.updateDialog()
		return

/obj/machinery/computer/aifixer/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if (href_list["fix"])
		src.active = 1
		add_overlay(image('icons/obj/computer.dmi', "ai-fixer-on"))
		while (src.occupier.health < 100)
			src.occupier.adjustOxyLoss(-1)
			src.occupier.adjustFireLoss(-1)
			src.occupier.adjustToxLoss(-1)
			src.occupier.adjustBruteLoss(-1)
			src.occupier.updatehealth()
			if (src.occupier.health >= 0 && src.occupier.stat == DEAD)
				src.occupier.stat = CONSCIOUS
				src.occupier.lying = 0
				dead_mob_list -= src.occupier
				alive_mob_list += src.occupier
				src.cut_overlay(image('icons/obj/computer.dmi', "ai-fixer-404"))
				add_overlay(image('icons/obj/computer.dmi', "ai-fixer-full"))
				src.occupier.add_ai_verbs()
			src.updateUsrDialog()
			sleep(10)
		src.active = 0
		src.cut_overlay(image('icons/obj/computer.dmi', "ai-fixer-on"))

	src.updateUsrDialog()


/obj/machinery/computer/aifixer/update_icon()
	..()
	// Broken / Unpowered
	if((stat & BROKEN) || (stat & NOPOWER))
		cut_overlays()

	// Working / Powered
	else
		if (occupier)
			switch (occupier.stat)
				if (0)
					add_overlay(image('icons/obj/computer.dmi', "ai-fixer-full"))
				if (2)
					add_overlay(image('icons/obj/computer.dmi', "ai-fixer-404"))
		else
			add_overlay(image('icons/obj/computer.dmi', "ai-fixer-empty"))
