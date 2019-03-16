/datum/admins/proc/artifact_control_panel()
	if(!usr.client.holder)
		return

	var/dat = "<html><head><title>Artifact Control Panel</title></head>"

	dat += {"

		<head>
			<script type='text/javascript'>

				var locked_tabs = new Array();

				function updateSearch(){


					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if(complete_list != null && complete_list != ""){
						var mtbl = document.getElementById("maintable_data_archive");
						mtbl.innerHTML = complete_list;
					}

					if(filter.value == ""){
						return;
					}else{

						var maintable_data = document.getElementById('maintable_data');
						var ltr = maintable_data.getElementsByTagName("tr");
						for ( var i = 0; i < ltr.length; ++i )
						{
							try{
								var tr = ltr\[i\];
								if(tr.getAttribute("id").indexOf("data") != 0){
									continue;
								}
								var ltd = tr.getElementsByTagName("td");
								var td = ltd\[0\];
								var lsearch = td.getElementsByTagName("b");
								var search = lsearch\[0\];
								//var inner_span = li.getElementsByTagName("span")\[1\] //Should only ever contain one element.
								//document.write("<p>"+search.innerText+"<br>"+filter+"<br>"+search.innerText.indexOf(filter))
								if ( search.innerText.toLowerCase().indexOf(filter) == -1 )
								{
									//document.write("a");
									//ltr.removeChild(tr);
									td.innerHTML = "";
									i--;
								}
							}catch(err) {   }
						}
					}

					var count = 0;
					var index = -1;
					var debug = document.getElementById("debug");

					locked_tabs = new Array();

				}

				function expand(id,name,first_effect,second_effect,active,ref){

					clearAll();

					var span = document.getElementById(id);

					body = "<table><tr><td>";

					body += "</td><td align='center'>";

					body += "<font size='2'><b>Name:</b>  "+name+"<br><b>First effect:</b>  "+first_effect+"<br><b>Second effect:</b>  "+second_effect+"<br><b>Active:</b>  "+active+"</font>"

					body += "</td><td align='center'>";

					body += "  - "
					body += "<a href='?src=\ref[src];jumpto="+ref+"'>JMP</a> - "
					body += "<a href='?_src_=vars;Vars="+ref+"'>VV</a><br>"

					body += "</td></tr></table>";


					span.innerHTML = body
				}

				function clearAll(){
					var spans = document.getElementsByTagName('span');
					for(var i = 0; i < spans.length; i++){
						var span = spans\[i\];

						var id = span.getAttribute("id");

						if(!(id.indexOf("item")==0))
							continue;

						span.innerHTML = "";
					}
				}

				function attempt(ab){
					return ab;
				}

				function selectTextField(){
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();
				}

			</script>
		</head>


	"}

	//body tag start + onload and onkeypress (onkeyup) javascript event calls
	dat += "<body onload='selectTextField(); updateSearch();' onkeyup='updateSearch();'>"

	//title + search bar
	dat += {"

		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable'>
			<tr id='title_tr'>
				<td align='center'>
					<font size='5'><b>Artifact Control panel</b></font><br>
					Hover over a line to see more information
					<p>
				</td>
			</tr>
			<tr id='search_tr'>
				<td align='center'>
					<b>Search:</b> <input type='text' id='filter' value='' style='width:300px;'>
				</td>
			</tr>
	</table>

	"}

	//player table header
	dat += {"
		<span id='maintable_data_archive'>
		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable_data'>"}

	var/i = 1
	for(var/obj/machinery/artifact/A in artifact_list)
		var/color = "#e6e6e6"
		if(i%2 == 0)
			color = "#f2f2f2"
		// output for each artifact
		var/A_name = A.name
		var/A_sprite = FALSE
		var/A_first_effect = "none"
		var/A_second_effect = "none"
		var/A_active = "NO"

		if(A.icon && A.icon_state)
			A_sprite = TRUE
		if(A.my_effect)
			A_first_effect = "[A.my_effect.effect_name]"
		if(A.secondary_effect)
			A_second_effect = "[A.secondary_effect.effect_name]"
		if((A.my_effect && A.my_effect.activated) || (A.secondary_effect && A.secondary_effect.activated))
			A_active = "YES"

		dat += {"

			<tr id='data[i]' name='[i]'">
				<td align='center' bgcolor='[color]'>
					<span id='notice_span[i]'></span>
					<a id='link[i]'
					onmouseover='expand("item[i]","[A_name]","[A_first_effect]","[A_second_effect]","[A_active]","\ref[A]")'
					>
					<b id='search[i]'>[A_sprite ? "[bicon(A, use_class = 0)]" : ""][A_name] (#[i]) - <a href='?_src_=artifacts;art_configuration=\ref[A]'>CONFIG</A></b>
					</a>
					<br><span id='item[i]'></span>
				</td>
			</tr>

		"}

		i++


	//player table ending
	dat += {"
		</table>
		</span>

		<script type='text/javascript'>
			var maintable = document.getElementById("maintable_data_archive");
			var complete_list = maintable.innerHTML;
		</script>
	</body></html>
	"}

	usr << browse(entity_ja(dat), "window=artifactcontrol;size=600x480")

/client/proc/artifact_configuration(obj/machinery/artifact/ART as obj)
	if(!holder)
		return
	if(isnull(ART))
		to_chat(src, "There is no artifact")
		return
	var/dat = "<html><head><title>Artifact Configuration</title></head>"

	dat += "<div align='center'><table width='100%'><tr><td width='50%'>"

	if(ART.icon && ART.icon_state)
		dat += "<table align='center' width='100%'><tr><td>[bicon(ART, use_class = 0)]</td><td><br>(<a href='?_src_=artifacts;art_c_change_icon=\ref[ART]'>change_sprite</A>)"
	else
		dat += "<table align='center' width='100%'><tr><td>"

	dat += "<div align='center'>"

	dat += "<b>[ART]</b> - (<a href='?_src_=artifacts;art_c_change_name=\ref[ART]'>change_name</A>)"

	dat += "</div>"

	dat += "</tr></td></table>"

	dat += "<td width='50%'><div align='center'><b><a href='?_src_=vars;Vars=\ref[ART]'>VV</a> - <a href='?_src_=artifacts;art_c_refresh=\ref[ART]'>Refresh</A></b></td></div>"

	dat += "</tr></td></table>"

	dat += "<br><hr><br>"
	dat += "<table width='100%'><tr><td width='20%'>"

	if(ART.my_effect)

		var/first_effect_name = "NONE"
		var/first_effect_activated = "INACTIVE"
		var/first_effect_effectrange = "NONE"
		var/first_effect_type = "TOUCH"
		var/first_effect_trigger = "TOUCH"

		if(ART.my_effect.effect_name)
			first_effect_name = ART.my_effect.effect_name

		if(ART.my_effect.activated)
			first_effect_activated = "ACTIVE"

		if(ART.my_effect.effectrange)
			first_effect_effectrange = ART.my_effect.effectrange

		if(ART.my_effect.effect)
			switch(ART.my_effect.effect)
				if(EFFECT_AURA)
					first_effect_type = "AURA"
				if(EFFECT_PULSE)
					first_effect_type = "PULSE"

		if(ART.my_effect.trigger)
			switch(ART.my_effect.trigger)
				if(TRIGGER_WATER)
					first_effect_trigger = "WATER"
				if(TRIGGER_ACID)
					first_effect_trigger = "ACID"
				if(TRIGGER_VOLATILE)
					first_effect_trigger = "VOLATILE"
				if(TRIGGER_TOXIN)
					first_effect_trigger = "TOXIN"
				if(TRIGGER_FORCE)
					first_effect_trigger = "FORCE"
				if(TRIGGER_ENERGY)
					first_effect_trigger = "ENERGY"
				if(TRIGGER_HEAT)
					first_effect_trigger = "HEAT"
				if(TRIGGER_COLD)
					first_effect_trigger = "COLD"
				if(TRIGGER_PHORON)
					first_effect_trigger = "PHORON"
				if(TRIGGER_OXY)
					first_effect_trigger = "OXY"
				if(TRIGGER_CO2)
					first_effect_trigger = "CO2"
				if(TRIGGER_NITRO)
					first_effect_trigger = "NITRO"
				if(TRIGGER_VIEW)
					first_effect_trigger = "VIEW"

		dat += "<b>FIRST EFFECT:</b> - <a href='?_src_=artifacts;art_c_first_create=\ref[ART]'>Choose a new effect</A><br>"
		dat += "<b>Name:</b> [first_effect_name]<br>"
		dat += "<b>Status:</b> [first_effect_activated] - <a href='?_src_=artifacts;art_c_first_activate=\ref[ART]'>[ART.my_effect.activated ? "Deactivate" : "Activate"]</A><br>"
		dat += "<b>Effect Range:</b> [first_effect_effectrange] - <a href='?_src_=artifacts;art_c_first_range=\ref[ART]'>Change</A><br>"
		dat += "<b>Effect Type:</b> [first_effect_type] - <a href='?_src_=artifacts;art_c_first_type=\ref[ART]'>Change</A><br>"
		dat += "<b>Trigger:</b> [first_effect_trigger] - <a href='?_src_=artifacts;art_c_first_trigger=\ref[ART]'>Change</A><br>"
		dat += "<br><hr><br>"

	if(ART.secondary_effect)

		var/second_effect_name = "NONE"
		var/second_effect_activated = "INACTIVE"
		var/second_effect_effectrange = "NONE"
		var/second_effect_type = "TOUCH"
		var/second_effect_trigger = "TOUCH"

		if(ART.secondary_effect.effect_name)
			second_effect_name = ART.secondary_effect.effect_name

		if(ART.secondary_effect.activated)
			second_effect_activated = "ACTIVE"

		if(ART.secondary_effect.effectrange)
			second_effect_effectrange = ART.secondary_effect.effectrange

		if(ART.secondary_effect.effect)
			switch(ART.secondary_effect.effect)
				if(EFFECT_AURA)
					second_effect_type = "AURA"
				if(EFFECT_PULSE)
					second_effect_type = "PULSE"

		if(ART.secondary_effect.trigger)
			switch(ART.secondary_effect.trigger)
				if(TRIGGER_WATER)
					second_effect_trigger = "WATER"
				if(TRIGGER_ACID)
					second_effect_trigger = "ACID"
				if(TRIGGER_VOLATILE)
					second_effect_trigger = "VOLATILE"
				if(TRIGGER_TOXIN)
					second_effect_trigger = "TOXIN"
				if(TRIGGER_FORCE)
					second_effect_trigger = "FORCE"
				if(TRIGGER_ENERGY)
					second_effect_trigger = "ENERGY"
				if(TRIGGER_HEAT)
					second_effect_trigger = "HEAT"
				if(TRIGGER_COLD)
					second_effect_trigger = "COLD"
				if(TRIGGER_PHORON)
					second_effect_trigger = "PHORON"
				if(TRIGGER_OXY)
					second_effect_trigger = "OXY"
				if(TRIGGER_CO2)
					second_effect_trigger = "CO2"
				if(TRIGGER_NITRO)
					second_effect_trigger = "NITRO"
				if(TRIGGER_VIEW)
					second_effect_trigger = "VIEW"

		dat += "<b>SECOND EFFECT:</b> - <a href='?_src_=artifacts;art_c_second_delete=\ref[ART]'>Delete</A> - <a href='?_src_=artifacts;art_c_second_create=\ref[ART]'>Choose a new effect</A><br>"
		dat += "<b>Name:</b> [second_effect_name]<br>"
		dat += "<b>Status:</b> [second_effect_activated] - <a href='?_src_=artifacts;art_c_second_activate=\ref[ART]'>[ART.secondary_effect.activated ? "Deactivate" : "Activate"]</A><br>"
		dat += "<b>Effect Range:</b> [second_effect_effectrange] - <a href='?_src_=artifacts;art_c_second_range=\ref[ART]'>Change</A><br>"
		dat += "<b>Effect Type:</b> [second_effect_type] - <a href='?_src_=artifacts;art_c_second_type=\ref[ART]'>Change</A><br>"
		dat += "<b>Trigger:</b> [second_effect_trigger] - <a href='?_src_=artifacts;art_c_second_trigger=\ref[ART]'>Change</A><br>"
		dat += "<br><hr><br>"

	else
		dat += "<b>SECOND EFFECT:</b> NONE - <a href='?_src_=artifacts;art_c_second_create=\ref[ART]'>Create a new secondary effect</A><br>"
		dat += "<br><hr><br>"

	dat += "</table></tr></td>"

	dat += "<td width='50%'><div align='center'><b><a href='?_src_=artifacts;art_c_secure_icon=\ref[ART]'>[ART.icon_secured ? "Unsecure icon_state" : "Secure icon_state"]</A></b> [ART.icon_secured ? "(It will be changing by itself)" : "(It would not be changed by itself)"]</td></div>"

	usr << browse(entity_ja(dat), "window=artifactconfiguration;size=600x480")

/client/proc/artifacts_Topic(href, href_list, hsrc)
	if(usr.client != src || !holder)
		return
	if(href_list["art_configuration"])
		var/obj/machinery/artifact/A = locate(href_list["art_configuration"])
		artifact_configuration(A)

	else if(href_list["art_c_change_name"])
		if(!check_rights(R_VAREDIT))
			return

		var/obj/machinery/artifact/A = locate(href_list["art_c_change_name"])
		var/newname = sanitize_safe(input(usr, "Enter new name"))
		if(!newname)
			to_chat(usr, "<span class='notice'>You left the field empty, so the name wasn't changed.</span>")
			return
		else
			A.name = "[sanitize(newname)]"

		href_list["art_c_refresh"] = href_list["art_c_change_name"]

	else if(href_list["art_c_first_activate"])
		if(!check_rights(R_VAREDIT))
			return

		var/obj/machinery/artifact/A = locate(href_list["art_c_first_activate"])
		if(A.my_effect)
			if(A.my_effect.activated)
				A.my_effect.activated = FALSE
				to_chat(usr, "<span class='notice'>The first effect is now inactive.</span>")
			else
				A.my_effect.activated = TRUE
				to_chat(usr, "<span class='notice'>The first effect is now active.</span>")
				var/turf/T = get_turf(A)
				var/area/T_area = get_area(T)
				message_admins("<span class='warning'>[src] activated [A.name]'s effect [A.my_effect.effect_name] in [T_area] [ADMIN_JMP(T)].</span>")
				log_game("[src] activated [A.name]'s effect [A.my_effect.effect_name] ([T.x], [T.y], [T.z]) in [T_area].")
			A.update_icon()
		else
			to_chat(usr, "<span class='warning'>There is no effect.</span>")
			return


		href_list["art_c_refresh"] = href_list["art_c_first_activate"]

	else if(href_list["art_c_second_activate"])
		if(!check_rights(R_VAREDIT))
			return

		var/obj/machinery/artifact/A = locate(href_list["art_c_second_activate"])
		if(A.secondary_effect)
			if(A.secondary_effect.activated)
				A.secondary_effect.activated = FALSE
				to_chat(usr, "<span class='notice'>The second effect is now inactive.</span>")
			else
				A.secondary_effect.activated = TRUE
				to_chat(usr, "<span class='notice'>The second effect is now active.</span>")
				var/turf/T = get_turf(A)
				var/area/T_area = get_area(T)
				message_admins("<span class='warning'>[src] activated [A.name]'s effect [A.secondary_effect.effect_name] in [T_area] [ADMIN_JMP(T)].</span>")
				log_game("[src] activated [A.name]'s effect [A.secondary_effect.effect_name] ([T.x], [T.y], [T.z]) in [T_area].")
		else
			to_chat(usr, "<span class='warning'>\The [A] doesn't have a secondary effect.</span>")
			return


		href_list["art_c_refresh"] = href_list["art_c_second_activate"]

	else if(href_list["art_c_first_range"])
		if(!check_rights(R_VAREDIT))
			return

		var/obj/machinery/artifact/A = locate(href_list["art_c_first_range"])
		var/newrange = text2num(input(usr, "Enter new effect range (from 0 to 20. Warning, range bigger than 10 can be very dangerous)"))
		if(newrange > 20 || newrange < 0)
			to_chat(usr, "<span class='warning'>You entered an inappropriate number. Remember, effect range should be from 0 to 20 only.</span>")
			return
		else
			A.my_effect.effectrange = newrange

		href_list["art_c_refresh"] = href_list["art_c_first_range"]

	else if(href_list["art_c_second_range"])
		if(!check_rights(R_VAREDIT))
			return

		var/obj/machinery/artifact/A = locate(href_list["art_c_second_range"])
		if(!A.secondary_effect)
			to_chat(usr, "<span class='warning'>\The [A] doesn't have a secondary effect.</span>")
			return

		var/newrange = text2num(input(usr, "Enter new effect range (from 0 to 20. Warning, range bigger than 10 can be very dangerous)"))
		if(newrange > 20 || newrange < 0)
			to_chat(usr, "<span class='warning'>You entered an inappropriate number. Remember, effect range should be from 0 to 20 only.</span>")
			return
		else
			A.secondary_effect.effectrange = newrange

		href_list["art_c_refresh"] = href_list["art_c_second_range"]

	else if(href_list["art_c_first_type"])
		if(!check_rights(R_VAREDIT))
			return

		var/obj/machinery/artifact/A = locate(href_list["art_c_first_type"])

		var/newtype = input(usr, "Enter new effect type") in list("TOUCH", "PULSE", "AURA")
		if(!newtype)
			to_chat(usr, "<span class='notice'>You left the field empty, so the type wasn't changed.</span>")
			return
		switch(newtype)
			if("TOUCH")
				A.my_effect.effect = EFFECT_TOUCH
			if("PULSE")
				A.my_effect.effect = EFFECT_PULSE
			if("AURA")
				A.my_effect.effect = EFFECT_AURA

		href_list["art_c_refresh"] = href_list["art_c_first_type"]

	else if(href_list["art_c_second_type"])
		if(!check_rights(R_VAREDIT))
			return

		var/obj/machinery/artifact/A = locate(href_list["art_c_second_type"])
		if(!A.secondary_effect)
			to_chat(usr, "<span class='warning'>\The [A] doesn't have a secondary effect.</span>")
			return

		var/newtype = input(usr, "Choose new effect type") in list("Cancel", "TOUCH", "PULSE", "AURA")
		if(!newtype)
			to_chat(usr, "<span class='notice'>You left the field empty, so the type wasn't changed.</span>")
			return
		switch(newtype)
			if("TOUCH")
				A.secondary_effect.effect = EFFECT_TOUCH
			if("PULSE")
				A.secondary_effect.effect = EFFECT_PULSE
			if("AURA")
				A.secondary_effect.effect = EFFECT_AURA

		href_list["art_c_refresh"] = href_list["art_c_second_type"]

	else if(href_list["art_c_first_trigger"])
		if(!check_rights(R_VAREDIT))
			return

		var/obj/machinery/artifact/A = locate(href_list["art_c_first_trigger"])

		var/newtrigger = input("Which sprite would you like to use?") in list("Cancel",
																				"TOUCH",
																				"WATER",
																				"ACID",
																				"VOLATILE",
																				"TOXIN",
																				"FORCE",
																				"ENERGY",
																				"HEAT",
																				"COLD",
																				"PHORON",
																				"OXY",
																				"CO2",
																				"NITRO",
																				"VIEW")
		if(!newtrigger)
			to_chat(usr, "<span class='notice'>You left the field empty, so the trigger wasn't changed.</span>")
			return

		switch(newtrigger)
			if("TOUCH")
				A.my_effect.trigger = TRIGGER_TOUCH
			if("WATER")
				A.my_effect.trigger = TRIGGER_WATER
			if("ACID")
				A.my_effect.trigger = TRIGGER_ACID
			if("VOLATILE")
				A.my_effect.trigger = TRIGGER_VOLATILE
			if("TOXIN")
				A.my_effect.trigger = TRIGGER_TOXIN
			if("FORCE")
				A.my_effect.trigger = TRIGGER_FORCE
			if("ENERGY")
				A.my_effect.trigger = TRIGGER_ENERGY
			if("HEAT")
				A.my_effect.trigger = TRIGGER_HEAT
			if("COLD")
				A.my_effect.trigger = TRIGGER_COLD
			if("PHORON")
				A.my_effect.trigger = TRIGGER_PHORON
			if("OXY")
				A.my_effect.trigger = TRIGGER_OXY
			if("CO2")
				A.my_effect.trigger = TRIGGER_CO2
			if("NITRO")
				A.my_effect.trigger = TRIGGER_NITRO
			if("VIEW")
				A.my_effect.trigger = TRIGGER_VIEW

		href_list["art_c_refresh"] = href_list["art_c_first_trigger"]

	else if(href_list["art_c_second_trigger"])
		if(!check_rights(R_VAREDIT))
			return

		var/obj/machinery/artifact/A = locate(href_list["art_c_second_trigger"])

		if(!A.secondary_effect)
			to_chat(usr, "<span class='warning'>\The [A] doesn't have a secondary effect.</span>")
			return

		var/newtrigger = input("Which sprite would you like to use?") in list("Cancel",
																				"TOUCH",
																				"WATER",
																				"ACID",
																				"VOLATILE",
																				"TOXIN",
																				"FORCE",
																				"ENERGY",
																				"HEAT",
																				"COLD",
																				"PHORON",
																				"OXY",
																				"CO2",
																				"NITRO",
																				"VIEW")
		if(!newtrigger)
			to_chat(usr, "<span class='notice'>You left the field empty, so the trigger wasn't changed.</span>")
			return

		switch(newtrigger)
			if("TOUCH")
				A.secondary_effect.trigger = TRIGGER_TOUCH
			if("WATER")
				A.secondary_effect.trigger = TRIGGER_WATER
			if("ACID")
				A.secondary_effect.trigger = TRIGGER_ACID
			if("VOLATILE")
				A.secondary_effect.trigger = TRIGGER_VOLATILE
			if("TOXIN")
				A.secondary_effect.trigger = TRIGGER_TOXIN
			if("FORCE")
				A.secondary_effect.trigger = TRIGGER_FORCE
			if("ENERGY")
				A.secondary_effect.trigger = TRIGGER_ENERGY
			if("HEAT")
				A.secondary_effect.trigger = TRIGGER_HEAT
			if("COLD")
				A.secondary_effect.trigger = TRIGGER_COLD
			if("PHORON")
				A.secondary_effect.trigger = TRIGGER_PHORON
			if("OXY")
				A.secondary_effect.trigger = TRIGGER_OXY
			if("CO2")
				A.secondary_effect.trigger = TRIGGER_CO2
			if("NITRO")
				A.secondary_effect.trigger = TRIGGER_NITRO
			if("VIEW")
				A.secondary_effect.trigger = TRIGGER_VIEW

		href_list["art_c_refresh"] = href_list["art_c_second_trigger"]

	else if(href_list["art_c_second_delete"])
		if(!check_rights(R_VAREDIT))
			return

		var/obj/machinery/artifact/A = locate(href_list["art_c_second_delete"])
		if(A.secondary_effect)
			var/choice = input("Are you sure you want to delete this [A.secondary_effect.effect_name] effect?") in list("Yes", "No")
			if(choice == "Yes")
				if(A.secondary_effect.activated)
					A.secondary_effect.activated = FALSE
				A.secondary_effect = null
			else
				return
		else
			to_chat(usr, "<span class='warning'>There is no second effect.</span>")
			return


		href_list["art_c_refresh"] = href_list["art_c_second_delete"]

	else if(href_list["art_c_first_create"])
		if(!check_rights(R_VAREDIT))
			return

		var/obj/machinery/artifact/A = locate(href_list["art_c_first_create"])
		var/choice = input("Choose an effect type") in all_artifact_effect_types
		if(choice)
			if(A.my_effect)
				if(A.my_effect.activated)
					A.my_effect.activated = FALSE
				A.my_effect = null
			A.my_effect = new choice(A)
			A.update_icon()
		else
			return

		href_list["art_c_refresh"] = href_list["art_c_first_create"]

	else if(href_list["art_c_second_create"])
		if(!check_rights(R_VAREDIT))
			return

		var/obj/machinery/artifact/A = locate(href_list["art_c_second_create"])
		var/choice = input("Choose an effect type") in all_artifact_effect_types
		if(choice)
			if(A.secondary_effect)
				if(A.secondary_effect.activated)
					A.secondary_effect.activated = FALSE
				A.secondary_effect = null
			A.secondary_effect = new choice(A)
		else
			return

		href_list["art_c_refresh"] = href_list["art_c_second_create"]

	else if(href_list["art_c_change_icon"])
		if(!check_rights(R_VAREDIT))
			return

		var/obj/machinery/artifact/A = locate(href_list["art_c_change_icon"])
		var/choice_icon = input("Which sprite would you like to use?") in list("Cancel",
																				"WIZARD_LARGE",
																				"WIZARD_SMALL",
																				"MARTIAN_LARGE",
																				"MARTIAN_SMALL",
																				"MARTIAN_PINK",
																				"CUBE",
																				"PILLAR",
																				"COMPUTER",
																				"VENTS",
																				"FLOATING",
																				"CRYSTAL_GREEN",
																				"CRYSTAL_PURPLE",
																				"CRYSTAL_BLUE")
		if(!choice_icon)
			to_chat(usr, "<span class='notice'>You left the field empty, so the icon wasn't changed.</span>")
			return

		A.icon = 'icons/obj/xenoarchaeology/artifacts.dmi'

		switch(choice_icon)
			if("WIZARD_LARGE")
				A.icon_num = ARTIFACT_WIZARD_LARGE
			if("WIZARD_SMALL")
				A.icon_num = ARTIFACT_WIZARD_SMALL
			if("MARTIAN_LARGE")
				A.icon_num = ARTIFACT_MARTIAN_LARGE
			if("MARTIAN_SMALL")
				A.icon_num = ARTIFACT_MARTIAN_SMALL
			if("MARTIAN_PINK")
				A.icon_num = ARTIFACT_MARTIAN_PINK
			if("CUBE")
				A.icon_num = ARTIFACT_CUBE
			if("PILLAR")
				A.icon_num = ARTIFACT_PILLAR
			if("COMPUTER")
				A.icon_num = ARTIFACT_COMPUTER
			if("VENTS")
				A.icon_num = ARTIFACT_VENTS
			if("FLOATING")
				A.icon_num = ARTIFACT_FLOATING
			if("CRYSTAL_GREEN")
				A.icon_num = ARTIFACT_CRYSTAL_GREEN
			if("CRYSTAL_PURPLE")
				A.icon_num = ARTIFACT_CRYSTAL_PURPLE
			if("CRYSTAL_BLUE")
				A.icon_num = ARTIFACT_CRYSTAL_BLUE

		A.update_icon()

		href_list["art_c_refresh"] = href_list["art_c_change_icon"]

	else if(href_list["art_c_secure_icon"])
		if(!check_rights(R_VAREDIT))
			return

		var/obj/machinery/artifact/A = locate(href_list["art_c_secure_icon"])

		A.icon_secured = !A.icon_secured

		if(A.icon_secured)
			to_chat(usr, "<span class='notice'>The [A]'s icon_state is now secured, so it wouldn't change by itself.</span>")
		else
			to_chat(usr, "<span class='notice'>The [A]'s icon_state is now unsecured, so it will be changing by itself.</span>")
			A.update_icon()

		href_list["art_c_refresh"] = href_list["art_c_secure_icon"]

	if(href_list["art_c_refresh"])
		var/obj/machinery/artifact/A = locate(href_list["art_c_refresh"])
		artifact_configuration(A)

	return
