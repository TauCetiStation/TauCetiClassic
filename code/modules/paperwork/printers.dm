var/global/list/obj/machinery/faxmachine/allfaxes = list()
var/global/list/alldepartments = list("Central Command")

var/global/list/obj/machinery/paperwork/papermachines = list("Central Command")

ADD_TO_GLOBAL_LIST(/obj/machinery/paperwork, papermachines)
/obj/machinery/paperwork
	icon = 'icons/obj/machines/printers.dmi'
	icon_state = "printer-idle"

	var/id_name = ""
	var/list/queue = list()

/obj/machinery/paperwork/atom_init()
	. = ..()

	if( !("[id_name]" in alldepartments) )
		alldepartments += id_name

	STOP_PROCESSING(SSmachines, src)

/obj/machinery/paperwork/Destroy()
	alldepartments -= id_name
	return ..()

/obj/machinery/paperwork/is_operational()
	return TRUE

/proc/send_document(content, id_name)//Types are "photo", "document"
	for(var/obj/machinery/paperwork/Machine in global.papermachines)
		if(Machine.id_name == id_name)
			Machine.queue += content
			START_PROCESSING(SSmachines, Machine)
			return TRUE

/obj/machinery/paperwork/proc/print_photo(datum/picture/P)
	var/obj/item/weapon/photo/Photo = new/obj/item/weapon/photo(src.loc)
	Photo.construct(P)

/obj/machinery/paperwork/proc/print_document(datum/document/Doc)
	var/obj/item/weapon/paper/Paper = new/obj/item/weapon/paper(src.loc)
	Paper.construct(Doc)

	var/obj/item/weapon/pen/Pen = new(src)
	Paper.parsepencode(Paper.info, Pen)

	Paper.updateinfolinks()
	Paper.update_icon()
	qdel(Pen)

/obj/machinery/paperwork/printer
	name = "printer"
	icon = 'icons/obj/machines/printers.dmi'
	icon_state = "printer-papers-idle"
	anchored = TRUE
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	active_power_usage = 100

	var/processing_state = "printer-papers-process"

/obj/machinery/paperwork/printer/process()
	if(!queue.len)
		STOP_PROCESSING(SSmachines, src)
		return

	var/datum/Item = queue[1]
	switch(Item.type)
		if(/datum/picture)
			print_photo(Item)
		if(/datum/document)
			print_document(Item)

	queue -= Item

	flick(processing_state, src)

/obj/machinery/paperwork/printer/attackby(obj/item/O, mob/user)

	if(istype(O, /obj/item/device/pda))
		var/obj/item/device/pda/PDA = O
		PDA.printer_id = id_name
		to_chat(user, "<span class='notice'>You succesfully connected your PDA to a printer.</span>")

	else if(istype(O, /obj/item/device/camera))
		var/obj/item/device/camera/Camera = O
		if(Camera.drive.len && istype(Camera.drive[Camera.drive_current], /datum/picture))
			send_document(Camera.drive[Camera.drive_current], id_name)

	else if(iswrench(O))
		default_unfasten_wrench(user, O)


/obj/machinery/paperwork/printer/faxmachine
	name = "fax machine"
	icon = 'icons/obj/machines/printers.dmi'
	icon_state = "fax-idle"
	req_one_access = list(access_lawyer, access_heads, access_qm)
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

	var/obj/item/weapon/tofax = null // what we're sending
	var/sendcooldown = 0 // to avoid spamming fax messages

	var/destination_name = "Central Command" // the department we're sending to
	var/can_send_to_CC = TRUE
	required_skills = list(/datum/skill/command = SKILL_LEVEL_TRAINED)
	processing_state = "fax-receive"

/obj/machinery/paperwork/printer/faxmachine/Destroy()
	QDEL_NULL(scan)
	QDEL_NULL(tofax)
	return ..()

/obj/machinery/paperwork/printer/faxmachine/ui_interact(mob/user)
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
				dat += "<b>Sending to:</b> <a href='byond://?src=\ref[src];dept=1'>[destination_name]</a><br>"

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

/obj/machinery/paperwork/printer/faxmachine/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["send"])
		if(sendcooldown)
			return

		if(tofax)
			if(destination_name == "Central Command")
				if(istype(tofax, /obj/item/weapon/paper))
					sendcooldown = 180
					centcomm_fax(usr, tofax, src)
				else
					to_chat(usr, "<span class='warning'>You send this to CentComm.</span>")
			else
				if(istype(tofax, /obj/item/weapon/paper_bundle))
					var/obj/item/weapon/paper_bundle/bundle = tofax
					for(var/obj/item/weapon/W in bundle.pages)
						if(istype(W, /obj/item/weapon/paper))
							var/obj/item/weapon/paper/P = W
							send_document(P.scan(), destination_name)
						else if(istype(W, /obj/item/weapon/photo))
							var/obj/item/weapon/photo/P = W
							send_document(P.scan(), destination_name)
				else
					sendcooldown = 60
					//if(send_document(tofax.scan(), destination_name))
						//log_fax("[usr] sending [tofax.name] to [destination_name]: [tofax.info]")

			audible_message("Message transmitted successfully.")

			addtimer(CALLBACK(src, .proc/restore_sendcooldown), sendcooldown SECONDS)

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
		var/last_destination = destination_name
		destination_name = input(usr, "Which department?", "Choose a department", "") as null|anything in can_send_to_CC ? alldepartments : alldepartments - "Central Command"
		if(!destination_name) destination_name = last_destination

	if(href_list["auth"])
		if ( (!( authenticated ) && (scan)) )
			if (check_access(scan))
				authenticated = 1

	if(href_list["logout"])
		authenticated = 0

	updateUsrDialog()

