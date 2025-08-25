
#define DMM_IGNORE_AREAS   (1<<0)
#define DMM_IGNORE_TURFS   (1<<1)
#define DMM_IGNORE_OBJS    (1<<2)
#define DMM_IGNORE_MOBS    (1<<3)

/dmm_suite
	var/quote = "\""
	var/list/letter_digits = list(
			"a","b","c","d","e","f","g","h","i","j","k","l","m",
			"n","o","p","q","r","s","t","u","v","w","x","y","z",
			"A","B","C","D","E","F","G","H","I","J","K","L","M",
			"N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
	var/list/obj_vars_to_save = list(
		"amount", "dock_tag", "id", "id_tag", "tag", "grilled", "delete_after_roundstart",
		"name", "dir", "pixel_x", "pixel_y")

/dmm_suite/save_map(turf/t1, turf/t2, map_path, flags)
	if(!map_path)
		CRASH("Invalid empty path string.")

	if(!isturf(t1) || !isturf(t2))
		CRASH("Invalid arguments supplied to proc save_map, arguments were not turfs.")

	var/file_text = write_map(t1, t2, flags)
	if(fexists("[map_path].dmm"))
		fdel("[map_path].dmm")

	var/saved_map = file("[map_path].dmm")
	saved_map << file_text
	return saved_map

/dmm_suite/write_map(turf/t1, turf/t2, flags)
	if(!isturf(t1) || !isturf(t2))
		CRASH("Invalid arguments supplied to proc write_map, arguments were not turfs.")

	var/turf/nw = locate(min(t1.x,t2.x),max(t1.y,t2.y),min(t1.z,t2.z))
	var/turf/se = locate(max(t1.x,t2.x),min(t1.y,t2.y),max(t1.z,t2.z))

	var/list/templates = list()
	var/template_buffer = ""
	var/dmm_text = ""

	var/turf/curr_turf
	var/curr_template
	var/template_number

	for(var/pos_z = nw.z; pos_z <= se.z; pos_z++)
		for(var/pos_y = nw.y; pos_y >= se.y; pos_y--)
			for(var/pos_x = nw.x; pos_x <= se.x; pos_x++)
				curr_turf = locate(pos_x, pos_y, pos_z)
				curr_template = make_template(curr_turf, flags)
				template_number = templates.Find(curr_template)
				if(!template_number)
					templates.Add(curr_template)
					template_number = templates.len

				template_buffer += "[template_number],"
			template_buffer += ";"
		template_buffer += "."

	var/list/keys[templates.len]
	var/key_length = round(log(letter_digits.len,templates.len-1)+1)
	for(var/key_pos = 1; key_pos <= templates.len; key_pos++)
		keys[key_pos] = get_model_key(key_pos, key_length)
		dmm_text += "\"[keys[key_pos]]\" = ([templates[key_pos]])\n"

	var/z_level = 0
	var/z_pos = 1
	while(z_pos < length(template_buffer))
		if(z_level)
			dmm_text += "\n"
		dmm_text += "\n(1,1,[++z_level]) = {\"\n"
		var/z_block = copytext(template_buffer,z_pos,findtext(template_buffer,".",z_pos))
		var/y_pos = 1
		while(y_pos < length(z_block))
			var/y_block = copytext(z_block,y_pos,findtext(z_block,";",y_pos))
			var/x_pos = 1
			while(x_pos < length(y_block))
				var/x_block = copytext(y_block,x_pos,findtext(y_block,",",x_pos))
				var/key_number = text2num(x_block)
				var/temp_key = keys[key_number]
				dmm_text += temp_key
				sleep(-1)
				x_pos = findtext(y_block, ",", x_pos) + 1
			dmm_text += "\n"
			sleep(-1)
			y_pos = findtext(z_block, ";", y_pos) + 1
		dmm_text += "\"}"
		sleep(-1)
		z_pos = findtext(template_buffer, ".", z_pos) + 1
	return dmm_text


/dmm_suite/proc/make_template(turf/T, flags)
	var/template = ""

	var/list/turf_contents = T.contents
	for(var/atom/A in T.contents)
		if(istype(A, /obj/structure/closet))
			for(var/atom/AC in A.contents)
				turf_contents += AC

	if(!(flags & (DMM_IGNORE_MOBS)))
		for(var/mob/M in turf_contents)
			template += "[M.type][check_attributes(M)],"

	if(!(flags & DMM_IGNORE_OBJS))
		for(var/obj/O in turf_contents)
			template += "[O.type][check_attributes(O)],"

	if(flags & DMM_IGNORE_TURFS)
		template += "[world.turf],"
	else if(isenvironmentturf(T))
		template += "/turf/environment/space,"
	else
		template += "[T.type][check_attributes(T)],"

	if(!(flags & DMM_IGNORE_AREAS))
		var/area/A = T.loc
		template += "[A.type][check_attributes(A)]"
	else
		template += "[world.area]"

	return template


/dmm_suite/proc/check_attributes(atom/A)
	var/attributes_text = "{"

	if(isobj(A))
		for(var/var_name in (obj_vars_to_save & A.vars))
			if(A.vars[var_name])
				attributes_text += "[var_name] = [pack_attribute(A.vars[var_name])]; "
		if(!A.smooth)
			attributes_text += "icon_state = [pack_attribute(A.icon_state)]; "

		var/obj/O = A
		if(length(O.req_access))
			attributes_text += "req_access = [pack_attribute(O.req_access)]; "
		if(length(O.req_one_access))
			attributes_text += "req_one_access = [pack_attribute(O.req_one_access)]; "

	else if(isarea(A))
		if(A.tag)
			attributes_text += "tag = [pack_attribute(A.tag)]; "
		attributes_text += "name = [pack_attribute(A.name)]"

	else if(isturf(A))
		if(!A.smooth)
			attributes_text += "icon_state = [pack_attribute(A.icon_state)]; "
		attributes_text += "dir = [pack_attribute(A.dir)]"

	if(attributes_text == "{")
		return

	attributes_text += "}"

	return attributes_text

/dmm_suite/proc/pack_attribute(V)
	if(istext(V))
		return "\"[V]\""
	if(isnum(V))
		return "[V]"
	if(isicon(V) || ispath(V))
		return "'[V]'"
	if(islist(V))
		var/list/L = V
		var/list_text = "list("
		for(var/E in L)
			list_text += pack_attribute(E)
			if(is_associative_list(L))
				list_text += " = " + pack_attribute(L[E])
			list_text += ", "

		if(list_text != "list(")
			list_text = copytext(list_text, 1, length(list_text) - 1)
		list_text += ")"
		return list_text

/dmm_suite/proc/get_model_key(which, key_length)
	var/key = ""
	var/working_digit = which - 1

	for(var/digit_pos = key_length; digit_pos >= 1; digit_pos--)
		var/place_value = round(working_digit / (letter_digits.len ** (digit_pos - 1)))
		working_digit -= place_value * (letter_digits.len ** (digit_pos -1 ))
		key = "[key][letter_digits[place_value+1]]"

	return key
