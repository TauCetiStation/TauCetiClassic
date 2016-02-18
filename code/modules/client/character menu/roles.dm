/datum/preferences/proc/ShowRoles(mob/user)
	. =  "<table width='100%' cellpadding='5' cellspacing='0'>"
	. += 	"<tr>"
	. += 		"<td width='50%'>"
	. += 			"<table width='100%'>"
	. += 				"<tr><td colspan='2'><b>Special Role Preference:</b></td></tr>"
	if(jobban_isbanned(user, "Syndicate"))
		. += 			"<tr><td><font color='red'><b>You are banned from antagonist roles.</b></font></td></tr>"
		src.be_special = 0
	else
		var/n = 0
		for (var/i in special_roles)
			if(special_roles[i]) //if mode is available on the server
				if(jobban_isbanned(user, i))
					. += 	"<tr><td width='45%'>[i]: </td><td><font color=red><b> \[BANNED]</b></font></td></tr>"
				else if(i == "pai candidate")
					if(jobban_isbanned(user, "pAI"))
						. +="<tr><td width='45%'>[i]: </td><td><font color=red><b> \[BANNED]</b></font><br></td></tr>"
				else
					if(src.be_special&(1<<n))
						. +="<tr><td width='45%'>[i]: </td><td><b>Yes</b> / <a href='?_src_=prefs;preference=be_special;num=[n]'>No</a></td></tr>"
					else
						. +="<tr><td width='45%'>[i]: </td><td><a href='?_src_=prefs;preference=be_special;num=[n]'>Yes</a> / <b>No</b></td></tr>"
			n++

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

		if("be_special")
			var/num = text2num(href_list["num"])
			be_special ^= (1<<num)