/obj/machinery/paperwork/printer/faxmachine/proc/restore_sendcooldown()
	sendcooldown = 0

/obj/machinery/paperwork/printer/faxmachine/attackby(obj/item/O, mob/user)

	if(istype(O, /obj/item/weapon/paper))
		if(!tofax)
			user.drop_from_inventory(O, src)
			tofax = O
			to_chat(user, "<span class='notice'>You insert the paper into \the [src].</span>")
			flick("fax-transmitt", src)
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

	else if(istype(O, /obj/item/device/pda))
		var/obj/item/device/pda/PDA = O
		PDA.printer_id = id_name
		to_chat(user, "<span class='notice'>You succesfully connected your PDA to a printer.</span>")

	else if(iswrench(O))
		default_unfasten_wrench(user, O)

/proc/centcomm_fax(mob/sender, obj/item/weapon/paper/P, obj/machinery/paperwork/printer/faxmachine/fax)
	var/msg = text("<span class='notice'><b>[] [] [] [] [] [] []</b>: Receiving '[P.name]' via secure connection ... []</span>",
	"<font color='orange'>CENTCOMM FAX: </font>[key_name(sender, 1)]",
	"(<a href='?_src_=holder;adminplayeropts=\ref[sender]'>PP</a>)",
	"(<a href='?_src_=vars;Vars=\ref[sender]'>VV</a>)",
	"(<a href='?_src_=holder;subtlemessage=\ref[sender]'>SM</a>)",
	ADMIN_JMP(sender),
	"(<a href='?_src_=holder;secretsadmin=check_antagonist'>CA</a>)",
	"(<a href='?_src_=holder;CentcommFaxReply=\ref[sender];CentcommFaxReplyDestination=\ref[fax.id_name]'>RPLY</a>)",
	"<a href='?_src_=holder;CentcommFaxViewInfo=\ref[P.info];CentcommFaxViewStamps=\ref[P.stamp_text]'>view message</a>")  // Some weird BYOND bug doesn't allow to send \ref like `[P.info + P.stamp_text]`.

	for(var/client/C as anything in admins)
		to_chat(C, msg)

	if(send_document(P.scan(), "Central Command"))
		log_fax("[sender] sending [P.name] to ["Central Command"]: [P.info]")

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


/obj/machinery/photocopier
	name = "photocopier"
	icon = 'icons/obj/machines/printers.dmi'
	icon_state = "scanner-opened-idle"
	anchored = TRUE
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	active_power_usage = 100
	var/obj/item/weapon/paper/copyitem = null	//what's in the copier!
	var/obj/item/weapon/photo/photocopy = null
	var/obj/item/weapon/paper_bundle/bundle = null
	var/copies = 1	//how many copies to print!
	var/maxcopies = 10	//how many copies can be copied at once
	var/copying = FALSE
	var/closed = FALSE
	var/destination_name = ""

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

			var/mob/living/silicon/tempAI = usr
			var/obj/item/device/camera/siliconcam/camera = tempAI.aiCamera
			if(!camera)
				return

			var/datum/picture/selection = camera.selectpicture()
			if (!selection)
				return
			send_document(selection, destination_name)
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
		var/obj/item/weapon/paper/P = I
		send_document(P.scan(), destination_name)
		change_overlays()
		return 0

	if(istype(I, /obj/item/weapon/photo))
		var/obj/item/weapon/photo/P = I
		send_document(P.scan(), destination_name)
		change_overlays()
		return 0

	if(istype(I, /obj/item/weapon/paper_bundle))
		bundlecopy(I)
		return 0

	return 0

/obj/machinery/photocopier/proc/bundlecopy(obj/item/weapon/paper_bundle/bundle)
	for(var/obj/item/weapon/W in bundle.pages)
		if(istype(W, /obj/item/weapon/paper))
			var/obj/item/weapon/paper/P = W
			send_document(P.scan(), destination_name)
		else if(istype(W, /obj/item/weapon/photo))
			var/obj/item/weapon/photo/P = W
			send_document(P.scan(), destination_name)

		change_overlays()


/obj/machinery/photocopier/proc/copy_operation(mob/user)
	if(copying)
		return FALSE
	copying = TRUE
	for(var/i = 0, i < copies, i++)
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

/obj/machinery/photocopier/proc/change_overlays()
	if(closed)
		flick("scanner-closed-process", src)
	else
		flick("scanner-opened-process", src)

/obj/machinery/photocopier/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/paper) || istype(O, /obj/item/weapon/photo) || istype(O, /obj/item/weapon/paper_bundle))
		if(!copyitem)
			user.drop_from_inventory(O, src)
			copyitem = O
			to_chat(user, "<span class='notice'>You insert \the [O] into \the [src].</span>")
		else
			to_chat(user, "<span class='notice'>There is already something in \the [src].</span>")

	else if(iswrench(O))
		default_unfasten_wrench(user, O)

/obj/item/device/toner
	name = "toner cartridge"
	icon_state = "tonercartridge"
	w_class = SIZE_TINY
	var/charges = 50
	var/max_charges = 50
