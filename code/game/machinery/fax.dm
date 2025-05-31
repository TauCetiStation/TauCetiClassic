var/global/list/obj/machinery/faxmachine/allfaxes = list()
var/global/list/alldepartments = list("Central Command")

/obj/machinery/faxmachine
	name = "fax machine"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "fax"
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

	var/obj/item/weapon/tofax = null // what we're sending
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
			dat += "<a href='byond://?src=\ref[src];remove=1'>Remove Item</a><br><br>"

			if(sendcooldown)
				dat += "<b>Transmitter arrays realigning. Please stand by.</b><br>"
			else
				dat += "<a href='byond://?src=\ref[src];send=1'>Send</a><br>"
				dat += "<b>Currently sending:</b> [tofax.name]<br>"
				dat += "<b>Sending to:</b> <a href='byond://?src=\ref[src];dept=1'>[dptdest]</a><br>"
		else
			dat += "Please insert paper, photo or bundle to send via secure connection.<br><br>"
			if(sendcooldown)
				dat += "<b>Transmitter arrays realigning. Please stand by.</b><br>"
	else
		dat += "Proper authentication is required to use this device.<br><br>"
		if(tofax)
			dat += "<a href ='byond://?src=\ref[src];remove=1'>Remove Item</a><br>"

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
			if(usr.Adjacent(loc))
				tofax.loc = usr.loc
				usr.put_in_hands(tofax)
			else
				tofax.forceMove(loc)

			to_chat(usr, "<span class='notice'>You take the item out of \the [src].</span>")
			tofax = null

	if(href_list["scan"])
		if (scan)
			if(ishuman(usr) && usr.Adjacent(loc))
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
		var/new_dep_dest = input(usr, "Which department?", "Choose a department", "") as null|anything in alldepartments
		if(!new_dep_dest || !can_still_interact_with(usr))
			return
		dptdest = new_dep_dest

	if(href_list["auth"])
		if ( (!( authenticated ) && (scan)) )
			if (check_access(scan))
				authenticated = 1

	if(href_list["logout"])
		authenticated = 0

	updateUsrDialog()

/obj/machinery/faxmachine/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/paper) || istype(O, /obj/item/weapon/photo) || istype(O, /obj/item/weapon/paper_bundle))
		if(!tofax)
			user.drop_from_inventory(O, src)
			tofax = O
			to_chat(user, "<span class='notice'>You insert \the [O] into \the [src].</span>")
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
	else if(iswrenching(O))
		default_unfasten_wrench(user, O)

/obj/item/proc/get_fax_info()
	return null

/obj/item/weapon/paper/get_fax_info()
	. = info
	if(stamped && islist(stamped))
		. += "\nStamps: [jointext(stamped, ", ")]"

/obj/item/weapon/photo/get_fax_info()
	return desc

/obj/item/weapon/paper_bundle/get_fax_info()
	. = "This is a bundle containing [pages.len] items."
	for(var/obj/item/page in pages)
		if(istype(page, /obj/item/weapon/photo))
			. += "\nPhoto: [page.get_fax_info()]"
		else if(istype(page, /obj/item/weapon/paper))
			. += "\nPaper: [page.get_fax_info()]"

/obj/item/proc/get_fax_copy()
	return null

/obj/item/weapon/paper/get_fax_copy()
	var/obj/item/weapon/paper/P = new

	P.name       = name
	P.info       = info
	P.info_links = info_links
	P.stamp_text = stamp_text
	P.fields     = fields
	P.sfields    = sfields
	P.stamped    = LAZYCOPY(stamped)
	P.ico        = LAZYCOPY(ico)
	P.offset_x   = LAZYCOPY(offset_x)
	P.offset_y   = LAZYCOPY(offset_y)
	P.copy_overlays(src, TRUE)

	P.updateinfolinks()
	P.update_icon()

	return P

/obj/item/weapon/photo/get_fax_copy()
	var/obj/item/weapon/photo/copy = new()
	copy.img = img
	copy.icon_state = icon_state
	copy.desc = desc
	if(scribble)
		copy.scribble = scribble
	copy.name = name
	return copy

/obj/item/weapon/paper_bundle/get_fax_copy()
	var/obj/item/weapon/paper_bundle/copy = new()
	copy.icon_state = icon_state
	copy.overlays = overlays
	copy.underlays = underlays
	for(var/obj/item/page in pages)
		var/obj/item/copied_page
		if(istype(page, /obj/item/weapon/photo))
			copied_page = page.get_fax_copy()
		else if(istype(page, /obj/item/weapon/paper))
			copied_page = page.get_fax_copy()
		if(copied_page)
			copied_page.forceMove(copy)
			copy.pages.Add(copied_page)
	copy.update_icon()
	return copy

/proc/centcomm_fax(mob/sender, obj/item/weapon/P, obj/machinery/faxmachine/fax)
	var/item_info = P.get_fax_info()

	var/msg = text("<span class='notice'><b>[] [] [] [] [] [] []</b>: Receiving '[P.name]' via secure connection ... []</span>",
	"<font color='orange'>CENTCOMM FAX: </font>[key_name(sender, 1)]",
	"(<a href='byond://?_src_=holder;adminplayeropts=\ref[sender]'>PP</a>)",
	"(<a href='byond://?_src_=vars;Vars=\ref[sender]'>VV</a>)",
	"(<a href='byond://?_src_=holder;subtlemessage=\ref[sender]'>SM</a>)",
	ADMIN_JMP(sender),
	"(<a href='byond://?_src_=holder;secretsadmin=check_antagonist'>CA</a>)",
	"(<a href='byond://?_src_=holder;CentcommFaxReply=\ref[sender];CentcommFaxReplyDestination=\ref[fax.department]'>RPLY</a>)",
	"<a href='byond://?_src_=holder;CentcommFaxViewInfo=\ref[item_info]'>view message</a>") // Some weird BYOND bug doesn't allow to send \ref like `[P.info + P.stamp_text]`.

	for(var/client/C as anything in admins)
		to_chat(C, msg)

	send_fax(sender, P, "Central Command")

	SSStatistics.add_communication_log(type = "fax-station", author = sender.name, content = item_info)

	for(var/client/X in global.admins)
		X.mob.playsound_local(null, 'sound/machines/fax_centcomm.ogg', VOL_NOTIFICATIONS, vary = FALSE, frequency = null, ignore_environment = TRUE)

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = ":fax: **[key_name(sender)]** sent fax to ***Centcomm***",
		attachment_msg = strip_html_properly(replacetext(item_info,"<br>", "\n")),
		attachment_footer = get_admin_counts_formatted(),
		attachment_color = BRIDGE_COLOR_ADMINCOM,
	)

/proc/send_fax(mob/sender, obj/item/weapon/P, department)
	for(var/obj/machinery/faxmachine/F in allfaxes)
		if((department == "All" || F.department == department) && !( F.stat & (BROKEN|NOPOWER) ))
			var/obj/item/copy = P.get_fax_copy()
			if(copy)
				copy.loc = F.loc
				F.print_fax(copy)

	log_fax("[sender] sending [P.name] to [department]: [P.get_fax_info()]")

/obj/machinery/faxmachine/proc/print_fax(obj/item/weapon/P)
	set waitfor = FALSE

	playsound(src, "sound/items/polaroid1.ogg", VOL_EFFECTS_MASTER)
	flick("faxreceive", src)

	sleep(20)

	P.loc = loc
	audible_message("Received message.")
