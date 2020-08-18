var/list/obj/machinery/faxmachine/allfaxes = list()
var/list/alldepartments = list("Central Command")

/obj/machinery/faxmachine
	name = "fax machine"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "fax"
	req_one_access = list(access_lawyer, access_heads)
	anchored = 1
	density = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	active_power_usage = 200
	interact_offline = TRUE
	allowed_checks = ALLOWED_CHECK_NONE
	var/obj/item/weapon/card/id/scan = null // identification
	var/authenticated = 0

	var/obj/item/weapon/paper/tofax = null // what we're sending
	var/sendcooldown = 0 // to avoid spamming fax messages

	var/department = "Unknown" // our department
	var/dptdest = "Central Command" // the department we're sending to

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

/obj/machinery/faxmachine/is_operational_topic()
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
				usr.drop_item()
				I.loc = src
				scan = I
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
			user.drop_item()
			tofax = O
			O.loc = src
			to_chat(user, "<span class='notice'>You insert the paper into \the [src].</span>")
			flick("faxsend", src)
			updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>There is already something in \the [src].</span>")

	else if(istype(O, /obj/item/weapon/card/id))

		var/obj/item/weapon/card/id/idcard = O
		if(!scan)
			usr.drop_item()
			idcard.loc = src
			scan = idcard

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

	for(var/client/C in admins)
		to_chat(C, msg)

	send_fax(sender, P, "Central Command")

	add_communication_log(type = "fax-station", author = sender.name, content = P.info + "\n" + P.stamp_text)

	for(var/client/X in global.admins)
		X.mob.playsound_local(null, 'sound/machines/fax_centcomm.ogg', VOL_NOTIFICATIONS, vary = FALSE, ignore_environment = TRUE)

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = ":fax: **[key_name(sender)]** sent fax to ***Centcomm***",
		attachment_msg = strip_html_properly(replacetext((P.info + "\n" + P.stamp_text),"<br>", "\n")),
		attachment_color = BRIDGE_COLOR_ADMINCOM,
	)

/proc/send_fax(mob/sender, obj/item/weapon/paper/P, department)
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
