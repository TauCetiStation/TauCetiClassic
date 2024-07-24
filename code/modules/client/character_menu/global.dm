/datum/preferences/proc/ShowGlobal(mob/user)
	. =  "<table cellspacing='0' width='100%'>"
	. += 	"<tr valign='top'>"
	. += 		"<td width='50%'>"
	. += 			"<table width='100%'>"
	. +=			"<tr><td><br><b>OOC Notes: </b><a href='?_src_=prefs;preference=metadata;task=input'>[length(metadata)>0?"[copytext_char(metadata, 1, 3)]...":"\[...\]"]</a></td></tr>"
	. += 			"</table>"
	. += 		"</td>"
	. += 	"</tr>"
	. += "</table>"

/datum/preferences/proc/process_link_glob(mob/user, list/href_list)
	switch(href_list["task"])
		if("input")
			if(href_list["preference"] == "metadata")
				var/new_metadata = sanitize(input(user, "Enter any OOC information you'd like others to see:", "Game Preference", input_default(metadata)) as message|null)
				if(new_metadata)
					metadata = new_metadata
