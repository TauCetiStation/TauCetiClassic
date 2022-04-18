/obj/machinery/photocopier
	name = "photocopier"
	icon = 'icons/obj/machines/printers.dmi'
	icon_state = "scanner-opened-idle"
	anchored = TRUE
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	active_power_usage = 200
	var/obj/item/weapon/copyitem = null	//what's in the copier!
	var/copies = 1	//how many copies to print!
	var/maxcopies = 10	//how many copies can be copied at once- idea shamelessly stolen from bs12's copier!

	var/department = "Unknown" // our department

/obj/machinery/photocopier/attack_hand(mob/user)
	user.set_machine(src)

	tgui_interact(user)

/obj/machinery/photocopier/tgui_interact(mob/user, datum/tgui/ui, datum/tgui/parent_ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Photocopier", name)
		ui.open()

/obj/machinery/photocopier/tgui_data(mob/user, datum/tgui/ui, datum/tgui_state/state)
	var/list/data = ..()

	data["has_item"] = copyitem
	data["isAI"] = issilicon(user)
	data["num_copies"] = copies
	data["max_copies"] = maxcopies
	data["can_AI_print"] = TRUE

	return data

/obj/machinery/photocopier/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return TRUE

	switch(action)
		if("make_copy")
			addtimer(CALLBACK(src, .proc/send_item, usr), 0)
			. = TRUE
		if("remove")
			if(copyitem)
				icon_state = "scanner-opened-idle"
				copyitem.loc = usr.loc
				usr.put_in_hands(copyitem)
				to_chat(usr, "<span class='notice'>You take \the [copyitem] out of \the [src].</span>")
				copyitem = null
			. = TRUE
		if("set_copies")
			copies = clamp(text2num(params["num_copies"]), 1, maxcopies)
			. = TRUE
		if("ai_photo")
			if(!issilicon(usr))
				return
			if(stat & (BROKEN|NOPOWER))
				return

			var/mob/living/silicon/tempAI = usr
			var/obj/item/device/camera/siliconcam/camera = tempAI.aiCamera
			if(!camera)
				return

			var/datum/picture/selection = camera.selectpicture()
			if (!selection)
				return

			var/obj/item/weapon/photo/p = new /obj/item/weapon/photo(loc)
			p.construct(selection)
			if (p.desc == "")
				p.desc += "Copied by [tempAI.name]"
			else
				p.desc += " - Copied by [tempAI.name]"
			. = TRUE

/obj/machinery/photocopier/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/paper) || istype(O, /obj/item/weapon/photo) || istype(O, /obj/item/weapon/paper_bundle))
		if(!copyitem)
			user.drop_from_inventory(O, src)
			copyitem = O
			to_chat(user, "<span class='notice'>You insert \the [O] into \the [src].</span>")
			if(istype(O, /obj/item/weapon/photo))
				flick("scanner-opened-closing-photo", src)
			else
				flick("scanner-opened-closing-paper", src)
			icon_state = "scanner-closed-idle"
		else
			to_chat(user, "<span class='notice'>There is already something in \the [src].</span>")
	else if(iswrench(O))
		default_unfasten_wrench(user, O)

/obj/machinery/photocopier/proc/send_item()
	for(var/obj/machinery/printer/Printer in allprinters)
		if((department == "All" || Printer.department == department) && !( Printer.stat & (BROKEN|NOPOWER) ))
			Printer.queue_print(copyitem)
