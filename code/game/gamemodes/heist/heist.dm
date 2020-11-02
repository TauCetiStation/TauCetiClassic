//not used, look heist_old (wtf)

/obj/effect/landmark/heist/aurora //used to locate shuttle.
	name = "Aurora"
	icon_state = "x3"

/obj/effect/landmark/heist/mob_loot //fulton - locate where to drop mobs.
	name = "mob loot"
	icon_state = "x3"

/obj/effect/landmark/heist/obj_loot //fulton - locate where to drop objs.
	name = "obj loot"
	icon_state = "x3"

/datum/game_mode
	var/list/datum/mind/raiders = list()  //Antags.

/datum/game_mode/heist
	name = "heist"
	config_tag = "heist"
	role_type = ROLE_RAIDER
	required_players = 15
	required_players_secret = 25
	required_enemies = 4
	recommended_enemies = 6

	votable = 0

	var/list/raid_objectives = list()     //Raid objectives.
	var/list/obj/cortical_stacks = list() //Stacks for 'leave nobody behind' objective.

/datum/game_mode/heist/announce()
	to_chat(world, "<B>The current game mode is - Heist!</B>")
	to_chat(world, "<B>An unidentified bluespace signature has slipped past the Icarus and is approaching [station_name()]!</B>")
	to_chat(world, "Whoever they are, they're likely up to no good. Protect the crew and station resources against this dastardly threat!")
	to_chat(world, "<B>Raiders:</B> Loot [station_name()] for anything and everything you need.")
	to_chat(world, "<B>Personnel:</B> Repel the raiders and their low, low prices and/or guns.")

/datum/game_mode/heist/can_start()
	if (!..())
		return FALSE
	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "voxstart")
			return TRUE
	return FALSE

/datum/game_mode/heist/assign_outsider_antag_roles()
	if(!..())
		return FALSE

	var/raider_num = recommended_enemies

	//Check that we have enough vox.
	if(antag_candidates.len < recommended_enemies)
		raider_num = antag_candidates.len

	//Grab candidates randomly until we have enough.
	while(raider_num > 0)
		var/datum/mind/new_raider = pick(antag_candidates)
		raiders += new_raider
		modePlayer += new_raider
		antag_candidates -= new_raider
		raider_num--

	for(var/datum/mind/raider in raiders)
		raider.assigned_role = "MODE"
		raider.special_role = "Raider"
	return TRUE

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
		vox.age = rand(vox.species.min_age, vox.species.max_age)
		//vox.dna.mutantrace = "vox"
		//vox.set_species(VOX)
		vox.languages = list() // Removing language from chargen.
		vox.flavor_text = ""
		vox.add_language("Gutter")
		vox.h_style = "Skinhead"
		vox.f_style = "Shaved"
		//for(var/obj/item/organ/external/BP in vox.bodyparts)
		//	BP.status &= ~(ORGAN_DESTROYED | ORGAN_ROBOT)
		vox.equip_raider()
		vox.regenerate_icons()

		raider.objectives = raid_objectives
		greet_vox(raider)

	for(var/atom/movable/AM in locate(/area/shuttle/vox/arkship))
		heist_recursive_price_reset(AM)

	return ..()

/datum/game_mode/heist/proc/is_raider_crew_safe()
	if(cortical_stacks.len == 0)
		return 0

	for(var/obj/stack in cortical_stacks)
		if (get_area(stack) != locate(/area/shuttle/vox/arkship))
			return 0
	return 1

/datum/game_mode/heist/proc/is_raider_crew_alive()
	for(var/datum/mind/raider in raiders)
		if(raider.current)
			if(istype(raider.current,/mob/living/carbon/human) && raider.current.stat != DEAD)
				return 1
	return 0

/datum/game_mode/heist/proc/forge_vox_objectives()
	var/list/objs = list()
	var/datum/objective/heist/O = new /datum/objective/heist/robbery()
	O.choose_target()
	objs += O

	return objs

