#define AI_CHECK_WIRELESS 1
#define AI_CHECK_RADIO 2
#define EMERGENCY_MESSAGE_COOLDOWN 300

var/list/ai_verbs_default = list(
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
	icon = 'icons/mob/AI.dmi'//
	icon_state = "ai"
	anchored = TRUE // -- TLE
	density = TRUE
	canmove = FALSE
	status_flags = CANSTUN|CANPARALYSE
	shouldnt_see = list(/obj/effect/rune)
	var/list/network = list("SS13")
	var/obj/machinery/camera/camera = null
	var/list/connected_robots = list()
	var/aiRestorePowerRoutine = 0
	//var/list/laws = list()
	var/viewalerts = 0
	var/lawcheck[1]
	var/holohack = FALSE
	var/datum/AI_Module/active_module = null
	var/ioncheck[1]
	var/lawchannel = "Common" // Default channel on which to state laws
	var/icon/holo_icon//Default is assigned when AI is created.
	var/obj/item/device/multitool/aiMulti = null
	var/obj/item/device/radio/headset/heads/ai_integrated/aiRadio = null
	var/custom_sprite = 0 //For our custom sprites
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

/mob/living/silicon/ai/proc/add_ai_verbs()
	verbs |= ai_verbs_default
	verbs -= /mob/living/verb/ghost

/mob/living/silicon/ai/proc/hcattack_ai(atom/A)
	if(!holo || !isliving(A) || !in_range(eyeobj, A))
		return FALSE
	if(get_dist(eyeobj, holo) > holo.holo_range) // some scums can catch a moment between ticks in process to make unwanted attack
		return FALSE
	SetNextMove(CLICK_CD_MELEE * 3)
	var/mob/living/L = A
	eyeobj.visible_message("<span class='userdanger'>space carp nashes at [A]</span>")
	L.apply_damage(15, BRUTE, BP_CHEST, L.run_armor_check(BP_CHEST, "melee"), DAM_SHARP|DAM_EDGE)
	playsound(eyeobj, 'sound/weapons/bite.ogg', VOL_EFFECTS_MASTER)
	return TRUE


/mob/living/silicon/ai/proc/remove_ai_verbs()
	verbs -= ai_verbs_default
	verbs += /mob/living/verb/ghost

/mob/living/silicon/ai/atom_init(mapload, datum/ai_laws/L, obj/item/device/mmi/B, safety = 0)
	. = ..()
	var/list/possibleNames = ai_names

	var/pickedName = null
	while(!pickedName)
		pickedName = pick(ai_names)
		for (var/mob/living/silicon/ai/A in ai_list)
			if (A.real_name == pickedName && possibleNames.len > 1) //fixing the theoretically possible infinite loop
				possibleNames -= pickedName
				pickedName = null

	real_name = pickedName
	name = real_name

	holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo1"))

	proc_holder_list = new()

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
	add_language("Sol Common", 0)
	add_language("Sinta'unathi", 0)
	add_language("Siik'maas", 0)
	add_language("Siik'tajr", 0)
	add_language("Skrellian", 0)
	add_language("Rootspeak", 0)
	add_language("Tradeband", 1)
	add_language("Trinary", 1)
	add_language("Gutter", 0)

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

	hud_list[HEALTH_HUD]      = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[STATUS_HUD]      = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[ID_HUD]          = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[WANTED_HUD]      = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPLOYAL_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPCHEM_HUD]     = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPTRACK_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[SPECIALROLE_HUD] = image('icons/mob/hud.dmi', src, "hudblank")

	ai_list += src

/mob/living/silicon/ai/proc/announce_role()
	to_chat(src, "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>")
	to_chat(src, "<B>To look at other parts of the station, click on yourself to get a camera menu.</B>")
	to_chat(src, "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>")
	to_chat(src, "To use something, simply click on it.")
	to_chat(src, "Use say \":b to speak to your cyborgs through binary.")
	if (!(SSticker && SSticker.mode && (src.mind in SSticker.mode.malf_ai)))
		src.show_laws()
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

