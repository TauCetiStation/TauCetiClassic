/datum/preferences/proc/ShowCustomKeybindings(mob/user)
	if(!key_bindings.len)
		. += "Этот текст вы можете видеть только при ошибке со стороны кода.<br>"
		. += "Попробуйте нажать сверху кнопку Reload Slot. Если это не помогло, то подождите рестарт."
		. += "Можете так же сообщить о проблеме в гитхаб репозитория."
		return

	// Create an inverted list of keybindings -> key
	var/list/user_binds = list()
	for (var/key in key_bindings)
		for(var/kb_name in key_bindings[key])
			user_binds[kb_name] += list(key)

	var/list/kb_categories = list()
	// Group keybinds by category
	for (var/name in global.keybindings_by_name)
		var/datum/keybinding/kb = global.keybindings_by_name[name]
		kb_categories[kb.category] += list(kb)
	. += "<tr><td>Hotkeys Mode: <a href='?_src_=prefs;preference=hotkeys'>[hotkeys ? "Focus on Game" : "Focus on Chat"]</a></td></tr>"
	. += "<center>"
	for (var/category in kb_categories)
		. += "<h3>[category]</h3>"
		. += "<table width='100%'>"
		for (var/i in kb_categories[category])
			var/datum/keybinding/kb = i
			if(!length(user_binds[kb.name]) || (user_binds[kb.name][1] == "None" && length(user_binds[kb.name]) == 1))
				. += "<tr><td width='40%'>[kb.full_name]</td><td width='15%'><a class='white fluid' href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=["None"]'>None</a></td>"
				var/list/default_keys = kb.hotkey_keys
				var/class
				if(compare_list(user_binds[kb.name], default_keys))
					class = "class='disabled fluid'"
				else
					class = "class='white fluid' href ='?_src_=prefs;preference=keybinding_reset;keybinding=[kb.name];old_keys=[jointext(user_binds[kb.name], ",")]"

				. += {"<td width='15%'></td><td width='15%'></td><td width='15%'><a [class]'>Reset</a></td>"}
				. += "</tr>"
			else
				var/bound_key = user_binds[kb.name][1]
				var/normal_name = _kbMap_reverse[bound_key] ? _kbMap_reverse[bound_key] : bound_key
				. += "<tr><td width='40%'>[kb.full_name]</td><td width='15%'><a class='white fluid' href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[normal_name]</a></td>"
				for(var/bound_key_index in 2 to length(user_binds[kb.name]))
					bound_key = user_binds[kb.name][bound_key_index]
					normal_name = _kbMap_reverse[bound_key] ? _kbMap_reverse[bound_key] : bound_key
					. += "<td width='15%'><a class='white fluid' href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[normal_name]</a></td>"
				if(length(user_binds[kb.name]) < MAX_KEYS_PER_KEYBIND)
					. += "<td width='15%'><a class='white fluid' href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name]'>None</a></td>"
				for(var/j in 1 to MAX_KEYS_PER_KEYBIND - (length(user_binds[kb.name]) + 1))
					. += "<td width='15%'></td>"
				var/list/default_keys = kb.hotkey_keys
				. += {"<td width='15%'><a [compare_list(user_binds[kb.name], default_keys) ? "class='disabled fluid'" : "class='white fluid' href ='?_src_=prefs;preference=keybinding_reset;keybinding=[kb.name];old_keys=[jointext(user_binds[kb.name], ",")]"]'>Reset</a></td>"}
				. += "</tr>"
		. += "</table>"

	. += "<br><br>"
	. += "<a class='white' href ='?_src_=prefs;preference=keybindings_reset'>Reset to default</a>"
	. += "</center>"

/datum/preferences/proc/CaptureKeybinding(mob/user, datum/keybinding/kb, old_key)
	var/HTML = {"
	<div class='Section fill'id='focus' style="outline: 0; text-align:center;" tabindex=0>
		Keybinding: [kb.full_name]<br>[kb.description]
		<br><br>
		<b>Press any key to change<br>Press ESC to clear</b>
	</div>
	<script>
	var deedDone = false;
	document.onkeyup = function(e) {
		if(deedDone){ return; }
		var alt = e.altKey ? 1 : 0;
		var ctrl = e.ctrlKey ? 1 : 0;
		var shift = e.shiftKey ? 1 : 0;
		var numpad = (95 < e.keyCode && e.keyCode < 112) ? 1 : 0;
		var escPressed = e.keyCode == 27 ? 1 : 0;
		var sanitizedKey = e.key;
		if (47 < e.keyCode && e.keyCode < 58) {
			sanitizedKey = String.fromCharCode(e.keyCode);
		}
		else if (64 < e.keyCode && e.keyCode < 91) {
			sanitizedKey = String.fromCharCode(e.keyCode);
		}
		var url = 'byond://?_src_=prefs;preference=keybindings_set;keybinding=[kb.name];old_key=[old_key];clear_key='+escPressed+';key='+sanitizedKey+';alt='+alt+';ctrl='+ctrl+';shift='+shift+';numpad='+numpad+';key_code='+e.keyCode;
		window.location=url;
		deedDone = true;
	}
	document.getElementById('focus').focus();
	</script>
	"}
	winshow(user, "capturekeypress", TRUE)
	var/datum/browser/popup = new(user, "capturekeypress", "<div align='center'>Keybindings</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(FALSE)

/datum/preferences/proc/toggle_hotkeys_mode()
	hotkeys = !hotkeys
	if(hotkeys)
		winset(usr, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED]")
	else
		winset(usr, null, "input.focus=true input.background-color=[COLOR_INPUT_DISABLED]")
	save_preferences()


/datum/preferences/proc/process_link_custom_keybindings(mob/user, list/href_list)
	if(!user)
		return
	switch(href_list["preference"])
		if("hotkeys")
			toggle_hotkeys_mode()

		if("keybindings_capture")
			var/datum/keybinding/kb = global.keybindings_by_name[href_list["keybinding"]]
			var/old_key = href_list["old_key"]
			CaptureKeybinding(user, kb, old_key)
			return

		if("keybindings_set")
			var/kb_name = href_list["keybinding"]
			if(!kb_name)
				user << browse(null, "window=capturekeypress")
				ShowChoices(user)
				return

			var/clear_key = text2num(href_list["clear_key"])
			var/old_key = href_list["old_key"]
			if(clear_key)
				if(key_bindings[old_key])
					key_bindings[old_key] -= kb_name
					if(!(kb_name in key_bindings["None"]))
						LAZYADD(key_bindings["None"], kb_name)
					if(!length(key_bindings[old_key]))
						key_bindings -= old_key
				user << browse(null, "window=capturekeypress")
				user.client.set_macros()
				save_preferences()
				ShowChoices(user)
				return

			var/new_key = uppertext(href_list["key"])
			var/AltMod = text2num(href_list["alt"]) ? "Alt" : ""
			var/CtrlMod = text2num(href_list["ctrl"]) ? "Ctrl" : ""
			var/ShiftMod = text2num(href_list["shift"]) ? "Shift" : ""
			var/numpad = text2num(href_list["numpad"]) ? "Numpad" : ""

			if(!new_key) // Just in case (; - not work although keyCode 186 and nothing should break)
				user << browse(null, "window=capturekeypress")
				return

			if(global._kbMap[new_key])
				new_key = global._kbMap[new_key]

			var/full_key
			switch(new_key)
				if("Alt")
					full_key = "[new_key][CtrlMod][ShiftMod]"
				if("Ctrl")
					full_key = "[AltMod][new_key][ShiftMod]"
				if("Shift")
					full_key = "[AltMod][CtrlMod][new_key]"
				else
					full_key = "[AltMod][CtrlMod][ShiftMod][numpad][new_key]"
			if(kb_name in key_bindings[full_key]) //We pressed the same key combination that was already bound here, so let's remove to re-add and re-sort.
				key_bindings[full_key] -= kb_name
			if(key_bindings[old_key])
				key_bindings[old_key] -= kb_name
				if(!length(key_bindings[old_key]))
					key_bindings -= old_key
			key_bindings[full_key] += list(kb_name)
			key_bindings[full_key] = sortList(key_bindings[full_key])

			user << browse(null, "window=capturekeypress")
			user.client.set_macros()
			save_preferences()

		if("keybindings_reset")
			key_bindings = deepCopyList(global.hotkey_keybinding_list_by_key)
			user.client.set_macros()
			save_preferences()

		if("keybinding_reset")
			var/kb_name = href_list["keybinding"]
			var/list/old_keys = splittext(href_list["old_keys"], ",")

			for(var/old_key in old_keys)
				if(!key_bindings[old_key])
					continue
				key_bindings[old_key] -= kb_name
				if(!length(key_bindings[old_key]))
					key_bindings -= old_key

			var/datum/keybinding/kb = global.keybindings_by_name[kb_name]
			for(var/key in kb.hotkey_keys)
				key_bindings[key] += list(kb_name)
				key_bindings[key] = sortList(key_bindings[key])
			user.client.set_macros()
			save_preferences()
