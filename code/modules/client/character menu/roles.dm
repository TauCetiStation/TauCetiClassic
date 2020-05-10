/datum/preferences/proc/CanBeRole(role)
	if(!species)
		return FALSE

	var/datum/species/S = all_species[species]
	return S.can_be_role(role)

/datum/preferences/proc/ShowRoles(mob/user)
	. =  "<table cellspacing='0' width='100%'>"
	. += 	"<tr>"
	. += 		"<td width='50%'>"
	. += 			"<table width='100%'>"
	. += 				"<tr><td colspan='2'><b>Special Role Preference:</b></td></tr>"
	if(jobban_isbanned(user, "Syndicate"))
		. += 			"<tr><td><font color='red'><b>You are banned from antagonist roles.</b></font></td></tr>"
		src.be_role = list()
	else
		for (var/i in special_roles)
			var/available_in_minutes = role_available_in_minutes(user, i)
			if(jobban_isbanned(user, i))
				. += 	"<tr><td width='45%'>[i]: </td><td><font color=red><b> \[BANNED]</b></font></td></tr>"
			else if(i == "pai candidate")
				if(jobban_isbanned(user, "pAI"))
					. +="<tr><td width='45%'>[i]: </td><td><font color=red><b> \[BANNED]</b></font><br></td></tr>"
			else if(available_in_minutes && !(i == ROLE_PLANT && is_alien_whitelisted(user, DIONA)))
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
	. += 				"</tr></td>"
	. += 				"<tr><td>"
	. += 					"Uplink Type : <a href='?src=\ref[user];preference=antagoptions;antagtask=uplinktype'>[uplinklocation]</a>"
	. += 				"</tr></td>"
	. += 			"</table>"
	. += 		"</td>"
	. += 	"</tr>"
	. += "</table>"

/datum/preferences/proc/process_link_roles(mob/user, list/href_list)
	switch(href_list["preference"])
		if("antagoptions")
			if(href_list["antagtask"] == "uplinktype")
				var/uplink_type = input(user, "Select a type of uplink") as null|anything in list("PDA", "Headset", "None")
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
