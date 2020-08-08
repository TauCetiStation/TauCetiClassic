/mob/camera/blob
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	icon = 'icons/mob/blob.dmi'
	icon_state = "marker"

	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	invisibility = INVISIBILITY_OBSERVER
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF

	pass_flags = PASSBLOB
	faction = "blob"

	var/obj/effect/blob/core/blob_core = null // The blob overmind's core
	var/blob_points = 0
	var/max_blob_points = 100
	var/victory_in_progress = FALSE
	var/static/added_to_blobminds = FALSE

/mob/camera/blob/atom_init()
	var/new_name = "[initial(name)] ([rand(1, 999)])"
	name = new_name
	real_name = new_name
	. = ..()
	START_PROCESSING(SSobj, src)

/mob/camera/blob/Login()
	..()
	sync_mind()
	update_health_hud()
	add_points(0)
	blob_help()
	if(!added_to_blobminds)
		added_to_blobminds = TRUE
		SSticker.mode.infected_crew |= mind

		var/list/datum/objective/objectives = list(
			new /datum/objective/blob_takeover()
			)
		for(var/datum/objective/O in objectives)
			O.owner = mind
		mind.objectives = objectives

		var/obj_count = 1
		to_chat(src, "<span class = 'notice'><B>Your current objectives:</B></span>")
		for(var/datum/objective/objective in mind.objectives)
			to_chat(src, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++

/mob/camera/blob/proc/blob_help()
	to_chat(src, "<span class='notice'>You are the overmind!</span>")
	to_chat(src, "You are the overmind and can control the blob! You can expand, which will attack people, and place new blob pieces such as...")
	to_chat(src, "<b>Normal Blob</b> will expand your reach and allow you to upgrade into special blobs that perform certain functions.")
	to_chat(src, "<b>Shield Blob</b> is a strong and expensive blob which can take more damage. It is fireproof and can block air, use this to protect yourself from station fires.")
	to_chat(src, "<b>Resource Blob</b> is a blob which will collect more resources for you, try to build these earlier to get a strong income. It will benefit from being near your core or multiple nodes, by having an increased resource rate; put it alone and it won't create resources at all.")
	to_chat(src, "<b>Node Blob</b> is a blob which will grow, like the core. Unlike the core it won't give you a small income but it can power resource and factory blobs to increase their rate.")
	to_chat(src, "<b>Factory Blob</b> is a blob which will spawn blob spores which will attack nearby food. Putting this nearby nodes and your core will increase the spawn rate; put it alone and it will not spawn any spores.")
	to_chat(src, "<b>Shortcuts:</b> CTRL Click = Expand Blob / Middle Mouse Click = Rally Spores / Alt Click = Create Shield")

/mob/camera/blob/proc/update_health_hud()
	if(blob_core && hud_used)
		hud_used.blobhealthdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[round(blob_core.health)]</font></div>"

/mob/camera/blob/proc/add_points(points)
	blob_points = clamp(blob_points + points, 0, max_blob_points)
	hud_used.blobpwrdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[round(src.blob_points)]</font></div>"


/mob/camera/blob/process()
	if(blob_core && !victory_in_progress && (blobs.len >= blobwincount))
		victory_in_progress = TRUE
		command_alert("Biohazard has reached critical mass. Station loss is imminent.", "Biohazard Alert")
		set_security_level("delta")
		max_blob_points = INFINITY
		blob_points = INFINITY
		if(!istype(SSticker.mode,/datum/game_mode/blob))
			addtimer(CALLBACK(src, .proc/victory), 450)

/mob/camera/blob/proc/victory()
	SSticker.force_ending = TRUE

/mob/camera/blob/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/mob/camera/blob/say(var/message)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat)
		return

	blob_talk(message)

/mob/camera/blob/proc/blob_talk(message)
	message = sanitize(message)

	log_say("[key_name(src)] : [message]")

	if (!message)
		return

	//var/message_a = say_quote(message)
	message = "<span class='say_quote'>says,</span> \"<span class='body'>[message]</span>\""
	message = "<font color=\"#EE4000\"><i><span class='game say'>Blob Telepathy, <span class='name'>[name]</span> <span class='message'>[message]</span></span></i></font>"

	for (var/mob/M in mob_list)
		if(isovermind(M) || isobserver(M))
			to_chat(M, message)

/mob/camera/blob/emote(act, m_type = SHOWMSG_VISUAL, message = null, auto)
	return

/mob/camera/blob/blob_act()
	return

/mob/camera/blob/Stat()
	..()
	if(statpanel("Status"))
		if(blob_core)
			stat(null, "Core Health: [blob_core.health]")
		stat(null, "Power Stored: [blob_points]/[max_blob_points]")
		stat(null, "Progress: [blobs.len]/[blobwincount]")
		stat(null, "Total Nodes: [blob_nodes.len]")
		stat(null, "Total Cores: [blob_cores.len]")

/mob/camera/blob/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = FALSE
	var/obj/effect/blob/B = locate() in range(3, NewLoc)
	if(NewLoc && B)
		loc = NewLoc
		return TRUE
