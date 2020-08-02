/////////////////////////////////////////////
//Guest pass ////////////////////////////////
/////////////////////////////////////////////
/obj/item/weapon/card/id/guest
	name = "guest pass"
	desc = "Allows temporary access to station areas."
	icon_state = "guest"
	light_color = "#0099ff"
	customizable_view = FORDBIDDEN_VIEW

	var/temp_access = list() // to prevent agent cards stealing access as permanent
	var/reason = "NOT SPECIFIED"
	var/issuedby

	var/expiration_time = 0
	var/is_expired = 0

/obj/item/weapon/card/id/guest/proc/count_until_expired()
	var/time_until_remind = expiration_time - world.time
	addtimer(CALLBACK(src, .proc/expire_warn), time_until_remind - 3 MINUTES)
	addtimer(CALLBACK(src, .proc/expire), time_until_remind)
	return

/obj/item/weapon/card/id/guest/proc/expire_warn()
	playsound(src, 'sound/machines/buzz-sigh.ogg', VOL_EFFECTS_MASTER, 20)
	flick("guest_warn", src)
	return

/obj/item/weapon/card/id/guest/proc/expire()
	playsound(src, 'sound/machines/buzz-sigh.ogg', VOL_EFFECTS_MASTER, 20)
	is_expired = 1
	icon_state = "guest_expired"
	return

/obj/item/weapon/card/id/guest/GetAccess()
	if(is_expired)
		return access
	else
		return temp_access

/obj/item/weapon/card/id/guest/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Issued to [registered_name] by [issuedby].</span>")
	if (world.time < expiration_time)
		var/time_until_expiration = CEIL((expiration_time - world.time) / 600) // Sould be in minutes.
		to_chat(user, "<span class='notice'>This pass expires at [worldtime2text(expiration_time)].<br>There is [time_until_expiration] minutes left.</span>")
	else
		to_chat(user, "<span class='warning'>It expired at [worldtime2text(expiration_time)].</span>")

/obj/item/weapon/card/id/guest/read()
	to_chat(usr, "<span class='notice'>Issued to [registered_name] by [issuedby].</span>")
	if (world.time > expiration_time)
		to_chat(usr, "<span class='notice'>This pass expired at [worldtime2text(expiration_time)].</span>")
	else
		to_chat(usr, "<span class='notice'>This pass expires at [worldtime2text(expiration_time)].</span>")

	to_chat(usr, "<span class='notice'>It grants access to following areas:</span>")
	for (var/A in temp_access)
		to_chat(usr, "<span class='notice'>[get_access_desc(A)].</span>")
	to_chat(usr, "<span class='notice'>Issuing reason: [reason].</span>")
	return

/////////////////////////////////////////////
//Guest pass terminal////////////////////////
/////////////////////////////////////////////

/obj/machinery/computer/guestpass
	name = "guest pass terminal"
	icon_state = "guest"
	desc = "It's a wall-mounted console that allows you to issue temporary access. Be careful when issuing guest passes. Maximum guest pass card time - one hour."
	density = 0


	var/obj/item/weapon/card/id/giver
	var/list/accesses = list()
	var/giv_name = "NOT SPECIFIED"
	var/reason = "NOT SPECIFIED"
	var/duration = 5

	var/list/internal_log = list()
	var/mode = 0  // 0 - making pass, 1 - viewing logs

/obj/machinery/computer/guestpass/atom_init()
	. = ..()
	uid = "[rand(100,999)]-G[rand(10,99)]"

/obj/machinery/computer/guestpass/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/weapon/card/id))
		if(!giver)
			user.drop_item()
			O.loc = src
			giver = O
			updateUsrDialog()
		else
			to_chat(user, "<span class='warning'>There is already ID card inside.</span>")

