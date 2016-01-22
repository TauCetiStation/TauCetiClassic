/*
VOX HEIST ROUNDTYPE
*/

/datum/game_mode/
	var/list/datum/mind/raiders = list()  //Antags.

/datum/game_mode/heist
	name = "heist"
	config_tag = "heist"
	required_players = 15
	required_players_secret = 15
	required_enemies = 4
	recommended_enemies = 6

	votable = 0

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/list/raid_objectives = list()     //Raid objectives.
	var/list/obj/cortical_stacks = list() //Stacks for 'leave nobody behind' objective.

/datum/game_mode/heist/announce()
	world << "<B>The current game mode is - Heist!</B>"
	world << "<B>An unidentified bluespace signature has slipped past the Icarus and is approaching [station_name()]!</B>"
	world << "Whoever they are, they're likely up to no good. Protect the crew and station resources against this dastardly threat!"
	world << "<B>Raiders:</B> Loot [station_name()] for anything and everything you need."
	world << "<B>Personnel:</B> Repel the raiders and their low, low prices and/or crossbows."

/datum/game_mode/heist/can_start()

	if(!..())
		return 0

	var/list/candidates = get_players_for_role(BE_RAIDER)
	var/raider_num = 0

	//Check that we have enough vox.
	if(candidates.len < required_enemies)
		return 0
	else if(candidates.len < recommended_enemies)
		raider_num = candidates.len
	else
		raider_num = recommended_enemies

	//Grab candidates randomly until we have enough.
	while(raider_num > 0)
		var/datum/mind/new_raider = pick(candidates)
		raiders += new_raider
		candidates -= new_raider
		raider_num--

	for(var/datum/mind/raider in raiders)
		raider.assigned_role = "MODE"
		raider.special_role = "Raider"
	return 1

/datum/game_mode/heist/pre_setup()
	return 1

