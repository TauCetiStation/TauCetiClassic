//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/datum/game_mode
	var/list/datum/mind/cult = list()

/proc/iscultist(mob/living/M)
	return istype(M) && M.mind && SSticker && SSticker.mode && (M.mind in SSticker.mode.cult)

/proc/is_convertable_to_cult(datum/mind/mind)
	if(!istype(mind))
		return FALSE
	if(ishuman(mind.current))
		if((mind.assigned_role in list("Captain", "Chaplain")))
			return FALSE
		if(mind.current.get_species() == GOLEM)
			return FALSE
	if(ismindshielded(mind.current))
		return FALSE
	return TRUE


/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	role_type = ROLE_CULTIST
	restricted_jobs = list("Security Cadet", "Chaplain","AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Internal Affairs Agent")
	protected_jobs = list()
	required_players = 5
	required_players_secret = 20

	required_enemies = 3
	recommended_enemies = 4

	votable = 0

	uplink_welcome = "Nar-Sie Uplink Console:"
	uplink_uses = 20

	restricted_species_flags = list(NO_BLOOD)

	var/datum/mind/sacrifice_target = null
	var/finished = 0

	var/list/startwords = list("blood","join","self","hell")

	var/list/objectives = list()
	var/list/sacrificed = list()

	var/eldergod = 1 //for the summon god objective
	var/eldertry = 0

	var/const/acolytes_needed = 5 //for the survive objective
	var/acolytes_survived = 0


/datum/game_mode/cult/announce()
	to_chat(world, "<B>The current game mode is - Cult!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a cult!<BR>\nCultists - complete your objectives. Convert crewmembers to your cause by using the convert rune. Remember - there is no you, there is only the cult.<BR>\nPersonnel - Do not let the cult succeed in its mission. Brainwashing them with the chaplain's bible reverts them to whatever CentCom-allowed faith they had.</B>")


/datum/game_mode/cult/pre_setup()
	if(!config.objectives_disabled)
		if(prob(50))
			objectives += "survive"
			objectives += "sacrifice"
		else
			objectives += "eldergod"
			objectives += "sacrifice"

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	for(var/datum/mind/player in antag_candidates)
		if(player.assigned_role in restricted_jobs)	//Removing heads and such from the list
			antag_candidates -= player

	for(var/cultists_number = 1 to recommended_enemies)
		if(!antag_candidates.len)
			break
		var/datum/mind/cultist = pick(antag_candidates)
		antag_candidates -= cultist
		cult += cultist

	return (cult.len >= required_enemies)


/datum/game_mode/cult/post_setup()
	modePlayer += cult
	if("sacrifice" in objectives)
		var/list/possible_targets = get_unconvertables()
		listclearnulls(possible_targets)

		if(!possible_targets.len)
			for(var/mob/living/carbon/human/player in player_list)
				if(player.mind && !(player.mind in cult))
					possible_targets += player.mind

		listclearnulls(possible_targets)

		if(length(possible_targets))
			sacrifice_target = pick(possible_targets)

	for(var/datum/mind/cult_mind in cult)
		equip_cultist(cult_mind.current)
		to_chat(cult_mind.current, "<span class = 'info'><b>You are a member of the <font color='red'>cult</font>!</b></span>")
		grant_runeword(cult_mind.current)
		if(!config.objectives_disabled)
			memoize_cult_objectives(cult_mind)
		else
			to_chat(cult_mind.current, "<span class ='blue'>Within the rules,</span> try to act as an opposing force to the crew. Further RP and try to make sure other players have fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>")
		cult_mind.special_role = "Cultist"
	update_all_cult_icons()

	return ..()


/datum/game_mode/cult/proc/memoize_cult_objectives(datum/mind/cult_mind)
	for(var/obj_count = 1,obj_count <= objectives.len,obj_count++)
		var/explanation
		switch(objectives[obj_count])
			if("survive")
				explanation = "Our knowledge must live on. Make sure at least [acolytes_needed] acolytes escape on the shuttle to spread their work on an another station."
			if("sacrifice")
				if(sacrifice_target)
					explanation = "Sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role]. You will need the sacrifice rune (Hell blood join) and three acolytes to do so."
				else
					explanation = "Free objective."
			if("eldergod")
				explanation = "Summon Nar-Sie via the use of the appropriate rune (Hell join self). It will only work if nine cultists stand on and around it."
		to_chat(cult_mind.current, "<B>Objective #[obj_count]</B>: [explanation]")
		cult_mind.memory += "<B>Objective #[obj_count]</B>: [explanation]<BR>"
	to_chat(cult_mind.current, "The convert rune is join blood self")
	cult_mind.memory += "The convert rune is join blood self<BR>"


