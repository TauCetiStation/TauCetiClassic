/datum/admins/Topic(href, href_list)
	..()

	if(usr.client != src.owner || !check_rights(0))
		log_admin("[key_name(usr)] tried to use the admin panel without authorization.")
		message_admins("[key_name_admin(usr)] has attempted to override the admin panel!")
		return

	if(SSticker.mode && SSticker.mode.check_antagonists_topic(href, href_list))
		check_antagonists()
		return

	if(href_list["ahelp"])
		if(!check_rights(R_ADMIN, TRUE))
			return

		var/ahelp_ref = href_list["ahelp"]
		var/datum/admin_help/AH = locate(ahelp_ref)
		if(AH)
			AH.Action(href_list["ahelp_action"])
		else
			to_chat(usr, "Ticket [ahelp_ref] has been deleted!")
		return

	if(href_list["ahelp_tickets"])
		global.ahelp_tickets.BrowseTickets(text2num(href_list["ahelp_tickets"]))
		return

	if(href_list["stickyban"])
		stickyban(href_list["stickyban"], href_list)
		if (href_list["stickyban"] != "show") // Update window after action
			stickyban("show", null)

	if(href_list["makeAntag"])
		switch(href_list["makeAntag"])
			if("1")
				log_admin("[key_name(usr)] has spawned a traitor.")
				if(!src.makeTraitors())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("2")
				log_admin("[key_name(usr)] has spawned a changeling.")
				if(!src.makeChanglings())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("3")
				log_admin("[key_name(usr)] has spawned revolutionaries.")
				if(!src.makeRevs())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("4")
				log_admin("[key_name(usr)] has spawned a cultists.")
				if(!src.makeCult())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("5")
				log_admin("[key_name(usr)] has spawned a malf AI.")
				if(!src.makeMalfAImode())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("6")
				log_admin("[key_name(usr)] has spawned a wizard.")
				if(!src.makeWizard())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("7")
				log_admin("[key_name(usr)] has spawned a nuke team.")
				if(!src.makeNukeTeam())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			/*
			if("8")
				log_admin("[key_name(usr)] has spawned a ninja.")
				src.makeSpaceNinja()
			if("9")
				log_admin("[key_name(usr)] has spawned aliens.")
				src.makeAliens()
			*/
			if("10")
				log_admin("[key_name(usr)] has spawned a death squad.")
			if("11")
				log_admin("[key_name(usr)] has spawned vox raiders.")
				if(!src.makeVoxRaiders())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("12")
				message_admins("[key_name(usr)] started a gang war.")
				log_admin("[key_name(usr)] started a gang war.")
				if(!src.makeGangsters())
					to_chat(usr, "<span class='danger'>Unfortunatly there were not enough candidates available.</span>")

	else if(href_list["dbsearchckey"] || href_list["dbsearchadmin"] || href_list["dbsearchip"] || href_list["dbsearchcid"] || href_list["dbsearchbantype"])
		var/adminckey = href_list["dbsearchadmin"]
		var/playerckey = href_list["dbsearchckey"]
		var/playerip = href_list["dbsearchip"]
		var/playercid = href_list["dbsearchcid"]
		var/dbbantype = text2num(href_list["dbsearchbantype"])
		var/match = 0

		if("dbmatch" in href_list)
			match = 1

		DB_ban_panel(playerckey, adminckey, playerip, playercid, dbbantype, match)
		return

	else if(href_list["dbbanedit"])
		var/banedit = href_list["dbbanedit"]
		var/banid = text2num(href_list["dbbanid"])
		if(!banedit || !banid)
			return

		DB_ban_edit(banid, banedit)
		return

	else if(href_list["dbbanaddtype"])

		var/bantype = text2num(href_list["dbbanaddtype"])
		var/banckey = href_list["dbbanaddckey"]
		var/banip = href_list["dbbanaddip"]
		var/bancid = href_list["dbbanaddcid"]
		var/banduration = text2num(href_list["dbbaddduration"])
		var/banjob = href_list["dbbanaddjob"]
		var/banreason = sanitize(href_list["dbbanreason"])

		banckey = ckey(banckey)

		switch(bantype)
			if(BANTYPE_PERMA)
				if(!banckey || !banreason)
					to_chat(usr, "Not enough parameters (Requires ckey and reason)")
					return
				banduration = null
				banjob = null
			if(BANTYPE_TEMP)
				if(!banckey || !banreason || !banduration)
					to_chat(usr, "Not enough parameters (Requires ckey, reason and duration)")
					return
				banjob = null
			if(BANTYPE_JOB_PERMA)
				if(!banckey || !banreason || !banjob)
					to_chat(usr, "Not enough parameters (Requires ckey, reason and job)")
					return
				banduration = null
			if(BANTYPE_JOB_TEMP)
				if(!banckey || !banreason || !banjob || !banduration)
					to_chat(usr, "Not enough parameters (Requires ckey, reason and job)")
					return

		var/mob/playermob

		for(var/mob/M in player_list)
			if(M.ckey == banckey)
				playermob = M
				break


		banreason = "(MANUAL BAN) "+banreason

		if(!playermob)
			if(banip)
				banreason = "[banreason] (CUSTOM IP)"
			if(bancid)
				banreason = "[banreason] (CUSTOM CID)"
		else
			message_admins("Ban process: A mob matching [playermob.ckey] was found at location [playermob.x], [playermob.y], [playermob.z]. Custom ip and computer id fields replaced with the ip and computer id from the located mob")

		DB_ban_record(bantype, playermob, banduration, banreason, banjob, null, banckey, banip, bancid )

	else if(href_list["editrights"])
		if(!check_rights(R_PERMISSIONS))
			message_admins("[key_name_admin(usr)] attempted to edit the admin permissions without sufficient rights.")
			log_admin("[key_name(usr)] attempted to edit the admin permissions without sufficient rights.")
			return
		var/target_ckey = ckey(href_list["ckey"])
		var/task = href_list["editrights"]
		if(!task)
			return
		switch(task)
			if("add")
				var/response = alert(usr, "Who do you want to add?","Message","Admin","Mentor","Cancel")
				switch(response)
					if("Admin")
						add_admin()
					if("Mentor")
						add_mentor()
					else
						return
			if("remove_admin")
				remove_admin(target_ckey)
			if("remove_mentor")
				remove_mentor(target_ckey)
			if("rank")
				edit_rank(target_ckey)
			if("permissions")
				var/new_rights = text2num(href_list["new_rights"])
				change_permissions(target_ckey, new_rights)
				usr << browse(null,"window=change_permissions;")
			if("get_new_rights")
				get_new_rights(target_ckey)
				return
		edit_admin_permissions()

	else if(href_list["whitelist"])
		if(!check_rights(R_ADMIN))
			return

		var/target_ckey = ckey(href_list["ckey"])
		var/task = href_list["whitelist"]
		if(!task)
			return
		var/role = href_list["role"]

		switch(task)
			if("add_user")
				whitelist_add_user()
			if("add_role")
				whitelist_add_role(target_ckey)
			if("showroles")
				whitelist_view(target_ckey)
			if("edit_ban")
				whitelist_edit(target_ckey, role, ban_edit = TRUE)
			if("edit_reason")
				whitelist_edit(target_ckey, role)

	else if(href_list["custom_items"])
		if(!check_rights(R_PERMISSIONS))
			return

		var/target_ckey = ckey(href_list["ckey"])
		var/task = href_list["custom_items"]
		var/index = href_list["index"]
		if(!task)
			return

		switch(task)
			if("add")
				customs_items_add()
			if("addckey")
				customs_items_add(target_ckey)
			if("history")
				customs_items_history(target_ckey)
			if("history_remove")
				index = text2num(index)
				customs_items_remove(target_ckey, index)
			if("moderation_view")
				var/itemname = href_list["itemname"]
				editing_item_list[usr.ckey] = get_custom_item(target_ckey, itemname)
				if(editing_item_list[usr.ckey])
					edit_custom_item_panel(null, usr, readonly = TRUE, adminview = TRUE)
			if("moderation_accept")
				var/itemname = href_list["itemname"]
				custom_item_premoderation_accept(target_ckey, itemname)
				if(href_list["viewthis"])
					customitemsview_panel(target_ckey)
				else
					customitemspremoderation_panel()
			if("moderation_reject")
				var/itemname = href_list["itemname"]

				var/reason = sanitize(input("Write reason for item rejection or leave empty for no reason","Text") as null|text)

				custom_item_premoderation_reject(target_ckey, itemname, reason)
				if(href_list["viewthis"])
					customitemsview_panel(target_ckey)
				else
					customitemspremoderation_panel()
			if("moderation_viewbyckey")
				var/viewckey = ckey(input("Enter player ckey","Text") as null|text)
				if(viewckey)
					customitemsview_panel(viewckey)
			if("moderation_viewpremoderation")
				customitemspremoderation_panel()

	else if(href_list["call_shuttle"])
		if(!check_rights(R_ADMIN))
			return

		if( SSticker.mode.name == "blob" )
			alert("You can't call the shuttle during blob!")
			return

		switch(href_list["call_shuttle"])
			if("1")
				if ((!( SSticker ) || SSshuttle.location))
					return
				SSshuttle.incall()
				captain_announce("The emergency shuttle has been called. It will arrive in [shuttleminutes2text()] minutes.", sound = "emer_shut_called")
				log_admin("[key_name(usr)] called the Emergency Shuttle")
				message_admins("<span class='notice'>[key_name_admin(usr)] called the Emergency Shuttle to the station</span>")
				make_maint_all_access(FALSE)

			if("2")
				if ((!( SSticker ) || SSshuttle.location || SSshuttle.direction == 0))
					return
				switch(SSshuttle.direction)
					if(-1)
						SSshuttle.incall()
						captain_announce("The emergency shuttle has been called. It will arrive in [shuttleminutes2text()] minutes.", sound = "emer_shut_called")
						log_admin("[key_name(usr)] called the Emergency Shuttle")
						message_admins("<span class='notice'>[key_name_admin(usr)] called the Emergency Shuttle to the station</span>")
						make_maint_all_access(FALSE)
					if(1)
						SSshuttle.recall()
						log_admin("[key_name(usr)] sent the Emergency Shuttle back")
						message_admins("<span class='notice'>[key_name_admin(usr)] sent the Emergency Shuttle back</span>")
						if(timer_maint_revoke_id)
							deltimer(timer_maint_revoke_id)
							timer_maint_revoke_id = 0
						timer_maint_revoke_id = addtimer(CALLBACK(GLOBAL_PROC, .proc/revoke_maint_all_access, FALSE), 600, TIMER_UNIQUE|TIMER_STOPPABLE)

		href_list["secretsadmin"] = "check_antagonist"

	else if(href_list["edit_shuttle_time"])
		if(!check_rights(R_SERVER))	return

		SSshuttle.settimeleft( input("Enter new shuttle duration (seconds):","Edit Shuttle Timeleft", SSshuttle.timeleft() ) as num )
		log_admin("[key_name(usr)] edited the Emergency Shuttle's timeleft to [SSshuttle.timeleft()]")
		captain_announce("The emergency shuttle has been called. It will arrive in [shuttleminutes2text()] minutes.", sound = "emer_shut_called")
		message_admins("<span class='notice'>[key_name_admin(usr)] edited the Emergency Shuttle's timeleft to [SSshuttle.timeleft()]</span>")
		href_list["secretsadmin"] = "check_antagonist"

	else if(href_list["delay_round_end"])
		if(!check_rights(R_SERVER))	return

		SSticker.delay_end = !SSticker.delay_end
		log_admin("[key_name(usr)] [SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
		message_admins("[key_name(usr)] [SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
		world.send2bridge(
			type = list(BRIDGE_ROUNDSTAT),
			attachment_msg = "**[key_name(usr)]** [SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].",
			attachment_color = BRIDGE_COLOR_ROUNDSTAT,
		)
		href_list["secretsadmin"] = "check_antagonist"

	else if(href_list["simplemake"])
		if(!check_rights(R_SPAWN))	return

		var/mob/M = locate(href_list["mob"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		var/delmob = 0
		switch(alert("Delete old mob?","Message","Yes","No","Cancel"))
			if("Cancel")	return
			if("Yes")		delmob = 1

		log_admin("[key_name(usr)] has used rudimentary transformation on [key_name(M)]. Transforming to [href_list["simplemake"]]; deletemob=[delmob]")
		message_admins("[key_name_admin(usr)] has used rudimentary transformation on [key_name_admin(M)]. Transforming to [href_list["simplemake"]]; deletemob=[delmob]")

		switch(href_list["simplemake"])
			if("observer")			M.change_mob_type( /mob/dead/observer , null, null, delmob )
			if("drone")				M.change_mob_type( /mob/living/carbon/xenomorph/humanoid/drone , null, null, delmob )
			if("hunter")			M.change_mob_type( /mob/living/carbon/xenomorph/humanoid/hunter , null, null, delmob )
			if("queen")				M.change_mob_type( /mob/living/carbon/xenomorph/humanoid/queen , null, null, delmob )
			if("sentinel")			M.change_mob_type( /mob/living/carbon/xenomorph/humanoid/sentinel , null, null, delmob )
			if("larva")				M.change_mob_type( /mob/living/carbon/xenomorph/larva , null, null, delmob )
			if("human")				M.change_mob_type( /mob/living/carbon/human , null, null, delmob )
			if("slime")			M.change_mob_type( /mob/living/carbon/slime , null, null, delmob )
			if("adultslime")		M.change_mob_type( /mob/living/carbon/slime/adult , null, null, delmob )
			if("monkey")			M.change_mob_type( /mob/living/carbon/monkey , null, null, delmob )
			if("robot")				M.change_mob_type( /mob/living/silicon/robot , null, null, delmob )
			if("cat")				M.change_mob_type( /mob/living/simple_animal/cat , null, null, delmob )
			if("runtime")			M.change_mob_type( /mob/living/simple_animal/cat/Runtime , null, null, delmob )
			if("corgi")				M.change_mob_type( /mob/living/simple_animal/corgi , null, null, delmob )
			if("crab")				M.change_mob_type( /mob/living/simple_animal/crab , null, null, delmob )
			if("coffee")			M.change_mob_type( /mob/living/simple_animal/crab/Coffee , null, null, delmob )
			if("parrot")			M.change_mob_type( /mob/living/simple_animal/parrot , null, null, delmob )
			if("polyparrot")		M.change_mob_type( /mob/living/simple_animal/parrot/Poly , null, null, delmob )
			if("constructarmoured")	M.change_mob_type( /mob/living/simple_animal/construct/armoured , null, null, delmob )
			if("constructbuilder")	M.change_mob_type( /mob/living/simple_animal/construct/builder , null, null, delmob )
			if("constructwraith")	M.change_mob_type( /mob/living/simple_animal/construct/wraith , null, null, delmob )
			if("shade")				M.change_mob_type( /mob/living/simple_animal/shade , null, null, delmob )
			if("meme")
				var/mob/living/parasite/meme/newmeme = new
				M.mind.transfer_to(newmeme)
				newmeme.clearHUD()

				var/found = 0
				for(var/mob/living/carbon/human/H in human_list) if(H.client && !H.parasites.len)
					found = 1
					newmeme.enter_host(H)

					message_admins("[H] has become [newmeme.key]'s host")

					break

				// if there was no host, abort
				if(!found)
					newmeme.mind.transfer_to(M)
					message_admins("Failed to find host for meme [M.key]. Aborting.")

				SSticker.mode.memes += newmeme

				if(delmob)
					qdel(M)


	/////////////////////////////////////new ban stuff
	else if(href_list["unbanf"])
		if(!check_rights(R_BAN))	return

		var/banfolder = href_list["unbanf"]
		Banlist.cd = "/base/[banfolder]"
		var/key = Banlist["key"]
		if(alert(usr, "Are you sure you want to unban [key]?", "Confirmation", "Yes", "No") == "Yes")
			if(RemoveBan(banfolder))
				unbanpanel()
			else
				alert(usr, "This ban has already been lifted / does not exist.", "Error", "Ok")
				unbanpanel()

	else if(href_list["warn"])
		usr.client.warn(href_list["warn"])

	else if(href_list["unbane"])
		if(!check_rights(R_BAN))	return

		UpdateTime()
		var/reason

		var/banfolder = href_list["unbane"]
		Banlist.cd = "/base/[banfolder]"
		var/reason2 = Banlist["reason"]
		var/temp = Banlist["temp"]

		var/minutes = Banlist["minutes"]

		var/banned_key = Banlist["key"]
		Banlist.cd = "/base"

		var/duration

		switch(alert("Temporary Ban?",,"Yes","No"))
			if("Yes")
				temp = 1
				var/mins = 0
				if(minutes > CMinutes)
					mins = minutes - CMinutes
				mins = input(usr,"How long (in minutes)? (Default: 1440)","Ban time",mins ? mins : 1440) as num|null
				if(!mins)	return
				mins = min(525599,mins)
				minutes = CMinutes + mins
				duration = GetExp(minutes)
				reason = sanitize(input(usr,"Reason?","reason",reason2) as text|null)
				if(!reason)	return
			if("No")
				temp = 0
				duration = "Perma"
				reason = sanitize(input(usr,"Reason?","reason",reason2) as text|null)
				if(!reason)	return

		log_admin("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]")
		ban_unban_log_save("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]")
		message_admins("<span class='notice'>[key_name_admin(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]</span>")
		Banlist.cd = "/base/[banfolder]"
		Banlist["reason"] << reason
		Banlist["temp"] << temp
		Banlist["minutes"] << minutes
		Banlist["bannedby"] << usr.ckey
		Banlist.cd = "/base"
		feedback_inc("ban_edit",1)
		unbanpanel()

	/////////////////////////////////////new ban stuff

	else if(href_list["jobban2"])
//		if(!check_rights(R_BAN))	return

		var/mob/M = locate(href_list["jobban2"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(!M.ckey)	//sanity
			to_chat(usr, "This mob has no ckey")
			return
		if(!SSjob)
			to_chat(usr, "Job Master has not been setup!")
			return

		var/jobs = ""

	/***********************************WARNING!************************************
				      The jobban stuff looks mangled and disgusting
						      But it looks beautiful in-game
						                -Nodrak
	************************************WARNING!***********************************/
		var/counter = 0
//Regular jobs
	//Command (Blue)
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr align='center' bgcolor='ccccff'><th colspan='[length(command_positions)]'><a href='?src=\ref[src];jobban3=commanddept;jobban4=\ref[M]'>Command Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in command_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjob.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 6) //So things dont get squiiiiished!
				jobs += "</tr><tr>"
				counter = 0
		jobs += "</tr></table>"

	//Security (Red)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffddf0'><th colspan='[length(security_positions)]'><a href='?src=\ref[src];jobban3=securitydept;jobban4=\ref[M]'>Security Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in security_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjob.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Engineering (Yellow)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='fff5cc'><th colspan='[length(engineering_positions)]'><a href='?src=\ref[src];jobban3=engineeringdept;jobban4=\ref[M]'>Engineering Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in engineering_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjob.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Medical (White)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffeef0'><th colspan='[length(medical_positions)]'><a href='?src=\ref[src];jobban3=medicaldept;jobban4=\ref[M]'>Medical Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in medical_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjob.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Science (Purple)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='e79fff'><th colspan='[length(science_positions)]'><a href='?src=\ref[src];jobban3=sciencedept;jobban4=\ref[M]'>Science Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in science_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjob.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Civilian (Grey)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='dddddd'><th colspan='[length(civilian_positions)]'><a href='?src=\ref[src];jobban3=civiliandept;jobban4=\ref[M]'>Civilian Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in civilian_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjob.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0

		jobs += "</tr></table>"

	//Non-Human (Green)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ccffcc'><th colspan='[length(nonhuman_positions) + 4]'><a href='?src=\ref[src];jobban3=nonhumandept;jobban4=\ref[M]'>Non-human Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in nonhuman_positions)
			if(!jobPos)	continue
			var/datum/job/job = SSjob.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0

		if(jobban_isbanned(M, ROLE_DRONE))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_DRONE];jobban4=\ref[M]'><font color=red>[ROLE_DRONE]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_DRONE];jobban4=\ref[M]'>[ROLE_DRONE]</a></td>"

		//pAI isn't technically a job, but it goes in here.

		if(jobban_isbanned(M, ROLE_PAI))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_PAI];jobban4=\ref[M]'><font color=red>[ROLE_PAI]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_PAI];jobban4=\ref[M]'>[ROLE_PAI]</a></td>"

		//Observer is no job and probably not at all human still there's no better place.

		if(jobban_isbanned(M, "Observer"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Observer;jobban4=\ref[M]'><font color=red>Observer</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Observer;jobban4=\ref[M]'>Observer</a></td>"

		if(jobban_isbanned(M, "AntagHUD"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=AntagHUD;jobban4=\ref[M]'><font color=red>AntagHUD</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=AntagHUD;jobban4=\ref[M]'>AntagHUD</a></td>"

/*
	//Clown&Mime
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='dddddd'><th colspan='[length(entertaiment_positions)]'><a href='?src=\ref[src];jobban3=entertaimentdept;jobban4=\ref[M]'>Entertaiment Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in entertaiment_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>" */

	//Antagonist (Orange)
		var/isbanned_dept = jobban_isbanned(M, "Syndicate")
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffeeaa'><th colspan='10'><a href='?src=\ref[src];jobban3=Syndicate;jobban4=\ref[M]'>Antagonist Positions</a></th></tr><tr align='center'>"

		//Traitor
		if(jobban_isbanned(M, ROLE_TRAITOR) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_TRAITOR];jobban4=\ref[M]'><font color=red>[ROLE_TRAITOR]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_TRAITOR];jobban4=\ref[M]'>[ROLE_TRAITOR]</a></td>"

		//Changeling
		if(jobban_isbanned(M, ROLE_CHANGELING) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_CHANGELING];jobban4=\ref[M]'><font color=red>[ROLE_CHANGELING]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_CHANGELING];jobban4=\ref[M]'>[ROLE_CHANGELING]</a></td>"

		//Nuke Operative
		if(jobban_isbanned(M, ROLE_OPERATIVE) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_OPERATIVE];jobban4=\ref[M]'><font color=red>[ROLE_OPERATIVE]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_OPERATIVE];jobban4=\ref[M]'>[ROLE_OPERATIVE]</a></td>"

		//Revolutionary
		if(jobban_isbanned(M, ROLE_REV) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_REV];jobban4=\ref[M]'><font color=red>[ROLE_REV]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_REV];jobban4=\ref[M]'>[ROLE_REV]</a></td>"

		//Raider (New heist)
		if(jobban_isbanned(M, ROLE_RAIDER) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_RAIDER];jobban4=\ref[M]'><font color=red>[ROLE_RAIDER]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_RAIDER];jobban4=\ref[M]'>[ROLE_RAIDER]</a></td>"

		jobs += "</tr><tr align='center'>" //Breaking it up so it fits nicer on the screen every 5 entries

		//Cultist
		if(jobban_isbanned(M, ROLE_CULTIST) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_CULTIST];jobban4=\ref[M]'><font color=red>[ROLE_CULTIST]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_CULTIST];jobban4=\ref[M]'>[ROLE_CULTIST]</a></td>"

		//Wizard
		if(jobban_isbanned(M, ROLE_WIZARD) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_WIZARD];jobban4=\ref[M]'><font color=red>[ROLE_WIZARD]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_WIZARD];jobban4=\ref[M]'>[ROLE_WIZARD]</a></td>"

		//ERT
		if(jobban_isbanned(M, ROLE_ERT) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_ERT];jobban4=\ref[M]'><font color=red>[ROLE_ERT]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_ERT];jobban4=\ref[M]'>[ROLE_ERT]</a></td>"

		//Meme
		if(jobban_isbanned(M, ROLE_MEME) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_MEME];jobban4=\ref[M]'><font color=red>[ROLE_MEME]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_MEME];jobban4=\ref[M]'>[ROLE_MEME]</a></td>"

		//Mutineer
		if(jobban_isbanned(M, ROLE_MUTINEER) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_MUTINEER];jobban4=\ref[M]'><font color=red>[ROLE_MUTINEER]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_MUTINEER];jobban4=\ref[M]'>[ROLE_MUTINEER]</a></td>"

		jobs += "</tr><tr align='center'>" //Breaking it up so it fits nicer on the screen every 5 entries

		//Shadowling
		if(jobban_isbanned(M, ROLE_SHADOWLING) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_SHADOWLING];jobban4=\ref[M]'><font color=red>[ROLE_SHADOWLING]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_SHADOWLING];jobban4=\ref[M]'>[ROLE_SHADOWLING]</a></td>"

		//Abductor
		if(jobban_isbanned(M, ROLE_ABDUCTOR) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_ABDUCTOR];jobban4=\ref[M]'><font color=red>[ROLE_ABDUCTOR]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_ABDUCTOR];jobban4=\ref[M]'>[ROLE_ABDUCTOR]</a></td>"

		//Ninja
		if(jobban_isbanned(M, ROLE_NINJA) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_NINJA];jobban4=\ref[M]'><font color=red>[ROLE_NINJA]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_NINJA];jobban4=\ref[M]'>[ROLE_NINJA]</a></td>"

		//Blob
		if(jobban_isbanned(M, ROLE_BLOB) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_BLOB];jobban4=\ref[M]'><font color=red>[ROLE_BLOB]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_BLOB];jobban4=\ref[M]'>[ROLE_BLOB]</a></td>"

		//Malfunctioning AI
		if(jobban_isbanned(M, ROLE_MALF) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_MALF];jobban4=\ref[M]'><font color=red>[ROLE_MALF]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_MALF];jobban4=\ref[M]'>[ROLE_MALF]</a></td>"

		jobs += "</tr><tr align='center'>" //Breaking it up so it fits nicer on the screen every 5 entries

		//Xenomorph
		if(jobban_isbanned(M, ROLE_ALIEN) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_ALIEN];jobban4=\ref[M]'><font color=red>[ROLE_ALIEN]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_ALIEN];jobban4=\ref[M]'>[ROLE_ALIEN]</a></td>"

		jobs += "</tr></table>"

		//Other races  (BLUE, because I have no idea what other color to make this)
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ccccff'><th colspan='3'>Other Races</th></tr><tr align='center'>"

		if(jobban_isbanned(M, ROLE_PLANT))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_PLANT];jobban4=\ref[M]'><font color=red>[ROLE_PLANT]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_PLANT];jobban4=\ref[M]'>[ROLE_PLANT]</a></td>"

		//many roles available to ghost after die
		if(jobban_isbanned(M, ROLE_GHOSTLY))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_GHOSTLY];jobban4=\ref[M]'><font color=red>[ROLE_GHOSTLY]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[ROLE_GHOSTLY];jobban4=\ref[M]'>[ROLE_GHOSTLY]</a></td>"

		if(jobban_isbanned(M, "Mouse"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Mouse;jobban4=\ref[M]'><font color=red>Mouse</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Mouse;jobban4=\ref[M]'>Mouse</a></td>"


		jobs += "</tr></table>"


		var/datum/browser/popup = new(usr, "window=jobban2", "Job-Ban Panel: [M.name]", 800, 490, ntheme = CSS_THEME_LIGHT)
		popup.set_content(jobs)
		popup.open()
		return

	//JOBBAN'S INNARDS
	else if(href_list["jobban3"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["jobban4"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(M != usr)																//we can jobban ourselves
			if(M.client && M.client.holder && (M.client.holder.rights & R_BAN))		//they can ban too. So we can't ban them
				alert("You cannot perform this action. You must be of a higher administrative rank!")
				return

		if(!SSjob)
			to_chat(usr, "Job Master has not been setup!")
			return

		//get jobs for department if specified, otherwise just returnt he one job in a list.
		var/list/joblist = list()
		switch(href_list["jobban3"])
			if("commanddept")
				for(var/jobPos in command_positions)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("securitydept")
				for(var/jobPos in security_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjob.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("engineeringdept")
				for(var/jobPos in engineering_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjob.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("medicaldept")
				for(var/jobPos in medical_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjob.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("sciencedept")
				for(var/jobPos in science_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjob.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("civiliandept")
				for(var/jobPos in civilian_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjob.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
/*			if("entertaimentdept")
				for(var/jobPos in entertaiment_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title */
			if("nonhumandept")
				joblist += ROLE_DRONE
				joblist += ROLE_PAI
				for(var/jobPos in nonhuman_positions)
					if(!jobPos)	continue
					var/datum/job/temp = SSjob.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			else
				joblist += href_list["jobban3"]

		//Create a list of unbanned jobs within joblist
		var/list/notbannedlist = list()
		for(var/job in joblist)
			if(!jobban_isbanned(M, job))
				notbannedlist += job

		//Banning comes first
		if(notbannedlist.len) //at least 1 unbanned job exists in joblist so we have stuff to ban.
			switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
				if("Yes")
					if(!check_rights(R_BAN))  return
					var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
					if(!mins)
						return
					var/reason = sanitize(input(usr,"Reason?","Please State Reason","") as text|null)
					if(!reason)
						return

					var/msg
					for(var/job in notbannedlist)
						ban_unban_log_save("[key_name(usr)] temp-jobbanned [key_name(M)] from [job] for [mins] minutes. reason: [reason]")
						log_admin("[key_name(usr)] temp-jobbanned [key_name(M)] from [job] for [mins] minutes")
						feedback_inc("ban_job_tmp",1)
						DB_ban_record(BANTYPE_JOB_TEMP, M, mins, reason, job)
						if(M.client)
							jobban_buildcache(M.client)
						feedback_add_details("ban_job_tmp","- [job]")
						if(!msg)
							msg = job
						else
							msg += ", [job]"
					message_admins("<span class='notice'>[key_name_admin(usr)] banned [key_name_admin(M)] from [msg] for [mins] minutes</span>")
					to_chat(M, "<span class='warning'><BIG><B>You have been jobbanned by [usr.client.ckey] from: [msg].</B></BIG></span>")
					to_chat(M, "<span class='warning'><B>The reason is: [reason]</B></span>")
					to_chat(M, "<span class='warning'>This jobban will be lifted in [mins] minutes.</span>")
					href_list["jobban2"] = 1 // lets it fall through and refresh
					return 1
				if("No")
					if(!check_rights(R_BAN))
						return
					var/reason = sanitize(input(usr,"Reason?","Please State Reason","") as text|null)
					if(reason)
						var/msg
						for(var/job in notbannedlist)
							ban_unban_log_save("[key_name(usr)] perma-jobbanned [key_name(M)] from [job]. reason: [reason]")
							log_admin("[key_name(usr)] perma-banned [key_name(M)] from [job]")
							feedback_inc("ban_job",1)
							DB_ban_record(BANTYPE_JOB_PERMA, M, -1, reason, job)
							if(M.client)
								jobban_buildcache(M.client)
							feedback_add_details("ban_job","- [job]")
							if(!msg)	msg = job
							else		msg += ", [job]"
						message_admins("<span class='notice'>[key_name_admin(usr)] banned [key_name_admin(M)] from [msg]</span>")
						to_chat(M, "<span class='warning'><BIG><B>You have been jobbanned by [usr.client.ckey] from: [msg].</B></BIG></span>")
						to_chat(M, "<span class='warning'><B>The reason is: [reason]</B></span>")
						to_chat(M, "<span class='warning'>Jobban can be lifted only upon request.</span>")
						href_list["jobban2"] = 1 // lets it fall through and refresh
						return 1
				if("Cancel")
					return

		//Unbanning joblist
		//all jobs in joblist are banned already OR we didn't give a reason (implying they shouldn't be banned)
		if(joblist.len) //at least 1 banned job exists in joblist so we have stuff to unban.
			var/msg
			for(var/job in joblist)
				var/reason = jobban_isbanned(M, job)
				if(!reason)
					continue //skip if it isn't jobbanned anyway
				switch(alert("Job: '[job]' Reason: '[reason]' Un-jobban?","Please Confirm","Yes","No"))
					if("Yes")
						ban_unban_log_save("[key_name(usr)] unjobbanned [key_name(M)] from [job]")
						log_admin("[key_name(usr)] unbanned [key_name(M)] from [job]")
						DB_ban_unban(M.ckey, BANTYPE_ANY_JOB, job)
						if(M.client)
							jobban_buildcache(M.client)
						feedback_inc("ban_job_unban",1)
						feedback_add_details("ban_job_unban","- [job]")
						if(!msg)	msg = job
						else		msg += ", [job]"
					else
						continue
			if(msg)
				message_admins("<span class='notice'>[key_name_admin(usr)] unbanned [key_name_admin(M)] from [msg]</span>")
				to_chat(M, "<span class='warning'><BIG><B>You have been un-jobbanned by [usr.client.ckey] from [msg].</B></BIG></span>")
				href_list["jobban2"] = 1 // lets it fall through and refresh
			return 1
		return 0 //we didn't do anything!

	else if(href_list["guard"])
		if(!(check_rights(R_LOG) && check_rights(R_BAN)))
			return

		var/mob/M = locate(href_list["guard"])
		if (ismob(M))
			if(!M.client)
				return
			M.client.guard.print_report()

	else if(href_list["cid_list"])
		if(!check_rights(R_LOG))
			return
		else
			var/mob/M = locate(href_list["cid_list"])
			if (ismob(M))
				if(!M.client)
					return
				var/client/C = M.client
				var/dat = "<html><head><title>[C.ckey] cid list</title></head>"
				dat += "<center><b>Ckey:</b> [C.ckey] | <b>Ignore warning:</b> [C.prefs.ignore_cid_warning ? "yes" : "no"]</center>"
				for(var/x in C.prefs.cid_list)
					dat += "<b>computer_id:</b> [x] - <b>first seen:</b> [C.prefs.cid_list[x]["first_seen"]] - <b>last seen:</b> [C.prefs.cid_list[x]["last_seen"]]<br>"
				usr << browse(dat, "window=[C.ckey]_cid_list")

	else if(href_list["cid_ignore"])
		if(!check_rights(R_LOG))
			return
		else
			var/mob/M = locate(href_list["cid_ignore"])
			if (ismob(M))
				if(!M.client)
					return
				var/client/C = M.client
				C.prefs.ignore_cid_warning = !(C.prefs.ignore_cid_warning)
				log_admin("[key_name(usr)] has [C.prefs.ignore_cid_warning ? "disabled" : "enabled"] multiple cid notice for [C.ckey].")
				message_admins("[key_name_admin(usr)] has [C.prefs.ignore_cid_warning ? "disabled" : "enabled"] multiple cid notice for [C.ckey].")

	else if(href_list["related_accounts"])
		if(!check_rights(R_LOG))
			return
		else
			var/mob/M = locate(href_list["related_accounts"])
			if (ismob(M))
				if(!M.client)
					return
				var/client/C = M.client

				var/dat = "<html><head><title>[C.key] related accounts by IP and cid</title></head>"
				dat += "<center><b>Ckey:</b> [C.ckey]</center><br>"
				dat += "<b>IP:</b> [C.related_accounts_ip]<hr>"
				dat += "<b>CID:</b> [C.related_accounts_cid]"

				usr << browse(dat, "window=[C.ckey]_related_accounts")

	else if(href_list["boot2"])
		var/mob/M = locate(href_list["boot2"])
		if (ismob(M))
			if(!check_if_greater_rights_than(M.client))
				return
			var/reason = sanitize(input("Please enter reason"))
			if(!reason)
				to_chat(M, "<span class='warning'>You have been kicked from the server</span>")
			else
				to_chat(M, "<span class='warning'>You have been kicked from the server: [reason]</span>")
			log_admin("[key_name(usr)] booted [key_name(M)].")
			message_admins("<span class='notice'>[key_name_admin(usr)] booted [key_name_admin(M)].</span>")
			//M.client = null
			del(M.client)

	else if(href_list["newban"])
		if(!check_rights(R_BAN))  return

		var/mob/M = locate(href_list["newban"])
		if(!ismob(M)) return

		if(M.client && M.client.holder)	return	//admins cannot be banned. Even if they could, the ban doesn't affect them anyway

		switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
			if("Yes")
				var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
				if(!mins)
					return
				if(mins >= 525600) mins = 525599
				var/reason = sanitize(input(usr,"Reason?","reason","Griefer") as text|null)
				if(!reason)
					return
				AddBan(M.ckey, M.computer_id, reason, usr.ckey, 1, mins)
				ban_unban_log_save("[usr.client.ckey] has banned [M.ckey]. - Reason: [reason] - This will be removed in [mins] minutes.")
				to_chat(M, "<span class='warning'><BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG></span>")
				to_chat(M, "<span class='warning'>This is a temporary ban, it will be removed in [mins] minutes.</span>")
				feedback_inc("ban_tmp",1)
				DB_ban_record(BANTYPE_TEMP, M, mins, reason)
				feedback_inc("ban_tmp_mins",mins)
				if(config.banappeals)
					to_chat(M, "<span class='warning'>To try to resolve this matter head to [config.banappeals]</span>")
				else
					to_chat(M, "<span class='warning'>No ban appeals URL has been set.</span>")
				log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
				message_admins("<span class='notice'>[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.</span>")

				del(M.client)
				//del(M)	// See no reason why to delete mob. Important stuff can be lost. And ban can be lifted before round ends.
			if("No")
				if(!check_rights(R_BAN))   return
				var/reason = sanitize(input(usr,"Reason?","reason","Griefer") as text|null)
				if(!reason)
					return
				switch(alert(usr,"IP ban?",,"Yes","No","Cancel"))
					if("Cancel")	return
					if("Yes")
						AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0, M.lastKnownIP)
					if("No")
						AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0)
				to_chat(M, "<span class='warning'><BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG></span>")
				to_chat(M, "<span class='warning'>This is a permanent ban.</span>")
				if(config.banappeals)
					to_chat(M, "<span class='warning'>To try to resolve this matter head to [config.banappeals]</span>")
				else
					to_chat(M, "<span class='warning'>No ban appeals URL has been set.</span>")
				ban_unban_log_save("[usr.client.ckey] has permabanned [M.ckey]. - Reason: [reason] - This is a permanent ban.")
				log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
				message_admins("<span class='notice'>[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.</span>")
				feedback_inc("ban_perma",1)
				DB_ban_record(BANTYPE_PERMA, M, -1, reason)

				del(M.client)
				//del(M)
			if("Cancel")
				return

	else if(href_list["mute"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["mute"])
		if(!ismob(M))
			return
		if(!M.client)
			return

		var/mute_type = href_list["mute_type"]
		if(istext(mute_type))
			mute_type = text2num(mute_type)
		if(!isnum(mute_type))
			return

		cmd_admin_mute(M, mute_type)

	else if(href_list["c_mode"])
		if(!check_rights(R_ADMIN))
			return

		if(SSticker && SSticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		var/dat = {"<B>What mode do you wish to play?</B><HR>"}
		for(var/mode in config.modes)
			dat += {"<A href='?src=\ref[src];c_mode2=[mode]'>[config.mode_names[mode]]</A><br>"}
		dat += {"<A href='?src=\ref[src];c_mode2=secret'>Secret</A><br>"}
		dat += {"<A href='?src=\ref[src];c_mode2=random'>Random</A><br>"}
		dat += {"Now: [master_mode]"}
		usr << browse(dat, "window=c_mode")

	else if(href_list["f_secret"])
		if(!check_rights(R_ADMIN))
			return

		if(SSticker && SSticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(master_mode != "secret")
			return alert(usr, "The game mode has to be secret!", null, null, null, null)
		var/dat = {"<B>What game mode do you want to force secret to be? Use this if you want to change the game mode, but want the players to believe it's secret. This will only work if the current game mode is secret.</B><HR>"}
		for(var/mode in config.modes)
			dat += {"<A href='?src=\ref[src];f_secret2=[mode]'>[config.mode_names[mode]]</A><br>"}
		dat += {"<A href='?src=\ref[src];f_secret2=secret'>Random (default)</A><br>"}
		dat += {"Now: [secret_force_mode]"}
		usr << browse(dat, "window=f_secret")

	else if(href_list["c_mode2"])
		if(!check_rights(R_ADMIN|R_SERVER))
			return

		if (SSticker && SSticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		master_mode = href_list["c_mode2"]
		log_admin("[key_name(usr)] set the mode as [master_mode].")
		message_admins("<span class='notice'>[key_name_admin(usr)] set the mode as [master_mode].</span>")
		to_chat(world, "<span class='notice'><b>The mode is now: [master_mode]</b></span>")
		Game() // updates the main game menu
		world.save_mode(master_mode)
		.(href, list("c_mode"=1))

	else if(href_list["f_secret2"])
		if(!check_rights(R_ADMIN|R_SERVER))
			return

		if(SSticker && SSticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(master_mode != "secret")
			return alert(usr, "The game mode has to be secret!", null, null, null, null)
		secret_force_mode = href_list["f_secret2"]
		log_admin("[key_name(usr)] set the forced secret mode as [secret_force_mode].")
		message_admins("<span class='notice'>[key_name_admin(usr)] set the forced secret mode as [secret_force_mode].</span>")
		Game() // updates the main game menu
		.(href, list("f_secret"=1))

	else if(href_list["monkeyone"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["monkeyone"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		log_admin("[key_name(usr)] attempting to monkeyize [key_name(H)]")
		message_admins("<span class='notice'>[key_name_admin(usr)] attempting to monkeyize [key_name_admin(H)]</span>")
		H.monkeyize()

	else if(href_list["corgione"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["corgione"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		log_admin("[key_name(usr)] attempting to corgize [key_name(H)]")
		message_admins("<span class='notice'>[key_name_admin(usr)] attempting to corgize [key_name_admin(H)]</span>")
		H.corgize()

	else if(href_list["forcespeech"])
		if(!check_rights(R_FUN))
			return

		var/mob/M = locate(href_list["forcespeech"])
		if(!ismob(M))
			to_chat(usr, "this can only be used on instances of type /mob")

		var/speech = input("What will [key_name(M)] say?.", "Force speech", "")// Don't need to sanitize, since it does that in say(), we also trust our admins.
		if(!speech)	return
		M.say(speech)
		speech = sanitize(speech) // Nah, we don't trust them
		log_admin("[key_name(usr)] forced [key_name(M)] to say: [speech]")
		message_admins("<span class='notice'>[key_name_admin(usr)] forced [key_name_admin(M)] to say: [speech]</span>")

	else if(href_list["sendtoprison"])
		if(!check_rights(R_ADMIN))	return

		if(alert(usr, "Send to admin prison for the round?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["sendtoprison"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		var/turf/prison_cell = pick(prisonwarp)
		if(!prison_cell)	return

		var/obj/structure/closet/secure_closet/brig/locker = new /obj/structure/closet/secure_closet/brig(prison_cell)
		locker.opened = 0
		locker.locked = 1

		//strip their stuff and stick it in the crate
		for(var/obj/item/I in M)
			M.drop_from_inventory(I, locker)
		M.update_icons()

		//so they black out before warping
		M.Paralyse(5)
		sleep(5)
		if(!M)	return

		M.loc = prison_cell
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/prisoner = M
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(prisoner), SLOT_W_UNIFORM)
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(prisoner), SLOT_SHOES)

		to_chat(M, "<span class='warning'>You have been sent to the prison station!</span>")
		log_admin("[key_name(usr)] sent [key_name(M)] to the prison station.")
		message_admins("<span class='notice'>[key_name_admin(usr)] sent [key_name_admin(M)] to the prison station.</span>")

	else if(href_list["tdome1"])
		if(!check_rights(R_FUN))
			return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdome1"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		for(var/obj/item/I in M)
			M.drop_from_inventory(I)

		M.Paralyse(5)
		sleep(5)
		M.loc = pick(tdome1)
		spawn(50)
			to_chat(M, "<span class='notice'>You have been sent to the Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Team 1)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Team 1)")

	else if(href_list["tdome2"])
		if(!check_rights(R_FUN))
			return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdome2"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		for(var/obj/item/I in M)
			M.drop_from_inventory(I)

		M.Paralyse(5)
		sleep(5)
		M.loc = pick(tdome2)
		spawn(50)
			to_chat(M, "<span class='notice'>You have been sent to the Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Team 2)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Team 2)")

	else if(href_list["tdomeadmin"])
		if(!check_rights(R_FUN))
			return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdomeadmin"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		M.Paralyse(5)
		sleep(5)
		M.loc = pick(tdomeadmin)
		spawn(50)
			to_chat(M, "<span class='notice'>You have been sent to the Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Admin.)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Admin.)")

	else if(href_list["tdomeobserve"])
		if(!check_rights(R_FUN))
			return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdomeobserve"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		for(var/obj/item/I in M)
			M.drop_from_inventory(I)

		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/observer = M
			observer.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket(observer), SLOT_W_UNIFORM)
			observer.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(observer), SLOT_SHOES)
		M.Paralyse(5)
		sleep(5)
		M.loc = pick(tdomeobserve)
		spawn(50)
			to_chat(M, "<span class='notice'>You have been sent to the Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Observer.)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Observer.)")

	else if(href_list["revive"])
		if(!check_rights(R_REJUVINATE))	return

		var/mob/living/L = locate(href_list["revive"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /mob/living")
			return

		if(config.allow_admin_rev)
			L.revive()
			message_admins("<span class='warning'>Admin [key_name_admin(usr)] healed / revived [key_name_admin(L)]!</span>")
			log_admin("[key_name(usr)] healed / Rrvived [key_name(L)]")
		else
			to_chat(usr, "Admin Rejuvinates have been disabled")

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makeai"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		message_admins("<span class='warning'>Admin [key_name_admin(usr)] AIized [key_name_admin(H)]!</span>")
		log_admin("[key_name(usr)] AIized [key_name(H)]")
		H.AIize()

	else if(href_list["makealien"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makealien"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		usr.client.cmd_admin_alienize(H)

	else if(href_list["makeslime"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makeslime"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		usr.client.cmd_admin_slimeize(H)

	else if(href_list["makeblob"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makeblob"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		usr.client.cmd_admin_blobize(H)

	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makerobot"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		usr.client.cmd_admin_robotize(H)

	else if(href_list["makeanimal"])
		if(!check_rights(R_SPAWN))	return

		var/mob/M = locate(href_list["makeanimal"])
		if(isnewplayer(M))
			to_chat(usr, "This cannot be used on instances of type /mob/dead/new_player")
			return

		usr.client.cmd_admin_animalize(M)

	else if(href_list["togmutate"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["togmutate"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return
		var/block=text2num(href_list["block"])
		//testing("togmutate([href_list["block"]] -> [block])")
		usr.client.cmd_admin_toggle_block(H,block)
		show_player_panel(H)
		//H.regenerate_icons()

	else if(href_list["adminplayeropts"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["adminplayeropts"])
		show_player_panel(M)

	else if(href_list["adminplayerobservejump"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["adminplayerobservejump"])

		var/client/C = usr.client
		if(!isobserver(usr))
			C.admin_ghost()
		sleep(2)
		C.jumptomob(M)

	else if(href_list["check_antagonist"])
		if(!check_rights(R_ADMIN))
			return

		check_antagonists()

	else if(href_list["adminplayerobservefollow"])
		if(!isobserver(usr) && !check_rights(R_ADMIN))
			return

		var/atom/movable/AM = locate(href_list["adminplayerobservefollow"])

		var/client/C = usr.client
		if(!isobserver(usr))	C.admin_ghost()
		var/mob/dead/observer/A = C.mob
		A.ManualFollow(AM)

	else if(href_list["adminplayerobservecoodjump"])
		if(!check_rights(R_ADMIN))
			return

		var/x = text2num(href_list["X"])
		var/y = text2num(href_list["Y"])
		var/z = text2num(href_list["Z"])

		var/client/C = usr.client
		if(!isobserver(usr))	C.admin_ghost()
		sleep(2)
		C.jumptocoord(x,y,z)

	else if(href_list["adminchecklaws"])
		output_ai_laws()

	else if(href_list["adminmoreinfo"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["adminmoreinfo"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		var/location_description = ""
		var/special_role_description = ""
		var/health_description = ""
		var/gender_description = ""
		var/turf/T = get_turf(M)

		//Location
		if(isturf(T))
			if(isarea(T.loc))
				location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z] in area <b>[T.loc]</b>)"
			else
				location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z])"

		//Job + antagonist
		if(M.mind)
			special_role_description = "Role: <b>[M.mind.assigned_role]</b>; Antagonist: <font color='red'><b>[M.mind.special_role]</b></font>; Has been rev: [(M.mind.has_been_rev)?"Yes":"No"]"
		else
			special_role_description = "Role: <i>Mind datum missing</i> Antagonist: <i>Mind datum missing</i>; Has been rev: <i>Mind datum missing</i>;"

		//Health
		if(isliving(M))
			var/mob/living/L = M
			var/status
			switch (M.stat)
				if (0) status = "Alive"
				if (1) status = "<font color='orange'><b>Unconscious</b></font>"
				if (2) status = "<font color='red'><b>Dead</b></font>"
			health_description = "Status = [status]"
			health_description += "<BR>Oxy: [L.getOxyLoss()] - Tox: [L.getToxLoss()] - Fire: [L.getFireLoss()] - Brute: [L.getBruteLoss()] - Clone: [L.getCloneLoss()] - Brain: [L.getBrainLoss()]"
		else
			health_description = "This mob type has no health to speak of."

		//Gener
		switch(M.gender)
			if(MALE,FEMALE)	gender_description = "[M.gender]"
			else			gender_description = "<font color='red'><b>[M.gender]</b></font>"

		to_chat(src.owner, "<b>Info about [M.name]:</b> ")
		to_chat(src.owner, "Mob type = [M.type]; Gender = [gender_description] Damage = [health_description]")
		to_chat(src.owner, "Name = <b>[M.name]</b>; Real_name = [M.real_name]; Mind_name = [M.mind?"[M.mind.name]":""]; Key = <b>[M.key]</b>;")
		to_chat(src.owner, "Location = [location_description];")
		to_chat(src.owner, "[special_role_description]")
		to_chat(src.owner, "(<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a>) (<A HREF='?src=\ref[src];adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[M]'>VV</A>) (<A HREF='?src=\ref[src];subtlemessage=\ref[M]'>SM</A>) (<A HREF='?src=\ref[src];adminplayerobservejump=\ref[M]'>JMP</A>) (<A HREF='?src=\ref[src];secretsadmin=check_antagonist'>CA</A>)")

	else if(href_list["adminspawncookie"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/living/carbon/human/H = locate(href_list["adminspawncookie"])
		if(!ishuman(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		H.equip_to_slot_or_del( new /obj/item/weapon/reagent_containers/food/snacks/cookie(H), SLOT_L_HAND )
		if(!(istype(H.l_hand,/obj/item/weapon/reagent_containers/food/snacks/cookie)))
			H.equip_to_slot_or_del( new /obj/item/weapon/reagent_containers/food/snacks/cookie(H), SLOT_R_HAND )
			if(!(istype(H.r_hand,/obj/item/weapon/reagent_containers/food/snacks/cookie)))
				log_admin("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(src.owner)].")
				message_admins("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(src.owner)].")
				return
			else
				H.update_inv_r_hand()//To ensure the icon appears in the HUD
		else
			H.update_inv_l_hand()
		log_admin("[key_name(H)] got their cookie, spawned by [key_name(src.owner)]")
		message_admins("[key_name(H)] got their cookie, spawned by [key_name(src.owner)]")
		feedback_inc("admin_cookies_spawned",1)
		to_chat(H, "<span class='adminnotice'>Your prayers have been answered!! You received the <b>best cookie</b>!</span>")
		H.playsound_local(null, 'sound/effects/pray_chaplain.ogg', VOL_EFFECTS_MASTER, vary = FALSE, ignore_environment = TRUE)

	else if(href_list["BlueSpaceArtillery"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/living/M = locate(href_list["BlueSpaceArtillery"])
		if(!isliving(M))
			to_chat(usr, "This can only be used on instances of type /mob/living")
			return

		if(alert(src.owner, "Are you sure you wish to hit [key_name(M)] with Blue Space Artillery?",  "Confirm Firing?" , "Yes" , "No") != "Yes")
			return

		if(BSACooldown)
			to_chat(src.owner, "Standby!  Reload cycle in progress!  Gunnary crews ready in five seconds!")
			return

		BSACooldown = 1
		spawn(50)
			BSACooldown = 0

		to_chat(M, "You've been hit by bluespace artillery!")
		log_admin("[key_name(M)] has been hit by Bluespace Artillery fired by [src.owner]")
		message_admins("[key_name(M)] has been hit by Bluespace Artillery fired by [src.owner]")

		var/turf/simulated/floor/T = get_turf(M)
		if(istype(T))
			if(prob(80))	T.break_tile_to_plating()
			else			T.break_tile()

		if(M.health == 1)
			M.gib()
		else
			M.adjustBruteLoss( min( 99 , (M.health - 1) )    )
			M.Stun(20)
			M.Weaken(20)
			M.stuttering = 20

	else if(href_list["CentcommReply"])
		var/mob/living/H = locate(href_list["CentcommReply"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living")
			return
		if(!H.CanObtainCentcommMessage())
			to_chat(usr, "The person you are trying to contact is not wearing a headset")
			return

		var/input = sanitize(input(src.owner, "Please enter a message to reply to [key_name(H)] via their headset.","Outgoing message from Centcomm", ""))
		if(!input)	return

		to_chat(src.owner, "You sent [input] to [H] via a secure channel.")
		log_admin("[src.owner] replied to [key_name(H)]'s Centcomm message with the message [input].")
		message_admins("[src.owner] replied to [key_name(H)]'s Centcom message with: \"[input]\"")
		world.send2bridge(
			type = list(BRIDGE_ADMINCOM),
			attachment_title = ":regional_indicator_c: **[key_name(src.owner)]** replied to **[key_name(H)]**'s ***Centcom*** message",
			attachment_msg = input,
			attachment_color = BRIDGE_COLOR_ADMINCOM,
		)

		to_chat(H, "You hear something crackle in your headset for a moment before a voice speaks.  \"Please stand by for a message from Central Command.  Message as follows. <b>\"[input]\"</b>  Message ends.\"")

	else if(href_list["SyndicateReply"])
		var/mob/living/carbon/human/H = locate(href_list["SyndicateReply"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return
		if(!istype(H.l_ear, /obj/item/device/radio/headset) && !istype(H.r_ear, /obj/item/device/radio/headset))
			to_chat(usr, "The person you are trying to contact is not wearing a headset")
			return

		var/input = sanitize(input(src.owner, "Please enter a message to reply to [key_name(H)] via their headset.","Outgoing message from The Syndicate", ""))
		if(!input)	return

		to_chat(src.owner, "You sent [input] to [H] via a secure channel.")
		log_admin("[src.owner] replied to [key_name(H)]'s Syndicate message with the message [input].")
		message_admins("[src.owner] replied to [key_name(H)]'s Syndicate message with: \"[input]\"")
		world.send2bridge(
			type = list(BRIDGE_ADMINCOM),
			attachment_title = ":regional_indicator_s: **[key_name(src.owner)]** replied to **[key_name(H)]**'s ***Syndicate*** message",
			attachment_msg = input,
			attachment_color = BRIDGE_COLOR_ADMINCOM,
		)
		to_chat(H, "You hear something crackle in your headset for a moment before a voice speaks.  \"Please stand by for a message from your benefactor.  Message as follows, agent. <b>\"[input]\"</b>  Message ends.\"")

	else if(href_list["CentcommFaxViewInfo"])
		var/info = locate(href_list["CentcommFaxViewInfo"])
		var/stamps = locate(href_list["CentcommFaxViewStamps"])

		var/datum/browser/popup = new(usr, "window=Centcomm Fax Message", "Centcomm Fax Message", ntheme = CSS_THEME_LIGHT)
		popup.set_content("[info][stamps]")
		popup.open()

	else if(href_list["CentcommFaxReply"])
		var/mob/living/carbon/human/H = locate(href_list["CentcommFaxReply"])
		var/department = locate(href_list["CentcommFaxReplyDestination"])

		var/input = sanitize(input(src.owner, "Please, enter a message to reply to [key_name(H)] via secure connection.", "Outgoing message from Centcomm", "") as message|null, extra = FALSE)
		if(!input)
			return

		var/customname = sanitize_safe(input(src.owner, "Pick a title for the report", "Title") as text|null)

		var/obj/item/weapon/paper/P = new
		P.name = "[command_name()]- [customname]"
		var/parsed_text = parsebbcode(input)
		parsed_text = replacetext(parsed_text, "\[nt\]", "<img src = bluentlogo.png />")
		P.info = parsed_text
		P.update_icon()

		var/obj/item/weapon/stamp/centcomm/S = new
		S.stamp_paper(P)

		switch(alert("Should this be sended to all fax machines?",,"Yes","No"))
			if("Yes")
				send_fax(usr, P, "All")
			if("No")
				send_fax(usr, P, "[department]")

		add_communication_log(type = "fax-centcomm", title = customname ? customname : 0, author = "Centcomm Officer", content = input)

		to_chat(src.owner, "Message reply to transmitted successfully.")
		log_admin("[key_name(src.owner)] replied to a fax message from [key_name(H)]: [input]")
		message_admins("[key_name_admin(src.owner)] replied to a fax message from [key_name_admin(H)]")
		world.send2bridge(
			type = list(BRIDGE_ADMINCOM),
			attachment_title = ":fax: **[key_name(src.owner)]** replied to a fax message from **[key_name(H)]**",
			attachment_msg = input,
			attachment_color = BRIDGE_COLOR_ADMINCOM,
		)

	else if(href_list["jumpto"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["jumpto"])
		usr.client.jumptomob(M)

	else if(href_list["getmob"])
		if(!check_rights(R_ADMIN))
			return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")	return
		var/mob/M = locate(href_list["getmob"])
		usr.client.Getmob(M)

	else if(href_list["sendmob"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["sendmob"])
		usr.client.sendmob(M)

	else if(href_list["narrateto"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["narrateto"])
		usr.client.cmd_admin_direct_narrate(M)

	else if(href_list["subtlemessage"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["subtlemessage"])
		usr.client.cmd_admin_subtle_message(M)

	else if(href_list["traitor"])
		if(!check_rights(R_ADMIN))
			return

		if(!SSticker || !SSticker.mode)
			alert("The game hasn't started yet!")
			return

		var/mob/M = locate(href_list["traitor"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob.")
			return
		show_traitor_panel(M)

	else if(href_list["create_object"])
		if(!check_rights(R_SPAWN))	return
		return create_object(usr)

	else if(href_list["quick_create_object"])
		if(!check_rights(R_SPAWN))	return
		return quick_create_object(usr)

	else if(href_list["create_turf"])
		if(!check_rights(R_SPAWN))	return
		return create_turf(usr)

	else if(href_list["create_mob"])
		if(!check_rights(R_SPAWN))	return
		return create_mob(usr)

	else if(href_list["object_list"])			//this is the laggiest thing ever
		if(!check_rights(R_SPAWN))	return

		if(!config.allow_admin_spawning)
			to_chat(usr, "Spawning of items is not allowed.")
			return

		var/atom/loc = usr.loc

		var/dirty_paths
		if (istext(href_list["object_list"]))
			dirty_paths = list(href_list["object_list"])
		else if (istype(href_list["object_list"], /list))
			dirty_paths = href_list["object_list"]

		var/paths = list()
		var/removed_paths = list()
		var/max_paths_length = 5

		for(var/dirty_path in dirty_paths)
			var/path = text2path(dirty_path)
			if(!path)
				removed_paths += dirty_path
				continue
			else if(!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
				removed_paths += dirty_path
				continue
			else if(ispath(path, /obj/item/weapon/gun/energy/pulse_rifle))
				if(!check_rights(R_FUN,0))
					removed_paths += dirty_path
					continue
			else if(ispath(path, /obj/item/weapon/melee/energy/blade))//Not an item one should be able to spawn./N
				if(!check_rights(R_FUN,0))
					removed_paths += dirty_path
					continue
			else if(ispath(path, /obj/effect/anomaly/bhole))
				if(!check_rights(R_FUN,0))
					removed_paths += dirty_path
					continue
			else if(ispath(path, /turf))
				max_paths_length = 1
			paths += path

		if(!paths)
			alert("The path list you sent is empty")
			return
		if(length(paths) > max_paths_length)
			alert("Select fewer object types, (max [max_paths_length])")
			return
		else if(length(removed_paths))
			alert("Removed:\n" + jointext(removed_paths, "\n"))

		var/list/offset = splittext(href_list["offset"],",")
		var/number = clamp(text2num(href_list["object_count"]), 1, 100)
		var/X = offset.len > 0 ? text2num(offset[1]) : 0
		var/Y = offset.len > 1 ? text2num(offset[2]) : 0
		var/Z = offset.len > 2 ? text2num(offset[3]) : 0
		var/tmp_dir = href_list["object_dir"]
		var/obj_dir = tmp_dir ? text2num(tmp_dir) : 2
		if(!obj_dir || !(obj_dir in list(1,2,4,8,5,6,9,10)))
			obj_dir = 2
		var/obj_name = sanitize(href_list["object_name"])
		var/atom/target //Where the object will be spawned
		var/where = href_list["object_where"]
		if (!( where in list("onfloor","inhand","inmarked","dropped") ))
			where = "onfloor"


		switch(where)
			if("inhand")
				if (!iscarbon(usr) && !isrobot(usr))
					to_chat(usr, "Can only spawn in hand when you're a carbon mob or cyborg.")
					where = "onfloor"
				if(isrobot(usr))
					var/mob/living/silicon/robot/R = usr
					if(!R.module)
						to_chat(R, "Cyborg doesn't has module, you can't do that.")
						return
				target = usr
			if("onfloor", "dropped")
				switch(href_list["offset_type"])
					if ("absolute")
						target = locate(0 + X,0 + Y,0 + Z)
					if ("relative")
						target = locate(loc.x + X,loc.y + Y,loc.z + Z)
			if("inmarked")
				if(!marked_datum)
					to_chat(usr, "You don't have any object marked. Abandoning spawn.")
					return
				else if(!istype(marked_datum,/atom))
					to_chat(usr, "The object you have marked cannot be used as a target. Target must be of type /atom. Abandoning spawn.")
					return
				else
					target = marked_datum


		if(target)
			var/stop_main_loop = FALSE
			for (var/path in paths)
				for (var/i = 0; i < number; i++)
					if(where == "dropped")
						new /obj/effect/falling_effect(target, path)
					else if(path in typesof(/turf))
						var/turf/O = target
						var/turf/N = O.ChangeTurf(path)
						if(N && obj_name)
							N.name = obj_name
						number = 1 // this is not for this loop, but for the logs part down below.
						stop_main_loop = TRUE
						break // there is no point in spawning more than one turf.
					else
						var/atom/O = new path(target)
						if(O)
							O.dir = obj_dir
							if(obj_name)
								O.name = obj_name
								if(istype(O,/mob))
									var/mob/M = O
									M.real_name = obj_name
							if(where == "inhand" && isliving(usr) && istype(O, /obj/item))
								var/mob/living/L = usr
								var/obj/item/I = O
								L.put_in_hands(I)
								if(isrobot(L))
									var/mob/living/silicon/robot/R = L
									if(R.module)
										R.module.modules += I
										I.loc = R.module
										R.module.rebuild()
										R.activate_module(I)
				if(stop_main_loop)
					break

		if (number == 1)
			log_admin("[key_name(usr)] created a [english_list(paths)]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(usr)] created a [english_list(paths)]")
					break
		else
			log_admin("[key_name(usr)] created [number]ea [english_list(paths)]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(usr)] created [number]ea [english_list(paths)]")
					break
		return

	else if(href_list["secretsfun"])
		Secretsfun_topic(href_list["secretsfun"],href_list)

	else if(href_list["secretsadmin"])
		Secretsadmin_topic(href_list["secretsadmin"],href_list)

	else if(href_list["secretscoder"])
		Secretscoder_topic(href_list["secretscoder"],href_list)

	else if(href_list["ac_view_wanted"])            //Admin newscaster Topic() stuff be here
		src.admincaster_screen = 18                 //The ac_ prefix before the hrefs stands for AdminCaster.
		src.access_news_network()

	else if(href_list["ac_set_channel_name"])
		src.admincaster_feed_channel.channel_name = sanitize(input(usr, "Provide a Feed Channel Name", "Network Channel Handler", input_default(admincaster_feed_channel.channel_name)))
		src.access_news_network()

	else if(href_list["ac_set_channel_lock"])
		src.admincaster_feed_channel.locked = !src.admincaster_feed_channel.locked
		src.access_news_network()

	else if(href_list["ac_submit_new_channel"])
		var/check = 0
		for(var/datum/feed_channel/FC in news_network.network_channels)
			if(FC.channel_name == src.admincaster_feed_channel.channel_name)
				check = 1
				break
		if(src.admincaster_feed_channel.channel_name == "" || src.admincaster_feed_channel.channel_name == "\[REDACTED\]" || check )
			src.admincaster_screen=7
		else
			var/choice = alert("Please confirm Feed channel creation","Network Channel Handler","Confirm","Cancel")
			if(choice=="Confirm")
				var/datum/feed_channel/newChannel = new /datum/feed_channel
				newChannel.channel_name = src.admincaster_feed_channel.channel_name
				newChannel.author = src.admincaster_signature
				newChannel.locked = src.admincaster_feed_channel.locked
				newChannel.is_admin_channel = 1
				feedback_inc("newscaster_channels",1)
				news_network.network_channels += newChannel                        //Adding channel to the global network
				log_admin("[key_name(usr)] created command feed channel: [src.admincaster_feed_channel.channel_name]!")
				src.admincaster_screen=5
		src.access_news_network()

	else if(href_list["ac_set_channel_receiving"])
		var/list/available_channels = list()
		for(var/datum/feed_channel/F in news_network.network_channels)
			available_channels += F.channel_name
		src.admincaster_feed_channel.channel_name = input(usr, "Choose receiving Feed Channel", "Network Channel Handler") in available_channels
		src.access_news_network()

	else if(href_list["ac_set_new_message"])
		src.admincaster_feed_message.body = sanitize(input(usr, "Write your Feed story", "Network Channel Handler", input_default(admincaster_feed_message.body)), extra = FALSE)
		src.access_news_network()

	else if(href_list["ac_submit_new_message"])
		if(src.admincaster_feed_message.body =="" || src.admincaster_feed_message.body =="\[REDACTED\]" || src.admincaster_feed_channel.channel_name == "" )
			src.admincaster_screen = 6
		else
			var/datum/feed_message/newMsg = new /datum/feed_message
			newMsg.author = src.admincaster_signature
			newMsg.body = src.admincaster_feed_message.body
			newMsg.is_admin_message = 1
			feedback_inc("newscaster_stories",1)
			for(var/datum/feed_channel/FC in news_network.network_channels)
				if(FC.channel_name == src.admincaster_feed_channel.channel_name)
					FC.messages += newMsg                  //Adding message to the network's appropriate feed_channel
					break
			src.admincaster_screen=4

		for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
			NEWSCASTER.newsAlert(src.admincaster_feed_channel.channel_name)

		log_admin("[key_name(usr)] submitted a feed story to channel: [src.admincaster_feed_channel.channel_name]!")
		src.access_news_network()

	else if(href_list["ac_create_channel"])
		src.admincaster_screen=2
		src.access_news_network()

	else if(href_list["ac_create_feed_story"])
		src.admincaster_screen=3
		src.access_news_network()

	else if(href_list["ac_menu_censor_story"])
		src.admincaster_screen=10
		src.access_news_network()

	else if(href_list["ac_menu_censor_channel"])
		src.admincaster_screen=11
		src.access_news_network()

	else if(href_list["ac_menu_wanted"])
		var/already_wanted = 0
		if(news_network.wanted_issue)
			already_wanted = 1

		if(already_wanted)
			src.admincaster_feed_message.author = news_network.wanted_issue.author
			src.admincaster_feed_message.body = news_network.wanted_issue.body
		src.admincaster_screen = 14
		src.access_news_network()

	else if(href_list["ac_set_wanted_name"])
		src.admincaster_feed_message.author = sanitize(input(usr, "Provide the name of the Wanted person", "Network Security Handler", input_default(admincaster_feed_message.author)))
		src.access_news_network()

	else if(href_list["ac_set_wanted_desc"])
		src.admincaster_feed_message.body = sanitize(input(usr, "Provide the a description of the Wanted person and any other details you deem important", "Network Security Handler", ""))
		src.access_news_network()

	else if(href_list["ac_submit_wanted"])
		var/input_param = text2num(href_list["ac_submit_wanted"])
		if(src.admincaster_feed_message.author == "" || src.admincaster_feed_message.body == "")
			src.admincaster_screen = 16
		else
			var/choice = alert("Please confirm Wanted Issue [(input_param==1) ? ("creation.") : ("edit.")]","Network Security Handler","Confirm","Cancel")
			if(choice=="Confirm")
				if(input_param==1)          //If input_param == 1 we're submitting a new wanted issue. At 2 we're just editing an existing one. See the else below
					var/datum/feed_message/WANTED = new /datum/feed_message
					WANTED.author = src.admincaster_feed_message.author               //Wanted name
					WANTED.body = src.admincaster_feed_message.body                   //Wanted desc
					WANTED.backup_author = src.admincaster_signature                  //Submitted by
					WANTED.is_admin_message = 1
					news_network.wanted_issue = WANTED
					for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
						NEWSCASTER.newsAlert()
						NEWSCASTER.update_icon()
					src.admincaster_screen = 15
				else
					news_network.wanted_issue.author = src.admincaster_feed_message.author
					news_network.wanted_issue.body = src.admincaster_feed_message.body
					news_network.wanted_issue.backup_author = src.admincaster_feed_message.backup_author
					src.admincaster_screen = 19
				log_admin("[key_name(usr)] issued a Station-wide Wanted Notification for [src.admincaster_feed_message.author]!")
		src.access_news_network()

	else if(href_list["ac_cancel_wanted"])
		var/choice = alert("Please confirm Wanted Issue removal","Network Security Handler","Confirm","Cancel")
		if(choice=="Confirm")
			news_network.wanted_issue = null
			for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
				NEWSCASTER.update_icon()
			src.admincaster_screen=17
		src.access_news_network()

	else if(href_list["ac_censor_channel_author"])
		var/datum/feed_channel/FC = locate(href_list["ac_censor_channel_author"])
		if(FC.author != "<B>\[REDACTED\]</B>")
			FC.backup_author = FC.author
			FC.author = "<B>\[REDACTED\]</B>"
		else
			FC.author = FC.backup_author
		src.access_news_network()

	else if(href_list["ac_censor_channel_story_author"])
		var/datum/feed_message/MSG = locate(href_list["ac_censor_channel_story_author"])
		if(MSG.author != "<B>\[REDACTED\]</B>")
			MSG.backup_author = MSG.author
			MSG.author = "<B>\[REDACTED\]</B>"
		else
			MSG.author = MSG.backup_author
		src.access_news_network()

	else if(href_list["ac_censor_channel_story_body"])
		var/datum/feed_message/MSG = locate(href_list["ac_censor_channel_story_body"])
		if(MSG.body != "<B>\[REDACTED\]</B>")
			MSG.backup_body = MSG.body
			MSG.body = "<B>\[REDACTED\]</B>"
		else
			MSG.body = MSG.backup_body
		src.access_news_network()

	else if(href_list["ac_pick_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["ac_pick_d_notice"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen=13
		src.access_news_network()

	else if(href_list["ac_toggle_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["ac_toggle_d_notice"])
		FC.censored = !FC.censored
		src.access_news_network()

	else if(href_list["ac_view"])
		src.admincaster_screen=1
		src.access_news_network()

	else if(href_list["ac_setScreen"]) //Brings us to the main menu and resets all fields~
		src.admincaster_screen = text2num(href_list["ac_setScreen"])
		if (src.admincaster_screen == 0)
			if(src.admincaster_feed_channel)
				src.admincaster_feed_channel = new /datum/feed_channel
			if(src.admincaster_feed_message)
				src.admincaster_feed_message = new /datum/feed_message
		src.access_news_network()

	else if(href_list["ac_show_channel"])
		var/datum/feed_channel/FC = locate(href_list["ac_show_channel"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen = 9
		src.access_news_network()

	else if(href_list["ac_pick_censor_channel"])
		var/datum/feed_channel/FC = locate(href_list["ac_pick_censor_channel"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen = 12
		src.access_news_network()

	else if(href_list["ac_refresh"])
		src.access_news_network()

	else if(href_list["ac_set_signature"])
		src.admincaster_signature = sanitize(input(usr, "Provide your desired signature", "Network Identity Handler", ""))
		src.access_news_network()

	if(href_list["secretsmenu"])
		switch(href_list["secretsmenu"])
			if("tab")
				current_tab = text2num(href_list["tab"])
				Secrets(usr)
				return 1

	else if(href_list["readbook"])
		var/bookid = text2num(href_list["readbook"])

		if(!isnum(bookid))
			return

		var/DBQuery/query = dbcon_old.NewQuery("SELECT content FROM library WHERE id = '[bookid]'")

		if(!query.Execute())
			return

		var/content
		if(query.NextRow())
			content = query.item[1]
		else
			return

		var/datum/browser/popup = new(usr, "window=book", "Book #[bookid]", ntheme = CSS_THEME_LIGHT)
		popup.set_content(content)
		popup.open()

	else if(href_list["restorebook"])
		if(!check_rights(R_PERMISSIONS))
			return

		if(alert(usr, "Confirm restoring?", "Message", "Yes", "No") != "Yes")
			return
		var/bookid = text2num(href_list["restorebook"])

		if(!isnum(bookid))
			return

		var/DBQuery/query = dbcon_old.NewQuery("SELECT title FROM library WHERE id = '[bookid]'")
		if(!query.Execute())
			return

		var/title
		if(query.NextRow())
			title = query.item[1]
		else
			return

		query = dbcon_old.NewQuery("UPDATE library SET deletereason = NULL WHERE id = '[bookid]'")
		if(!query.Execute())
			return

		library_recycle_bin()
		log_admin("[key_name(usr)] restored [title] from the recycle bin")
		message_admins("[key_name_admin(usr)] restored [title] from the recycle bin")

	else if(href_list["deletebook"])
		if(!check_rights(R_PERMISSIONS))
			return

		if(alert(usr, "Confirm removal?", "Message", "Yes", "No") != "Yes")
			return

		var/bookid = text2num(href_list["deletebook"])

		if(!isnum(bookid))
			return

		var/DBQuery/query = dbcon_old.NewQuery("SELECT title FROM library WHERE id = '[bookid]'")

		if(!query.Execute())
			return

		var/title
		if(query.NextRow())
			title = query.item[1]
		else
			return

		query = dbcon_old.NewQuery("DELETE FROM library WHERE id='[bookid]'")
		if(!query.Execute())
			return

		library_recycle_bin()
		log_admin("[key_name(usr)] restored [title] from the recycle bin")
		message_admins("[key_name_admin(usr)] removed [title] from the library database")

	else if(href_list["vsc"])
		if(check_rights(R_ADMIN|R_SERVER))
			if(href_list["vsc"] == "airflow")
				vsc.ChangeSettingsDialog(usr,vsc.settings)
			if(href_list["vsc"] == "phoron")
				vsc.ChangeSettingsDialog(usr,vsc.plc.settings)
			if(href_list["vsc"] == "default")
				vsc.SetDefault(usr)

	else if(href_list["viewruntime"])
		if(!check_rights(R_DEBUG))
			return

		var/datum/error_viewer/error_viewer = locate(href_list["viewruntime"])
		if(!istype(error_viewer))
			to_chat(usr, "<span class='warning'>That runtime viewer no longer exists.</span>")
			return

		if(href_list["viewruntime_backto"])
			error_viewer.show_to(owner, locate(href_list["viewruntime_backto"]), href_list["viewruntime_linear"])
		else
			error_viewer.show_to(owner, null, href_list["viewruntime_linear"])

	else if(href_list["salary"])
		if(!check_rights(R_EVENT))	return
		var/datum/money_account/account = locate(href_list["salary"])
		if(!account)
			to_chat(usr, "<span class='warning'>Account not found!</span>")
			return
		account.change_salary(usr, "CentComm", "CentComm", "Admin")

	else if(href_list["global_salary"])
		if(!check_rights(R_EVENT))	return
		if(alert(usr, "Are you sure you want to globally change the salary?", "Confirm", "Yes", "No") != "Yes")
			return
		var/list/rate = list("+100%", "+50%", "+25%", "0", "-25%", "-50%", "-100%")
		var/input_rate = input(usr, "Please, select a rate!", "Salary Rate", null) as null|anything in rate
		if(!input_rate)
			return
		var/ratio_rate = text2num(replacetext(replacetext(input_rate, "+", ""), "%", ""))
		var/new_ratio = 1 + (ratio_rate/100)
		var/list/excluded_rank = list("AI", "Cyborg", "Clown Police", "Internal Affairs Agent")
		for(var/datum/job/J in SSjob.occupations)
			if(J.title in excluded_rank)
				continue
			J.salary_ratio = new_ratio
		var/list/crew = my_subordinate_staff("Admin")
		for(var/person in crew)
			var/datum/money_account/account = person["acc_datum"]
			account.change_salary(null, "CentComm", "CentComm", "Admin", force_rate = ratio_rate)
		if(new_ratio == 1)	//if 0 was selected
			to_chat(usr, "<span class='warning'><b>You returned basic salaries to all professions</b></span>")
		else
			to_chat(usr, "<span class='warning'><b>You have globally changed the salary of all professions by [input_rate]</b></span>")

	// player info stuff

	if(href_list["add_player_info"])
		var/key = ckey(href_list["add_player_info"])
		var/add = input("Add Player Info") as null|text//sanitise below in notes_add
		if(!add) return

		notes_add(key, add, usr.client)
		show_player_notes(key)

	/* unimplemented
	if(href_list["remove_player_info"])
		var/key = ckey(href_list["remove_player_info"])
		var/index = text2num(href_list["remove_index"])

		notes_del(key, index, usr.client)
		show_player_notes(key)*/

	if(href_list["notes"])
		var/ckey = ckey(href_list["ckey"])
		if(!ckey)
			var/mob/M = locate(href_list["mob"])
			if(ismob(M))
				ckey = M.ckey

		switch(href_list["notes"])
			if("show")
				show_player_notes(ckey)
		return
