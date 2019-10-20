/client/proc/Jump(area/A in return_sorted_areas())
	set name = "Jump to Area"
	set desc = "Area to jump to."
	set category = "Admin"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(config.allow_admin_jump)
		if(src.mob)
			var/mob/AM = src.mob
			AM.forceMove(pick(get_area_turfs(A)))
			log_admin("[key_name(usr)] jumped to [A]")
			message_admins("[key_name_admin(usr)] jumped to [A]")
			feedback_add_details("admin_verb","JA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		alert("Admin jumping disabled")

/client/proc/jumptoturf(turf/T in world)
	set name = "Jump to Turf"
	set category = "Admin"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(config.allow_admin_jump)
		if(src.mob)
			var/mob/A = src.mob
			A.forceMove(T)
			log_admin("[key_name(usr)] jumped to [T.x],[T.y],[T.z] in [T.loc]")
			message_admins("[key_name_admin(usr)] jumped to [T.x],[T.y],[T.z] in [T.loc]")
			feedback_add_details("admin_verb","JT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		alert("Admin jumping disabled")
	return

/client/proc/jumptomob(mob/M in mob_list)
	set category = "Admin"
	set name = "Jump to Mob"

	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(config.allow_admin_jump)

		if(src.mob)
			var/mob/A = src.mob
			var/turf/T = get_turf(M)
			if(T && isturf(T))
				A.forceMove(T)
				log_admin("[key_name(usr)] jumped to [key_name(M)]")
				message_admins("[key_name_admin(usr)] jumped to [key_name_admin(M)]")
				feedback_add_details("admin_verb","JM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
			else
				to_chat(A, "This mob is not located in the game world.")
	else
		alert("Admin jumping disabled")

/client/proc/jumptocoord(tx as num, ty as num, tz as num)
	set category = "Admin"
	set name = "Jump to Coordinate"

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if (config.allow_admin_jump)
		if(src.mob)
			var/mob/A = src.mob
			A.forceMove(locate(tx,ty,tz))
			log_admin("[key_name(usr)] jumped to coordinates [tx], [ty], [tz]")
			message_admins("[key_name_admin(usr)] jumped to coordinates [tx], [ty], [tz]")
			feedback_add_details("admin_verb","JC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		alert("Admin jumping disabled")

/client/proc/jumptokey()
	set category = "Admin"
	set name = "Jump to Key"

	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(config.allow_admin_jump)
		var/list/keys = list()
		for(var/mob/M in player_list)
			keys += M.client
		var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in sortKey(keys)
		if(!selection)
			to_chat(src, "No keys found.")
			return
		var/mob/M = selection:mob
		if(src.mob)
			var/mob/A = src.mob
			A.forceMove(M.loc)
			log_admin("[key_name(usr)] jumped to [key_name(M)]")
			message_admins("[key_name_admin(usr)] jumped to [key_name_admin(M)]")
			feedback_add_details("admin_verb","JK") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		alert("Admin jumping disabled")

/client/proc/Getmob(mob/M in mob_list)
	set category = "Admin"
	set name = "Get Mob"
	set desc = "Mob to teleport."
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(config.allow_admin_jump)
		M.forceMove(get_turf(usr))
		log_admin("[key_name(usr)] teleported [key_name(M)]")
		message_admins("[key_name_admin(usr)] teleported [key_name_admin(M)]")
		feedback_add_details("admin_verb","GM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		alert("Admin jumping disabled")

/client/proc/Getkey()
	set category = "Admin"
	set name = "Get Key"
	set desc = "Key to teleport."

	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(config.allow_admin_jump)
		var/list/keys = list()
		for(var/mob/M in player_list)
			keys += M.client
		var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in sortKey(keys)
		if(!selection)
			return
		var/mob/M = selection:mob

		if(!M)
			return

		if(M)
			M.forceMove(get_turf(usr))
			log_admin("[key_name(usr)] teleported [key_name(M)]")
			message_admins("[key_name_admin(usr)] teleported [key_name(M)]")
			feedback_add_details("admin_verb","GK") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		alert("Admin jumping disabled")

/client/proc/sendmob(mob/M in sortmobs())
	set category = "Admin"
	set name = "Send Mob"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/area/A = input(usr, "Pick an area.", "Pick an area") in return_sorted_areas()
	if(A)
		if(config.allow_admin_jump)
			M.forceMove(pick(get_area_turfs(A)))
			log_admin("[key_name(usr)] teleported [key_name(M)] to [A]")
			message_admins("[key_name_admin(usr)] teleported [key_name_admin(M)] to [A]")
			feedback_add_details("admin_verb","SMOB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		else
			alert("Admin jumping disabled")
