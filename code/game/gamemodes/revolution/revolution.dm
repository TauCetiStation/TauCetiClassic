// To add a rev to the list of revolutionaries, make sure it's rev (with if(SSticker.mode.name == "revolution)),
// then call SSticker.mode:add_revolutionary(_THE_PLAYERS_MIND_)
// nothing else needs to be done, as that proc will check if they are a valid target.
// Just make sure the converter is a head before you call it!
// To remove a rev (from brainwashing or w/e), call SSticker.mode:remove_revolutionary(_THE_PLAYERS_MIND_),
// this will also check they're not a head, so it can just be called freely
// If the rev icons start going wrong for some reason, SSticker.mode:update_all_rev_icons() can be called to correct them.
// If the game somtimes isn't registering a win properly, then SSticker.mode.check_win() isn't being called somewhere.

/datum/game_mode
	var/list/datum/mind/head_revolutionaries = list()
	var/list/datum/mind/revolutionaries = list()

/datum/game_mode/revolution
	name = "revolution"
	config_tag = "revolution"
	role_type = ROLE_REV
	restricted_jobs = list("Security Cadet", "Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Internal Affairs Agent")
	required_players = 4
	required_players_secret = 20
	required_enemies = 3
	recommended_enemies = 3

	votable = 0


	uplink_welcome = "AntagCorp Uplink Console:"
	uplink_uses = 20

	var/finished = 0
	var/checkwin_counter = 0
	var/max_headrevs = 3

///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/revolution/announce()
	to_chat(world, "<B>The current game mode is - Revolution!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a revolution!<BR>\nRevolutionaries - Kill the Captain, HoP, HoS, CE, RD and CMO. Convert other crewmembers (excluding the heads of staff, and security officers) to your cause by flashing them. Protect your leaders.<BR>\nPersonnel - Protect the heads of staff. Kill the leaders of the revolution, and brainwash the other revolutionaries (by beating them in the head).</B>")


///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/head_check = 0
	for(var/mob/dead/new_player/player in player_list)
		if(player.mind.assigned_role in command_positions)
			head_check = 1
			break

	for(var/datum/mind/player in antag_candidates)
		for(var/job in restricted_jobs)//Removing heads and such from the list
			if(player.assigned_role == job)
				antag_candidates -= player

	for (var/i=1 to max_headrevs)
		if (antag_candidates.len==0)
			break
		var/datum/mind/lenin = pick(antag_candidates)
		antag_candidates -= lenin
		head_revolutionaries += lenin

	if((head_revolutionaries.len==0)||(!head_check))
		return 0

	return 1


/datum/game_mode/revolution/post_setup()
	var/list/heads = get_living_heads()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		if(!config.objectives_disabled)
			for(var/datum/mind/head_mind in heads)
				var/datum/objective/mutiny/rev_obj = new
				rev_obj.owner = rev_mind
				rev_obj.target = head_mind
				rev_obj.explanation_text = "Assassinate [head_mind.name], the [head_mind.assigned_role]."
				rev_mind.objectives += rev_obj

		spawn(rand(10,100))
		//	equip_traitor(rev_mind.current, 1) //changing how revs get assigned their uplink so they can get PDA uplinks. --NEO
		//	Removing revolutionary uplinks.	-Pete
			equip_revolutionary(rev_mind.current)
			update_all_rev_icons()

	for(var/datum/mind/rev_mind in head_revolutionaries)
		greet_revolutionary(rev_mind)
	modePlayer += head_revolutionaries
	if(SSshuttle)
		SSshuttle.always_fake_recall = 1
	return ..()


/datum/game_mode/revolution/process()
	checkwin_counter++
	if(checkwin_counter >= 5)
		if(!finished)
			SSticker.mode.check_win()
		checkwin_counter = 0
	return 0