/mob/living/silicon/ai/proc/pick_icon()
	set category = "AI Commands"
	set name = "Set AI Core Display"
	if(stat || aiRestorePowerRoutine)
		return
	if(!custom_sprite) //Check to see if custom sprite time, checking the appopriate file to change a var
		var/file = file2text("config/custom_sprites.txt")
		var/lines = splittext(file, "\n")

		for(var/line in lines)
		// split & clean up
			var/list/Entry = splittext(line, ":")
			for(var/i = 1 to Entry.len)
				Entry[i] = trim(Entry[i])

			if(Entry.len < 2)
				continue;

			if(Entry[1] == src.ckey && Entry[2] == src.real_name)
				custom_sprite = 1 //They're in the list? Custom sprite time
				icon = 'icons/mob/custom-synthetic.dmi'

		//if(icon_state == initial(icon_state))
	var/icontype = ""
	if (custom_sprite == 1) icontype = ("Custom")//automagically selects custom sprite if one is available
	else icontype = input("Select an icon!", "AI", null, null) in list("Monochrome", "Rainbow","Clown", "Blue", "Inverted", "Text", "Smiley", "Angry", "Dorf", "Matrix", "Bliss", "Firewall", "Green", "Red", "Static", "Triumvirate", "Triumvirate Static", "Soviet", "Trapped", "Heartline","No Pulse","President","BANNED","Helios","House","Yuki","Hiss!","Alter Ego","Urist","Totally Not A Malf","Fuzz","Goon","Database","Glitchman","AmericAI","NT","Gentoo","Hal 9000")
	switch(icontype)
		if("Custom") icon_state = "[src.ckey]-ai"
		if("Rainbow") icon_state = "ai-clown"
		if("Clown") icon_state = "ai-clown2"
		if("Monochrome") icon_state = "ai-mono"
		if("Inverted") icon_state = "ai-u"
		if("Firewall") icon_state = "ai-magma"
		if("Green") icon_state = "ai-wierd"
		if("Red") icon_state = "ai-red"
		if("Static") icon_state = "ai-static"
		if("Text") icon_state = "ai-text"
		if("Smiley") icon_state = "ai-smiley"
		if("Matrix") icon_state = "ai-matrix"
		if("Angry") icon_state = "ai-angryface"
		if("Dorf") icon_state = "ai-dorf"
		if("Bliss") icon_state = "ai-bliss"
		if("Triumvirate") icon_state = "ai-triumvirate"
		if("Triumvirate Static") icon_state = "ai-triumvirate-malf"
		if("Soviet") icon_state = "ai-redoctober"
		if("Trapped") icon_state = "ai-hades"
		if("Heartline") icon_state = "ai-heartline"
		if("No Pulse") icon_state = "ai-heartline_dead"
		if("President") icon_state = "ai-president"
		if("BANNED") icon_state = "ai-banned"
		if("Helios") icon_state = "ai-helios"
		if("House") icon_state = "ai-house"
		if("Gigyas") icon_state = "ai-gigyas"
		if("Yuki") icon_state = "ai-yuki"
		if("SyndiCat") icon_state = "ai-syndicatmeow"
		if("Yuki") icon_state = "ai-yuki"
		if("Hiss!") icon_state = "ai-alien"
		if("Alter Ego") icon_state = "ai-alterego"
		if("Urist") icon_state = "ai-toodeep"
		if("Totally Not A Malf") icon_state = "ai-malf"
		if("Fuzz") icon_state = "ai-fuzz"
		if("Goon") icon_state = "ai-goon"
		if("Database") icon_state = "ai-database"
		if("Glitchman") icon_state = "ai-glitchman"
		if("AmericAI") icon_state = "ai-murica"
		if("NT") icon_state = "ai-nanotrasen"
		if("Gentoo") icon_state = "ai-gentoo"
		if("Hal 9000") icon_state = "ai-hal"
		else icon_state = "ai"
	//else
			//usr <<"You can only change your display once!"
			//return


