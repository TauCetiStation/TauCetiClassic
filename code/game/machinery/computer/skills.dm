#define SKILLS_MODE_MAIN_SCREEN 1
#define SKILLS_MODE_MAINTENACE_SCREEN 2
#define SKILLS_MODE_EDIT_SCREEN 3
#define SKILLS_MODE_SEARCH_SCREEN 4

/obj/machinery/computer/skills//TODO:SANITY
	name = "Employment Records"
	desc = "Used to view personnel's employment records."
	icon_state = "laptop_employment"
	state_broken_preset = "laptopb"
	state_nopower_preset = "laptop0"
	light_color = "#00b000"
	req_one_access = list(access_heads)
	circuit = /obj/item/weapon/circuitboard/skills
	allowed_checks = ALLOWED_CHECK_NONE

	var/obj/item/weapon/card/id/scan = null  //current id card inside machine
	var/authenticated = null                 // Are user authenticated?
	var/rank = null                          // Rank of authenticated person
	var/screen = null                        // What type of screen now output
	var/datum/data/record/active1 = null     // Current using record
	var/temp = null                          // Buffer for temporary menu show
	var/static/icon/mugshot = icon('icons/obj/mugshot.dmi', "background") //records photo background
	var/next_print = 0
	var/list/Perp                            // Buffer for searched results
	var/searched_text = null                 // Name of found person
	var/sortBy = "name"                      // field to sort
	var/order = 1                            // -1 = Descending - 1 = Ascending
	var/docname

	required_skills = list(/datum/skill/command = SKILL_LEVEL_TRAINED)

/obj/machinery/computer/skills/attackby(obj/item/O, user)
	if(istype(O, /obj/item/weapon/card/id) && !scan)
		usr.drop_from_inventory(O, src)
		scan = O
		to_chat(user, "You insert [O].")
	..()

