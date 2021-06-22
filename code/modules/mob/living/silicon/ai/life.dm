/mob/living/silicon/ai/Life()
	if (src.stat == DEAD)
		return
	else //I'm not removing that shitton of tabs, unneeded as they are. -- Urist
		//Being dead doesn't mean your temperature never changes
		var/turf/T = get_turf(src)

		if (src.stat!=0)
			src.cameraFollow = null
			reset_view(null)
			unset_machine()

		updatehealth()
		update_gravity(mob_has_gravity())
		update_action_buttons()

		if (src.malfhack)
			if (src.malfhack.aidisabled)
				to_chat(src, "<span class='warning'>ERROR: APC access disabled, hack attempt canceled.</span>")
				src.malfhacking = 0
				src.malfhack = null


		if (src.health <= config.health_threshold_dead)
			death()
			return

		if (src.machine)
			if (!( src.machine.check_eye(src) ))
				reset_view(null)

		// Handle power damage (oxy)
		if(src:aiRestorePowerRoutine != 0)
			// Lost power
			adjustOxyLoss(1)
		else
			// Gain Power
			adjustOxyLoss(-1)

		//stage = 1
		//if (istype(src, /mob/living/silicon/ai)) // Are we not sure what we are?
		var/blind = 0
		//stage = 2
		var/area/loc = null
		if (istype(T, /turf))
			//stage = 3
			loc = T.loc
			if (istype(loc, /area))
				//stage = 4
				if (!loc.power_equip && !istype(src.loc,/obj/item))
					//stage = 5
					blind = 1

		if (!blind)	//lol? if(!blind)	#if(src.blind.layer)    <--something here is clearly wrong :P
					//I'll get back to this when I find out  how this is -supposed- to work ~Carn //removed this shit since it was confusing as all hell --39kk9t
			//stage = 4.5
			src.sight |= SEE_TURFS
			src.sight |= SEE_MOBS
			src.sight |= SEE_OBJS
			src.see_in_dark = 8
			src.see_invisible = SEE_INVISIBLE_LEVEL_TWO


			//Congratulations!  You've found a way for AI's to run without using power!
			//Todo:  Without snowflaking up master_controller procs find a way to make AI use_power but only when APC's clear the area usage the tick prior
			//       since mobs are in master_controller before machinery.  We also have to do it in a manner where we don't reset the entire area's need to update
			//	 the power usage.
			//
			//	 We can probably create a new machine that resides inside of the AI contents that uses power using the idle_usage of 1000 and nothing else and
			//       be fine.
/*
			var/area/home = get_area(src)
			if(!home)	return//something to do with malf fucking things up I guess. <-- aisat is gone. is this still necessary? ~Carn
			if(home.powered(EQUIP))
				home.use_power(1000, EQUIP)
*/

			if (src:aiRestorePowerRoutine==2)
				to_chat(src, "Alert cancelled. Power has been restored without our assistance.")
				src:aiRestorePowerRoutine = 0
				return
			else if (src:aiRestorePowerRoutine==3)
				to_chat(src, "Alert cancelled. Power has been restored.")
				src:aiRestorePowerRoutine = 0
				return
		else

			//stage = 6
			src.sight = src.sight&~SEE_TURFS
			src.sight = src.sight&~SEE_MOBS
			src.sight = src.sight&~SEE_OBJS
			src.see_in_dark = 0
			src.see_invisible = SEE_INVISIBLE_LIVING

			if (((!loc.power_equip) || istype(T, /turf/space)) && !istype(src.loc,/obj/item))
				if (src:aiRestorePowerRoutine==0)
					src:aiRestorePowerRoutine = 1

					to_chat(src, "You've lost power!")
//							world << "DEBUG CODE TIME! [loc] is the area the AI is sucking power from"
					if (!is_special_character(src))
						set_zeroth_law("")
					//clear_supplied_laws() // Don't reset our laws.
					//var/time = time2text(world.realtime,"hh:mm:ss")
					//lawchanges.Add("[time] <b>:</b> [src.name]'s noncore laws have been reset due to power failure")
					spawn(20)
						to_chat(src, "Backup battery online. Scanners, camera, and radio interface offline. Beginning fault-detection.")
						sleep(50)
						if (loc.power_equip)
							if (!istype(T, /turf/space))
								to_chat(src, "Alert cancelled. Power has been restored without our assistance.")
								src:aiRestorePowerRoutine = 0
								return
						to_chat(src, "Fault confirmed: missing external power. Shutting down main control system to save power.")
						sleep(20)
						to_chat(src, "Emergency control system online. Verifying connection to power network.")
						sleep(50)
						if (istype(T, /turf/space))
							to_chat(src, "Unable to verify! No power connection detected!")
							src:aiRestorePowerRoutine = 2
							return
						to_chat(src, "Connection verified. Searching for APC in power network.")
						sleep(50)
						var/obj/machinery/power/apc/theAPC = null
/*
						for (var/something in loc)
							if (istype(something, /obj/machinery/power/apc))
								if (!(something:stat & BROKEN))
									theAPC = something
									break
*/
						var/PRP //like ERP with the code, at least this stuff is no more 4x sametext
						for (PRP=1, PRP<=4, PRP++)
							var/area/AIarea = get_area(src)
							for (var/obj/machinery/power/apc/APC in AIarea)
								if (!(APC.stat & BROKEN))
									theAPC = APC
									break
							if(!theAPC)
								switch(PRP)
									if (1)
										to_chat(src, "Unable to locate APC!")
									else
										to_chat(src, "Lost connection with the APC!")
								src:aiRestorePowerRoutine = 2
								return
							if(loc.power_equip)
								if(!istype(T, /turf/space))
									to_chat(src, "Alert cancelled. Power has been restored without our assistance.")
									src:aiRestorePowerRoutine = 0
									return
							switch(PRP)
								if (1)
									to_chat(src, "APC located. Optimizing route to APC to avoid needless power waste.")
								if (2)
									to_chat(src, "Best route identified. Hacking offline APC power port.")
								if (3)
									to_chat(src, "Power port upload access confirmed. Loading control program into APC power port software.")
								if (4)
									to_chat(src, "Transfer complete. Forcing APC to execute program.")
									sleep(50)
									to_chat(src, "Receiving control information from APC.")
									sleep(2)
									//bring up APC dialog
									apc_override = 1
									theAPC.attack_ai(src)
									apc_override = 0
									src:aiRestorePowerRoutine = 3
									to_chat(src, "Here are your current laws:")
									show_laws()
							sleep(50)
							theAPC = null

	add_ingame_age()
	regular_hud_updates()

/mob/living/silicon/ai/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		if(fire_res_on_core)
			health = 100 - getOxyLoss() - getToxLoss() - getBruteLoss()
		else
			health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
	diag_hud_set_health()
	diag_hud_set_status()

/mob/living/silicon/ai/rejuvenate()
	..()
	add_ai_verbs(src)