// displays the malf_ai information if the AI is the malf
/mob/living/silicon/ai/show_malf_ai()
	if(SSticker.mode.name == "AI malfunction")
		var/datum/game_mode/malfunction/malf = SSticker.mode
		for (var/datum/mind/malfai in malf.malf_ai)
			if (mind == malfai) // are we the evil one?
				if (malf.apcs >= APC_MIN_TO_MALF_DECLARE)
					stat(null, "Time until station control secured: [max(malf.AI_win_timeleft/(malf.apcs/APC_MIN_TO_MALF_DECLARE), 0)] seconds")


/mob/living/silicon/ai/show_alerts()

	var/dat = ""
	for (var/cat in alarms)
		dat += text("<B>[]</B><BR>\n", cat)
		var/list/alarmlist = alarms[cat]
		if (alarmlist.len)
			for (var/area_name in alarmlist)
				var/datum/alarm/alarm = alarmlist[area_name]
				dat += "<NOBR>"

				var/cameratext = ""
				if (alarm.cameras)
					for (var/obj/machinery/camera/I in alarm.cameras)
						cameratext += text("[]<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>", (cameratext=="") ? "" : " | ", src, I, I.c_tag)
				dat += text("-- [] ([])", alarm.area.name, (cameratext)? cameratext : "No Camera")

				if (alarm.sources.len > 1)
					dat += text(" - [] sources", alarm.sources.len)
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	viewalerts = 1

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
	if(!input)
		return

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	captain_announce(input, "A.I. Announcement", src.name, "aiannounce")
	log_say("[key_name(usr)] has made an AI announcement: [input]")
	message_admins("[key_name_admin(usr)] has made an AI announcement.")
	message_cooldown = 1
	spawn(600)//One minute cooldown
		message_cooldown = 0

/mob/living/silicon/ai/proc/ai_call_shuttle()

	if(check_unable(AI_CHECK_WIRELESS))
		return

	var/confirm = alert(src, "Are you sure you want to call the shuttle?", "Confirm Shuttle Call", "Yes", "No")

	if(check_unable(AI_CHECK_WIRELESS))
		return

	if(confirm == "Yes")
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

	var/confirm = alert("Are you sure you want to recall the shuttle?", "Confirm Shuttle Recall", "Yes", "No")
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
	if(!blinded)
		flash_eyes()

	switch(severity)
		if(1.0)
			if (stat != DEAD)
				adjustBruteLoss(100)
				adjustFireLoss(100)
		if(2.0)
			if (stat != DEAD)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if (stat != DEAD)
				adjustBruteLoss(30)

	updatehealth()


/mob/living/silicon/ai/Topic(href, href_list)
	if(usr != src)
		return
	..()
	if (href_list["mach_close"])
		if (href_list["mach_close"] == "aialerts")
			viewalerts = 0
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)
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
		var/setchannel = input(usr, "Specify channel.", "Channel selection") in list("State","Common","Science","Command","Medical","Engineering","Security","Supply","Binary","Holopad", "Cancel")
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
		if(target || html_decode(href_list["trackname"]) == target:get_visible_name())
			ai_actual_track(target)
		else
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

	return

/mob/living/silicon/ai/bullet_act(obj/item/projectile/Proj)
	. = ..()
	if(. == PROJECTILE_ABSORBED || . == PROJECTILE_FORCE_MISS)
		return

	updatehealth()

/mob/living/silicon/ai/reset_view(atom/A)
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

	if(viewalerts)
		show_alerts()

/mob/living/silicon/ai/cancelAlarm(class, area/A, source)
	var/has_alarm = ..()

	if (!has_alarm)
		queueAlarm(text("--- [] alarm in [] has been cleared.", class, A.name), class, 0)
		if(viewalerts)
			show_alerts()

	return has_alarm

