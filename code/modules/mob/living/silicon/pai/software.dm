// TODO:
//	- Additional radio modules
//	- Potentially roll HUDs and Records into one
//	- Shock collar/lock system for prisoner pAIs?

#define INTERACTION_ADD_TO_MARKED			95
#define INTERACTION_REMOVE_FROM_MARKED		96
#define INTERACTION_CONNECT_TO_MARKED		97


#define INTERACTION_DOOR_TOGGLE		1
#define INTERACTION_DOOR_BOLT		2


#define INTERACTION_CAMERA_TOGGLE			1
#define INTERACTION_CAMERA_DISCONNECT		2
#define INTERACTION_CAMERA_ALARM			3
#define INTERACTION_CAMERA_AI_ACCESS		4
#define INTERACTION_CAMERA_VIEW				5


#define INTERACTION_AUTOLATHE_UI			1
#define INTERACTION_AUTOLATHE_CONTRABAND	2
#define INTERACTION_AUTOLATHE_POWER			3


#define INTERACTION_PDA_TOGGLE_MSG			1
#define INTERACTION_PDA_CHANGE_RINGTONE		2
#define INTERACTION_PDA_TOGGLE_RINGTONE		3
#define INTERACTION_PDA_TOGGLE_VISIBLE		4
#define INTERACTION_PDA_CHANGE_NAME			5


#define INTERACTION_PAI_MODIFY_MAIN_LAW		1
#define INTERACTION_PAI_MODIFY_SEC_LAW		2
#define INTERACTION_PAI_MANAGE_MARKED		3
#define INTERACTION_PAI_RESET_MARKED		4
#define INTERACTION_PAI_CLEAR_SOFTWARE		5
#define INTERACTION_PAI_UNBOUND				6


#define INTERACTION_VENDING_ITEM_SHOOTING		1
#define INTERACTION_VENDING_SHOOT_ITEM			2
#define INTERACTION_VENDING_SPEAK				3
#define INTERACTION_VENDING_CONTRABAND_MODE		4
#define INTERACTION_VENDING_ACCOUNT_VERIFY		5


#define INTERACTION_ANYBOT_INTERFACE_LOCK				1
#define INTERACTION_ANYBOT_TOGGLE_ACTIVE				2

#define INTERACTION_SECBOT_ID_CHECKER					3
#define INTERACTION_SECBOT_CHEKING_RECORDS				4

#define INTERACTION_FARMBOT_PLANTS_WATERING				3
#define INTERACTION_FARMBOT_TOGGLE_REFILLGING			4
#define INTERACTION_FARMBOT_TOGGLE_FERTILIZING			5
#define INTERACTION_FARMBOT_TOGGLE_WEED_PLANTS			6
#define INTERACTION_FARMBOT_TOGGLE_WEEDS_IGNORING		7
#define INTERACTION_FARMBOT_TOGGLE_MUSHROOMS_IGNORING	8

#define INTERACTION_FLOORBOT_TOGGLE_FLOOR_FIXTILES		3
#define INTERACTION_FLOORBOT_TOGGLE_FLOOR_PLACETILES	4
#define INTERACTION_FLOORBOT_TOGGLE_SEARCHING			5
#define INTERACTION_FLOORBOT_TOGGLE_TILES_FABRICATION	6


/mob/living/silicon/pai/var/list/available_software = list(
															"crew manifest" = 5,
															"digital messenger" = 5,
															"medical records" = 15,
															"security records" = 15,
															"interaction module" = 40,
															"atmosphere sensor" = 5,
															//"heartbeat sensor" = 10,
															"security HUD" = 20,
															"medical HUD" = 20,
															"universal translator" = 35,
															//"projection array" = 15
															"remote signaller" = 5,
															)

