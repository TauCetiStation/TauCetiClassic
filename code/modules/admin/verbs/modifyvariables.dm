/client/proc/mod_list_add_ass() //haha

	var/class = "text"
	if(src.holder && src.holder.marked_datum)
		class = input("What kind of variable?","Variable Type") as null|anything in list("text",
			"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default","marked datum ([holder.marked_datum.type])")
	else
		class = input("What kind of variable?","Variable Type") as null|anything in list("text",
			"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default")

	if(!class)
		return

	if(holder.marked_datum && class == "marked datum ([holder.marked_datum.type])")
		class = "marked datum"

	var/var_value = null

	switch(class)

		if("text")
			var_value = sanitize(input("Enter new text:","Text") as null|text)

		if("num")
			var_value = input("Enter new number:","Num") as null|num

		if("type")
			var_value = input("Enter type:","Type") as null|anything in typesof(/obj,/mob,/area,/turf)

		if("reference")
			var_value = input("Select reference:","Reference") as null|mob|obj|turf|area in world

		if("mob reference")
			var_value = input("Select reference:","Reference") as null|mob in world

		if("file")
			var_value = input("Pick file:","File") as null|file

		if("icon")
			var_value = input("Pick icon:","Icon") as null|icon

		if("marked datum")
			var_value = holder.marked_datum

	if(!var_value) return

	return var_value


/client/proc/mod_list_add(list/L)

	var/class = "text"
	if(src.holder && src.holder.marked_datum)
		class = input("What kind of variable?","Variable Type") as null|anything in list("text",
			"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default","marked datum ([holder.marked_datum.type])")
	else
		class = input("What kind of variable?","Variable Type") as null|anything in list("text",
			"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default")

	if(!class)
		return

	if(holder.marked_datum && class == "marked datum ([holder.marked_datum.type])")
		class = "marked datum"

	var/var_value = null

	switch(class)

		if("text")
			var_value = sanitize(input("Enter new text:","Text") as text)

		if("num")
			var_value = input("Enter new number:","Num") as num

		if("type")
			var_value = input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)

		if("reference")
			var_value = input("Select reference:","Reference") as mob|obj|turf|area in world

		if("mob reference")
			var_value = input("Select reference:","Reference") as mob in world

		if("file")
			var_value = input("Pick file:","File") as file

		if("icon")
			var_value = input("Pick icon:","Icon") as icon

		if("marked datum")
			var_value = holder.marked_datum

	if(!var_value) return

	switch(alert("Would you like to associate a var with the list entry?",,"Yes","No"))
		if("Yes")
			L += var_value
			L[var_value] = mod_list_add_ass() //haha
		if("No")
			L += var_value

