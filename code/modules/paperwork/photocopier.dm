/obj/machinery/photocopier
	name = "photocopier"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	anchored = 1
	density = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	active_power_usage = 200
	var/obj/item/weapon/paper/copy = null	//what's in the copier!
	var/obj/item/weapon/photo/photocopy = null
	var/obj/item/weapon/paper_bundle/bundle = null
	var/copies = 1	//how many copies to print!
	var/toner = 30 //how much toner is left! woooooo~
	var/maxcopies = 10	//how many copies can be copied at once- idea shamelessly stolen from bs12's copier!

/obj/machinery/photocopier/ui_interact(mob/user)
	var/dat = "Photocopier<BR><BR>"
	if(copy || photocopy || bundle)
		dat += "<a href='byond://?src=\ref[src];remove=1'>Remove Paper</a><BR>"
		if(toner)
			dat += "<a href='byond://?src=\ref[src];copy=1'>Copy</a><BR>"
			dat += "Printing: [copies] copies."
			dat += "<a href='byond://?src=\ref[src];min=1'>-</a> "
			dat += "<a href='byond://?src=\ref[src];add=1'>+</a><BR><BR>"
	else if(toner)
		dat += "Please insert paper to copy.<BR><BR>"
	if(istype(user,/mob/living/silicon))
		dat += "<a href='byond://?src=\ref[src];aipic=1'>Print photo from database</a><BR><BR>"
	dat += "Current toner level: [toner]"
	if(!toner)
		dat +="<BR>Please insert a new toner cartridge!"
	user << browse(dat, "window=copier")
	onclose(user, "copier")

/obj/machinery/photocopier/is_operational_topic()
	return TRUE

/obj/machinery/photocopier/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["copy"])
		if(copy)
			for(var/i = 1 to copies)
				if(toner > 0 && copy)
					copy(copy)
					sleep(15)
				else
					break
			updateUsrDialog()
		else if(photocopy)
			for(var/i = 1 to copies)
				if(toner > 0 && photocopy)
					photocopy(photocopy)
					sleep(15)
				else
					break
		else if(bundle)
			for(var/i = 1 to copies)
				if(toner <= 0 || !bundle)
					break
				var/obj/item/weapon/paper_bundle/p = new /obj/item/weapon/paper_bundle (src)
				var/j = 0
				for(var/obj/item/weapon/W in bundle)
					if(toner <= 0)
						to_chat(usr, "<span class='notice'>The photocopier couldn't finish the printjob.</span>")
						break
					else if(istype(W, /obj/item/weapon/paper))
						W = copy(W)
					else if(istype(W, /obj/item/weapon/photo))
						W = photocopy(W)
					W.loc = p
					p.amount++
					j++
				p.amount--
				p.loc = src.loc
				p.update_icon()
				p.icon_state = "paper_words"
				p.name = bundle.name
				p.pixel_y = rand(-8, 8)
				p.pixel_x = rand(-9, 9)
				sleep(15 * j)
	else if(href_list["remove"])
		if(copy)
			copy.loc = usr.loc
			usr.put_in_hands(copy)
			to_chat(usr, "<span class='notice'>You take the paper out of \the [src].</span>")
			copy = null
		else if(photocopy)
			photocopy.loc = usr.loc
			usr.put_in_hands(photocopy)
			to_chat(usr, "<span class='notice'>You take the photo out of \the [src].</span>")
			photocopy = null
		else if(bundle)
			bundle.loc = usr.loc
			usr.put_in_hands(bundle)
			to_chat(usr, "<span class='notice'>You take the paper bundle out of \the [src].</span>")
			bundle = null
	else if(href_list["min"])
		if(copies > 1)
			copies--
	else if(href_list["add"])
		if(copies < maxcopies)
			copies++
	else if(href_list["aipic"])
		if(!istype(usr,/mob/living/silicon)) return
		if(toner >= 5)
			var/mob/living/silicon/tempAI = usr
			var/obj/item/device/camera/siliconcam/camera = tempAI.aiCamera

			if(!camera)
				return
			var/datum/picture/selection = camera.selectpicture()
			if (!selection)
				return

			var/obj/item/weapon/photo/p = new /obj/item/weapon/photo (src.loc)
			p.construct(selection)
			if (p.desc == "")
				p.desc += "Copied by [tempAI.name]"
			else
				p.desc += " - Copied by [tempAI.name]"
			toner -= 5

	updateUsrDialog()

/obj/machinery/photocopier/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/paper))
		if(!copy && !photocopy && !bundle)
			user.drop_item()
			copy = O
			O.loc = src
			to_chat(user, "<span class='notice'>You insert the paper into \the [src].</span>")
			flick("bigscanner1", src)
			updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>There is already something in \the [src].</span>")
	else if(istype(O, /obj/item/weapon/photo))
		if(!copy && !photocopy && !bundle)
			user.drop_item()
			photocopy = O
			O.loc = src
			to_chat(user, "<span class='notice'>You insert the photo into \the [src].</span>")
			flick("bigscanner1", src)
			updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>There is already something in \the [src].</span>")
	else if(istype(O, /obj/item/weapon/paper_bundle))
		if(!copy && !photocopy && !bundle)
			user.drop_item()
			bundle = O
			O.loc = src
			to_chat(user, "<span class='notice'>You insert the bundle into \the [src].</span>")
			flick("bigscanner1", src)
			updateUsrDialog()
	else if(istype(O, /obj/item/device/toner))
		if(toner == 0)
			user.drop_item()
			qdel(O)
			toner = 30
			to_chat(user, "<span class='notice'>You insert the toner cartridge into \the [src].</span>")
			updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>This cartridge is not yet ready for replacement! Use up the rest of the toner.</span>")
	else if(iswrench(O))
		default_unfasten_wrench(user, O)


/obj/machinery/photocopier/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(50))
				qdel(src)
			else
				if(toner > 0)
					new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
					toner = 0
		else
			if(prob(50))
				if(toner > 0)
					new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
					toner = 0
	return

/obj/machinery/photocopier/blob_act()
	if(prob(50))
		qdel(src)
	else
		if(toner > 0)
			new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
			toner = 0
	return


/obj/machinery/photocopier/proc/copy(obj/item/weapon/paper/copy)
	var/obj/item/weapon/paper/P = new(loc)
	if(toner > 10)	//lots of toner, make it dark
		P.info = "<font color = #101010>"
	else			//no toner? shitty copies for you!
		P.info = "<font color = #808080>"
	var/copied = html_decode(copy.info)
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
	w_class = ITEM_SIZE_SMALL
	var/charges = 50
	var/max_charges = 50