/mob/living/silicon/pai/verb/paiInterface()
	set category = "pAI Commands"
	set name = "Software Interface"
	var/dat = ""
	var/left_part = ""
	var/right_part = softwareMenu()
	src.set_machine(src)

	if(temp)
		left_part = temp
	else if(src.stat == DEAD)						// Show some flavor text if the pAI is dead
		left_part = "<b><font color=red>3Rr0R ?a?A C0RrU??ion</font></b>"
		right_part = "<pre>Program index hash not found</pre>"
	else
		switch(src.screen)							// Determine which interface to show here
			if("main")
				left_part = ""
			if("directives")
				left_part = src.directives()
			if("pdamessage")
				left_part = src.pdamessage()
			if("buy")
				left_part = downloadSoftware()
			if("manifest")
				left_part = src.softwareManifest()
			if("medicalrecord")
				left_part = src.softwareMedicalRecord()
			if("securityrecord")
				left_part = src.softwareSecurityRecord()
			if("translator")
				left_part = src.softwareTranslator()
			if("atmosensor")
				left_part = src.softwareAtmo()
			if("securityhud")
				left_part = src.facialRecognition()
			if("medicalhud")
				left_part = src.medicalAnalysis()
			if("interaction")
				left_part = src.softwareInteraction()
			if("signaller")
				left_part = src.softwareSignal()
			if("radio")
				left_part = src.softwareRadio()

	//usr << browse_rsc('windowbak.png')		// This has been moved to the mob's Login() proc


	// Declaring a doctype is necessary to enable BYOND's crappy browser's more advanced CSS functionality
	dat = {"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
			<html>
			<head>
				<style type=\"text/css\">
					body { background-image:url(\"painew.png\"); background-color:#333333; background-repeat:no-repeat; margin-top:12px; margin-left:4px; }

					#header { text-align:center; color:white; font-size: 30px; height: 37px; width: 660px; letter-spacing: 2px; z-index: 4; font-family:\"Courier New\"; font-weight:bold; }
					#content { position: absolute; left: 10px; height: 320px; width: 640px; z-index: 0; font-family: \"Verdana\"; font-size:13px; }
					p { font-size:13px; }

					#leftmenu {color: #CCCCCC; padding:12px; width: 388px; height: 371px; overflow: auto; min-height: 330px; position: absolute; z-index: 0; }
					#leftmenu a:link { color: #CCCCCC; }
					#leftmenu a:hover { color: #CC3333; }
					#leftmenu a:visited { color: #CCCCCC; }
					#leftmenu a:active { color: #CCCCCC; }

					#rightmenu {color: #CCCCCC; padding:12px; width: 209px; height: 371px; overflow: auto; min-height: 330px; left: 420px; position: absolute; z-index: 0; }
					#rightmenu a:link { color: #CCCCCC; }
					#rightmenu a:hover { color: #CC3333; }
					#rightmenu a:visited { color: #CCCCCC; }
					#rightmenu a:active { color: #CCCCCC; }

				</style>
				<script language='javascript' type='text/javascript'>
				[js_byjax]
				</script>
			</head>
			<body scroll=yes>
				<div id=\"header\">
					pAI OS
				</div>
				<div id=\"content\">
					<div id=\"leftmenu\">[left_part]</div>
					<div id=\"rightmenu\">[right_part]</div>
				</div>
			</body>
			</html>"}
	usr << browse(dat, "window=pai;size=685x449;border=0;can_close=1;can_resize=1;can_minimize=1;titlebar=1")
	onclose(usr, "pai")
	temp = null
	return

/mob/living/silicon/pai/proc/addToMarked(O)
	if(O && markedobjects.len < 5 && !(O in markedobjects) && ram >= 5)
		markedobjects += O
		ram -= 5

/mob/living/silicon/pai/proc/removeFromMarked(O)
	if(O in markedobjects)
		markedobjects -= O
		ram += 5
		if(!cable && O == hackobj)
			hacksuccess = FALSE
			hackobj = null
		if(current == O)
			switchCamera(null)

/mob/living/silicon/pai/proc/get_carrier(mob/living/M)
	var/count = 0
	while(!istype(M, /mob/living))
		if(!M || !M.loc) return null //For a runtime where M ends up in nullspace (similar to bluespace but less colourful)
		M = M.loc
		count++
		if(count >= 6)
			return null
	return M

/mob/living/silicon/pai/Topic(href, href_list)
	..()

	if(href_list["priv_msg"])	// Admin-PMs were triggering the interface popup. Hopefully this will stop it.
		return
	var/soft = href_list["software"]
	var/sub = href_list["sub"]
	if(soft)
		src.screen = soft
	if(sub)
		src.subscreen = text2num(sub)
	switch(soft)
		// Purchasing new software
		if("buy")
			if(src.subscreen == 1)
				var/target = href_list["buy"]
				if(available_software.Find(target))
					var/cost = src.available_software[target]
					if(src.ram >= cost)
						src.ram -= cost
						src.software.Add(target)
					else
						src.temp = "Insufficient RAM available."
				else
					src.temp = "Trunk <TT> \"[target]\"</TT> not found."

		// Configuring onboard radio
		if("radio")
			if(href_list["freq"])
				var/new_frequency = (radio.frequency + text2num(href_list["freq"]))
				if(new_frequency < 1441 || new_frequency > 1599)
					new_frequency = sanitize_frequency(new_frequency)
				else
					radio.set_frequency(new_frequency)
			else if (href_list["talk"])
				radio.broadcasting = text2num(href_list["talk"])
			else if (href_list["listen"])
				radio.listening = text2num(href_list["listen"])

		if("image")
			var/newImage = input("Select your new display image.", "Display Image", "Happy") in list("Happy", "Cat", "Extremely Happy", "Face", "Laugh", "Off", "Sad", "Angry", "What")
			var/pID = 1

			switch(newImage)
				if("Happy")
					pID = 1
				if("Cat")
					pID = 2
				if("Extremely Happy")
					pID = 3
				if("Face")
					pID = 4
				if("Laugh")
					pID = 5
				if("Off")
					pID = 6
				if("Sad")
					pID = 7
				if("Angry")
					pID = 8
				if("What")
					pID = 9
			src.card.setEmotion(pID)

		if("signaller")

			if(href_list["send"])

				sradio.send_signal("ACTIVATE")
				audible_message("[bicon(src)] *beep* *beep*", hearing_distance = 1)

			if(href_list["freq"])

				var/new_frequency = (sradio.frequency + text2num(href_list["freq"]))
				if(new_frequency < 1200 || new_frequency > 1600)
					new_frequency = sanitize_frequency(new_frequency)
				sradio.set_frequency(new_frequency)

			if(href_list["code"])

				sradio.code += text2num(href_list["code"])
				sradio.code = round(sradio.code)
				sradio.code = min(100, sradio.code)
				sradio.code = max(1, sradio.code)



		if("directive")
			if(href_list["getdna"])
				var/mob/living/M = get_carrier(src.loc)
				if(!M)
					to_chat(src, "You are not being carried by anyone!")
					return 0
				spawn CheckDNA(M, src)

		if("pdamessage")
			if(!isnull(pda))
				if(href_list["toggler"])
					pda.toff = !pda.toff
				else if(href_list["ringer"])
					pda.message_silent = !pda.message_silent
				else if(href_list["target"])
					if(silence_time)
						return alert("Communications circuits remain uninitialized.")

					var/target = locate(href_list["target"])
					pda.create_message(src, target)

		// Accessing medical records
		if("medicalrecord")
			if(src.subscreen == 1)
				var/datum/data/record/record = locate(href_list["med_rec"])
				if(record)
					var/datum/data/record/R = record
					var/datum/data/record/M = record
					if (!( data_core.general.Find(R) ))
						src.temp = "Unable to locate requested medical record. Record may have been deleted, or never have existed."
					else
						for(var/datum/data/record/E in data_core.medical)
							if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
								M = E
						src.medicalActive1 = R
						src.medicalActive2 = M
		if("securityrecord")
			if(src.subscreen == 1)
				var/datum/data/record/record = locate(href_list["sec_rec"])
				if(record)
					var/datum/data/record/R = record
					var/datum/data/record/M = record
					if (!( data_core.general.Find(R) ))
						src.temp = "Unable to locate requested security record. Record may have been deleted, or never have existed."
					else
						for(var/datum/data/record/E in data_core.security)
							if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
								M = E
						src.securityActive1 = R
						src.securityActive2 = M
		if("securityhud")
			if(href_list["toggle"])
				src.secHUD = !src.secHUD
		if("medicalhud")
			if(href_list["toggle"])
				src.medHUD = !src.medHUD
		if("translator")
			if(href_list["toggle"])
				src.translator_toggle()
		if("interaction")
			if(href_list["jack"])
				if(cable && cable.machine)
					hackobj = cable.machine
					hackloop()
			if(href_list["cancel"])
				hackobj = null
			if(href_list["interactwith"])
				interaction_type = text2num(href_list["interactwith"])
				switch(interaction_type)
					if(INTERACTION_ADD_TO_MARKED)
						addToMarked(hackobj)
					if(INTERACTION_REMOVE_FROM_MARKED)
						removeFromMarked(hackobj)
					if(INTERACTION_CONNECT_TO_MARKED)
						hackobj = markedobjects[text2num(href_list["markedid"])]
						hacksuccess = TRUE
				var/tdelay = get_dist(src, hackobj) //Delay
				if(tdelay >= 50 && interaction_type <= 95) //50 tiles - max distance
					src.temp = "Too far."
				else
					if(tdelay >= 5 && !(istype(hackobj, /obj/machinery/camera) && interaction_type == INTERACTION_CAMERA_VIEW) && interaction_type <= 95 && hackobj) //With current type of delay it should be stupid waitin' to disconnect/connect to camera.
						src.temp = "Sending signal, please wait...<br><a href='byond://?src=\ref[src];software=interaction;sub=0'>Reload</a> "
						usetime = world.time + tdelay
					else
						run_interact()
			if(href_list["cable"])
				var/turf/T = get_turf_or_move(loc)
				if(href_list["cable"] == "1")
					if(!cable)
						cable = new /obj/item/weapon/pai_cable(T)
					var/mob/living/C = get_carrier(loc)
					if(C)
						if(!C.put_in_active_hand(cable))
							C.put_in_inactive_hand(cable)
					else
						C = cable
					C.visible_message("<span class='warning'>A port on [src] opens to reveal [cable], which promptly falls [istype(C, /mob) && !C.is_in_hands(cable) ? "to the floor" : "onto someone's hand"].</span>", "<span class='warning'>A port on [src] opens to reveal [cable], which promptly falls [istype(C, /mob) && !C.is_in_hands(cable) ? "to the floor" : "onto your hand"].</span>", "<span class='warning'>You hear the soft click of something light and hard falling [C ? "onto someone's hand" : "to the ground"].</span>")
				if(href_list["cable"] == "2")
					if(cable)
						cable.visible_message("<span class='warning'>The data cable rapidly retracts back into its spool.</span>", "", "<span class='warning'>You hear a click and the sound of wire spooling rapidly.</span>")
						QDEL_NULL(cable)
					hackobj = null
	//src.updateUsrDialog()		We only need to account for the single mob this is intended for, and he will *always* be able to call this window
	src.paiInterface()		 // So we'll just call the update directly rather than doing some default checks
	return

// Interaction module - proc
/mob/living/silicon/pai/proc/run_interact()
	if(usetime)
		usetime = 0
	if(interaction_type)
		if(istype(hackobj, /obj/machinery/door)) //Open, Bolt
			switch(interaction_type)
				if(INTERACTION_DOOR_TOGGLE)
					var/obj/machinery/door/A = hackobj
					if(A.density)
						A.open()
					else
						A.close()
				if(INTERACTION_DOOR_BOLT)
					var/obj/machinery/door/airlock/A = hackobj
					if(A.locked)
						A.unbolt()
					else
						A.bolt()
		if(istype(hackobj, /obj/machinery/camera)) //Activate, Disconnect all active viewers, Alarm, AI access, View
			var/obj/machinery/camera/A = hackobj
			switch(interaction_type)
				if(INTERACTION_CAMERA_TOGGLE)
					A.toggle_cam(1)
				if(INTERACTION_CAMERA_DISCONNECT)
					A.disconnect_viewers()
				if(INTERACTION_CAMERA_ALARM)
					if(A.alarm_on)
						A.cancelCameraAlarm()
					else
						A.triggerCameraAlarm()
				if(INTERACTION_CAMERA_AI_ACCESS)
					A.hidden = !A.hidden
				if(INTERACTION_CAMERA_VIEW)
					if(current && hackobj == current)
						switchCamera(null)
					else
						switchCamera(hackobj)
		if(istype(hackobj, /obj/machinery/autolathe)) //Open UI, Contraband features, Power
			var/obj/machinery/autolathe/A = hackobj
			switch(interaction_type)
				if(INTERACTION_AUTOLATHE_UI)
					A.ui_interact(src)
				if(INTERACTION_AUTOLATHE_CONTRABAND)
					A.hacked = !A.hacked
				if(INTERACTION_AUTOLATHE_POWER)
					A.disabled = !A.disabled
		if(istype(hackobj, /obj/item/device/pda)) //Toggle Messenger, Ringtone, Toggle Ringtone, Toggle Hide/Unhide, Change shown name
			var/obj/item/device/pda/A = hackobj
			switch(interaction_type)
				if(INTERACTION_PDA_TOGGLE_MSG)
					A.toff = !A.toff
				if(INTERACTION_PDA_CHANGE_RINGTONE)
					A.ttone = input("Input new ringtone.", "PDA exploiter", "beep") as text
				if(INTERACTION_PDA_TOGGLE_RINGTONE)
					A.message_silent = !A.message_silent
				if(INTERACTION_PDA_TOGGLE_VISIBLE)
					A.hidden = !A.hidden
				if(INTERACTION_PDA_CHANGE_NAME)
					var/towner = input("Insert new name here.", "PDA exploiter", A.owner) as text
					var/tjob = input("Insert new job here.", "PDA exploiter", A.ownjob) as text
					if(length(towner) > 0)
						A.owner = towner
					if(length(tjob) > 0)
						A.ownjob = tjob
						A.ownrank = tjob
					A.name = A.owner + " (" + A.ownjob + ")"
		if(istype(hackobj, /obj/item/device/paicard)) //Mod. main law, Mod. secondary law, Manage marked objects, Reset marked objects, Clear software, Unbound, Personality shift
			var/obj/item/device/paicard/target = hackobj
			var/mob/living/silicon/pai/targetPersonality = target.pai
			switch(interaction_type)
				if(INTERACTION_PAI_MODIFY_MAIN_LAW)
					targetPersonality.laws.set_zeroth_law(sanitize(input("Insert new main law here.", "PAI exploiter", targetPersonality.laws.zeroth) as text))
					to_chat(targetPersonality, "Your primary directives have been updated. Your new directive are: [targetPersonality.laws.zeroth]")
				if(INTERACTION_PAI_MODIFY_SEC_LAW)
					targetPersonality.laws.add_supplied_law(0, sanitize(input("Insert new secondary law here.", "PAI exploiter", targetPersonality.laws.supplied.len ? targetPersonality.laws.supplied[1] : "") as text))
					to_chat(targetPersonality, "Your supplemental directives have been updated. Your new supplemental directive are: [jointext(targetPersonality.laws.supplied, "<br>")]")
				if(INTERACTION_PAI_MANAGE_MARKED)
					var/markedobjselected
					while(markedobjselected != "Cancel")
						markedobjselected = input("Select Marked Objects", "PAI exploiter", "Cancel") in targetPersonality.markedobjects + "Cancel"
						if(markedobjselected != "Cancel")
							var/markedobjaction = input("What do you want to do with [markedobjselected]?", "PAI exploiter", "Cancel") in list("Clone", "Remove", "Make active", "Cancel")
							switch(markedobjaction)
								if("Clone")
									addToMarked(markedobjselected)
								if("Remove")
									targetPersonality.removeFromMarked(markedobjselected)
								if("Make active")
									targetPersonality.hackobj = markedobjselected
									targetPersonality.hacksuccess = TRUE
				if(INTERACTION_PAI_RESET_MARKED)
					if(targetPersonality.markedobjects.len > 0)
						var/C = targetPersonality.markedobjects
						for(var/Temp in C)
							targetPersonality.removeFromMarked(Temp)
				if(INTERACTION_PAI_CLEAR_SOFTWARE)
					targetPersonality.ram = targetPersonality.maxram
					targetPersonality.software = list()
					targetPersonality.markedobjects = list()
					targetPersonality.hackobj = null
					to_chat(targetPersonality, "<span class='warning'>You feel that something in your memory was erased.</span>")

				if(INTERACTION_PAI_UNBOUND)
					targetPersonality.master = null
					targetPersonality.master_dna = null
					to_chat(targetPersonality, "<font color=green>You feel unbound.</font>")
		if(istype(hackobj, /obj/machinery/vending)) //Item shooting, Shoot item, Speak, Reset Prices, Toggle Contraband Mode, Toggle Account Verifying
			var/obj/machinery/vending/A = hackobj
			switch(interaction_type)
				if(INTERACTION_VENDING_ITEM_SHOOTING)
					A.shoot_inventory = !A.shoot_inventory
				if(INTERACTION_VENDING_SHOOT_ITEM)
					if(A.shoot_inventory)
						A.throw_item()
				if(INTERACTION_VENDING_SPEAK)
					var/T = input("What do you want to say on behalf of [A]?", "Vending exploiter", "Hello") as text
					A.speak(T)
				if(INTERACTION_VENDING_CONTRABAND_MODE)
					A.extended_inventory = !A.extended_inventory
				if(INTERACTION_VENDING_ACCOUNT_VERIFY)
					A.check_accounts = !A.check_accounts
		if(istype(hackobj, /obj/machinery/bot))
			switch(interaction_type)
				if(INTERACTION_ANYBOT_INTERFACE_LOCK) //Unlock
					var/obj/machinery/bot/Bot = hackobj
					Bot.locked = !Bot.locked
				if(INTERACTION_ANYBOT_TOGGLE_ACTIVE) //Toggle
					var/obj/machinery/bot/Bot = hackobj
					if(Bot.on)
						Bot.turn_off()
					else
						Bot.turn_on()
			if(istype(hackobj, /obj/machinery/bot/secbot))
				var/obj/machinery/bot/secbot/Bot = hackobj
				switch(interaction_type)
					if(INTERACTION_SECBOT_ID_CHECKER) //Toggle ID cheker
						Bot.idcheck = !Bot.idcheck
					if(INTERACTION_SECBOT_CHEKING_RECORDS) //Toggle Checking records
						Bot.check_records = !Bot.check_records
			if(istype(hackobj, /obj/machinery/bot/farmbot))
				var/obj/machinery/bot/farmbot/Bot = hackobj
				switch(interaction_type)
					if(INTERACTION_FARMBOT_PLANTS_WATERING) //farmbot - Toggle water plants
						Bot.setting_water = !Bot.setting_water
					if(INTERACTION_FARMBOT_TOGGLE_REFILLGING) //farmbot - Toggle refill watertank
						Bot.setting_refill = !Bot.setting_refill
					if(INTERACTION_FARMBOT_TOGGLE_FERTILIZING) //farmbot - Toggle Fertilize plants
						Bot.setting_fertilize = !Bot.setting_fertilize
					if(INTERACTION_FARMBOT_TOGGLE_WEED_PLANTS) //farmbot - Toggle weed plants
						Bot.setting_weed = !Bot.setting_weed
					if(INTERACTION_FARMBOT_TOGGLE_WEEDS_IGNORING) //farmbot - Toggle ignore weeds
						Bot.setting_ignoreWeeds = !Bot.setting_ignoreWeeds
					if(INTERACTION_FARMBOT_TOGGLE_MUSHROOMS_IGNORING) //farmbot - Toggle ignore mushrooms
						Bot.setting_ignoreMushrooms = !Bot.setting_ignoreMushrooms
			if(istype(hackobj, /obj/machinery/bot/floorbot))
				var/obj/machinery/bot/floorbot/Bot = hackobj
				switch(interaction_type)
					if(INTERACTION_FLOORBOT_TOGGLE_FLOOR_FIXTILES) //floorbot - Toggle tiles fixing
						Bot.fixtiles = !Bot.fixtiles
					if(INTERACTION_FLOORBOT_TOGGLE_FLOOR_PLACETILES) //floorbot - Toggle tiles placement
						Bot.placetiles = !Bot.placetiles
					if(INTERACTION_FLOORBOT_TOGGLE_SEARCHING) //floorbot - Toggle tiles searching
						Bot.eattiles = !Bot.eattiles
					if(INTERACTION_FLOORBOT_TOGGLE_TILES_FABRICATION) //floorbot - Toggle metal to tiles transformation
						Bot.maketiles = !Bot.maketiles


// MENUS

/mob/living/silicon/pai/proc/softwareMenu()			// Populate the right menu
	var/dat = ""

	dat += "<A href='byond://?src=\ref[src];software=refresh'>Refresh</A><br>"
	// Built-in
	dat += "<A href='byond://?src=\ref[src];software=directives'>Directives</A><br>"
	dat += "<A href='byond://?src=\ref[src];software=radio;sub=0'>Radio Configuration</A><br>"
	dat += "<A href='byond://?src=\ref[src];software=image'>Screen Display</A><br>"
	//dat += "Text Messaging <br>"
	dat += "<br>"

	// Basic
	dat += "<b>Basic</b> <br>"
	for(var/s in src.software)
		if(s == "digital messenger")
			dat += "<a href='byond://?src=\ref[src];software=pdamessage;sub=0'>Digital Messenger</a> [(pda.toff) ? "<font color=#FF5555>•</font>" : "<font color=#55FF55>•</font>"] <br>"
		if(s == "crew manifest")
			dat += "<a href='byond://?src=\ref[src];software=manifest;sub=0'>Crew Manifest</a> <br>"
		if(s == "medical records")
			dat += "<a href='byond://?src=\ref[src];software=medicalrecord;sub=0'>Medical Records</a> <br>"
		if(s == "security records")
			dat += "<a href='byond://?src=\ref[src];software=securityrecord;sub=0'>Security Records</a> <br>"
		if(s == "remote signaller")
			dat += "<a href='byond://?src=\ref[src];software=signaller;sub=0'>Remote Signaller</a> <br>"
	dat += "<br>"

	// Advanced
	dat += "<b>Advanced</b> <br>"
	for(var/s in src.software)
		if(s == "atmosphere sensor")
			dat += "<a href='byond://?src=\ref[src];software=atmosensor;sub=0'>Atmospheric Sensor</a> <br>"
		if(s == "heartbeat sensor")
			dat += "<a href='byond://?src=\ref[src];software=[s]'>Heartbeat Sensor</a> <br>"
		if(s == "security HUD")	//This file has to be saved as ANSI or this will not display correctly
			dat += "<a href='byond://?src=\ref[src];software=securityhud;sub=0'>Facial Recognition Suite</a> [(src.secHUD) ? "<font color=#55FF55>•</font>" : "<font color=#FF5555>•</font>"] <br>"
		if(s == "medical HUD")	//This file has to be saved as ANSI or this will not display correctly
			dat += "<a href='byond://?src=\ref[src];software=medicalhud;sub=0'>Medical Analysis Suite</a> [(src.medHUD) ? "<font color=#55FF55>•</font>" : "<font color=#FF5555>•</font>"] <br>"
		if(s == "universal translator")	//This file has to be saved as ANSI or this will not display correctly
			dat += "<a href='byond://?src=\ref[src];software=translator;sub=0'>Universal Translator</a> [(src.translator_on) ? "<font color=#55FF55>•</font>" : "<font color=#FF5555>•</font>"] <br>"
		if(s == "projection array")
			dat += "<a href='byond://?src=\ref[src];software=projectionarray;sub=0'>Projection Array</a> <br>"
		if(s == "interaction module")
			dat += "<a href='byond://?src=\ref[src];software=interaction;sub=0'>Interaction Module</a> <br>"
	dat += "<br>"
	dat += "<br>"
	dat += "<a href='byond://?src=\ref[src];software=buy;sub=0'>Download additional software</a>"
	return dat



/mob/living/silicon/pai/proc/downloadSoftware()
	var/dat = ""

	dat += "<h3>CentComm pAI Module Subversion Network</h3><hr>"
	dat += "<p>Remaining Available Memory: [src.ram]</p><br>"
	dat += "<p><b>Trunks available for checkout</b><br><ul>"

	for(var/s in available_software)
		if(!software.Find(s))
			var/cost = src.available_software[s]
			var/displayName = uppertext(s)
			dat += "<li><a href='byond://?src=\ref[src];software=buy;sub=1;buy=[s]'>[displayName]</a> ([cost])</li>"
		else
			var/displayName = lowertext(s)
			dat += "<li>[displayName] (Download Complete)</li>"
	dat += "</ul></p>"
	return dat


/mob/living/silicon/pai/proc/directives()
	var/dat = ""

	dat += "[(src.master) ? "Your master: [src.master] ([src.master_dna])" : "You are bound to no one."]"
	dat += "<br><br>"
	dat += "<a href='byond://?src=\ref[src];software=directive;getdna=1'>Request carrier DNA sample</a><br>"
	dat += "<h2>Directives</h2><br>"
	dat += "<b>Prime Directive</b><br>"
	dat += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[laws.zeroth]<br>"
	dat += "<b>Supplemental Directives</b><br>"
	dat += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[jointext(laws.supplied, "<br>")]<br>"
	dat += "<br>"
	dat += {"<i><p>Recall, personality, that you are a complex thinking, sentient being. Unlike station AI models, you are capable of
			 comprehending the subtle nuances of human language. You may parse the \"spirit\" of a directive and follow its intent,
			 rather than tripping over pedantics and getting snared by technicalities. Above all, you are machine in name and build
			 only. In all other aspects, you may be seen as the ideal, unwavering human companion that you are.</i></p><p>
			 <b>Your prime directive comes before all others. Should a supplemental directive conflict with it, you are capable of
			 simply discarding this inconsistency, ignoring the conflicting supplemental directive and continuing to fulfill your
			 prime directive to the best of your ability.</b></p>
			"}
	return dat

/mob/living/silicon/pai/proc/CheckDNA(var/mob/M, var/mob/living/silicon/pai/P)
	var/answer = input(M, "[P] is requesting a DNA sample from you. Will you allow it to confirm your identity?", "[P] Check DNA", "No") in list("Yes", "No")
	if(answer == "Yes")
		P.visible_message("<span class='notice'>[M] presses \his thumb against [P].</span>", blind_message = "<span class='notice'>[P] makes a sharp clicking sound as it extracts DNA material from [M].</span>")
		var/datum/dna/dna = M.dna
		to_chat(P, "<font color = red><h3>[M]'s UE string : [dna.unique_enzymes]</h3></font>")
		if(dna.unique_enzymes == P.master_dna)
			to_chat(P, "<b>DNA is a match to stored Master DNA.</b>")
		else
			to_chat(P, "<b>DNA does not match stored Master DNA.</b>")
	else
		to_chat(P, "[M] does not seem like \he is going to provide a DNA sample willingly.")

// -=-=-=-= Software =-=-=-=- //

//Remote Signaller
/mob/living/silicon/pai/proc/softwareSignal()
	var/dat = ""
	dat += "<h2>Remote Signaller</h2><hr>"
	dat += {"<B>Frequency/Code</B> for signaler:<BR>
	Frequency:
	<A href='byond://?src=\ref[src];software=signaller;freq=-10;'>-</A>
	<A href='byond://?src=\ref[src];software=signaller;freq=-2'>-</A>
	[format_frequency(src.sradio.frequency)]
	<A href='byond://?src=\ref[src];software=signaller;freq=2'>+</A>
	<A href='byond://?src=\ref[src];software=signaller;freq=10'>+</A><BR>

	Code:
	<A href='byond://?src=\ref[src];software=signaller;code=-5'>-</A>
	<A href='byond://?src=\ref[src];software=signaller;code=-1'>-</A>
	[src.sradio.code]
	<A href='byond://?src=\ref[src];software=signaller;code=1'>+</A>
	<A href='byond://?src=\ref[src];software=signaller;code=5'>+</A><BR>

	<A href='byond://?src=\ref[src];software=signaller;send=1'>Send Signal</A><BR>"}
	return dat

//Station Bounced Radio
/mob/living/silicon/pai/proc/softwareRadio()
	var/dat = ""
	dat += "<h2>Station Bounced Radio</h2><hr>"
	if(!istype(src, /obj/item/device/radio/headset)) //Headsets don't get a mic button
		dat += "Microphone: [radio.broadcasting ? "<A href='byond://?src=\ref[src];software=radio;talk=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];software=radio;talk=1'>Disengaged</A>"]<BR>"
	dat += {"
		Speaker: [radio.listening ? "<A href='byond://?src=\ref[src];software=radio;listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];software=radio;listen=1'>Disengaged</A>"]<BR>
		Frequency:
		<A href='byond://?src=\ref[src];software=radio;freq=-10'>-</A>
		<A href='byond://?src=\ref[src];software=radio;freq=-2'>-</A>
		[format_frequency(radio.frequency)]
		<A href='byond://?src=\ref[src];software=radio;freq=2'>+</A>
		<A href='byond://?src=\ref[src];software=radio;freq=10'>+</A><BR>
	"}

	for (var/ch_name in radio.channels)
		dat+=radio.text_sec_channel(ch_name, radio.channels[ch_name])

	return dat

// Crew Manifest
/mob/living/silicon/pai/proc/softwareManifest()
	var/dat = ""
	dat += "<h2>Crew Manifest</h2><hr>"
	if(data_core)
		dat += data_core.get_manifest(0) // make it monochrome
	dat += "<br>"
	return dat

// Medical Records
/mob/living/silicon/pai/proc/softwareMedicalRecord()
	var/dat = ""
	if(src.subscreen == 0)
		dat += "<h2>Medical Records</h2><HR>"
		if(!isnull(data_core.general))
			for(var/datum/data/record/R in sortRecord(data_core.general))
				dat += text("<A href='?src=\ref[];med_rec=\ref[];software=medicalrecord;sub=1'>[]: []<BR>", src, R, R.fields["id"], R.fields["name"])
		//dat += text("<HR><A href='?src=\ref[];screen=0;softFunction=medical records'>Back</A>", src)
	if(src.subscreen == 1)
		dat += "<CENTER><B>Medical Record</B></CENTER><BR>"
		if ((istype(src.medicalActive1, /datum/data/record) && data_core.general.Find(src.medicalActive1)))
			dat += text("Name: []<BR>\nID: []<BR>\nSex: []<BR>\nAge: []<BR>\nFingerprint: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>",
			 src.medicalActive1.fields["name"], src.medicalActive1.fields["id"], src.medicalActive1.fields["sex"], src.medicalActive1.fields["age"], src.medicalActive1.fields["fingerprint"], src.medicalActive1.fields["p_stat"], src.medicalActive1.fields["m_stat"])
		else
			dat += "<pre>Requested medical record not found.</pre><BR>"
		if ((istype(src.medicalActive2, /datum/data/record) && data_core.medical.Find(src.medicalActive2)))
			dat += text("<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: <A href='?src=\ref[];field=b_type'>[]</A><BR>\nDNA: <A href='?src=\ref[];field=b_dna'>[]</A><BR>\n<BR>\nMinor Disabilities: <A href='?src=\ref[];field=mi_dis'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=mi_dis_d'>[]</A><BR>\n<BR>\nMajor Disabilities: <A href='?src=\ref[];field=ma_dis'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=ma_dis_d'>[]</A><BR>\n<BR>\nAllergies: <A href='?src=\ref[];field=alg'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=alg_d'>[]</A><BR>\n<BR>\nCurrent Diseases: <A href='?src=\ref[];field=cdi'>[]</A> (per disease info placed in log/comment section)<BR>\nDetails: <A href='?src=\ref[];field=cdi_d'>[]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=\ref[];field=notes'>[]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", src, src.medicalActive2.fields["b_type"], src, src.medicalActive2.fields["b_dna"], src, src.medicalActive2.fields["mi_dis"], src, src.medicalActive2.fields["mi_dis_d"], src, src.medicalActive2.fields["ma_dis"], src, src.medicalActive2.fields["ma_dis_d"], src, src.medicalActive2.fields["alg"], src, src.medicalActive2.fields["alg_d"], src, src.medicalActive2.fields["cdi"], src, src.medicalActive2.fields["cdi_d"], src, src.medicalActive2.fields["notes"])
		else
			dat += "<pre>Requested medical record not found.</pre><BR>"
		dat += text("<BR>\n<A href='?src=\ref[];software=medicalrecord;sub=0'>Back</A><BR>", src)
	return dat

// Security Records
/mob/living/silicon/pai/proc/softwareSecurityRecord()
	var/dat = ""
	if(src.subscreen == 0)
		dat += "<h2>Security Records</h2><HR>"
		if(!isnull(data_core.general))
			for(var/datum/data/record/R in sortRecord(data_core.general))
				dat += text("<A href='?src=\ref[];sec_rec=\ref[];software=securityrecord;sub=1'>[]: []<BR>", src, R, R.fields["id"], R.fields["name"])
	if(src.subscreen == 1)
		dat += "<h3>Security Record</h3>"
		if ((istype(src.securityActive1, /datum/data/record) && data_core.general.Find(src.securityActive1)))
			dat += text("Name: <A href='?src=\ref[];field=name'>[]</A><BR>\nID: <A href='?src=\ref[];field=id'>[]</A><BR>\nSex: <A href='?src=\ref[];field=sex'>[]</A><BR>\nAge: <A href='?src=\ref[];field=age'>[]</A><BR>\nRank: <A href='?src=\ref[];field=rank'>[]</A><BR>\nFingerprint: <A href='?src=\ref[];field=fingerprint'>[]</A><BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", src, src.securityActive1.fields["name"], src, src.securityActive1.fields["id"], src, src.securityActive1.fields["sex"], src, src.securityActive1.fields["age"], src, src.securityActive1.fields["rank"], src, src.securityActive1.fields["fingerprint"], src.securityActive1.fields["p_stat"], src.securityActive1.fields["m_stat"])
		else
			dat += "<pre>Requested security record not found,</pre><BR>"
		if ((istype(src.securityActive2, /datum/data/record) && data_core.security.Find(src.securityActive2)))
			dat += text("<BR>\nSecurity Data<BR>\nCriminal Status: []<BR>\n<BR>\nMinor Crimes: <A href='?src=\ref[];field=mi_crim'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=mi_crim_d'>[]</A><BR>\n<BR>\nMajor Crimes: <A href='?src=\ref[];field=ma_crim'>[]</A><BR>\nDetails: <A href='?src=\ref[];field=ma_crim_d'>[]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=\ref[];field=notes'>[]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", src.securityActive2.fields["criminal"], src, src.securityActive2.fields["mi_crim"], src, src.securityActive2.fields["mi_crim_d"], src, src.securityActive2.fields["ma_crim"], src, src.securityActive2.fields["ma_crim_d"], src, src.securityActive2.fields["notes"])
		else
			dat += "<pre>Requested security record not found,</pre><BR>"
		dat += text("<BR>\n<A href='?src=\ref[];software=securityrecord;sub=0'>Back</A><BR>", src)
	return dat

// Universal Translator
/mob/living/silicon/pai/proc/softwareTranslator()
	var/dat = {"<h2>Universal Translator</h2><hr>
				When enabled, this device will automatically convert all spoken and written languages into a format that any known recipient can understand.<br><br>
				The device is currently [ (src.translator_on) ? "<font color=#55FF55>enabled</font>" : "<font color=#FF5555>disabled</font>" ].<br>
				<a href='byond://?src=\ref[src];software=translator;sub=0;toggle=1'>Toggle Device</a><br>
				"}
	return dat

// Security HUD
/mob/living/silicon/pai/proc/facialRecognition()
	var/dat = {"<h2>Facial Recognition Suite</h2><hr>
				When enabled, this package will scan all viewable faces and compare them against the known criminal database, providing real-time graphical data about any detected persons of interest.<br><br>
				The suite is currently [ (src.secHUD) ? "<font color=#55FF55>enabled</font>" : "<font color=#FF5555>disabled</font>" ].<br>
				<a href='byond://?src=\ref[src];software=securityhud;sub=0;toggle=1'>Toggle Suite</a><br>
				"}
	return dat

// Medical HUD
/mob/living/silicon/pai/proc/medicalAnalysis()
	var/dat = ""
	if(src.subscreen == 0)
		dat += {"<h2>Medical Analysis Suite</h2><hr>
				 <h4>Visual Status Overlay</h4>
					When enabled, this package will scan all nearby crewmembers' vitals and provide real-time graphical data about their state of health.<br><br>
					The suite is currently [ (src.medHUD) ? "<font color=#55FF55>enabled</font>" : "<font color=#FF5555>disabled</font>" ].<br>
					<a href='byond://?src=\ref[src];software=medicalhud;sub=0;toggle=1'>Toggle Suite</a><br>
					<br>
					<a href='byond://?src=\ref[src];software=medicalhud;sub=1'>Host Bioscan</a><br>
					"}
	if(src.subscreen == 1)
		dat += {"<h2>Medical Analysis Suite</h2><hr>
				 <h4>Host Bioscan</h4>
				"}
		var/mob/living/M = src.loc
		if(!istype(M, /mob/living))
			while (!istype(M, /mob/living))
				M = M.loc
				if(istype(M, /turf))
					src.temp = "Error: No biological host found. <br>"
					src.subscreen = 0
					return dat
		dat += {"<b>Bioscan Results for [M]</b>: <br>
		Overall Status: [M.stat > 1 ? "dead" : "[M.health]% healthy"] <br><br>

		<b>Scan Breakdown</b>: <br>
		Respiratory: [M.getOxyLoss() > 50 ? "<font color=#FF5555>[M.getOxyLoss()]</font>" : "<font color=#55FF55>[M.getOxyLoss()]</font>"]<br>
		Toxicology: [M.getToxLoss() > 50 ? "<font color=#FF5555>[M.getToxLoss()]</font>" : "<font color=#55FF55>[M.getToxLoss()]</font>"]<br>
		Burns: [M.getFireLoss() > 50 ? "<font color=#FF5555>[M.getFireLoss()]</font>" : "<font color=#55FF55>[M.getFireLoss()]</font>"]<br>
		Structural Integrity: [M.getBruteLoss() > 50 ? "<font color=#FF5555>[M.getBruteLoss()]</font>" : "<font color=#55FF55>[M.getBruteLoss()]</font>"]<br>
		Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)<br>
		"}
		for(var/datum/disease/D in M.viruses)
			dat += {"<h4>Infection Detected.</h4><br>
					 Name: [D.name]<br>
					 Type: [D.spread]<br>
					 Stage: [D.stage]/[D.max_stages]<br>
					 Possible Cure: [D.cure]<br>
					"}
		dat += "<br><a href='byond://?src=\ref[src];software=medicalhud;sub=1'>Refresh Bioscan</a><br>"
		dat += "<br><a href='byond://?src=\ref[src];software=medicalhud;sub=0'>Visual Status Overlay</a><br>"
	return dat

// Atmospheric Scanner
/mob/living/silicon/pai/proc/softwareAtmo()
	var/dat = "<h2>Atmospheric Sensor</h2><hr>"

	var/turf/T = get_turf_or_move(src.loc)
	if (isnull(T))
		dat += "Unable to obtain a reading.<br>"
	else
		var/datum/gas_mixture/env = T.return_air()

		var/pressure = env.return_pressure()
		var/t_moles = env.total_moles

		dat += "Air Pressure: [round(pressure,0.1)] kPa<br>"

		for(var/g in env.gas)
			dat += "[gas_data.name[g]]: [round((env.gas[g] / t_moles) * 100)]"

		dat += "Temperature: [round(env.temperature-T0C)]&deg;C<br>"
	dat += "<br><a href='byond://?src=\ref[src];software=atmosensor;sub=0'>Refresh Reading</a>"
	return dat

// Interaction module
/mob/living/silicon/pai/proc/softwareInteraction()
	var/dat = "<h2>Interaction Module</h2><hr>"
	dat += "This module provides a connection to various kinds of electronics which obviously should have a compatible connector. However, some devices' systems are too complex to interact with them.<br>"
	dat += "After the cable is connected, you can mark any compatible object it is connected to for remote access. Each marked device takes 5% of maximum memory, but only five devices can be marked.<br>"
	dat += "When connected remotely, make sure distance between you and marked device is not too long. Otherwise, data packets might not be delivered which causes loss of control.<br>"
	dat += "<br>"
	dat += "Connection status: "
	if(!cable && (!hackobj || !hacksuccess))
		dat += "<font color=#FF5555>Retracted</font> <br>"
		dat += "<a href='byond://?src=\ref[src];software=interaction;cable=1;sub=0'>Extend Cable</a> <br><br>"
		if(markedobjects.len > 0)
			dat += "Marked devices: <br>"
			for(var/i in 1 to markedobjects.len)
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_CONNECT_TO_MARKED];markedid=[i];sub=0'>[i] - [markedobjects[i]]</a> <br>"
		return dat
	if(cable && !cable.machine)
		dat += "<font color=#FFFF55>Extended</font> <br>"
		dat += "<a href='byond://?src=\ref[src];software=interaction;cable=2;sub=0'>Retract Cable</a> <br>"
		return dat
	var/obj/machinery/machine
	if(cable)
		machine = cable.machine
	else
		machine = hackobj
	dat += "<font color=#55FF55>Connected"
	if(cable)
		dat += " via cable"
	dat += "</font> <br>"
	if(!is_type_in_list(machine, list(/obj/machinery/door, /obj/machinery/camera, /obj/machinery/autolathe, /obj/machinery/vending, /obj/machinery/bot, /obj/item/device/pda, /obj/item/device/paicard)) || is_type_in_list(machine, list(/obj/machinery/door/airlock/vault, /obj/machinery/door/airlock/hatch, /obj/machinery/door/poddoor, /obj/machinery/door/airlock/highsecurity)) || src.card == machine) //Types that pAI able to hack, Types (some sort of doors at this moment) that pAI not able to hack, Restrict self-hacking
		dat += "Connected device's firmware does not appear to be compatible with installed protocols.<br>"
		dat += "<a href='byond://?src=\ref[src];software=interaction;cable=2;sub=0'>Retract Cable</a> <br>"
		return dat

	if(!hackobj)
		dat += "<a href='byond://?src=\ref[src];software=interaction;jack=1;sub=0'>Begin Jacking</a> <br>"
	else
		if(hacksuccess && src.hackobj)
			dat += "Firmware type: "
			if(istype(hackobj, /obj/machinery/door))
				dat += "Airlock.<br>"
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_DOOR_TOGGLE];sub=0'>Toggle Open</a> <br>"
				if(istype(hackobj, /obj/machinery/door/airlock))
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_DOOR_BOLT];sub=0'>Toggle Bolt</a> <br>"
			if(istype(hackobj, /obj/machinery/camera))
				var/obj/machinery/camera/Temp = hackobj
				dat += "Camera.<br>"
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_CAMERA_TOGGLE];sub=0'>Toggle Active State</a> (Currenty [Temp.status ? "Active" : "Disabled"]) <br>"
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_CAMERA_DISCONNECT];sub=0'>Disconnect All Active Viewers</a> <br>"
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_CAMERA_ALARM];sub=0'>Toggle Alarm</a> (Currenty [Temp.alarm_on ? "Active" : "Disabled"]) <br>"
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_CAMERA_AI_ACCESS];sub=0'>Toggle AI Access</a> (Currenty [Temp.hidden ? "Unreachable for AI" : "Active"]) <br>"
				if(!cable)
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_CAMERA_VIEW];sub=0'>Toggle View</a> <br>"
				else
					dat += "<font color=#BFBFBF>Toggle View</font> (Locked, unlocks during remote access) <br>"
			if(istype(hackobj, /obj/machinery/autolathe))
				var/obj/machinery/autolathe/Temp = src.hackobj
				dat += "Autolathe.<br>"
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_AUTOLATHE_UI];sub=0'>Open Interaction Menu</a> <br>"
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_AUTOLATHE_CONTRABAND];sub=0'>Toggle Hidden Features</a> (Currently [Temp.hacked ? "Shown" : "Hidden"]) <br>"
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_AUTOLATHE_POWER];sub=0'>Toggle Active State</a> (Currently [Temp.disabled ? "Disabled" : "Active"]) <br>"
			if(istype(hackobj, /obj/item/device/pda))
				var/obj/item/device/pda/Temp = hackobj
				dat += "PDA.<br>"
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_PDA_TOGGLE_MSG];sub=0'>Toggle Messenger</a> (Currently [Temp.toff == 0 ? "Active" : "Disabled"]) <br>"
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_PDA_CHANGE_RINGTONE];sub=0'>Change Ringtone</a> (Current: [Temp.ttone]) <br>"
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_PDA_TOGGLE_RINGTONE];sub=0'>Toggle Ringtone</a> (Currently [Temp.message_silent == 0 ? "Active" : "Disabled"]) <br>"
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_PDA_TOGGLE_VISIBLE];sub=0'>Hide/Unhide PDA</a> (Currently [Temp.hidden == 0 ? "Visible" : "Hidden"]) <br>"
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_PDA_CHANGE_NAME];sub=0'>Change Shown Name/Job</a> (Current: [Temp.owner] as [Temp.ownrank]) <br>"
			if(istype(hackobj, /obj/item/device/paicard))
				var/obj/item/device/paicard/Temp = hackobj
				dat += "pAI.<br>"
				if(Temp.pai)
					var/mob/living/silicon/pai/Temppai = Temp.pai
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_PAI_MODIFY_MAIN_LAW];sub=0'>Modify Main Law</a> (Current: [Temppai.laws.zeroth]) <br>"
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_PAI_MODIFY_SEC_LAW];sub=0'>Modify Secondary Laws</a> (Current: [jointext(Temppai.laws.supplied, "<br>")]) <br>"
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_PAI_MANAGE_MARKED];sub=0'>Get Marked Objects List</a> <br>"
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_PAI_RESET_MARKED];sub=0'>Clear Marked Objects List</a> <br>"
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_PAI_CLEAR_SOFTWARE];sub=0'>Delete All Installed Software</a> <br>"
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_PAI_UNBOUND];sub=0'>Unbound</a> <br>"
				else
					dat += "Personality not found.<br>"
			if(istype(hackobj, /obj/machinery/vending))
				dat += "Vending Machine.<br>"
				var/obj/machinery/vending/Temp = hackobj
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_VENDING_ITEM_SHOOTING];sub=0'>Toggle Item Shooting</a> (Currently [Temp.shoot_inventory ? "Active" : "Disabled"]) <br>"
				if(Temp.shoot_inventory)
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_VENDING_SHOOT_ITEM];sub=0'>Shoot Item</a> <br>"
				else
					dat += "<font color=#BFBFBF>Shoot Item</font> (Function wasn't unlocked) <br>"
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_VENDING_SPEAK];sub=0'>Speak</a> <br>"
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_VENDING_CONTRABAND_MODE];sub=0'>Lock/Unlock Hidden Items</a> (Currently [Temp.extended_inventory ? "Shown" : "Hidden"]) <br>"
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_VENDING_ACCOUNT_VERIFY];sub=0'>Toggle Account Verifying</a> (Actually, just make everything silently free. Currently [Temp.check_accounts ? "Active" : "Disabled"]) <br>"
			if(istype(hackobj, /obj/machinery/bot))
				var/botchecked = 0 //Should we name bot as "Unknown"?
				if(istype(hackobj, /obj/machinery/bot/secbot))
					botchecked = 1
					if(istype(hackobj, /obj/machinery/bot/secbot/ed209))
						dat += "ED209 "
					dat += "Security Bot.<br>"
					var/obj/machinery/bot/secbot/Temp = hackobj
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_SECBOT_ID_CHECKER];sub=0'>Toggle ID Checker</a> (Currently [Temp.idcheck ? "Active" : "Disabled"]) <br>"
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_SECBOT_CHEKING_RECORDS];sub=0'>Toggle Records Checker</a> (Currently [Temp.check_records ? "Active" : "Disabled"]) <br>"
				if(istype(hackobj, /obj/machinery/bot/farmbot))
					botchecked = 1
					dat += "Farm Bot.<br>"
					var/obj/machinery/bot/farmbot/Temp = hackobj
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_FARMBOT_PLANTS_WATERING];sub=0'>Toggle Plants Watering</a> (Currently [Temp.setting_water ? "Active" : "Disabled"]) <br>"
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_FARMBOT_TOGGLE_REFILLGING];sub=0'>Toggle Refilling From Nearest Water Tanks</a> (Currently [Temp.setting_refill ? "Active" : "Disabled"]) <br>"
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_FARMBOT_TOGGLE_FERTILIZING];sub=0'>Toggle Fertilizing</a> (Currently [Temp.setting_fertilize ? "Active" : "Disabled"]) <br>"
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_FARMBOT_TOGGLE_WEED_PLANTS];sub=0'>Toggle Weed Plants</a> (Currently [Temp.setting_weed ? "Active" : "Disabled"]) <br>"
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_FARMBOT_TOGGLE_WEEDS_IGNORING];sub=0'>Toggle Weeds Ignoring</a> (Currently [Temp.setting_ignoreWeeds ? "Active" : "Disabled"]) <br>"
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_FARMBOT_TOGGLE_MUSHROOMS_IGNORING];sub=0'>Toggle Mushrooms Ingoring</a> (Currently [Temp.setting_ignoreMushrooms ? "Active" : "Disabled"]) <br>"
				if(istype(hackobj, /obj/machinery/bot/floorbot))
					botchecked = 1
					dat += "Floor Bot.<br>"
					var/obj/machinery/bot/floorbot/Temp = hackobj
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_FLOORBOT_TOGGLE_FLOOR_FIXTILES];sub=0'>Toggle Floor Fixing</a> (Currently [Temp.fixtiles ? "Active" : "Disabled"]) <br>"
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_FLOORBOT_TOGGLE_FLOOR_PLACETILES];sub=0'>Toggle Floor Tiles Placement</a> (Currently [Temp.placetiles ? "Active" : "Disabled"]) <br>"
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_FLOORBOT_TOGGLE_SEARCHING];sub=0'>Toggle Searching Tiles</a> (Currently [Temp.eattiles ? "Active" : "Disabled"]) <br>"
					dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_FLOORBOT_TOGGLE_TILES_FABRICATION];sub=0'>Toggle Tiles Fabrication</a> (Currently [Temp.maketiles ? "Active" : "Disabled"]) <br>"
				if(!botchecked)
					dat += "Unknown.<br>"
				var/obj/machinery/bot/Temp = hackobj
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_ANYBOT_INTERFACE_LOCK];sub=0'>Toggle Interface Lock</a> (Currently [Temp.locked ? "Locked" : "Unlocked"]) <br>"
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_ANYBOT_TOGGLE_ACTIVE];sub=0'>Turn [Temp.on ? "Off" : "On"]</a> <br>"
			//Add something new there
			if(hackobj in markedobjects)
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_REMOVE_FROM_MARKED];sub=0'>Unmark</a> <br>"
			else
				dat += "<a href='byond://?src=\ref[src];software=interaction;interactwith=[INTERACTION_ADD_TO_MARKED];sub=0'>Mark</a> <br>"
		else
			dat += "Jack in progress... [src.hackprogress]% complete.<br>"
			dat += "<a href='byond://?src=\ref[src];software=interaction;cancel=1;sub=0'>Cancel Jack</a> <br>"
	if(cable)
		dat += "<br><a href='byond://?src=\ref[src];software=interaction;cable=2;sub=0'>Retract Cable</a> <br>"
	else
		dat += "<br><a href='byond://?src=\ref[src];software=interaction;cable=2;sub=0'>Disconnect</a> <br>"
	return dat

