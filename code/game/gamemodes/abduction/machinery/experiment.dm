//*************-Experiment-*************//

/obj/machinery/abductor/experiment
	name = "experimentation machine"
	desc = "A large man-sized tube sporting a complex array of surgical apparatus."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "experiment-open"
	density = 0
	anchored = 1
	state_open = 1
	var/points = 0
	var/list/history = new
	var/flash = " - || - "
	var/obj/machinery/abductor/console/console

/obj/machinery/abductor/experiment/MouseDrop_T(mob/target, mob/user)
	if(user.incapacitated() || !Adjacent(user) || !target.Adjacent(user) || !ishuman(target))
		return
	if(IsAbductor(target))
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return
	close_machine(target)

/obj/machinery/abductor/experiment/allow_drop()
	return 0

/obj/machinery/abductor/experiment/open_machine()
	if(!state_open && !panel_open)
		..()

/obj/machinery/abductor/experiment/close_machine(mob/target)
	for(var/mob/living/carbon/C in loc)
		if(IsAbductor(C))
			return
	if(state_open && !panel_open)
		..(target)

/obj/machinery/abductor/experiment/proc/dissection_icon(mob/living/carbon/human/H)
	var/icon/preview_icon = null

	var/g = "m"
	if (H.gender == FEMALE)
		g = "f"

	var/icon/icobase = H.species.icobase

	preview_icon = new /icon(icobase, "[BP_CHEST]_[g]")
	var/icon/temp
	temp = new /icon(icobase, "[BP_GROIN]_[g]")
	preview_icon.Blend(temp, ICON_OVERLAY)
	temp = new /icon(icobase, "[BP_HEAD]_[g]")
	preview_icon.Blend(temp, ICON_OVERLAY)

	for(var/obj/item/organ/external/BP in H.bodyparts)
		if((BP.status & ORGAN_CUT_AWAY) || (BP.is_stump))
			continue
		temp = new /icon(icobase, "[BP.body_zone]")
		if(BP.is_robotic())
			temp.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
		preview_icon.Blend(temp, ICON_OVERLAY)

	//Tail
	if(H.species.tail && H.species.flags[HAS_TAIL])
		temp = new/icon("icon" = 'icons/mob/species/tail.dmi', "icon_state" = H.species.tail)
		preview_icon.Blend(temp, ICON_OVERLAY)

	// Skin tone
	if(H.species.flags[HAS_SKIN_TONE])
		if (H.s_tone >= 0)
			preview_icon.Blend(rgb(H.s_tone, H.s_tone, H.s_tone), ICON_ADD)
		else
			preview_icon.Blend(rgb(-H.s_tone,  -H.s_tone,  -H.s_tone), ICON_SUBTRACT)

	// Skin color
	if(H.species.flags[HAS_SKIN_TONE])
		if(!H.species || H.species.flags[HAS_SKIN_COLOR])
			preview_icon.Blend(rgb(H.r_skin, H.g_skin, H.b_skin), ICON_ADD)

	var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = H.species ? H.species.eyes : "eyes_s")

	eyes_s.Blend(rgb(H.r_eyes, H.g_eyes, H.b_eyes), ICON_ADD)

	var/datum/sprite_accessory/hair_style = hair_styles_list[H.h_style]
	if(hair_style)
		var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
		hair_s.Blend(rgb(H.r_hair, H.g_hair, H.b_hair), ICON_ADD)
		eyes_s.Blend(hair_s, ICON_OVERLAY)

	var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[H.f_style]
	if(facial_hair_style)
		var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
		facial_s.Blend(rgb(H.r_facial, H.g_facial, H.b_facial), ICON_ADD)
		eyes_s.Blend(facial_s, ICON_OVERLAY)

	preview_icon.Blend(eyes_s, ICON_OVERLAY)
	qdel(eyes_s)

	return preview_icon

