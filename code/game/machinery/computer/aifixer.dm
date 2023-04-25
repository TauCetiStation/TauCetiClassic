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
	required_skills = list(/datum/skill/research = SKILL_LEVEL_MASTER)
	fumbling_time = 7 SECONDS

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
	var/dat = ""

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

	var/datum/browser/popup = new(user, "computer", "AI System Integrity Restorer", 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/aifixer/process()
	if(..())
		updateDialog()
		return

/obj/machinery/computer/aifixer/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if (href_list["fix"])
		src.active = 1
		add_overlay(image('icons/obj/computer.dmi', "ai-fixer-on"))
		while (src.occupier.health < 100)
			occupier.adjustOxyLoss(-1)
			occupier.adjustFireLoss(-1)
			occupier.adjustToxLoss(-1)
			occupier.adjustBruteLoss(-1)
			occupier.updatehealth()
			if (src.occupier.health >= 0 && src.occupier.stat == DEAD)
				src.occupier.stat = CONSCIOUS
				src.occupier.lying = 0
				dead_mob_list -= src.occupier
				alive_mob_list += src.occupier
				cut_overlay(image('icons/obj/computer.dmi', "ai-fixer-404"))
				add_overlay(image('icons/obj/computer.dmi', "ai-fixer-full"))
				occupier.add_ai_verbs()
				var/mob/dead/observer/ghost = occupier.get_ghost()
				if(ghost)
					to_chat(ghost, "<span class='ghostalert'>Your AI systems are being restored! Return to your system if you wish to be brought back to artificial life.</span> (Verbs -> Ghost -> Re-enter corpse)")
					ghost.playsound_local(null, 'sound/effects/genetics.ogg', VOL_NOTIFICATIONS, vary = FALSE, frequency = null, ignore_environment = TRUE)
			updateUsrDialog()
			sleep(10)
		src.active = 0
		cut_overlay(image('icons/obj/computer.dmi', "ai-fixer-on"))

	updateUsrDialog()


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