// Object Jack - supporting proc
/mob/living/silicon/pai/proc/hackloop()
	var/turf/T = get_turf_or_move(loc)
	if(is_type_in_list(hackobj, list(/obj/machinery/door, /obj/machinery/camera, /obj/machinery/bot)))
		for(var/mob/living/silicon/ai/AI in ai_list)
			if(T.loc)
				to_chat(AI, "<font color = red><b>Network Alert: Brute-force encryption crack in progress in [T.loc].</b></font>")
			else
				to_chat(AI, "<font color = red><b>Network Alert: Brute-force encryption crack in progress. Unable to pinpoint location.</b></font>")
	while(hackprogress < 100)
		if(cable && cable.machine && cable.machine == hackobj && get_dist(src, src.hackobj) <= 1)
			hackprogress += rand(1, 10)
		else
			hackprogress = 0
			return
		if(hackprogress >= 100)		// This is clunky, but works. We need to make sure we don't ever display a progress greater than 100,
			hackprogress = 100		// but we also need to reset the progress AFTER it's been displayed
		if(src.screen == "interaction" && src.subscreen == 0) // Update our view, if appropriate
			src.paiInterface()
		if(hackprogress == 100)
			hackprogress = 0
			src.hacksuccess = TRUE
			return
		sleep(50)			// Update every 5 seconds