/obj/machinery/computer/guestpass/ui_interact(mob/user)
	var/dat

	if (mode == 1) //Logs
		dat += "<h3>Activity log</h3><br>"
		for (var/entry in internal_log)
			dat += "[entry]<br><hr>"
		dat += "<a href='?src=\ref[src];action=print'>Print</a><br>"
		dat += "<a href='?src=\ref[src];mode=0'>Back</a><br>"
	else
		dat += "<h3>Guest pass terminal #[uid]</h3><br>"
		dat += "<a href='?src=\ref[src];mode=1'>View activity log</a><br><br>"
		dat += "Issuing ID: <a href='?src=\ref[src];action=id'>[giver]</a><br>"
		dat += "Issued to: <a href='?src=\ref[src];choice=giv_name'>[giv_name]</a><br>"
		dat += "Reason:  <a href='?src=\ref[src];choice=reason'>[reason]</a><br>"
		dat += "Duration (minutes):  <a href='?src=\ref[src];choice=duration'>[duration] m</a><br>"
		dat += "Access to areas:<br>"
		if (giver && giver.access)
			for (var/A in giver.access)
				var/area = get_access_desc(A)
				if (A in accesses)
					area = "<b>[area]</b>"
				dat += "<a href='?src=\ref[src];choice=access;access=[A]'>[area]</a><br>"
		dat += "<br><a href='?src=\ref[src];action=issue'>Issue pass</a><br>"

	user << browse(dat, "window=guestpass;size=400x520")
	onclose(user, "guestpass")


/obj/machinery/computer/guestpass/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if (href_list["mode"])
		mode = text2num(href_list["mode"])

	if (href_list["choice"])
		switch(href_list["choice"])
			if ("giv_name")
				var/nam = sanitize(input("Person pass is issued to", "Name", input_default(giv_name)) as text|null)
				if (nam)
					giv_name = nam
			if ("reason")
				var/reas = sanitize(input("Reason why pass is issued", "Reason", input_default(reason)) as text|null)
				if(reas)
					reason = reas
			if ("duration")
				var/dur = input("Duration (in minutes) during which pass is valid (up to 60 minutes).", "Duration") as num|null
				if (dur)
					if (dur > 0 && dur <= 60)
						duration = dur
					else
						to_chat(usr, "<span class='warning'>Invalid duration.</span>")
			if ("access")
				var/A = text2num(href_list["access"])
				if (giver && (A in giver.access))
					if (A in accesses)
						accesses.Remove(A)
					else
						accesses.Add(A)
	if (href_list["action"])
		switch(href_list["action"])
			if ("id")
				if (giver)
					if(ishuman(usr))
						giver.loc = usr.loc
						if(!usr.get_active_hand())
							usr.put_in_hands(giver)
						giver = null
					else
						giver.loc = src.loc
						giver = null
					accesses.Cut()
				else
					var/obj/item/I = usr.get_active_hand()
					if (istype(I, /obj/item/weapon/card/id))
						usr.drop_item()
						I.loc = src
						giver = I
				updateUsrDialog()

			if ("print")
				var/dat = "<h3>Activity log of guest pass terminal #[uid]</h3><br>"
				for (var/entry in internal_log)
					dat += "[entry]<br><hr>"
				//usr << "Printing the log, standby..."
				//sleep(50)
				var/obj/item/weapon/paper/P = new/obj/item/weapon/paper(loc)
				P.name = "activity log"
				P.info = dat
				P.update_icon()

			if ("issue")
				if (giver)
					var/number = add_zero("[rand(0,9999)]", 4)
					var/entry = "\[[worldtime2text()]\] Pass #[number] issued by [giver.registered_name] ([giver.assignment]) to [giv_name]. Reason: [reason]. Grants access to following areas: "
					for (var/i=1 to accesses.len)
						var/A = accesses[i]
						if (A)
							var/area = get_access_desc(A)
							entry += "[i > 1 ? ", [area]" : "[area]"]"
					entry += ". Expires at [worldtime2text(world.time + duration*10*60)]."
					internal_log.Add(entry)

					var/obj/item/weapon/card/id/guest/pass = new(src.loc)
					pass.temp_access = accesses.Copy()
					pass.registered_name = giv_name
					pass.expiration_time = world.time + duration*10*60
					pass.reason = reason
					pass.issuedby = giver.registered_name
					pass.name = "guest pass #[number]"
					pass.count_until_expired()
				else
					to_chat(usr, "<span class='warning'>Cannot issue pass without issuing ID.</span>")

	updateUsrDialog()

/obj/machinery/computer/guestpass/dark // The darker sprite verison of a guest pass term. Did it just for mappers to use.
	name = "guest pass terminal"
	icon_state = "guest_dark"