/mob/living/silicon/ai/cancel_camera()
	set category = "AI Commands"
	set name = "Cancel Camera View"

	//src.cameraFollow = null
	src.view_core()


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
	network = input(U, "Which network would you like to view?") as null|anything in cameralist

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

	var/list/ai_emotions = list("Very Happy", "Happy", "Neutral", "Unsure", "Confused", "Sad", "BSOD", "Blank", "Problems?", "Awesome", "Facepalm", "Friend Computer", "HAL")
	var/emote = input("Please, select a status!", "AI Status", null, null) in ai_emotions
	for (var/obj/machinery/M in machines) //change status
		if(istype(M, /obj/machinery/ai_status_display))
			var/obj/machinery/ai_status_display/AISD = M
			AISD.emotion = emote
		//if Friend Computer, change ALL displays
		else if(istype(M, /obj/machinery/status_display))

			var/obj/machinery/status_display/SD = M
			if(emote=="Friend Computer")
				SD.friendc = 1
			else
				SD.friendc = 0
	return

//I am the icon meister. Bow fefore me.	//>fefore
/mob/living/silicon/ai/proc/ai_hologram_change()
	set name = "Change Hologram"
	set desc = "Change the default hologram available to AI to something else."
	set category = "AI Commands"

	if(check_unable())
		return

	var/input
	if(alert("Would you like to select a hologram based on a crew member or switch to unique avatar?",,"Crew Member","Unique")=="Crew Member")

		var/personnel_list[] = list()

		for(var/datum/data/record/t in data_core.locked)//Look in data core locked.
			personnel_list["[t.fields["name"]]: [t.fields["rank"]]"] = t.fields["image"]//Pull names, rank, and image.

		if(personnel_list.len)
			input = input("Select a crew member:") as null|anything in personnel_list
			var/icon/character_icon = personnel_list[input]
			if(character_icon)
				qdel(holo_icon)//Clear old icon so we're not storing it in memory.
				holo_icon = getHologramIcon(icon(character_icon))
		else
			alert("No suitable records found. Aborting.")

	else
		var/icon_list[] = list(
		"default",
		"floating face",
		"alien",
		"carp",
		"queen",
		"rommie",
		"sonny",
		"miku",
		"medbot"
		)
		input = input("Please select a hologram:") as null|anything in icon_list
		if(input)
			qdel(holo_icon)
			switch(input)
				if("default")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo1"))
				if("floating face")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo2"))
				if("alien")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo3"))
				if("carp")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo4"))
				if("queen")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo5"))
				if("rommie")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo6"))
				if("sonny")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo7"))
				if("miku")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo8"))
				if("medbot")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo9"))
	return

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
				src.camera.set_light(0)
				if(!camera.light_disabled)
					src.camera = camera
					src.camera.set_light(AI_CAMERA_LUMINOSITY)
				else
					src.camera = null
			else if(isnull(camera))
				src.camera.set_light(0)
				src.camera = null
		else
			var/obj/machinery/camera/camera = near_range_camera(src.eyeobj)
			if(camera && !camera.light_disabled)
				src.camera = camera
				src.camera.set_light(AI_CAMERA_LUMINOSITY)
		camera_light_on = world.timeofday + 1 * 20 // Update the light every 2 seconds.


/mob/living/silicon/ai/attackby(obj/item/weapon/W, mob/user)
	if(iswrench(W))
		if(user.is_busy()) return
		if(anchored)
			user.visible_message("<span class='notice'>\The [user] starts to unbolt \the [src] from the plating...</span>")
			if(!W.use_tool(src, user, 40, volume = 50))
				user.visible_message("<span class='notice'>\The [user] decides not to unbolt \the [src].</span>")
				return
			user.visible_message("<span class='notice'>\The [user] finishes unfastening \the [src]!</span>")
			anchored = 0
			return
		else
			user.visible_message("<span class='notice'>\The [user] starts to bolt \the [src] to the plating...</span>")
			if(!W.use_tool(src, user, 40, volume = 50))
				user.visible_message("<span class='notice'>\The [user] decides not to bolt \the [src].</span>")
				return
			user.visible_message("<span class='notice'>\The [user] finishes fastening down \the [src]!</span>")
			anchored = 1
			return
	else
		return ..()

/mob/living/silicon/ai/proc/control_integrated_radio()

	if(check_unable(AI_CHECK_RADIO))
		return

	to_chat(src, "Accessing Subspace Transceiver control...")
	if (src.aiRadio)
		src.aiRadio.interact(src)

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
