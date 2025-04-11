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
	var/dptdest = "Central Command"  // the department we're sending to
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
			if(sendcooldown)
				dat += "Please insert paper, photo or bundle to send via secure connection.<br><br>"
				dat += "<b>Transmitter arrays realigning. Please stand by.</b><br>"
			else
				dat += "Please insert paper, photo or bundle to send via secure connection.<br><br>"

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

			spawn(sendcooldown)  // cooldown time
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
			to_chat(user, "<span class='notice'>You insert the item into \the [src].</span>")
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

/proc/centcomm_fax(mob/sender, obj/item/weapon/P, obj/machinery/faxmachine/fax)
	var/item_info = ""
	if(istype(P, /obj/item/weapon/paper))
		var/obj/item/weapon/paper/paper = P
		item_info = paper.info
		if(paper.stamped && islist(paper.stamped))
			item_info += "\nStamps: [jointext(paper.stamped, ", ")]"
	else if(istype(P, /obj/item/weapon/photo))
		var/obj/item/weapon/photo/photo = P
		item_info = photo.desc
	else if(istype(P, /obj/item/weapon/paper_bundle))
		var/obj/item/weapon/paper_bundle/bundle = P
		item_info = "This is a bundle containing [bundle.pages.len] items."
		for(var/page in bundle.pages)
			if(istype(page, /obj/item/weapon/paper))
				var/obj/item/weapon/paper/paper_page = page
				item_info += "\nPaper: [paper_page.info]"
				if(paper_page.stamped && islist(paper_page.stamped))
					item_info += "\nStamps: [jointext(paper_page.stamped, ", ")]"
			else if(istype(page, /obj/item/weapon/photo))
				var/obj/item/weapon/photo/photo_page = page
				item_info += "\nPhoto: [photo_page.desc]"

	var/msg = text("<span class='notice'><b>[] [] [] [] [] [] []</b>: Receiving '[P.name]' via secure connection ... []</span>",
	"<font color='orange'>CENTCOMM FAX: </font>[key_name(sender, 1)]",
	"(<a href='byond://?_src_=holder;adminplayeropts=\ref[sender]'>PP</a>)",
	"(<a href='byond://?_src_=vars;Vars=\ref[sender]'>VV</a>)",
	"(<a href='byond://?_src_=holder;subtlemessage=\ref[sender]'>SM</a>)",
	ADMIN_JMP(sender),
	"(<a href='byond://?_src_=holder;secretsadmin=check_antagonist'>CA</a>)",
	"(<a href='byond://?_src_=holder;CentcommFaxReply=\ref[sender];CentcommFaxReplyDestination=\ref[fax.department]'>RPLY</a>)",
	"<a href='byond://?_src_=holder;CentcommFaxViewInfo=\ref[item_info]'>view message</a>")

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
			if(istype(P, /obj/item/weapon/paper))
				var/obj/item/weapon/paper/original = P
				var/obj/item/weapon/paper/copy = new /obj/item/weapon/paper(F.loc)
				copy.info = original.info
				copy.name = original.name
				if(original.stamped && islist(original.stamped))
					copy.stamped = original.stamped.Copy()
				F.print_fax(copy)
			else if(istype(P, /obj/item/weapon/photo))
				var/obj/item/weapon/photo/original = P
				var/obj/item/weapon/photo/copy = new /obj/item/weapon/photo(F.loc)
				copy.img = original.img
				copy.desc = original.desc
				if(original.scribble)
					copy.scribble = original.scribble
				copy.name = original.name
				F.print_fax(copy)
			else if(istype(P, /obj/item/weapon/paper_bundle))
				var/obj/item/weapon/paper_bundle/original = P
				var/obj/item/weapon/paper_bundle/copy = new /obj/item/weapon/paper_bundle(F.loc)
				for(var/page in original.pages)
					if(istype(page, /obj/item/weapon/paper))
						var/obj/item/weapon/paper/paper_page = page
						var/obj/item/weapon/paper/copied_paper = new /obj/item/weapon/paper()
						copied_paper.info = paper_page.info
						copied_paper.name = paper_page.name
						if(paper_page.stamped && islist(paper_page.stamped))
							copied_paper.stamped = paper_page.stamped.Copy()
						copied_paper.forceMove(copy)
						copy.pages.Add(copied_paper)
					else if(istype(page, /obj/item/weapon/photo))
						var/obj/item/weapon/photo/photo_page = page
						var/obj/item/weapon/photo/copied_photo = new /obj/item/weapon/photo()
						copied_photo.img = photo_page.img
						copied_photo.desc = photo_page.desc
						if(photo_page.scribble)
							copied_photo.scribble = photo_page.scribble
						copied_photo.name = photo_page.name
						copied_photo.forceMove(copy)
						copy.pages.Add(copied_photo)
				copy.update_icon()
				F.print_fax(copy)

	if(istype(P, /obj/item/weapon/paper))
		var/obj/item/weapon/paper/paper = P
		log_fax("[sender] sending [paper.name] to [department]: [paper.info]")
	else if(istype(P, /obj/item/weapon/photo))
		var/obj/item/weapon/photo/photo = P
		log_fax("[sender] sending photo [photo.name] to [department]: [photo.desc]")
	else if(istype(P, /obj/item/weapon/paper_bundle))
		log_fax("[sender] sending paper bundle [P.name] to [department]")

/obj/machinery/faxmachine/proc/print_fax(obj/item/weapon/P)
	set waitfor = FALSE

	playsound(src, "sound/items/polaroid1.ogg", VOL_EFFECTS_MASTER)
	flick("faxreceive", src)

	sleep(20)

	P.loc = loc
	audible_message("Received message.")
