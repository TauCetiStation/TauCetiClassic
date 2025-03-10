#define AI_CHECK_WIRELESS 1
#define AI_CHECK_RADIO 2
#define EMERGENCY_MESSAGE_COOLDOWN 300

var/global/list/ai_verbs_default = list(
//	/mob/living/silicon/ai/proc/ai_recall_shuttle,
	/mob/living/silicon/ai/proc/ai_goto_location,
	/mob/living/silicon/ai/proc/ai_remove_location,
	/mob/living/silicon/ai/proc/ai_hologram_change,
	/mob/living/silicon/ai/proc/ai_network_change,
	/mob/living/silicon/ai/proc/ai_statuschange,
	/mob/living/silicon/ai/proc/ai_store_location,
	/mob/living/silicon/ai/proc/pick_icon,
	/mob/living/silicon/ai/proc/show_laws_verb,
	/mob/living/silicon/ai/proc/toggle_acceleration,
	/mob/living/silicon/ai/proc/toggle_retransmit,
	/mob/living/silicon/ai/proc/change_floor,
	/mob/living/silicon/ai/proc/ai_emergency_message
)

//Not sure why this is necessary...
/proc/AutoUpdateAI(obj/subject)
	var/is_in_use = FALSE
	if (subject!=null)
		for(var/A in ai_list)
			var/mob/living/silicon/ai/M = A
			if ((M.client && M.machine == subject))
				is_in_use = TRUE
				subject.attack_ai(M)
	return is_in_use

/mob/living/silicon/ai
	name = "AI"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai"
	anchored = TRUE // -- TLE
	density = TRUE
	canmove = FALSE
	status_flags = CANSTUN|CANPARALYSE
	shouldnt_see = list(/obj/effect/rune)
	w_class = SIZE_HUMAN
	var/list/network = list("SS13")
	var/obj/machinery/camera/camera = null
	var/list/connected_robots = list()
	var/aiRestorePowerRoutine = 0
	var/lawcheck[1]
	var/holohack = FALSE
	var/datum/AI_Module/active_module = null
	var/ioncheck[1]
	var/lawchannel = "Common" // Default channel on which to state laws
	var/icon/holo_icon //Default is assigned when AI is created.
	var/obj/item/device/multitool/aiMulti = null
	var/obj/item/device/radio/headset/heads/ai_integrated/aiRadio = null
	var/next_emergency_message_time = 0
	var/allow_auto_broadcast_messages = TRUE // For disabling retransmiting
//Hud stuff

	//MALFUNCTION
	var/processing_time = 100
	var/list/datum/AI_Module/current_modules = list()
	var/fire_res_on_core = 0

	var/control_disabled = 0 // Set to 1 to stop AI from interacting via Click() -- TLE
	var/malfhacking = 0 // More or less a copy of the above var, so that malf AIs can hack and still get new cyborgs -- NeoFite

	var/obj/machinery/power/apc/malfhack = null
	var/explosive = 0 //does the AI explode when it dies?

	var/mob/living/silicon/ai/parent = null

	var/apc_override = 0 //hack for letting the AI use its APC even when visionless

	var/camera_light_on = 0	//Defines if the AI toggled the light on the camera it's looking through.
	var/datum/trackable/track = null
	var/last_announcement = ""
	var/wipe_timer_id = 0

	var/mob/camera/Eye/ai/eyeobj
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1
	var/obj/machinery/hologram/holopad/holo = null

	// Radial menu for choose skin of core
	var/static/list/chooses_ai_cores
	// Radial menu for choose skin of standart hologram
	var/static/list/chooses_ai_holo
	// Radial menu for choose skin of staff hologram
	var/static/list/chooses_ai_staff
	// Radial menu for choose category of holo type
	var/static/list/chooses_holo_category
	// Radilal menu.
	var/static/list/name_by_state = list(
		"Standard" = "ai",
		"Rainbow" = "ai-clown",
		"Clown" = "ai-clown2",
		"Monochrome" = "ai-mono",
		"Inverted" = "ai-u",
		"Firewall" = "ai-magma",
		"Green" = "ai-wierd",
		"Red" = "ai-red",
		"Static" = "ai-static",
		"Text" = "ai-text",
		"Smiley" = "ai-smiley",
		"Matrix" = "ai-matrix",
		"Angry" = "ai-angryface",
		"Dorf" = "ai-dorf",
		"Bliss" = "ai-bliss",
		"Triumvirate" = "ai-triumvirate",
		"Triumvirate Static" = "ai-triumvirate-malf",
		"Soviet" = "ai-redoctober",
		"Trapped" = "ai-hades",
		"Heartline" = "ai-heartline",
		"No Pulse" = "ai-heartline_dead",
		"President" = "ai-president",
		"BANNED" = "ai-banned",
		"Helios" = "ai-helios",
		"House" = "ai-house",
		"Gigyas" = "ai-gigyas",
		"Yuki" = "ai-yuki",
		"SyndiCat" = "ai-syndicatmeow",
		"Hiss!" = "ai-alien",
		"Alter Ego" = "ai-alterego",
		"Urist" = "ai-toodeep",
		"Totally Not A Malf" = "ai-malf",
		"Fuzz" = "ai-fuzz",
		"Goon" = "ai-goon",
		"Database" = "ai-database",
		"Glitchman" = "ai-glitchman",
		"AmericAI" = "ai-murica",
		"NT" = "ai-nanotrasen",
		"Gentoo" = "ai-gentoo",
		"Hal 9000" = "ai-hal",
	)

	var/datum/announcement/station/command/ai/announcement = new

	var/legs = FALSE //shitspawn only var
	var/uses_legs = FALSE //shitspawn only var