/client/proc/mod_list(list/L)
	if(!check_rights(R_VAREDIT))
		return

	if(!islist(L))
		to_chat(usr, "Still not a list")
		return


	var/list/locked = list("vars", "key", "ckey", "client", "virus", "viruses", "icon", "icon_state")
	var/list/names = sortList(L)

	var/variable = input("Which var?","Var") as null|anything in names + "(ADD VAR)"

	if(variable == "(ADD VAR)")
		mod_list_add(L)
		return

	if(!variable)
		return

	var/default

	var/dir

	if(variable in locked)
		if(!check_rights(R_DEBUG))	return

	if(isnull(variable))
		to_chat(usr, "Unable to determine variable type.")

	else if(isnum(variable))
		to_chat(usr, "Variable appears to be <b>NUM</b>.")
		default = "num"

	else if(istext(variable))
		to_chat(usr, "Variable appears to be <b>TEXT</b>.")
		default = "text"

	else if(isloc(variable))
		to_chat(usr, "Variable appears to be <b>REFERENCE</b>.")
		default = "reference"

	else if(isicon(variable))
		to_chat(usr, "Variable appears to be <b>ICON</b>.")
		variable = "[bicon(variable)]"
		default = "icon"

	else if(istype(variable,/atom) || istype(variable,/datum))
		to_chat(usr, "Variable appears to be <b>TYPE</b>.")
		default = "type"

	else if(istype(variable,/list))
		to_chat(usr, "Variable appears to be <b>LIST</b>.")
		default = "list"

	else if(istype(variable,/client))
		to_chat(usr, "Variable appears to be <b>CLIENT</b>.")
		default = "cancel"

	else
		to_chat(usr, "Variable appears to be <b>FILE</b>.")
		default = "file"

	to_chat(usr, "Variable contains: [variable]")
	if(dir)
		switch(variable)
			if(1)
				dir = "NORTH"
			if(2)
				dir = "SOUTH"
			if(4)
				dir = "EAST"
			if(8)
				dir = "WEST"
			if(5)
				dir = "NORTHEAST"
			if(6)
				dir = "SOUTHEAST"
			if(9)
				dir = "NORTHWEST"
			if(10)
				dir = "SOUTHWEST"
			else
				dir = null

		if(dir)
			to_chat(usr, "If a direction, direction is: [dir]")

	var/class = "text"
	if(src.holder && src.holder.marked_datum)
		class = input("What kind of variable?","Variable Type",default) as null|anything in list("text",
			"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default","marked datum ([holder.marked_datum.type])", "DELETE FROM LIST")
	else
		class = input("What kind of variable?","Variable Type",default) as null|anything in list("text",
			"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default", "DELETE FROM LIST")

	if(!class)
		return

	if(holder.marked_datum && class == "marked datum ([holder.marked_datum.type])")
		class = "marked datum"

	switch(class) //Spits a runtime error if you try to modify an entry in the contents list. Dunno how to fix it, yet.

		if("list")
			if(!islist(L[L.Find(variable)]))
				if(alert("This is not a list. Would you like to create new list?",,"Yes","No") == "No")
					return
				L[L.Find(variable)] = list()
			mod_list(L[L.Find(variable)])

		if("restore to default")
			L[L.Find(variable)]=initial(variable)

		if("edit referenced object")
			modify_variables(variable)

		if("DELETE FROM LIST")
			L -= variable
			return

		if("text")
			L[L.Find(variable)] = sanitize(input("Enter new text:","Text") as text)

		if("num")
			L[L.Find(variable)] = input("Enter new number:","Num") as num

		if("type")
			L[L.Find(variable)] = input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)

		if("reference")
			L[L.Find(variable)] = input("Select reference:","Reference") as mob|obj|turf|area in world

		if("mob reference")
			L[L.Find(variable)] = input("Select reference:","Reference") as mob in world

		if("file")
			L[L.Find(variable)] = input("Pick file:","File") as file

		if("icon")
			L[L.Find(variable)] = input("Pick icon:","Icon") as icon

		if("marked datum")
			L[L.Find(variable)] = holder.marked_datum


