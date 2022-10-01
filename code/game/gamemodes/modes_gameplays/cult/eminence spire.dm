//Used to nominate oneself or ghosts for the role of Eminence.
/obj/structure/eminence_spire
	name = "eminence spire"
	desc = "This spire is used to become the Eminence, who functions as an invisible leader of the cult. Activate it to nominate yourself or propose that the Eminence should be \
	selected from available ghosts. Once an Eminence is selected, they can't normally be changed."
	icon = 'icons/effects/64x64.dmi'
	icon_state = "spire"
	max_integrity = 400
	var/mob/eminence_nominee
	var/selection_timer //Timer ID; this is canceled if the vote is canceled
	var/kingmaking

/proc/hierophant_message(message, servantsonly, atom/target)
	if(!message)
		return FALSE
	for(var/M in mob_list)
		if(!servantsonly && isobserver(M))
			if(target)
				var/link = FOLLOW_LINK(M, target)
				to_chat(M, "[link] [message]")
			else
				to_chat(M, message)
		else if(iscultist(M))
			to_chat(M, message)
	return TRUE

//Used to nominate oneself or ghosts for the role of Eminence.
/obj/structure/eminence_spire/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!iscultist(user))
		to_chat(user, "<span class='notice'>You can tell how powerful [src] is; you know better than to touch it.</span>")
		return
	if(kingmaking)
		return

	if(!cult_religion)
		to_chat(user, "<span class='warning'>The Ark isn't active!</span>")
		return
	if(cult_religion.eminence)
		to_chat(user, "<span class='warning'>There's already an Eminence!</span>")
		return
	if(eminence_nominee) //This could be one large proc, but is split into three for ease of reading
		if(eminence_nominee == user)
			cancelation(user)
		else
			objection(user)
	else
		nomination(user)

//Used to nominate oneself or ghosts for the role of Eminence.
/obj/structure/eminence_spire/attack_animal(mob/living/simple_animal/user)
	if(!iscultist(user))
		..()
	else
		to_chat(user, "<span class='warning'>You feel the omniscient gaze turn into a puzzled frown. Perhaps you should just stick to building.</span>")
		return

//Used to nominate oneself or ghosts for the role of Eminence.
/obj/structure/eminence_spire/proc/nomination(mob/living/nominee) //A user is nominating themselves or ghosts to become Eminence
	var/nomination_choice = alert(nominee, "Who would you like to nominate?", "Eminence Nomination", "Nominate Yourself", "Nominate Ghosts", "Cancel")
	if(!iscultist(nominee) || eminence_nominee)
		return
	switch(nomination_choice)
		if("Cancel")
			return
		if("Nominate Yourself")
			eminence_nominee = nominee
			hierophant_message("<span class='cult'><b>[nominee] nominates themselves as the Eminence!</b> You may object by interacting with the eminence spire. The vote will otherwise pass in 30 seconds.</span>")
		if("Nominate Ghosts")
			eminence_nominee = "ghosts"
			hierophant_message("<span class='cult'><b>[nominee] proposes selecting an Eminence from ghosts!</b> You may object by interacting with the eminence spire. The vote will otherwise pass in 30 seconds.</span>")
	//for(var/mob/M in servants_and_ghosts())
	//	M.playsound_local(M, 'sound/machines/clockcult/ocularwarden-target.ogg', 50, FALSE)
	selection_timer = addtimer(CALLBACK(src, .proc/kingmaker), 30 SECONDS, TIMER_STOPPABLE)

//Used to nominate oneself or ghosts for the role of Eminence.
/obj/structure/eminence_spire/proc/objection(mob/living/wright)
	if(alert(wright, "Object to the selection of [eminence_nominee] as Eminence?", "Objection!", "Object", "Cancel") == "Cancel" || !iscultist(wright) || !eminence_nominee)
		return
	hierophant_message("<span class='cult'><b>[wright] objects to the nomination of [eminence_nominee]!</b> The eminence spire has been reset.</span>")
	//for(var/mob/M in servants_and_ghosts())
	//	M.playsound_local(M, 'sound/machines/clockcult/integration_cog_install.ogg', 50, FALSE)
	eminence_nominee = null
	deltimer(selection_timer)