/mob/living/silicon/ai/proc/add_ai_verbs()
	verbs |= ai_verbs_default

/mob/living/silicon/ai/proc/hcattack_ai(atom/A)
	if(!holo || !isliving(A) || !in_range(eyeobj, A))
		return FALSE
	if(get_dist(eyeobj, holo) > holo.holo_range) // some scums can catch a moment between ticks in process to make unwanted attack
		return FALSE
	SetNextMove(CLICK_CD_MELEE * 3)
	var/mob/living/L = A
	eyeobj.visible_message("<span class='userdanger'>space carp nashes at [A]</span>")
	L.apply_damage(15, BRUTE, BP_CHEST, L.run_armor_check(BP_CHEST, MELEE), DAM_SHARP|DAM_EDGE)
	playsound(eyeobj, 'sound/weapons/bite.ogg', VOL_EFFECTS_MASTER)
	return TRUE


/mob/living/silicon/ai/proc/remove_ai_verbs()
	verbs -= ai_verbs_default

/mob/living/silicon/ai/atom_init(mapload, datum/ai_laws/L, obj/item/device/mmi/B, safety = 0)
	. = ..()
	var/list/possibleNames = ai_names

	var/pickedName = null
	while(!pickedName)
		pickedName = pick(ai_names)
		for (var/mob/living/silicon/ai/A as anything in ai_list)
			if (A.real_name == pickedName && possibleNames.len > 1) //fixing the theoretically possible infinite loop
				possibleNames -= pickedName
				pickedName = null

	real_name = pickedName
	name = real_name

	holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo1"))

	if(L)
		if (istype(L, /datum/ai_laws))
			laws = L
	else
		laws = new base_law_type

	pda = new/obj/item/device/pda/silicon(src)
	pda.owner = name
	pda.ownjob = "AI"
	pda.name = name + " (" + pda.ownjob + ")"

	aiMulti = new(src)
	aiRadio = new(src)
	aiRadio.myAi = src

	aiCamera = new/obj/item/device/camera/siliconcam/ai_camera(src)

	if (isturf(loc))
		add_ai_verbs(src)

	//Languages
	add_language(LANGUAGE_SOLCOMMON, LANGUAGE_CAN_UNDERSTAND)
	add_language(LANGUAGE_SINTAUNATHI, LANGUAGE_CAN_UNDERSTAND)
	add_language(LANGUAGE_SIIKMAAS, LANGUAGE_CAN_UNDERSTAND)
	add_language(LANGUAGE_SIIKTAJR, LANGUAGE_CAN_UNDERSTAND)
	add_language(LANGUAGE_SKRELLIAN, LANGUAGE_CAN_UNDERSTAND)
	add_language(LANGUAGE_ROOTSPEAK, LANGUAGE_CAN_UNDERSTAND)
	add_language(LANGUAGE_TRADEBAND)
	add_language(LANGUAGE_TRINARY)
	add_language(LANGUAGE_GUTTER, LANGUAGE_CAN_UNDERSTAND)

	if(!safety) // Only used by AIize() to successfully spawn an AI.
		if(!B)  // If there is no player/brain inside.
			empty_playable_ai_cores += new/obj/structure/AIcore/deactivated(loc)//New empty terminal.
			return INITIALIZE_HINT_QDEL // Delete AI.
		else
			if (B.brainmob.mind)
				B.brainmob.mind.transfer_to(src)

			announce_role()

			job = "AI"

	create_eye()

	new /obj/machinery/ai_powersupply(src)

	ai_list += src

	if(mind)
		mind.skills.add_available_skillset(/datum/skillset/max)
		mind.skills.maximize_active_skills()

