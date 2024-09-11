ADD_TO_GLOBAL_LIST(/obj/machinery/computer/med_data, med_record_consoles_list)
/obj/machinery/computer/med_data//TODO:SANITY
	name = "Medical Records"
	desc = "This can be used to check medical records."
	icon_state = "medcomp"
	state_broken_preset = "crewb"
	state_nopower_preset = "crew0"
	light_color = "#315ab4"
	req_one_access = list(access_medical, access_forensics_lockers)
	circuit = /obj/item/weapon/circuitboard/med_data
	allowed_checks = ALLOWED_CHECK_NONE
	var/obj/item/weapon/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/a_id = null
	var/temp = null
	var/static/icon/mugshot = icon('icons/obj/mugshot.dmi', "background") //records photo background
	var/next_print = 0
	var/docname
	required_skills = list(/datum/skill/medical = SKILL_LEVEL_NOVICE)

/obj/machinery/computer/med_data/attackby(obj/item/O, user)
	if(istype(O, /obj/item/weapon/card/id) && !scan)
		usr.drop_from_inventory(O, src)
		scan = O
		to_chat(user, "You insert [O].")
	..()

/obj/machinery/computer/med_data/ui_interact(mob/user)
	var/dat
	if (src.temp)
		dat = "<TT>[src.temp]</TT><BR><BR><A href='?src=\ref[src];temp=1'>Clear Screen</A>"
	else
		dat = "Confirm Identity: <A href='?src=\ref[src];scan=1'>[src.scan ? "[src.scan.name]" : "----------"]</A><HR>"
		if (src.authenticated)
			switch(src.screen)
				if(1.0)
					dat += {"
						<A href='?src=\ref[src];search=1'>Search Records</A>
						<BR><A href='?src=\ref[src];screen=2'>List Records</A>
						<BR>
						<BR><A href='?src=\ref[src];screen=5'>Virus Database</A>
						<BR><A href='?src=\ref[src];screen=6'>Medbot Tracking</A>
						<BR>
						<BR><A href='?src=\ref[src];screen=3'>Record Maintenance</A>
						<BR><A href='?src=\ref[src];logout=1'>Log Out</A><BR>
						"}
				if(2.0)
					dat += "<B>Record List</B>:<HR>"
					if(!isnull(data_core.general))
						for(var/datum/data/record/R in sortRecord(data_core.general))
							dat += "<A href='?src=\ref[src];d_rec=\ref[R]'>[R.fields["id"]]: [R.fields["name"]]</A><BR>"
							//Foreach goto(132)
					dat += "<HR><A href='?src=\ref[src];screen=1'>Back</A>"
				if(3.0)
					dat += "<B>Records Maintenance</B><HR>\n<A href='?src=\ref[src];back=1'>Backup To Disk</A><BR>\n<A href='?src=\ref[src];u_load=1'>Upload From disk</A><BR>\n<A href='?src=\ref[src];del_all=1'>Delete All Records</A><BR>\n<BR>\n<A href='?src=\ref[src];screen=1'>Back</A>"
				if(4.0)
					dat += "<CENTER><B>Medical Record</B></CENTER><BR>"
					if ((istype(src.active1, /datum/data/record) && data_core.general.Find(src.active1)))
						var/icon/front = active1.fields["photo_f"]
						front.Blend(mugshot,ICON_UNDERLAY,1,1)
						var/icon/side = active1.fields["photo_s"]
						side.Blend(mugshot,ICON_UNDERLAY,1,1)
						user << browse_rsc(front, "front.png")
						user << browse_rsc(side, "side.png")

						dat += "<style>img.nearest { -ms-interpolation-mode:nearest-neighbor }</style><table><tr><td>Name: [active1.fields["name"]] \
								ID: [active1.fields["id"]]<BR>\n	\
								Sex: <A href='?src=\ref[src];field=sex'>[active1.fields["sex"]]</A><BR>\n	\
								Age: <A href='?src=\ref[src];field=age'>[active1.fields["age"]]</A><BR>\n	\
								Fingerprint: <A href='?src=\ref[src];field=fingerprint'>[active1.fields["fingerprint"]]</A><BR>\n	\
								Insurance Account Number: <A href='?src=\ref[src];field=insurance_account_number'>[active1.fields["insurance_account_number"]]</A><BR>\n	\
								Insurance Type: [active1.fields["insurance_type"]]<BR>\n \
								Physical Status: <A href='?src=\ref[src];field=p_stat'>[active1.fields["p_stat"]]</A><BR>\n	\
								Mental Status: <A href='?src=\ref[src];field=m_stat'>[active1.fields["m_stat"]]</A><BR></td><td align = center valign = top> \
								Photo:<br><img src=front.png height=64 width=64 border=5 class=nearest><img src=side.png height=64 width=64 border=5 class=nearest></td></tr></table>"
					else
						dat += "<B>General Record Lost!</B><BR>"
					if ((istype(src.active2, /datum/data/record) && data_core.medical.Find(src.active2)))
						dat += text(
							"<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: <A href='?src=\ref[src];field=b_type'>[]</A><BR>\nDNA: <A href='?src=\ref[src];field=b_dna'>[]</A><BR>\n<BR>\nMinor Disabilities: <A href='?src=\ref[src];field=mi_dis'>[]</A><BR>\nDetails: <A href='?src=\ref[src];field=mi_dis_d'>[]</A><BR>\n<BR>\nMajor Disabilities: <A href='?src=\ref[src];field=ma_dis'>[]</A><BR>\nDetails: <A href='?src=\ref[src];field=ma_dis_d'>[]</A><BR>\n<BR>\nAllergies: <A href='?src=\ref[src];field=alg'>[]</A><BR>\nDetails: <A href='?src=\ref[src];field=alg_d'>[]</A><BR>\n<BR>\nCurrent Diseases: <A href='?src=\ref[src];field=cdi'>[]</A> (per disease info placed in log/comment section)<BR>\nDetails: <A href='?src=\ref[src];field=cdi_d'>[]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=\ref[src];field=notes'>[]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>",
							src.active2.fields["b_type"],
							src.active2.fields["b_dna"],
							src.active2.fields["mi_dis"],
							src.active2.fields["mi_dis_d"],
							src.active2.fields["ma_dis"],
							src.active2.fields["ma_dis_d"],
							src.active2.fields["alg"],
							src.active2.fields["alg_d"],
							src.active2.fields["cdi"],
							src.active2.fields["cdi_d"],
							decode(src.active2.fields["notes"])
						)
						var/counter = 1
						while(src.active2.fields["com_[counter]"])
							dat += "[src.active2.fields["com_[counter]"]]<BR><A href='?src=\ref[src];del_c=[counter]'>Delete Entry</A><BR><BR>"
							counter++
						dat += "<A href='?src=\ref[src];add_c=1'>Add Entry</A><BR><BR>"
						dat += "<A href='?src=\ref[src];del_r=1'>Delete Record (Medical Only)</A><BR><BR>"
					else
						dat += "<B>Medical Record Lost!</B><BR>"
						dat += "<A href='?src=\ref[src];new=1'>New Record</A><BR><BR>"
					dat += "\n<A href='?src=\ref[src];print_p=1'>Print Record</A><BR>\n<A href='?src=\ref[src];print_photos=1'>Print Photos</A><BR>\n<A href='?src=\ref[src];screen=2'>Back</A><BR>"
				if(5.0)
					dat += "<CENTER><B>Virus Database</B></CENTER>"
					for (var/ID in virusDB)
						var/datum/data/record/v = virusDB[ID]
						dat += "<br><a href='?src=\ref[src];vir=\ref[v]'>[v.fields["name"]]</a>"

					dat += "<br><a href='?src=\ref[src];screen=1'>Back</a>"
				if(6.0)
					dat += "<center><b>Medical Robot Monitor</b></center>"
					dat += "<a href='?src=\ref[src];screen=1'>Back</a>"
					dat += "<br><b>Medical Robots:</b>"
					var/bdat = null
					for(var/obj/machinery/bot/medbot/M in bots_list)

						if(M.z != src.z)	continue	//only find medibots on the same z-level as the computer
						var/turf/bl = get_turf(M)
						if(bl)	//if it can't find a turf for the medibot, then it probably shouldn't be showing up
							bdat += "[M.name] - <b>\[[bl.x],[bl.y]\]</b> - [M.on ? "Online" : "Offline"]<br>"
							if((!isnull(M.reagent_glass)) && M.use_beaker)
								bdat += "Reservoir: \[[M.reagent_glass.reagents.total_volume]/[M.reagent_glass.reagents.maximum_volume]\]<br>"
							else
								bdat += "Using Internal Synthesizer.<br>"
					if(!bdat)
						dat += "<br><center>None detected</center>"
					else
						dat += "<br>[bdat]"

				else
		else
			dat += "<A href='?src=\ref[src];login=1'>Log In</A>"

	var/datum/browser/popup = new(user, "med_rec", "Medical Records")
	popup.set_content("<TT>[dat]</TT>")
	popup.open()

/obj/machinery/computer/med_data/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if (!( data_core.general.Find(src.active1) ))
		src.active1 = null

	if (!( data_core.medical.Find(src.active2) ))
		src.active2 = null

	if (href_list["temp"])
		src.temp = null

	if (href_list["scan"])
		if (src.scan)

			if(ishuman(usr))
				scan.loc = usr.loc

				if(!usr.get_active_hand())
					usr.put_in_hands(scan)

				scan = null

			else
				src.scan.loc = src.loc
				src.scan = null

		else
			var/obj/item/I = usr.get_active_hand()
			if (istype(I, /obj/item/weapon/card/id))
				usr.drop_from_inventory(I, src)
				src.scan = I
				if(ishuman(usr))
					var/mob/living/carbon/human/H = usr
					H.sec_hud_set_ID()
	else if (href_list["logout"])
		src.authenticated = null
		src.screen = null
		src.active1 = null
		src.active2 = null

	else if (href_list["login"])

		if (isAI(usr))
			src.active1 = null
			src.active2 = null
			src.authenticated = usr.name
			src.rank = "AI"
			src.screen = 1

		else if (isrobot(usr))
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

		else if (istype(src.scan, /obj/item/weapon/card/id))
			src.active1 = null
			src.active2 = null

			if (check_access(src.scan))
				src.authenticated = src.scan.registered_name
				src.rank = src.scan.assignment
				src.screen = 1

	if (src.authenticated)

		if(href_list["screen"])
			src.screen = text2num(href_list["screen"])
			if(src.screen < 1)
				src.screen = 1

			src.active1 = null
			src.active2 = null

		if(href_list["vir"])
			var/datum/data/record/v = locate(href_list["vir"])
			src.temp = "<center>GNAv2 based virus lifeform V-[v.fields["id"]]</center>"
			src.temp += "<br><b>Name:</b> <A href='?src=\ref[src];field=vir_name;edit_vir=\ref[v]'>[v.fields["name"]]</A>"
			src.temp += "<br><b>Antigen:</b> [v.fields["antigen"]]"
			src.temp += "<br><b>Spread:</b> [v.fields["spread type"]] "
			src.temp += "<br><b>Details:</b><br> <A href='?src=\ref[src];field=vir_desc;edit_vir=\ref[v]'>[v.fields["description"]]</A>"

		if (href_list["del_all"])
			src.temp = "Are you sure you wish to delete all records?<br>\n\t<A href='?src=\ref[src];temp=1;del_all2=1'>Yes</A><br>\n\t<A href='?src=\ref[src];temp=1'>No</A><br>"

		if (href_list["del_all2"])
			for(var/datum/data/record/R in data_core.medical)
				//R = null
				qdel(R)
				//Foreach goto(494)
			src.temp = "All records deleted."

		if (href_list["field"])
			var/a1 = src.active1
			var/a2 = src.active2
			switch(href_list["field"]) // TODO: what the fuck is this mess
				if("fingerprint")
					if (istype(src.active1, /datum/data/record))
						var/t1 = sanitize(input("Please input fingerprint hash:", "Med. records", input_default(src.active1.fields["fingerprint"]), null)  as text)
						if ((!( t1 ) || !( src.authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || src.active1 != a1 || t1 == src.active1.fields["fingerprint"]))
							return

						src.active1.fields["fingerprint"] = t1
						src.active1.fields["insurance_account_number"] = 0
						src.active1.fields["insurance_type"] = INSURANCE_NONE

				if("insurance_account_number")
					if (istype(src.active1, /datum/data/record))
						var/t1 = input("Please input insurance account number:", "Med. records", input_default(src.active1.fields["insurance_account_number"]), null)  as num
						if ((!( t1 ) || !( src.authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || src.active1 != a1 || t1 == src.active1.fields["insurance_account_number"]))
							return
						var/datum/money_account/MA = get_account(t1)
						if(!MA)
							tgui_alert(usr, "Unable to find this money account.")
							return
						for(var/i in global.department_accounts)
							if(t1 == global.department_accounts[i].account_number)
								tgui_alert(usr, "This is department account, you can't use it.")
								return
						if(MA.owner_name != src.active1.fields["name"])
							tgui_alert(usr, "[src.active1.fields["name"]] is not owner of this money account.")
							return

						var/datum/data/record/R = find_record("insurance_account_number", t1, data_core.general)
						if(R)
							tgui_alert(usr, "This money account is already used by [R.fields["id"]] record.")
							return

						for(var/mob/living/carbon/human/H as anything in global.human_list)
							if(md5(H.dna.uni_identity) != src.active1.fields["fingerprint"])
								continue
							src.active1.fields["insurance_account_number"] = t1

						if(src.active1.fields["insurance_account_number"] != t1)
							tgui_alert(usr, "Can't match the 'fingerprint' data, please check this and try again.")

				if("sex")
					if (istype(src.active1, /datum/data/record))
						if (src.active1.fields["sex"] == "Male")
							src.active1.fields["sex"] = "Female"
						else
							src.active1.fields["sex"] = "Male"
				if("age")
					if (istype(src.active1, /datum/data/record))
						var/t1 = input("Please input age:", "Med. records", src.active1.fields["age"], null)  as num
						if ((!( t1 ) || !( src.authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || src.active1 != a1))
							return
						src.active1.fields["age"] = t1
				if("mi_dis")
					if (istype(src.active2, /datum/data/record))
						var/t1 = sanitize(input("Please input minor disabilities list:", "Med. records", input_default(src.active2.fields["mi_dis"]), null)  as text)
						if ((!( t1 ) || !( src.authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || src.active2 != a2))
							return
						src.active2.fields["mi_dis"] = t1
				if("mi_dis_d")
					if (istype(src.active2, /datum/data/record))
						var/t1 = sanitize(input("Please summarize minor dis.:", "Med. records", input_default(src.active2.fields["mi_dis_d"]), null)  as message)
						if ((!( t1 ) || !( src.authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || src.active2 != a2))
							return
						src.active2.fields["mi_dis_d"] = t1
				if("ma_dis")
					if (istype(src.active2, /datum/data/record))
						var/t1 = sanitize(input("Please input major diabilities list:", "Med. records", input_default(src.active2.fields["ma_dis"]), null)  as text)
						if ((!( t1 ) || !( src.authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || src.active2 != a2))
							return
						src.active2.fields["ma_dis"] = t1
				if("ma_dis_d")
					if (istype(src.active2, /datum/data/record))
						var/t1 = sanitize(input("Please summarize major dis.:", "Med. records", input_default(src.active2.fields["ma_dis_d"]), null)  as message)
						if ((!( t1 ) || !( src.authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || src.active2 != a2))
							return
						src.active2.fields["ma_dis_d"] = t1
				if("alg")
					if (istype(src.active2, /datum/data/record))
						var/t1 = sanitize(input("Please state allergies:", "Med. records", input_default(src.active2.fields["alg"]), null)  as text)
						if ((!( t1 ) || !( src.authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || src.active2 != a2))
							return
						src.active2.fields["alg"] = t1
				if("alg_d")
					if (istype(src.active2, /datum/data/record))
						var/t1 = sanitize(input("Please summarize allergies:", "Med. records", input_default(src.active2.fields["alg_d"]), null)  as message)
						if ((!( t1 ) || !( src.authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || src.active2 != a2))
							return
						src.active2.fields["alg_d"] = t1
				if("cdi")
					if (istype(src.active2, /datum/data/record))
						var/t1 = sanitize(input("Please state diseases:", "Med. records", input_default(src.active2.fields["cdi"]), null)  as text)
						if ((!( t1 ) || !( src.authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || src.active2 != a2))
							return
						src.active2.fields["cdi"] = t1
				if("cdi_d")
					if (istype(src.active2, /datum/data/record))
						var/t1 = sanitize(input("Please summarize diseases:", "Med. records", input_default(src.active2.fields["cdi_d"]), null)  as message)
						if ((!( t1 ) || !( src.authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || src.active2 != a2))
							return
						src.active2.fields["cdi_d"] = t1
				if("notes")
					if (istype(src.active2, /datum/data/record))
						var/t1 = sanitize(input("Please summarize notes:", "Med. records", input_default(src.active2.fields["notes"]), null)  as message)
						if ((!( t1 ) || !( src.authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || src.active2 != a2))
							return
						src.active2.fields["notes"] = t1
				if("p_stat")
					if (istype(src.active1, /datum/data/record))
						src.temp = "<B>Physical Condition:</B><BR>\n\t<A href='?src=\ref[src];temp=1;p_stat=deceased'>*Deceased*</A><BR>\n\t<A href='?src=\ref[src];temp=1;p_stat=ssd'>*SSD*</A><BR>\n\t<A href='?src=\ref[src];temp=1;p_stat=active'>Active</A><BR>\n\t<A href='?src=\ref[src];temp=1;p_stat=unfit'>Physically Unfit</A><BR>\n\t<A href='?src=\ref[src];temp=1;p_stat=disabled'>Disabled</A><BR>"
				if("m_stat")
					if (istype(src.active1, /datum/data/record))
						src.temp = "<B>Mental Condition:</B><BR>\n\t<A href='?src=\ref[src];temp=1;m_stat=insane'>*Insane*</A><BR>\n\t<A href='?src=\ref[src];temp=1;m_stat=unstable'>*Unstable*</A><BR>\n\t<A href='?src=\ref[src];temp=1;m_stat=watch'>*Watch*</A><BR>\n\t<A href='?src=\ref[src];temp=1;m_stat=stable'>Stable</A><BR>"
				if("b_type")
					if (istype(src.active2, /datum/data/record))
						src.temp = "<B>Blood Type:</B><BR>\n\t<A href='?src=\ref[src];temp=1;b_type=an'>[BLOOD_A_MINUS]</A> <A href='?src=\ref[src];temp=1;b_type=ap'>[BLOOD_A_PLUS]</A><BR>\n\t<A href='?src=\ref[src];temp=1;b_type=bn'>[BLOOD_B_MINUS]</A> <A href='?src=\ref[src];temp=1;b_type=bp'>[BLOOD_B_PLUS]</A><BR>\n\t<A href='?src=\ref[src];temp=1;b_type=abn'>[BLOOD_AB_MINUS]</A> <A href='?src=\ref[src];temp=1;b_type=abp'>[BLOOD_AB_PLUS]</A><BR>\n\t<A href='?src=\ref[src];temp=1;b_type=on'>[BLOOD_O_MINUS]</A> <A href='?src=\ref[src];temp=1;b_type=op'>[BLOOD_O_PLUS]</A><BR>"
				if("b_dna")
					if (istype(src.active1, /datum/data/record))
						var/t1 = sanitize(input("Please input DNA hash:", "Med. records", input_default(src.active1.fields["dna"]), null)  as text)
						if ((!( t1 ) || !( src.authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || src.active1 != a1))
							return
						src.active1.fields["dna"] = t1
				if("vir_name")
					var/datum/data/record/v = locate(href_list["edit_vir"])
					if (v)
						var/t1 = sanitize(input("Please input pathogen name:", "VirusDB", input_default(v.fields["name"]), null)  as text)
						if ((!( t1 ) || !( src.authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || src.active1 != a1))
							return
						v.fields["name"] = t1
				if("vir_desc")
					var/datum/data/record/v = locate(href_list["edit_vir"])
					if (v)
						var/t1 = sanitize(input("Please input information about pathogen:", "VirusDB", input_default(v.fields["description"]), null)  as message)
						if ((!( t1 ) || !( src.authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || src.active1 != a1))
							return
						v.fields["description"] = t1
				else

		if (href_list["p_stat"])
			if (src.active1)
				switch(href_list["p_stat"])
					if("deceased")
						src.active1.fields["p_stat"] = "*Deceased*"
					if("ssd")
						src.active1.fields["p_stat"] = "*SSD*"
					if("active")
						src.active1.fields["p_stat"] = "Active"
					if("unfit")
						src.active1.fields["p_stat"] = "Physically Unfit"
					if("disabled")
						src.active1.fields["p_stat"] = "Disabled"
				PDA_Manifest.Cut()

		if (href_list["m_stat"])
			if (src.active1)
				switch(href_list["m_stat"])
					if("insane")
						src.active1.fields["m_stat"] = "*Insane*"
					if("unstable")
						src.active1.fields["m_stat"] = "*Unstable*"
					if("watch")
						src.active1.fields["m_stat"] = "*Watch*"
					if("stable")
						src.active1.fields["m_stat"] = "Stable"


		if (href_list["b_type"])
			if (src.active2)
				switch(href_list["b_type"])
					if("an")
						src.active2.fields["b_type"] = BLOOD_A_MINUS
					if("bn")
						src.active2.fields["b_type"] = BLOOD_B_MINUS
					if("abn")
						src.active2.fields["b_type"] = BLOOD_AB_MINUS
					if("on")
						src.active2.fields["b_type"] = BLOOD_O_MINUS
					if("ap")
						src.active2.fields["b_type"] = BLOOD_A_PLUS
					if("bp")
						src.active2.fields["b_type"] = BLOOD_B_PLUS
					if("abp")
						src.active2.fields["b_type"] = BLOOD_AB_PLUS
					if("op")
						src.active2.fields["b_type"] = BLOOD_O_PLUS


		if (href_list["del_r"])
			if (src.active2)
				src.temp = "Are you sure you wish to delete the record (Medical Portion Only)?<br>\n\t<A href='?src=\ref[src];temp=1;del_r2=1'>Yes</A><br>\n\t<A href='?src=\ref[src];temp=1'>No</A><br>"

		if (href_list["del_r2"])
			if (src.active2)
				//src.active2 = null
				qdel(src.active2)

		if (href_list["d_rec"])
			var/datum/data/record/R = locate(href_list["d_rec"])
			var/datum/data/record/M = locate(href_list["d_rec"])
			if (!( data_core.general.Find(R) ))
				src.temp = "Record Not Found!"
				return
			for(var/datum/data/record/E in data_core.medical)
				if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
					M = E
				else
					//Foreach continue //goto(2540)
			src.active1 = R
			src.active2 = M
			src.screen = 4

		if (href_list["new"])
			if ((istype(src.active1, /datum/data/record) && !( istype(src.active2, /datum/data/record) )))
				var/datum/data/record/R = new /datum/data/record(  )
				R.fields["name"] = src.active1.fields["name"]
				R.fields["id"] = src.active1.fields["id"]
				R.name = "Medical Record #[R.fields["id"]]"
				R.fields["b_type"] = "Unknown"
				R.fields["b_dna"] = "Unknown"
				R.fields["mi_dis"] = "None"
				R.fields["mi_dis_d"] = "No minor disabilities have been declared."
				R.fields["ma_dis"] = "None"
				R.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
				R.fields["alg"] = "None"
				R.fields["alg_d"] = "No allergies have been detected in this patient."
				R.fields["cdi"] = "None"
				R.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
				R.fields["notes"] = "No notes."
				data_core.medical += R
				src.active2 = R
				src.screen = 4

		if (href_list["add_c"])
			if (!( istype(src.active2, /datum/data/record) ))
				return
			var/a2 = src.active2
			var/t1 = sanitize(input("Add Comment:", "Med. records", null, null)  as message)
			if ((!( t1 ) || !( src.authenticated ) || usr.incapacitated() || (!Adjacent(usr) && !issilicon(usr) && !isobserver(usr)) || src.active2 != a2))
				return
			var/counter = 1
			while(src.active2.fields["com_[counter]"])
				counter++
			src.active2.fields["com_[counter]"] = "Made by [authenticated] ([rank]) on [worldtime2text()], [time2text(world.realtime, "DD/MM")]/[game_year]<BR>[t1]"

		if (href_list["del_c"])
			if ((istype(src.active2, /datum/data/record) && src.active2.fields["com_[href_list["del_c"]]"]))
				src.active2.fields["com_[href_list["del_c"]]"] = "<B>Deleted</B>"

		if (href_list["search"])
			var/t1 = sanitize(input("Search String: (Name, DNA, or ID)", "Med. records", null, null)  as text)
			if ((!( t1 ) || !( src.authenticated ) || usr.incapacitated() || ((!Adjacent(usr)) && !issilicon(usr) && !isobserver(usr))))
				return
			src.active1 = null
			src.active2 = null
			t1 = lowertext(t1)
			for(var/datum/data/record/R in data_core.medical)
				if ((lowertext(R.fields["name"]) == t1 || t1 == lowertext(R.fields["id"]) || t1 == lowertext(R.fields["b_dna"])))
					src.active2 = R
				else
					//Foreach continue //goto(3229)
			if (!( src.active2 ))
				src.temp = "Could not locate record [t1]."
			else
				for(var/datum/data/record/E in data_core.general)
					if ((E.fields["name"] == src.active2.fields["name"] || E.fields["id"] == src.active2.fields["id"]))
						src.active1 = E
					else
						//Foreach continue //goto(3334)
				src.screen = 4
//PRINTING
		if (href_list["print_p"])
			if(next_print > world.time)
				return
			var/datum/data/record/record1 = null
			var/datum/data/record/record2 = null
			if ((istype(src.active1, /datum/data/record) && data_core.general.Find(src.active1)))
				record1 = active1
			if ((istype(src.active2, /datum/data/record) && data_core.medical.Find(src.active2)))
				record2 = active2
			var/info = "<CENTER><B>Medical Record</B></CENTER><BR>"
			if (record1)
				info += text(
					"Name: [] ID: []<BR>\nSex: []<BR>\nAge: []<BR>\nFingerprint: []<BR>\n<BR>Insurance Account Number: []<BR>\nInsurance Type: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>",
					record1.fields["name"],
					record1.fields["id"],
					record1.fields["sex"],
					record1.fields["age"],
					record1.fields["fingerprint"],
					record1.fields["insurance_account_number"],
					record1.fields["insurance_type"],
					record1.fields["p_stat"],
					record1.fields["m_stat"]
				)
				docname = "Medical Record ([record1.fields["name"]])"
			else
				info += "<B>General Record Lost!</B><BR>"
				docname = "Medical Record"
			if (record2)
				info += text(
					"<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: []<BR>\nDNA: []<BR>\n<BR>\nMinor Disabilities: []<BR>\nDetails: []<BR>\n<BR>\nMajor Disabilities: []<BR>\nDetails: []<BR>\n<BR>\nAllergies: []<BR>\nDetails: []<BR>\n<BR>\nCurrent Diseases: [] (per disease info placed in log/comment section)<BR>\nDetails: []<BR>\n<BR>\nImportant Notes:<BR>\n\t[]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>",
					record2.fields["b_type"],
					record2.fields["b_dna"],
					record2.fields["mi_dis"],
					record2.fields["mi_dis_d"],
					record2.fields["ma_dis"],
					record2.fields["ma_dis_d"],
					record2.fields["alg"],
					record2.fields["alg_d"],
					record2.fields["cdi"],
					record2.fields["cdi_d"],
					decode(record2.fields["notes"])
				)
				var/counter = 1
				while(record2.fields["com_[counter]"])
					info += "[record2.fields["com_[counter]"]]<BR>"
					counter++
			else
				info += "<B>Medical Record Lost!</B><BR>"
			info += "</TT>"
			print_document(info, docname)
			next_print = world.time + 50

		if (href_list["print_photos"])
			if(next_print > world.time)
				return
			if (istype(active1, /datum/data/record) && data_core.general.Find(active1))
				var/datum/data/record/photo = active1
				photo.fields["image"] = photo.fields["photo_f"]
				docname = "Medical Record's photo"
				photo.fields["author"] = usr
				photo.fields["icon"] = icon('icons/obj/mugshot.dmi',"photo")
				photo.fields["small_icon"] = icon('icons/obj/mugshot.dmi',"small_photo")
				if(istype(active1.fields["photo_f"], /icon))
					print_photo(photo, docname)
				if(istype(active1.fields["photo_s"], /icon))
					photo.fields["image"] = active1.fields["photo_s"]
					print_photo(photo, docname)
				next_print = world.time + 50
	updateUsrDialog()

/obj/machinery/computer/med_data/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	for(var/datum/data/record/R in data_core.medical)
		if(prob(10/severity))
			switch(rand(1,6))
				if(1)
					R.fields["name"] = "[pick(pick(first_names_male), pick(first_names_female))] [pick(last_names)]"
				if(2)
					R.fields["sex"]	= pick("Male", "Female")
				if(3)
					R.fields["age"] = rand(5, 85)
				if(4)
					R.fields["b_type"] = random_blood_type()
				if(5)
					R.fields["p_stat"] = pick("*SSD*", "Active", "Physically Unfit", "Disabled")
				if(6)
					R.fields["m_stat"] = pick("*Insane*", "*Unstable*", "*Watch*", "Stable")
			continue

		else if(prob(1))
			qdel(R)
			continue

	..(severity)


/obj/machinery/computer/med_data/laptop
	name = "Medical Laptop"
	desc = "Cheap Nanotrasen Laptop."
	icon_state = "laptop_med"
	state_broken_preset = "laptopb"
	state_nopower_preset = "laptop0"
	light_color = "#00b000"
