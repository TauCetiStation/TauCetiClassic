var/global/list/obj/machinery/faxmachine/allfaxes = list()
var/global/list/alldepartments = list("Central Command")

var/global/list/obj/machinery/paperwork/papermachines = list()

/obj/machinery/paperwork
	icon = 'icons/obj/machines/printers.dmi'

	var/id = ""
	var/list/queue = list()

/obj/machinery/paperwork/atom_init()
	. = ..()

	global.papermachines += src

	STOP_PROCESSING(SSmachines, src)

/proc/send_document(type, name, content)//Types are "photo", "document"
	queue += list("type" = type, "name" = name, "content" = content)
	START_PROCESSING(SSmachines, src)

/obj/machinery/paperwork/proc/print_photo(datum/picture/P)
	var/obj/item/weapon/photo/Photo = new/obj/item/weapon/photo(src.loc)
	Photo.construct(P)

/obj/machinery/paperwork/proc/print_document(datum/document/Doc)
	var/obj/item/weapon/paper/Paper = new/obj/item/weapon/paper(src.loc)
	Paper.construct(Doc)

/obj/machinery/paperwork/printer/process()
	if(!papers || !queue.len)
		STOP_PROCESSING(SSmachines, src)
		return
	var/processing_state = "printer-paper-process"
	if(papers > 1)
		processing_state = "printer-papers-process"

	var/list/Item = queue[1]
	switch(Item["type"])
		if("photo")
			print_photo(content)
		if("document")
			print_document(name, content)
	queue -= Item

	flick(processing_state, src)

/obj/machinery/faxmachine
	name = "fax machine"
	icon = 'icons/obj/machines/printers.dmi'
	icon_state = "fax-idle"
	req_one_access = list(access_lawyer, access_heads)
	anchored = TRUE
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	active_power_usage = 200
	interact_offline = TRUE
	allowed_checks = ALLOWED_CHECK_NONE
	resistance_flags = FULL_INDESTRUCTIBLE

	var/obj/item/weapon/card/id/scan = null // identification
	var/authenticated = 0

	var/obj/item/weapon/paper/tofax = null // what we're sending
	var/sendcooldown = 0 // to avoid spamming fax messages

	var/department = "Unknown" // our department
	var/dptdest = "Central Command" // the department we're sending to
	required_skills = list(/datum/skill/command = SKILL_LEVEL_TRAINED)


/obj/machinery/faxmachine/atom_init()
	. = ..()
	allfaxes += src

	if( !("[department]" in alldepartments) )
		alldepartments += department

/obj/machinery/faxmachine/Destroy()
	allfaxes -= src
	QDEL_NULL(scan)
	QDEL_NULL(tofax)
	return ..()

/obj/machinery/faxmachine/ui_interact(mob/user)
	var/dat

	var/scan_name
	if(scan)
		scan_name = scan.name
	else
		scan_name = "--------"

	dat += "Confirm Identity: <a href='byond://?src=\ref[src];scan=1'>[scan_name]</a><br>"

	if(authenticated)
		dat += "<a href='byond://?src=\ref[src];logout=1'>Log Out</a>"
	else
		dat += "<a href='byond://?src=\ref[src];auth=1'>Log In</a>"

	dat += "<hr>"

	if(authenticated)
		dat += "<b>Logged in to:</b> Central Command Quantum Entanglement Network<br><br>"

		if(tofax)
			dat += "<a href='byond://?src=\ref[src];remove=1'>Remove Paper</a><br><br>"

			if(sendcooldown)
				dat += "<b>Transmitter arrays realigning. Please stand by.</b><br>"

			else
				dat += "<a href='byond://?src=\ref[src];send=1'>Send</a><br>"
				dat += "<b>Currently sending:</b> [tofax.name]<br>"
				dat += "<b>Sending to:</b> <a href='byond://?src=\ref[src];dept=1'>[dptdest]</a><br>"

		else
			if(sendcooldown)
				dat += "Please insert paper to send via secure connection.<br><br>"
				dat += "<b>Transmitter arrays realigning. Please stand by.</b><br>"
			else
				dat += "Please insert paper to send via secure connection.<br><br>"

	else
		dat += "Proper authentication is required to use this device.<br><br>"

		if(tofax)
			dat += "<a href ='byond://?src=\ref[src];remove=1'>Remove Paper</a><br>"

	var/datum/browser/popup = new(user, "window=copier", "Fax Machine", 450, 300)
	popup.set_content(dat)
	popup.open()

/obj/machinery/faxmachine/is_operational()
	return TRUE