/mob/living/silicon/ai/proc/announce_role()
	to_chat(src, "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>")
	to_chat(src, "<B>To look at other parts of the station, click on yourself to get a camera menu.</B>")
	to_chat(src, "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>")
	to_chat(src, "To use something, simply click on it.")
	to_chat(src, "Use say \":b to speak to your cyborgs through binary.")
	if(!ismalf(src))
		show_laws()
		to_chat(src, "<b>These laws may be changed by other players, or by you being the traitor.</b>")

/mob/living/silicon/ai/Destroy()
	connected_robots.Cut()
	ai_list -= src
	qdel(eyeobj)
	return ..()

/mob/living/silicon/ai/IgniteMob()
	return FALSE //No we're not flammable


/*
	The AI Power supply is a dummy object used for powering the AI since only machinery should be using power.
	The alternative was to rewrite a bunch of AI code instead here we are.
*/
/obj/machinery/ai_powersupply
	name="Power Supply"
	active_power_usage=1000
	use_power = ACTIVE_POWER_USE
	var/mob/living/silicon/ai/powered_ai = null
	invisibility = 100

/obj/machinery/ai_powersupply/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/ai_powersupply/atom_init_late()
	var/mob/living/silicon/ai/ai = loc
	powered_ai = ai
	if(isnull(powered_ai))
		qdel(src)
		return

	forceMove(powered_ai.loc)
	use_power(1) // Just incase we need to wake up the power system.

/obj/machinery/ai_powersupply/process()
	if(!powered_ai || powered_ai.stat & DEAD)
		qdel(src)
		return
	if(!powered_ai.anchored)
		forceMove(powered_ai.loc)
		set_power_use(NO_POWER_USE)
	if(powered_ai.anchored)
		set_power_use(ACTIVE_POWER_USE)

/mob/living/silicon/ai/proc/gen_radial_cores()
	if(!chooses_ai_cores)
		chooses_ai_cores = list()
		for(var/name in name_by_state)
			chooses_ai_cores[name] = image(icon = 'icons/mob/AI.dmi', icon_state = name_by_state[name])

/mob/living/silicon/ai/proc/pick_icon()
	set category = "AI Commands"
	set name = "Set AI Core Display"
	if(check_unable())
		return

	gen_radial_cores()

	var/mob/showing_to = eyeobj
	if(uses_legs)
		showing_to = src
	var/state = show_radial_menu(usr, showing_to, chooses_ai_cores, radius = 50, tooltips = TRUE)
	if(!state)
		return
	icon_state = name_by_state[state]

// displays the malf_ai information if the AI is the malf
/mob/living/silicon/ai/show_malf_ai()
	var/datum/role/malfAI/M = ismalf(src)
	if(M)
		var/datum/faction/malf_silicons/malf = M.GetFaction()
		if (SSticker.hacked_apcs >= APC_MIN_TO_MALF_DECLARE)
			stat(null, "Time until station control secured: [max(malf.AI_win_timeleft/(SSticker.hacked_apcs/APC_MIN_TO_MALF_DECLARE), 0)] seconds")


/mob/living/silicon/ai/show_alerts()

	var/dat = ""
	for (var/cat in alarms)
		dat += "<B>[cat]</B><BR>"
		var/list/alarmlist = alarms[cat]
		if (alarmlist.len)
			for (var/area_name in alarmlist)
				var/datum/alarm/alarm = alarmlist[area_name]

				var/cameratext
				if (alarm.cameras)
					for (var/obj/machinery/camera/I in alarm.cameras)
						cameratext += "<br>---- <A HREF=?src=\ref[src];switchcamera=\ref[I]>[I.c_tag]</A>"
				dat += "-- [alarm.area.name] [cameratext ? cameratext : "No Camera"]"

				if (alarm.sources.len > 1)
					dat += text(" - [] sources", alarm.sources.len)
				dat += "<BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	var/datum/browser/popup = new(src, "window=aialerts", "Current Station Alerts")
	popup.set_content(dat)
	popup.open()