/client/proc/modify_variables(atom/O, param_var_name = null, autodetect_class = 0)
	if(!check_rights(R_VAREDIT))	return

	if(is_type_in_list(O, VE_PROTECTED_TYPES))
		to_chat(usr, "<span class='warning'>It is forbidden to edit this object's variables.</span>")
		return

	var/class
	var/variable
	var/var_value

	if(param_var_name)
		if(!(param_var_name in O.vars))
			to_chat(src, "A variable with this name ([param_var_name]) doesn't exist in this atom ([O])")
			return

		if(param_var_name in VE_FULLY_LOCKED)
			to_chat(usr, "<span class='warning'>It is forbidden to edit this variable.</span>")
			return

		if((param_var_name in VE_DEBUG) && !check_rights(R_DEBUG))
			return

		if((param_var_name in VE_ICONS) && !check_rights(R_DEBUG|R_EVENT))
			return

		if((param_var_name in VE_HIDDEN_LOG) && !check_rights(R_LOG))
			return

		variable = param_var_name

		var_value = O.vars[variable]

		if(autodetect_class)
			if(isnull(var_value))
				to_chat(usr, "Unable to determine variable type.")
				class = null
				autodetect_class = null

			else if (variable in global.bitfields)
				to_chat(usr, "Variable appears to be <b>BITFIELD</b>.")
				class = "bitfield"

			else if(isnum(var_value))
				to_chat(usr, "Variable appears to be <b>NUM</b>.")
				class = "num"

			else if(istext(var_value))
				to_chat(usr, "Variable appears to be <b>TEXT</b>.")
				class = "text"

			else if(isloc(var_value))
				to_chat(usr, "Variable appears to be <b>REFERENCE</b>.")
				class = "reference"

			else if(isicon(var_value))
				to_chat(usr, "Variable appears to be <b>ICON</b>.")
				var_value = "[bicon(var_value)]"
				class = "icon"

			else if(istype(var_value,/atom) || istype(var_value,/datum))
				to_chat(usr, "Variable appears to be <b>TYPE</b>.")
				class = "type"

			else if(istype(var_value,/list))
				to_chat(usr, "Variable appears to be <b>LIST</b>.")
				class = "list"

			else if(istype(var_value,/client))
				to_chat(usr, "Variable appears to be <b>CLIENT</b>.")
				class = "cancel"

			else
				to_chat(usr, "Variable appears to be <b>FILE</b>.")
				class = "file"

	else

		var/list/names = list()
		for (var/V in O.vars)
			names += V

		names = sortList(names)

		variable = input("Which var?","Var") as null|anything in names
		if(!variable)	return
		var_value = O.vars[variable]

		if(variable == "holder" || (variable in VE_DEBUG))
			if(!check_rights(R_DEBUG))	return

	if(!autodetect_class)

		var/dir
		var/default
		if(isnull(var_value))
			to_chat(usr, "Unable to determine variable type.")

		else if (variable in global.bitfields)
			to_chat(usr, "Variable appears to be <b>BITFIELD</b>.")
			class = "bitfield"

		else if(isnum(var_value))
			to_chat(usr, "Variable appears to be <b>NUM</b>.")
			default = "num"

		else if(istext(var_value))
			to_chat(usr, "Variable appears to be <b>TEXT</b>.")
			default = "text"

		else if(isloc(var_value))
			to_chat(usr, "Variable appears to be <b>REFERENCE</b>.")
			default = "reference"

		else if(isicon(var_value))
			to_chat(usr, "Variable appears to be <b>ICON</b>.")
			var_value = "[bicon(var_value)]"
			default = "icon"

		else if(istype(var_value,/atom) || istype(var_value,/datum))
			to_chat(usr, "Variable appears to be <b>TYPE</b>.")
			default = "type"

		else if(istype(var_value,/list))
			to_chat(usr, "Variable appears to be <b>LIST</b>.")
			default = "list"

		else if(istype(var_value,/client))
			to_chat(usr, "Variable appears to be <b>CLIENT</b>.")
			default = "cancel"

		else
			to_chat(usr, "Variable appears to be <b>FILE</b>.")
			default = "file"

		to_chat(usr, "Variable contains: [var_value]")
		if(dir)
			switch(var_value)
				if(1)
					dir = "NORTH"
				if(2)
					dir = "SOUTH"
				if(4)
					dir = "EAST"
				if(8)
					dir = "WEST"
				if(5)
					dir = "NORTHEAST"
				if(6)
					dir = "SOUTHEAST"
				if(9)
					dir = "NORTHWEST"
				if(10)
					dir = "SOUTHWEST"
				else
					dir = null
			if(dir)
				to_chat(usr, "If a direction, direction is: [dir]")

		if(src.holder && src.holder.marked_datum)
			class = input("What kind of variable?","Variable Type",default) as null|anything in list("text", "bitfield",
				"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default","marked datum ([holder.marked_datum.type])")
		else
			class = input("What kind of variable?","Variable Type",default) as null|anything in list("text", "bitfield",
				"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default")

		if(!class)
			return

	var/original_name

	if (!istype(O, /atom))
		original_name = "\ref[O] ([O])"
	else
		original_name = O:name

	if(holder.marked_datum && class == "marked datum ([holder.marked_datum.type])")
		class = "marked datum"

	var/log_handled = FALSE

	switch(class)

		if("list")
			if(!islist(O.vars[variable]))
				if(alert("This is not a list. Would you like to create new list?",,"Yes","No") == "No")
					return
				O.vars[variable] = list()
			mod_list(O.vars[variable])
			return

		if("restore to default")
			if(variable=="resize")
				world.log << "### VarEdit by [src]: [O.type] [variable]=[html_encode("[O.resize_rev]")]"
				log_admin("[key_name(src)] modified [original_name]'s [variable] to [O.resize_rev]")
				message_admins("[key_name_admin(src)] modified [original_name]'s [variable] to [O.resize_rev]")
				log_handled = TRUE
				O.vars[variable] = O.resize_rev
				O.update_transform()
				O.resize_rev = initial(O.resize_rev)
			else
				O.vars[variable] = initial(O.vars[variable])

		if("edit referenced object")
			return .(O.vars[variable])

		if("text")
			switch(variable)
				if("light_color")
					var/var_new = input("Select new color:", "Color", O.vars[variable]) as null|color
					if(isnull(var_new))
						return
					O.set_light(l_color = var_new)
				if("ckey")
					var/var_new = ckey(input("Enter new text:", "Text", O.vars[variable]) as null|text)
					if(isnull(var_new))
						return
					O.vars[variable] = var_new
				else
					var/var_new = sanitize(input("Enter new text:", "Text", O.vars[variable]) as null|text)
					if(isnull(var_new))
						return
					O.vars[variable] = var_new
		if("num")
			switch(variable)
				if("opacity")
					var/var_new = input("Enter new number:", "Num", O.vars[variable]) as null|num
					if(isnull(var_new))
						return
					O.set_opacity(var_new)
				if("light_range")
					var/var_new = input("Enter new number:", "Num", O.vars[variable]) as null|num
					if(isnull(var_new))
						return
					O.set_light(var_new)
				if("light_power")
					var/var_new = input("Enter new number:", "Num", O.vars[variable]) as null|num
					if(isnull(var_new))
						return
					O.set_light(l_power = var_new)
				if("dynamic_lighting")
					if(!isarea(O) && !isturf(O))
						to_chat(usr, "This can only be used on instances of type /area and /turf")
						return
					var/var_new = alert("dynamic_lighting", ,
						"DYNAMIC_LIGHTING_DISABLED", "DYNAMIC_LIGHTING_ENABLED", "DYNAMIC_LIGHTING_FORCED"
						)
					switch(var_new)
						if("DYNAMIC_LIGHTING_DISABLED")
							var_new = DYNAMIC_LIGHTING_DISABLED
						if("DYNAMIC_LIGHTING_ENABLED")
							var_new = DYNAMIC_LIGHTING_ENABLED
						if("DYNAMIC_LIGHTING_FORCED")
							var_new = DYNAMIC_LIGHTING_FORCED
					if(isnull(var_new))
						return
					var/area/A = O
					A.set_dynamic_lighting(var_new)
				if("player_ingame_age")
					var/var_new = input("Enter new number:", "Num", O.vars[variable]) as null|num
					if(isnull(var_new) || var_new < 0)
						return
					O.vars[variable] = var_new
					if(istype(O,/client))
						var/client/C = O
						if(C) C.log_client_ingame_age_to_db()
				if("stat")
					var/var_new = input("Enter new number:", "Num", O.vars[variable]) as null|num
					if(isnull(var_new))
						return
					if((O.vars[variable] == DEAD) && (var_new < DEAD))//Bringing the dead back to life
						dead_mob_list -= O
						alive_mob_list += O
					if((O.vars[variable] < DEAD) && (var_new == DEAD))//Kill him
						alive_mob_list -= O
						dead_mob_list += O
					O.vars[variable] = var_new
				if("resize")
					var/var_new = input("Enter new coefficient: \n(object will be resized by multiplying this number)", "Num", O.vars[variable]) as null|num
					if(isnull(var_new))
						return
					if(var_new == 0)
						to_chat(usr, "<b>Resize coefficient can't be equal 0</b>")
						return
					O.vars[variable] = var_new
					world.log << "### VarEdit by [src]: [O.type] [variable]=[html_encode("[O.resize]")]"
					log_admin("[key_name(src)] modified [original_name]'s [variable] to [O.resize]")
					message_admins("[key_name_admin(src)] modified [original_name]'s [variable] to [O.resize]")
					log_handled = TRUE
					O.update_transform()
				else
					var/var_new = input("Enter new number:", "Num", O.vars[variable]) as null|num
					if(isnull(var_new))
						return
					O.vars[variable] = var_new

		if("type")
			var/var_new = input("Enter type:","Type",O.vars[variable]) as null|anything in typesof(/obj,/mob,/area,/turf)
			if(var_new==null) return
			O.vars[variable] = var_new

		if("reference")
			var/var_new = input("Select reference:","Reference",O.vars[variable]) as null|mob|obj|turf|area in world
			if(var_new==null) return
			O.vars[variable] = var_new

		if("mob reference")
			var/var_new = input("Select reference:","Reference",O.vars[variable]) as null|mob in world
			if(var_new==null) return
			O.vars[variable] = var_new

		if("bitfield")
			var/var_new = input_bitfield(usr, "Editing bitfield: [variable]", variable, O.vars[variable], null, 400)
			if(var_new==null) return
			O.vars[variable] = var_new

		if("file")
			var/var_new = input("Pick file:","File",O.vars[variable]) as null|file
			if(var_new==null) return
			O.vars[variable] = var_new

		if("icon")
			var/var_new = input("Pick icon:","Icon",O.vars[variable]) as null|icon
			if(var_new==null) return
			O.vars[variable] = var_new

		if("marked datum")
			O.vars[variable] = holder.marked_datum

	if(!log_handled)
		world.log << "### VarEdit by [src]: [O.type] [variable]=[html_encode("[O.vars[variable]]")]"
		log_admin("[key_name(src)] modified [original_name]'s [variable] to [O.vars[variable]]")
		message_admins("[key_name_admin(src)] modified [original_name]'s [variable] to [O.vars[variable]]")
