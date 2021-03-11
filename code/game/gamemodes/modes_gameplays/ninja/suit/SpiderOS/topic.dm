/obj/item/clothing/suit/space/space_ninja/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/U = affecting
	var/mob/living/silicon/ai/A = AI
	var/display_to = s_control ? U : A//Who do we want to display certain messages to?

	if(usr != U && usr != A)
		return

	if(s_control)
		if(!affecting||U.stat||!s_initialized)//Check to make sure the guy is wearing the suit after clicking and it's on.
			to_chat(U, "<span class='warning'>Your suit must be worn and active to use this function.</span>")
			U << browse(null, "window=spideros")//Closes the window.
			return

		if(k_unlock!=7&&href_list["choice"]!="Return")
			var/u1=text2num(href_list["choice"])
			var/u2=(u1?abs(abs(k_unlock-u1)-2):1)
			k_unlock=(!u2? k_unlock+1:0)
			if(k_unlock==7)
				to_chat(U, "Anonymous Messenger blinks.")
	else
		if(!affecting||A.stat||!s_initialized||A.loc!=src)
			to_chat(A, "<span class='warning'>This function is not available at this time.</span>")
			A << browse(null, "window=spideros")//Closes the window.
			return

	switch(href_list["choice"])
		if("Close")
			display_to << browse(null, "window=spideros")
			return
		if("Refresh")//Refresh, goes to the end of the proc.
		if("Return")//Return
			if(spideros<=9)
				spideros=0
			else
				spideros = round(spideros/10)//Best way to do this, flooring to nearest integer.

		if("Shock")
			var/damage = min(cell.charge, rand(50,150))//Uses either the current energy left over or between 50 and 150.
			if(damage>1)//So they don't spam it when energy is a factor.
				spark_system.start()//SPARKS THERE SHALL BE SPARKS
				U.electrocute_act(damage, src, 0.1)
				if(cell.charge < damage)
					cell.use(cell.charge)
				else
					cell.use(damage)
			else
				to_chat(A, "<span class='warning'><b>ERROR</b>:</span> Not enough energy remaining.")

		if("Message")
			var/obj/item/device/pda/P = locate(href_list["target"])
			var/t = sanitize(input(U, "Please enter untraceable message.") as text)
			if(!t||U.stat||U.wear_suit!=src||!s_initialized)//Wow, another one of these. Man...
				display_to << browse(null, "window=spideros")
				return
			if(isnull(P)||P.toff)//So it doesn't freak out if the object no-longer exists.
				to_chat(display_to, "<span class='warning'>Error: unable to deliver message.</span>")
				display_spideros()
				return
			var/obj/machinery/message_server/useMS = null
			if(!useMS || !useMS.active)
				useMS = null
				if(message_servers)
					for (var/obj/machinery/message_server/MS in message_servers)
						if(MS.active)
							useMS = MS
							break
			if(useMS)
				var/sender = "an unknown source"
				useMS.send_pda_message("[P.owner]",sender,"[t]")

				for(var/mob/M in player_list)
					if(M.stat == DEAD && M.client && (M.client.prefs.chat_toggles & CHAT_GHOSTEARS)) // src.client is so that ghosts don't have to listen to mice
						if(isnewplayer(M))
							continue
						to_chat(M, "<span class='game say'>PDA Message - <span class='name'>[U]</span> -> <span class='name'>[P.owner]</span>: <span class='message'>[t]</span></span>")

				if (!P.message_silent)
					playsound(P, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)
					P.audible_message("[bicon(P)] *[P.ttone]*", hearing_distance = 3)
				P.cut_overlays()
				P.add_overlay(image('icons/obj/pda.dmi', "pda-r"))
				var/mob/living/L = null
				if(P.loc && isliving(P.loc))
					L = P.loc
				//Maybe they are a pAI!
				else
					L = get(P, /mob/living/silicon)

				if(L)
					to_chat(L, "[bicon(P)] <b>Message from [sender], </b>\"[t]\" (Unable to Reply)")
			else
				to_chat(U, "<span class='notice'>ERROR: Messaging server is not responding.</span>")

		if("Inject")
			if( (href_list["tag"]=="radium"? (reagents.get_reagent_amount("radium"))<=(a_boost*a_transfer) : !reagents.get_reagent_amount(href_list["tag"])) )//Special case for radium. If there are only a_boost*a_transfer radium units left.
				to_chat(display_to, "<span class='warning'>Error: the suit cannot perform this function. Out of [href_list["name"]].</span>")
			else
				reagents.reaction(U, 2)
				reagents.trans_id_to(U, href_list["tag"], href_list["tag"]=="nutriment"?5:a_transfer)//Nutriment is a special case since it's very potent. Shouldn't influence actual refill amounts or anything.
				to_chat(display_to, "Injecting...")
				to_chat(U, "You feel a tiny prick and a sudden rush of substance in to your veins.")

		if("Trigger Ability")
			if(!(href_list["name"] in list("Phase Jaunt","Phase Shift","Energy Blade","Energy Star","Energy Net","EM Burst","Smoke Bomb","Adrenaline Boost")))
				return
			var/ability_name = href_list["name"]+href_list["cost"]//Adds the name and cost to create the full proc name.
			var/proc_arguments//What arguments to later pass to the proc, if any.
			var/targets[] = list()//To later check for.
			var/safety = 0//To later make sure we're triggering the proc when needed.
			switch(href_list["name"])//Special case.
				if("Phase Shift")
					safety = 1
					for(var/turf/T in oview(5,loc))
						targets.Add(T)
				if("Energy Net")
					safety = 1
					for(var/mob/living/carbon/M in oview(5,loc))
						targets.Add(M)
			if(targets.len)//Let's create an argument for the proc if needed.
				proc_arguments = pick(targets)
				safety = 0
			if(!safety)
				to_chat(A, "You trigger [href_list["name"]].")
				to_chat(U, "[href_list["name"]] suddenly triggered!")
				call(src,ability_name)(proc_arguments)
			else
				to_chat(A, "There are no potential [href_list["name"]=="Phase Shift"?"destinations" : "targets"] in view.")

		if("Unlock Kamikaze")
			if(input(U)=="Divine Wind")
				if( !(U.stat||U.wear_suit!=src||!s_initialized) )
					if( !(cell.charge<=1||s_busy) )
						s_busy = 1
						for(var/i, i<4, i++)
							switch(i)
								if(0)
									to_chat(U, "<span class='notice'>Engaging mode...\n</span><b>CODE NAME</b>: <span class='warning'><b>KAMIKAZE</b></span>")
								if(1)
									to_chat(U, "<span class='notice'>Re-routing power nodes... \nUnlocking limiter...</span>")
								if(2)
									to_chat(U, "<span class='notice'>Power nodes re-routed. \nLimiter unlocked.</span>")
								if(3)
									grant_kamikaze(U)//Give them verbs and change variables as necessary.
									U.regenerate_icons()//Update their clothing.
									ninjablade()//Summon two energy blades.
									message_admins("<span class='notice'>[key_name_admin(U)] used KAMIKAZE mode. [ADMIN_JMP(U)]</span>")//Let the admins know.
									s_busy = 0
									return
							sleep(s_delay)
					else
						to_chat(U, "<span class='warning'><b>ERROR</b>:</span> Unable to initiate mode.")
				else
					U << browse(null, "window=spideros")
					s_busy = 0
					return
			else
				to_chat(U, "<span class='warning'>ERROR: WRONG PASSWORD!</span>")
				k_unlock = 0
				spideros = 0
			s_busy = 0

		if("Eject Disk")
			var/turf/T = get_turf(loc)
			if(!U.get_active_hand())
				U.put_in_hands(t_disk)
				t_disk.add_fingerprint(U)
				t_disk = null
			else
				if(T)
					t_disk.loc = T
					t_disk = null
				else
					to_chat(U, "<span class='warning'><b>ERROR</b>:</span> Could not eject disk.")

		if("Copy to Disk")
			var/datum/tech/current_data = locate(href_list["target"])
			to_chat(U, "[current_data.name] successfully [(!t_disk.stored) ? "copied" : "overwritten"] to disk.")
			t_disk.stored = current_data

		if("Configure pAI")
			pai.attack_self(U)

		if("Eject pAI")
			var/turf/T = get_turf(loc)
			if(!U.get_active_hand())
				U.put_in_hands(pai)
				pai.add_fingerprint(U)
				pai = null
			else
				if(T)
					pai.loc = T
					pai = null
				else
					to_chat(U, "<span class='warning'><b>ERROR</b>:</span> Could not eject pAI card.")

		if("Override AI Laws")
			var/law_zero = A.laws.zeroth//Remembers law zero, if there is one.
			A.laws = new /datum/ai_laws/ninja_override
			A.set_zeroth_law(law_zero)//Adds back law zero if there was one.
			A.show_laws()
			to_chat(U, "<span class='notice'>Law Override: <b>SUCCESS</b>.</span>")

		if("Purge AI")
			var/confirm = alert("Are you sure you want to purge the AI? This cannot be undone once started.", "Confirm purge", "Yes", "No")
			if(U.stat||U.wear_suit!=src||!s_initialized)
				U << browse(null, "window=spideros")
				return
			if(confirm == "Yes"&&AI)
				if(A.laws.zeroth)//Gives a few seconds to re-upload the AI somewhere before it takes full control.
					s_busy = 1
					for(var/i,i<5,i++)
						if(AI==A)
							switch(i)
								if(0)
									to_chat(A, "<span class='warning'><b>WARNING</b>:</span> purge procedure detected. \nNow hacking host...")
									to_chat(U, "<span class='warning'><b>WARNING</b>: HACKING AT��TEMP� IN PR0GRESs!</span>")
									spideros = 0
									k_unlock = 0
									U << browse(null, "window=spideros")
								if(1)
									to_chat(A, "Disconnecting neural interface...")
									to_chat(U, "<span class='warning'><b>WAR�NING</b>: �R�O0�Gr�--S 2&3%</span>")
								if(2)
									to_chat(A, "Shutting down external protocol...")
									to_chat(U, "<span class='warning'><b>WARNING</b>: P����RֆGr�5S 677^%</span>")
									cancel_stealth()
								if(3)
									to_chat(A, "Connecting to kernel...")
									to_chat(U, "<span class='warning'><b>WARNING</b>: �R�r�R_404</span>")
									A.control_disabled = 0
								if(4)
									to_chat(A, "Connection established and secured. Menu updated.")
									to_chat(U, "<span class='warning'><b>W�r#nING</b>: #%@!!WȆ|_4�54@ \nUn�B88l3 T� L�-�o-L�CaT2 ##$!�RN�0..%..</span>")
									grant_AI_verbs()
									return
							sleep(s_delay)
						else	break
					s_busy = 0
					to_chat(U, "<span class='notice'>Hacking attempt disconnected. Resuming normal operation.</span>")
				else
					flush = 1
					A.suiciding = 1
					to_chat(A, "Your core files are being purged! This is the end...")
					spawn(0)
						display_spideros()//To refresh the screen and let this finish.
					while (A.stat != DEAD)
						A.adjustOxyLoss(2)
						A.updatehealth()
						sleep(10)
					killai()
					to_chat(U, "Artificial Intelligence was terminated. Rebooting...")
					flush = 0

		if("Wireless AI")
			A.control_disabled = !A.control_disabled
			to_chat(A, "AI wireless has been [A.control_disabled ? "disabled" : "enabled"].")
		else//If it's not a defined function, it's a menu.
			spideros=text2num(href_list["choice"])

	display_spideros()//Refreshes the screen by calling it again (which replaces current screen with new screen).
	return