/datum/game_mode/proc/forge_revolutionary_objectives(datum/mind/rev_mind)
	if(!config.objectives_disabled)
		var/list/heads = get_living_heads()
		for(var/datum/mind/head_mind in heads)
			var/datum/objective/mutiny/rev_obj = new
			rev_obj.owner = rev_mind
			rev_obj.target = head_mind
			rev_obj.explanation_text = "Assassinate or exile [head_mind.name], the [head_mind.assigned_role]."
			rev_mind.objectives += rev_obj

/datum/game_mode/proc/greet_revolutionary(datum/mind/rev_mind, you_are=1)
	var/obj_count = 1
	if (you_are)
		to_chat(rev_mind.current, "<span class='notice'>You are a member of the revolutionaries' leadership!</span>")
	if(!config.objectives_disabled)
		for(var/datum/objective/objective in rev_mind.objectives)
			to_chat(rev_mind.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			rev_mind.special_role = "Head Revolutionary"
			obj_count++
	else
		to_chat(rev_mind.current, "<font color=blue>Within the rules,</font> try to act as an opposing force to the crew. Further RP and try to make sure other players have fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>")

/////////////////////////////////////////////////////////////////////////////////
//This are equips the rev heads with their gear, and makes the clown not clumsy//
/////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/equip_revolutionary(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	if (mob.mind)
		if (mob.mind.assigned_role == "Clown")
			to_chat(mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			mob.mutations.Remove(CLUMSY)


	var/obj/item/device/flash/T = new(mob)
	var/obj/item/toy/crayon/spraycan/R = new(mob)

	var/list/slots = list (
		"backpack" = SLOT_IN_BACKPACK,
		"left pocket" = SLOT_L_STORE,
		"right pocket" = SLOT_R_STORE,
		"left hand" = SLOT_L_HAND,
		"right hand" = SLOT_R_HAND,
	)
	var/where = mob.equip_in_one_of_slots(T, slots)
	mob.equip_in_one_of_slots(R,slots)

	mob.update_icons()

	if (!where)
		to_chat(mob, "The Syndicate were unfortunately unable to get you a flash.")
	else
		to_chat(mob, "The flash in your [where] will help you to persuade the crew to join your cause.")
		return 1

//////////////////////////////////////
//Checks if the revs have won or not//
//////////////////////////////////////
/datum/game_mode/revolution/check_win()
	if(check_rev_victory())
		finished = 1
	else if(check_heads_victory())
		finished = 2
	return

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/revolution/check_finished()
	if(config.continous_rounds)
		if(finished)
			if(SSshuttle)
				SSshuttle.always_fake_recall = 0
		return ..()
	if(finished)
		return 1
	else
		return 0

///////////////////////////////////////////////////
//Deals with converting players to the revolution//
///////////////////////////////////////////////////
/datum/game_mode/proc/add_revolutionary(datum/mind/rev_mind)
	if(rev_mind.assigned_role in command_positions)
		return 0
	var/mob/living/carbon/human/H = rev_mind.current//Check to see if the potential rev is implanted
	if(ismindshielded(H))
		return 0
	if((rev_mind in revolutionaries) || (rev_mind in head_revolutionaries))
		return 0
	revolutionaries += rev_mind
	if(iscarbon(rev_mind.current))
		var/mob/living/carbon/carbon_mob = rev_mind.current
		carbon_mob.silent = max(carbon_mob.silent, 5)
	rev_mind.current.Stun(5)
	to_chat(rev_mind.current, "<span class='warning'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT></span>")
	rev_mind.special_role = "Revolutionary"
	if(config.objectives_disabled)
		to_chat(rev_mind.current, "<font color=blue>Within the rules,</font> try to act as an opposing force to the crew. Further RP and try to make sure other players have fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>")
	update_all_rev_icons()
	return 1
//////////////////////////////////////////////////////////////////////////////
//Deals with players being converted from the revolution (Not a rev anymore)//  // Modified to handle borged MMIs.  Accepts another var if the target is being borged at the time  -- Polymorph.
//////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/remove_revolutionary(datum/mind/rev_mind , beingborged)
	if(rev_mind in revolutionaries)
		revolutionaries -= rev_mind
		rev_mind.special_role = null
		rev_mind.current.hud_updateflag |= 1 << SPECIALROLE_HUD

		if(beingborged)
			to_chat(rev_mind.current, "<span class='warning'><FONT size = 3><B>The frame's firmware detects and deletes your neural reprogramming!  You remember nothing from the moment you were flashed until now.</B></FONT></span>")

		else
			to_chat(rev_mind.current, "<span class='warning'><FONT size = 3><B>You have been brainwashed! You are no longer a revolutionary! Your memory is hazy from the time you were a rebel...the only thing you remember is the name of the one who brainwashed you...</B></FONT></span>")

		update_rev_icons_removed(rev_mind)
		for(var/mob/living/M in view(rev_mind.current))
			if(beingborged)
				to_chat(rev_mind.current, "<span class='warning'><FONT size = 3><B>The frame's firmware detects and deletes your neural reprogramming!  You remember nothing but the name of the one who flashed you.</B></FONT></span>")
				message_admins("[key_name_admin(rev_mind.current)] <A HREF='?_src_=holder;adminmoreinfo=\ref[rev_mind.current]'>?</A> has been borged while being a member of the revolution.")

			else
				to_chat(M, "[rev_mind.current] looks like they just remembered their real allegiance!")


/////////////////////////////////////////////////////////////////////////////////////////////////
//Keeps track of players having the correct icons////////////////////////////////////////////////
//CURRENTLY CONTAINS BUGS:///////////////////////////////////////////////////////////////////////
//-PLAYERS THAT HAVE BEEN REVS FOR AWHILE OBTAIN THE BLUE ICON WHILE STILL NOT BEING A REV HEAD//
// -Possibly caused by cloning of a standard rev/////////////////////////////////////////////////
//-UNCONFIRMED: DECONVERTED REVS NOT LOSING THEIR ICON PROPERLY//////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/update_all_rev_icons()
	spawn(0)
		for(var/datum/mind/head_rev_mind in head_revolutionaries)
			if(head_rev_mind.current)
				if(head_rev_mind.current.client)
					for(var/image/I in head_rev_mind.current.client.images)
						if(I.icon_state == "rev" || I.icon_state == "rev_head")
							qdel(I)

		for(var/datum/mind/rev_mind in revolutionaries)
			if(rev_mind.current)
				if(rev_mind.current.client)
					for(var/image/I in rev_mind.current.client.images)
						if(I.icon_state == "rev" || I.icon_state == "rev_head")
							qdel(I)

		for(var/datum/mind/head_rev in head_revolutionaries)
			if(head_rev.current)
				if(head_rev.current.client)
					for(var/datum/mind/rev in revolutionaries)
						if(rev.current)
							var/I = image('icons/mob/mob.dmi', loc = rev.current, icon_state = "rev")
							head_rev.current.client.images += I
					for(var/datum/mind/head_rev_1 in head_revolutionaries)
						if(head_rev_1.current)
							var/I = image('icons/mob/mob.dmi', loc = head_rev_1.current, icon_state = "rev_head")
							head_rev.current.client.images += I

		for(var/datum/mind/rev in revolutionaries)
			if(rev.current)
				if(rev.current.client)
					for(var/datum/mind/head_rev in head_revolutionaries)
						if(head_rev.current)
							var/I = image('icons/mob/mob.dmi', loc = head_rev.current, icon_state = "rev_head")
							rev.current.client.images += I
					for(var/datum/mind/rev_1 in revolutionaries)
						if(rev_1.current)
							var/I = image('icons/mob/mob.dmi', loc = rev_1.current, icon_state = "rev")
							rev.current.client.images += I

////////////////////////////////////////////////////
//Keeps track of converted revs icons///////////////
//Refer to above bugs. They may apply here as well//
////////////////////////////////////////////////////
/datum/game_mode/proc/update_rev_icons_added(datum/mind/rev_mind)
	spawn(0)
		for(var/datum/mind/head_rev_mind in head_revolutionaries)

			//Tagging the new rev for revheads to see
			if(head_rev_mind.current)
				if(head_rev_mind.current.client)
					var/I
					if(rev_mind in head_revolutionaries) //If the new rev is a head rev
						I = image('icons/mob/mob.dmi', loc = rev_mind.current, icon_state = "rev_head")
					else
						I = image('icons/mob/mob.dmi', loc = rev_mind.current, icon_state = "rev")
					head_rev_mind.current.client.images += I

			//Tagging the revheads for new rev to see
			if(rev_mind.current)
				if(rev_mind.current.client)
					var/image/J = image('icons/mob/mob.dmi', loc = head_rev_mind.current, icon_state = "rev_head")
					rev_mind.current.client.images += J

		for(var/datum/mind/rev_mind_1 in revolutionaries)

			//Tagging the new rev for fellow revs to see
			if(rev_mind_1.current)
				if(rev_mind_1.current.client)
					var/I
					if(rev_mind in head_revolutionaries) //If the new rev is a head rev
						I = image('icons/mob/mob.dmi', loc = rev_mind.current, icon_state = "rev_head")
					else
						I = image('icons/mob/mob.dmi', loc = rev_mind.current, icon_state = "rev")
					rev_mind_1.current.client.images += I

			//Tagging fellow revs for the new rev to see
			if(rev_mind.current)
				if(rev_mind.current.client)
					var/image/J = image('icons/mob/mob.dmi', loc = rev_mind_1.current, icon_state = "rev")
					rev_mind.current.client.images += J

///////////////////////////////////
//Keeps track of deconverted revs//
///////////////////////////////////
/datum/game_mode/proc/update_rev_icons_removed(datum/mind/rev_mind)
	spawn(0)
		for(var/datum/mind/head_rev_mind in head_revolutionaries)
			if(head_rev_mind.current)
				if(head_rev_mind.current.client)
					for(var/image/I in head_rev_mind.current.client.images)
						if((I.icon_state == "rev" || I.icon_state == "rev_head") && I.loc == rev_mind.current)
							qdel(I)

		for(var/datum/mind/rev_mind_1 in revolutionaries)
			if(rev_mind_1.current)
				if(rev_mind_1.current.client)
					for(var/image/I in rev_mind_1.current.client.images)
						if((I.icon_state == "rev" || I.icon_state == "rev_head") && I.loc == rev_mind.current)
							qdel(I)

		if(rev_mind.current)
			if(rev_mind.current.client)
				for(var/image/I in rev_mind.current.client.images)
					if(I.icon_state == "rev" || I.icon_state == "rev_head")
						qdel(I)

//////////////////////////
//Checks for rev victory//
//////////////////////////
/datum/game_mode/revolution/proc/check_rev_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/objective/objective in rev_mind.objectives)
			if(!(objective.check_completion()))
				return 0

		return 1

/////////////////////////////
//Checks for a head victory//
/////////////////////////////
/datum/game_mode/revolution/proc/check_heads_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		var/turf/T = get_turf(rev_mind.current)
		if((rev_mind) && (rev_mind.current) && (rev_mind.current.stat != DEAD) && T && is_station_level(T.z))
			if(ishuman(rev_mind.current))
				return 0
	return 1

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/declare_completion()
	if(name == "rp-revolution") // hack, we should move game_mode/revolution/rp_revolution to game_mode/rp_revolution
		return ..()
	completion_text += "<h3>Revolution mode resume:</h3>"
	if(!config.objectives_disabled)
		if(finished == 1)
			mode_result = "win - heads killed"
			feedback_set_details("round_end_result",mode_result)
			completion_text += "<br><span style='color: red; font-weight: bold;'>The heads of staff were killed or exiled! The revolutionaries win!</span>"
		else if(finished == 2)
			mode_result = "loss - rev heads killed"
			feedback_set_details("round_end_result",mode_result)
			completion_text += "<br><span style='color: red; font-weight: bold;'>The heads of staff managed to stop the revolution!</span>"
	var/num_revs = 0
	for(var/mob/living/carbon/mob in alive_mob_list)
		if(mob.mind)
			if((mob.mind in head_revolutionaries) || (mob.mind in revolutionaries))
				num_revs++
	completion_text += "<br>[TAB]Command's Approval Rating: <b>[100 - round((num_revs/alive_mob_list.len)*100, 0.1)]%</b>" // % of loyal crew
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_revolution()
	var/list/targets = list()

	var/text = ""
	if(head_revolutionaries.len || istype(SSticker.mode,/datum/game_mode/revolution))
		text += printlogo("rev_head", "head revolutionaries")

		for(var/datum/mind/headrev in head_revolutionaries)
			if(headrev.current)
				var/icon/flat = getFlatIcon(headrev.current,exact=1)
				end_icons += flat
				var/tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[headrev.key]</b> was <b>[headrev.name]</b> ("}
				if(headrev.current.stat == DEAD)
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else if(!is_station_level(headrev.current.z))
					text += "fled the station"
				else
					text += "survived the revolution"
				if(headrev.current.real_name != headrev.name)
					text += " as [headrev.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "gibbearcore")
				end_icons += sprotch
				var/tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[headrev.key]</b> was <b>[headrev.name]</b> ("}
				text += "body destroyed"
			text += ")"
			if(headrev.total_TC)
				if(headrev.spent_TC)
					text += "<br><b>TC Remaining:</b> [headrev.total_TC - headrev.spent_TC]/[headrev.total_TC]"
					text += "<br><b>The tools used by the Head Revolutionary were:</b>"
					for(var/entry in headrev.uplink_items_bought)
						text += "<br>[entry]"
				else
					text += "<br>The Head Revolutionary was a smooth operator this round (did not purchase any uplink items)."

			for(var/datum/objective/mutiny/objective in headrev.objectives)
				targets |= objective.target


	if(revolutionaries.len || istype(SSticker.mode,/datum/game_mode/revolution))
		text += "<br>"
		text += printlogo("rev-logo", "head revolutionaries")
		var/icon/logo2 = icon('icons/mob/mob.dmi', "rev-logo")
		end_icons += logo2
		var/tempstate = end_icons.len
		text += {"<br><img src="logo_[tempstate].png"> <b>The revolutionaries were:</b> <img src="logo_[tempstate].png">"}

		for(var/datum/mind/rev in revolutionaries)
			if(rev.current)
				var/icon/flat = getFlatIcon(rev.current,exact=1)
				end_icons += flat
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[rev.key]</b> was <b>[rev.name]</b> ("}
				if(rev.current.stat == DEAD || isbrain(rev.current))
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else if(!is_station_level(rev.current.z))
					text += "fled the station"
				else
					text += "survived the revolution"
				if(rev.current.real_name != rev.name)
					text += " as [rev.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "gibbearcore")
				end_icons += sprotch
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[rev.key]</b> was <b>[rev.name]</b> ("}
				text += "body destroyed"
			text += ")"


	if( head_revolutionaries.len || revolutionaries.len || istype(SSticker.mode,/datum/game_mode/revolution) )
		text += "<br>"
		text += printlogo("nano-logo", "heads of staff")

		var/list/heads = get_all_heads()
		for(var/datum/mind/head in heads)
			var/target = (head in targets)
			if(target)
				text += "<span style='color: red'>"
			if(head.current)
				var/icon/flat = getFlatIcon(head.current,exact=1)
				end_icons += flat
				var/tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[head.key]</b> was <b>[head.name]</b> ("}
				if(head.current.stat == DEAD || isbrain(head.current))
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else if(!is_station_level(head.current.z))
					text += "fled the station"
				else
					text += "survived the revolution"
				if(head.current.real_name != head.name)
					text += " as [head.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "gibbearcore")
				end_icons += sprotch
				var/tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[head.key]</b> was <b>[head.name]</b> ("}
				text += "body destroyed"
			text += ")"
			if(target)
				text += "</span>"

	if(text)
		antagonists_completion += list(list("mode" = "revolution", "html" = text))
		text = "<div class='block'>[text]</div>"

	return text