/obj/machinery/abductor/experiment/ui_interact(mob/user)
	var/dat
	dat += "<h3> Experiment </h3>"
	if(occupant)
		var/obj/item/weapon/photo/P = new
		P.photocreate(null, icon(dissection_icon(occupant), dir = SOUTH))
		user << browse_rsc(P.img, "dissection_img")
		dat += "<table><tr><td>"
		dat += "<img src=dissection_img height=80 width=80>" //Avert your eyes
		dat += "</td><td>"
		dat += "<a href='?src=\ref[src];experiment=1'>Probe</a><br>"
		dat += "<a href='?src=\ref[src];experiment=2'>Dissect</a><br>"
		dat += "<a href='?src=\ref[src];experiment=3'>Analyze</a><br>"
		dat += "</td></tr></table>"
	else
		dat += "<span class='linkOff'> Experiment </span>"
	if(!occupant)
		dat += "<h3>Machine Unoccupied</h3>"
	else
		dat += "<h3>Subject Status : </h3>"
		dat += "[occupant.name] => "
		switch(occupant.stat)
			if(0)
				dat += "<span class='good'>Conscious</span>"
			if(1)
				dat += "<span class='average'>Unconscious</span>"
			else
				dat += "<span class='bad'>Deceased</span>"
	dat += "<br>"
	dat += "[flash]"
	dat += "<br>"
	dat += "<a href='?src=\ref[src];refresh=1'>Scan</a>"
	dat += "<a href='?src=\ref[src];[state_open ? "close=1'>Close</a>" : "open=1'>Open</a>"]"

	var/datum/browser/popup = new(user, "experiment", "Probing Console", 300, 300)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.set_content(dat)
	popup.open()

/obj/machinery/abductor/experiment/Topic(href, href_list)
	. = ..()
	if(!. || usr == occupant)
		return FALSE
	if(href_list["open"])
		open_machine()
	else if(href_list["close"])
		close_machine()
	else if(occupant && occupant.stat != DEAD)
		if(href_list["experiment"])
			flash = Experiment(occupant,href_list["experiment"])
	updateUsrDialog()

/obj/machinery/abductor/experiment/proc/Experiment(mob/occupant,type)
	var/mob/living/carbon/human/H = occupant
	var/point_reward = 0
	if(H in history)
		return "<span class='bad'>Specimen already in database.</span>"
	if(H.stat == DEAD)
		src.visible_message("Specimen deceased - please provide fresh sample.")
		return "<span class='bad'>Specimen deceased.</span>"
	var/obj/item/gland/GlandTest = locate() in H
	if(!GlandTest)
		src.visible_message("Experimental dissection not detected!")
		return "<span class='bad'>No glands detected!</span>"
	if(H.mind != null && H.ckey != null)
		history += H
		src.visible_message("Processing specimen...")
		sleep(5)
		switch(text2num(type))
			if(1)
				to_chat(H, "<span class='warning'>You feel violated.</span>")
			if(2)
				to_chat(H, "<span class='warning'>You feel yourself being sliced apart and put back together.</span>")
			if(3)
				to_chat(H, "<span class='warning'>You feel intensely watched.</span>")
		sleep(5)
		to_chat(H, "<span class='warning'><b>Your mind snaps!</b></span>")
		var/objtype = pick(typesof(/datum/objective/abductee) - /datum/objective/abductee)
		var/datum/objective/abductee/O = new objtype()
		SSticker.mode.abductees += H.mind
		H.mind.objectives += O
		var/obj_count = 1
		to_chat(H, "<span class='notice'>Your current objectives:</span>")
		for(var/datum/objective/objective in H.mind.objectives)
			to_chat(H, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++
		for(var/obj/item/gland/G in H)
			G.Start()
			point_reward++
		if(point_reward > 0)
			open_machine()
			SendBack(H)
			playsound(src, 'sound/machines/ding.ogg', VOL_EFFECTS_MASTER)
			points += point_reward
			return "<span class='good'>Experiment successfull! [point_reward] new data-points collected.</span>"
		else
			playsound(src, 'sound/machines/buzz-sigh.ogg', VOL_EFFECTS_MASTER)
			return "<span class='bad'>Experiment failed! No replacement organ detected.</span>"
	else
		src.visible_message("Brain activity nonexistant - disposing Sample...")
		open_machine()
		SendBack(H)
		return "<span class='bad'>Specimen braindead - disposed</span>"

/obj/machinery/abductor/experiment/proc/SendBack(mob/living/carbon/human/H)
	H.Sleeping(16 SECONDS)
	var/area/A
	if(console && console.pad && console.pad.teleport_target)
		A = console.pad.teleport_target
	else
		A = teleportlocs[pick(teleportlocs)]
	TeleportToArea(H,A)
	var/obj/item/weapon/handcuffs/alien/handcuffs = H.handcuffed
	H.drop_from_inventory(handcuffs)
	qdel(handcuffs)
	return

/obj/machinery/abductor/experiment/update_icon()
	if(state_open)
		icon_state = "experiment-open"
	else
		icon_state = "experiment"

/obj/machinery/abductor/experiment/visible_message(text, blind_message, viewing_distance, list/ignored_mobs)
	return "beeps, \"[text]\""