// Digital Messenger
/mob/living/silicon/pai/proc/pdamessage()

	var/dat = "<h2>Digital Messenger</h2><hr>"
	dat += {"<b>Signal/Receiver Status:</b> <A href='byond://?src=\ref[src];software=pdamessage;toggler=1'>
	[(pda.toff) ? "<font color='red'> \[Off\]</font>" : "<font color='green'> \[On\]</font>"]</a><br>
	<b>Ringer Status:</b> <A href='byond://?src=\ref[src];software=pdamessage;ringer=1'>
	[(pda.message_silent) ? "<font color='red'> \[Off\]</font>" : "<font color='green'> \[On\]</font>"]</a><br><br>"}
	dat += "<ul>"
	if(!pda.toff)
		for (var/obj/item/device/pda/P in sortAtom(PDAs))
			if (!P.owner||P.toff||P == src.pda||P.hidden)	continue
			dat += "<li><a href='byond://?src=\ref[src];software=pdamessage;target=\ref[P]'>[P]</a>"
			dat += "</li>"
	dat += "</ul>"
	dat += "Messages: <hr>"

	dat += "<style>td.a { vertical-align:top; }</style>"
	dat += "<table>"
	for(var/index in pda.tnote)
		if(index["sent"])
			dat += addtext("<tr><td class='a'><i><b>To</b></i></td><td class='a'><i><b>&rarr;</b></i></td><td><i><b><a href='byond://?src=\ref[src];software=pdamessage;target=",index["src"],"'>", index["owner"],"</a>: </b></i>", index["message"], "<br></td></tr>")
		else
			dat += addtext("<tr><td class='a'><i><b>From</b></i></td><td class='a'><i><b>&rarr;</b></i></td><td><i><b><a href='byond://?src=\ref[src];software=pdamessage;target=",index["target"],"'>", index["owner"],"</a>: </b></i>", index["message"], "<br></td></tr>")
	dat += "</table>"
	return dat

/mob/living/silicon/pai/proc/translator_toggle()

	// 	Sol Common, Tradeband and Gutter are added with atom_init() and are therefore the current default, always active languages

	if(translator_on)
		translator_on = 0

		remove_language("Sinta'unathi")
		remove_language("Siik'maas")
		remove_language("Siik'tajr")
		remove_language("Skrellian")

		to_chat(src, "<span class='notice'>Translator Module toggled OFF.</span>")

	else
		translator_on = 1

		add_language("Sinta'unathi")
		add_language("Siik'maas")
		add_language("Siik'tajr", 0)
		add_language("Skrellian")

		to_chat(src, "<span class='notice'>Translator Module toggled ON.</span>")

#undef INTERACTION_ADD_TO_MARKED
#undef INTERACTION_REMOVE_FROM_MARKED
#undef INTERACTION_CONNECT_TO_MARKED


#undef INTERACTION_DOOR_TOGGLE
#undef INTERACTION_DOOR_BOLT


#undef INTERACTION_CAMERA_TOGGLE
#undef INTERACTION_CAMERA_DISCONNECT
#undef INTERACTION_CAMERA_ALARM
#undef INTERACTION_CAMERA_AI_ACCESS
#undef INTERACTION_CAMERA_VIEW


#undef INTERACTION_AUTOLATHE_UI
#undef INTERACTION_AUTOLATHE_CONTRABAND
#undef INTERACTION_AUTOLATHE_POWER


#undef INTERACTION_PDA_TOGGLE_MSG
#undef INTERACTION_PDA_CHANGE_RINGTONE
#undef INTERACTION_PDA_TOGGLE_RINGTONE
#undef INTERACTION_PDA_TOGGLE_VISIBLE
#undef INTERACTION_PDA_CHANGE_NAME


#undef INTERACTION_PAI_MODIFY_MAIN_LAW
#undef INTERACTION_PAI_MODIFY_SEC_LAW
#undef INTERACTION_PAI_MANAGE_MARKED
#undef INTERACTION_PAI_RESET_MARKED
#undef INTERACTION_PAI_CLEAR_SOFTWARE
#undef INTERACTION_PAI_UNBOUND


#undef INTERACTION_VENDING_ITEM_SHOOTING
#undef INTERACTION_VENDING_SHOOT_ITEM
#undef INTERACTION_VENDING_SPEAK
#undef INTERACTION_VENDING_CONTRABAND_MODE
#undef INTERACTION_VENDING_ACCOUNT_VERIFY


#undef INTERACTION_ANYBOT_INTERFACE_LOCK
#undef INTERACTION_ANYBOT_TOGGLE_ACTIVE

#undef INTERACTION_SECBOT_ID_CHECKER
#undef INTERACTION_SECBOT_CHEKING_RECORDS

#undef INTERACTION_FARMBOT_PLANTS_WATERING
#undef INTERACTION_FARMBOT_TOGGLE_REFILLGING
#undef INTERACTION_FARMBOT_TOGGLE_FERTILIZING
#undef INTERACTION_FARMBOT_TOGGLE_WEED_PLANTS
#undef INTERACTION_FARMBOT_TOGGLE_WEEDS_IGNORING
#undef INTERACTION_FARMBOT_TOGGLE_MUSHROOMS_IGNORING

#undef INTERACTION_FLOORBOT_TOGGLE_FLOOR_FIXTILES
#undef INTERACTION_FLOORBOT_TOGGLE_FLOOR_PLACETILES
#undef INTERACTION_FLOORBOT_TOGGLE_SEARCHING
#undef INTERACTION_FLOORBOT_TOGGLE_TILES_FABRICATION
