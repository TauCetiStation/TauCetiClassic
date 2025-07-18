/obj/machinery/computer/secure_data//TODO:SANITY
	name = "Security Records"
	desc = "Used to view and edit personnel's security records."
	icon_state = "security"
	light_color = "#a91515"
	req_one_access = list(access_security, access_forensics_lockers)
	circuit = /obj/item/weapon/circuitboard/secure_data
	allowed_checks = ALLOWED_CHECK_NONE
	var/obj/item/weapon/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/a_id = null
	var/temp = null
	var/can_change_id = 0
	var/list/Perp
	var/tempname = null
	//Sorting Variables
	var/sortBy = "name"
	var/order = 1 // -1 = Descending - 1 = Ascending
	var/static/icon/mugshot = icon('icons/obj/mugshot.dmi', "background") //records photo background
	var/next_print = 0
	var/docname

/obj/machinery/computer/secure_data/attackby(obj/item/O, user)
	if(istype(O, /obj/item/weapon/card/id) && !scan)
		usr.drop_from_inventory(O, src)
		O.loc = src
		scan = O
		to_chat(user, "You insert [O].")
	else
		..()

//Someone needs to break down the dat += into chunks instead of long ass lines.
/obj/machinery/computer/secure_data/ui_interact(mob/user)
	if (!SSmapping.has_level(z))
		to_chat(user, "<span class='warning'><b>Unable to establish a connection</b>:</span> You're too far away from the station!")
		return
	var/dat
	if (temp)
		dat = "<TT>[temp]</TT><BR><BR><A href='byond://?src=\ref[src];choice=Clear Screen'>Clear Screen</A>"
	else
		dat = "Confirm Identity: <A href='byond://?src=\ref[src];choice=Confirm Identity'>[scan ? "[scan.name]" : "----------"]</A><HR>"
		if (authenticated)
			switch(screen)
				if(1.0)
					dat += {"
						<p style='text-align:center;'>"}
					dat += "<A href='byond://?src=\ref[src];choice=Search Records'>Search Records</A><BR>"
					dat += "<A href='byond://?src=\ref[src];choice=New Record (General)'>New Record</A><BR>"
					dat += {"
						</p>
						<table style="text-align:center;" cellspacing="0" width="100%">
						<tr>
						<th>Records:</th>
						</tr>
						</table>
						<table style="text-align:center;" border="1" cellspacing="0" width="100%">
						<tr>
						<th><A href='byond://?src=\ref[src];choice=Sorting;sort=name'>Name</A></th>
						<th><A href='byond://?src=\ref[src];choice=Sorting;sort=id'>ID</A></th>
						<th><A href='byond://?src=\ref[src];choice=Sorting;sort=rank'>Rank</A></th>
						<th><A href='byond://?src=\ref[src];choice=Sorting;sort=fingerprint'>Fingerprints</A></th>
						<th>Criminal Status</th>
						</tr>"}
					if(!isnull(data_core.general))
						for(var/datum/data/record/R in sortRecord(data_core.general, sortBy, order))
							var/crimstat = ""
							for(var/datum/data/record/E in data_core.security)
								if ((E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"]))
									crimstat = E.fields["criminal"]
							var/background
							switch(crimstat)
								if("*Arrest*")
									background = "'bgbad'"
								if("Incarcerated")
									background = "'bgorange'"
								if("Paroled")
									background = "'bgorange'"
								if("Released")
									background = "'bgblue'"
								if("None")
									background = "'bggood'"
								if("")
									background = "''"
									crimstat = "No Record"
							dat += "<tr class=[background]><td><A href='byond://?src=\ref[src];choice=Browse Record;d_rec=\ref[R]'>[R.fields["name"]]</a></td>"
							dat += "<td>[R.fields["id"]]</td>"
							dat += "<td>[R.fields["rank"]]</td>"
							dat += "<td>[R.fields["fingerprint"]]</td>"
							dat += "<td>[crimstat]</td></tr>"
						dat += "</table><hr width='75%' />"
					dat += "<A href='byond://?src=\ref[src];choice=Record Maintenance'>Record Maintenance</A><br><br>"
					dat += "<A href='byond://?src=\ref[src];choice=Log Out'>Log Out</A>"
				if(2.0)
					dat += "<B>Records Maintenance</B><HR>"
					dat += "<BR><A href='byond://?src=\ref[src];choice=Delete All Records'>Delete All Records</A><BR><BR><A href='byond://?src=\ref[src];choice=Return'>Back</A>"
				if(3.0)
					dat += "<CENTER><B>Security Record</B></CENTER><BR>"
					if ((istype(active1, /datum/data/record) && data_core.general.Find(active1)))
						if(istype(active1.fields["photo_f"], /icon))
							var/icon/front = active1.fields["photo_f"]
							front.Blend(mugshot,ICON_UNDERLAY,1,1)
							user << browse_rsc(front, "front.png")
						if(istype(active1.fields["photo_s"], /icon))
							var/icon/side = active1.fields["photo_s"]
							side.Blend(mugshot,ICON_UNDERLAY,1,1)
							user << browse_rsc(side, "side.png")
						dat += "<style>img.nearest { -ms-interpolation-mode:nearest-neighbor }</style><table><tr><td>	\
							Name: <A href='byond://?src=\ref[src];choice=Edit Field;field=name'>[active1.fields["name"]]</A><BR> \
							ID: [active1.fields["id"]]<BR>\n	\
							Sex: <A href='byond://?src=\ref[src];choice=Edit Field;field=sex'>[active1.fields["sex"]]</A><BR>\n	\
							Age: <A href='byond://?src=\ref[src];choice=Edit Field;field=age'>[active1.fields["age"]]</A><BR>\n	\
							Home system: [active1.fields["home_system"]]<BR>\n	\
							Citizenship: [active1.fields["citizenship"]]<BR>\n	\
							Faction: [active1.fields["faction"]]<BR>\n	\
							Religion: [active1.fields["religion"]]<BR>\n	\
							Rank: <A href='byond://?src=\ref[src];choice=Edit Field;field=rank'>[active1.fields["rank"]]</A><BR>\n	\
							Fingerprint: <A href='byond://?src=\ref[src];choice=Edit Field;field=fingerprint'>[active1.fields["fingerprint"]]</A><BR>\n	\
							Insurance Account Number: [active1.fields["insurance_account_number"]]<BR>\n \
							Insurance Type: [active1.fields["insurance_type"]]<BR>\n \
							Physical Status: [active1.fields["p_stat"]]<BR>\n	\
							Mental Status: [active1.fields["m_stat"]]<BR></td>	\
							<td align = center valign = top>Photo:<br><img src=front.png height=80 width=80 border=4 class=nearest>	\
							<img src=side.png height=80 width=80 border=4 class=nearest><BR>\n	\
							Upload new photo: <A href='byond://?src=\ref[src];choice=Edit Field;field=photo_f'>front</A> <A href='byond://?src=\ref[src];choice=Edit Field;field=photo_s'>side</A></td></tr></table>"
					else
						dat += "<B>General Record Lost!</B><BR>"
					if ((istype(active2, /datum/data/record) && data_core.security.Find(active2)))
						dat += text(
							"<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: <A href='byond://?src=\ref[src];choice=Edit Field;field=criminal'>[]</A><BR>\n<BR>\nMinor Crimes: <A href='byond://?src=\ref[src];choice=Edit Field;field=mi_crim'>[]</A><BR>\nDetails: <A href='byond://?src=\ref[src];choice=Edit Field;field=mi_crim_d'>[]</A><BR>\n<BR>\nMajor Crimes: <A href='byond://?src=\ref[src];choice=Edit Field;field=ma_crim'>[]</A><BR>\nDetails: <A href='byond://?src=\ref[src];choice=Edit Field;field=ma_crim_d'>[]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='byond://?src=\ref[src];choice=Edit Field;field=notes'>[]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><HR>",
							active2.fields["criminal"],
							active2.fields["mi_crim"],
							active2.fields["mi_crim_d"],
							active2.fields["ma_crim"],
							active2.fields["ma_crim_d"],
							decode(active2.fields["notes"])
						)
						var/counter = 1
						while(active2.fields["com_[counter]"])
							dat += "[active2.fields["com_[counter]"]]<BR><A href='byond://?src=\ref[src];choice=Delete Entry;del_c=[counter]'>Delete Entry</A><HR>"
							counter++
						dat += "<A href='byond://?src=\ref[src];choice=Add Entry'>Add Entry</A><BR>"
						dat += "<A href='byond://?src=\ref[src];choice=Delete Record (Security)'>Delete Record (Security Only)</A><BR>"
					else
						dat += "<B>Security Record Lost!</B><BR>"
						dat += "<A href='byond://?src=\ref[src];choice=New Record (Security)'>New Security Record</A><BR><BR>"
					dat += "\n<A href='byond://?src=\ref[src];choice=Delete Record (ALL)'>Delete Record (ALL)</A><BR>\n<A href='byond://?src=\ref[src];choice=Print Record'>Print Record</A><BR>\n<A href='byond://?src=\ref[src];choice=Print Photos'>Print Photos</A><BR>\n<A href='byond://?src=\ref[src];choice=Return'>Back</A><BR>"
				if(4.0)
					if(!Perp.len)
						dat += "ERROR.  String could not be located.<br><br><A href='byond://?src=\ref[src];choice=Return'>Back</A>"
					else
						dat += {"
							<table style="text-align:center;" cellspacing="0" width="100%">
							<tr>					"}
						dat += "<th>Search Results for '[tempname]':</th>"
						dat += {"
							</tr>
							</table>
							<table style="text-align:center;" border="1" cellspacing="0" width="100%">
							<tr>
							<th>Name</th>
							<th>ID</th>
							<th>Rank</th>
							<th>Fingerprints</th>
							<th>Criminal Status</th>
							</tr>					"}
						for(var/i=1, i<=Perp.len, i += 2)
							var/crimstat = ""
							var/datum/data/record/R = Perp[i]
							if(istype(Perp[i+1],/datum/data/record))
								var/datum/data/record/E = Perp[i+1]
								crimstat = E.fields["criminal"]
							var/background
							switch(crimstat)
								if("*Arrest*")
									background = "'background-color:#DC143C;'"
								if("Incarcerated")
									background = "'background-color:#CD853F;'"
								if("Paroled")
									background = "'background-color:#CD853F;'"
								if("Released")
									background = "'background-color:#3BB9FF;'"
								if("None")
									background = "'background-color:#00FF7F;'"
								if("")
									background = "'background-color:#FFFFFF;'"
									crimstat = "No Record."
							dat += "<tr style=[background]><td><A href='byond://?src=\ref[src];choice=Browse Record;d_rec=\ref[R]'>[R.fields["name"]]</a></td>"
							dat += "<td>[R.fields["id"]]</td>"
							dat += "<td>[R.fields["rank"]]</td>"
							dat += "<td>[R.fields["fingerprint"]]</td>"
							dat += "<td>[crimstat]</td></tr>"
						dat += "</table><hr width='75%' />"
						dat += "<br><A href='byond://?src=\ref[src];choice=Return'>Return to index</a>"
		else
			dat += "<A href='byond://?src=\ref[src];choice=Log In'>Log In</A>"

	var/datum/browser/popup = new(user, "secure_rec", "Security Records", 600, 400)
	popup.set_content("<TT>[dat]</TT>")
	popup.open()

/*Revised /N
I can't be bothered to look more of the actual code outside of switch but that probably needs revising too.
What a mess.*/
/obj/machinery/computer/secure_data/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(!data_core.general.Find(active1))
		active1 = null
	if(!data_core.security.Find(active2))
		active2 = null

	switch(href_list["choice"])
// SORTING!
		if("Sorting")
			// Reverse the order if clicked twice
			if(sortBy == href_list["sort"])
				if(order == 1)
					order = -1
				else
					order = 1
			else
			// New sorting order!
				sortBy = href_list["sort"]
				order = initial(order)
//BASIC FUNCTIONS
		if("Clear Screen")
			temp = null

		if ("Return")
			screen = 1
			active1 = null
			active2 = null

		if("Confirm Identity")
			if(scan)
				if(ishuman(usr) && !usr.get_active_hand())
					usr.put_in_hands(scan)
				else
					scan.loc = get_turf(src)
				scan = null
				//Log Out
				authenticated = null
				screen = null
				active1 = null
				active2 = null
			else
				var/obj/item/I = usr.get_active_hand()
				if (istype(I, /obj/item/weapon/card/id))
					usr.drop_from_inventory(I, src)
					scan = I
					if(ishuman(usr))
						var/mob/living/carbon/human/H = usr
						H.sec_hud_set_ID()

		if("Log Out")
			authenticated = null
			screen = null
			active1 = null
			active2 = null

		if("Log In")
			if(isAI(usr))
				src.active1 = null
				src.active2 = null
				src.authenticated = usr.name
				src.rank = "AI"
				src.screen = 1
			else if(isrobot(usr))
				src.active1 = null
				src.active2 = null
				src.authenticated = usr.name
				var/mob/living/silicon/robot/R = usr
				src.rank = "[R.modtype] [R.braintype]"
				src.screen = 1
			else if (isobserver(usr))
				src.active1 = null
				src.active2 = null
				src.authenticated = "Centcomm Agent"
				src.rank = "Overseer"
				src.screen = 1
			else if (istype(scan, /obj/item/weapon/card/id))
				active1 = null
				active2 = null
				if(check_access(scan))
					authenticated = scan.registered_name
					rank = scan.assignment
					screen = 1
//RECORD FUNCTIONS
		if("Search Records")
			var/t1 = sanitize(input("Search String: (Partial Name or ID or Fingerprints or Rank)", "Secure. records", null, null)  as text, ascii_only = TRUE)
			if(!t1 || is_not_allowed(usr))
				return
			Perp = list()
			t1 = lowertext(t1)
			var/list/components = splittext(t1, " ")
			if(components.len > 5)
				return //Lets not let them search too greedily.
			for(var/datum/data/record/R in data_core.general)
				var/temptext = R.fields["name"] + " " + R.fields["id"] + " " + R.fields["fingerprint"] + " " + R.fields["rank"]
				for(var/i = 1, i<=components.len, i++)
					if(findtext(temptext,components[i]))
						var/list/prelist[2]
						prelist[1] = R
						Perp += prelist
			for(var/i = 1, i<=Perp.len, i+=2)
				for(var/datum/data/record/E in data_core.security)
					var/datum/data/record/R = Perp[i]
					if ((E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"]))
						Perp[i+1] = E
			tempname = t1
			screen = 4

		if("Record Maintenance")
			screen = 2
			active1 = null
			active2 = null

		if("Browse Record")
			var/datum/data/record/R = locate(href_list["d_rec"])
			var/S = locate(href_list["d_rec"])
			if(!data_core.general.Find(R))
				temp = "Record Not Found!"
			else
				for(var/datum/data/record/E in data_core.security)
					if ((E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"]))
						S = E
				active1 = R
				active2 = S
				screen = 3
//PRINTING
		if("Print Record")
			if(next_print > world.time)
				return
			var/datum/data/record/record1 = null
			var/datum/data/record/record2 = null
			if (istype(active1, /datum/data/record) && data_core.general.Find(active1))
				record1 = active1
			if (istype(active2, /datum/data/record) && data_core.security.Find(active2))
				record2 = active2
			var/info = "<CENTER><B>Security Record</B></CENTER><BR>"
			if (record1)
				info += text(
					"Name: [] ID: []<BR>\nSex: []<BR>\nAge: []<BR>\nFingerprint: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>",
					record1.fields["name"],
					record1.fields["id"],
					record1.fields["sex"],
					record1.fields["age"],
					record1.fields["fingerprint"],
					record1.fields["p_stat"],
					record1.fields["m_stat"]
				)
				docname = "Security Record ([record1.fields["name"]])"
			else
				info += "<B>General Record Lost!</B><BR>"
				docname = "Security Record"
			if (record2)
				info += text(
					"<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: []<BR>\n<BR>\nMinor Crimes: []<BR>\nDetails: []<BR>\n<BR>\nMajor Crimes: []<BR>\nDetails: []<BR>\n<BR>\nImportant Notes:<BR>\n\t[]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>",
					record2.fields["criminal"],
					record2.fields["mi_crim"],
					record2.fields["mi_crim_d"],
					record2.fields["ma_crim"],
					record2.fields["ma_crim_d"],
					decode(record2.fields["notes"])
				)
				var/counter = 1
				while(record2.fields["com_[counter]"])
					info += "[record2.fields["com_[counter]"]]<BR>"
					counter++
			else
				info += "<B>Security Record Lost!</B><BR>"
			info += "</TT>"
			print_document(info, docname)
			next_print = world.time + 50
			updateUsrDialog()
		if("Print Photos")
			if(next_print > world.time)
				return
			if (istype(active1, /datum/data/record) && data_core.general.Find(active1))
				var/datum/data/record/photo = active1
				photo.fields["image"] = photo.fields["photo_f"]
				docname = "Security Record's photo"
				photo.fields["author"] = usr
				photo.fields["icon"] = icon('icons/obj/mugshot.dmi',"photo")
				photo.fields["small_icon"] = icon('icons/obj/mugshot.dmi',"small_photo")
				if(istype(active1.fields["photo_f"], /icon))
					print_photo(photo, docname)
				if(istype(active1.fields["photo_s"], /icon))
					photo.fields["image"] = active1.fields["photo_s"]
					print_photo(photo, docname)
				next_print = world.time + 50

//RECORD DELETE
		if("Delete All Records")
			temp = ""
			temp += "Are you sure you wish to delete all Security records?<br>"
			temp += "<a href='byond://?src=\ref[src];choice=Purge All Records'>Yes</a><br>"
			temp += "<a href='byond://?src=\ref[src];choice=Clear Screen'>No</a>"

		if("Purge All Records")
			for(var/datum/data/record/R in data_core.security)
				qdel(R)
			temp = "All Security records deleted."

		if("Add Entry")
			if(!istype(active2, /datum/data/record))
				return
			var/a2 = active2
			var/t1 = sanitize(input("Add Comment:", "Secure. records", null, null)  as message)
			if ((!( t1 ) || !( authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || active2 != a2))
				return FALSE
			if(scan)
				add_record(scan, active2, t1)
			else
				add_record(usr, active2, t1)

		if("Delete Record (ALL)")
			if(active1)
				temp = "<h5>Are you sure you wish to delete the record (ALL)?</h5>"
				temp += "<a href='byond://?src=\ref[src];choice=Delete Record (ALL) Execute'>Yes</a><br>"
				temp += "<a href='byond://?src=\ref[src];choice=Clear Screen'>No</a>"

		if("Delete Record (Security)")
			if(active2)
				temp = "<h5>Are you sure you wish to delete the record (Security Portion Only)?</h5>"
				temp += "<a href='byond://?src=\ref[src];choice=Delete Record (Security) Execute'>Yes</a><br>"
				temp += "<a href='byond://?src=\ref[src];choice=Clear Screen'>No</a>"

		if("Delete Entry")
			if ((istype(active2, /datum/data/record) && active2.fields["com_[href_list["del_c"]]"]))
				active2.fields["com_[href_list["del_c"]]"] = "<B>Deleted</B>"
//RECORD CREATE
		if("New Record (Security)")
			if ((istype(active1, /datum/data/record) && !( istype(active2, /datum/data/record) )))
				active2 = CreateSecurityRecord(active1.fields["name"], active1.fields["id"])
				screen = 3

		if("New Record (General)")
			active1 = CreateGeneralRecord() // todo: datacore.manifest_inject or scaner (Identity Analyser)
			active2 = null

//FIELD FUNCTIONS
		if("Edit Field")
			if(is_not_allowed(usr))
				return
			var/a1 = active1
			var/a2 = active2
			switch(href_list["field"])
				if("name")
					if(istype(active1, /datum/data/record))
						var/t1 = sanitize(input("Please input name:", "Secure. records", input_default(active1.fields["name"]), null)  as text)
						if(!t1 || active1 != a1)
							return FALSE
						active1.fields["name"] = t1
				if("fingerprint")
					if(istype(active1, /datum/data/record))
						var/t1 = sanitize(input("Please input fingerprint hash:", "Secure. records", input_default(active1.fields["fingerprint"]), null)  as text)
						if(!t1 || active1 != a1 || t1 == active1.fields["fingerprint"])
							return FALSE

						active1.fields["fingerprint"] = t1
						active1.fields["insurance_account_number"] = 0
						active1.fields["insurance_type"] = INSURANCE_NONE

				if("sex")
					if(istype(active1, /datum/data/record))
						if(active1.fields["sex"] == "Male")
							active1.fields["sex"] = "Female"
						else
							active1.fields["sex"] = "Male"
				if("age")
					if(istype(active1, /datum/data/record))
						var/t1 = input("Please input age:", "Secure. records", active1.fields["age"], null)  as num
						if(!t1 || active1 != a1)
							return FALSE
						active1.fields["age"] = t1
				if("mi_crim")
					if(istype(active2, /datum/data/record))
						var/t1 = sanitize(input("Please input minor disabilities list:", "Secure. records", input_default(active2.fields["mi_crim"]), null)  as text)
						if (!t1 || active2 != a2)
							return FALSE
						active2.fields["mi_crim"] = t1
				if("mi_crim_d")
					if(istype(active2, /datum/data/record))
						var/t1 = sanitize(input("Please summarize minor dis.:", "Secure. records", input_default(active2.fields["mi_crim_d"]), null)  as message)
						if (!t1 || active2 != a2)
							return FALSE
						active2.fields["mi_crim_d"] = t1
				if("ma_crim")
					if(istype(active2, /datum/data/record))
						var/t1 = sanitize(input("Please input major diabilities list:", "Secure. records", input_default(active2.fields["ma_crim"]), null)  as text)
						if (!t1 || active2 != a2)
							return FALSE
						active2.fields["ma_crim"] = t1
				if("ma_crim_d")
					if (istype(active2, /datum/data/record))
						var/t1 = sanitize(input("Please summarize major dis.:", "Secure. records", input_default(active2.fields["ma_crim_d"]), null)  as message)
						if(!t1 || active2 != a2)
							return FALSE
						active2.fields["ma_crim_d"] = t1
				if("notes")
					if(istype(active2, /datum/data/record))
						var/t1 = sanitize(input("Please summarize notes:", "Secure. records", input_default(active2.fields["notes"]), null)  as message)
						if (!t1 || active2 != a2)
							return FALSE
						active2.fields["notes"] = t1
				if("criminal")
					if(istype(active2, /datum/data/record))
						if(scan)
							change_criminal_status(usr, scan, null, active2, TRUE, src)
						else
							change_criminal_status(usr, usr, null, active2, TRUE, src)
				if("rank")
					var/list/L = list( "Head of Personnel", "Captain", "AI" )
					//This was so silly before the change. Now it actually works without beating your head against the keyboard. /N
					if((istype(active1, /datum/data/record) && L.Find(rank)))
						temp = "<h5>Rank:</h5>"
						temp += "<ul>"
						for(var/rank in SSjob.GetHumanJobs())
							temp += "<li><a href='byond://?src=\ref[src];choice=Change Rank;rank=[rank]'>[rank]</a></li>"
						temp += "</ul>"
					else
						tgui_alert(usr, "You do not have the required rank to do this!")
				if("species")
					if (istype(active1, /datum/data/record))
						var/t1 = sanitize(input("Please enter race:", "General records", input_default(active1.fields["species"]), null) as message)
						if(!t1 || is_not_allowed(usr) || (active1 != a1))
							return FALSE
						active1.fields["species"] = t1
				if("photo_f")
					if(istype(active1, /datum/data/record))
						if(active1 != a1)
							return FALSE
						var/icon/photo = get_photo(usr)
						if(!photo)
							return FALSE
						qdel(active1.fields["photo_f"])
						active1.fields["photo_f"] = photo
				if("photo_s")
					if(istype(active1, /datum/data/record))
						if(active1 != a1)
							return FALSE
						var/icon/photo = get_photo(usr)
						if(!photo)
							return FALSE
						qdel(active1.fields["photo_s"])
						active1.fields["photo_s"] = photo
//TEMPORARY MENU FUNCTIONS
		else//To properly clear as per clear screen.
			temp=null
			switch(href_list["choice"])
				if ("Change Rank")
					if (active1)
						active1.fields["rank"] = href_list["rank"]
						if(href_list["rank"] in SSjob.GetHumanJobs())
							active1.fields["real_rank"] = href_list["real_rank"]

				if ("Delete Record (Security) Execute")
					if (active2)
						qdel(active2)

				if ("Delete Record (ALL) Execute")
					if (active1)
						for(var/datum/data/record/R in data_core.medical)
							if ((R.fields["name"] == active1.fields["name"] || R.fields["id"] == active1.fields["id"]))
								qdel(R)
						qdel(active1)
					if (active2)
						qdel(active2)
				else
					temp = "This function does not appear to be working at the moment. Our apologies."

	updateUsrDialog()

/obj/machinery/computer/secure_data/proc/is_not_allowed(mob/user)
	return !src.authenticated || user.incapacitated()|| (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr))

/obj/machinery/computer/secure_data/proc/get_photo(mob/user)
	var/icon/I = null
	var/obj/item/weapon/photo/P = null
	if(issilicon(user))
		var/mob/living/silicon/S = user
		if(!S.aiCamera)
			return null
		var/datum/picture/selection = S.aiCamera.selectpicture()
		if(selection)
			P = new()
			P.construct(selection)
			I = P.img
			qdel(P)
	else if(istype(user.get_active_hand(), /obj/item/weapon/photo))
		P = user.get_active_hand()
		I = P.img
		user.drop_from_inventory(P)
		qdel(P)
	return I

/obj/machinery/computer/secure_data/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	for(var/datum/data/record/R in data_core.security)
		if(prob(10/severity))
			switch(rand(1,6))
				if(1)
					R.fields["name"] = "[pick(pick(first_names_male), pick(first_names_female))] [pick(last_names)]"
				if(2)
					R.fields["sex"]	= pick("Male", "Female")
				if(3)
					R.fields["age"] = rand(5, 85)
				if(4)
					R.fields["criminal"] = pick("None", "*Arrest*", "Incarcerated", "Paroled", "Released")
				if(5)
					R.fields["p_stat"] = pick("*SSD*", "Active", "Physically Unfit", "Disabled")
				if(6)
					R.fields["m_stat"] = pick("*Insane*", "*Unstable*", "*Watch*", "Stable")
			continue

		else if(prob(1))
			qdel(R)
			continue

	..(severity)

/obj/machinery/computer/secure_data/detective_computer
	icon = 'icons/obj/computer.dmi'
	icon_state = "messyfiles"