//Returns a list of all servants of Ratvar and observers.
/proc/servants_and_ghosts()
	. = list()
	for(var/V in player_list)
		if(iscultist(V) || isobserver(V))
			. += V

//Used to nominate oneself or ghosts for the role of Eminence.
/obj/structure/eminence_spire/proc/cancelation(mob/living/cold_feet)
	if(tgui_alert(cold_feet, "Cancel your nomination?", "Cancel Nomination", list("Withdraw Nomination", "Cancel")) == "Cancel" || !iscultist(cold_feet) || !eminence_nominee)
		return
	hierophant_message("<span class='cult'><b>[eminence_nominee] has withdrawn their nomination!</b> The eminence spire has been reset.</span>")
	//for(var/mob/M in servants_and_ghosts())
	//	M.playsound_local(M, 'sound/machines/clockcult/integration_cog_install.ogg', 50, FALSE)
	eminence_nominee = null
	deltimer(selection_timer)

//Used to nominate oneself or ghosts for the role of Eminence.
/obj/structure/eminence_spire/proc/kingmaker()
	if(!eminence_nominee)
		return
	if(ismob(eminence_nominee))
		if(!eminence_nominee.client || !eminence_nominee.mind)
			hierophant_message("<span class='cult'><b>[eminence_nominee] somehow lost their sentience!</b> The eminence spire has been reset.</span>")
			//for(var/mob/M in servants_and_ghosts())
			//	M.playsound_local(M, 'sound/machines/clockcult/integration_cog_install.ogg', 50, FALSE)
			eminence_nominee = null
			return
		//playsound(eminence_nominee, 'sound/machines/clockcult/ark_damage.ogg', 50, FALSE)
		eminence_nominee.visible_message("<span class='warning'>A blast of darkness flows into [eminence_nominee], devouring them in an instant!</span>", \
		"<span class='userdanger'>All the darkness in the universe flowing into YOU</span>")
		for(var/obj/item/I in eminence_nominee)
			eminence_nominee.drop_item(get_turf(src))
		var/mob/camera/eminence/eminence = new(get_turf(src))
		eminence_nominee.mind.transfer_to(eminence)
		eminence_nominee.dust()
		hierophant_message("<span class='cult'>[eminence_nominee] has ascended into the Eminence!</span>")
	else if(eminence_nominee == "ghosts")
		kingmaking = TRUE
		hierophant_message("<span class='cult'><b>The eminence spire is now selecting a ghost to be the Eminence...</b></span>")
		var/list/candidates = pollGhostCandidates("Would you like to play as the servants' Eminence?", ROLE_CULTIST, null, ROLE_CULTIST, poll_time = 100)
		kingmaking = FALSE
		if(!length(candidates))
			//for(var/mob/M in servants_and_ghosts())
			//	M.playsound_local(M, 'sound/machines/clockcult/integration_cog_install.ogg', 50, FALSE)
			hierophant_message("<span class='cult'><b>No ghosts accepted the offer!</b> The eminence spire has been reset.</span>")
			eminence_nominee = null
			return
		visible_message("<span class='warning'>A blast of white-hot light spirals from [src] in waves!</span>")
		//playsound(src, 'sound/machines/clockcult/ark_damage.ogg', 50, FALSE)
		var/mob/camera/eminence/eminence = new(get_turf(src))
		eminence_nominee = pick(candidates)
		eminence.key = eminence_nominee.key
		hierophant_message("<span class='cult'>A ghost has ascended into the Eminence!</span>")
	for(var/mob/M in servants_and_ghosts())
		M.playsound_local(M, 'sound/antag/eminence_selected.ogg', VOL_EFFECTS_MASTER)
	eminence_nominee = null
