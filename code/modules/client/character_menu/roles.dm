/datum/preferences/proc/CanBeRole(role)
	if(!species)
		return FALSE

	var/datum/species/S = all_species[species]
	return S.can_be_role(role)

/datum/preferences/proc/ShowRoles(mob/user)
	. =  "<table cellspacing='0' width='100%'>"
	. += 	"<tr>"
	. += 		"<td valign='top' width='50%'>"
	. += 			"<table width='100%'>"
	. += 				"<tr><td colspan='2'><b>Special Role Preference:</b></td></tr>"
	if(jobban_isbanned(user, "Syndicate"))
		. += 			"<tr><td><font color='red'><b>You are banned from antagonist roles.</b></font><br><a href='?_src_=prefs;preference=open_jobban_info;position=Syndicate'>Show details</a></td></tr>"
		src.be_role = list()
	else
		for (var/i in special_roles)
			var/available_in_minutes = role_available_in_minutes(user, i)
			if(jobban_isbanned(user, i))
				. += 	"<tr><td width='45%'>[i]: </td><td><font color=red><b> \[BANNED]</b></font><br><a href='?_src_=prefs;preference=open_jobban_info;position=[i]'>Show details</a></td></tr>"
			else if(available_in_minutes)
				. += "<tr><td width='45%'><del>[i]</del>: </td><td> \[IN [(available_in_minutes)] MINUTES]</td></tr>"
			else if(!CanBeRole(i))
				. +="<tr><td width='45%'>[i]: </td><td><font color=red><b> \[RESTRICTED]</b></font><br></td></tr>"
			else
				if(i in be_role)
					. +="<tr><td width='45%'>[i]: </td><td><b>Yes</b> / <a href='?_src_=prefs;preference=be_role;be_role_type=[i]'>No</a></td></tr>"
				else
					. +="<tr><td width='45%'>[i]: </td><td><a href='?_src_=prefs;preference=be_role;be_role_type=[i]'>Yes</a> / <b>No</b></td></tr>"

	. += 			"</table>"
	. += 		"</td>"
	. += 		"<td valign='top' width='50%'>"

	if(uplinklocation == "" || !uplinklocation)
		uplinklocation = "PDA"

	. += 			"<table width='100%'>"
	. += 				"<tr><td>"
	. += 					"<b>Antag setup:</b>"
	. += 				"</td></tr>"
	. += 				"<tr><td colspan='2'>"
	. += 					"Uplink Type : <a href='?src=\ref[user];preference=antagoptions;antagtask=uplinktype'>[uplinklocation]</a>"
	. += 				"</td></tr>"
	. += 			"</table>"

	. += 			"<br>"

	. += 			"<table width='100%'>"
	. += 				"<tr><td colspan='2'>"
	. += 					"<b>Ghost Poll Preference:</b>"
	. += 				"</td></tr>"
	for (var/role in global.special_roles_ignore_question)
		if((role in be_role) && !jobban_isbanned(user, role))
			for (var/ignore in global.special_roles_ignore_question[role])
				if(ignore in ignore_question)
					. += 				"<tr><td width='45%'>[ignore]: </td><td><a href='?_src_=prefs;preference=ignore_question;ghost_role=[ignore]'>Yes</a> / <b>No</b></td></tr>"
				else
					. += 				"<tr><td width='45%'>[ignore]: </td><td><b>Yes</b> / <a href='?_src_=prefs;preference=ignore_question;ghost_role=[ignore]'>No</a></td></tr>"
	. += 			"</table>"

	. += 		"</td>"
	. += 	"</tr>"
	. += "</table>"

/datum/preferences/proc/process_link_roles(mob/user, list/href_list)
	switch(href_list["preference"])
		if("antagoptions")
			if(href_list["antagtask"] == "uplinktype")
				var/uplink_type = input(user, "Select a type of uplink") as null|anything in list("PDA", "Headset", "Intercom", "None")
				if(!isnull(uplink_type))
					uplinklocation = uplink_type

		if("be_role")
			var/be_role_type = href_list["be_role_type"]
			if(!CanBeRole(be_role_type))
				return

			if(be_role_type in be_role)
				be_role -= be_role_type
			else
				be_role += be_role_type

		if("ignore_question")
			var/ghost_role = href_list["ghost_role"]
			if(!(ghost_role in global.full_ignore_question))
				return
			if(ghost_role in ignore_question)
				ignore_question -= ghost_role
			else
				ignore_question += ghost_role
