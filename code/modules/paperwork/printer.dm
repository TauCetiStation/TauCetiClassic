/obj/machinery/printer
	name = "printer"
	icon = 'icons/obj/machines/printers.dmi'
	icon_state = "printer-idle"
	anchored = TRUE
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	active_power_usage = 200
	interact_offline = TRUE
	allowed_checks = ALLOWED_CHECK_NONE
	var/toner = 30 //how much toner is left! woooooo~

	var/obj/item/weapon/paper/print = null // what we're sending
	var/paper = 15

	var/department = "Unknown" // our department

	var/obj/item/weapon/paper/copypaper = null	//what's in the copier!
	var/obj/item/weapon/photo/copyphoto = null
	var/obj/item/weapon/paper_bundle/copybundle = null

/obj/machinery/printer/atom_init()
	. = ..()
	allprinters += src

	if( !("[department]" in alldepartments) )
		alldepartments += department

	update_icon()

/obj/machinery/printer/Destroy()
	allprinters -= src
	QDEL_NULL(print)
	return ..()

/obj/machinery/printer/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				if(toner > 0)
					new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
					toner = 0
				return
		if(EXPLODE_LIGHT)
			if(prob(50))
				if(toner > 0)
					new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
					toner = 0
			return
	qdel(src)

/obj/machinery/printer/blob_act()
	if(prob(50))
		qdel(src)
	else
		if(toner > 0)
			new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
			toner = 0
	return

/obj/machinery/printer/update_icon()
	if(paper > 0)
		icon_state = "printer-paper-idle"
		if(paper > 1)
			icon_state = "printer-papers-idle"

/obj/machinery/printer/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/paper))
		if(!print)
			user.drop_from_inventory(O, src)
			paper++
			to_chat(user, "<span class='notice'>You insert the paper into \the [src].</span>")
			update_icon()
			updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>There is already something in \the [src].</span>")
	else if(iswrench(O))
		default_unfasten_wrench(user, O)
	else if(istype(O, /obj/item/device/toner))
		if(toner == 0)
			user.drop_item()
			qdel(O)
			toner = 30
			to_chat(user, "<span class='notice'>You insert the toner cartridge into \the [src].</span>")
			updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>This cartridge is not yet ready for replacement! Use up the rest of the toner.</span>")

/obj/machinery/printer/proc/get_print_delay(obj/item/I)
	if(istype(I, /obj/item/weapon/paper))
		return 11

	if(istype(I, /obj/item/weapon/photo))
		return 11

	if(istype(I, /obj/item/weapon/paper_bundle))
		return 11

	return 0

// Return additional delay after copying
/obj/machinery/printer/proc/print_item(obj/O)
	if(paper > 1)
		flick("printer-papers-process", src)
	else
		flick("printer-paper-process", src)

	sleep(10)

	if(istype(O, /obj/item/weapon/paper))
		copypaper = O
		print(O)
		return 0

	if(istype(O, /obj/item/weapon/photo))
		copyphoto = O
		printphoto(O)
		return 0

	if(istype(O, /obj/item/weapon/paper_bundle))
		copybundle = O
		var/obj/item/weapon/paper_bundle/B = printbundle(copybundle)
		return 11 * B.pages.len

	return 0

/obj/machinery/printer/proc/printbundle(obj/item/weapon/paper_bundle/bundle, need_toner = TRUE)
	var/obj/item/weapon/paper_bundle/p = new /obj/item/weapon/paper_bundle (src)

	for(var/obj/item/weapon/W in bundle.pages)
		if(toner <= 0 && need_toner)
			toner = 0
			break
		if(istype(W, /obj/item/weapon/paper))
			W = print(W)
		else if(istype(W, /obj/item/weapon/photo))
			W = printphoto(W)
		W.loc = p
		p.pages += W

	p.loc = src.loc
	p.update_icon()
	p.icon_state = "paper_words"
	p.name = bundle.name
	p.pixel_y = rand(-8, 8)
	p.pixel_x = rand(-9, 9)
	p.pixel_y += pixel_y
	p.pixel_x += pixel_x
	p.pixel_y -= 8
	update_icon()
	return p

/obj/machinery/printer/proc/print(obj/item/weapon/paper/copy)
	if(!(paper > 0))
		return
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
	P.pixel_y += pixel_y
	P.pixel_x += pixel_x
	P.pixel_y -= 8
	var/image/img
	for (var/i in 1 to copy.overlays.len)        //Iterates through stamps gray and puts a matching overlay onto the copy
		if (findtext(copy.ico[i], "cap") || findtext(copy.ico[i], "cent"))
			img = image('icons/obj/bureaucracy.dmi', "paper_stamp-circle")
		else if (findtext(copy.ico[i], "deny"))
			img = image('icons/obj/bureaucracy.dmi', "paper_stamp-x")
		else if (findtext(copy.ico[i], "approve"))
			img = image('icons/obj/bureaucracy.dmi', "paper_stamp-check")
		else
			img = image('icons/obj/bureaucracy.dmi', "paper_stamp-dots")
		img.pixel_x = copy.offset_x[i]
		img.pixel_y = copy.offset_y[i]
		P.add_overlay(img)
	P.updateinfolinks()
	P.update_icon()
	update_icon()
	toner--
	paper--
	return P


/obj/machinery/printer/proc/printphoto(obj/item/weapon/photo/photocopy)
	if(!(paper > 0))
		return
	var/obj/item/weapon/photo/p = new /obj/item/weapon/photo(src.loc)
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
	p.pixel_y += pixel_y
	p.pixel_x += pixel_x
	p.pixel_y -= 8
	toner -= 5	//photos use a lot of ink!
	paper--
	if(toner < 0)
		toner = 0
	return p

/obj/item/device/toner
	name = "toner cartridge"
	icon_state = "tonercartridge"
	w_class = SIZE_TINY
	var/charges = 50
	var/max_charges = 50
