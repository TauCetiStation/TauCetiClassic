/obj/machinery/photocopier
	name = "photocopier"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	anchored = TRUE
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	active_power_usage = 200
	var/obj/item/weapon/paper/copyitem = null	//what's in the copier!
	var/obj/item/weapon/photo/photocopy = null
	var/obj/item/weapon/paper_bundle/bundle = null
	var/copies = 1	//how many copies to print!
	var/toner = 30 //how much toner is left! woooooo~
	var/maxcopies = 10	//how many copies can be copied at once- idea shamelessly stolen from bs12's copier!
	var/copying = FALSE

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
	data["can_AI_print"] = (toner >= 5)
	data["has_toner"] = !!toner
	data["current_toner"] = toner
	data["max_toner"] = 40
	data["num_copies"] = copies
	data["max_copies"] = maxcopies

	return data

/obj/machinery/photocopier/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return TRUE

	switch(action)
		if("make_copy")
			addtimer(CALLBACK(src, PROC_REF(copy_operation), usr), 0)
			. = TRUE
		if("remove")
			if(copyitem)
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

			if(toner >= 5)
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
				toner -= 5
			. = TRUE

/obj/machinery/photocopier/proc/get_copy_delay(obj/item/I)
	if(istype(I, /obj/item/weapon/paper))
		return 11

	if(istype(I, /obj/item/weapon/photo))
		return 11

	if(istype(I, /obj/item/weapon/paper_bundle))
		return 11

	return 0

// Return additional delay after copying
/obj/machinery/photocopier/proc/copy_item(obj/item/I)
	if(istype(I, /obj/item/weapon/paper))
		copy(I)
		return 0

	if(istype(I, /obj/item/weapon/photo))
		photocopy(I)
		return 0

	if(istype(I, /obj/item/weapon/paper_bundle))
		var/obj/item/weapon/paper_bundle/B = bundlecopy(copyitem)
		return 11 * B.pages.len

	return 0

/obj/machinery/photocopier/proc/copy_operation(mob/user)
	if(copying)
		return FALSE
	copying = TRUE
	for(var/i = 0, i < copies, i++)
		if(toner <= 0)
			break
		if(!copyitem)
			break
		var/delay = get_copy_delay(copyitem)
		if(delay == 0)
			to_chat(user, "<span class='warning'>\The [copyitem] can't be copied by [src].</span>")
			break

		if(user.is_busy() || !do_after(user, delay, target = src))
			break

		if(!copyitem)
			break

		delay = copy_item(copyitem)
		use_power(active_power_usage)
		if(user.is_busy() || !do_after(user, delay, target = src, progress = FALSE))
			break

	copying = FALSE

/obj/machinery/photocopier/proc/bundlecopy(obj/item/weapon/paper_bundle/bundle, need_toner = TRUE)
	var/obj/item/weapon/paper_bundle/p = new /obj/item/weapon/paper_bundle (src)
	for(var/obj/item/weapon/W in bundle.pages)
		if(toner <= 0 && need_toner)
			toner = 0
			break
		if(istype(W, /obj/item/weapon/paper))
			W = copy(W)
		else if(istype(W, /obj/item/weapon/photo))
			W = photocopy(W)
		W.loc = p
		p.pages += W

	p.loc = src.loc
	p.update_icon()
	p.icon_state = "paper_words"
	p.name = bundle.name
	p.pixel_y = rand(-8, 8)
	p.pixel_x = rand(-9, 9)
	return p

/obj/machinery/photocopier/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/paper) || istype(O, /obj/item/weapon/photo) || istype(O, /obj/item/weapon/paper_bundle))
		if(!copyitem)
			user.drop_from_inventory(O, src)
			copyitem = O
			to_chat(user, "<span class='notice'>You insert \the [O] into \the [src].</span>")
		else
			to_chat(user, "<span class='notice'>There is already something in \the [src].</span>")
	else if(istype(O, /obj/item/device/toner))
		if(toner == 0)
			user.drop_item()
			qdel(O)
			toner = 30
			to_chat(user, "<span class='notice'>You insert the toner cartridge into \the [src].</span>")
			updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>This cartridge is not yet ready for replacement! Use up the rest of the toner.</span>")
	else if(iswrenching(O))
		default_unfasten_wrench(user, O)

/obj/machinery/photocopier/atom_break(damage_flag)
	. = ..()
	if(. && toner > 0)
		new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
		toner = 0

/obj/machinery/photocopier/proc/copy(obj/item/weapon/paper/copy)
	var/obj/item/weapon/paper/P = new(loc)
	if(toner > 10)	//lots of toner, make it dark
		P.info = "<font color = #101010>"
	else			//no toner? shitty copies for you!
		P.info = "<font color = #808080>"
	var/copied = copy.info
	copied = replacetext(copied, "<font face=\"[P.deffont]\" color=", "<font face=\"[P.deffont]\" nocolor=")	//state of the art techniques in action
	copied = replacetext(copied, "<font face=\"[P.crayonfont]\" color=", "<font face=\"[P.crayonfont]\" nocolor=")	//This basically just breaks the existing color tag, which we need to do because the innermost tag takes priority.
	copied = replacetext(copied, "<img ", "<img style=\"filter: gray;\"")	//IE is still IE
	copied = replacetext(copied, "<font color=", "<font nocolor=")
	copied = replacetext(copied, "<table border=3px cellpadding=5px bordercolor=", "<table border=3px cellpadding=5px bordernocolor=")
	P.info += copied
	P.info += "</font>"//</font>
	P.name = copy.name // -- Doohl
	P.fields = copy.fields
	P.sfields = copy.sfields
	P.stamp_text = replacetext(copy.stamp_text, "color:", "nocolor:") // Russian server? I hope nobody will write this on paper
	P.stamped = LAZYCOPY(copy.stamped)
	P.ico = LAZYCOPY(copy.ico)
	P.offset_x = LAZYCOPY(copy.offset_x)
	P.offset_y = LAZYCOPY(copy.offset_y)
	var/image/img
	for (var/i in 1 to copy.overlays.len)        //Iterates through stamps gray and puts a matching overlay onto the copy
		img = copy.ico[i]
		img.color = "#7f7f7f" // 50% grey
		img.pixel_x = copy.offset_x[i]
		img.pixel_y = copy.offset_y[i]
		P.add_overlay(img)
	P.updateinfolinks()
	P.update_icon()
	toner--
	return P


/obj/machinery/photocopier/proc/photocopy(obj/item/weapon/photo/photocopy)
	var/obj/item/weapon/photo/p = new /obj/item/weapon/photo (src.loc)
	var/icon/I = icon(photocopy.icon, photocopy.icon_state)
	var/icon/img = icon(photocopy.img)
	var/icon/tiny = icon(photocopy.tiny)
	if(toner > 10)	//plenty of toner, go straight greyscale
		I.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))		//I'm not sure how expensive this is, but given the many limitations of photocopying, it shouldn't be an issue.
		img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
		tiny.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
	else			//not much toner left, lighten the photo
		I.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(100,100,100))
		img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(100,100,100))
		tiny.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(100,100,100))
	p.icon = I
	p.img = img
	p.tiny = tiny
	p.name = photocopy.name
	p.desc = photocopy.desc
	p.scribble = photocopy.scribble
	toner -= 5	//photos use a lot of ink!
	if(toner < 0)
		toner = 0
	return p


/obj/item/device/toner
	name = "toner cartridge"
	icon_state = "tonercartridge"
	w_class = SIZE_TINY
	var/charges = 50
	var/max_charges = 50
