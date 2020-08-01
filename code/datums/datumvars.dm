// reference: /client/proc/modify_variables(atom/O, param_var_name = null, autodetect_class = 0)

/datum/proc/on_varedit(modified_var) //called whenever a var is edited
	return

/client/proc/debug_variables(datum/D in world)
	set category = "Debug"
	set name = "View Variables"
	//set src in world

	if(!usr.client || !usr.client.holder)
		to_chat(usr, "<span class='warning'>You need to be an administrator to access this.</span>")
		return

	if(!check_rights(R_DEBUG|R_VAREDIT|R_LOG)) // Since client.holder still doesn't mean we have permissions...
		return

	var/title = ""
	var/body = ""

	if(!D)	return
	if(istype(D, /atom))
		var/atom/A = D
		title = "[A.name] (\ref[A]) = [A.type]"

		#ifdef VARSICON
		if (A.icon)
			body += debug_variable("icon", new/icon(A.icon, A.icon_state, A.dir), 0)
		#endif

	var/sprite

	if(istype(D,/atom))
		var/atom/AT = D
		if(AT.icon && AT.icon_state)
			sprite = 1

	title = "[D] (\ref[D]) = [D.type]"

	body += {"<script type="text/javascript">

				function updateSearch(){
					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if(event.keyCode == 13){	//Enter / return
						var vars_ol = document.getElementById('vars');
						var lis = vars_ol.getElementsByTagName("li");
						for ( var i = 0; i < lis.length; ++i )
						{
							try{
								var li = lis\[i\];
								if ( li.style.backgroundColor == "#ffee88" )
								{
									alist = lis\[i\].getElementsByTagName("a")
									if(alist.length > 0){
										location.href=alist\[0\].href;
									}
								}
							}catch(err) {   }
						}
						return
					}

					if(event.keyCode == 38){	//Up arrow
						var vars_ol = document.getElementById('vars');
						var lis = vars_ol.getElementsByTagName("li");
						for ( var i = 0; i < lis.length; ++i )
						{
							try{
								var li = lis\[i\];
								if ( li.style.backgroundColor == "#ffee88" )
								{
									if( (i-1) >= 0){
										var li_new = lis\[i-1\];
										li.style.backgroundColor = "white";
										li_new.style.backgroundColor = "#ffee88";
										return
									}
								}
							}catch(err) {  }
						}
						return
					}

					if(event.keyCode == 40){	//Down arrow
						var vars_ol = document.getElementById('vars');
						var lis = vars_ol.getElementsByTagName("li");
						for ( var i = 0; i < lis.length; ++i )
						{
							try{
								var li = lis\[i\];
								if ( li.style.backgroundColor == "#ffee88" )
								{
									if( (i+1) < lis.length){
										var li_new = lis\[i+1\];
										li.style.backgroundColor = "white";
										li_new.style.backgroundColor = "#ffee88";
										return
									}
								}
							}catch(err) {  }
						}
						return
					}

					//This part here resets everything to how it was at the start so the filter is applied to the complete list. Screw efficiency, it's client-side anyway and it only looks through 200 or so variables at maximum anyway (mobs).
					if(complete_list != null && complete_list != ""){
						var vars_ol1 = document.getElementById("vars");
						vars_ol1.innerHTML = complete_list
					}

					if(filter.value == ""){
						return;
					}else{
						var vars_ol = document.getElementById('vars');
						var lis = vars_ol.getElementsByTagName("li");

						for ( var i = 0; i < lis.length; ++i )
						{
							try{
								var li = lis\[i\];
								if ( li.innerText.toLowerCase().indexOf(filter) == -1 )
								{
									vars_ol.removeChild(li);
									i--;
								}
							}catch(err) {   }
						}
					}
					var lis_new = vars_ol.getElementsByTagName("li");
					for ( var j = 0; j < lis_new.length; ++j )
					{
						var li1 = lis\[j\];
						if (j == 0){
							li1.style.backgroundColor = "#ffee88";
						}else{
							li1.style.backgroundColor = "white";
						}
					}
				}



				function selectTextField(){
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();

				}

				function loadPage(list) {

					if(list.options\[list.selectedIndex\].value == ""){
						return;
					}

					location.href=list.options\[list.selectedIndex\].value;

				}
			</script> "}

	body += "<body onload='selectTextField(); updateSearch()' onkeyup='updateSearch()'>"

	body += "<div align='center'><table width='100%'><tr><td width='50%'>"

	if(sprite)
		body += "<table align='center' width='100%'><tr><td>[bicon(D, use_class = 0)]</td><td>"
	else
		body += "<table align='center' width='100%'><tr><td>"

	body += "<div align='center'>"

	if(istype(D,/atom))
		var/atom/A = D
		if(isliving(A))
			body += "<a href='?_src_=vars;rename=\ref[D]'><b>[D]</b></a>"
			if(A.dir)
				body += "<br><font size='1'><a href='?_src_=vars;rotatedatum=\ref[D];rotatedir=left'><<</a> <a href='?_src_=vars;datumedit=\ref[D];varnameedit=dir'>[dir2text(A.dir)]</a> <a href='?_src_=vars;rotatedatum=\ref[D];rotatedir=right'>>></a></font>"
			var/mob/living/M = A
			body += "<br><font size='1'><a href='?_src_=vars;datumedit=\ref[D];varnameedit=ckey'>[M.ckey ? M.ckey : "No ckey"]</a> / <a href='?_src_=vars;datumedit=\ref[D];varnameedit=real_name'>[M.real_name ? M.real_name : "No real name"]</a></font>"
			body += {"
			<br><font size='1'>
			BRUTE:<a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=brute'>[M.getBruteLoss()]</a>
			FIRE:<a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=fire'>[M.getFireLoss()]</a>
			TOXIN:<a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=toxin'>[M.getToxLoss()]</a>
			OXY:<a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=oxygen'>[M.getOxyLoss()]</a>
			CLONE:<a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=clone'>[M.getCloneLoss()]</a>
			BRAIN:<a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=brain'>[M.getBrainLoss()]</a>
			</font>


			"}
		else
			body += "<a href='?_src_=vars;datumedit=\ref[D];varnameedit=name'><b>[D]</b></a>"
			if(A.dir)
				body += "<br><font size='1'><a href='?_src_=vars;rotatedatum=\ref[D];rotatedir=left'><<</a> <a href='?_src_=vars;datumedit=\ref[D];varnameedit=dir'>[dir2text(A.dir)]</a> <a href='?_src_=vars;rotatedatum=\ref[D];rotatedir=right'>>></a></font>"
	else
		body += "<b>[D]</b>"

	body += "</div>"

	body += "</tr></td></table>"

	var/formatted_type = text("[D.type]")
	if(length(formatted_type) > 25)
		var/middle_point = length(formatted_type) / 2
		var/splitpoint = findtext(formatted_type,"/",middle_point)
		if(splitpoint)
			formatted_type = "[copytext(formatted_type,1,splitpoint)]<br>[copytext(formatted_type,splitpoint)]"
		else
			formatted_type = "Type too long" //No suitable splitpoint (/) found.

	body += "<div align='center'><b><font size='1'>[formatted_type]</font></b>"

	if(src.holder && src.holder.marked_datum && src.holder.marked_datum == D)
		body += "<br><font size='1' color='red'><b>Marked Object</b></font>"

	body += "</div>"

	body += "</div></td>"

	body += "<td width='50%'><div align='center'><a href='?_src_=vars;datumrefresh=\ref[D]'>Refresh</a>"

	//if(ismob(D))
	//	body += "<br><a href='?_src_=vars;mob_player_panel=\ref[D]'>Show player panel</a></div></td></tr></table></div><hr>"

	body += {"	<form>
				<select name="file" size="1"
				onchange="loadPage(this.form.elements\[0\])"
				target="_parent._top"
				onmouseclick="this.focus()"
				style="background-color:#ffffff">
			"}

	body += {"	<option value>Select option</option>
				<option value> </option>
			"}


	body += "<option value='?_src_=vars;mark_object=\ref[D]'>Mark Object</option>"
	if(ismob(D))
		body += "<option value='?_src_=vars;mob_player_panel=\ref[D]'>Show player panel</option>"
	if(istype(D, /atom/movable))
		body += "<option value='?_src_=holder;adminplayerobservefollow=\ref[D]'>Follow</option>"
	else
		var/atom/A = D
		if(istype(A))
			body += "<option value='?_src_=holder;adminplayerobservecoodjump=1;X=[A.x];Y=[A.y];Z=[A.z]'>Jump to</option>"

	body += "<option value>---</option>"

	if(ismob(D))
		body += "<option value='?_src_=vars;give_spell=\ref[D]'>Give Spell</option>"
		body += "<option value='?_src_=vars;give_disease2=\ref[D]'>Give Disease</option>"
		if(isliving(D))
			body += "<option value='?_src_=vars;give_status_effect=\ref[D]'>Give Status Effect</option>"
		body += "<option value='?_src_=vars;give_disease=\ref[D]'>Give TG-style Disease</option>"
		body += "<option value='?_src_=vars;godmode=\ref[D]'>Toggle Godmode</option>"
		body += "<option value='?_src_=vars;build_mode=\ref[D]'>Toggle Build Mode</option>"

		body += "<option value='?_src_=vars;ninja=\ref[D]'>Make Space Ninja</option>"

		body += "<option value='?_src_=vars;direct_control=\ref[D]'>Assume Direct Control</option>"
		body += "<option value='?_src_=vars;drop_everything=\ref[D]'>Drop Everything</option>"

		body += "<option value='?_src_=vars;regenerateicons=\ref[D]'>Regenerate Icons</option>"
		body += "<option value='?_src_=vars;addlanguage=\ref[D]'>Add Language</option>"
		body += "<option value='?_src_=vars;remlanguage=\ref[D]'>Remove Language</option>"

		body += "<option value='?_src_=vars;fix_nano=\ref[D]'>Fix NanoUI</option>"

		body += "<option value='?_src_=vars;addverb=\ref[D]'>Add Verb</option>"
		body += "<option value='?_src_=vars;remverb=\ref[D]'>Remove Verb</option>"
		body += "<option value='?_src_=vars;setckey=\ref[D]'>Set Client</option>"
		if(ishuman(D))
			body += "<option value>---</option>"
			body += "<option value='?_src_=vars;setmutantrace=\ref[D]'>Set Mutantrace</option>"
			body += "<option value='?_src_=vars;setspecies=\ref[D]'>Set Species</option>"
			body += "<option value='?_src_=vars;makeai=\ref[D]'>Make AI</option>"
			body += "<option value='?_src_=vars;makerobot=\ref[D]'>Make cyborg</option>"
			body += "<option value='?_src_=vars;makemonkey=\ref[D]'>Make monkey</option>"
			body += "<option value='?_src_=vars;makealien=\ref[D]'>Make alien</option>"
			body += "<option value='?_src_=vars;makeslime=\ref[D]'>Make slime</option>"
			body += "<option value='?_src_=vars;makezombie=\ref[D]'>Make zombie</option>"
		body += "<option value>---</option>"
		body += "<option value='?_src_=vars;gib=\ref[D]'>Gib</option>"
		body += "<option value='?_src_=vars;dust=\ref[D]'>Turn to dust</option>"
	if(isatom(D))
		body += "<option value='?_src_=vars;delthis=\ref[D]'>Delete this object</option>"
	if(isobj(D))
		body += "<option value='?_src_=vars;delall=\ref[D]'>Delete all of type</option>"
	if(isobj(D) || ismob(D) || isturf(D))
		body += "<option value='?_src_=vars;explode=\ref[D]'>Trigger explosion</option>"
		body += "<option value='?_src_=vars;emp=\ref[D]'>Trigger EM pulse</option>"

	body += "</select></form>"

	body += "</div></td></tr></table></div><hr>"

	body += "<font size='1'><b>E</b> - Edit, tries to determine the variable type by itself.<br>"
	body += "<b>C</b> - Change, asks you for the var type first.<br>"
	body += "<b>M</b> - Mass modify: changes this variable for all objects of this type.</font><br>"

	body += "<hr><table width='100%'><tr><td width='20%'><div align='center'><b>Search:</b></div></td><td width='80%'><input type='text' id='filter' name='filter_text' value='' style='width:100%;'></td></tr></table><hr>"

	body += "<ol id='vars'>"

	var/list/names = list()
	for (var/V in D.vars)
		if((V in VE_HIDDEN_LOG) && !check_rights(R_LOG, show_msg = FALSE))
			continue
		names += V

	names = sortList(names)

	for (var/V in names)
		body += debug_variable(V, D.vars[V], 0, D)

	body += "</ol>"

	var/html = "<html><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'>"
	if (title)
		html += "<title>[title]</title>"
	html += {"<style>
body
{
	font-family: Verdana, sans-serif;
	font-size: 9pt;
}
.value
{
	font-family: "Courier New", monospace;
	font-size: 8pt;
}
</style>"}
	html += "</head>"
	html += body

	html += {"
		<script type='text/javascript'>
			var vars_ol = document.getElementById("vars");
			var complete_list = vars_ol.innerHTML;
		</script>
	"}

	html += "</body></html>"

	usr << browse(html, "window=variables\ref[D];size=475x650")

	return

/client/proc/debug_variable(name, value, level, datum/DA = null)
	var/html = ""

	if(DA)
		html += "<li style='backgroundColor:white'>(<a href='?_src_=vars;datumedit=\ref[DA];varnameedit=[name]'>E</a>) (<a href='?_src_=vars;datumchange=\ref[DA];varnamechange=[name]'>C</a>) (<a href='?_src_=vars;datummass=\ref[DA];varnamemass=[name]'>M</a>) "
	else
		html += "<li>"

	if (isnull(value))
		html += "[name] = <span class='value'>null</span>"

	else if (istext(value))
		html += "[name] = <span class='value'>\"[value]\"</span>"

	else if (isicon(value))
		#ifdef VARSICON
		html += "[name] = /icon (<span class='value'>[value]</span>) [bicon(value, use_class = 0)]"
		#else
		html += "[name] = /icon (<span class='value'>[value]</span>)"
		#endif

	else if (istype(value, /image))
		#ifdef VARSICON
		html += "<a href='?_src_=vars;Vars=\ref[value]'>[name] \ref[value]</a> = /image (<span class='value'>[value]</span>) [bicon(value, use_class = 0)]"
		#else
		html += "<a href='?_src_=vars;Vars=\ref[value]'>[name] \ref[value]</a> = /image (<span class='value'>[value]</span>)"
		#endif

	else if (isfile(value))
		html += "[name] = <span class='value'>'[value]'</span>"

	else if (istype(value, /datum))
		var/datum/D = value
		html += "<a href='?_src_=vars;Vars=\ref[value]'>[name] \ref[value]</a> = [D.type]"

	else if (istype(value, /client))
		var/client/C = value
		html += "<a href='?_src_=vars;Vars=\ref[value]'>[name] \ref[value]</a> = [C] [C.type]"
//
	else if (istype(value, /list))
		var/list/L = value
		html += "[name] = /list ([L.len])"

		if (L.len > 0 && !(name == "underlays" || name == "overlays" || name == "vars" || L.len > 500))
			html += "<ul>"
			var/index = 1
			for (var/entry in L)
				if(istext(entry))
					html += debug_variable(entry, L[entry], level + 1)
				//html += debug_variable("[index]", L[index], level + 1)
				else
					html += debug_variable(index, L[index], level + 1)
				index++
			html += "</ul>"

	else if (name in global.bitfields)
		var/list/flags = list()
		for (var/i in global.bitfields[name])
			if (value & global.bitfields[name][i])
				flags += i
		html += "[name] = <span class='value'>[jointext(flags, ", ")]</span>"

	else
		html += "[name] = <span class='value'>[value]</span>"

	html += "</li>"

	return html

/client/proc/view_var_Topic(href, href_list, hsrc)
	//This should all be moved over to datum/admins/Topic() or something ~Carn
	if(usr.client != src || !holder)
		return
	if(href_list["Vars"])
		if(!check_rights(R_DEBUG|R_VAREDIT|R_LOG))
			return
		debug_variables(locate(href_list["Vars"]))

	//~CARN: for renaming mobs (updates their name, real_name, mind.name, their ID/PDA and datacore records).
	else if(href_list["rename"])
		if(!check_rights(R_VAREDIT))
			return

		var/mob/M = locate(href_list["rename"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		var/new_name = sanitize_safe(input(usr,"What would you like to name this mob?","Input a name",input_default(M.real_name)) as text|null, MAX_NAME_LEN)
		if(!new_name || !M)
			return

		message_admins("Admin [key_name_admin(usr)] renamed [key_name_admin(M)] to [new_name].")
		M.fully_replace_character_name(M.real_name,new_name)
		href_list["datumrefresh"] = href_list["rename"]

	else if(href_list["varnameedit"] && href_list["datumedit"])
		if(!check_rights(R_VAREDIT))
			return

		var/D = locate(href_list["datumedit"])
		if(!istype(D,/datum) && !istype(D,/client))
			to_chat(usr, "This can only be used on instances of types /client or /datum")
			return

		modify_variables(D, href_list["varnameedit"], 1)

	else if(href_list["varnamechange"] && href_list["datumchange"])
		if(!check_rights(R_VAREDIT))
			return

		var/D = locate(href_list["datumchange"])
		if(!istype(D,/datum) && !istype(D,/client))
			to_chat(usr, "This can only be used on instances of types /client or /datum")
			return

		modify_variables(D, href_list["varnamechange"], 0)

	else if(href_list["varnamemass"] && href_list["datummass"])
		if(!check_rights(R_VAREDIT))
			return

		var/atom/A = locate(href_list["datummass"])
		if(!istype(A))
			to_chat(usr, "This can only be used on instances of type /atom")
			return

		cmd_mass_modify_object_variables(A, href_list["varnamemass"])

	else if(href_list["mob_player_panel"])
		if(!check_rights(0))
			return

		var/mob/M = locate(href_list["mob_player_panel"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.holder.show_player_panel(M)
		href_list["datumrefresh"] = href_list["mob_player_panel"]

	else if(href_list["give_spell"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/M = locate(href_list["give_spell"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.give_spell(M)
		href_list["datumrefresh"] = href_list["give_spell"]

	else if(href_list["give_disease"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/M = locate(href_list["give_disease"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.give_disease(M)
		href_list["datumrefresh"] = href_list["give_spell"]

	else if(href_list["give_disease2"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/M = locate(href_list["give_disease2"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.give_disease2(M)
		href_list["datumrefresh"] = href_list["give_spell"]

	else if(href_list["give_status_effect"])
		if(!check_rights(R_ADMIN|R_VAREDIT))
			return

		var/mob/living/L = locate(href_list["give_status_effect"])
		if(!isliving(L))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		var/list/params = admin_spawn_status_effect(usr)

		if(params)
			L.apply_status_effect(arglist(params))
			href_list["datumrefresh"] = href_list["give_status_effect"]

	else if(href_list["ninja"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/M = locate(href_list["ninja"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.cmd_admin_ninjafy(M)
		href_list["datumrefresh"] = href_list["ninja"]

	else if(href_list["godmode"])
		if(!check_rights(R_REJUVINATE))
			return

		var/mob/M = locate(href_list["godmode"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.cmd_admin_godmode(M)
		href_list["datumrefresh"] = href_list["godmode"]

	else if(href_list["gib"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/M = locate(href_list["gib"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.cmd_admin_gib(M)

	else if(href_list["dust"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/M = locate(href_list["dust"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.cmd_admin_dust(M)

	else if(href_list["build_mode"])
		if(!check_rights(R_BUILDMODE))
			return

		var/mob/M = locate(href_list["build_mode"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		togglebuildmode(M)
		href_list["datumrefresh"] = href_list["build_mode"]

	else if(href_list["drop_everything"])
		if(!check_rights(R_ADMIN|R_VAREDIT))
			return

		var/mob/M = locate(href_list["drop_everything"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(usr.client)
			usr.client.cmd_admin_drop_everything(M)

	else if(href_list["direct_control"])
		if(!check_rights(0))
			return

		var/mob/M = locate(href_list["direct_control"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(usr.client)
			usr.client.cmd_assume_direct_control(M)

	else if(href_list["delthis"])
		//Rights check are in cmd_admin_delete() proc
		var/atom/A = locate(href_list["delthis"])
		cmd_admin_delete(A)

	else if(href_list["delall"])
		if(!check_rights(R_DEBUG|R_SERVER))
			return

		var/obj/O = locate(href_list["delall"])
		if(!isobj(O))
			to_chat(usr, "This can only be used on instances of type /obj")
			return

		var/action_type = alert("Strict type ([O.type]) or type and all subtypes?",,"Strict type","Type and subtypes","Cancel")
		if(action_type == "Cancel" || !action_type)
			return

		if(alert("Are you really sure you want to delete all objects of type [O.type]?",,"Yes","No") != "Yes")
			return

		if(alert("Second confirmation required. Delete?",,"Yes","No") != "Yes")
			return

		var/O_type = O.type
		switch(action_type)
			if("Strict type")
				var/i = 0
				for(var/obj/Obj in world)
					if(Obj.type == O_type)
						i++
						qdel(Obj)
					CHECK_TICK
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
				log_admin("[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted) ")
				message_admins("<span class='notice'>[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted) </span>")
			if("Type and subtypes")
				var/i = 0
				for(var/obj/Obj in world)
					if(istype(Obj,O_type))
						i++
						qdel(Obj)
					CHECK_TICK
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
				log_admin("[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted) ")
				message_admins("<span class='notice'>[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted) </span>")

	else if(href_list["explode"])
		if(!check_rights(R_DEBUG|R_FUN))
			return

		var/atom/A = locate(href_list["explode"])
		if(!isobj(A) && !ismob(A) && !isturf(A))
			to_chat(usr, "This can only be done to instances of type /obj, /mob and /turf")
			return

		src.cmd_admin_explosion(A)
		href_list["datumrefresh"] = href_list["explode"]

	else if(href_list["emp"])
		if(!check_rights(R_DEBUG|R_FUN))
			return

		var/atom/A = locate(href_list["emp"])
		if(!isobj(A) && !ismob(A) && !isturf(A))
			to_chat(usr, "This can only be done to instances of type /obj, /mob and /turf")
			return

		src.cmd_admin_emp(A)
		href_list["datumrefresh"] = href_list["emp"]

	else if(href_list["mark_object"])
		if(!check_rights(0))
			return

		var/datum/D = locate(href_list["mark_object"])
		if(!istype(D))
			to_chat(usr, "This can only be done to instances of type /datum")
			return

		src.holder.marked_datum = D
		href_list["datumrefresh"] = href_list["mark_object"]

	else if(href_list["rotatedatum"])
		if(!check_rights(0))
			return

		var/atom/A = locate(href_list["rotatedatum"])
		if(!istype(A))
			to_chat(usr, "This can only be done to instances of type /atom")
			return

		switch(href_list["rotatedir"])
			if("right")	A.dir = turn(A.dir, -45)
			if("left")	A.dir = turn(A.dir, 45)
		href_list["datumrefresh"] = href_list["rotatedatum"]

	else if(href_list["makemonkey"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makemonkey"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("monkeyone"=href_list["makemonkey"]))

	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makerobot"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makerobot"=href_list["makerobot"]))

	else if(href_list["makealien"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makealien"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makealien"=href_list["makealien"]))

	else if(href_list["makeslime"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makeslime"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makeslime"=href_list["makeslime"]))

	else if(href_list["makezombie"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makezombie"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		switch(input("Zombie menu", "Select action", "Cancel") in list("Turn into zombie instantly", "Infect with slow zombie virus (10-20 min)", "Infect with fast zombie virus (~3 min)", "Make immune to zombie virus", "Make vulnerable to zombie virus", "Cancel"))
			if("Turn into zombie instantly")
				if(H)
					H.zombify()
					to_chat(usr, "[H] is now a zombie")
					log_admin("[key_name(usr)] turned [key_name(H)] into a zombie.")
					message_admins("[key_name_admin(usr)] turned [key_name(H)] into a zombie.")
			if("Infect with slow zombie virus (10-20 min)")
				if(H)
					H.infect_zombie_virus(target_zone = null, forced = TRUE, fast = FALSE)
					to_chat(usr, "[H] is now infected with slow zombie virus")
					log_admin("[key_name(usr)] infected [key_name(H)] with slow zombie virus.")
					message_admins("[key_name_admin(usr)] infected [key_name(H)] with slow zombie virus.")
			if("Infect with fast zombie virus (~3 min)")
				if(H)
					H.infect_zombie_virus(target_zone = null, forced = TRUE, fast = TRUE)
					to_chat(usr, "[H] is now infected with fast zombie virus")
					log_admin("[key_name(usr)] infected [key_name(H)] with fast zombie virus.")
					message_admins("[key_name_admin(usr)] infected [key_name(H)] with fast zombie virus.")
			if("Make immune to zombie virus")
				if(H)
					H.antibodies |= ANTIGEN_Z
					to_chat(usr, "[H] is now immune to zombie virus")
					log_admin("[key_name(usr)] made [key_name(H)] immune to zombie virus.")
					message_admins("[key_name_admin(usr)] made [key_name(H)] immune to zombie virus.")
			if("Make vulnerable to zombie virus")
				if(H)
					H.antibodies &= ~ANTIGEN_Z
					to_chat(usr, "[H] is now vulnerable to zombie virus")
					log_admin("[key_name(usr)] made [key_name(H)] vulnerable to zombie virus.")
					message_admins("[key_name_admin(usr)] made [key_name(H)] vulnerable to zombie virus.")

		holder.Topic(href, list("makezombie"=href_list["makezombie"]))

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makeai"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makeai"=href_list["makeai"]))

	else if(href_list["setmutantrace"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["setmutantrace"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		var/new_mutantrace = input("Please choose a new mutantrace","Mutantrace",null) as null|anything in list("NONE","adamantine","golem","shadow","shadowling","slime")
		switch(new_mutantrace)
			if(null)
				return
			if("NONE")
				new_mutantrace = ""
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(H.dna)
			H.dna.mutantrace = new_mutantrace
			H.update_mutantrace()

	else if(href_list["setspecies"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["setspecies"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		var/new_species = input("Please choose a new species.","Species",null) as null|anything in all_species

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(H.set_species(new_species))
			to_chat(usr, "Set species of [H] to [H.species].")
			H.regenerate_icons()
		else
			to_chat(usr, "Failed! Something went wrong.")

	else if(href_list["addlanguage"])
		if(!check_rights(R_VAREDIT))
			return

		var/mob/H = locate(href_list["addlanguage"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob")
			return

		var/new_language = input("Please choose a language to add.","Language",null) as null|anything in all_languages

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(H.add_language(new_language))
			to_chat(usr, "Added [new_language] to [H].")
		else
			to_chat(usr, "Mob already knows that language.")

	else if(href_list["remlanguage"])
		if(!check_rights(R_VAREDIT))
			return

		var/mob/H = locate(href_list["remlanguage"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob")
			return

		if(!H.languages.len)
			to_chat(usr, "This mob knows no languages.")
			return

		var/datum/language/rem_language = input("Please choose a language to remove.","Language",null) as null|anything in H.languages

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(H.remove_language(rem_language.name))
			to_chat(usr, "Removed [rem_language] from [H].")
		else
			to_chat(usr, "Mob doesn't know that language.")

	else if(href_list["addverb"])
		if(!check_rights(R_DEBUG))
			return

		var/mob/living/H = locate(href_list["addverb"])

		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living")
			return
		var/list/possibleverbs = list()
		possibleverbs += "Cancel" 								// One for the top...
		possibleverbs += typesof(/mob/proc,/mob/verb,/mob/living/proc,/mob/living/verb)
		switch(H.type)
			if(/mob/living/carbon/human)
				possibleverbs += typesof(/mob/living/carbon/proc,/mob/living/carbon/verb,/mob/living/carbon/human/verb,/mob/living/carbon/human/proc)
			if(/mob/living/silicon/robot)
				possibleverbs += typesof(/mob/living/silicon/proc,/mob/living/silicon/robot/proc,/mob/living/silicon/robot/verb)
			if(/mob/living/silicon/ai)
				possibleverbs += typesof(/mob/living/silicon/proc,/mob/living/silicon/ai/proc,/mob/living/silicon/ai/verb)
		possibleverbs -= H.verbs
		possibleverbs += "Cancel" 								// ...And one for the bottom

		var/verb = input("Select a verb!", "Verbs",null) as anything in possibleverbs
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(!verb || verb == "Cancel")
			return
		else
			H.verbs += verb

	else if(href_list["remverb"])
		if(!check_rights(R_DEBUG))
			return

		var/mob/H = locate(href_list["remverb"])

		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob")
			return
		var/verb = input("Please choose a verb to remove.","Verbs",null) as null|anything in H.verbs
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(!verb)
			return
		else
			H.verbs -= verb


	else if(href_list["fix_nano"])
		if(!check_rights(R_DEBUG))
			return

		var/mob/H = locate(href_list["fix_nano"])

		if(!istype(H) || !H.client)
			to_chat(usr, "This can only be done on mobs with clients")
			return

		H.client.reload_nanoui_resources()

		to_chat(usr, "Resource files sent")
		log_admin("[key_name(usr)] resent the NanoUI resource files to [key_name(H)] ")


	else if(href_list["regenerateicons"])
		if(!check_rights(0))
			return

		var/mob/M = locate(href_list["regenerateicons"])
		if(!ismob(M))
			to_chat(usr, "This can only be done to instances of type /mob")
			return
		M.regenerate_icons()

	else if(href_list["adjustDamage"] && href_list["mobToDamage"])
		if(!check_rights(R_DEBUG|R_ADMIN|R_FUN))
			return

		var/mob/living/L = locate(href_list["mobToDamage"])
		if(!istype(L)) return

		var/Text = href_list["adjustDamage"]

		var/amount =  input("Deal how much damage to mob? (Negative values here heal)","Adjust [Text]loss",0) as num

		if(!L)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		switch(Text)
			if("brute")	L.adjustBruteLoss(amount)
			if("fire")	L.adjustFireLoss(amount)
			if("toxin")	L.adjustToxLoss(amount)
			if("oxygen")L.adjustOxyLoss(amount)
			if("brain")	L.adjustBrainLoss(amount)
			if("clone")	L.adjustCloneLoss(amount)
			else
				to_chat(usr, "You caused an error. DEBUG: Text:[Text] Mob:[L]")
				return

		if(amount != 0)
			log_admin("[key_name(usr)] dealt [amount] amount of [Text] damage to [L] ")
			message_admins("<span class='notice'>[key_name(usr)] dealt [amount] amount of [Text] damage to [L] </span>")
			href_list["datumrefresh"] = href_list["mobToDamage"]

	else if(href_list["setckey"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/C = locate(href_list["setckey"])
		if(C.ckey && C.ckey[1] != "@")
			if(alert("This mob already controlled by [C.ckey]. Are you sure you want to continue?",,"Cancel","Continue") != "Continue")
				return

		var/list/clients_list = clients + "Cancel"
		var/client/new_client = input("Select client:","Clients","Cancel") in clients_list

		if(new_client == "Cancel") return

		message_admins("<span class='notice'>[key_name_admin(usr)] set client [new_client.ckey] to [C.name].</span>", 1)
		log_admin("[key_name(usr)] set client [new_client.ckey] to [C.name].")

		C.ckey = new_client.ckey

	if(href_list["datumrefresh"])
		var/datum/DAT = locate(href_list["datumrefresh"])
		if(!istype(DAT, /datum))
			return
		src.debug_variables(DAT)

	return
