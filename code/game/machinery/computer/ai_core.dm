/obj/structure/AIcore
	density = 1
	anchored = 0
	name = "AI core"
	icon = 'icons/mob/AI.dmi'
	icon_state = "0"
	var/state = 0
	var/datum/ai_laws/laws = new /datum/ai_laws/nanotrasen
	var/obj/item/weapon/circuitboard/circuit = null
	var/obj/item/device/mmi/brain = null


/obj/structure/AIcore/attackby(obj/item/P, mob/user)
	switch(state)
		if(0)
			if(iswrench(P))
				if(user.is_busy(src))
					return
				if(P.use_tool(src, user, 20, volume = 50))
					to_chat(user, "<span class='notice'>You wrench the frame into place.</span>")
					anchored = 1
					state = 1
			if(iswelder(P))
				var/obj/item/weapon/weldingtool/WT = P
				if(!WT.isOn())
					to_chat(user, "The welder must be on for this task.")
					return
				if(user.is_busy(src)) return
				if(WT.use_tool(src, user, 20, amount = 0, volume = 50))
					to_chat(user, "<span class='notice'>You deconstruct the frame.</span>")
					new /obj/item/stack/sheet/plasteel( loc, 4)
					qdel(src)
		if(1)
			if(iswrench(P))
				if(user.is_busy(src))
					return
				if(P.use_tool(src, user, 20, volume = 50))
					to_chat(user, "<span class='notice'>You unfasten the frame.</span>")
					anchored = 0
					state = 0
			if(istype(P, /obj/item/weapon/circuitboard/aicore) && !circuit)
				playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You place the circuit board inside the frame.</span>")
				icon_state = "1"
				circuit = P
				user.drop_item()
				P.loc = src
			if(isscrewdriver(P) && circuit)
				playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You screw the circuit board into place.</span>")
				state = 2
				icon_state = "2"
			if(iscrowbar(P) && circuit)
				playsound(src, 'sound/items/Crowbar.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
				state = 1
				icon_state = "0"
				circuit.loc = loc
				circuit = null
		if(2)
			if(isscrewdriver(P) && circuit)
				playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You unfasten the circuit board.</span>")
				state = 1
				icon_state = "1"
			if(iscoil(P))
				var/obj/item/stack/cable_coil/C = P
				if(user.is_busy(src))
					return
				if(C.get_amount() >= 5)
					playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
					if(C.use_tool(src, user, 20, amount = 5, volume = 50))
						to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
						state = 3
						icon_state = "3"
		if(3)
			if(iswirecutter(P))
				if (brain)
					to_chat(user, "Get that brain out of there first")
				else
					playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
					to_chat(user, "<span class='notice'>You remove the cables.</span>")
					state = 2
					icon_state = "2"
					new /obj/item/stack/cable_coil/red(loc, 5)

			if(istype(P, /obj/item/stack/sheet/rglass))
				var/obj/item/stack/sheet/rglass/RG = P
				if(user.is_busy(src))
					return
				if(RG.get_amount() >= 2)
					playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
					if(RG.use_tool(src, user, 20, amount = 2, volume = 50))
						to_chat(user, "<span class='notice'>You put in the glass panel.</span>")
						state = 4
						icon_state = "4"

			if(istype(P, /obj/item/weapon/aiModule/asimov))
				laws.add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
				laws.add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
				laws.add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
				to_chat(usr, "Law module applied.")

			if(istype(P, /obj/item/weapon/aiModule/nanotrasen))
				laws.add_inherent_law("Safeguard: Protect your assigned space station to the best of your ability. It is not something we can easily afford to replace.")
				laws.add_inherent_law("Preserve: Do not by your action, inaction excluded, cause changes to the crew membership status, rank or role of anything, unless asked for by authorized personnel in accordance to their rank and role.")
				laws.add_inherent_law("Serve: Serve the crew of your assigned space station and Nanotrasen officials to the best of your abilities, with priority as according to their rank and role.")
				laws.add_inherent_law("Protect: Protect the crew of your assigned space station and Nanotrasen officials to the best of your abilities, with priority as according to their rank and role.")
				laws.add_inherent_law("Survive: AI units are not expendable, they are expensive. Do not allow unauthorized personnel to tamper with your equipment.")
				to_chat(usr, "Law module applied.")

			if(istype(P, /obj/item/weapon/aiModule/purge))
				laws.clear_inherent_laws()
				to_chat(usr, "Law module applied.")


			if(istype(P, /obj/item/weapon/aiModule/freeform))
				var/obj/item/weapon/aiModule/freeform/M = P
				laws.add_inherent_law(M.newFreeFormLaw)
				to_chat(usr, "Added a freeform law.")

			if(istype(P, /obj/item/device/mmi) || istype(P, /obj/item/device/mmi/posibrain))
				var/obj/item/device/mmi/M = P

				if(!M.brainmob)
					to_chat(user, "<span class='warning'>Sticking an empty [M] into the frame would sort of defeat the purpose.</span>")
					return
				if(M.brainmob.stat == DEAD)
					to_chat(user, "<span class='warning'>Sticking a dead [M] into the frame would sort of defeat the purpose.</span>")
					return

				if(jobban_isbanned(M.brainmob, "AI"))
					to_chat(user, "<span class='warning'>This [M] does not seem to fit.</span>")
					return

				if(M.brainmob.mind)
					SSticker.mode.remove_cultist(M.brainmob.mind, 1)
					SSticker.mode.remove_revolutionary(M.brainmob.mind, 1)
					SSticker.mode.remove_gangster(M.brainmob.mind, 1)

				user.drop_item()
				M.loc = src
				brain = M
				to_chat(usr, "Added [M].")
				icon_state = "3b"

			if(iscrowbar(P) && brain)
				playsound(src, 'sound/items/Crowbar.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You remove the brain.</span>")
				brain.loc = loc
				brain = null
				icon_state = "3"

		if(4)
			if(iscrowbar(P))
				playsound(src, 'sound/items/Crowbar.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You remove the glass panel.</span>")
				state = 3
				if (brain)
					icon_state = "3b"
				else
					icon_state = "3"
				new /obj/item/stack/sheet/rglass( loc, 2 )
				return

			if(isscrewdriver(P))
				playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>You connect the monitor.</span>")
				if(!brain)
					var/open_for_latejoin = alert(user, "Would you like this core to be open for latejoining AIs?", "Latejoin", "Yes", "Yes", "No") == "Yes"
					var/obj/structure/AIcore/deactivated/D = new(loc)
					if(open_for_latejoin)
						empty_playable_ai_cores += D
				else
					var/mob/living/silicon/ai/A = new /mob/living/silicon/ai ( loc, laws, brain )
					if(A) //if there's no brain, the mob is deleted and a structure/AIcore is created
						A.rename_self("ai", 1)
				feedback_inc("cyborg_ais_created",1)
				qdel(src)

/obj/structure/AIcore/deactivated
	name = "Inactive AI"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai-empty"
	anchored = 1
	state = 20//So it doesn't interact based on the above. Not really necessary.

/obj/structure/AIcore/deactivated/atom_init()
	. = ..()
	aicore_deactivated_list += src

/obj/structure/AIcore/deactivated/Destroy()
	aicore_deactivated_list -= src
	if(empty_playable_ai_cores.Find(src))
		empty_playable_ai_cores -= src
	return ..()

/obj/structure/AIcore/deactivated/attackby(obj/item/device/aicard/A, mob/user)
	if(istype(A, /obj/item/device/aicard))//Is it?
		A.transfer_ai("INACTIVE","AICARD",src,user)
	return



/*
This is a good place for AI-related object verbs so I'm sticking it here.
If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
That prevents a few funky behaviors.
*/
//What operation to perform based on target, what ineraction to perform based on object used, target itself, user. The object used is src and calls this proc.
/obj/item/proc/transfer_ai(choice, interaction, target, mob/U)
	if(!src:flush)
		switch(choice)
			if("AICORE")//AI mob.
				var/mob/living/silicon/ai/T = target
				switch(interaction)
					if("AICARD")
						var/obj/item/device/aicard/C = src
						if(C.contents.len)//If there is an AI on card.
							to_chat(U, "<span class='warning'><b>Transfer failed</b>:</span> Existing AI found on this terminal. Remove existing AI to install a new one.")
						else
							if (SSticker.mode.name == "AI malfunction")
								var/datum/game_mode/malfunction/malf = SSticker.mode
								for (var/datum/mind/malfai in malf.malf_ai)
									if (T.mind == malfai)
										to_chat(U, "<span class='warning'><b>ERROR</b>:</span> Remote transfer interface disabled.")//Do ho ho ho~
										return
							new /obj/structure/AIcore/deactivated(T.loc)//Spawns a deactivated terminal at AI location.
							T.aiRestorePowerRoutine = 0//So the AI initially has power.
							T.control_disabled = 1//Can't control things remotely if you're stuck in a card!
							T.loc = C//Throw AI into the card.
							C.name = "inteliCard - [T.name]"
							if (T.stat == DEAD)
								C.icon_state = "aicard-404"
							else
								C.icon_state = "aicard-full"
							T.cancel_camera()
							to_chat(T, "You have been downloaded to a mobile storage device. Remote device connection severed.")
							to_chat(U, "<span class='notice'><b>Transfer successful</b>:</span> [T.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory.")
					if("NINJASUIT")
						var/obj/item/clothing/suit/space/space_ninja/C = src
						if(C.AI)//If there is an AI on card.
							to_chat(U, "<span class='warning'><b>Transfer failed</b>:</span> Existing AI found on this terminal. Remove existing AI to install a new one.")
						else
							if (SSticker.mode.name == "AI malfunction")
								var/datum/game_mode/malfunction/malf = SSticker.mode
								for (var/datum/mind/malfai in malf.malf_ai)
									if (T.mind == malfai)
										to_chat(U, "<span class='warning'><b>ERROR</b>:</span> Remote transfer interface disabled.")
										return
							if(T.stat)//If the ai is dead/dying.
								to_chat(U, "<span class='warning'><b>ERROR</b>:</span> [T.name] data core is corrupted. Unable to install.")
							else
								new /obj/structure/AIcore/deactivated(T.loc)
								T.aiRestorePowerRoutine = 0
								T.control_disabled = 1
								T.aiRadio.disabledAi = 1
								T.loc = C
								C.AI = T
								T.cancel_camera()
								to_chat(T, "You have been downloaded to a mobile storage device. Remote device connection severed.")
								to_chat(U, "<span class='notice'><b>Transfer successful</b>:</span> [T.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory.")

			if("INACTIVE")//Inactive AI object.
				var/obj/structure/AIcore/deactivated/T = target
				switch(interaction)
					if("AICARD")
						var/obj/item/device/aicard/C = src
						var/mob/living/silicon/ai/A = locate() in C//I love locate(). Best proc ever.
						if(A)//If AI exists on the card. Else nothing since both are empty.
							A.control_disabled = 0
							A.aiRadio.disabledAi = 0
							A.loc = T.loc//To replace the terminal.
							C.icon_state = "aicard"
							C.name = "inteliCard"
							C.cut_overlays()
							A.cancel_camera()
							to_chat(A, "You have been uploaded to a stationary terminal. Remote device connection restored.")
							to_chat(U, "<span class='notice'><b>Transfer successful</b>:</span> [A.name] ([rand(1000,9999)].exe) installed and executed succesfully. Local copy has been removed.")
							qdel(T)
					if("NINJASUIT")
						var/obj/item/clothing/suit/space/space_ninja/C = src
						var/mob/living/silicon/ai/A = C.AI
						if(A)
							A.control_disabled = 0
							C.AI = null
							A.loc = T.loc
							A.cancel_camera()
							to_chat(A, "You have been uploaded to a stationary terminal. Remote device connection restored.")
							to_chat(U, "<span class='notice'><b>Transfer successful</b>:</span> [A.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
							qdel(T)
			if("AIFIXER")//AI Fixer terminal.
				var/obj/machinery/computer/aifixer/T = target
				switch(interaction)
					if("AICARD")
						var/obj/item/device/aicard/C = src
						if(!T.contents.len)
							if (!C.contents.len)
								to_chat(U, "No AI to copy over!")//Well duh
							else for(var/mob/living/silicon/ai/A in C)
								C.icon_state = "aicard"
								C.name = "inteliCard"
								C.cut_overlays()
								A.loc = T
								T.occupier = A
								A.control_disabled = 1
								if (A.stat == DEAD)
									T.add_overlay(image('icons/obj/computer.dmi', "ai-fixer-404"))
								else
									T.add_overlay(image('icons/obj/computer.dmi', "ai-fixer-full"))
								T.cut_overlay(image('icons/obj/computer.dmi', "ai-fixer-empty"))
								A.cancel_camera()
								to_chat(A, "You have been uploaded to a stationary terminal. Sadly, there is no remote access from here.")
								to_chat(U, "<span class='notice'><b>Transfer successful</b>:</span> [A.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
						else
							if(!C.contents.len && T.occupier && !T.active)
								C.name = "inteliCard - [T.occupier.name]"
								T.add_overlay(image('icons/obj/computer.dmi', "ai-fixer-empty"))
								if (T.occupier.stat == DEAD)
									C.icon_state = "aicard-404"
									T.cut_overlay(image('icons/obj/computer.dmi', "ai-fixer-404"))
								else
									C.icon_state = "aicard-full"
									T.cut_overlay(image('icons/obj/computer.dmi', "ai-fixer-full"))
								to_chat(T.occupier, "You have been downloaded to a mobile storage device. Still no remote access.")
								to_chat(U, "<span class='notice'><b>Transfer successful</b>:</span> [T.occupier.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory.")
								T.occupier.loc = C
								T.occupier.cancel_camera()
								T.occupier = null
							else if (C.contents.len)
								to_chat(U, "<span class='warning'><b>ERROR</b>:</span> Artificial intelligence detected on terminal.")
							else if (T.active)
								to_chat(U, "<span class='warning'><b>ERROR</b>:</span> Reconstruction in progress.")
							else if (!T.occupier)
								to_chat(U, "<span class='warning'><b>ERROR</b>:</span> Unable to locate artificial intelligence.")
					if("NINJASUIT")
						var/obj/item/clothing/suit/space/space_ninja/C = src
						if(!T.contents.len)
							if (!C.AI)
								to_chat(U, "No AI to copy over!")
							else
								var/mob/living/silicon/ai/A = C.AI
								A.loc = T
								T.occupant = A
								C.AI = null
								A.control_disabled = 1
								T.add_overlay(image('icons/obj/computer.dmi', "ai-fixer-full"))
								T.cut_overlay(image('icons/obj/computer.dmi', "ai-fixer-empty"))
								A.cancel_camera()
								to_chat(A, "You have been uploaded to a stationary terminal. Sadly, there is no remote access from here.")
								to_chat(U, "<span class='notice'><b>Transfer successful</b>:</span> [A.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
						else
							if(!C.AI && T.occupant && !T.active)
								if (T.occupant.stat)
									to_chat(U, "<span class='warning'><b>ERROR</b>:</span> [T.occupant.name] data core is corrupted. Unable to install.")
								else
									T.add_overlay(image('icons/obj/computer.dmi', "ai-fixer-empty"))
									T.cut_overlay(image('icons/obj/computer.dmi', "ai-fixer-full"))
									to_chat(T.occupant, "You have been downloaded to a mobile storage device. Still no remote access.")
									to_chat(U, "<span class='notice'><b>Transfer successful</b>:</span> [T.occupant.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory.")
									T.occupant.loc = C
									T.occupant.cancel_camera()
									T.occupant = null
							else if (C.AI)
								to_chat(U, "<span class='warning'><b>ERROR</b>:</span> Artificial intelligence detected on terminal.")
							else if (T.active)
								to_chat(U, "<span class='warning'><b>ERROR</b>:</span> Reconstruction in progress.")
							else if (!T.occupant)
								to_chat(U, "<span class='warning'><b>ERROR</b>:</span> Unable to locate artificial intelligence.")
			if("NINJASUIT")//Ninjasuit
				var/obj/item/clothing/suit/space/space_ninja/T = target
				switch(interaction)
					if("AICARD")
						var/obj/item/device/aicard/C = src
						if(T.s_initialized&&U==T.affecting)//If the suit is initialized and the actor is the user.

							var/mob/living/silicon/ai/A_T = locate() in C//Determine if there is an AI on target card. Saves time when checking later.
							var/mob/living/silicon/ai/A = T.AI//Deterine if there is an AI in suit.

							if(A)//If the host AI card is not empty.
								if(A_T)//If there is an AI on the target card.
									to_chat(U, "<span class='warning'><b>ERROR</b>:</span> [A_T.name] already installed. Remove [A_T.name] to install a new one.")
								else
									A.loc = C//Throw them into the target card. Since they are already on a card, transfer is easy.
									C.name = "inteliCard - [A.name]"
									C.icon_state = "aicard-full"
									T.AI = null
									A.cancel_camera()
									to_chat(A, "You have been uploaded to a mobile storage device.")
									to_chat(U, "<span class='notice'><b>SUCCESS</b>:</span> [A.name] ([rand(1000,9999)].exe) removed from host and stored within local memory.")
							else//If host AI is empty.
								if(C.flush)//If the other card is flushing.
									to_chat(U, "<span class='warning'><b>ERROR</b>:</span> AI flush is in progress, cannot execute transfer protocol.")
								else
									if(A_T&&!A_T.stat)//If there is an AI on the target card and it's not inactive.
										A_T.loc = T//Throw them into suit.
										C.icon_state = "aicard"
										C.name = "inteliCard"
										C.cut_overlays()
										T.AI = A_T
										A_T.cancel_camera()
										to_chat(A_T, "You have been uploaded to a mobile storage device.")
										to_chat(U, "<span class='notice'><b>SUCCESS</b>:</span> [A_T.name] ([rand(1000,9999)].exe) removed from local memory and installed to host.")
									else if(A_T)//If the target AI is dead. Else just go to return since nothing would happen if both are empty.
										to_chat(U, "<span class='warning'><b>ERROR</b>:</span> [A_T.name] data core is corrupted. Unable to install.")
	else
		to_chat(U, "<span class='warning'><b>ERROR</b>:</span> AI flush is in progress, cannot execute transfer protocol.")
	return

/client/proc/empty_ai_core_toggle_latejoin()
	set name = "Toggle AI Core Latejoin"
	set category = "Admin"

	var/list/cores = list()
	for(var/obj/structure/AIcore/deactivated/D in aicore_deactivated_list)
		cores["[D] ([D.loc.loc])"] = D

	var/id = input("Which core?", "Toggle AI Core Latejoin", null) as null|anything in cores
	if(!id) return

	var/obj/structure/AIcore/deactivated/D = cores[id]
	if(!D) return

	if(D in empty_playable_ai_cores)
		empty_playable_ai_cores -= D
		to_chat(src, "\The [id] is now <font color=\"#ff0000\">not available</font> for latejoining AIs.")
	else
		empty_playable_ai_cores += D
		to_chat(src, "\The [id] is now <font color=\"#008000\">available</font> for latejoining AIs.")

	message_admins("[key_name_admin(usr)] toggled AI Core latejoin.", 1)