//Someone needs to break down the dat += into chunks instead of long ass lines.
/obj/machinery/computer/skills/ui_interact(mob/user)
	if (!SSmapping.has_level(z))
		to_chat(user, "<span class='warning'><b>Unable to establish a connection</b>:</span> You're too far away from the station!")
		return
	var/dat
	if (temp)
		dat = "<tt>[temp]</tt><br><br><a href='?src=\ref[src];choice=Clear Screen'>Clear Screen</a>"
	else
		dat = "Confirm Identity: <a href='?src=\ref[src];choice=Confirm Identity'>[scan ? scan.name : "----------"]</a><hr>"
		if (authenticated)
			switch(screen)
				if(SKILLS_MODE_MAIN_SCREEN)
					dat += {"<p style='text-align:center;'>
						<a href='?src=\ref[src];choice=Search Records'>Search Records</a><br>
						<a href='?src=\ref[src];choice=New Record (General)'>New Record</a><br></p>
						<table style="text-align:center;" cellspacing="0" width="100%">
						<tr><th>Records:</th></tr>
						</table>
						<table style="text-align:center;" border="1" cellspacing="0" width="100%">
						<tr>
						<th><a href='?src=\ref[src];choice=Sorting;sort=name'>Name</a></th>
						<th><a href='?src=\ref[src];choice=Sorting;sort=id'>ID</a></th>
						<th><a href='?src=\ref[src];choice=Sorting;sort=rank'>Rank</a></th>
						<th><a href='?src=\ref[src];choice=Sorting;sort=fingerprint'>Fingerprints</a></th>
						</tr>"}
					if(!isnull(data_core.general))
						for(var/datum/data/record/R in sortRecord(data_core.general, sortBy, order))
							for(var/datum/data/record/E in data_core.security)
							var/background
							dat += {"<tr style=[background]>
							<td><A href='?src=\ref[src];choice=Browse Record;d_rec=\ref[R]'>[R.fields["name"]]</a></td>
							<td>[R.fields["id"]]</td>
							<td>[R.fields["rank"]]</td>
							<td>[R.fields["fingerprint"]]</td>
							</tr>"}
						dat += "</table><hr width='75%' />"
					dat += "<A href='?src=\ref[src];choice=Record Maintenance'>Record Maintenance</A><br><br>"
					dat += "<A href='?src=\ref[src];choice=Log Out'>Log Out</A>"
				if(SKILLS_MODE_MAINTENACE_SCREEN)
					dat += {"<b>Records Maintenance</b>
					<hr><br>
					<a href='?src=\ref[src];choice=Delete All Records'>Delete All Records</a><br><br>
					<a href='?src=\ref[src];choice=Return'>Back</a>"}
				if(SKILLS_MODE_EDIT_SCREEN)
					dat += "<center><b>Employment Record</b></center><br>"
					if ((istype(active1, /datum/data/record) && data_core.general.Find(active1)))
						var/icon/front = active1.fields["photo_f"]
						front.Blend(mugshot,ICON_UNDERLAY,1,1)
						var/icon/side = active1.fields["photo_s"]
						side.Blend(mugshot,ICON_UNDERLAY,1,1)
						user << browse_rsc(front, "front.png")
						user << browse_rsc(side, "side.png")
						dat += {"<style>img.nearest { -ms-interpolation-mode:nearest-neighbor }</style><table><tr><td>
							Name: <a href='?src=\ref[src];choice=Edit Field;field=name'>[active1.fields["name"]]</a><br>
							ID: [active1.fields["id"]]<br>
							Sex: <a href='?src=\ref[src];choice=Edit Field;field=sex'>[active1.fields["sex"]]</a><br>
							Age: <a href='?src=\ref[src];choice=Edit Field;field=age'>[active1.fields["age"]]</a><br>
							Home system: [active1.fields["home_system"]]<br>
							Citizenship: [active1.fields["citizenship"]]<br>
							Faction: [active1.fields["faction"]]<br>
							Religion: [active1.fields["religion"]]<br>
							Rank: <a href='?src=\ref[src];choice=Edit Field;field=rank'>[active1.fields["rank"]]</a><br>
							Fingerprint: [active1.fields["fingerprint"]]<br>
							Insurance Account Number: [active1.fields["insurance_account_number"]]<br>
							Insurance Type: [active1.fields["insurance_type"]]<br>
							Physical Status: [active1.fields["p_stat"]]<br>
							Mental Status: [active1.fields["m_stat"]]<br><br>
							Employment/skills summary:<BR> [decode(active1.fields["notes"])]<br></td>
							<td align = center valign = top>Photo:<br><img src=front.png height=80 width=80 border=4 class=nearest>
							<img src=side.png height=80 width=80 border=4 class=nearest></td></tr></table>"}
					else
						dat += "<b>General Record Lost!</b><br>"
					dat += {"
					<a href='?src=\ref[src];choice=Delete Record (ALL)'>Delete Record (ALL)</a><br><br>
					<a href='?src=\ref[src];choice=Print Record'>Print Record</a><br>
					<a href='?src=\ref[src];choice=Print Photos'>Print Photos</a><br>
					<a href='?src=\ref[src];choice=Return'>Back</a><br>"}
				if(SKILLS_MODE_SEARCH_SCREEN)
					if(!Perp.len)
						dat += "ERROR.  String could not be located.<br><br><A href='?src=\ref[src];choice=Return'>Back</A>"
					else
						dat += {"
							<table style="text-align:center;" cellspacing="0" width="100%">
							<tr>
							<th>Search Results for '[searched_text]':</th>
							</tr>
							</table>
							<table style="text-align:center;" border="1" cellspacing="0" width="100%">
							<tr>
							<th>Name</th>
							<th>ID</th>
							<th>Rank</th>
							<th>Fingerprints</th>
							</tr>"}
						for(var/i=1, i<=Perp.len, i += 2)
							var/crimstat = ""
							var/datum/data/record/R = Perp[i]
							if(istype(Perp[i+1],/datum/data/record))
								var/datum/data/record/E = Perp[i+1]
								crimstat = E.fields["criminal"]
							var/background
							background = "'background-color:#00FF7F;'"
							dat += "<tr style=[background]><td><A href='?src=\ref[src];choice=Browse Record;d_rec=\ref[R]'>[R.fields["name"]]</a></td>"
							dat += "<td>[R.fields["id"]]</td>"
							dat += "<td>[R.fields["rank"]]</td>"
							dat += "<td>[R.fields["fingerprint"]]</td>"
							dat += "<td>[crimstat]</td></tr>"
						dat += "</table><hr width='75%' />"
						dat += "<br><A href='?src=\ref[src];choice=Return'>Return to index</A>"
				else
		else
			dat += "<A href='?src=\ref[src];choice=Log In'>Log In</A>"

	var/datum/browser/popup = new(user, "secure_rec", "Employment Records", 600, 400)
	popup.set_content("<TT>[dat]</TT>")
	popup.open()


/*Revised /N
I can't be bothered to look more of the actual code outside of switch but that probably needs revising too.
What a mess.*/
/obj/machinery/computer/skills/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if (!( data_core.general.Find(active1) ))
		active1 = null
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
		// BASIC FUNCTIONS
		if("Clear Screen")
			temp = null

		if ("Return")
			screen = SKILLS_MODE_MAIN_SCREEN
			active1 = null

		if("Confirm Identity")
			if (scan)
				if(ishuman(usr) && !usr.get_active_hand())
					usr.put_in_hands(scan)
				else
					scan.loc = get_turf(src)
				scan = null
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

		if("Log In")
			if (isAI(usr))
				src.active1 = null
				src.authenticated = usr.name
				src.rank = "AI"
				src.screen = SKILLS_MODE_MAIN_SCREEN
			else if (isrobot(usr))
				src.active1 = null
				src.authenticated = usr.name
				var/mob/living/silicon/robot/R = usr
				src.rank = R.braintype
				src.screen = SKILLS_MODE_MAIN_SCREEN
			else if (isobserver(usr))
				src.active1 = null
				src.authenticated = "Centcomm Agent"
				src.rank = "Overseer"
				src.screen = SKILLS_MODE_MAIN_SCREEN
			else if (istype(scan, /obj/item/weapon/card/id))
				active1 = null
				if(check_access(scan))
					authenticated = scan.registered_name
					rank = scan.assignment
					screen = SKILLS_MODE_MAIN_SCREEN
		// RECORD FUNCTIONS
		if("Search Records")
			var/t1 = sanitize_safe(input("Search String: (Partial Name or ID or Fingerprints or Rank)", "Secure. records", null, null)  as text, ascii_only = TRUE)
			if ((!( t1 ) || !( authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr))))
				return FALSE
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
			searched_text = t1
			screen = SKILLS_MODE_SEARCH_SCREEN

		if("Record Maintenance")
			screen = SKILLS_MODE_MAINTENACE_SCREEN
			active1 = null

		if ("Browse Record")
			var/datum/data/record/R = locate(href_list["d_rec"])
			if (!( data_core.general.Find(R) ))
				temp = "Record Not Found!"
			else
				for(var/datum/data/record/E in data_core.security)
				active1 = R
				screen = SKILLS_MODE_EDIT_SCREEN

		if ("Print Record")
			if(next_print > world.time)
				return
			var/info = "<center><b>Employment Record</b></center><BR>"
			if ((istype(active1, /datum/data/record) && data_core.general.Find(active1)))
				info += "Name: [active1.fields["name"]]<BR>\n"
				info += "ID: [active1.fields["id"]]<BR>\n"
				info += "Sex: [active1.fields["sex"]]<BR>\n"
				info += "Age: [active1.fields["age"]]<BR>\n"
				info += "Fingerprint: [active1.fields["fingerprint"]]<BR>\n"
				info += "Physical Status: [active1.fields["p_stat"]]<BR>\n"
				info += "Mental Status: [active1.fields["m_stat"]]<BR>\n"
				info += "Employment/Skills Summary:<BR>\n[decode(active1.fields["notes"])]<BR>"
			else
				info += "<b>General Record Lost!</b><br>"
			info += "</tt>"
			docname = "Employment Record ([active1.fields["name"]])"
			print_document(info, docname)
			updateUsrDialog()
			next_print = world.time + 50

		if("Print Photos")
			if(next_print > world.time)
				return
			if (istype(active1, /datum/data/record) && data_core.general.Find(active1))
				var/datum/data/record/photo = active1
				photo.fields["image"] = photo.fields["photo_f"]
				docname = "Employment Record's photo"
				photo.fields["author"] = usr
				photo.fields["icon"] = icon('icons/obj/mugshot.dmi',"photo")
				photo.fields["small_icon"] = icon('icons/obj/mugshot.dmi',"small_photo")
				if(istype(active1.fields["photo_f"], /icon))
					print_photo(photo, docname)
				if(istype(active1.fields["photo_s"], /icon))
					photo.fields["image"] = active1.fields["photo_s"]
					print_photo(photo, docname)
				next_print = world.time + 50

		// RECORD DELETE
		if ("Delete All Records")
			//FIXME: Now only removing security records, not general
			/*
			temp = ""
			temp += "Are you sure you wish to delete all Employment records?<br>"
			temp += "<a href='?src=\ref[src];choice=Purge All Records'>Yes</a><br>"
			temp += "<a href='?src=\ref[src];choice=Clear Screen'>No</a>"
			*/
			temp = "<b>Error!</b> This function does not appear to be working at the moment. Our apologies."

		if ("Purge All Records")
			PDA_Manifest.Cut()
			for(var/datum/data/record/R in data_core.security)
				qdel(R)
			temp = "All Employment records deleted."

		if ("Delete Record (ALL)")
			if (active1)
				temp = "<h5>Are you sure you wish to delete the record (ALL)?</h5>"
				temp += "<a href='?src=\ref[src];choice=Delete Record (ALL) Execute'>Yes</a><br>"
				temp += "<a href='?src=\ref[src];choice=Clear Screen'>No</a>"
		// RECORD CREATE
		if ("New Record (General)")
			active1 = CreateGeneralRecord() // todo: datacore.manifest_inject or scaner (Identity Analyser)

		// FIELD FUNCTIONS
		if ("Edit Field")
			var/a1 = active1
			switch(href_list["field"])
				if("name")
					if (istype(active1, /datum/data/record))
						var/t1 = sanitize(input("Please input name:", "Secure. records", input_default(active1.fields["name"]), null)  as text, MAX_NAME_LEN)
						if ((!( t1 ) || !( authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr))) || active1 != a1)
							return FALSE
						active1.fields["name"] = t1
						PDA_Manifest.Cut()
				if("sex")
					if (istype(active1, /datum/data/record))
						if (active1.fields["sex"] == "Male")
							active1.fields["sex"] = "Female"
						else
							active1.fields["sex"] = "Male"
				if("age")
					if (istype(active1, /datum/data/record))
						var/t1 = input("Please input age:", "Secure. records", active1.fields["age"], null)  as num
						if ((!( t1 ) || !( authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || active1 != a1))
							return FALSE
						active1.fields["age"] = t1
				if("rank")
					var/list/L = list( "Head of Personnel", "Captain", "AI" )
					//This was so silly before the change. Now it actually works without beating your head against the keyboard. /N
					if ((istype(active1, /datum/data/record) && L.Find(rank)))
						temp = "<h5>Rank:</h5>"
						temp += "<ul>"
						for(var/rank in joblist)
							temp += "<li><a href='?src=\ref[src];choice=Change Rank;rank=[rank]'>[rank]</a></li>"
						temp += "</ul>"
					else
						tgui_alert(usr, "You do not have the required rank to do this!")
				if("species")
					if (istype(active1, /datum/data/record))
						var/t1 = sanitize(input("Please enter race:", "General records", input_default(active1.fields["species"]), null) as message)
						if ((!( t1 ) || !( authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || active1 != a1))
							return FALSE
						active1.fields["species"] = t1

		// TEMPORARY MENU FUNCTIONS
		else // To properly clear as per clear screen.
			temp=null
			switch(href_list["choice"])
				if ("Change Rank")
					if (active1)
						PDA_Manifest.Cut()
						active1.fields["rank"] = href_list["rank"]
						if(href_list["rank"] in joblist)
							active1.fields["real_rank"] = href_list["real_rank"]

				if ("Delete Record (ALL) Execute")
					if (active1)
						PDA_Manifest.Cut()
						for(var/datum/data/record/R in data_core.medical)
							if ((R.fields["name"] == active1.fields["name"] || R.fields["id"] == active1.fields["id"]))
								qdel(R)
						qdel(active1)
				else
					temp = "This function does not appear to be working at the moment. Our apologies."

	updateUsrDialog()

/obj/machinery/computer/skills/emp_act(severity)
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

#undef SKILLS_MODE_MAIN_SCREEN
#undef SKILLS_MODE_MAINTENACE_SCREEN
#undef SKILLS_MODE_EDIT_SCREEN
#undef SKILLS_MODE_SEARCH_SCREEN