/datum/game_mode/proc/equip_cultist(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	if (mob.mind)
		if (mob.mind.assigned_role == "Clown")
			to_chat(mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			mob.mutations.Remove(CLUMSY)


	var/obj/item/weapon/paper/talisman/supply/T = new(mob)
	var/list/slots = list (
		"backpack" = SLOT_IN_BACKPACK,
		"left pocket" = SLOT_L_STORE,
		"right pocket" = SLOT_R_STORE,
		"left hand" = SLOT_L_HAND,
		"right hand" = SLOT_R_HAND,
	)
	var/where = mob.equip_in_one_of_slots(T, slots)
	if (!where)
		to_chat(mob, "Unfortunately, you weren't able to get a talisman. This is very bad and you should adminhelp immediately.")
	else
		var/obj/item/weapon/paper/talisman/T2 = new(mob)
		T2.power = new /datum/cult/communicate(T2)
		mob.equip_in_one_of_slots(T2, slots)
		to_chat(mob, "You have a talisman in your [where], one that will help you start the cult on this station. Use it well and remember - there are others.")
		mob.update_icons()
		return 1


/datum/game_mode/cult/grant_runeword(mob/living/carbon/human/cult_mob, word)
	if (!word)
		if(length(startwords) > 0)
			word = pick_n_take(startwords)
	return ..(cult_mob, word)


/datum/game_mode/proc/grant_runeword(mob/living/carbon/human/cult_mob, word)
	if(!cultwords["travel"])
		runerandom()
	if (!word)
		word = pick(cultwords)
	var/wordexp = "[cultwords[word]] is [word]..."
	to_chat(cult_mob, "<span class = 'cult'>You remember one thing from the dark teachings of your master... <b>[wordexp]</b></span>")
	cult_mob.mind.store_memory("<B>You remember that</B> [wordexp]", 0)


/datum/game_mode/proc/add_cultist(datum/mind/cult_mind) //BASE
	if (!istype(cult_mind))
		return 0
	if(!(cult_mind in cult) && is_convertable_to_cult(cult_mind))
		cult_mind.current.Paralyse(5)
		cult += cult_mind
		update_cult_icons_added(cult_mind)
		return 1


/datum/game_mode/cult/add_cultist(datum/mind/cult_mind) //INHERIT
	if (!..(cult_mind))
		return
	if (!config.objectives_disabled)
		memoize_cult_objectives(cult_mind)


/datum/game_mode/proc/remove_cultist(datum/mind/cult_mind, show_message = 1)
	if(cult_mind in cult)
		cult -= cult_mind
		cult_mind.current.Paralyse(5)
		to_chat(cult_mind.current, "<span class='danger'><FONT size = 3>An unfamiliar white light flashes through your mind, cleansing the taint of the dark-one and the memories of your time as his servant with it.</span></FONT>")
		cult_mind.memory = ""
		update_cult_icons_removed(cult_mind)
		if(show_message)
			cult_mind.current.visible_message("<span class='danger'><FONT size = 3>[cult_mind.current] looks like they just reverted to their old faith!</span></FONT>")

/datum/game_mode/proc/update_all_cult_icons()
	for(var/datum/mind/cultist in cult)
		if(cultist.current && cultist.current.client)
			for(var/image/I in cultist.current.client.images)
				if(I.icon_state == "cult")
					cultist.current.client.images -= I
					qdel(I)
	for(var/datum/mind/cultist in cult)
		if(cultist.current && cultist.current.client)
			for(var/datum/mind/cultist_1 in cult)
				if(cultist_1.current)
					var/I = image('icons/mob/mob.dmi', loc = cultist_1.current, icon_state = "cult")
					cultist.current.client.images += I


/datum/game_mode/proc/update_cult_icons_added(datum/mind/cult_mind)
	if(!cult_mind.current)
		return 0
	for(var/datum/mind/cultist in cult)
		if(cultist.current && cultist.current.client)
			var/I = image('icons/mob/mob.dmi', loc = cult_mind.current, icon_state = "cult")
			cultist.current.client.images += I
		if(cult_mind.current.client)
			var/image/J = image('icons/mob/mob.dmi', loc = cultist.current, icon_state = "cult")
			cult_mind.current.client.images += J

/datum/game_mode/proc/update_cult_icons_removed(datum/mind/cult_mind)
	if(!cult_mind.current)
		return 0
	for(var/datum/mind/cultist in cult)
		if(cultist.current && cultist.current.client)
			for(var/image/I in cultist.current.client.images)
				if(I.icon_state == "cult" && I.loc == cult_mind.current)
					cultist.current.client.images -= I
					qdel(I)
	if(cult_mind.current.client)
		for(var/image/I in cult_mind.current.client.images)
			if(I.icon_state == "cult")
				cult_mind.current.client.images -= I
				qdel(I)


/datum/game_mode/cult/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in human_list)
		if(!is_convertable_to_cult(player.mind))
			ucs += player.mind
	return ucs


/datum/game_mode/cult/proc/check_cult_victory()
	var/cult_fail = 0
	if(objectives.Find("survive"))
		cult_fail += check_survive() //the proc returns 1 if there are not enough cultists on the shuttle, 0 otherwise
	if(objectives.Find("eldergod"))
		cult_fail += eldergod //1 by default, 0 if the elder god has been summoned at least once
	if(objectives.Find("sacrifice"))
		if(sacrifice_target && !sacrificed.Find(sacrifice_target)) //if the target has been sacrificed, ignore this step. otherwise, add 1 to cult_fail
			cult_fail++

	return cult_fail //if any objectives aren't met, failure


/datum/game_mode/cult/proc/check_survive()
	acolytes_survived = 0
	for(var/datum/mind/cult_mind in cult)
		if (cult_mind.current && cult_mind.current.stat!=2)
			var/area/A = get_area(cult_mind.current )
			if ( is_type_in_typecache(A, centcom_areas_typecache))
				acolytes_survived++
	if(acolytes_survived>=acolytes_needed)
		return 0
	else
		return 1


/datum/game_mode/cult/declare_completion()
	if(config.objectives_disabled)
		return 1
	completion_text += "<h3>Cult mode resume:</h3>"
	if(!check_cult_victory())
		mode_result = "win - cult win"
		feedback_set_details("round_end_result",mode_result)
		feedback_set("round_end_result",acolytes_survived)
		completion_text += "<span class='color: red; font-weight: bold;'>The cult <span style='color: green'>wins</span>! It has succeeded in serving its dark masters!</span><br>"
		score["roleswon"]++
	else
		mode_result = "loss - staff stopped the cult"
		feedback_set_details("round_end_result",mode_result)
		feedback_set("round_end_result",acolytes_survived)
		completion_text += "<span class='color: red; font-weight: bold;'>The staff managed to stop the cult!</span><br>"

	var/text = "<b>Cultists escaped:</b> [acolytes_survived]"
	if(!config.objectives_disabled)
		if(objectives.len)
			text += "<br><b>The cultists' objectives were:</b>"
			for(var/obj_count in 1 to objectives.len)
				var/explanation
				switch(objectives[obj_count])
					if("survive")
						if(!check_survive())
							explanation = "Make sure at least [acolytes_needed] acolytes escape on the shuttle. <span style='color: green; font-weight: bold;'>Success!</span>"
							feedback_add_details("cult_objective","cult_survive|SUCCESS|[acolytes_needed]")
						else
							explanation = "Make sure at least [acolytes_needed] acolytes escape on the shuttle. <span style='color: red; font-weight: bold;'>Fail.</span>"
							feedback_add_details("cult_objective","cult_survive|FAIL|[acolytes_needed]")
					if("sacrifice")
						if(sacrifice_target)
							if(sacrifice_target in sacrificed)
								explanation = "Sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role]. <span style='color: green; font-weight: bold;'>Success!</span>"
								feedback_add_details("cult_objective","cult_sacrifice|SUCCESS")
							else if(sacrifice_target && sacrifice_target.current)
								explanation = "Sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role]. <span style='color: red; font-weight: bold;'>Fail.</span>"
								feedback_add_details("cult_objective","cult_sacrifice|FAIL")
							else
								explanation = "Sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role]. <span style='color: red; font-weight: bold;'>Fail (Gibbed).</span>"
								feedback_add_details("cult_objective","cult_sacrifice|FAIL|GIBBED")
						else
							explanation = "Free objective. <span style='color: green; font-weight: bold;'>Success!</span>"
							feedback_add_details("cult_objective","cult_free_objective|SUCCESS")
					if("eldergod")
						if(!eldergod)
							explanation = "Summon Nar-Sie. <span style='color: green; font-weight: bold;'>Success!</span>"
							feedback_add_details("cult_objective","cult_narsie|SUCCESS")
						else
							explanation = "Summon Nar-Sie. <span style='color: red; font-weight: bold;'>Fail.</span>"
						feedback_add_details("cult_objective","cult_narsie|FAIL")
				text += "<br><b>Objective #[obj_count]</b>: [explanation]"

	completion_text += text
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_cult()
	var/text = ""
	if( cult.len || (SSticker && istype(SSticker.mode,/datum/game_mode/cult)) )
		text += printlogo("cult", "cultists")
		for(var/datum/mind/cultist in cult)
			text += printplayerwithicon(cultist)

	if(text)
		antagonists_completion += list(list("mode" = "cult", "html" = text))
		text = "<div class='block'>[text]</div>"

	return text
