var/list/obj/machinery/faxmachine/allfaxes = list()
var/list/alldepartments = list("Central Command")

/obj/machinery/faxmachine
	name = "fax machine"
	icon = 'icons/obj/library.dmi'
	icon_state = "fax"
	req_one_access = list(access_lawyer, access_heads)
	anchored = 1
	density = 1
	use_power = 1
	idle_power_usage = 30
	active_power_usage = 200
	power_channel = EQUIP

	var/obj/item/weapon/card/id/scan = null // identification
	var/authenticated = 0

	var/obj/item/weapon/paper/tofax = null // what we're sending
	var/sendcooldown = 0 // to avoid spamming fax messages

	var/department = "All" // our department
	// NOTE: Default content of the var is used only in fax inside the CENTCOMM and is also used as identifier for sending to all faxes on the station, so you will have to change this identifier in SentFax proc

	var/dptdest = "Central Command" // the department we're sending to

/obj/machinery/faxmachine/New()
	..()
	allfaxes += src

	if( !("[department]" in alldepartments) )
		alldepartments += department

/obj/machinery/faxmachine/Destroy()
	allfaxes -= src
	return ..()

/obj/machinery/faxmachine/process()
	return 0

/obj/machinery/faxmachine/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/faxmachine/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/faxmachine/attack_hand(mob/user)
	user.set_machine(src)

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
	return

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
				Centcomm_fax(tofax.info, tofax.name, usr)

			else
				sendcooldown = 600
				SendFax(tofax.info, tofax.name, usr, dptdest)

			to_chat(usr, "Message transmitted successfully.")

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
		else
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

	else if(istype(O, /obj/item/weapon/wrench))
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
	return

/proc/Centcomm_fax(sent, sentname, mob/Sender)
	var/msg = "\blue <b><font color='orange'>CENTCOMM FAX: </font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[Sender]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<a href='?_src_=holder;CentcommFaxReply=\ref[Sender]'>RPLY</a>)</b>: Receiving '[sentname]' via secure connection ... <a href='?_src_=holder;CentcommFaxView=\ref[sent]'>view message</a>"
	log_fax("[Sender] sending [sentname] : [sent]")
	for(var/client/C in admins)
		to_chat(C, msg)
	send2slack_custommsg("[key_name(Sender)] sent fax to Centcomm", sent, ":fax:")

/proc/MakeFaxPaper(locator, sent_text, sent_name, mob/Sender, stamp, stamp_text, stamp_imgbuf)
	spawn(20)	// give the sprite some time to flick
		var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( locator )
		P.name = "[sent_name]"
		P.info = "[sent_text]"
		P.update_icon()
		if(stamp == "CentCom")
			var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
			stampoverlay.icon_state = "paper_stamp-cent"
			if(!stamp_text)
				P.stamp_text += "<HR><i>This paper has been stamped by the Central Command Quantum Relay.</i>"
			else
				P.stamp_text = "<HR><i>[stamp_text]</i>"
			P.overlays += stampoverlay
		if (stamp == "Clown")
			var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
			stampoverlay.icon_state = "paper_stamp-clown"
			if(!stamp_text)
				P.stamp_text += "<HR><i>This paper has been stamped by strange pink stamp.</i>"
			else
				P.stamp_text = "<HR><i>[stamp_text]</i>"
			P.overlays += stampoverlay
		if (stamp == "Syndicate")
			var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
			stampoverlay.icon_state = "paper_stamp-syndicate"
			if(!stamp_text)
				P.stamp_text += "<HR><i>This paper has been stamped by the Syndicate Command Interception Relay.</i>"
			else
				P.stamp_text = "<HR><i>[stamp_text]</i>"
			P.overlays += stampoverlay
		if (stamp == "FakeCentCom")
			var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
			stampoverlay.icon_state = "paper_stamp-fakecentcom"
			if(!stamp_text)
				P.stamp_text += "<HR><i>This paper has been stamped by the Central Compound Quantum Relay.</i>"
			else
				P.stamp_text = "<HR><i>[stamp_text]</i>"
			P.overlays += stampoverlay
		if (stamp == "Custom")
			if(!stamp_text)
				P.stamp_text += "<HR><i>This paper has been stamped by the Central Compound Quantum Relay.</i>"
			else
				P.stamp_text = "<HR><i>[stamp_text]</i>"
			P.overlays += stamp_imgbuf

/proc/SendFax(sent_text, sent_name, mob/Sender, dpt, stamp, stamp_text)

	log_fax("[Sender] sending [sent_name] to [dpt] : [sent_text]")
	var/stamp_imgbuf
	if(stamp == "Custom")
		stamp_imgbuf = input("Pick icon:","Icon") as icon
		if (!stamp_imgbuf)
			return
	for(var/obj/machinery/faxmachine/F in allfaxes)
		if(dpt == "All")
			if(! (F.stat & (BROKEN|NOPOWER) ) )

				flick("faxreceive", F)
				MakeFaxPaper (F.loc, sent_text, sent_name, Sender, stamp, stamp_text, stamp_imgbuf)
				playsound(F.loc, "sound/items/polaroid1.ogg", 50, 1)

		if( F.department == dpt )
			if(! (F.stat & (BROKEN|NOPOWER) ) )

				flick("faxreceive", F)
				MakeFaxPaper (F.loc, sent_text, sent_name, Sender, stamp, stamp_text, stamp_imgbuf)
				playsound(F.loc, "sound/items/polaroid1.ogg", 50, 1)