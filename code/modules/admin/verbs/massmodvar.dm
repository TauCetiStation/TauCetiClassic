/client/proc/cmd_mass_modify_object_variables(atom/A, var_name)
	set category = "Debug"
	set name = "Mass Edit Variables"
	set desc="(target) Edit all instances of a target item's variables"

	var/method = 0	//0 means strict type detection while 1 means this type and all subtypes (IE: /obj/item with this set to 1 will set it to ALL itms)

	if(!check_rights(R_VAREDIT))	return

	if(A && A.type)
		if(typesof(A.type))
			switch(input("Strict object type detection?") as null|anything in list("Strictly this type","This type and subtypes", "Cancel"))
				if("Strictly this type")
					method = 0
				if("This type and subtypes")
					method = 1
				if("Cancel")
					return
				if(null)
					return

	src.massmodify_variables(A, var_name, method)
	feedback_add_details("admin_verb","MEV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/massmodify_variables(atom/O, var_name = "", method = 0)
	if(!check_rights(R_VAREDIT))	return

	if(is_type_in_list(O, VE_PROTECTED_TYPES))
		to_chat(usr, "<span class='warning'>It is forbidden to edit this object's variables.</span>")
		return

	var/list/names = list()
	for (var/V in O.vars)
		names += V

	names = sortList(names)

	var/variable = ""

	if(!var_name)
		variable = input("Which var?","Var") as null|anything in names
	else
		variable = var_name

	if(!variable)
		return

	var/default
	var/var_value = O.vars[variable]
	var/dir

	if(variable in VE_MASS_FULLY_LOCKED)
		to_chat(usr, "<span class='warning'>It is forbidden to edit this variable.</span>")
		return

	if((variable in VE_MASS_DEBUG) && !check_rights(R_DEBUG))
		return

	if((variable in VE_MASS_ICONS) && !check_rights(R_DEBUG|R_EVENT))
		return

	if((variable in VE_HIDDEN_LOG) && !check_rights(R_LOG))
		return

	if(isnull(var_value))
		to_chat(usr, "Unable to determine variable type.")

	else if (variable in global.bitfields)
		to_chat(usr, "Variable appears to be <b>BITFIELD</b>.")
		default = "bitfield"

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

	var/class = input("What kind of variable?","Variable Type",default) as null|anything in list("text", "bitfield",
		"num","type","icon","file","edit referenced object","restore to default")

	if(!class)
		return

	var/original_name

	if (!istype(O, /atom))
		original_name = "\ref[O] ([O])"
	else
		original_name = O:name

	var/log_handled = FALSE

	switch(class)

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

			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if(istype(M, O.type))
							if(variable=="resize")
								M.vars[variable] = M.resize_rev
								M.update_transform()
								M.resize_rev = O.resize_rev
							else
								M.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if(istype(A, O.type))
							if(variable=="resize")
								A.vars[variable] = A.resize_rev
								A.update_transform()
								A.resize_rev = O.resize_rev
							else
								A.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if(istype(A, O.type))
							if(variable=="resize")
								A.vars[variable] = A.resize_rev
								A.update_transform()
								A.resize_rev = O.resize_rev
							else
								A.vars[variable] = O.vars[variable]
						CHECK_TICK

			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if(M.type == O.type)
							if(variable=="resize")
								M.vars[variable] = M.resize_rev
								M.update_transform()
								M.resize_rev = O.resize_rev
							else
								M.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if(A.type == O.type)
							if(variable=="resize")
								A.vars[variable] = A.resize_rev
								A.update_transform()
								A.resize_rev = O.resize_rev
							else
								A.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if(A.type == O.type)
							if(variable=="resize")
								A.vars[variable] = A.resize_rev
								A.update_transform()
								A.resize_rev = O.resize_rev
							else
								A.vars[variable] = O.vars[variable]
						CHECK_TICK

		if("edit referenced object")
			return .(O.vars[variable])

		if("text")
			var/new_value

			if(variable == "light_color")
				var/var_new = input("Select new color:", "Color", O.vars[variable]) as null|color
				if(isnull(var_new))
					return
			else
				new_value = input("Enter new text:", "Text", O.vars[variable]) as text|null
				if(isnull(new_value))
					return
				O.vars[variable] = new_value

			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if(istype(M, O.type))
							if(variable == "light_color")
								M.set_light(l_color = new_value)
							else
								M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if(istype(A, O.type))
							if(variable == "light_color")
								A.set_light(l_color = new_value)
							else
								A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if(istype(A, O.type))
							if(variable == "light_color")
								A.set_light(l_color = new_value)
							else
								A.vars[variable] = O.vars[variable]
			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if(M.type == O.type)
							if(variable == "light_color")
								M.set_light(l_color = new_value)
							else
								M.vars[variable] = O.vars[variable]

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if(A.type == O.type)
							if(variable == "light_color")
								A.set_light(l_color = new_value)
							else
								A.vars[variable] = O.vars[variable]

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if(A.type == O.type)
							if(variable == "light_color")
								A.set_light(l_color = new_value)
							else
								A.vars[variable] = O.vars[variable]

		if("num")
			var/new_value

			if(variable == "dynamic_lighting")
				new_value = alert("dynamic_lighting", ,
					"DYNAMIC_LIGHTING_DISABLED", "DYNAMIC_LIGHTING_ENABLED", "DYNAMIC_LIGHTING_FORCED"
					)
				switch(new_value)
					if("DYNAMIC_LIGHTING_DISABLED")
						new_value = DYNAMIC_LIGHTING_DISABLED
					if("DYNAMIC_LIGHTING_ENABLED")
						new_value = DYNAMIC_LIGHTING_ENABLED
					if("DYNAMIC_LIGHTING_FORCED")
						new_value = DYNAMIC_LIGHTING_FORCED
			else
				new_value = input("Enter new number:","Num", O.vars[variable]) as num|null

			if(isnull(new_value))
				return

			if(variable in list("opacity", "light_range", "light_power", "dynamic_lighting"))
				// do nothing, as we shouldn't set O.vars[variable] = new_value before procs.
			else if(variable=="resize")
				if(new_value == 0)
					to_chat(usr, "<b>Resize coefficient can't be equal 0</b>")
					return
				world.log << "### VarEdit by [src]: [O.type] [variable]=[html_encode("[new_value]")]"
				log_admin("[key_name(src)] modified [original_name]'s [variable] to [new_value]")
				message_admins("[key_name_admin(src)] modified [original_name]'s [variable] to [new_value]")
				log_handled = TRUE
			else
				O.vars[variable] = new_value

			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if(istype(M, O.type))
							switch(variable)
								if("opacity")
									M.set_opacity(new_value)
								if("light_range")
									M.set_light(new_value)
								if("light_power")
									M.set_light(l_power = new_value)
								if("resize")
									M.vars[variable] = new_value
									M.update_transform()
								else
									M.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if(istype(A, O.type))
							switch(variable)
								if("opacity")
									A.set_opacity(new_value)
								if("light_range")
									A.set_light(new_value)
								if("light_power")
									A.set_light(l_power = new_value)
								if("resize")
									A.vars[variable] = new_value
									A.update_transform()
								else
									A.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if(istype(A, O.type))
							switch(variable)
								if("opacity")
									A.set_opacity(new_value)
								if("light_range")
									A.set_light(new_value)
								if("light_power")
									A.set_light(l_power = new_value)
								if("dynamic_lighting")
									A.set_dynamic_lighting(new_value)
								if("resize")
									A.vars[variable] = new_value
									A.update_transform()
								else
									A.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O, /area))
					for(var/area/A in world)
						if(istype(A, O.type))
							switch(variable)
								if("opacity")
									A.set_opacity(new_value)
								if("dynamic_lighting")
									A.set_dynamic_lighting(new_value)
						CHECK_TICK

			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if(M.type == O.type)
							switch(variable)
								if("opacity")
									M.set_opacity(new_value)
								if("light_range")
									M.set_light(new_value)
								if("light_power")
									M.set_light(l_power = new_value)
								if("resize")
									M.vars[variable] = new_value
									M.update_transform()
								else
									M.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if(A.type == O.type)
							switch(variable)
								if("opacity")
									A.set_opacity(new_value)
								if("light_range")
									A.set_light(new_value)
								if("light_power")
									A.set_light(l_power = new_value)
								if("resize")
									A.vars[variable] = new_value
									A.update_transform()
								else
									A.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if(A.type == O.type)
							switch(variable)
								if("opacity")
									A.set_opacity(new_value)
								if("light_range")
									A.set_light(new_value)
								if("light_power")
									A.set_light(l_power = new_value)
								if("dynamic_lighting")
									A.set_dynamic_lighting(new_value)
								if("resize")
									A.vars[variable] = new_value
									A.update_transform()
								else
									A.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O, /area))
					for(var/area/A in world)
						if(A.type == O.type)
							switch(variable)
								if("opacity")
									A.set_opacity(new_value)
								if("dynamic_lighting")
									A.set_dynamic_lighting(new_value)
						CHECK_TICK

		if("type")
			var/new_value
			new_value = input("Enter type:", "Type", O.vars[variable]) as null|anything in typesof(/obj, /mob, /area, /turf)
			if(isnull(new_value))
				return
			O.vars[variable] = new_value
			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if(istype(M, O.type) )
							M.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if(istype(A, O.type) )
							A.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if(istype(A, O.type))
							A.vars[variable] = O.vars[variable]
						CHECK_TICK
			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if(M.type == O.type)
							M.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if(A.type == O.type)
							A.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if(A.type == O.type)
							A.vars[variable] = O.vars[variable]
						CHECK_TICK

		if("file")
			var/new_value = input("Pick file:", "File", O.vars[variable]) as null|file
			if(isnull(new_value))
				return
			O.vars[variable] = new_value

			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if(istype(M, O.type))
							M.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O.type, /obj))
					for(var/obj/A in world)
						if(istype(A , O.type))
							A.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O.type, /turf))
					for(var/turf/A in world)
						if(istype(A , O.type))
							A.vars[variable] = O.vars[variable]
						CHECK_TICK
			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if(M.type == O.type)
							M.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O.type, /obj))
					for(var/obj/A in world)
						if(A.type == O.type)
							A.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O.type, /turf))
					for(var/turf/A in world)
						if(A.type == O.type)
							A.vars[variable] = O.vars[variable]
						CHECK_TICK

		if("icon")
			var/new_value = input("Pick icon:", "Icon", O.vars[variable]) as null|icon
			if(isnull(new_value))
				return
			O.vars[variable] = new_value
			if(method)
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if(istype(M, O.type))
							M.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if(istype(A, O.type))
							A.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if(istype(A, O.type))
							A.vars[variable] = O.vars[variable]
						CHECK_TICK

			else
				if(istype(O, /mob))
					for(var/mob/M in mob_list)
						if(M.type == O.type)
							M.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O, /obj))
					for(var/obj/A in world)
						if(A.type == O.type)
							A.vars[variable] = O.vars[variable]
						CHECK_TICK

				else if(istype(O, /turf))
					for(var/turf/A in world)
						if(A.type == O.type)
							A.vars[variable] = O.vars[variable]
						CHECK_TICK

		if("bitfield")
			var/new_value = input_bitfield(usr, "Editing bitfield: [variable]", variable, O.vars[variable], null, 400)
			if(isnull(new_value))
				return
			var/target_type = O.type
			for(var/datum/D in world)
				if(method && istype(D, target_type) || D.type == target_type)
					D.vars[variable] = new_value
				CHECK_TICK

	if(!log_handled)
		world.log << "### MassVarEdit by [src]: [O.type] [variable]=[html_encode("[O.vars[variable]]")]"
		log_admin("[key_name(src)] mass modified [original_name]'s [variable] to [O.vars[variable]]")
		message_admins("[key_name_admin(src)] mass modified [original_name]'s [variable] to [O.vars[variable]]", 1)