/obj/machinery/faxmachine/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["send"])
		if(sendcooldown)
			return

		if(tofax)
			if(dptdest == "Central Command")
				sendcooldown = 1800
				centcomm_fax(usr, tofax, src)
			else
				sendcooldown = 600
				send_fax(usr, tofax, dptdest)

			audible_message("Message transmitted successfully.")

			spawn(sendcooldown) // cooldown time
				sendcooldown = 0

	if(href_list["remove"])
		if(tofax)
			if(!ishuman(usr))
				to_chat(usr, "<span class='warning'>You can't do it.</span>")
			else
				tofax.loc = usr.loc
				usr.put_in_hands(tofax)
				to_chat(usr, "<span class='notice'>You take the paper out of \the [src].</span>")
				tofax = null

	if(href_list["scan"])
		if (scan)
			if(ishuman(usr))
				scan.loc = usr.loc
				if(!usr.get_active_hand())
					usr.put_in_hands(scan)
				scan = null
			else
				scan.loc = src.loc
				scan = null
		else if(ishuman (usr))
			var/obj/item/I = usr.get_active_hand()
			if (istype(I, /obj/item/weapon/card/id))
				usr.drop_from_inventory(I, src)
				scan = I
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			H.sec_hud_set_ID()
		authenticated = 0

	if(href_list["dept"])
		var/lastdpt = dptdest
		dptdest = input(usr, "Which department?", "Choose a department", "") as null|anything in alldepartments
		if(!dptdest) dptdest = lastdpt

	if(href_list["auth"])
		if ( (!( authenticated ) && (scan)) )
			if (check_access(scan))
				authenticated = 1

	if(href_list["logout"])
		authenticated = 0

	updateUsrDialog()

/obj/machinery/faxmachine/attackby(obj/item/O, mob/user)

	if(istype(O, /obj/item/weapon/paper))
		if(!tofax)
			user.drop_from_inventory(O, src)
			tofax = O
			to_chat(user, "<span class='notice'>You insert the paper into \the [src].</span>")
			flick("faxsend", src)
			updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>There is already something in \the [src].</span>")

	else if(istype(O, /obj/item/weapon/card/id))

		var/obj/item/weapon/card/id/idcard = O
		if(!scan)
			usr.drop_from_inventory(idcard, src)
			idcard.loc = src
			scan = idcard
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				H.sec_hud_set_ID()

	else if(iswrench(O))
		default_unfasten_wrench(user, O)

/proc/centcomm_fax(mob/sender, obj/item/weapon/paper/P, obj/machinery/faxmachine/fax)
	var/msg = text("<span class='notice'><b>[] [] [] [] [] [] []</b>: Receiving '[P.name]' via secure connection ... []</span>",
	"<font color='orange'>CENTCOMM FAX: </font>[key_name(sender, 1)]",
	"(<a href='?_src_=holder;adminplayeropts=\ref[sender]'>PP</a>)",
	"(<a href='?_src_=vars;Vars=\ref[sender]'>VV</a>)",
	"(<a href='?_src_=holder;subtlemessage=\ref[sender]'>SM</a>)",
	ADMIN_JMP(sender),
	"(<a href='?_src_=holder;secretsadmin=check_antagonist'>CA</a>)",
	"(<a href='?_src_=holder;CentcommFaxReply=\ref[sender];CentcommFaxReplyDestination=\ref[fax.department]'>RPLY</a>)",
	"<a href='?_src_=holder;CentcommFaxViewInfo=\ref[P.info];CentcommFaxViewStamps=\ref[P.stamp_text]'>view message</a>")  // Some weird BYOND bug doesn't allow to send \ref like `[P.info + P.stamp_text]`.

	for(var/client/C as anything in admins)
		to_chat(C, msg)

	send_fax(sender, P, "Central Command")

	SSStatistics.add_communication_log(type = "fax-station", author = sender.name, content = P.info + "\n" + P.stamp_text)

	for(var/client/X in global.admins)
		X.mob.playsound_local(null, 'sound/machines/fax_centcomm.ogg', VOL_NOTIFICATIONS, vary = FALSE, frequency = null, ignore_environment = TRUE)

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = ":fax: **[key_name(sender)]** sent fax to ***Centcomm***",
		attachment_msg = strip_html_properly(replacetext((P.info + "\n" + P.stamp_text),"<br>", "\n")),
		attachment_footer = get_admin_counts_formatted(),
		attachment_color = BRIDGE_COLOR_ADMINCOM,
	)

/proc/send_fax(sender, obj/item/weapon/paper/P, department)
	for(var/obj/machinery/faxmachine/F in allfaxes)
		if((department == "All" || F.department == department) && !( F.stat & (BROKEN|NOPOWER) ))
			F.print_fax(P.create_self_copy())

	log_fax("[sender] sending [P.name] to [department]: [P.info]")

/obj/machinery/faxmachine/proc/print_fax(obj/item/weapon/paper/P)
	set waitfor = FALSE

	playsound(src, "sound/items/polaroid1.ogg", VOL_EFFECTS_MASTER)
	flick("faxreceive", src)

	sleep(20)

	P.loc = loc
	audible_message("Received message.")


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
			addtimer(CALLBACK(src, .proc/copy_operation, usr), 0)
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
	else if(iswrench(O))
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
	w_class = SIZE_TINY
	var/charges = 50
	var/max_charges = 50
