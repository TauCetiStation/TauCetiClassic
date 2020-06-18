/obj/item/device/aicard
	name = "inteliCard"
	icon = 'icons/obj/pda.dmi'
	icon_state = "aicard" // aicard-full
	item_state = "electronic"
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_FLAGS_BELT
	var/flush = null
	origin_tech = "programming=4;materials=4"


/obj/item/device/aicard/attack(mob/living/silicon/ai/M, mob/user)
	if(!istype(M, /mob/living/silicon/ai))//If target is not an AI.
		return ..()

	M.log_combat(user, "carded via [name]")

	transfer_ai("AICORE", "AICARD", M, user)
	return

/obj/item/device/aicard/attack(mob/living/silicon/decoy/M, mob/user)
	if (!istype (M, /mob/living/silicon/decoy))
		return ..()
	else
		M.death()
		to_chat(user, "<b>ERROR ERROR ERROR</b>")

/obj/item/device/aicard/attack_self(mob/user)
	if (!in_range(src, user))
		return
	user.set_machine(src)
	var/dat = "<TT><B>Intelicard</B><BR>"
	var/laws
	for(var/mob/living/silicon/ai/A in src)
		dat += "Stored AI: [A.name]<br>System integrity: [(A.health+100)/2]%<br>"

		for (var/index = 1, index <= A.laws.ion.len, index++)
			var/law = A.laws.ion[index]
			if (length(law) > 0)
				var/num = ionnum()
				laws += "[num]. [law]"

		if (A.laws.zeroth)
			laws += "0: [A.laws.zeroth]<BR>"

		var/number = 1
		for (var/index = 1, index <= A.laws.inherent.len, index++)
			var/law = A.laws.inherent[index]
			if (length(law) > 0)
				laws += "[number]: [law]<BR>"
				number++

		for (var/index = 1, index <= A.laws.supplied.len, index++)
			var/law = A.laws.supplied[index]
			if (length(law) > 0)
				laws += "[number]: [law]<BR>"
				number++

		dat += "Laws:<br>[laws]<br>"

		if (A.stat == DEAD)
			dat += "<b>AI nonfunctional</b>"
		else
			if (!src.flush)
				dat += {"<A href='byond://?src=\ref[src];choice=Wipe'>Wipe AI</A>"}
			else
				dat += "<b>Wipe in progress</b>"
			dat += "<br>"
			dat += {"<a href='byond://?src=\ref[src];choice=Wireless'>[A.control_disabled ? "Enable" : "Disable"] Wireless Activity</a>"}
			dat += "<br>"
			dat += "Subspace Transceiver is: [A.aiRadio.disabledAi ? "Disabled" : "Enabled"]"
			dat += "<br>"
			dat += {"<a href='byond://?src=\ref[src];choice=Radio'>[A.aiRadio.disabledAi ? "Enable" : "Disable"] Subspace Transceiver</a>"}
			dat += "<br>"
			dat += {"<a href='byond://?src=\ref[src];choice=Close'> Close</a>"}
	user << browse(dat, "window=aicard")
	onclose(user, "aicard")
	return

/obj/item/device/aicard/Topic(href, href_list)
	var/mob/U = usr
	if (!in_range(src, U)||U.machine!=src)//If they are not in range of 1 or less or their machine is not the card (ie, clicked on something else).
		U << browse(null, "window=aicard")
		U.unset_machine()
		return

	add_fingerprint(U)
	U.set_machine(src)

	switch(href_list["choice"])//Now we switch based on choice.
		if ("Close")
			U << browse(null, "window=aicard")
			U.unset_machine()
			return

		if ("Radio")
			for(var/mob/living/silicon/ai/A in src)
				A.aiRadio.disabledAi = !A.aiRadio.disabledAi
				to_chat(A, "Your Subspace Transceiver has been: [A.aiRadio.disabledAi ? "disabled" : "enabled"]")
				to_chat(U, "You [A.aiRadio.disabledAi ? "Disable" : "Enable"] the AI's Subspace Transceiver")

		if ("Wipe")
			var/confirm = alert("Are you sure you want to wipe this card's memory? This cannot be undone once started.", "Confirm Wipe", "Yes", "No")
			if(confirm == "Yes")
				if(isnull(src)||!in_range(src, U)||U.machine!=src)
					U << browse(null, "window=aicard")
					U.unset_machine()
					return
				else
					flush = 1
					for(var/mob/living/silicon/ai/A in src)
						A.suiciding = 1
						to_chat(A, "Your core files are being wiped!")
						while (A.stat != DEAD)
							A.adjustOxyLoss(2)
							A.updatehealth()
							sleep(10)
						flush = 0

		if ("Wireless")
			for(var/mob/living/silicon/ai/A in src)
				A.control_disabled = !A.control_disabled
				to_chat(A, "The intelicard's wireless port has been [A.control_disabled ? "disabled" : "enabled"]!")
				if (A.control_disabled)
					cut_overlay(image('icons/obj/pda.dmi', "aicard-on"))
				else
					add_overlay(image('icons/obj/pda.dmi', "aicard-on"))
	attack_self(U)