/datum/game_mode/heist/proc/greet_vox(datum/mind/raider)
	var/msg = ""
	to_chat(raider.current, "<span class='info'><B>You are a <font color='red'>Pirate</font>....ARGH!</B></span>")
	to_chat(raider.current, "<span class='info'>Use :3 to guttertalk, :H to talk on your encrypted channel!</span>")
	msg = "У вашего капитана имеется fulton recovery pack! Используйте его, чтобы быстро доставить все что угодно на ваш корабль (если цель живая - попадет в комнату удержания на шаттле)."
	to_chat(raider.current, "[sanitize(msg)]")
	msg = "На вашем корабле лежат семена кудзу и эксклюзивные кубические гранаты! Используйте их на станции, чтобы сеять хаос (осторожно, гранаты содержат агрессивную живность которая с удовольствием перекусит даже вами, а семена можно сажать прямо на пол станции)."
	to_chat(raider.current, "<span class='info'>[sanitize(msg)]</span>")
	msg = "Ваша винтовка и пистолет модифицированы для использования специальных сверхзвуковых снарядов нового поколения, они не наносят вреда обычным живым существам но имеют огромную силу удара, что позволяет вывести из боя человека нацепившего на себя много брони, а синтетам и мехам наносит колоссальный вред."
	to_chat(raider.current, "[sanitize(msg)]")
	msg = "Debugger который вы найдете на корабле - поможет вам со взломом APC и дверей. Учтите что такой метод наносит вред программному обеспечению и в случае с дверьми - попросту сжигает плату. Не используйте его на дверях с опущенными болтами, конечно если ваша цель не является полностью заблокировать дверь."
	to_chat(raider.current, "<span class='info'>[sanitize(msg)]</span>")
	var/obj_count = 1
	if(!config.objectives_disabled)
		for(var/datum/objective/objective in raider.objectives)
			to_chat(raider.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++

/datum/game_mode/heist/declare_completion()

	//No objectives, go straight to the feedback.
	if(!(raid_objectives.len)) return ..()

	completion_text += "<B>Heist mode resume:</B><BR>"

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
			score["roleswon"]++
		else
			win_msg += "<B>The Raiders were repelled!</B>"

	completion_text += "<FONT size = 3, color='red'><B>[win_type] [win_group] victory!</B></FONT>"
	completion_text += "<BR>[win_msg]"

	mode_result = "heist - [win_type] [win_group]"
	feedback_set_details("round_end_result",mode_result)

	var/count = 1
	for(var/datum/objective/objective in raid_objectives)
		if(objective.check_completion())
			if(objective.target == "valuables")
				completion_text += "<BR><B>Objective #[count]</B>: [objective.explanation_text] ([num2text(heist_rob_total,9)]/[num2text(objective.target_amount,9)]) <span style='color: green; font-weight: bold;'>Success!</span>"
				feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
			else
				completion_text += "<BR><B>Objective #[count]</B>: [objective.explanation_text] <span style='color: green; font-weight: bold;'>Success!</span>"
				feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
		else
			if(objective.target == "valuables")
				completion_text += "<BR><B>Objective #[count]</B>: [objective.explanation_text] ([num2text(heist_rob_total,9)]/[num2text(objective.target_amount,9)]) <span style='color: red; font-weight: bold;'>Fail.</span>"
				feedback_add_details("traitor_objective","[objective.type]|FAIL")
			else
				completion_text += "<BR><B>Objective #[count]</B>: [objective.explanation_text] <span style='color: red; font-weight: bold;'>Fail.</span>"
				feedback_add_details("traitor_objective","[objective.type]|FAIL")
		count++

	if(heist_rob_total == 0)
		heist_get_shuttle_price()
		completion_text += "<BR><BR>Estimated value of valuables left on Aurora - $<font color='red'>[num2text(heist_rob_total,9)]</font> spacebucks."
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_heist()
	var/text =""
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
			for(var/atom/movable/AM in locate(/area/shuttle/vox/arkship))
				if(AM.get_price())
					var/count = 0
					S["[AM.type]"] >> count
					count++
					S["[AM.type]"] << count

		text += printlogo("raider", "raiders")
		for(var/datum/mind/raider in raiders)
			if(raider.current)
				var/icon/flat = getFlatIcon(raider.current,exact=1)
				end_icons += flat
				var/tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[raider.key]</b> was <b>[raider.name]</b> ("}
				var/area/A = get_area(raider.current)
				if(!istype(A, /area/shuttle/vox/arkship))
					text += "left behind)"
					continue
				else if(raider.current.stat == DEAD)
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else
					text += "survived"
				if(raider.current.real_name != raider.name)
					text += " as [raider.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "gibbearcore")
				end_icons += sprotch
				var/tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> [raider.key] was [raider.name] ("}
				text += "body destroyed"
			text += ")"

	if(text)
		antagonists_completion += list(list("mode" = "heist", "html" = text))
		text = "<div class='block'>[text]</div>"

	return text

/datum/game_mode/heist/check_finished()
	if (!(is_raider_crew_alive()) || (vox_shuttle_location && (vox_shuttle_location == "start")))
		return 1
	return ..()