/datum/game_mode/heist/post_setup()

	//Build a list of spawn points.
	var/list/turf/raider_spawn = list()

	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "voxstart")
			raider_spawn += get_turf(L)
			qdel(L)
			continue

	//Generate objectives for the group.
	if(!config.objectives_disabled)
		raid_objectives = forge_vox_objectives()

	var/index = 1
	var/captain = 1

	//Spawn the vox!
	for(var/datum/mind/raider in raiders)

		if(index > raider_spawn.len)
			index = 1

		raider.current.loc = raider_spawn[index]
		index++

		//var/sounds = rand(2,8)
		//var/i = 0
		var/newname = ""

		if(captain)
			captain = 0
			newname += "Captain "
		else
			newname += pick(list("Diry ","Squidlips ","Bowman ","Buccaneer ","Two Toes ","Carpbait ","Old ",
				"Fluffbucket ","Scallywag ","Bucko ","Dead man ","Matey ","Jolly ","Stinky ","Bloody ","Miss ",
				"Mad ","Red ","Lady ","Bretheren ","Rapscallion ","Landlubber ","Wrench ","Freeboter "))

		newname += pick(list("Creeper ","Jim ","Storm ","John ","George ","O` ","Rat ","Jack ","Legs ",
			"Head ","Cackle ","Patch ","Bones ","Plank ","Greedy ","Space ","Mama ","Spike ",
			"Squiffy ","Gold ","Yellow ","Felony ","Eddie ","Bay ","Thomas ","Spot "))

		newname += pick(list("From the West","Byrd","Jackson","Sparrow","Of the Coast","Jones","Ned Head","Bart","O`Carp",
			"Kidd","O`Malley","Barnacle","Holystone","Hornswaggle","McStinky","Swashbuckler","Space Wolf","Beard",
			"Chumbucket","Rivers","Morgan","Tuna Breath","Three Gates","Bailey","Of Atlantis","Of Dark Space"))

		var/mob/living/carbon/human/vox = raider.current

		vox.real_name = newname
		vox.name = vox.real_name
		raider.name = vox.name
		vox.age = rand(17,85)
		//vox.dna.mutantrace = "vox"
		//vox.set_species("Vox")
		vox.languages = list() // Removing language from chargen.
		vox.flavor_text = ""
		vox.add_language("Gutter")
		vox.h_style = "Skinhead"
		vox.f_style = "Shaved"
		//for(var/datum/organ/external/limb in vox.organs)
		//	limb.status &= ~(ORGAN_DESTROYED | ORGAN_ROBOT)
		vox.equip_raider()
		vox.regenerate_icons()

		raider.objectives = raid_objectives
		greet_vox(raider)

	for(var/atom/movable/AM in locate(/area/shuttle/vox/station))
		heist_recursive_price_reset(AM)

	spawn (rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/heist/proc/is_raider_crew_safe()
	if(cortical_stacks.len == 0)
		return 0

	for(var/obj/stack in cortical_stacks)
		if (get_area(stack) != locate(/area/shuttle/vox/station))
			return 0
	return 1

/datum/game_mode/heist/proc/is_raider_crew_alive()
	for(var/datum/mind/raider in raiders)
		if(raider.current)
			if(istype(raider.current,/mob/living/carbon/human) && raider.current.stat != 2)
				return 1
	return 0

/datum/game_mode/heist/proc/forge_vox_objectives()
	var/list/objs = list()
	var/datum/objective/heist/O = new /datum/objective/heist/robbery()
	O.choose_target()
	objs += O

	return objs

/datum/game_mode/heist/proc/greet_vox(var/datum/mind/raider)
	raider.current << "\blue <B>You are a Pirate....ARGH!</b>"
	//raider.current << "\blue The Vox are a race of cunning, sharp-eyed nomadic raiders and traders endemic to Tau Ceti and much of the unexplored galaxy. You and the crew have come to the Exodus for plunder, trade or both."
	//raider.current << "\blue Vox are cowardly and will flee from larger groups, but corner one or find them en masse and they are vicious."
	raider.current << "\blue Use :3 to guttertalk, :H to talk on your encrypted channel!"
	var/obj_count = 1
	if(!config.objectives_disabled)
		for(var/datum/objective/objective in raider.objectives)
			raider.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
			obj_count++
	//else
	//	raider.current << "<font color=blue>Within the rules,</font> try to act as an opposing force to the crew or come up with other fun ideas. Further RP and try to make sure other players have </i>fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>"


/datum/game_mode/heist/declare_completion()

	//No objectives, go straight to the feedback.
	if(!(raid_objectives.len)) return ..()

	var/win_type = "Major"
	var/win_group = "Crew"
	var/win_msg = ""

	var/success = raid_objectives.len

	//Decrease success for failed objectives.
	for(var/datum/objective/O in raid_objectives)
		if(!(O.check_completion())) success--

	//Set result by objectives.
	if(success == raid_objectives.len)
		win_type = "Major"
		win_group = "Raider"
	else if(success > 2)
		win_type = "Minor"
		win_group = "Raider"
	else
		win_type = "Minor"
		win_group = "Crew"

	//Now we modify that result by the state of the pirate crew.
	if(!is_raider_crew_alive())
		win_type = "Major"
		win_group = "Crew"
		win_msg += "<B>The Raiders have been wiped out!</B>"
	else
		if(win_group == "Raider")
			if(win_type == "Minor")
				win_type = "Major"
			win_msg += "<B>The Raiders escaped the station!</B>"
		else
			win_msg += "<B>The Raiders were repelled!</B>"

	world << "\red <FONT size = 3><B>[win_type] [win_group] victory!</B></FONT>"
	world << "[win_msg]"
	feedback_set_details("round_end_result","heist - [win_type] [win_group]")

	var/count = 1
	for(var/datum/objective/objective in raid_objectives)
		if(objective.check_completion())
			if(objective.target == "valuables")
				world << "<br><B>Objective #[count]</B>: [objective.explanation_text] ([num2text(heist_rob_total,9)]/[num2text(objective.target_amount,9)]) <font color='green'><B>Success!</B></font>"
				feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
			else
				world << "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
				feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
		else
			if(objective.target == "valuables")
				world << "<br><B>Objective #[count]</B>: [objective.explanation_text] ([num2text(heist_rob_total,9)]/[num2text(objective.target_amount,9)]) <font color='red'>Fail.</font>"
				feedback_add_details("traitor_objective","[objective.type]|FAIL")
			else
				world << "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
				feedback_add_details("traitor_objective","[objective.type]|FAIL")
		count++

	..()

datum/game_mode/proc/auto_declare_completion_heist()
	if(raiders.len)
		var/loot_savefile = "data/pirate_loot.sav" //loot statistics
		var/savefile/S = new /savefile(loot_savefile)
		if(S)
			S.cd = "/"
			var/max_score = heist_rob_total
			var/sav_score
			S["HeistMaxScore"] >> sav_score
			sav_score = text2num(sav_score)
			if(!sav_score)
				sav_score = 0
			if(max_score > sav_score)
				S["HeistMaxScore"] << num2text(heist_rob_total,9)
			for(var/atom/movable/AM in locate(/area/shuttle/vox/station))
				if(AM.get_price())
					var/count = 0
					S["[AM.type]"] >> count
					count++
					S["[AM.type]"] << count

		var/text = "<FONT size = 2><B>The raiders were:</B></FONT>"
		for(var/datum/mind/raider in raiders)
			text += "<br>[raider.key] was [raider.name] ("
			if(raider.current)
				var/area/A = get_area(raider.current)
				if(!istype(A, /area/shuttle/vox/station))
					text += "left behind)"
					continue
				else if(raider.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(raider.current.real_name != raider.name)
					text += " as [raider.current.real_name]"
			else
				text += "body destroyed"
			text += ")"

		world << text
	return 1

/datum/game_mode/heist/check_finished()
	if (!(is_raider_crew_alive()) || (vox_shuttle_location && (vox_shuttle_location == "start")))
		return 1
	return ..()
