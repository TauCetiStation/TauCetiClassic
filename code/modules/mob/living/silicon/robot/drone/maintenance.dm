/mob/living/silicon/robot/drone/maintenance
	req_access = list(access_engine, access_robotics)

	// We need to keep track of a few module items so we don't need to do list operations
	// every time we need them. These get set in New() after the module is chosen.
	var/obj/item/stack/sheet/metal/cyborg/stack_metal = null
	var/obj/item/stack/sheet/wood/cyborg/stack_wood = null
	var/obj/item/stack/sheet/glass/cyborg/stack_glass = null
	var/obj/item/stack/sheet/mineral/plastic/cyborg/stack_plastic = null
	var/obj/item/weapon/matter_decompiler/decompiler = null


/mob/living/silicon/robot/drone/maintenance/atom_init()
	. = ..()
	drone_list += src

	if(camera && ("Robots" in camera.network))
		camera.add_network("Engineering Robots")

	module = new /obj/item/weapon/robot_module/drone(src)

	//Grab stacks.
	stack_metal = locate(/obj/item/stack/sheet/metal/cyborg) in src.module
	stack_wood = locate(/obj/item/stack/sheet/wood/cyborg) in src.module
	stack_glass = locate(/obj/item/stack/sheet/glass/cyborg) in src.module
	stack_plastic = locate(/obj/item/stack/sheet/mineral/plastic/cyborg) in src.module
	//Grab decompiler.
	decompiler = locate(/obj/item/weapon/matter_decompiler) in src.module

	//Some tidying-up.
	flavor_text = "It's a tiny little repair drone. The casing is stamped with an NT logo and the subscript: 'NanoTrasen Recursive Repair Systems: Fixing Tomorrow's Problem, Today!'"
	updateicon()

/mob/living/silicon/robot/drone/maintenance/Destroy()
	drone_list -= src
	return ..()

/mob/living/silicon/robot/drone/maintenance/init()
	laws = new /datum/ai_laws/drone()
	set_ai_link(null)

	aiCamera = new/obj/item/device/camera/siliconcam/drone_camera(src)
	playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/mob/living/silicon/robot/drone/maintenance/updatename()
	real_name = "maintenance drone ([rand(100,999)])"
	name = real_name

//Drones can only use binary and say emotes. NOTHING else.
//TBD, fix up boilerplate. ~ Z
/mob/living/silicon/robot/drone/maintenance/say(message)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (client.handle_spam_prevention(message,MUTE_IC))
			return

	message = sanitize(message)

	if(!message)
		return

	if (stat == DEAD)
		return say_dead(message)

	if(message[1] == "*")
		return emote(copytext(message, 2))
	else if(length(message) >= 2)
		if(parse_message_mode(message, "NONE") == "dronechat")
			if(!is_component_functioning("radio"))
				to_chat(src, "<span class='warning'>Your radio transmitter isn't functional.</span>")
				return

			for (var/mob/living/S as anything in drone_list)
				if(S.stat != DEAD)
					to_chat(S, "<i><span class='game say'>Drone Talk, <span class='name'>[name]</span><span class='message'> transmits, \"[trim(copytext(message,2 + length(message[2])))]\"</span></span></i>")

			for (var/mob/M as anything in observer_list)
				if(M.client && M.client.prefs.chat_toggles & CHAT_GHOSTEARS)
					to_chat(M, "<i><span class='game say'>Drone Talk, <span class='name'>[name]</span><span class='message'> transmits, \"[trim(copytext(message,2 + length(message[2])))]\"</span></span></i>")

		else
			var/list/listeners = hearers(5,src)
			listeners |= src

			for(var/mob/living/silicon/robot/drone/D in listeners)
				if(D.client)
					to_chat(D, "<b>[src]</b> transmits, \"[message]\"")

			for(var/mob/M as anything in observer_list)
				if(M.client && M.client.prefs.chat_toggles & CHAT_GHOSTEARS)
					to_chat(M, "<b>[src]</b> transmits, \"[message]\"")