/mob/living/silicon/ai/proc/can_retransmit_messages()
	return (stat != DEAD && !control_disabled && aiRadio && !aiRadio.disabledAi && allow_auto_broadcast_messages)

/mob/living/silicon/ai/proc/retransmit_message(message)
	if (aiRadio)
		aiRadio.talk_into(src, message)

/mob/living/silicon/ai/proc/toggle_retransmit()
	set category = "AI Commands"
	set name = "Toggle Auto Messages"
	if (allow_auto_broadcast_messages)
		to_chat(usr, "Your core is <b>disconnected</b> from station information module.")
	else
		to_chat(usr, "Your core is <b>connected</b> to station information module.")
	allow_auto_broadcast_messages = !allow_auto_broadcast_messages

/mob/living/silicon/ai/var/message_cooldown = 0
/mob/living/silicon/ai/proc/ai_announcement()

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	if(message_cooldown)
		to_chat(src, "Please allow one minute to pass between announcements.")
		return
	var/input = sanitize(input(usr, "Please write a message to announce to the station crew.", "A.I. Announcement") as null|message)
	if(message_cooldown)
		to_chat(src, "Please allow one minute to pass between announcements.")
		return

	if(!input)
		return

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	announcement.play(src, input)
	log_say("[key_name(usr)] has made an AI announcement: [input]")
	message_admins("[key_name_admin(usr)] has made an AI announcement.")
	message_cooldown = 1
	spawn(600)//One minute cooldown
		message_cooldown = 0

/mob/living/silicon/ai/proc/ai_call_shuttle()

	if(check_unable(AI_CHECK_WIRELESS))
		return

	var/confirm = tgui_alert(src, "Вы уверены, что хотите вызвать экстренный шаттл?", "Подтвердите вызов шаттла", list("Да", "Нет"))

	if(check_unable(AI_CHECK_WIRELESS))
		return

	if(confirm == "Да")
		call_shuttle_proc(src)

	// hack to display shuttle timer
	if(SSshuttle.online)
		var/obj/machinery/computer/communications/C = locate() in communications_list
		if(C)
			C.post_status("shuttle")

	return

/mob/living/silicon/ai/proc/change_floor()
	set category = "AI Commands"
	set name = "Change Floor"

	var/f_color = input("Choose your color, dark colors are not recommended!") as color|null
	if(!f_color)
		return
	for(var/turf/simulated/floor/whitegreed/F  in world)
		F.color = f_color

	to_chat(usr, "Floor color was change to [f_color]")

/mob/living/silicon/ai/proc/ai_emergency_message()
	set category = "AI Commands"
	set name = "Send Emergency Message"

	if(check_unable(AI_CHECK_WIRELESS))
		return
	if(world.time < next_emergency_message_time)
		to_chat(usr, "<span class='warning'>Arrays recycling. Please stand by.</span>")
		return
	var/input = sanitize(input(usr, "Please choose a message to transmit to Centcom via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination.  Transmission does not guarantee a response. There is a 30 second delay before you may send another message, be clear, full and concise.", "To abort, send an empty message.", ""))
	if(!input)
		return
	Centcomm_announce(input, usr)
	to_chat(usr, "<span class='notice'>Message transmitted.</span>")
	log_say("[key_name(usr)] has sent an emergency message: [input]")
	next_emergency_message_time = world.time + EMERGENCY_MESSAGE_COOLDOWN

/mob/living/silicon/ai/proc/ai_recall_shuttle()
	set category = "AI Commands"
	set name = "Recall Emergency Shuttle"

	if(check_unable(AI_CHECK_WIRELESS))
		return

	var/confirm = tgui_alert(usr, "Are you sure you want to recall the shuttle?", "Confirm Shuttle Recall", list("Yes", "No"))
	if(check_unable(AI_CHECK_WIRELESS))
		return

	if(confirm == "Yes")
		cancel_call_proc(src)

/mob/living/silicon/ai/check_eye(mob/user)
	if (!camera)
		return null
	user.reset_view(camera)
	return 1

/mob/living/silicon/ai/blob_act()
	if (stat != DEAD)
		adjustBruteLoss(60)
		updatehealth()
		return 1
	return 0

/mob/living/silicon/ai/restrained()
	return 0

