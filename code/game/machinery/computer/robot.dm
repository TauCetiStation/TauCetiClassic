/obj/machinery/computer/robotics
	name = "Robotics Control"
	desc = "Used to remotely lockdown or detonate linked Cyborgs."
	icon = 'icons/obj/computer.dmi'
	icon_state = "robot"
	state_broken_preset = "techb"
	state_nopower_preset = "tech0"
	light_color = "#a97faa"
	req_access = list(access_robotics)
	circuit = /obj/item/weapon/circuitboard/robotics

	required_skills = list(/datum/skill/research = SKILL_LEVEL_PRO)

	var/id = 0.0
	var/temp = null
	var/status = 0
	var/timeleft = 60
	var/stop = 0.0
	var/screen = 0 // 0 - Main Menu, 1 - Cyborg Status, 2 - Kill 'em All! -- In text

/obj/machinery/computer/robotics/attackby(obj/item/I, mob/user)
	if(issilicon(user))
		to_chat(user, "<span class='warning'>It's too complicated for you.</span>")
		return
	return ..()

/obj/machinery/computer/robotics/ui_interact(mob/user)
	if (!SSmapping.has_level(z))
		to_chat(user, "<span class='warning'><b>Unable to establish a connection</b>:</span> You're too far away from the station!")
		return

	var/dat
	if (src.temp)
		dat = "<TT>[src.temp]</TT><BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear Screen</A>"
	else
		if(screen == 0)
			dat += "<h3>Cyborg Control Console</h3><BR>"
			dat += "<A href='byond://?src=\ref[src];screen=1'>1. Cyborg Status</A><BR>"
			dat += "<A href='byond://?src=\ref[src];screen=2'>2. Emergency Full Destruct</A><BR>"
		if(screen == 1)
			for(var/mob/living/silicon/robot/R in silicon_list)
				if(isdrone(R))
					continue //There's a specific console for drones.
				if(isAI(user))
					if (R.connected_ai != user)
						continue
				if(isrobot(user))
					if (R != user)
						continue
				if(R.scrambledcodes)
					continue

				dat += "[R.name] |"
				if(R.stat != CONSCIOUS)
					dat += " Not Responding |"
				else if (!R.canmove)
					dat += " Locked Down |"
				else
					dat += " Operating Normally |"
				if (!R.canmove)
					EMPTY_BLOCK_GUARD
				else if(R.cell)
					dat += " Battery Installed ([R.cell.charge]/[R.cell.maxcharge]) |"
				else
					dat += " No Cell Installed |"
				if(R.module)
					dat += " Module Installed ([R.module.name]) |"
				else
					dat += " No Module Installed |"
				if(R.connected_ai)
					dat += " Slaved to [R.connected_ai.name] |"
				else
					dat += " Independent from AI |"
				if (issilicon(user))
					if((user.mind.special_role && user.mind.original == user) && !R.emagged)
						dat += "<A class='violet' href='byond://?src=\ref[src];magbot=\ref[R]'><i>Hack</i></A> "
				dat += "<A class='green' href='byond://?src=\ref[src];stopbot=\ref[R]'><i>[R.canmove ? "Lockdown" : "Release"]</i></A> "
				dat += "<A class='red' href='byond://?src=\ref[src];killbot=\ref[R]'><i>Destroy</i></A>"
				dat += "<BR>"
			dat += "<A href='byond://?src=\ref[src];screen=0'>Main Menu</A><BR>"
		if(screen == 2)
			if(!src.status)
				dat += {"<BR><B>Emergency Robot Self-Destruct</B><HR>\nStatus: Off<BR>
				\n<BR>
				\nCountdown: [src.timeleft]/60 <A href='byond://?src=\ref[src];reset=1'>Reset</A><BR>
				\n<BR>
				\n<A href='byond://?src=\ref[src];eject=1'>Start Sequence</A><BR>"}
			else
				dat = {"<B>Emergency Robot Self-Destruct</B><HR>\nStatus: Activated<BR>
				\n<BR>
				\nCountdown: [src.timeleft]/60 \[Reset\]<BR>
				\n<BR>\n<A href='byond://?src=\ref[src];stop=1'>Stop Sequence</A><BR>"}
			dat += "<A href='byond://?src=\ref[src];screen=0'>Main Menu</A><BR>"

	var/datum/browser/popup = new(user, "computer", null, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/robotics/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if (href_list["eject"])
		src.temp = {"Destroy Robots?<BR>
		<BR><B><A href='byond://?src=\ref[src];eject2=1'>Swipe ID to initiate destruction sequence</A></B><BR>
		<A href='byond://?src=\ref[src];temp=1'>Cancel</A>"}

	else if (href_list["eject2"])
		if(allowed(usr))
			if (!status)
				message_admins("<span class='notice'>[key_name_admin(usr)] has initiated the global cyborg killswitch! [ADMIN_JMP(usr)]</span>")
				log_game("[key_name(usr)] has initiated the global cyborg killswitch!")
				src.status = 1
				start_sequence()
				src.temp = null
		else
			to_chat(usr, "<span class='warning'>Access Denied.</span>")

	else if (href_list["stop"])
		src.temp = {"
		Stop Robot Destruction Sequence?<BR>
		<BR><A href='byond://?src=\ref[src];stop2=1'>Yes</A><BR>
		<A href='byond://?src=\ref[src];temp=1'>No</A>"}

	else if (href_list["stop2"])
		src.stop = 1
		src.temp = null
		src.status = 0

	else if (href_list["reset"])
		src.timeleft = 60

	else if (href_list["temp"])
		src.temp = null
	else if (href_list["screen"])
		switch(href_list["screen"])
			if("0")
				screen = 0
			if("1")
				screen = 1
			if("2")
				screen = 2
	else if (href_list["killbot"])
		if(allowed(usr))
			var/mob/living/silicon/robot/R = locate(href_list["killbot"])
			if(R)
				var/choice = input("Are you certain you wish to detonate [R.name]?") in list("Confirm", "Abort")
				if(choice == "Confirm")
					if(R && istype(R))
						if(R.mind && R.mind.special_role && R.emagged)
							to_chat(R, "Extreme danger.  Termination codes detected.  Scrambling security codes and automatic AI unlink triggered.")
							R.ResetSecurityCodes()

						else
							message_admins("<span class='notice'>[key_name_admin(usr)] [ADMIN_JMP(usr)] detonated [R.name]! [ADMIN_JMP(R)]</span>")
							log_game("[key_name(usr)] detonated [R.name]!")
							R.self_destruct()
		else
			to_chat(usr, "<span class='warning'>Access Denied.</span>")

	else if (href_list["stopbot"])
		if(allowed(usr))
			var/mob/living/silicon/robot/R = locate(href_list["stopbot"])
			if(R && istype(R)) // Extra sancheck because of input var references
				var/choice = input("Are you certain you wish to [R.canmove ? "lock down" : "release"] [R.name]?") in list("Confirm", "Abort")
				if(choice == "Confirm")
					if(R && istype(R))
						message_admins("[key_name_admin(usr)] [ADMIN_JMP(usr)] [R.canmove ? "locked down" : "released"] [R.name]! [ADMIN_JMP(R)]")
						log_game("[key_name(usr)] [R.canmove ? "locked down" : "released"] [R.name]!")
						R.canmove = !R.canmove
						if (R.lockcharge)
							R.clear_alert("locked")
						//	R.cell.charge = R.lockcharge
							R.lockcharge = !R.lockcharge
							to_chat(R, "Your lockdown has been lifted!")
							playsound(R, 'sound/effects/robot_unlocked.ogg', VOL_EFFECTS_MASTER, null, FALSE)
						else
							R.throw_alert("locked", /atom/movable/screen/alert/locked)
							R.lockcharge = !R.lockcharge
					//		R.cell.charge = 0
							to_chat(R, "You have been locked down!")
							playsound(R, 'sound/effects/robot_locked.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		else
			to_chat(usr, "<span class='warning'>Access Denied.</span>")

	else if (href_list["magbot"])
		if(allowed(usr))
			var/mob/living/silicon/robot/R = locate(href_list["magbot"])
			if(R)
				var/choice = input("Are you certain you wish to hack [R.name]?") in list("Confirm", "Abort")
				if(choice == "Confirm")
					if(R && istype(R))
//							message_admins("<span class='notice'>[key_name_admin(usr)] emagged [R.name] using robotic console!</span>")
						log_game("[key_name(usr)] emagged [R.name] using robotic console!")
						R.emagged = 1
						var/mob/living/silicon/ai/AI = R.connected_ai
						R.set_zeroth_law(AI.laws.zeroth_borg)
						if(R.mind.special_role)
							R.verbs += /mob/living/silicon/robot/proc/ResetSecurityCodes

	updateUsrDialog()

/obj/machinery/computer/robotics/proc/start_sequence()

	do
		if(src.stop)
			src.stop = 0
			return
		src.timeleft--
		sleep(10)
	while(src.timeleft)

	for(var/mob/living/silicon/robot/R in silicon_list)
		if(!R.scrambledcodes && !isdrone(R))
			R.self_destruct()

	return