/mob/living/silicon/robot/drone/maintenance/request_player()
	var/list/candidates = pollGhostCandidates("Someone is attempting to reboot a maintenance drone. Would you like to play as one?", ROLE_GHOSTLY, IGNORE_DRONE, 100, TRUE)
	for(var/mob/M in candidates) // No random
		transfer_personality(M.client)
		break

/mob/living/silicon/robot/drone/maintenance/transfer_personality(client/candidate)
	if(!candidate)
		return

	ckey = candidate.ckey

	if(candidate.mob && candidate.mob.mind)
		candidate.mob.mind.transfer_to(src)

	lawupdate = 0
	to_chat(src, "<b>Systems rebooted</b>. Loading base pattern maintenance protocol... <b>loaded</b>.")
	full_law_reset()
	to_chat(src, "<br><b>You are a maintenance drone, a tiny-brained robotic repair machine</b>.")
	to_chat(src, "You have no individual will, no personality, and no drives or urges other than your laws.")
	to_chat(src, "Use <b>:d</b> to talk to other drones and <b>say</b> to speak silently to your nearby fellows.")
	to_chat(src, "Remember,  you are <b>lawed against interference with the crew</b>. Also remember, <b>you DO NOT take orders from the AI.</b>")
	to_chat(src, "<b>Don't invade their worksites, don't steal their resources, don't tell them about the changeling in the toilets.</b>")
	to_chat(src, "<b>If a crewmember has noticed you, <i>you are probably breaking your third law</i></b>.")


//Putting the decompiler here to avoid doing list checks every tick.
/mob/living/silicon/robot/drone/maintenance/use_power()
	..()
	if(!src.has_power || !decompiler)
		return

	//The decompiler replenishes drone stores from hoovered-up junk each tick.
	for(var/type in decompiler.stored_comms)
		if(decompiler.stored_comms[type] > 0)
			var/obj/item/stack/sheet/stack
			switch(type)
				if("metal")
					if(!stack_metal)
						stack_metal = new (module, 1)
					stack = stack_metal
				if("glass")
					if(!stack_glass)
						stack_glass = new (module, 1)
					stack = stack_glass
				if("wood")
					if(!stack_wood)
						stack_wood = new (module, 1)
					stack = stack_wood
				if("plastic")
					if(!stack_plastic)
						stack_plastic = new (module, 1)
					stack = stack_plastic

			stack.add(1)
			decompiler.stored_comms[type]--;

//PRETTIER TOOL LIST.
/mob/living/silicon/robot/drone/maintenance/installed_modules()

	if(weapon_lock)
		to_chat(src, "<span class='warning'>Weapon lock active, unable to use modules! Count:[weaponlock_time]</span>")
		return

	if(!module)
		module = new /obj/item/weapon/robot_module/drone(src)

	var/dat = ""
	dat += {"
	<B>Activated Modules</B>
	<BR>
	Module 1: [module_state_1 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]<BR>
	Module 2: [module_state_2 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]<BR>
	Module 3: [module_state_3 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]<BR>
	<BR>
	<B>Installed Modules</B><BR><BR>"}


	var/tools = "<B>Tools and devices</B><BR>"
	var/resources = "<BR><B>Resources</B><BR>"

	for (var/O in module.modules)

		var/module_string = ""

		if (!O)
			module_string += text("<B>Resource depleted</B><BR>")
		else if(activated(O))
			module_string += text("[O]: <B>Activated</B><BR>")
		else
			module_string += text("[O]: <A HREF=?src=\ref[src];act=\ref[O]>Activate</A><BR>")

		if((istype(O,/obj/item/weapon) || istype(O,/obj/item/device)) && !(iscoil(O)))
			tools += module_string
		else
			resources += module_string

	dat += tools

	if (emagged)
		if (!module.emag)
			dat += text("<B>Resource depleted</B><BR>")
		else if(activated(module.emag))
			dat += text("[module.emag]: <B>Activated</B><BR>")
		else
			dat += text("[module.emag]: <A HREF=?src=\ref[src];act=\ref[module.emag]>Activate</A><BR>")

	dat += resources

	var/datum/browser/popup = new(src, "robotmod", "Drone modules")
	popup.set_content(dat)
	popup.open()