/mob/living/silicon/ai/emp_act(severity)
	if (prob(30))
		switch(pick(1,2))
			if(1)
				view_core()
			if(2)
				ai_call_shuttle()
	..()

/mob/living/silicon/ai/ex_act(severity)
	if(stat == DEAD)
		return
	if(!blinded)
		flash_eyes()
	switch(severity)
		if(EXPLODE_DEVASTATE)
			adjustBruteLoss(100)
			adjustFireLoss(100)
		if(EXPLODE_HEAVY)
			adjustBruteLoss(60)
			adjustFireLoss(60)
		if(EXPLODE_LIGHT)
			adjustBruteLoss(30)
	updatehealth()

/mob/living/silicon/ai/Topic(href, href_list)
	if(usr != src)
		return
	..()
	if (href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"])) in cameranet.cameras
	if (href_list["showalerts"])
		show_alerts()
	//Carn: holopad requests
	if (href_list["jumptoholopad"])
		var/obj/machinery/hologram/holopad/H = locate(href_list["jumptoholopad"])
		if(stat == CONSCIOUS)
			if(H)
				H.attack_ai(src) //may as well recycle
			else
				to_chat(src, "<span class='notice'>Unable to locate the holopad.</span>")

	if (href_list["lawc"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawc"])
		switch(lawcheck[L+1])
			if ("Yes") lawcheck[L+1] = "No"
			if ("No") lawcheck[L+1] = "Yes"
//		src << text ("Switching Law [L]'s report status to []", lawcheck[L+1])
		checklaws()

	if (href_list["lawr"]) // Selects on which channel to state laws
		var/setchannel = tgui_input_list(usr, "Specify channel.", "Channel selection", list("State","Common","Science","Command","Medical","Engineering","Security","Supply","Binary","Holopad", "Cancel"))
		if(setchannel == "Cancel")
			return
		lawchannel = setchannel
		checklaws()

	//Uncomment this line of code if you are enabling the AI Vocal (VOX) announcements.
/*
	if(href_list["say_word"])
		play_vox_word(href_list["say_word"], null, src)
		return
*/

	if (href_list["lawi"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawi"])
		switch(ioncheck[L])
			if ("Yes") ioncheck[L] = "No"
			if ("No") ioncheck[L] = "Yes"
//		src << text ("Switching Law [L]'s report status to []", lawcheck[L+1])
		checklaws()

	if (href_list["laws"]) // With how my law selection code works, I changed statelaws from a verb to a proc, and call it through my law selection panel. --NeoFite
		statelaws()

	if (href_list["track"])
		var/mob/target = locate(href_list["track"]) in living_list
		if(target)
			ai_actual_track(target)
			return
		var/mob/living/carbon/human/H = locate(href_list["track"]) in living_list
		if(html_decode(href_list["trackname"]) == H.get_visible_name())
			ai_actual_track(H)
			return
		to_chat(src, "<span class='rose'>System error. Cannot locate [html_decode(href_list["trackname"])].</span>")
		return

	else if (href_list["faketrack"])
		var/mob/target = locate(href_list["track"]) in living_list
		var/mob/living/silicon/ai/A = locate(href_list["track2"]) in ai_list
		if(A && target)

			A.cameraFollow = target
			to_chat(A, text("Now tracking [] on camera.", target.name))
			if (usr.machine == null)
				usr.machine = usr

			while (src.cameraFollow == target)
				to_chat(usr, "Target is not on or near any active cameras on the station. We'll check again in 5 seconds (unless you use the cancel-camera verb).")
				sleep(40)
				continue

		return

	if(href_list["x"] && href_list["y"] && href_list["z"])
		var/tx = text2num(href_list["x"])
		var/ty = text2num(href_list["y"])
		var/tz = text2num(href_list["z"])
		var/turf/target = locate(tx, ty, tz)
		if(istype(target))
			eyeobj.forceMove(target)
			return

	return

/mob/living/silicon/ai/bullet_act(obj/item/projectile/Proj, def_zone)
	. = ..()
	if(. == PROJECTILE_ABSORBED || . == PROJECTILE_FORCE_MISS)
		return

	updatehealth()

/mob/living/silicon/ai/reset_view(atom/A, force_remote_viewing)
	if(camera)
		camera.set_light(0)
	if(istype(A,/obj/machinery/camera))
		camera = A
	..()
	if(istype(A,/obj/machinery/camera))
		if(camera_light_on)	A.set_light(AI_CAMERA_LUMINOSITY)
		else				A.set_light(0)


/mob/living/silicon/ai/proc/switchCamera(obj/machinery/camera/C)

	src.cameraFollow = null

	if (!C || stat == DEAD) //C.can_use())
		return 0

	if(!src.eyeobj)
		view_core()
		return
	// ok, we're alive, camera is good and in our network...
	eyeobj.setLoc(get_turf(C))
	//machine = src

	return 1

/mob/living/silicon/ai/triggerAlarm(class, area/A, list/cameralist, source)
	if (stat == DEAD)
		return 1

	..()

	var/cameratext = ""
	for (var/obj/machinery/camera/C in cameralist)
		cameratext += "[(cameratext == "")? "" : "|"]<A HREF=?src=\ref[src];switchcamera=\ref[C]>[C.c_tag]</A>"

	queueAlarm("--- [class] alarm detected in [A.name]! ([(cameratext)? cameratext : "No Camera"])", class)

/mob/living/silicon/ai/cancelAlarm(class, area/A, source)
	var/has_alarm = ..()

	if (!has_alarm)
		queueAlarm(text("--- [] alarm in [] has been cleared.", class, A.name), class, 0)

	return has_alarm

/mob/living/silicon/ai/cancel_camera()
	set category = "AI Commands"
	set name = "Cancel Camera View"

	//src.cameraFollow = null
	view_core()


//Replaces /mob/living/silicon/ai/verb/change_network() in ai.dm & camera.dm
//Adds in /mob/living/silicon/ai/proc/ai_network_change() instead
//Addition by Mord_Sith to define AI's network change ability
/mob/living/silicon/ai/proc/ai_network_change()
	set category = "AI Commands"
	set name = "Jump To Network"
	unset_machine()
	src.cameraFollow = null
	var/cameralist[0]

	if(check_unable())
		return

	var/mob/living/silicon/ai/U = usr

	for (var/obj/machinery/camera/C in cameranet.cameras)
		if(!C.can_use())
			continue

		if(C.hidden)
			continue

		var/list/tempnetwork = difflist(C.network,RESTRICTED_CAMERA_NETWORKS,1)
		if(tempnetwork.len)
			for(var/i in tempnetwork)
				cameralist[i] = i
	var/old_network = network
	network = tgui_input_list(U, "Which network would you like to view?", "Jump To Network", cameralist)

	if(!U.eyeobj)
		U.view_core()
		return

	if(isnull(network))
		network = old_network // If nothing is selected
		return
	else
		for(var/obj/machinery/camera/C in cameranet.cameras)
			if(!C.can_use())
				continue
			if(network in C.network)
				U.eyeobj.setLoc(get_turf(C))
				break
	to_chat(src, "<span class='notice'>Switched to [network] camera network.</span>")
//End of code by Mord_Sith




/mob/living/silicon/ai/proc/ai_statuschange()
	set category = "AI Commands"
	set name = "AI Status"

	if(check_unable(AI_CHECK_WIRELESS))
		return

	var/list/ai_emotions = list("Very Happy", "Happy", "Neutral", "Unsure", "Confused", "Sad", "BSOD", "Blank", "Problems?", "Awesome", "Dorfy", "Facepalm", "Friend Computer", "Beer mug", "Dwarf", "Fishtank", "Plump Helmet", "HAL", "Tribunal", "Tribunal Malfunctioning")
	var/emote = tgui_input_list(usr, "Please, select a status!", "AI Status", ai_emotions)
	for(var/obj/machinery/ai_status_display/AISD in ai_status_display_list) //change status
		AISD.emotion = emote
	if(emote == "Friend Computer")  //if Friend Computer, change ALL displays, else restore them to normal
		for(var/obj/machinery/status_display/SD in status_display_list)
			SD.friendc = TRUE
	else
		for(var/obj/machinery/status_display/SD in status_display_list)
			SD.friendc = FALSE
	return

/mob/living/silicon/ai/proc/gen_ai_uniq_holo()
	var/icon_list = list(
		"Default",
		"Floatingface",
		"Alien",
		"Carp",
		"Queen",
		"Rommie",
		"Sonny",
		"Miku",
		"Medbot",
	)

	if(!chooses_ai_holo)
		chooses_ai_holo = list()
		var/i = 1
		for(var/name_holo in icon_list)
			chooses_ai_holo[name_holo] = getHologramIcon(icon('icons/mob/AI.dmi', "holo[i]"))
			i++

/mob/living/silicon/ai/proc/gen_ai_staff_holo()
	if(!chooses_ai_staff)
		chooses_ai_staff = list()

	for(var/datum/data/record/t in data_core.locked) //Look in data core locked.
		if(chooses_ai_staff["[t.fields["name"]]: [t.fields["rank"]]"])
			continue

		chooses_ai_staff["[t.fields["name"]]: [t.fields["rank"]]"] = getHologramIcon(icon(t.fields["image"])) //Pull names, rank, and image.

/mob/living/silicon/ai/proc/gen_radial_holo(type)
	switch(type)
		if("Crew Member Category")
			gen_ai_staff_holo()
			if(chooses_ai_staff.len)
				var/state = show_radial_menu(usr, eyeobj, chooses_ai_staff, radius = 38, tooltips = TRUE)
				if(!state)
					return
				if(chooses_ai_staff[state])
					holo_icon = chooses_ai_staff[state]
			else
				tgui_alert(usr, "No suitable records found. Aborting.")

		if("Unique Category")
			gen_ai_uniq_holo()
			var/state = show_radial_menu(usr, eyeobj, chooses_ai_holo, radius = 38, tooltips = TRUE)
			if(!state)
				return
			holo_icon = chooses_ai_holo[state]

//I am the icon meister. Bow fefore me.	//>fefore
/mob/living/silicon/ai/proc/ai_hologram_change()
	set name = "Change Hologram"
	set desc = "Change the default hologram available to AI to something else."
	set category = "AI Commands"

	if(check_unable())
		return

	if(!chooses_holo_category)
		chooses_holo_category = list()
		chooses_holo_category["Crew Member Category"] = getHologramIcon(icon('icons/mob/AI.dmi', "holo1"))
		chooses_holo_category["Unique Category"] = getHologramIcon(icon('icons/mob/AI.dmi', "holo4"))

	var/asnwer = show_radial_menu(usr, eyeobj, chooses_holo_category, tooltips = TRUE)
	if(!asnwer)
		return
	gen_radial_holo(asnwer)

/*/mob/living/silicon/ai/proc/corereturn()
	set category = "Malfunction"
	set name = "Return to Main Core"

	var/obj/machinery/power/apc/apc = src.loc
	if(!istype(apc))
		to_chat(src, "<span class='notice'>You are already in your Main Core.</span>")
		return
	apc.malfvacate()*/

//Toggles the luminosity and applies it by re-entereing the camera.
/mob/living/silicon/ai/proc/toggle_camera_light()

	if(check_unable())
		return

	camera_light_on = !camera_light_on
	to_chat(src, "Camera lights [camera_light_on ? "activated" : "deactivated"].")
	if(!camera_light_on)
		if(camera)
			camera.set_light(0)
			camera = null
	else
		lightNearbyCamera()



// Handled camera lighting, when toggled.
// It will get the nearest camera from the eyeobj, lighting it.

/mob/living/silicon/ai/proc/lightNearbyCamera()
	if(camera_light_on && camera_light_on < world.timeofday)
		if(src.camera)
			var/obj/machinery/camera/camera = near_range_camera(src.eyeobj)
			if(camera && src.camera != camera)
				camera.set_light(0)
				if(!camera.light_disabled)
					src.camera = camera
					camera.set_light(AI_CAMERA_LUMINOSITY)
				else
					src.camera = null
			else if(isnull(camera))
				camera.set_light(0)
				src.camera = null
		else
			var/obj/machinery/camera/camera = near_range_camera(src.eyeobj)
			if(camera && !camera.light_disabled)
				src.camera = camera
				camera.set_light(AI_CAMERA_LUMINOSITY)
		camera_light_on = world.timeofday + 1 * 20 // Update the light every 2 seconds.


/mob/living/silicon/ai/attackby(obj/item/weapon/W, mob/user)
	if(iswrenching(W))
		if(user.is_busy()) return
		if(anchored)
			user.visible_message("<span class='notice'>\The [user] starts to unbolt \the [src] from the plating...</span>")
			if(!W.use_tool(src, user, 40, volume = 50))
				user.visible_message("<span class='notice'>\The [user] decides not to unbolt \the [src].</span>")
				return
			user.visible_message("<span class='notice'>\The [user] finishes unfastening \the [src]!</span>")
			anchored = FALSE
			return
		else
			user.visible_message("<span class='notice'>\The [user] starts to bolt \the [src] to the plating...</span>")
			if(!W.use_tool(src, user, 40, volume = 50))
				user.visible_message("<span class='notice'>\The [user] decides not to bolt \the [src].</span>")
				return
			user.visible_message("<span class='notice'>\The [user] finishes fastening down \the [src]!</span>")
			anchored = TRUE
			return
	else
		return ..()

/mob/living/silicon/ai/proc/control_integrated_radio()

	if(check_unable(AI_CHECK_RADIO))
		return

	to_chat(src, "Accessing Subspace Transceiver control...")
	if (src.aiRadio)
		aiRadio.interact(src)

/mob/living/silicon/ai/proc/check_unable(flags = 0)
	if(stat == DEAD)
		to_chat(usr, "<span class='warning'>You are dead!</span>")
		return 1

	if((flags & AI_CHECK_WIRELESS) && src.control_disabled)
		to_chat(usr, "<span class='warning'>Wireless control is disabled!</span>")
		return 1
	if((flags & AI_CHECK_RADIO) && src.aiRadio.disabledAi)
		to_chat(src, "<span class='warning'>System Error - Transceiver Disabled!</span>")
		return 1
	return 0

/mob/living/silicon/ai/proc/is_in_chassis()
	return istype(loc, /turf)

/mob/living/silicon/ai/proc/toggle_small_alt_click_module(new_mod_name)
	var/datum/AI_Module/small/new_mod = current_modules[new_mod_name]
	if(!new_mod)
		to_chat(src, "<span class='warning'>ERROR: CAN'T FIND MODULE!</span>")
		return
	if(new_mod.uses)
		if(active_module != new_mod)
			active_module = new_mod
			to_chat(src, "[new_mod_name] module active. Alt+click to choose a machine to overload.")
		else
			active_module = null
			to_chat(src, "[new_mod_name] module deactivated.")
	else
		to_chat(src, "[new_mod_name] module activation failed. Out of uses.")

/mob/living/silicon/ai/CanObtainCentcommMessage()
	return TRUE

#undef AI_CHECK_WIRELESS
#undef AI_CHECK_RADIO
#undef EMERGENCY_MESSAGE_COOLDOWN

/mob/living/silicon/ai/ghost()
	if(istype(loc, /obj/item/device/aicard) || istype(loc, /obj/item/clothing/suit/space/space_ninja))
		return ..()
	if(ismalf(usr) && stat != DEAD)
		to_chat(usr, "<span class='danger'>You cannot use this verb in malfunction. If you need to leave, please adminhelp.</span>")
		return
	if(stat != CONSCIOUS)
		return ..()

	// Wipe Core
	// Guard against misclicks, this isn't the sort of thing we want happening accidentally
	if(tgui_alert(usr, "WARNING: This will immediately wipe your core and ghost you, removing your character from the round permanently (similar to cryo and robotic storage). Are you entirely sure you want to do this?",
					"Wipe Core", list("No", "Yes")) != "Yes")
		return
	perform_wipe_core()

/mob/living/silicon/ai/proc/allow_walking()
	legs = !legs
	if(!legs)
		verbs -= /mob/living/silicon/ai/proc/toggle_walking
		to_chat(src, "M.O.V.E. protocol has been disabled.")
		if(uses_legs)
			toggle_walking()
	else
		verbs += /mob/living/silicon/ai/proc/toggle_walking
		to_chat(src, "M.O.V.E. protocol has been enabled.")

/mob/living/silicon/ai/proc/toggle_walking()
	set name = "Toggle Moving"
	set desc = "Deploy or conceal your hidden mobility threads."
	set category = "AI Commands"

	if(stat == DEAD)
		return

	view_core()
	uses_legs = !uses_legs
	canmove = !canmove
	cut_overlays()
	playsound(src, 'sound/misc/ai_threads.ogg', VOL_EFFECTS_MASTER, 70, FALSE)

	visible_message("<span class='notice'>[src] [uses_legs ? "engages" : "disengages"] it's mobility module!</span>")

	if(uses_legs)
		var/image/legs = image(icon, src, "threads", MOB_LAYER, pixel_y = -9)
		legs.plane = plane
		add_overlay(legs)
		pixel_y = 8
	else
		pixel_y = 0
